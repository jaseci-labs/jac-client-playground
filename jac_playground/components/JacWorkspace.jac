cl import from react { useState, useRef, useCallback, forwardRef, useImperativeHandle }
cl import from "lucide-react" { Maximize2, Minimize2, Columns2, Code2, GitGraph }
cl import from "..lib.utils" { cn }
cl import from ".ui.Panel" { Panel }
cl import from "@monaco-editor/react" { Editor }
cl import from ".Visualizer" { Visualizer }
cl import from "..lib/syntax_highlighting" { loadSyntax, configureTheme }

cl {
    let: pub JacWorkspace = forwardRef(lambda props: dict, ref: any -> any {
        let theme = props.theme or "light";
        let language = props.language or "python";
        let value = props.value or "";
        let onChange = props.onChange;
        let graphData = props.graphData;
        let className = props.className or "";
        let isDarkMode = props.isDarkMode or false;
        let onBreakpointsChange = props.onBreakpointsChange;
        
        # View state: "split" | "editor" | "graph"
        let [viewMode, setViewMode] = useState("split");
        
        let showEditor = viewMode == "split" or viewMode == "editor";
        let showGraph = viewMode == "split" or viewMode == "graph";

        let editorRef = useRef(None);
        let monacoRef = useRef(None);
        let textMateLoadedRef = useRef(False);

        # Track IDs of decorations to update them efficiently
        let breakpointDecorationsRef = useRef([]);
        let executionDecorationRef = useRef([]);

        let [breakpoints, setBreakpoints] = useState([]); # Array of line numbers

        # Ref to always access the latest toggleBreakpoint function
        let toggleBreakpointRef = useRef(None);

        let registerJacLanguage = useCallback(lambda monaco:any, editor:any -> None {
            if (textMateLoadedRef.current) {
                return;
            }

            try {
                let grammarConfig = loadSyntax(monaco, editor);
                configureTheme(monaco, grammarConfig);
                textMateLoadedRef.current = True;
            } except Exception as error {
                console.error("Failed to register Jac language:", error);
            }
        });

        async def handleEditorDidMount(editor:any, monaco:any) -> None {
            editorRef.current = editor;
            monacoRef.current = monaco;

            if (language == "jac") {
                await registerJacLanguage(monaco, editor);
            }

            # Enable the left-side margin for breakpoint icons
            editor.updateOptions({ glyphMargin: true });

            # Handle clicks on the glyph margin to toggle breakpoints
            editor.onMouseDown(lambda e:any -> None {
                if (e.target.type == monaco.editor.MouseTargetType.GUTTER_GLYPH_MARGIN) {
                    toggleBreakpointRef.current(e.target.position.lineNumber);
                }
            });
        };

        let toggleBreakpoint = useCallback(lambda line:int -> None {
            setBreakpoints(lambda prev:any -> any {
                let isExisting = prev.includes(line);
                let newBreakpoints = prev.filter(lambda l:any -> any { return l != line; });
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
            let editor = editorRef.current;
            let monaco = monacoRef.current;

            # Clear old breakpoint decorations and apply new ones
            let newDecorations = activeLines.map(lambda line:int -> any {
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
            let oldIds = breakpointDecorationsRef.current;
            let newIds = editor.deltaDecorations(oldIds, newDecorations);

            # Store new IDs for next update
            breakpointDecorationsRef.current = newIds;
        };

        def highlightExecutionLine (line:int) -> None {
            let editor = editorRef.current;
            let monaco = monacoRef.current;

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
            let editor = editorRef.current;

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
                                            onClick={lambda -> None { setViewMode("split"); }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Split View"
                                        >
                                            <Columns2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                    {viewMode != "editor" and (
                                        <button
                                            onClick={lambda -> None { setViewMode("editor"); }}
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
                                    theme={props.editorTheme or "vs-light"}
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
                                            onClick={lambda -> None { setViewMode("split"); }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Split View"
                                        >
                                            <Columns2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                    {viewMode != "graph" and (
                                        <button
                                            onClick={lambda -> None { setViewMode("graph"); }}
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
