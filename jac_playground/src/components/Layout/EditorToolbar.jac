cl import from react { useState }
cl import from "lucide-react" { 
    Play, 
    RotateCcw, 
    Bug, 
    Loader2,
    ArrowRightLeft
}
cl import from "...lib.utils" { cn }
cl import from "..Controllers.debug-control" { DebugController }

cl {
    def EditorToolbar(props: dict) -> any {
        mode = props.mode or "jac";
        onRun = props.onRun;
        onReset = props.onReset;
        onConvert = props.onConvert;
        onDebug = props.onDebug;
        onhandleDebugAction = props.onhandleDebugAction;
        onStop = props.onStop;
        isRunning = props.isRunning or false;
        isConverting = props.isConverting or false;
        isDebugging = props.isDebugging or false;
        
        isJacMode = mode == "jac";
        isConversionMode = mode == "jac2py" or mode == "py2jac";
        
        return (
            <div className="flex items-center justify-between h-10 px-3 bg-surface/50 border-b border-border">
                <div className="flex items-center gap-1">
                    {isJacMode and (
                        <>
                            <button
                                onClick={onRun}
                                disabled={isRunning}
                                className={cn(
                                    "flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all",
                                    isRunning 
                                        and "bg-primary/20 text-primary cursor-wait" 
                                        or "bg-primary text-primary-foreground hover:bg-primary/90"
                                )}
                            >
                                {isRunning and (<Loader2 size={14} className="animate-spin" />) or (<Play size={14} />)}
                                <span>{isRunning and "Running..." or "Run"}</span>
                            </button>
                            
                            <button
                                onClick={onReset}
                                className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs font-medium text-text-secondary hover:bg-background transition-all"
                            >
                                <RotateCcw size={14} />
                                <span>Reset</span>
                            </button>
                            
                            <div className="w-px h-5 bg-border mx-2" />
                            
                            <button
                                onClick={onDebug}
                                className={cn(
                                    "flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs font-medium transition-all",
                                    isDebugging 
                                        and "bg-warning/20 text-warning" 
                                        or "text-text-secondary hover:bg-background"
                                )}
                            >
                                <Bug size={14} />
                                <span>Debug</span>
                            </button>
                            
                            {isDebugging and (
                                <DebugController
                                    onhandleDebugAction={onhandleDebugAction}
                                    isRunning={isRunning}
                                />
                            )}
                        </>
                    )}
                    
                    {isConversionMode and (
                        <button
                            onClick={onConvert}
                            disabled={isConverting}
                            className={cn(
                                "flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all",
                                isConverting 
                                    and "bg-primary/20 text-primary cursor-wait" 
                                    or "bg-primary text-primary-foreground hover:bg-primary/90"
                            )}
                        >
                            {isConverting and (<Loader2 size={14} className="animate-spin" />) or (<ArrowRightLeft size={14} />)}
                            <span>{isConverting and "Converting..." or "Convert"}</span>
                        </button>
                    )}
                </div>
            </div>
        );
    }
}
