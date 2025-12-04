def Button(props: dict) -> any {
    let className = props.className or "";
    let variant = props.variant or "default";
    let size = props.size or "default";
    let disabled = props.disabled or false;
    
    let baseClasses = "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none ring-offset-background";
    
    let variantClasses = {
        "default": "bg-primary text-primary-foreground hover:bg-primary/90",
        "outline": "border border-input hover:bg-accent hover:text-accent-foreground"
    };
    
    let sizeClasses = {
        "default": "h-10 py-2 px-4",
        "icon": "h-10 w-10"
    };
    
    let finalClassName = baseClasses + " " + (variantClasses[variant] or variantClasses["default"]) + " " + (sizeClasses[size] or sizeClasses["default"]) + " " + className;
    
    return (
        <button
            className={finalClassName}
            onClick={props.onClick}
            disabled={disabled}
            type={props.type or "button"}
        >
            {props.children}
        </button>
    );
}