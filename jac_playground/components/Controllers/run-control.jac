cl import from "...lib.utils" { cn }
cl import from "lucide-react" { Play, RotateCcw }
cl import from "..ui.Button" { Button }

cl {
    def RunController(props: dict) -> any {
        let onRun = props.onRun;
        let onReset = props.onReset;
        let isRunning = props.isRunning or false;
        let className = props.className or "";
        
        return (
            <div className={cn("flex items-center gap-2", className)}>
                <Button 
                    variant="primary" 
                    size="sm" 
                    onClick={onRun}
                    disabled={isRunning}
                >
                    <Play className="w-4 h-4" />
                    <span>{isRunning and "Running..." or "Run"}</span>
                </Button>

                <Button 
                    variant="outline" 
                    size="sm" 
                    onClick={onReset}
                >
                    <RotateCcw className="w-4 h-4" />
                    <span>Reset</span>
                </Button>
            </div>
        );
    }
}
