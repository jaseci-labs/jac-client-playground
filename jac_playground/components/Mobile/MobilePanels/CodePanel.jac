cl import from react { useState }
cl import from "lucide-react" { FileCode, FileOutput, Play, Copy, Check, Loader2 }
cl import from "....lib.utils" { cn }
cl import from "@monaco-editor/react" { Editor }

cl {
    def CodePanel(props: dict) -> any {
        let mode = props.mode or "jac";
        let value = props.value or "";
        let onChange = props.onChange;
        let outputValue = props.outputValue or "";
        let className = props.className or "";
        let onRun = props.onRun;
        let isRunning = props.isRunning or false;
        
        let [copiedInput, setCopiedInput] = useState(false);
        let [copiedOutput, setCopiedOutput] = useState(false);
        
        # Determine what to show based on mode
        let isJacMode = mode == "jac";
        let isJac2Py = mode == "jac2py";
        let isPy2Jac = mode == "py2jac";
        let isConversionMode = isJac2Py or isPy2Jac;
        let hasOutput = isConversionMode and outputValue and outputValue != "";
        
        let inputTitle = isJacMode and "main.jac" or (isJac2Py and "input.jac" or "input.py");
        let outputTitle = isJac2Py and "output.py" or "output.jac";
        let editorLanguage = (isJacMode or isJac2Py) and "python" or "python";
        
        def handleCopyInput() -> None {
            navigator.clipboard.writeText(value);
            setCopiedInput(true);
            setTimeout(lambda -> None { setCopiedInput(false); }, 2000);
        }
        
        def handleCopyOutput() -> None {
            navigator.clipboard.writeText(outputValue);
            setCopiedOutput(true);
            setTimeout(lambda -> None { setCopiedOutput(false); }, 2000);
        }
        
        # Run input code based on mode
        def handleRunInput() -> None {
            if onRun {
                if isJac2Py {
                    onRun("Jac Input");
                } elif isPy2Jac {
                    onRun("Python Input");
                } else {
                    onRun();
                }
            }
        }
        
        # Run output code based on mode
        def handleRunOutput() -> None {
            if onRun and hasOutput {
                if isJac2Py {
                    onRun("Python Output");
                } elif isPy2Jac {
                    onRun("Jac Output");
                }
            }
        }
        
        # For Jac mode - full height editor (no run button, FAB handles it)
        if isJacMode {
            return (
                <div className={cn("h-full flex flex-col bg-background", className)}>
                    <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                        <div className="flex items-center gap-2">
                            <FileCode className="w-4 h-4 text-primary" />
                            <span className="text-sm font-medium text-text-primary">{inputTitle}</span>
                        </div>
                        
                        <div className="flex items-center gap-1">
                            <button
                                onClick={handleCopyInput}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                                aria-label={copiedInput and "Copied!" or "Copy code"}
                            >
                                {copiedInput and (<Check className="w-4 h-4 text-green-500" />)}
                                {(not copiedInput) and (<Copy className="w-4 h-4" />)}
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
                </div>
            );
        }
        
        # For conversion modes - 50/50 split layout
        return (
            <div className={cn("h-full flex flex-col bg-background", className)}>
                <div className="flex-1 flex flex-col min-h-0">
                    <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                        <div className="flex items-center gap-2">
                            <FileCode className="w-4 h-4 text-primary" />
                            <span className="text-sm font-medium text-text-primary">{inputTitle}</span>
                        </div>
                        
                        <div className="flex items-center gap-1">
                            <button
                                onClick={handleRunInput}
                                disabled={isRunning or not value}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors disabled:opacity-30"
                                aria-label="Run input code"
                            >
                                {isRunning and (<Loader2 className="w-4 h-4 animate-spin" />)}
                                {(not isRunning) and (<Play className="w-4 h-4" />)}
                            </button>
                            <button
                                onClick={handleCopyInput}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                                aria-label={copiedInput and "Copied!" or "Copy code"}
                            >
                                {copiedInput and (<Check className="w-4 h-4 text-green-500" />)}
                                {(not copiedInput) and (<Copy className="w-4 h-4" />)}
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
                                "padding": {"top": 12, "bottom": 12},
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
                </div>
                
                <div className="flex-1 flex flex-col min-h-0 border-t-2 border-border">
                    <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                        <div className="flex items-center gap-2">
                            <FileOutput className="w-4 h-4 text-primary" />
                            <span className="text-sm font-medium text-text-primary">{outputTitle}</span>
                        </div>
                        
                        <div className="flex items-center gap-1">
                            <button
                                onClick={handleRunOutput}
                                disabled={isRunning or not hasOutput}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors disabled:opacity-30"
                                aria-label="Run output code"
                            >
                                {isRunning and (<Loader2 className="w-4 h-4 animate-spin" />)}
                                {(not isRunning) and (<Play className="w-4 h-4" />)}
                            </button>
                            <button
                                onClick={handleCopyOutput}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                                aria-label={copiedOutput and "Copied!" or "Copy code"}
                                disabled={not hasOutput}
                            >
                                {copiedOutput and (<Check className="w-4 h-4 text-green-500" />)}
                                {(not copiedOutput) and (<Copy className={cn("w-4 h-4", (not hasOutput) and "opacity-30")} />)}
                            </button>
                        </div>
                    </div>
                    
                    <div className="flex-1 overflow-hidden">
                        {hasOutput and (
                            <Editor
                                height="100%"
                                width="100%"
                                language={isJac2Py and "python" or "python"}
                                value={outputValue}
                                theme="vs-light"
                                options={{
                                    "fontSize": 14,
                                    "minimap": {"enabled": false},
                                    "scrollBeyondLastLine": false,
                                    "automaticLayout": true,
                                    "readOnly": true,
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
                        )}
                        {(not hasOutput) and (
                            <div className="h-full flex items-center justify-center">
                                <p className="text-sm text-text-secondary">
                                    Tap Convert to see output
                                </p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        );
    }
}

