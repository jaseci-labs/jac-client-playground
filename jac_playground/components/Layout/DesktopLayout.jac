cl import from "...lib.utils" { cn }
cl import from "..TopBar" { TopBar }
cl import from "..JacWorkspace" { JacWorkspace }
cl import from "..ConversionEditor" { ConversionEditor }
cl import from ".ActivityBar" { ActivityBar }
cl import from ".EditorToolbar" { EditorToolbar }
cl import from ".RightPanel" { RightPanel }
cl import from ".DockableConsole" { DockableConsole }

cl {
    
    def DesktopLayout(props: dict) -> any {
        # Theme
        let theme = props.theme or "light";
        let editorTheme = props.editorTheme or "vs-light";
        let onToggleTheme = props.onToggleTheme;
        
        # Mode
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
        let onBreakpointsChange = props.onBreakpointsChange;
        
        # Examples
        let examples = props.examples or [];
        let onSelectExample = props.onSelectExample;
        
        # Execution state
        let isRunning = props.isRunning or false;
        let isConverting = props.isConverting or false;
        let isDebugging = props.isDebugging or false;
        let onRun = props.onRun;
        let onConvert = props.onConvert;
        let onReset = props.onReset;
        let onDebug = props.onDebug;
        let onhandleDebugAction = props.onhandleDebugAction;
        
        # Props
        let envReady = props.envReady or true;
        let graphData = props.graphData;
        
        # Desktop UI state
        let activityBarCollapsed = props.activityBarCollapsed or false;
        let onToggleActivityBar = props.onToggleActivityBar;
        let rightPanelOpen = props.rightPanelOpen;
        let onToggleRightPanel = props.onToggleRightPanel;
        let rightPanelSection = props.rightPanelSection or "examples";
        let onRightPanelSectionChange = props.onRightPanelSectionChange;
        let consoleOpen = props.consoleOpen;
        let onToggleConsole = props.onToggleConsole;
        let consoleHeight = props.consoleHeight or 200;
        let onConsoleHeightChange = props.onConsoleHeightChange;
        
        return (
            <div className="h-screen flex flex-col bg-background text-text-primary">
                <TopBar 
                    envReady={envReady}
                    theme={theme}
                    onToggleTheme={onToggleTheme}
                />
                
                <div className="flex-1 flex overflow-hidden">
                    <ActivityBar
                        mode={mode}
                        onModeChange={onModeChange}
                        collapsed={activityBarCollapsed}
                        onToggleCollapse={onToggleActivityBar}
                    />
                    
                    <div className="flex-1 flex flex-col overflow-hidden">
                        <EditorToolbar
                            mode={mode}
                            onRun={onRun}
                            onReset={onReset}
                            onConvert={onConvert}
                            onDebug={onDebug}
                            onhandleDebugAction={onhandleDebugAction}
                            isRunning={isRunning}
                            isConverting={isConverting}
                            isDebugging={isDebugging}
                        />
                        
                        <div className="flex-1 flex overflow-hidden">
                            <div className="flex-1 overflow-hidden">
                                {mode == "jac" and (
                                    <div className="h-full p-3">
                                        <JacWorkspace
                                            value={jacCode}
                                            onChange={onJacCodeChange}
                                            graphData={graphData}
                                            editorTheme={editorTheme}
                                            isDarkMode={theme == "dark"}
                                            onBreakpointsChange={onBreakpointsChange}
                                        />
                                    </div>
                                )}
                                
                                {mode == "jac2py" and (
                                    <div className="h-full p-3">
                                        <ConversionEditor
                                            inputTitle="Jac Input"
                                            outputTitle="Python Output"
                                            inputLanguage="jac"
                                            outputLanguage="python"
                                            inputValue={jacCode}
                                            outputValue={outputCode}
                                            onInputChange={onJacCodeChange}
                                            onCodeRun={onRun}
                                            editorTheme={editorTheme}
                                        />
                                    </div>
                                )}
                                
                                {mode == "py2jac" and (
                                    <div className="h-full p-3">
                                        <ConversionEditor
                                            inputTitle="Python Input"
                                            outputTitle="Jac Output"
                                            inputLanguage="python"
                                            outputLanguage="jac"
                                            inputValue={pythonCode}
                                            outputValue={outputCode}
                                            onInputChange={onPythonCodeChange}
                                            onCodeRun={onRun}
                                            editorTheme={editorTheme}
                                        />
                                    </div>
                                )}
                            </div>
                            
                            <RightPanel
                                isOpen={rightPanelOpen}
                                onToggle={onToggleRightPanel}
                                examples={examples}
                                onSelectExample={onSelectExample}
                                activeSection={rightPanelSection}
                                onSectionChange={onRightPanelSectionChange}
                            />
                        </div>
                        
                        <DockableConsole
                            isOpen={consoleOpen}
                            onToggle={onToggleConsole}
                            height={consoleHeight}
                            onHeightChange={onConsoleHeightChange}
                            output={output}
                            errors={errors}
                            logs={logs}
                            onClearOutput={onClearOutput}
                            onClearErrors={onClearErrors}
                            onClearLogs={onClearLogs}
                        />
                    </div>
                </div>
            </div>
        );
    }
}
