"""E2E tests for the Jac Playground.

Tests cover: environment loading, example selection, code execution,
jac2py/py2jac conversion, and graph visualization.

Prerequisites:
    pip install playwright pytest-playwright
    playwright install chromium --with-deps

Run:
    pytest tests/e2e/test_playground.py -v
    pytest tests/e2e/test_playground.py -v -k execution
    pytest tests/e2e/test_playground.py -v --headed
"""

from playwright.sync_api import Page, expect

PYODIDE_TIMEOUT = 120_000  # 2 min for code execution
CONVERT_TIMEOUT = 60_000  # 1 min for conversion


# -- Helpers -------------------------------------------------------------------


def select_example(page: Page, title: str):
    """Click an example in the right panel by its display title."""
    page.get_by_text(title, exact=True).click()
    page.wait_for_timeout(500)


def run_and_wait(page: Page, timeout: int = PYODIDE_TIMEOUT):
    """Click Run and wait for execution to complete."""
    run_btn = page.get_by_role("button", name="Run")
    run_btn.click()
    # Wait for status to cycle through Running -> Ready
    page.get_by_text("Ready").wait_for(timeout=timeout)


def convert_and_wait(page: Page, timeout: int = CONVERT_TIMEOUT):
    """Click Convert and wait for conversion to complete."""
    convert_btn = page.get_by_role("button", name="Convert")
    convert_btn.wait_for(state="visible", timeout=timeout)
    convert_btn.click()
    page.get_by_text("Ready").wait_for(timeout=timeout)


def switch_mode(page: Page, mode: str):
    """Switch playground mode via the activity bar."""
    labels = {
        "jac": "Jac Playground",
        "jac2py": "Jac → Python",
        "py2jac": "Python → Jac",
    }
    page.get_by_role("button", name=labels[mode]).click()
    page.wait_for_timeout(300)


def get_editor_content(page: Page, model_index: int = 0) -> str:
    """Get the content of a Monaco editor model by index (supports negative)."""
    return page.evaluate(
        f"""() => {{
            if (typeof monaco === 'undefined') return '';
            const models = monaco.editor.getModels();
            const idx = {model_index} < 0 ? models.length + {model_index} : {model_index};
            return idx >= 0 && idx < models.length ? models[idx].getValue() : '';
        }}"""
    )


def set_editor_content(page: Page, code: str, model_index: int = 0):
    """Set the content of a Monaco editor model by index."""
    escaped = code.replace("\\", "\\\\").replace("`", "\\`").replace("$", "\\$")
    page.evaluate(
        f"""() => {{
            if (typeof monaco === 'undefined') return;
            const models = monaco.editor.getModels();
            if (models.length > {model_index}) {{
                models[{model_index}].setValue(`{escaped}`);
            }}
        }}"""
    )


def get_output_text(page: Page) -> str:
    """Get text from the console output area."""
    page.get_by_text("Output", exact=True).first.click()
    page.wait_for_timeout(300)
    return page.evaluate(
        """() => {
            const pres = document.querySelectorAll('pre');
            return Array.from(pres).map(el => el.textContent).join('\\n');
        }"""
    )


def reset_playground(page: Page):
    """Click Reset to clear editor and output."""
    reset_btn = page.get_by_role("button", name="Reset")
    if reset_btn.is_visible():
        reset_btn.click()
        page.wait_for_timeout(300)


# -- Rendering tests -----------------------------------------------------------


class TestRendering:
    """Verify the playground UI loads correctly."""

    def test_environment_ready(self, app: Page):
        """Pyodide environment loads and shows Ready status."""
        expect(app.get_by_text("Ready")).to_be_visible()
        expect(app.get_by_role("button", name="Jac Playground")).to_be_visible()

    def test_editor_loads(self, app: Page):
        """Monaco editor is visible."""
        expect(app.locator(".monaco-editor").first).to_be_visible()

    def test_examples_visible(self, app: Page):
        """Example categories are shown in the right panel."""
        expect(app.get_by_text("basic")).to_be_visible()
        expect(app.get_by_text("object_spatial")).to_be_visible()

    def test_example_loads_code(self, app: Page):
        """Selecting an example populates the editor with code."""
        select_example(app, "If Statements")
        content = get_editor_content(app)
        assert "Good Enough" in content, f"Editor should contain example code, got: {content[:100]}"


# -- Execution tests -----------------------------------------------------------


class TestExecution:
    """Verify code runs and produces correct output."""

    def test_run_if_statements(self, app: Page):
        """if_statements example outputs 'Good Enough'."""
        reset_playground(app)
        switch_mode(app, "jac")
        select_example(app, "If Statements")
        run_and_wait(app)
        output = get_output_text(app)
        assert "Good Enough" in output, f"Expected 'Good Enough', got: {output}"

    def test_run_while_statements(self, app: Page):
        """while_statements example outputs numbers 1-5."""
        reset_playground(app)
        switch_mode(app, "jac")
        select_example(app, "While Statements")
        run_and_wait(app)
        output = get_output_text(app)
        for i in range(1, 6):
            assert str(i) in output, f"Expected '{i}' in output, got: {output}"

    def test_run_greeting_walker(self, app: Page):
        """greeting_friends_walker example greets Alice, Bob, Charlie."""
        reset_playground(app)
        switch_mode(app, "jac")
        select_example(app, "Greeting Friends Walker")
        run_and_wait(app)
        output = get_output_text(app)
        assert "Hello, Alice" in output, f"Expected greeting for Alice, got: {output}"
        assert "Hello, Bob" in output, f"Expected greeting for Bob, got: {output}"
        assert "Hello, Charlie" in output, f"Expected greeting for Charlie, got: {output}"


# -- Conversion tests ----------------------------------------------------------


class TestConversion:
    """Verify jac2py and py2jac conversions work."""

    def test_jac2py_produces_python(self, app: Page):
        """Converting Jac if_statements to Python produces valid Python."""
        reset_playground(app)
        # Select example first (selecting switches mode back to "jac")
        select_example(app, "If Statements")
        # Then switch to jac2py — code stays in the editor
        switch_mode(app, "jac2py")
        app.wait_for_timeout(500)
        convert_and_wait(app)
        # Wait for output model to have content
        app.wait_for_function(
            """() => {
                if (typeof monaco === 'undefined') return false;
                const models = monaco.editor.getModels();
                return models.length >= 2 && models[models.length - 1].getValue().trim().length > 0;
            }""",
            timeout=CONVERT_TIMEOUT,
        )
        output = get_editor_content(app, model_index=-1)
        assert "print" in output, f"Expected Python 'print' in output, got: {output[:200]}"

    def test_py2jac_produces_jac(self, app: Page):
        """Converting Python code to Jac produces Jac syntax."""
        reset_playground(app)
        switch_mode(app, "py2jac")
        app.wait_for_timeout(500)
        python_code = 'def greet(name):\n    print(f"Hello, {name}!")\n\ngreet("World")'
        set_editor_content(app, python_code, model_index=0)
        convert_and_wait(app)
        app.wait_for_function(
            """() => {
                if (typeof monaco === 'undefined') return false;
                const models = monaco.editor.getModels();
                return models.length >= 2 && models[models.length - 1].getValue().trim().length > 0;
            }""",
            timeout=CONVERT_TIMEOUT,
        )
        output = get_editor_content(app, model_index=-1)
        assert len(output.strip()) > 0, "Conversion should produce output"


# -- Graph tests ---------------------------------------------------------------


class TestGraph:
    """Verify graph visualization renders correctly."""

    def test_graph_renders_on_execution(self, app: Page):
        """Running graph-producing code renders a vis-network canvas."""
        reset_playground(app)
        switch_mode(app, "jac")
        select_example(app, "Family Relationship Graph")
        run_and_wait(app)
        # vis-network renders into a canvas element
        expect(app.locator("canvas").first).to_be_visible(timeout=10_000)

    def test_graph_output_has_nodes(self, app: Page):
        """Graph output contains expected family node names."""
        reset_playground(app)
        switch_mode(app, "jac")
        select_example(app, "Family Relationship Graph")
        run_and_wait(app)
        output = get_output_text(app)
        assert "John" in output, f"Expected 'John' in output, got: {output}"
        assert "Alice" in output, f"Expected 'Alice' in output, got: {output}"
        assert "Bob" in output, f"Expected 'Bob' in output, got: {output}"
