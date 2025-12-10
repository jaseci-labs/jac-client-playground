cl import from "...lib.utils" { cn }
cl import from "..ui.Button" { Button }
cl import from ".run-control" { RunController }
cl import from ".debug-control" { DebugController }

cl {
    def ControllerWrapper(props: dict) -> any {
        return <div className="w-full flex items-center gap-4 px-4 pt-4 pb-2 bg-background ">{props.children}</div>;
    }
    def ContextToolbar(props: dict) -> any {
        let mode = props.mode or "jac";
        let onRun = props.onRun;
        let onReset = props.onReset;
        let onConvert = props.onConvert;
        let isRunning = props.isRunning or false;
        let isConverting = props.isConverting or false;
        
        # Jac Mode - Run/Reset + Debugger
        if mode == "jac" {
            return (
                <ControllerWrapper>
                <>
                    <RunController 
                        onRun={onRun} 
                        onReset={onReset}
                        isRunning={isRunning}
                    />
                    
                    <div className="w-px h-6 bg-border" />
                    
                    <div className="flex items-center gap-2">
                        <span className="text-xs text-text-secondary font-medium">Debugger:</span>
                        <DebugController />
                    </div>
                    </>
                </ControllerWrapper>
            );
        }
        
        # Jac → Python Mode
        if mode == "jac2py" {
            return (
                <ControllerWrapper>
                    <Button 
                        variant="primary" 
                        size="sm" 
                        onClick={onConvert}
                        disabled={isConverting}
                    >
                        <span>{isConverting and "Converting..." or "Convert"}</span>
                    </Button>
                </ControllerWrapper>
            );
        }
        
        # Python → Jac Mode
        if mode == "py2jac" {
            return (
                <ControllerWrapper>
                    <Button 
                        variant="primary" 
                        size="sm" 
                        onClick={onConvert}
                        disabled={isConverting}
                    >
                        <span>{isConverting and "Converting..." or "Convert"}</span>
                    </Button>
                </ControllerWrapper>
            );
        }
        
        return <div />;
    }
}
