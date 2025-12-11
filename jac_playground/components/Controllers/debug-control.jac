cl import from "...lib.utils" { cn }
cl import from "lucide-react" { 
    Play, 
    SkipForward, 
    ArrowDown, 
    ArrowUp, 
    RotateCw, 
    Square,
    StepForward,
    StepBack
}

cl {
    def DebugButton(props: dict) -> any {
        let onClick = props.onClick;
        let icon = props.icon;
        let label = props.label or "";
        let variant = props.variant or "default";
        let disabled = props.disabled or false;
        
        let variantClasses = {
            "default": "text-text-secondary hover:bg-background hover:text-text-primary",
            "danger": "text-error hover:bg-error/10",
            "warning": "text-warning hover:bg-warning/10",
            "primary": "text-primary hover:bg-primary/10"
        };
        
        return (
            <button
                onClick={onClick}
                disabled={disabled}
                title={label}
                className={cn(
                    "flex items-center gap-1 px-2 py-1.5 rounded-md text-xs transition-all",
                    "disabled:opacity-50 disabled:cursor-not-allowed",
                    variantClasses[variant] or variantClasses["default"]
                )}
            >
                {icon}
            </button>
        );
    }

    def DebugController(props: dict) -> any {
        let onPlay = props.onPlay;
        let onStepOver = props.onStepOver;
        let onStepIn = props.onStepIn;
        let onStepOut = props.onStepOut;
        let onRestart = props.onRestart;
        let onStop = props.onStop;
        let isRunning = props.isRunning or false;
        let className = props.className or "";
        
        return (
            <div className={cn("inline-flex items-center gap-0.5", className)}>
                <DebugButton
                    icon={<Play size={14} />}
                    label="Continue (F5)"
                    onClick={onPlay}
                    variant="primary"
                />
                <DebugButton
                    icon={<StepForward size={14} />}
                    label="Step Over (F10)"
                    onClick={onStepOver}
                    variant="default"
                />
                <DebugButton
                    icon={<StepBack size={14} />}
                    label="Step Into (F11)"
                    onClick={onStepIn}
                    variant="default"
                />
                <DebugButton
                    icon={<ArrowUp size={14} />}
                    label="Step Out (Shift+F11)"
                    onClick={onStepOut}
                    variant="default"
                />
                <DebugButton
                    icon={<RotateCw size={14} />}
                    label="Restart (Ctrl+Shift+F5)"
                    onClick={onRestart}
                    variant="warning"
                />
                <DebugButton
                    icon={<Square size={14} />}
                    label="Stop (Shift+F5)"
                    onClick={onStop}
                    variant="danger"
                />
            </div>
        );
    }
}
