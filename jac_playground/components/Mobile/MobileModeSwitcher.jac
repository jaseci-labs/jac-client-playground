cl import from react { useState }
cl import from "lucide-react" { Code2, Braces, FileCode, ChevronDown, X, Check }
cl import from "...lib.utils" { cn }

cl {
    def MobileModeSwitcher(props: dict) -> any {
        let mode = props.mode or "jac";
        let onModeChange = props.onModeChange;
        let className = props.className or "";
        
        let [isOpen, setIsOpen] = useState(false);
        
        let modes = [
            { "id": "jac", "icon": Code2, "label": "Jac", "shortLabel": "Jac" },
            { "id": "jac2py", "icon": Braces, "label": "Jac → Python", "shortLabel": "jac2py" },
            { "id": "py2jac", "icon": FileCode, "label": "Python → Jac", "shortLabel": "py2jac" }
        ];
        
        let currentMode = modes.find(lambda m: dict -> bool { return m["id"] == mode; });
        let CurrentIcon = currentMode and currentMode["icon"] or Code2;
        
        def handleModeSelect(modeId: str) -> None {
            if onModeChange {
                onModeChange(modeId);
            }
            setIsOpen(false);
        }
        
        return (
            <div className={cn("relative", className)}>
                <button
                    onClick={lambda -> None { setIsOpen(not isOpen); }}
                    className={cn(
                        "flex items-center gap-1.5 px-2.5 py-1.5 rounded-full",
                        "bg-primary/10 border border-primary/20",
                        "text-primary text-xs font-medium",
                        "transition-all active:scale-95"
                    )}
                    aria-label="Switch mode"
                    aria-expanded={isOpen}
                >
                    <CurrentIcon className="w-3.5 h-3.5" />
                    <span>{currentMode and currentMode["shortLabel"] or "Jac"}</span>
                    <ChevronDown className={cn(
                        "w-3 h-3 transition-transform",
                        isOpen and "rotate-180"
                    )} />
                </button>
                
                {isOpen and (
                    <>
                        <div 
                            className="fixed inset-0 z-[100]" 
                            onClick={lambda -> None { setIsOpen(false); }}
                        />
                        
                        <div className="absolute top-full right-0 mt-2 z-[101] w-48 bg-surface border border-border rounded-xl shadow-xl overflow-hidden">
                            <div className="p-2 border-b border-border bg-surface-hover">
                                <span className="text-[10px] font-semibold text-text-secondary uppercase tracking-wider">
                                    Switch Mode
                                </span>
                            </div>
                            
                            {modes.map(lambda modeItem: dict -> any {
                                let Icon = modeItem["icon"];
                                let isActive = mode == modeItem["id"];
                                
                                return (
                                    <button
                                        key={modeItem["id"]}
                                        onClick={lambda -> None { handleModeSelect(modeItem["id"]); }}
                                        className={cn(
                                            "w-full flex items-center gap-3 px-3 py-2.5 transition-colors",
                                            isActive and "bg-primary/10 text-primary" or "hover:bg-surface-hover text-text-primary"
                                        )}
                                    >
                                        <Icon className="w-4 h-4" />
                                        <span className="text-sm font-medium flex-1 text-left">
                                            {modeItem["label"]}
                                        </span>
                                        {isActive and (
                                            <Check className="w-4 h-4 text-primary" />
                                        )}
                                    </button>
                                );
                            })}
                        </div>
                    </>
                )}
            </div>
        );
    }
}
