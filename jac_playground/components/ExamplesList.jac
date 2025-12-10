# import React from "react";

# export type Example = {
#   id: string;
#   title: string;
#   category?: string;
#   description?: string;
# };

# export type ExamplesListProps = {
#   examples: Example[];
#   onSelect?: (id: string) => void;
# };

# export default function ExamplesList({ examples, onSelect }: ExamplesListProps) {
#   if (!examples || examples.length === 0) {
#     return <div className="text-text-secondary">No examples available</div>;
#   }

#   return (
#     <div className="flex flex-col gap-2">
#       {examples.map((ex) => (
#         <button
#           key={ex.id}
#           onClick={() => onSelect?.(ex.id)}
#           className="w-full text-left px-3 py-2 rounded-md hover:bg-surface text-text-primary border border-transparent hover:border-border"
#         >
#           <div className="text-sm font-medium">{ex.title}</div>
#           {ex.description && <div className="text-xs text-text-secondary mt-1">{ex.description}</div>}
#         </button>
#       ))}
#     </div>
#   );
# }

cl {
    def ExamplesList(props:dict) -> any {
        let examples = props.examples;
        let onSelect = props.onSelect;

        if (not examples or examples.length == 0) {
            return <div className="text-text-secondary text-sm">No examples available</div>;
        }

        return (
            <div className="flex flex-col gap-2">
                {examples.map(lambda ex:any -> any {
                    return (
                        <button
                            key={ex["id"]}
                            onClick={lambda -> None { onSelect and onSelect(ex["id"]); }}
                            className="w-full text-left px-3 py-2 rounded-md hover:bg-primary/10 text-text-primary border border-transparent hover:border-primary/30 transition-colors"
                        >
                            <div className="text-sm font-medium">{ex["title"]}</div>
                            {ex["category"] and <div className="text-xs text-text-secondary mt-0.5">{ex["category"]}</div>}
                        </button>
                    );
                })}
            </div>
        );
    }
}
