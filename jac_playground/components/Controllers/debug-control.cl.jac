import from "...lib.utils" { cn }
import from "lucide-react" { 
    Play, 
    SkipForward, 
    ArrowDown, 
    ArrowUp, 
    RotateCw, 
    Square,
    StepForward,
    StepBack
}

def: pub DebugButton(props: dict) -> JsxElement {
    onClick = props.onClick;
    icon = props.icon;
    label = props.label or "";
    variant = props.variant or "default";
    disabled = props.disabled or false;
    
    variantClasses = {
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

def: pub DebugController(props: dict) -> JsxElement {
    onContinue = props.onContinue;
    onStepOver = props.onStepOver;
    onStepIn = props.onStepIn;
    onStepOut = props.onStepOut;
    onRestart = props.onRestart;
    onStop = props.onStop;
    isRunning = props.isRunning or false;
    className = props.className or "";
    onhandleDebugAction = props.onhandleDebugAction;
    
    return (
        <div className={cn("inline-flex items-center gap-0.5", className)}>
            <DebugButton
                icon={<Play size={14} />}
                label="Continue (F5)"
                onClick={lambda -> None {onhandleDebugAction("continue");}}
                variant="primary"
            />
            <DebugButton
                icon={<StepForward size={14} />}
                label="Step Over (F10)"
                onClick={lambda -> None {onhandleDebugAction("stepOver");}}
                variant="default"
            />
            <DebugButton
                icon={<StepBack size={14} />}
                label="Step Into (F11)"
                onClick={lambda -> None {onhandleDebugAction("stepInto");}}
                variant="default"
            />
            <DebugButton
                icon={<ArrowUp size={14} />}
                label="Step Out (Shift+F11)"
                onClick={lambda -> None {onhandleDebugAction("stepOut");}}
                variant="default"
            />
            <DebugButton
                icon={<RotateCw size={14} />}
                label="Restart (Ctrl+Shift+F5)"
                onClick={lambda -> None {onhandleDebugAction("restart");}}
                variant="warning"
            />
            <DebugButton
                icon={<Square size={14} />}
                label="Stop (Shift+F5)"
                onClick={lambda -> None {onhandleDebugAction("stop");}}
                variant="danger"
            />
        </div>
    );
}

