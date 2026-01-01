import ".global.css";
import from .components.PlayGroundLayout { PlayGroundLayout }


def: pub app() -> None {
    return (
        <main>
            <PlayGroundLayout />
        </main>
    );
}
