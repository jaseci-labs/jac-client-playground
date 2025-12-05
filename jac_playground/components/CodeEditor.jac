# import React from "react";

# export type CodeEditorProps = {
#   value: string;
#   onChange?: (v: string) => void;
#   language?: string;
#   readOnly?: boolean;
#   ariaLabel?: string;
# };

# export default function CodeEditor({
#   value,
#   onChange,
#   readOnly = false,
#   ariaLabel = "code-editor",
# }: CodeEditorProps) {
#   // This is a lightweight wrapper placeholder. Replace with Monaco/CodeMirror in integration.
#   return (
#     <div
#       role="textbox"
#       aria-label={ariaLabel}
#       contentEditable={!readOnly}
#       suppressContentEditableWarning
#       onInput={(e) => onChange?.((e.target as HTMLElement).innerText)}
#       className="w-full h-full p-4 font-mono text-sm leading-6 bg-editor text-editor-foreground outline-none overflow-auto"
#     >
#       {value}
#     </div>
#   );
# }
cl import from "@monaco-editor/react" { Editor }

cl {
    def CodeEditor(props:dict) -> any {
        let value = props.value;
        let onChange = props.onChange;
        let readOnly = props.readOnly or false;
        let ariaLabel = props.ariaLabel or "code-editor";

        return (
            <div
                role="textbox"
                aria-label={ariaLabel}
                contentEditable={not readOnly}
                suppressContentEditableWarning={true}
                onInput={lambda e:any -> None {
                    onChange and onChange(e.target.innerText);
                }}
                className="w-full h-full p-4 font-mono text-sm leading-6 bg-editor text-editor-foreground outline-none overflow-auto"
            >
                <Editor
                    height="100%"
                    width="100%"
                    defaultLanguage="python"
                    defaultValue="// Write your Jac code here"
                    onChange={props.onChange}
                    theme="vs-light"
                    options={{
                        "fontSize": 14,
                        "minimap": {"enabled": False},
                        "scrollBeyondLastLine": False,
                        "automaticLayout": True
                    }}
                />
            </div>
        );
    }
}