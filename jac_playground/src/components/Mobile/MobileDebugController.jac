cl import from "...lib.utils" { cn }
cl import from "lucide-react" { 
    Play, 
    Pause,
    SkipForward,
    ArrowUp, 
    RotateCw, 
    Square,
    StepForward,
    StepBack,
    Bug,
    X
}

cl {
    def: pub MobileDebugController(props: dict) -> any {
        onPlay = props.onPlay;
        onPause = props.onPause;
        onStepOver = props.onStepOver;
        onStepIn = props.onStepIn;
        onStepOut = props.onStepOut;
        onRestart = props.onRestart;
        onStop = props.onStop;
        isRunning = props.isRunning or false;
        isDebugging = props.isDebugging or false;
        onToggleDebug = props.onToggleDebug;
        className = props.className or "";
        
        has isExpanded: bool = false;
        
        # If not in debug mode, show a simple toggle button
        if not isDebugging {
            return (
                <button
                    onClick={onToggleDebug}
                    className={cn(
                        "fixed bottom-20 left-4 w-12 h-12 rounded-full shadow-lg",
                        "flex items-center justify-center z-[999]",
                        "bg-surface border border-border",
                        "transition-all duration-200 active:scale-95",
                        className
                    )}
                    aria-label="Enable Debug Mode"
                >
                    <Bug className="w-5 h-5 text-text-secondary" />
                </button>
            );
        }
        
        # Debug mode active - show expanded controls
        return (
            <div className={cn(
                "fixed bottom-20 left-4 z-[999]",
                "bg-surface border border-border rounded-2xl shadow-xl",
                "transition-all duration-200",
                isExpanded and "p-3" or "p-1",
                className
            )}>
                {isExpanded and (
                    <div className="space-y-3">
                        <div className="flex items-center justify-between">
                            <span className="text-xs font-semibold text-primary flex items-center gap-1.5">
                                <Bug className="w-3.5 h-3.5" />
                                Debug Mode
                            </span>
                            <button
                                onClick={lambda -> None { isExpanded = false; }}
                                className="p-1 rounded-full hover:bg-background transition-colors"
                                aria-label="Collapse"
                            >
                                <X className="w-4 h-4 text-text-secondary" />
                            </button>
                        </div>
                        
                        <div className="grid grid-cols-3 gap-2">
                            <button
                                onClick={onPlay}
                                disabled={isRunning}
                                className="flex flex-col items-center gap-1 p-2 rounded-lg bg-primary/10 hover:bg-primary/20 transition-colors disabled:opacity-50"
                                aria-label="Continue"
                            >
                                <Play className="w-5 h-5 text-primary" />
                                <span className="text-[10px] text-primary font-medium">Continue</span>
                            </button>
                            
                            <button
                                onClick={onStepOver}
                                className="flex flex-col items-center gap-1 p-2 rounded-lg bg-background hover:bg-surface-hover transition-colors"
                                aria-label="Step Over"
                            >
                                <StepForward className="w-5 h-5 text-text-secondary" />
                                <span className="text-[10px] text-text-secondary font-medium">Over</span>
                            </button>
                            
                            <button
                                onClick={onStepIn}
                                className="flex flex-col items-center gap-1 p-2 rounded-lg bg-background hover:bg-surface-hover transition-colors"
                                aria-label="Step Into"
                            >
                                <StepBack className="w-5 h-5 text-text-secondary" />
                                <span className="text-[10px] text-text-secondary font-medium">Into</span>
                            </button>
                            
                            <button
                                onClick={onStepOut}
                                className="flex flex-col items-center gap-1 p-2 rounded-lg bg-background hover:bg-surface-hover transition-colors"
                                aria-label="Step Out"
                            >
                                <ArrowUp className="w-5 h-5 text-text-secondary" />
                                <span className="text-[10px] text-text-secondary font-medium">Out</span>
                            </button>
                            
                            <button
                                onClick={onRestart}
                                className="flex flex-col items-center gap-1 p-2 rounded-lg bg-warning/10 hover:bg-warning/20 transition-colors"
                                aria-label="Restart"
                            >
                                <RotateCw className="w-5 h-5 text-warning" />
                                <span className="text-[10px] text-warning font-medium">Restart</span>
                            </button>
                            
                            <button
                                onClick={onStop}
                                className="flex flex-col items-center gap-1 p-2 rounded-lg bg-error/10 hover:bg-error/20 transition-colors"
                                aria-label="Stop"
                            >
                                <Square className="w-5 h-5 text-error" />
                                <span className="text-[10px] text-error font-medium">Stop</span>
                            </button>
                        </div>
                        
                        <button
                            onClick={onToggleDebug}
                            className="w-full py-2 text-xs text-text-secondary hover:text-text-primary transition-colors"
                        >
                            Exit Debug Mode
                        </button>
                    </div>
                )}
                
                {(not isExpanded) and (
                    <button
                        onClick={lambda -> None { isExpanded = true; }}
                        className="w-10 h-10 rounded-xl bg-warning/20 flex items-center justify-center"
                        aria-label="Expand Debug Controls"
                    >
                        <Bug className="w-5 h-5 text-warning" />
                    </button>
                )}
            </div>
        );
    }
}
