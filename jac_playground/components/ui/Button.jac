
cl import from "...lib.utils" { cn }

cl {
    def Button(props:dict) -> any {
        let variant = props.variant or "primary";
        let size = props.size or "md";
        let onClick = props.onClick;
        let disabled = props.disabled or false;
        let children = props.children;
        let className = props.className or "";
        let type = props.type or "button";

        let base = "inline-flex items-center justify-center rounded-lg font-semibold focus:outline-none gap-2";
        let variantClasses = 
            variant == "primary" and "bg-primary text-primary-foreground hover:bg-primary-600" or
            variant == "secondary" and "bg-secondary text-secondary-foreground hover:bg-secondary-600" or
            variant == "outline" and "bg-transparent border border-border text-text-primary" or
            "bg-transparent text-primary";

        let sizeClasses = 
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