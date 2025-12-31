cl import from react { useState }
cl import from "lucide-react" { FileCode, FileOutput, Play, Copy, Check, Loader2, Maximize2, Minimize2 }
cl import from "....lib.utils" { cn }
cl import from "@monaco-editor/react" { Editor }

cl {
    def CodePanel(props: dict) -> any {
        mode = props.mode or "jac";
        value = props.value or "";
        onChange = props.onChange;
        outputValue = props.outputValue or "";
        className = props.className or "";
        onRun = props.onRun;
        isRunning = props.isRunning or false;
        
        [copiedInput, setCopiedInput] = useState(false);
        [copiedOutput, setCopiedOutput] = useState(false);
        [expandedPanel, setExpandedPanel] = useState("none");  # "none" | "input" | "output"
        
        # Determine what to show based on mode
        isJacMode = mode == "jac";
        isJac2Py = mode == "jac2py";
        isPy2Jac = mode == "py2jac";
        isConversionMode = isJac2Py or isPy2Jac;
        hasOutput = isConversionMode and outputValue and outputValue != "";
        
        inputTitle = isJacMode and "main.jac" or (isJac2Py and "input.jac" or "input.py");
        outputTitle = isJac2Py and "output.py" or "output.jac";
        editorLanguage = (isJacMode or isJac2Py) and "python" or "python";
        
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
        
        # Toggle expand for input/output panels
        def toggleExpandInput() -> None {
            setExpandedPanel(expandedPanel == "input" and "none" or "input");
        }
        
        def toggleExpandOutput() -> None {
            setExpandedPanel(expandedPanel == "output" and "none" or "output");
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
                                {copiedInput and (<Check className="w-4 h-4 text-success" />)}
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
                            theme={props.editorTheme or "vs-light"}
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
        
        # For conversion modes - expandable split layout
        inputExpanded = expandedPanel == "input";
        outputExpanded = expandedPanel == "output";
        inputCollapsed = expandedPanel == "output";
        outputCollapsed = expandedPanel == "input";
        
        return (
            <div className={cn("h-full flex flex-col bg-background", className)}>
                <div className={cn(
                    "flex flex-col min-h-0 transition-all duration-300",
                    inputExpanded and "flex-1" or "",
                    inputCollapsed and "flex-none" or "",
                    expandedPanel == "none" and "flex-1" or ""
                )}>
                    <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                        <div className="flex items-center gap-2">
                            <FileCode className="w-4 h-4 text-primary" />
                            <span className="text-sm font-medium text-text-primary">{inputTitle}</span>
                        </div>
                        
                        <div className="flex items-center gap-1">
                            <button
                                onClick={toggleExpandInput}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                                aria-label={inputExpanded and "Collapse input" or "Expand input"}
                            >
                                {inputExpanded and (<Minimize2 className="w-4 h-4" />)}
                                {(not inputExpanded) and (<Maximize2 className="w-4 h-4" />)}
                            </button>
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
                                {copiedInput and (<Check className="w-4 h-4 text-success" />)}
                                {(not copiedInput) and (<Copy className="w-4 h-4" />)}
                            </button>
                        </div>
                    </div>
                    
                    {(not inputCollapsed) and (
                        <div className="flex-1 overflow-hidden">
                            <Editor
                                height="100%"
                                width="100%"
                                language={editorLanguage}
                                value={value}
                                onChange={onChange}
                                theme={props.editorTheme or "vs-light"}
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
                    )}
                </div>
                
                <div className={cn(
                    "flex flex-col min-h-0 transition-all duration-300",
                    outputExpanded and "flex-1" or "",
                    outputCollapsed and "flex-none" or "",
                    expandedPanel == "none" and "flex-1" or ""
                )}>
                    <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                        <div className="flex items-center gap-2">
                            <FileOutput className="w-4 h-4 text-primary" />
                            <span className="text-sm font-medium text-text-primary">{outputTitle}</span>
                        </div>
                        
                        <div className="flex items-center gap-1">
                            <button
                                onClick={toggleExpandOutput}
                                className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                                aria-label={outputExpanded and "Collapse output" or "Expand output"}
                            >
                                {outputExpanded and (<Minimize2 className="w-4 h-4" />)}
                                {(not outputExpanded) and (<Maximize2 className="w-4 h-4" />)}
                            </button>
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
                                {copiedOutput and (<Check className="w-4 h-4 text-success" />)}
                                {(not copiedOutput) and (<Copy className={cn("w-4 h-4", (not hasOutput) and "opacity-30")} />)}
                            </button>
                        </div>
                    </div>
                    
                    {(not outputCollapsed) and (
                        <div className="flex-1 overflow-hidden">
                            {hasOutput and (
                                <Editor
                                    height="100%"
                                    width="100%"
                                    language={isJac2Py and "python" or "python"}
                                    value={outputValue}
                                    theme={props.editorTheme or "vs-light"}
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
                    )}
                </div>
            </div>
        );
    }
}

