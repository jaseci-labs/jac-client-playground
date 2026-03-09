"""Shared fixtures for playground E2E tests."""

import os
import socket
import subprocess
import time

import pytest
from playwright.sync_api import Page

PLAYGROUND_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "jac_playground")
)
APP_PATH = "/cl/app"
ENV_READY_TIMEOUT = 180_000  # 3 min for Pyodide + jaclang.zip


def _get_free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def _wait_for_port(port: int, timeout: float = 60.0) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.connect(("127.0.0.1", port))
                return True
        except OSError:
            time.sleep(0.5)
    return False


@pytest.fixture(scope="session")
def base_url():
    """Start the playground server, yield its base URL."""
    port = _get_free_port()
    proc = subprocess.Popen(
        ["jac", "start", "--port", str(port)],
        cwd=PLAYGROUND_DIR,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    assert _wait_for_port(port), f"Server failed to start on port {port}"
    yield f"http://127.0.0.1:{port}"
    proc.terminate()
    try:
        proc.wait(timeout=10)
    except subprocess.TimeoutExpired:
        proc.kill()


@pytest.fixture(scope="module")
def app(browser, base_url) -> Page:
    """Navigate to playground, wait for Pyodide ready.

    Module-scoped to avoid reloading Pyodide per test (~120s).
    """
    context = browser.new_context()
    page = context.new_page()
    page.goto(f"{base_url}{APP_PATH}", wait_until="networkidle")
    page.get_by_text("Ready").wait_for(timeout=ENV_READY_TIMEOUT)
    yield page
    context.close()
