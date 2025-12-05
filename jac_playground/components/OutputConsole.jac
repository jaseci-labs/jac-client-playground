# import React from "react";

# export type OutputConsoleProps = {
#   logs?: string[];
#   onClear?: () => void;
#   className?: string;
# };

# export default function OutputConsole({ logs = [], onClear, className = "" }: OutputConsoleProps) {
#   return (
#     <div className={`w-full h-44 bg-output p-3 text-sm text-output-foreground border-t border-border ${className}`}>
#       <div className="flex items-center justify-between mb-2">
#         <div className="text-xs text-text-secondary">Output</div>
#         <div className="flex items-center gap-2">
#           <button onClick={onClear} className="text-xs text-text-primary hover:underline">Clear</button>
#         </div>
#       </div>

#       <pre className="whitespace-pre-wrap overflow-auto text-xs text-output-foreground">
#         {logs.length ? logs.join("\n") : "// Output will appear here after running code"}
#       </pre>
#     </div>
#   );
# }

cl import from "..lib.utils" { cn }

cl {
    def OutputConsole(props:dict) -> any {
        let logs = props.logs or [];
        let onClear = props.onClear;
        let className = props.className or "";

        return (
            <div className={cn("w-full h-44 bg-output p-3 text-sm text-output-foreground border-t border-border", className)}>
                <div className="flex items-center justify-between mb-2">
                    <div className="text-xs text-text-secondary">Output</div>
                    <div className="flex items-center gap-2">
                        <button onClick={onClear} className="text-xs text-text-primary hover:underline">Clear</button>
                    </div>
                </div>

                <pre className="whitespace-pre-wrap overflow-auto text-xs text-output-foreground">
                    {logs.join("\n") if logs.length > 0 else "// Output will appear here after running code"}
                </pre>
            </div>
        );
    }
}