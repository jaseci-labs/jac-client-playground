cl import from "..lib.utils" { cn }
cl import from ".ui.Panel" { Panel }
cl import from "@monaco-editor/react" { Editor }

cl {
    def ConversionEditor(props: dict) -> any {
        let inputTitle = props.inputTitle or "Input";
        let outputTitle = props.outputTitle or "Output";
        let inputLanguage = props.inputLanguage or "python";
        let outputLanguage = props.outputLanguage or "python";
        let inputValue = props.inputValue or "";
        let outputValue = props.outputValue or "";
        let onInputChange = props.onInputChange;
        let className = props.className or "";
        let onCodeRun = props.onCodeRun;
        
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
                        language={inputLanguage == "jac" and "python" or inputLanguage}
                        value={inputValue}
                        onChange={onInputChange}
                        theme={props.editorTheme or "vs-light"}
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
                        language={outputLanguage == "jac" and "python" or outputLanguage}
                        value={outputValue}
                        theme={props.editorTheme or "vs-light"}
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
