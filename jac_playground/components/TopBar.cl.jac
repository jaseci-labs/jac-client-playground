import from "..lib.utils" { cn }
import from "lucide-react" { Search, Settings, User, HelpCircle, Github, Loader2, Check, X }
import from ".ui.Badge" { Badge }
import from ".ui.ThemeToggle" { ThemeToggle }


def: pub TopBar(props:dict) -> JsxElement {
    has tooltipDismissed: bool = false;
    
    envReady = props.envReady or false;
    isRunning = props.isRunning or false;
    theme = props.theme or "light";
    onToggleTheme = props.onToggleTheme;
    onOpenSettings = props.onOpenSettings;
    onOpenHelp = props.onOpenHelp;

    return (
        <header className="w-full h-12 flex items-center gap-4 px-4 bg-surface border-b border-border justify-between">
            <div className="flex items-center gap-2">
                <img src="/static/assets/jaseci.png" className="w-7 h-7" />
                <span className="text-sm font-semibold text-text-primary">
                    Jac Playground
                </span>
            </div>
            
            <div className="flex items-center gap-2">
                <div className="relative" aria-live="polite">
                    <Badge
                        variant={(not envReady) and "warning" or (isRunning and "info" or "success")}
                        size="sm"
                    >
                        {(not envReady) and (
                            <span className="flex items-center gap-2">
                                <Loader2 className="w-4 h-4 animate-spin" />
                                <span className="flex items-center">
                                    Loading
                                    <span className="loading-dots inline-flex items-center ml-1">
                                        <span style={ { "animationDelay": "0s" } } className="dot" />
                                        <span style={ { "animationDelay": "0.15s" } } className="dot" />
                                        <span style={ { "animationDelay": "0.3s" } } className="dot" />
                                    </span>
                                </span>
                            </span>
                        )}
                        {(envReady and isRunning) and (
                            <span className="flex items-center gap-2">
                                <Loader2 className="w-4 h-4 animate-spin" />
                                <span>Running</span>
                            </span>
                        )}
                        {(envReady and not isRunning) and (
                            <span className="flex items-center gap-2">
                                <Check className="w-4 h-4 text-success-foreground" />
                                <span>Ready</span>
                            </span>
                        )}
                    </Badge>

                    { (not envReady and not tooltipDismissed) and (
                        <div className={cn(
                            "absolute top-full mt-2 right-0 w-64 text-xs bg-surface border border-border text-text-primary p-2 rounded shadow-sm tooltip-bubble z-50 pointer-events-auto"
                        )}>
                            <button onClick={lambda -> None { tooltipDismissed = true; }} className="absolute -top-2 -right-2 p-1.5 bg-surface rounded-full hover:bg-surface-hover text-text-secondary">
                                <X className="w-3.5 h-3.5" />
                            </button>
                            Please wait — the environment is initializing. This may take a few seconds.
                        </div>
                    ) }
                </div>
                
                <div className="w-px h-5 bg-border mx-1" />
                
                <a 
                    href="https://github.com/Jaseci-Labs/jaclang" 
                    target="_blank"
                    className="p-1.5 text-text-secondary hover:text-text-primary hover:bg-background rounded transition-colors"
                    title="GitHub"
                >
                    <Github size={16} />
                </a>
                
                <button
                    onClick={onOpenHelp}
                    className="p-1.5 text-text-secondary hover:text-text-primary hover:bg-background rounded transition-colors"
                    title="Help"
                >
                    <HelpCircle size={16} />
                </button>
                
                <ThemeToggle 
                    theme={theme} 
                    onToggleTheme={onToggleTheme}
                    className="p-1.5"
                />
            </div>
        </header>
    );
}
