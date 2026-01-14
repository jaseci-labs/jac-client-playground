import from react { useRef, useCallback }

def: pub useEditor() -> dict {

    editorRef = useRef(None);
    monacoRef = useRef(None);

    # Track IDs of decorations to update them efficiently
    breakpointDecorationsRef = useRef([]);
    executionDecorationRef = useRef([]);

    has breakpoints: any = []; # Array of line numbers

    # Ref to always access the latest toggleBreakpoint function
    toggleBreakpointRef = useRef(None);

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

    toggleBreakpoint = useCallback(lambda line:int -> None {
        breakpoints = lambda prev:any -> any {
            isExisting = prev.includes(line);
            newBreakpoints = prev.filter(lambda l:any -> any { return l != line; });
            newBreakpoints = newBreakpoints if isExisting else prev.concat([line]);
            updateBreakpointDecorations(newBreakpoints);
            return newBreakpoints;
        };
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
