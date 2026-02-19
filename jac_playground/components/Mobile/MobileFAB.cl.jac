import from "lucide-react" { Play, ArrowRightLeft, Loader2 }
import from "...lib.utils" { cn }

def: pub MobileFAB(props: dict) -> JsxElement {
    mode = props.mode or "jac";
    activePanel = props.activePanel or "code";
    onRun = props.onRun;
    onConvert = props.onConvert;
    isRunning = props.isRunning or false;
    isConverting = props.isConverting or false;
    envReady = props.envReady or false;

    # Only show FAB on code panel or mode panel (where actions are needed)
    shouldShow = activePanel == "code" or activePanel == "mode";
    if not shouldShow {
        return None;
    }

    isJacMode = mode == "jac";
    isConversionMode = mode == "jac2py" or mode == "py2jac";
    isLoading = isRunning or isConverting;
    isDisabled = isLoading or not envReady;
    
    def handlePress() -> None {
        if isDisabled {
            return None;
        }
        if isJacMode and onRun {
            onRun();
        } elif isConversionMode and onConvert {
            onConvert();
        }
    }
    
    Icon = isJacMode and Play or ArrowRightLeft;
    label = isJacMode and "Run Code" or "Convert";
    
    return (
        <button
            onClick={handlePress}
            disabled={isDisabled}
            className={cn(
                "fixed bottom-20 right-4 w-14 h-14 rounded-full shadow-lg",
                "flex items-center justify-center z-[1000]",
                "transition-all duration-200 active:scale-95",
                (not envReady) and "bg-border cursor-not-allowed opacity-50"
                    or (isLoading and "bg-primary/70 cursor-wait" or "bg-primary hover:bg-primary/90"),
                "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
            )}
            aria-label={envReady and label or "Environment loading..."}
            aria-pressed={isLoading}
        >
            {isLoading and (
                <Loader2 className="w-6 h-6 text-primary-foreground animate-spin" />
            )}
            {(not isLoading) and (
                <Icon className={cn("w-6 h-6", (not envReady) and "text-text-secondary" or "text-primary-foreground")} />
            )}
        </button>
    );
}

