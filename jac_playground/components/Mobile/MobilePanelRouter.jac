cl import from ".MobilePanels.CodePanel" { CodePanel }
cl import from ".MobilePanels.GraphPanel" { GraphPanel }
cl import from ".MobilePanels.OutputPanel" { OutputPanel }
cl import from ".MobilePanels.ExamplesPanel" { ExamplesPanel }

cl {
    def MobilePanelRouter(props: dict) -> any {
        let activePanel = props.activePanel or "code";
        let mode = props.mode or "jac";
        
        # Code panel props
        let codeValue = props.codeValue or "";
        let onCodeChange = props.onCodeChange;
        let outputCode = props.outputCode or "";
        
        # Graph panel props
        let graphData = props.graphData;
        
        # Output panel props
        let output = props.output or "";
        let errors = props.errors or "";
        let logs = props.logs or "";
        let onClearOutput = props.onClearOutput;
        let onClearErrors = props.onClearErrors;
        let onClearLogs = props.onClearLogs;
        
        # Examples panel props
        let examples = props.examples or [];
        let onSelectExample = props.onSelectExample;
        
        # Render only the active panel for performance
        if activePanel == "code" {
            return (
                <CodePanel
                    mode={mode}
                    value={codeValue}
                    onChange={onCodeChange}
                    outputValue={outputCode}
                />
            );
        }
        
        if activePanel == "graph" {
            return (
                <GraphPanel graphData={graphData} />
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
