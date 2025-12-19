cl import from react { useState, useRef, useCallback }

cl {
    def useEditor() -> dict {

        let editorRef = useRef(None);
        let monacoRef = useRef(None);

        # Track IDs of decorations to update them efficiently
        let breakpointDecorationsRef = useRef([]);
        let executionDecorationRef = useRef([]);

        let [breakpoints, setBreakpoints] = useState([]); # Array of line numbers

        # Ref to always access the latest toggleBreakpoint function
        let toggleBreakpointRef = useRef(None);

        def handleEditorDidMount(editor:any, monaco:any) -> None {
            editorRef.current = editor;
            monacoRef.current = monaco;

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
                className: 'active-execution-line', # CSS for yellow background
                glyphMarginClassName: 'active-execution-glyph', # CSS for yellow arrow
                },
            }
            ]);
            
            editor.revealLineInCenter(line); # Auto-scroll to active line
        };
        return {
                "handleEditorDidMount": handleEditorDidMount,
                "highlightExecutionLine": highlightExecutionLine,
            };
    }
        
    
}