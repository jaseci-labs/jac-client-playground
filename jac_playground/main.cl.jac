import ".styles.global.css";
import from .components.PlayGroundLayout { PlayGroundLayout }
import from react { useEffect }

def: pub app() -> None {
    has examples: list = [];

    useEffect(lambda -> None {
        async def loadExamples() -> None {
            response = load_example_list() spawn root;
            examples = response.reports[0];
        }
        loadExamples();
    }, []);

    return (
        <main>
            <PlayGroundLayout examples={examples} />
        </main>
    );
}
