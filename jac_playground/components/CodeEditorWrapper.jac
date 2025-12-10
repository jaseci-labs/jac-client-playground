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
#       <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-background">
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
cl import from "@monaco-editor/react" { Editor }

cl {
    def CodeEditorWrapper(props:dict) -> any {
        let language = props.language or "python";
        let value = props.value or "";
        let showHeader = props.showHeader;
        # Default showHeader to true if not explicitly set to false
        let shouldShowHeader = showHeader != false;

        return (
            <div className="flex flex-col h-full">
                {shouldShowHeader and (
                    <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-background">
                        <div className="text-xs text-text-secondary">Editor</div>
                        <div className="flex-1" />
                        <div className="text-xs text-text-secondary">{language}</div>
                    </div>
                )}

                <div className="flex-1">
                    <Editor
                        height="100%"
                        width="100%"
                        language={language}
                        value={value}
                        defaultValue="// Write your code here"
                        onChange={props.onChange}
                        theme="vs-light"
                        options={{
                            "fontSize": 14,
                            "minimap": {"enabled": false},
                            "scrollBeyondLastLine": false,
                            "automaticLayout": true,
                            "padding": {"top": 12}
                        }}
                    />
                </div>
            </div>
        );
    }
}