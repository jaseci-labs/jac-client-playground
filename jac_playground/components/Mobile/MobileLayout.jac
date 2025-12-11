cl import from "...lib.utils" { cn }
cl import from ".MobileBottomNav" { MobileBottomNav }
cl import from ".MobileFAB" { MobileFAB }
cl import from ".MobilePanelRouter" { MobilePanelRouter }
cl import from ".MobileDebugController" { MobileDebugController }
cl import from ".MobileModeSwitcher" { MobileModeSwitcher }

cl {
    
    def MobileLayout(props: dict) -> any {
        # Mode
        let mode = props.mode or "jac";
        let onModeChange = props.onModeChange;
        
        # Code state
        let jacCode = props.jacCode or "";
        let pythonCode = props.pythonCode or "";
        let outputCode = props.outputCode or "";
        let codeValue = props.codeValue or (mode == "py2jac" and pythonCode or jacCode);
        let onJacCodeChange = props.onJacCodeChange;
        let onPythonCodeChange = props.onPythonCodeChange;
        let onCodeChange = mode == "py2jac" and onPythonCodeChange or onJacCodeChange;
        
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
        
        # Execution
        let onRun = props.onRun;
        let onConvert = props.onConvert;
        let onReset = props.onReset;
        let isRunning = props.isRunning or false;
        let isConverting = props.isConverting or false;
        
        # Debug
        let onDebug = props.onDebug;
        let isDebugging = props.isDebugging or false;
        let onStepOver = props.onStepOver;
        let onStepInto = props.onStepInto;
        let onStepOut = props.onStepOut;
        let onStop = props.onStop;
        
        # Environment
        let envReady = props.envReady or true;
        
        # Mobile UI state (from hook)
        let activePanel = props.activePanel or "code";
        let onPanelChange = props.onPanelChange;
        let problemsBadge = props.problemsBadge or 0;
        
        # Navigation handlers (from hook)
        let onNavigateToCode = props.onNavigateToCode;
        let onNavigateToOutput = props.onNavigateToOutput;
        
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
                        onRun={onRun}
                        isRunning={isRunning}
                        graphData={graphData}
                        output={output}
                        errors={errors}
                        logs={logs}
                        onClearOutput={onClearOutput}
                        onClearErrors={onClearErrors}
                        onClearLogs={onClearLogs}
                        examples={examples}
                        onSelectExample={onSelectExample}
                        onModeChange={onModeChange}
                        onNavigateToCode={onNavigateToCode}
                    />
                </main>
                
                {mode == "jac" and activePanel == "code" and (
                    <MobileDebugController
                        isDebugging={isDebugging}
                        onToggleDebug={onDebug}
                        onPlay={onRun}
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
                    onRun={onRun}
                    onConvert={onConvert}
                    isRunning={isRunning}
                    isConverting={isConverting}
                />
                
                <MobileBottomNav
                    activePanel={activePanel}
                    onChange={onPanelChange}
                    problemsBadge={problemsBadge}
                />
            </div>
        );
    }
}
