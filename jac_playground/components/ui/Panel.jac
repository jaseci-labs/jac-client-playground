cl import from "...lib.utils" { cn }

cl {
    def Panel(props: dict) -> any {
        let title = props.title or "";
        let subtitle = props.subtitle or "";
        let className = props.className or "";
        let headerClassName = props.headerClassName or "";
        let children = props.children;
        
        return (
            <div className={cn(
                "flex flex-col h-full bg-surface border border-border rounded-md overflow-hidden",
                className
            )}>
                <div className={cn(
                    "flex items-center gap-2 px-3 py-2 border-b border-border bg-background",
                    headerClassName
                )}>
                    <div className="text-xs font-medium text-text-primary">{title}</div>
                    <div className="flex-1" />
                    {subtitle and <div className="text-xs text-text-secondary">{subtitle}</div>}
                </div>
                <div className="flex-1 overflow-auto">
                    {children}
                </div>
            </div>
        );
    }
}
