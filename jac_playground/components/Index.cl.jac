import from .PlayGroundLayout { PlayGroundLayout }
import "..styles.global.css";

def: pub Index() -> JsxElement {
    has examples: list = [];

    can with entry {
        async def loadExamples() -> None {
            response = load_example_list() spawn root;
            examples = response.reports[0];
        }
        loadExamples();
    }
 
    return (
        <main>
            <PlayGroundLayout examples={examples} />
        </main>
    );
}
