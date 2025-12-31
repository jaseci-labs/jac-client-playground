
cl import from "...lib.utils" { cn }

cl {
    def Button(props:dict) -> any {
        variant = props.variant or "primary";
        size = props.size or "md";
        onClick = props.onClick;
        disabled = props.disabled or false;
        children = props.children;
        className = props.className or "";
        type = props.type or "button";

        base = "inline-flex items-center justify-center rounded-lg font-semibold focus:outline-none gap-2";
        variantClasses = 
            variant == "primary" and "bg-primary text-primary-foreground hover:bg-primary-600" or
            variant == "secondary" and "bg-secondary text-secondary-foreground hover:bg-secondary-600" or
            variant == "outline" and "bg-transparent border border-border text-text-primary" or
            "bg-transparent text-primary";

        sizeClasses = 
            size == "sm" and "px-3 py-1.5 text-sm" or
            size == "md" and "px-4 py-2 text-sm" or
            size == "lg" and "px-5 py-3 text-base";

        return (
            <button type={type} disabled={disabled} onClick={onClick} className={cn(base, variantClasses, sizeClasses, className)}>
                {children}
            </button>
        );
    }
}