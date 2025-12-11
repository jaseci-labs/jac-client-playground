

cl import from react { useState, useEffect }
cl import from "..lib.utils" { cn }
cl import from "..hooks.useMobile" { useIsMobile }
cl import from ".TopBar" { TopBar }
cl import from ".JacWorkspace" { JacWorkspace }
cl import from ".ConversionEditor" { ConversionEditor }
cl import from ".Layout.ActivityBar" { ActivityBar }
cl import from ".Layout.EditorToolbar" { EditorToolbar }
cl import from ".Layout.RightPanel" { RightPanel }
cl import from ".Layout.DockableConsole" { DockableConsole }
cl import from ".Mobile.MobileLayout" { MobileLayout }

cl {
    def PlayGroundLayout(props: dict) -> any {
        # Core state
        let [mode, setMode] = useState("jac");
        let [jacCode, setJacCode] = useState("");
        let [pythonCode, setPythonCode] = useState("");
        let [outputCode, setOutputCode] = useState("");
        
        # Output state (separated for console tabs)
        let [output, setOutput] = useState("");
        let [errors, setErrors] = useState("");
        let [logs, setLogs] = useState("");
        let [examples, setExamples] = useState([]);
        
        # UI state
        let [isRunning, setIsRunning] = useState(false);
        let [isConverting, setIsConverting] = useState(false);
        let [isDebugging, setIsDebugging] = useState(false);
        let [activityBarCollapsed, setActivityBarCollapsed] = useState(false);
        let [rightPanelOpen, setRightPanelOpen] = useState(true);
        let [rightPanelSection, setRightPanelSection] = useState("examples");
        let [consoleOpen, setConsoleOpen] = useState(true);
        let [consoleHeight, setConsoleHeight] = useState(200);

        useEffect(lambda -> None {
            async def loadExamples() -> None {
                loaded_examples = load_example_list() spawn root;
                setExamples(loaded_examples.reports[0] or []);
            }
            loadExamples();
        }, []);

        # Handle example selection
        def onSelectExample(exampleId: str) -> None {
            for ex in examples {
                if ex["id"] == exampleId {
                    setJacCode(ex["code"]);
                    setMode("jac");
                    setLogs(f"✓ Loaded example: {ex['title']}");
                }
            }
        }

        # Handle mode change
        def handleModeChange(newMode: str) -> None {
            setMode(newMode);
            setOutput("");
            setErrors("");
            setOutputCode("");
        }

        # Run Jac code
        async def onRun(title: str = "") -> None {
            let result = [];
            setIsRunning(true);
            setOutput("");
            setErrors("");

            if title == "Python Input" {
                result = code_processor(source_code=pythonCode, mode="pyrun") spawn root;
            } elif title == "Jac Input" {
                result = code_processor(source_code=jacCode, mode="jacrun") spawn root;
            } elif title == "Python Output" {
                result = code_processor(source_code=outputCode, mode="pyrun") spawn root;
            } elif title == "Jac Output" {
                result = code_processor(source_code=outputCode, mode="jacrun") spawn root;
            } else {
                result = code_processor(source_code=jacCode, mode="jacrun") spawn root;
            }
            
            setOutput(result.reports[0] or "Execution complete.");
            setIsRunning(false);
        }

        # Reset editor
        def onReset() -> None {
            setJacCode("");
            setOutput("");
            setErrors("");
            setLogs("");
        }

        # Convert code based on mode
        async def onConvert() -> None {
            setIsConverting(true);
            setOutput("");
            
            if mode == "jac2py" {
                setLogs("Converting Jac to Python...");
                result = code_processor(source_code=jacCode, mode="jac2py") spawn root;
                setOutputCode(result.reports[0] or "# Conversion result");
                setLogs("✓ Conversion complete.");
            } else {
                setLogs("Converting Python to Jac...");
                result = code_processor(source_code=pythonCode, mode="py2jac") spawn root;
                setOutputCode(result.reports[0] or "# Conversion result");
                setLogs("✓ Conversion complete.");
            }
            setIsConverting(false);
        }

        # Debug handlers
        def onDebug() -> None {
            setIsDebugging( not isDebugging);
            setLogs(isDebugging and "Debug mode disabled." or "Debug mode enabled. Set breakpoints in the editor.");
        }

        let envReady = props.envReady or true;
        let graphData = props.graphData;
        
        # Check if mobile viewport
        let isMobile = useIsMobile();
        
        # Render mobile layout for mobile devices
        if isMobile {
            return (
                <MobileLayout
                    mode={mode}
                    onModeChange={handleModeChange}
                    jacCode={jacCode}
                    pythonCode={pythonCode}
                    outputCode={outputCode}
                    onJacCodeChange={lambda v: any -> None { setJacCode(v); }}
                    onPythonCodeChange={lambda v: any -> None { setPythonCode(v); }}
                    output={output}
                    errors={errors}
                    logs={logs}
                    onClearOutput={lambda -> None { setOutput(""); }}
                    onClearErrors={lambda -> None { setErrors(""); }}
                    onClearLogs={lambda -> None { setLogs(""); }}
                    graphData={graphData}
                    examples={examples}
                    onSelectExample={onSelectExample}
                    onRun={onRun}
                    onConvert={onConvert}
                    isRunning={isRunning}
                    isConverting={isConverting}
                    isDebugging={isDebugging}
                    onDebug={onDebug}
                    onReset={onReset}
                    envReady={envReady}
                />
            );
        }
        
        # Desktop layout
        return (
            <div className="h-screen flex flex-col bg-background text-text-primary">
                <TopBar envReady={envReady} />
                
                <div className="flex-1 flex overflow-hidden">
                    <ActivityBar
                        mode={mode}
                        onModeChange={handleModeChange}
                        collapsed={activityBarCollapsed}
                        onToggleCollapse={lambda -> None { setActivityBarCollapsed(not activityBarCollapsed); }}
                    />
                    
                    <div className="flex-1 flex flex-col overflow-hidden">
                        <EditorToolbar
                            mode={mode}
                            onRun={onRun}
                            onReset={onReset}
                            onConvert={onConvert}
                            onDebug={onDebug}
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
                                            onChange={lambda v: any -> None { setJacCode(v); }}
                                            graphData={graphData}
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
                                            onInputChange={lambda v: any -> None { setJacCode(v); }}
                                            onCodeRun={onRun}
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
                                            onInputChange={lambda v: any -> None { setPythonCode(v); }}
                                            onCodeRun={onRun}
                                        />
                                    </div>
                                )}
                            </div>
                            
                            <RightPanel
                                isOpen={rightPanelOpen}
                                onToggle={lambda -> None { setRightPanelOpen(not rightPanelOpen); }}
                                examples={examples}
                                onSelectExample={onSelectExample}
                                activeSection={rightPanelSection}
                                onSectionChange={setRightPanelSection}
                            />
                        </div>
                        
                        <DockableConsole
                            isOpen={consoleOpen}
                            onToggle={lambda -> None { setConsoleOpen(not consoleOpen); }}
                            height={consoleHeight}
                            onHeightChange={setConsoleHeight}
                            output={output}
                            errors={errors}
                            logs={logs}
                            onClearOutput={lambda -> None { setOutput(""); }}
                            onClearErrors={lambda -> None { setErrors(""); }}
                            onClearLogs={lambda -> None { setLogs(""); }}
                        />
                    </div>
                </div>
            </div>
        );
    }
}