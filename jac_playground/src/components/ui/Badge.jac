cl import from "...lib.utils" { cn }

cl {
    def: pub Badge(props:dict) -> any {
        children = props.children;
        variant = props.variant or "neutral";
        size = props.size or "md";
        className = props.className or "";

        sizeClasses = 
            size == "sm" and "text-xs px-2 py-0.5" or
            "text-sm px-2.5 py-1";

        variantClasses = 
            variant == "primary" and "bg-primary text-primary-foreground" or
            variant == "secondary" and "bg-secondary text-secondary-foreground" or
            variant == "success" and "bg-success text-success-foreground" or
            variant == "warning" and "bg-warning text-warning-foreground" or
            variant == "error" and "bg-error text-error-foreground" or
            "bg-surface text-text-secondary border border-border";

        return (
            <span
                className={cn(
                    "inline-flex items-center font-medium rounded-md",
                    sizeClasses,
                    variantClasses,
                    className
                )}
            >
                {children}
            </span>
        );
    }
}