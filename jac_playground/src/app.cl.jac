import ".global.css";
import from .components.PlayGroundLayout { PlayGroundLayout }
import from react { useState, useEffect }

def: pub app() -> None {
    [examples, setExamples] = useState([]);

    useEffect(lambda -> None {
        async def loadExamples() -> None {
            examples = load_example_list() spawn root;
            setExamples(examples.reports[0]);
        }
        loadExamples();
    }, []);

    return (
        <main>
            <PlayGroundLayout examples={examples} />
        </main>
    );
}
