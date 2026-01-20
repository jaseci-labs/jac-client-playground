import from services.fetch_examples { 
    load_example_list 
}

cl import from .components.Index { Index }
cl {
    def: pub app() -> None {
        return <Index />;
    }
}