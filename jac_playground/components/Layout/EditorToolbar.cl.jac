import from "lucide-react" { 
    Play, 
    RotateCcw, 
    Bug, 
    Loader2,
    ArrowRightLeft
}
import from "...lib.utils" { cn }
import from "..Controllers.debug-control" { DebugController }


def: pub EditorToolbar(props: dict) -> JsxElement {
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
    envReady = props.envReady or false;

    isJacMode = mode == "jac";
    isConversionMode = mode == "jac2py" or mode == "py2jac";
    
    return (
        <div className="flex items-center justify-between h-10 px-3 bg-surface/50 border-b border-border">
            <div className="flex items-center gap-1">
                {isJacMode and (
                    <>
                        <button
                            onClick={onRun}
                            disabled={isRunning or not envReady}
                            className={cn(
                                "flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all",
                                (not envReady) and "bg-border text-text-secondary cursor-not-allowed opacity-50"
                                    or (isRunning
                                        and "bg-primary/20 text-primary cursor-wait"
                                        or "bg-primary text-primary-foreground hover:bg-primary/90")
                            )}
                        >
                            {isRunning and (<Loader2 size={14} className="animate-spin" />) or (<Play size={14} />)}
                            <span>{isRunning and "Running..." or "Run"}</span>
                        </button>
                        
                        <button
                            onClick={onReset}
                            disabled={not envReady}
                            className={cn(
                                "flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs font-medium transition-all",
                                (not envReady) and "text-text-secondary opacity-50 cursor-not-allowed" or "text-text-secondary hover:bg-background"
                            )}
                        >
                            <RotateCcw size={14} />
                            <span>Reset</span>
                        </button>
                        
                        <div className="w-px h-5 bg-border mx-2" />
                        
                        <button
                            onClick={onDebug}
                            disabled={not envReady}
                            className={cn(
                                "flex items-center gap-1.5 px-2.5 py-1.5 rounded-md text-xs font-medium transition-all",
                                (not envReady) and "text-text-secondary opacity-50 cursor-not-allowed"
                                    or (isDebugging
                                        and "bg-warning/20 text-warning"
                                        or "text-text-secondary hover:bg-background")
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
                        disabled={isConverting or not envReady}
                        className={cn(
                            "flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-all",
                            (not envReady) and "bg-border text-text-secondary cursor-not-allowed opacity-50"
                                or (isConverting
                                    and "bg-primary/20 text-primary cursor-wait"
                                    or "bg-primary text-primary-foreground hover:bg-primary/90")
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

