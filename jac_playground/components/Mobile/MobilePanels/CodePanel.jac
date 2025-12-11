cl import from react { useState }
cl import from "lucide-react" { FileCode, MoreVertical, Copy, Check }
cl import from "....lib.utils" { cn }
cl import from "@monaco-editor/react" { Editor }

cl {
    def CodePanel(props: dict) -> any {
        let mode = props.mode or "jac";
        let value = props.value or "";
        let onChange = props.onChange;
        let outputValue = props.outputValue or "";
        let className = props.className or "";
        
        let [copied, setCopied] = useState(false);
        let [showMenu, setShowMenu] = useState(false);
        
        # Determine what to show based on mode
        let isJacMode = mode == "jac";
        let isJac2Py = mode == "jac2py";
        let isPy2Jac = mode == "py2jac";
        
        let editorTitle = isJacMode and "main.jac" or (isJac2Py and "input.jac" or "input.py");
        let editorLanguage = (isJacMode or isJac2Py) and "python" or "python";
        
        def handleCopy() -> None {
            navigator.clipboard.writeText(value);
            setCopied(true);
            setTimeout(lambda -> None { setCopied(false); }, 2000);
        }
        
        return (
            <div className={cn("h-full flex flex-col bg-background", className)}>
                <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                    <div className="flex items-center gap-2">
                        <FileCode className="w-4 h-4 text-primary" />
                        <span className="text-sm font-medium text-text-primary">{editorTitle}</span>
                    </div>
                    
                    <div className="flex items-center gap-1">
                        <button
                            onClick={handleCopy}
                            className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                            aria-label={copied and "Copied!" or "Copy code"}
                        >
                            {copied and (<Check className="w-4 h-4 text-green-500" />)}
                            {(not copied) and (<Copy className="w-4 h-4" />)}
                        </button>
                        
                        <button
                            onClick={lambda -> None { setShowMenu(not showMenu); }}
                            className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                            aria-label="More options"
                        >
                            <MoreVertical className="w-4 h-4" />
                        </button>
                    </div>
                </div>
                
                <div className="flex-1 overflow-hidden">
                    <Editor
                        height="100%"
                        width="100%"
                        language={editorLanguage}
                        value={value}
                        onChange={onChange}
                        theme="vs-light"
                        options={{
                            "fontSize": 14,
                            "minimap": {"enabled": false},
                            "scrollBeyondLastLine": false,
                            "automaticLayout": true,
                            "padding": {"top": 12, "bottom": 60},
                            "lineNumbers": "on",
                            "wordWrap": "on",
                            "folding": false,
                            "glyphMargin": false,
                            "lineDecorationsWidth": 0,
                            "lineNumbersMinChars": 3,
                            "renderLineHighlight": "none",
                            "scrollbar": {
                                "vertical": "auto",
                                "horizontal": "hidden",
                                "verticalScrollbarSize": 8
                            }
                        }}
                    />
                </div>
                
                {(not isJacMode) and outputValue and (
                    <div className="border-t border-border">
                        <div className="h-9 px-3 flex items-center bg-surface-hover">
                            <span className="text-xs font-medium text-text-secondary">
                                {isJac2Py and "Python Output" or "Jac Output"}
                            </span>
                        </div>
                        <div className="h-32 overflow-auto">
                            <Editor
                                height="100%"
                                width="100%"
                                language={isJac2Py and "python" or "python"}
                                value={outputValue}
                                theme="vs-light"
                                options={{
                                    "fontSize": 13,
                                    "minimap": {"enabled": false},
                                    "scrollBeyondLastLine": false,
                                    "automaticLayout": true,
                                    "readOnly": true,
                                    "padding": {"top": 8},
                                    "lineNumbers": "off",
                                    "wordWrap": "on",
                                    "folding": false
                                }}
                            />
                        </div>
                    </div>
                )}
            </div>
        );
    }
}
