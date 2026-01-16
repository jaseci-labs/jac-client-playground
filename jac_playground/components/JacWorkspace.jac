cl {
    import from react { useEffect, useRef, useCallback, forwardRef, useImperativeHandle }
    import from "lucide-react" { Maximize2, Minimize2, Columns2, Code2, GitGraph }
    import from "..lib.utils" { cn }
    import from ".ui.Panel" { Panel }
    import from "@monaco-editor/react" { Editor }
    import from ".Visualizer" { Visualizer }
    import from "..lib/syntax_highlighting" { loadSyntax, configureTheme }

    glob: pub JacWorkspace = forwardRef(lambda props: dict, ref: any -> any {
        # View state: "split" | "editor" | "graph"
        has viewMode: str = "split";

        theme = props.theme or "light";
        language = props.language or "python";
        value = props.value or "";
        onChange = props.onChange;
        graphData = props.graphData;
        className = props.className or "";
        isDarkMode = props.isDarkMode or false;
        onBreakpointsChange = props.onBreakpointsChange;
        
        showEditor = viewMode == "split" or viewMode == "editor";
        showGraph = viewMode == "split" or viewMode == "graph";

        editorRef = useRef(None);
        monacoRef = useRef(None);
        textMateLoadedRef = useRef(False);

        # Track IDs of decorations to update them efficiently
        breakpointDecorationsRef = useRef([]);
        executionDecorationRef = useRef([]);

        has breakpoints: any = []; # Array of line numbers

        # Ref to always access the latest toggleBreakpoint function
        toggleBreakpointRef = useRef(None);

        # Function to register Jac language and load syntax highlighting
        registerJacLanguage = useCallback(lambda monaco:any, editor:any -> None {
            try {
                grammarConfig = loadSyntax(monaco, editor);
                configureTheme(monaco, grammarConfig, isDarkMode);
                textMateLoadedRef.current = True;
            } except Exception as error {
                console.error("Failed to register Jac language:", error);
            }
        }, [isDarkMode]);

        async def handleEditorDidMount(editor:any, monaco:any) -> None {
            editorRef.current = editor;
            monacoRef.current = monaco;

            if (language == "jac") {
                await registerJacLanguage(monaco, editor);
            }

            editor.updateOptions({ glyphMargin: true });
            editor.onMouseDown(lambda e:any -> None {
                if (e.target.type == monaco.editor.MouseTargetType.GUTTER_GLYPH_MARGIN) {
                    toggleBreakpointRef.current(e.target.position.lineNumber);
                }
            });
        };

        # Apply theme when isDarkMode changes
        useEffect(lambda -> None {
            async def applyTheme() {
                if (monacoRef.current and editorRef.current) {
                    grammarConfig = loadSyntax(monacoRef.current, editorRef.current);
                    configureTheme(monacoRef.current, grammarConfig, isDarkMode);
                }
            }
            applyTheme();
        }, [isDarkMode]);

        toggleBreakpoint = useCallback(lambda line:int -> None {
            breakpoints = (lambda prev:any -> any {
                isExisting = prev.includes(line);
                newBreakpoints = prev.filter(lambda l:any -> any { return l != line; });
                newBreakpoints = newBreakpoints if isExisting else prev.concat([line]);
                if (onBreakpointsChange) {
                    onBreakpointsChange(newBreakpoints);
                }
                updateBreakpointDecorations(newBreakpoints);
                return newBreakpoints;
            });
        }, []);

        # Keep the ref updated with the latest function
        toggleBreakpointRef.current = toggleBreakpoint;

        def updateBreakpointDecorations(activeLines: any) -> None {
            editor = editorRef.current;
            monaco = monacoRef.current;

            # Clear old breakpoint decorations and apply new ones
            newDecorations = activeLines.map(lambda line:int -> any {
                return {
                    range: Reflect.construct(monaco.Range, [line, 1, line, 1]) ,
                    options: {
                        isWholeLine: false,
                        glyphMarginClassName: 'breakpoint-glyph', # CSS for red circle
                    },
                };
            });
            if (not editorRef.current || not monacoRef.current) {
                return;
            };
            # deltaDecorations(oldIDs, newDefinitions)
            oldIds = breakpointDecorationsRef.current;
            newIds = editor.deltaDecorations(oldIds, newDecorations);

            # Store new IDs for next update
            breakpointDecorationsRef.current = newIds;
        };

        def highlightExecutionLine (line:int) -> None {
            editor = editorRef.current;
            monaco = monacoRef.current;

            if (not editorRef.current || not monacoRef.current) {
                return;
            };

            executionDecorationRef.current = editor.deltaDecorations(executionDecorationRef.current, [
            {
                range: Reflect.construct(monaco.Range, [line, 1, line, 1]) ,
                options: {
                isWholeLine: true,
                className: 'active-execution-line' if theme == "light" else 'active-execution-line-dark', # CSS for yellow background
                glyphMarginClassName: 'active-execution-glyph' if theme == "light" else 'active-execution-glyph-dark', # CSS for yellow arrow
                },
            }
            ]);
            
            editor.revealLineInCenter(line); # Auto-scroll to active line
        };

        def clearExecutionHighlight() -> None {
            editor = editorRef.current;

            if (not editorRef.current) {
                return;
            };
            executionDecorationRef.current = editor.deltaDecorations(executionDecorationRef.current, []);
        };

        useImperativeHandle(ref, lambda {
            return {
                highlightExecutionLine: lambda line: int: highlightExecutionLine(line),
                clearExecutionHighlight: lambda: clearExecutionHighlight()
            };
        });
        
        return (
            <div className={cn("h-full w-full flex flex-col", className)}>
                <div className="flex-1 flex gap-3 min-h-0">
                    {showEditor and (
                        <div className={cn(
                            "h-full rounded-lg border border-border overflow-hidden bg-surface flex flex-col",
                            viewMode == "split" and "w-1/2" or "flex-1"
                        )}>
                            <div className="h-9 px-3 flex items-center justify-between border-b border-border bg-surface-hover">
                                <div className="flex items-center gap-2">
                                    <Code2 className="w-4 h-4 text-primary" />
                                    <span className="text-xs font-medium text-text-primary">Editor</span>
                                </div>
                                <div className="flex items-center gap-1">
                                    {viewMode == "editor" and (
                                        <button
                                            onClick={lambda -> None { viewMode = "split"; }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Split View"
                                        >
                                            <Columns2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                    {viewMode != "editor" and (
                                        <button
                                            onClick={lambda -> None { viewMode = "editor"; }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Maximize Editor"
                                        >
                                            <Maximize2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                </div>
                            </div>
                            <div className="flex-1 overflow-hidden">
                                <Editor
                                    height="100%"
                                    width="100%"
                                    language={language}
                                    value={value}
                                    onChange={onChange}
                                    theme={"jac-theme"}
                                    onMount={handleEditorDidMount}
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
                    )}
                    
                    {showGraph and (
                        <div className={cn(
                            "h-full rounded-lg border border-border overflow-hidden bg-surface flex flex-col",
                            viewMode == "split" and "w-1/2" or "flex-1"
                        )}>
                            <div className="h-9 px-3 flex items-center justify-between border-b border-border bg-surface-hover">
                                <div className="flex items-center gap-2">
                                    <GitGraph className="w-4 h-4 text-primary" />
                                    <span className="text-xs font-medium text-text-primary">Graph Visualizer</span>
                                </div>
                                <div className="flex items-center gap-1">
                                    {viewMode == "graph" and (
                                        <button
                                            onClick={lambda -> None { viewMode = "split"; }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Split View"
                                        >
                                            <Columns2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                    {viewMode != "graph" and (
                                        <button
                                            onClick={lambda -> None { viewMode = "graph"; }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Maximize Graph"
                                        >
                                            <Maximize2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                </div>
                            </div>
                            <div className="flex-1 overflow-hidden">
                                <Visualizer graphData={graphData} showHeader={false} isDarkMode={isDarkMode} />
                            </div>
                        </div>
                    )}
                </div>
            </div>
        );
    });
}
