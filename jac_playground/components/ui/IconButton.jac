# import React from "react";

# export type IconButtonProps = {
#   icon: React.ReactNode;
#   label: string;
#   onClick?: () => void;
#   size?: "sm" | "md";
#   className?: string;
# };

# export default function IconButton({ icon, label, onClick, size = "md", className = "" }: IconButtonProps) {
#   const s = size === "sm" ? "w-8 h-8" : "w-9 h-9";
#   return (
#     <button
#       type="button"
#       aria-label={label}
#       onClick={onClick}
#       className={`inline-flex items-center justify-center ${s} rounded-md border border-border bg-transparent text-text-primary ${className}`}
#     >
#       {icon}
#     </button>
#   );
# }

cl import from "...lib.utils" { cn }

cl {
    def IconButton(props:dict) -> any {
        let icon = props.icon;
        let label = props.label;
        let onClick = props.onClick;
        let size = props.size or "md";
        let className = props.className or "";

        let s = size == "sm" and "w-8 h-8" or "w-9 h-9";

        return (
            <button
                type="button"
                aria-label={label}
                onClick={onClick}
                className={cn("inline-flex items-center justify-center", s, "rounded-md border border-border bg-transparent text-text-primary", className)}
            >
                {icon}
            </button>
        );
    }
}