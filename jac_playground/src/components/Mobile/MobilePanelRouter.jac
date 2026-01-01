cl import from ".MobilePanels.CodePanel" { CodePanel }
cl import from ".MobilePanels.GraphPanel" { GraphPanel }
cl import from ".MobilePanels.OutputPanel" { OutputPanel }
cl import from ".MobilePanels.ExamplesPanel" { ExamplesPanel }

cl {
    def: pub MobilePanelRouter(props: dict) -> any {
        activePanel = props.activePanel or "code";
        mode = props.mode or "jac";
        editorTheme = props.editorTheme or "vs-light";
        isDarkMode = props.isDarkMode or false;
        
        # Code panel props
        codeValue = props.codeValue or "";
        onCodeChange = props.onCodeChange;
        outputCode = props.outputCode or "";
        onRun = props.onRun;
        isRunning = props.isRunning or false;
        
        # Graph panel props
        graphData = props.graphData;
        
        # Output panel props
        output = props.output or "";
        errors = props.errors or "";
        logs = props.logs or "";
        onClearOutput = props.onClearOutput;
        onClearErrors = props.onClearErrors;
        onClearLogs = props.onClearLogs;
        
        # Examples panel props
        examples = props.examples or [];
        onSelectExample = props.onSelectExample;
        
        # Render only the active panel for performance
        if activePanel == "code" {
            return (
                <CodePanel
                    mode={mode}
                    value={codeValue}
                    onChange={onCodeChange}
                    outputValue={outputCode}
                    onRun={onRun}
                    isRunning={isRunning}
                    editorTheme={editorTheme}
                />
            );
        }
        
        if activePanel == "graph" {
            return (
                <GraphPanel graphData={graphData} isDarkMode={isDarkMode} />
            );
        }
        
        if activePanel == "output" {
            return (
                <OutputPanel
                    output={output}
                    errors={errors}
                    logs={logs}
                    onClearOutput={onClearOutput}
                    onClearErrors={onClearErrors}
                    onClearLogs={onClearLogs}
                />
            );
        }
        
        if activePanel == "examples" {
            return (
                <ExamplesPanel
                    examples={examples}
                    onSelectExample={onSelectExample}
                />
            );
        }
        
        return None;
    }
}
