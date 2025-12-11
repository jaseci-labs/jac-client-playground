# import React from "react";

# export type BadgeVariant =
#   | "neutral"
#   | "primary"
#   | "secondary"
#   | "success"
#   | "warning"
#   | "error";

# export type BadgeProps = {
#   children: React.ReactNode;
#   variant?: BadgeVariant;
#   size?: "sm" | "md";
#   className?: string;
# };

# export default function Badge({
#   children,
#   variant = "neutral",
#   size = "md",
#   className = "",
# }: BadgeProps) {
#   const sizeClasses =
#     size === "sm"
#       ? "text-xs px-2 py-0.5"
#       : "text-sm px-2.5 py-1";

#   const variantClasses =
#     variant === "primary"
#       ? "bg-primary text-primary-foreground"
#       : variant === "secondary"
#       ? "bg-secondary text-secondary-foreground"
#       : variant === "success"
#       ? "bg-success text-white"
#       : variant === "warning"
#       ? "bg-warning text-black"
#       : variant === "error"
#       ? "bg-error text-white"
#       : "bg-surface text-text-secondary border border-border";

#   return (
#     <span
#       className={`
#         inline-flex items-center font-medium rounded-md
#         ${sizeClasses}
#         ${variantClasses}
#         ${className}
#       `}
#     >
#       {children}
#     </span>
#   );
# }

cl import from "...lib.utils" { cn }

cl {
    def Badge(props:dict) -> any {
        let children = props.children;
        let variant = props.variant or "neutral";
        let size = props.size or "md";
        let className = props.className or "";

        let sizeClasses = 
            size == "sm" and "text-xs px-2 py-0.5" or
            "text-sm px-2.5 py-1";

        let variantClasses = 
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