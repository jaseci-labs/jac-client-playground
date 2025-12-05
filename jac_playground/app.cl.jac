import from .pages.Index { Index }
import ".global.css";
import from .components.PlayGroundLayout { PlayGroundLayout }


def app() -> None {
    return 
        
        <main>
            <PlayGroundLayout />
            # <Index />
        </main>;
    
}
