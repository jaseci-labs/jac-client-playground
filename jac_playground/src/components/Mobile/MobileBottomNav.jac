cl import from "lucide-react" { 
    Code2, 
    GitGraph, 
    Terminal, 
    BookOpen
}
cl import from "...lib.utils" { cn }

cl {
    def: pub MobileBottomNav(props: dict) -> any {
        activePanel = props.activePanel or "code";
        onChange = props.onChange;
        outputBadge = props.outputBadge or 0;
        problemsBadge = props.problemsBadge or 0;
        
        # Only 4 items - Mode is now in the header
        navItems = [
            { "id": "code", "icon": Code2, "label": "Code" },
            { "id": "graph", "icon": GitGraph, "label": "Graph" },
            { "id": "output", "icon": Terminal, "label": "Output", "badge": outputBadge + problemsBadge },
            { "id": "examples", "icon": BookOpen, "label": "Examples" }
        ];
        
        return (
            <nav 
                className="fixed bottom-0 left-0 right-0 h-14 bg-surface border-t border-border flex items-center justify-around z-50 safe-area-pb"
                role="navigation"
                aria-label="Main navigation"
            >
                {navItems.map(lambda item: dict -> any {
                    Icon = item["icon"];
                    isActive = activePanel == item["id"];
                    badge = "badge" in item and item["badge"] or 0;
                    hasBadge = badge > 0;
                    
                    return (
                        <button
                            key={item["id"]}
                            onClick={lambda -> None { onChange(item["id"]); }}
                            className={cn(
                                "flex flex-col items-center justify-center flex-1 h-full min-w-[48px] transition-colors relative",
                                isActive and "text-primary" or "text-text-secondary"
                            )}
                            aria-label={item["label"]}
                            aria-current={isActive and "page" or None}
                        >
                            <div className="relative">
                                <Icon className="w-5 h-5" />
                                {hasBadge and (
                                    <span className="absolute -top-1 -right-1 min-w-[16px] h-4 px-1 bg-error text-error-foreground text-[10px] rounded-full flex items-center justify-center">
                                        {badge > 99 and "99+" or badge}
                                    </span>
                                )}
                            </div>
                            <span className={cn(
                                "text-[10px] mt-0.5 font-medium",
                                isActive and "text-primary" or "text-text-secondary"
                            )}>
                                {item["label"]}
                            </span>
                            
                            {isActive and (
                                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-8 h-0.5 bg-primary rounded-full" />
                            )}
                        </button>
                    );
                })}
            </nav>
        );
    }
}
