
cl import from "..lib.utils" { cn }
cl import from ".ui.Button" { Button }
cl import from ".ui.IconButton" { IconButton }
cl import from "lucide-react" { Loader2 }

cl {
    def OutputConsole(props:dict) -> any {
        let onClear = props.onClear;
        let className = props.className or "";
        let isLoading = props.isLoading or false;

        return (
            <div className={cn("w-full h-72 bg-output p-3 text-sm text-output-foreground border-t border-border", className)}>
                <div className="flex items-center justify-between mb-2">
                    <div className="text-xs text-text-secondary">Output</div>
                    {
                        onClear and (
                          <Button
                              variant="outline"
                              size="sm"
                              onClick={onClear}
                          >
                              Clear
                          </Button>
                        )

                    }
                    {
                        isLoading and (
                            <div className="flex items-center text-xs text-text-secondary">
                               <IconButton>
                                   <Loader2 className="animate-spin h-4 w-4 text-primary" />
                               </IconButton>
                                Running...
                            </div>
                        )
                    }
                </div>

                
                <pre
                    className={"whitespace-pre-wrap text-sm " + ("text-red-400" if props.outIsError else "text-green-400")}>
                    {props.logs if props.logs else "No output yet. Click 'Run Code' to execute your code."}
                </pre>
            </div>
        );
    }
}