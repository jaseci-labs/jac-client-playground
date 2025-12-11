cl import from react { useState }
cl import from "...lib.utils" { cn }
cl import from ".MobileBottomNav" { MobileBottomNav }
cl import from ".MobileFAB" { MobileFAB }
cl import from ".MobilePanelRouter" { MobilePanelRouter }
cl import from ".MobileDebugController" { MobileDebugController }
cl import from ".MobileModeSwitcher" { MobileModeSwitcher }

cl {
    def MobileLayout(props: dict) -> any {
        # Core state from parent
        let mode = props.mode or "jac";
        let onModeChange = props.onModeChange;
        
        # Code state
        let jacCode = props.jacCode or "";
        let pythonCode = props.pythonCode or "";
        let outputCode = props.outputCode or "";
        let onJacCodeChange = props.onJacCodeChange;
        let onPythonCodeChange = props.onPythonCodeChange;
        
        # Output state
        let output = props.output or "";
        let errors = props.errors or "";
        let logs = props.logs or "";
        let onClearOutput = props.onClearOutput;
        let onClearErrors = props.onClearErrors;
        let onClearLogs = props.onClearLogs;
        
        # Graph data
        let graphData = props.graphData;
        
        # Examples
        let examples = props.examples or [];
        let onSelectExample = props.onSelectExample;
        
        # Actions
        let onRun = props.onRun;
        let onConvert = props.onConvert;
        let onReset = props.onReset;
        let isRunning = props.isRunning or false;
        let isConverting = props.isConverting or false;
        
        # Debug props
        let onDebug = props.onDebug;
        let isDebugging = props.isDebugging or false;
        let onStepOver = props.onStepOver;
        let onStepInto = props.onStepInto;
        let onStepOut = props.onStepOut;
        let onStop = props.onStop;
        
        # Environment status
        let envReady = props.envReady or true;
        
        # Mobile-specific state
        let [activePanel, setActivePanel] = useState("code");
        
        # Determine which code value to use based on mode
        let codeValue = mode == "py2jac" and pythonCode or jacCode;
        let onCodeChange = mode == "py2jac" and onPythonCodeChange or onJacCodeChange;
        
        # Calculate badges for bottom nav
        let problemsBadge = errors != "" and errors.split("\n").length or 0;
        
        def handleNavigateToCode() -> None {
            setActivePanel("code");
        }
        
        def handleNavigateToOutput() -> None {
            setActivePanel("output");
        }
        
        def handleSelectExample(exampleId: str) -> None {
            onSelectExample(exampleId);
            setActivePanel("code");
        }
        
        # Wrap onRun to auto-navigate to output panel after execution
        async def handleRun(title: str = "") -> None {
            # Navigate to output panel immediately so user sees "Running..."
            setActivePanel("output");
            # Then execute the run
            await onRun(title);
        }
        
        return (
            <div className="h-screen flex flex-col bg-background text-text-primary overflow-hidden">
                <header className="h-12 flex items-center justify-between px-4 bg-surface border-b border-border flex-shrink-0">
                    <div className="flex items-center gap-2">
                        <img src="/static/assets/jaseci.png" className="w-6 h-6" alt="Jaseci" />
                        <span className="text-sm font-semibold text-text-primary">Jac Playground</span>
                    </div>
                    
                    <div className="flex items-center gap-2">
                        <MobileModeSwitcher
                            mode={mode}
                            onModeChange={onModeChange}
                        />
                        
                        <div className={cn(
                            "px-2 py-0.5 rounded-full text-xs font-medium",
                            envReady and "bg-green-500/15 text-green-600" or "bg-gray-200 text-gray-600"
                        )}>
                            {envReady and "Ready" or "..."}
                        </div>
                    </div>
                </header>
                
                <main className="flex-1 overflow-hidden pb-14">
                    <MobilePanelRouter
                        activePanel={activePanel}
                        mode={mode}
                        codeValue={codeValue}
                        onCodeChange={onCodeChange}
                        outputCode={outputCode}
                        onRun={handleRun}
                        isRunning={isRunning}
                        graphData={graphData}
                        output={output}
                        errors={errors}
                        logs={logs}
                        onClearOutput={onClearOutput}
                        onClearErrors={onClearErrors}
                        onClearLogs={onClearLogs}
                        examples={examples}
                        onSelectExample={handleSelectExample}
                        onModeChange={onModeChange}
                        onNavigateToCode={handleNavigateToCode}
                    />
                </main>
                
                {mode == "jac" and activePanel == "code" and (
                    <MobileDebugController
                        isDebugging={isDebugging}
                        onToggleDebug={onDebug}
                        onPlay={handleRun}
                        onStepOver={onStepOver}
                        onStepIn={onStepInto}
                        onStepOut={onStepOut}
                        onRestart={onReset}
                        onStop={onStop}
                        isRunning={isRunning}
                    />
                )}
                
                <MobileFAB
                    mode={mode}
                    activePanel={activePanel}
                    onRun={handleRun}
                    onConvert={onConvert}
                    isRunning={isRunning}
                    isConverting={isConverting}
                />
                
                <MobileBottomNav
                    activePanel={activePanel}
                    onChange={setActivePanel}
                    problemsBadge={problemsBadge}
                />
            </div>
        );
    }
}
