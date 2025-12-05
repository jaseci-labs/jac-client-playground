# import React from "react";

# export type ButtonProps = {
#   variant?: "primary" | "secondary" | "outline" | "ghost";
#   size?: "sm" | "md" | "lg";
#   onClick?: () => void;
#   disabled?: boolean;
#   children?: React.ReactNode;
#   className?: string;
#   type?: "button" | "submit" | "reset";
# };

# const sizeClasses = {
#   sm: "px-3 py-1.5 text-sm",
#   md: "px-4 py-2 text-sm",
#   lg: "px-5 py-3 text-base",
# };

# export default function Button({
#   variant = "primary",
#   size = "md",
#   onClick,
#   disabled = false,
#   children,
#   className = "",
#   type = "button",
# }: ButtonProps) {
#   const base = "inline-flex items-center justify-center rounded-lg font-semibold focus:outline-none";
#   const variantClasses =
#     variant === "primary"
#       ? "bg-primary text-primary-foreground hover:bg-primary-600"
#       : variant === "secondary"
#       ? "bg-secondary text-secondary-foreground hover:bg-secondary-600"
#       : variant === "outline"
#       ? "bg-transparent border border-border text-text-primary"
#       : "bg-transparent text-primary";
#   return (
#     <button type={type} disabled={disabled} onClick={onClick} className={`${base} ${variantClasses} ${sizeClasses[size]} ${className}`}>
#       {children}
#     </button>
#   );
# }

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

        let base = "inline-flex items-center justify-center rounded-lg font-semibold focus:outline-none";
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