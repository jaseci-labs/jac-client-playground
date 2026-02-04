import from "lucide-react" { Play, ArrowRightLeft, Loader2 }
import from "...lib.utils" { cn }

def: pub MobileFAB(props: dict) -> JsxElement {
    mode = props.mode or "jac";
    activePanel = props.activePanel or "code";
    onRun = props.onRun;
    onConvert = props.onConvert;
    isRunning = props.isRunning or false;
    isConverting = props.isConverting or false;
    
    # Only show FAB on code panel or mode panel (where actions are needed)
    shouldShow = activePanel == "code" or activePanel == "mode";
    if not shouldShow {
        return None;
    }
    
    isJacMode = mode == "jac";
    isConversionMode = mode == "jac2py" or mode == "py2jac";
    isLoading = isRunning or isConverting;
    
    def handlePress() -> None {
        if isLoading {
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
            disabled={isLoading}
            className={cn(
                "fixed bottom-20 right-4 w-14 h-14 rounded-full shadow-lg",
                "flex items-center justify-center z-[1000]",
                "transition-all duration-200 active:scale-95",
                isLoading and "bg-primary/70 cursor-wait" or "bg-primary hover:bg-primary/90",
                "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2"
            )}
            aria-label={label}
            aria-pressed={isLoading}
        >
            {isLoading and (
                <Loader2 className="w-6 h-6 text-primary-foreground animate-spin" />
            )}
            {(not isLoading) and (
                <Icon className="w-6 h-6 text-primary-foreground" />
            )}
        </button>
    );
}

