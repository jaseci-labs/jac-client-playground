# import React from "react";
# import ExamplesList from "./ExamplesList";

# export type SidebarProps = {
#   examples: { id: string; title: string; category?: string }[];
#   onSelectExample?: (id: string) => void;
#   version?: string;
# };

# export default function Sidebar({ examples, onSelectExample, version = "v1.0.0" }: SidebarProps) {
#   return (
#     <aside className="w-72 h-full flex flex-col bg-panel border-l border-border">
#       <div className="px-4 py-3 border-b border-border flex items-center justify-between">
#         <div className="text-sm text-text-primary font-semibold">Jaclang Examples</div>
#         <div className="text-xs text-text-secondary">{version}</div>
#       </div>

#       <div className="p-3 overflow-auto">
#         <ExamplesList examples={examples} onSelect={onSelectExample} />
#       </div>

#       <div className="mt-auto p-3 text-xs text-text-secondary">Click an example to load</div>
#     </aside>
#   );
# }


cl import from ".ExamplesList" { ExamplesList }

cl {
    def Sidebar(props:dict) -> any {
        let examples = props.examples;
        let onSelectExample = props.onSelectExample;
        let version = props.version or "v1.0.0";

        return (
            <aside className="w-72 h-full flex flex-col bg-panel border-l border-border">
                <div className="px-4 py-3 border-b border-border flex items-center justify-between">
                    <div className="text-sm text-text-primary font-semibold">Jaclang Examples</div>
                    <div className="text-xs text-text-secondary">{version}</div>
                </div>

                <div className="p-3 overflow-auto">
                    <ExamplesList examples={examples} onSelect={onSelectExample} />
                </div>

                <div className="mt-auto p-3 text-xs text-text-secondary">Click an example to load</div>
            </aside>
        );
    }
}