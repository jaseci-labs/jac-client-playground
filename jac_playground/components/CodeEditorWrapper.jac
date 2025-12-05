# import React from "react";
# import CodeEditor from "./CodeEditor";

# export type CodeEditorWrapperProps = {
#   value: string;
#   onChange?: (v: string) => void;
#   language?: string;
# };

# export default function CodeEditorWrapper({
#   value,
#   onChange,
#   language = "jac",
# }: CodeEditorWrapperProps) {
#   return (
#     <div className="flex flex-col h-full">
#       <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-panel">
#         <div className="text-xs text-text-secondary">Editor</div>
#         <div className="flex-1" />
#         <div className="text-xs text-text-secondary">Jac</div>
#       </div>

#       <div className="flex-1">
#         <CodeEditor value={value} onChange={onChange} language={language} />
#       </div>
#     </div>
#   );
# }

cl import from "..lib.utils" { cn }
cl import from ".CodeEditor" { CodeEditor }

cl {
    def CodeEditorWrapper(props:dict) -> any {
        let value = props.value;
        let onChange = props.onChange;
        let language = props.language or "jac";

        return (
            <div className="flex flex-col h-full">
                <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-panel">
                    <div className="text-xs text-text-secondary">Editor</div>
                    <div className="flex-1" />
                    <div className="text-xs text-text-secondary">Jac</div>
                </div>

                <div className="flex-1">
                    <CodeEditor value={value} onChange={onChange} language={language} />
                </div>
            </div>
        );
    }
}