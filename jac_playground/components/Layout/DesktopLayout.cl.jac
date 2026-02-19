import from "...lib.utils" { cn }
import from "..TopBar" { TopBar }
import from "..JacWorkspace" { JacWorkspace }
import from "..ConversionEditor" { ConversionEditor }
import from ".ActivityBar" { ActivityBar }
import from ".EditorToolbar" { EditorToolbar }
import from ".RightPanel" { RightPanel }
import from ".DockableConsole" { DockableConsole }

def: pub DesktopLayout(props: dict) -> JsxElement {
    # Theme
    theme = props.theme or "light";
    editorTheme = props.editorTheme or "vs-light";
    onToggleTheme = props.onToggleTheme;
    editorRef = props.editorRef;
    
    # Mode
    mode = props.mode or "jac";
    onModeChange = props.onModeChange;
    
    # Code state
    jacCode = props.jacCode or "";
    pythonCode = props.pythonCode or "";
    outputCode = props.outputCode or "";
    onJacCodeChange = props.onJacCodeChange;
    onPythonCodeChange = props.onPythonCodeChange;
    
    # Output state
    output = props.output or "";
    errors = props.errors or "";
    logs = props.logs or "";
    onClearOutput = props.onClearOutput;
    onClearErrors = props.onClearErrors;
    onClearLogs = props.onClearLogs;
    onBreakpointsChange = props.onBreakpointsChange;
    
    # Examples
    examples = props.examples or [];
    onSelectExample = props.onSelectExample;
    
    # Execution state
    isRunning = props.isRunning or false;
    isConverting = props.isConverting or false;
    isDebugging = props.isDebugging or false;
    onRun = props.onRun;
    onConvert = props.onConvert;
    onReset = props.onReset;
    onDebug = props.onDebug;
    onhandleDebugAction = props.onhandleDebugAction;
    
    # Props
    envReady = props.envReady or false;
    graphData = props.graphData;
    
    # Desktop UI state
    activityBarCollapsed = props.activityBarCollapsed or false;
    onToggleActivityBar = props.onToggleActivityBar;
    rightPanelOpen = props.rightPanelOpen;
    onToggleRightPanel = props.onToggleRightPanel;
    rightPanelSection = props.rightPanelSection or "examples";
    onRightPanelSectionChange = props.onRightPanelSectionChange;
    consoleOpen = props.consoleOpen;
    onToggleConsole = props.onToggleConsole;
    consoleHeight = props.consoleHeight or 200;
    onConsoleHeightChange = props.onConsoleHeightChange;
    
    return (
        <div className="h-screen flex flex-col bg-background text-text-primary">
            <TopBar
                envReady={envReady}
                isRunning={isRunning}
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
                        envReady={envReady}
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
                                        ref={editorRef}
                                        language="jac"
                                        theme={theme}
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
                                        envReady={envReady}
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
                                        envReady={envReady}
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

