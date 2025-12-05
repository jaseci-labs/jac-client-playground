cl import from "lucide-react" { Loader2, Terminal, Eraser }

cl {
    def OutputPanel(props: dict) -> any {

        return (
            <div className="flex flex-col h-full w-full bg-card text-foreground font-mono">
                <div className="flex items-center justify-between p-2 bg-muted/30 border-b flex-shrink-0">
                    <div className="flex items-center gap-2">
                        <Terminal className="h-4 w-4 text-primary" />
                        <h3 className="text-sm font-medium">Output</h3>
                    </div>

                    <div className="flex items-center gap-2">
                        {props.isLoading && (
                            <div className="flex items-center">
                            <Loader2 className="animate-spin mr-2 h-4 w-4 text-primary" />
                            <span className="text-xs">Running...</span>
                            </div>
                        )}
                        {props.onClear && (
                            <button
                                className="ml-2 p-1 text-xs bg-muted rounded hover:bg-muted/70 border border-muted-foreground/20 flex items-center justify-center"
                                onClick={props.onClear}
                                type="button"
                                title="Clear Output"
                                >
                                <Eraser className="h-4 w-4 text-muted-foreground" />
                            </button>
                        )}
                    </div>
                </div>
                
                <div className="flex-1 p-2 bg-editor-background text-editor-foreground overflow-auto">
                    <pre
                        className={"whitespace-pre-wrap text-sm " + ("text-red-400" if props.outIsError else "text-green-400")}>
                            {props.output if props.output else "No output yet. Click 'Run Code' to execute your code."}
                        </pre>
                </div>
            </div>
        );
    }
}
