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
        
        return (
            <div className={cn("h-full w-full grid grid-cols-2 gap-3", className)}>
                <Panel title={inputTitle} subtitle={inputLanguage} className="h-full">
                    <Editor
                        height="100%"
                        width="100%"
                        language={inputLanguage}
                        value={inputValue}
                        onChange={onInputChange}
                        theme="vs-light"
                        options={{
                            "fontSize": 14,
                            "minimap": {"enabled": false},
                            "scrollBeyondLastLine": false,
                            "automaticLayout": true,
                            "padding": {"top": 12}
                        }}
                    />
                </Panel>
                
                <Panel title={outputTitle} subtitle={outputLanguage} className="h-full">
                    <Editor
                        height="100%"
                        width="100%"
                        language={outputLanguage}
                        value={outputValue}
                        theme="vs-light"
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
