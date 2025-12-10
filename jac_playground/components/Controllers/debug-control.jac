cl import from "...lib.utils" { cn }
cl import from "lucide-react" { 
    Play, 
    SkipForward, 
    ArrowDown, 
    ArrowUp, 
    RotateCw, 
    Square 
}

cl {
    def ControlButton(props: dict) -> any {
        let onClick = props.onClick;
        let icon = props.icon;
        let label = props.label or "";
        let variant = props.variant or "default";
        let disabled = props.disabled or false;
        
        let variantClasses = {
            "default": "text-primary hover:bg-primary/20",
            "danger": "text-error hover:bg-error/20",
            "warning": "text-warning hover:bg-warning/20"
        };
        
        return (
            <button
                onClick={onClick}
                disabled={disabled}
                title={label}
                className={cn(
                    "size-8 rounded-full flex items-center justify-center",
                    " border border-border",
                    "transition-all duration-150",
                    "hover:scale-105 active:scale-95",
                    "disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100",
                    variantClasses[variant]
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
            <div className={cn(
                "inline-flex items-center gap-2 ",
                
                className
            )}>
                <ControlButton
                    icon={<Play className="size-3" />}
                    label="Run (F5)"
                    onClick={onPlay}
                    variant="default"
                />
                <ControlButton
                    icon={<SkipForward className="size-3" />}
                    label="Step Over (F10)"
                    onClick={onStepOver}
                    variant="default"
                />
                <ControlButton
                    icon={<ArrowDown className="size-3" />}
                    label="Step Into (F11)"
                    onClick={onStepIn}
                    variant="default"
                />
                <ControlButton
                    icon={<ArrowUp className="size-3" />}
                    label="Step Out (Shift+F11)"
                    onClick={onStepOut}
                    variant="default"
                />
                <ControlButton
                    icon={<RotateCw className="size-3" />}
                    label="Restart (Ctrl+Shift+F5)"
                    onClick={onRestart}
                    variant="warning"
                />
                <ControlButton
                    icon={<Square className="size-3" />}
                    label="Stop (Shift+F5)"
                    onClick={onStop}
                    variant="danger"
                />
            </div>
        );
    }
}
