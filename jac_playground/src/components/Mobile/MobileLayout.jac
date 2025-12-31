cl import from "...lib.utils" { cn }
cl import from ".MobileBottomNav" { MobileBottomNav }
cl import from ".MobileFAB" { MobileFAB }
cl import from ".MobilePanelRouter" { MobilePanelRouter }
cl import from ".MobileDebugController" { MobileDebugController }
cl import from ".MobileModeSwitcher" { MobileModeSwitcher }
cl import from "..ui.ThemeToggle" { ThemeToggle }

cl {
    
    def MobileLayout(props: dict) -> any {
        # Theme
        theme = props.theme or "light";
        editorTheme = props.editorTheme or "vs-light";
        onToggleTheme = props.onToggleTheme;
        
        # Mode
        mode = props.mode or "jac";
        onModeChange = props.onModeChange;
        
        # Code state
        jacCode = props.jacCode or "";
        pythonCode = props.pythonCode or "";
        outputCode = props.outputCode or "";
        codeValue = props.codeValue or (mode == "py2jac" and pythonCode or jacCode);
        onJacCodeChange = props.onJacCodeChange;
        onPythonCodeChange = props.onPythonCodeChange;
        onCodeChange = mode == "py2jac" and onPythonCodeChange or onJacCodeChange;
        
        # Output state
        output = props.output or "";
        errors = props.errors or "";
        logs = props.logs or "";
        onClearOutput = props.onClearOutput;
        onClearErrors = props.onClearErrors;
        onClearLogs = props.onClearLogs;
        
        # Graph data
        graphData = props.graphData;
        
        # Examples
        examples = props.examples or [];
        onSelectExample = props.onSelectExample;
        
        # Execution
        onRun = props.onRun;
        onConvert = props.onConvert;
        onReset = props.onReset;
        isRunning = props.isRunning or false;
        isConverting = props.isConverting or false;
        
        # Debug
        onDebug = props.onDebug;
        isDebugging = props.isDebugging or false;
        onStepOver = props.onStepOver;
        onStepInto = props.onStepInto;
        onStepOut = props.onStepOut;
        onStop = props.onStop;
        
        # Environment
        envReady = props.envReady or true;
        
        # Mobile UI state (from hook)
        activePanel = props.activePanel or "code";
        onPanelChange = props.onPanelChange;
        problemsBadge = props.problemsBadge or 0;
        
        # Navigation handlers (from hook)
        onNavigateToCode = props.onNavigateToCode;
        onNavigateToOutput = props.onNavigateToOutput;
        
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
                        
                        <ThemeToggle
                            theme={theme}
                            onToggleTheme={onToggleTheme}
                            className="p-1.5"
                        />
                        
                        <div className={cn(
                            "px-2 py-0.5 rounded-full text-xs font-medium",
                            envReady and "bg-success/15 text-success" or "bg-border text-text-secondary"
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
                        editorTheme={editorTheme}
                        isDarkMode={theme == "dark"}
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
