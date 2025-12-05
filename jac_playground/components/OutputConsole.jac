
cl import from "..lib.utils" { cn }

cl {
    def OutputConsole(props:dict) -> any {
        let logs = props.output or [];
        let onClear = props.onClear;
        let className = props.className or "";
        let isLoading = props.isLoading or false;

        return (
            <div className={cn("w-full h-44 bg-output p-3 text-sm text-output-foreground border-t border-border", className)}>
                <div className="flex items-center justify-between mb-2">
                    <div className="text-xs text-text-secondary">Output</div>
                    <div className="flex items-center gap-2">
                        <button onClick={onClear} className="text-xs text-text-primary hover:underline">Clear</button>
                    </div>
                </div>

                
                <pre
                        className={"whitespace-pre-wrap text-sm " + ("text-red-400" if props.outIsError else "text-green-400")}>
                            {props.output if props.output else "No output yet. Click 'Run Code' to execute your code."}
                        </pre>
            </div>
        );
    }
}