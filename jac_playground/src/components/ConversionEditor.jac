cl import from "..lib.utils" { cn }
cl import from ".ui.Panel" { Panel }
cl import from "@monaco-editor/react" { Editor }
cl import from "react" { useRef, useEffect }
cl import from "..lib/syntax_highlighting" { loadSyntax, configureTheme }

cl {
    def: pub ConversionEditor(props: dict) -> any {
        inputTitle = props.inputTitle or "Input";
        outputTitle = props.outputTitle or "Output";
        inputLanguage = props.inputLanguage or "python";
        outputLanguage = props.outputLanguage or "python";
        inputValue = props.inputValue or "";
        outputValue = props.outputValue or "";
        onInputChange = props.onInputChange;
        className = props.className or "";
        onCodeRun = props.onCodeRun;
        
        isDark = props.editorTheme == "vs-dark" or false;

        inputEditorRef = useRef(None);
        outputEditorRef = useRef(None);
        monacoRef = useRef(None);

        async def handleOnMountIfJac(editor:any, monaco:any, lang:str) -> None {
            if (lang == "jac") {
                grammarConfig = await loadSyntax(monaco, editor);
                await configureTheme(monaco, grammarConfig, isDark);
            }
        }

        useEffect(lambda -> None {
            async def applyTheme(){
                if (not monacoRef.current) {
                    return;
                }
                monaco = monacoRef.current;
                # Re-apply/update the jac grammar/theme for any mounted jac editors
                if (inputLanguage == "jac" and inputEditorRef.current) {
                    grammarConfig = await loadSyntax(monaco, inputEditorRef.current);
                    await configureTheme(monaco, grammarConfig, isDark);
                }
                if (outputLanguage == "jac" and outputEditorRef.current) {
                    grammarConfig = await loadSyntax(monaco, outputEditorRef.current);
                    await configureTheme(monaco, grammarConfig, isDark);
                }
            }
            applyTheme();
        }, [props.editorTheme]);

        return (
            <div className={cn("h-full w-full grid grid-cols-2 gap-3", className)}>
                <Panel 
                    title={inputTitle} 
                    className="h-full"
                    showActions={true}
                    codeValue={inputValue}
                    onRun={onCodeRun}
                >
                    <Editor
                        height="100%"
                        width="100%"
                            language={inputLanguage}
                        value={inputValue}
                        onChange={onInputChange}
                            theme={inputLanguage == "jac" and "jac-theme" or (props.editorTheme or "vs-light")}
                            onMount={lambda editor: any, monaco: any -> None { inputEditorRef.current = editor; monacoRef.current = monaco; handleOnMountIfJac(editor, monaco, inputLanguage); }}
                        options={{
                            "fontSize": 14,
                            "minimap": {"enabled": false},
                            "scrollBeyondLastLine": false,
                            "automaticLayout": true,
                            "padding": {"top": 12}
                        }}
                    />
                </Panel>
                
                <Panel 
                    title={outputTitle} 
                    className="h-full"
                    showActions={true}
                    codeValue={outputValue}
                    onRun={onCodeRun}
                >
                    <Editor
                        height="100%"
                        width="100%"
                        language={outputLanguage}
                        value={outputValue}
                        theme={outputLanguage == "jac" and "jac-theme" or (props.editorTheme or "vs-light")}
                        onMount={lambda editor: any, monaco: any -> None { outputEditorRef.current = editor; monacoRef.current = monaco; handleOnMountIfJac(editor, monaco, outputLanguage); }}
                        options={{
                            "fontSize": 14,
                            "minimap": {"enabled": false},
                            "scrollBeyondLastLine": false,
                            "automaticLayout": true,
                            "readOnly": true,
                            "padding": {"top": 12}
                        }}
                    />
                </Panel>
            </div>
        );
    }
}
