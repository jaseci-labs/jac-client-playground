

cl import from react { useState }
cl import from "lucide-react" { Maximize2, Minimize2 }
cl import from "..lib.utils" { cn }
cl import from ".TopBar" { TopBar }
cl import from ".CodeEditorWrapper" { CodeEditorWrapper }
cl import from ".Visualizer" { Visualizer }
cl import from ".ConversionEditor" { ConversionEditor }
cl import from ".Layout.ActivityBar" { ActivityBar }
cl import from ".Layout.EditorToolbar" { EditorToolbar }
cl import from ".Layout.RightPanel" { RightPanel }
cl import from ".Layout.DockableConsole" { DockableConsole }

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
        
        # UI state
        let [isRunning, setIsRunning] = useState(false);
        let [isConverting, setIsConverting] = useState(false);
        let [isDebugging, setIsDebugging] = useState(false);
        let [activityBarCollapsed, setActivityBarCollapsed] = useState(false);
        let [rightPanelOpen, setRightPanelOpen] = useState(true);
        let [rightPanelSection, setRightPanelSection] = useState("examples");
        let [consoleOpen, setConsoleOpen] = useState(true);
        let [consoleHeight, setConsoleHeight] = useState(200);
        
        # Panel maximize state for Jac mode (null = split view, "editor" = editor full, "graph" = graph full)
        let [maximizedPanel, setMaximizedPanel] = useState("editor");

        # Example Jac code snippets
        let examples = [
            { 
                "id": "hello", 
                "title": "Hello World", 
                "category": "Basics",
                "code": "with entry {\n    print(\"Hello, World!\");\n}"
            },
            { 
                "id": "walker", 
                "title": "Simple Walker", 
                "category": "Walkers",
                "code": "node Person {\n    has name: str;\n}\n\nwalker greet {\n    can say_hello with Person entry {\n        print(f\"Hello, {here.name}!\");\n    }\n}\n\nwith entry {\n    p = Person(name=\"Alice\");\n    greet() spawn p;\n}"
            },
            { 
                "id": "graph", 
                "title": "Graph Example", 
                "category": "Graphs",
                "code": "node City {\n    has name: str;\n}\n\nedge Road {\n    has distance: int;\n}\n\nwith entry {\n    a = City(name=\"New York\");\n    b = City(name=\"Boston\");\n    a ++> Road(distance=200) ++> b;\n    print(\"Graph created!\");\n}"
            },
            { 
                "id": "ability", 
                "title": "Node Abilities", 
                "category": "Abilities",
                "code": "node Counter {\n    has count: int = 0;\n    \n    can increment {\n        self.count += 1;\n        print(f\"Count: {self.count}\");\n    }\n}\n\nwith entry {\n    c = Counter();\n    c.increment();\n    c.increment();\n}"
            },
            { 
                "id": "edges", 
                "title": "Edge Traversal", 
                "category": "Graphs",
                "code": "node Room {\n    has name: str;\n}\n\nedge Door {}\n\nwalker Explorer {\n    can explore with Room entry {\n        print(f\"Visiting: {here.name}\");\n        visit [-->];\n    }\n}\n\nwith entry {\n    r1 = Room(name=\"Living Room\");\n    r2 = Room(name=\"Kitchen\");\n    r3 = Room(name=\"Bedroom\");\n    r1 ++> Door ++> r2 ++> Door ++> r3;\n    Explorer() spawn r1;\n}"
            },
            { 
                "id": "filter", 
                "title": "Filter Walker", 
                "category": "Walkers",
                "code": "node Item {\n    has name: str;\n    has price: float;\n}\n\nwalker ShowExpensive {\n    can check with Item entry {\n        if here.price > 50 {\n            print(f\"{here.name}: ${here.price}\");\n        }\n    }\n}\n\nwith entry {\n    items = [\n        Item(name=\"Book\", price=25.0),\n        Item(name=\"Laptop\", price=999.0),\n        Item(name=\"Coffee\", price=5.0)\n    ];\n    for item in items {\n        ShowExpensive() spawn item;\n    }\n}"
            }
        ];

        # Handle example selection
        def onSelectExample(exampleId: str) -> None {
            for ex in examples {
                if ex["id"] == exampleId {
                    setJacCode(ex["code"]);
                    setMode("jac");
                    setActiveTab("editor");
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
                                        <div className="h-full flex gap-3">
                                            {( maximizedPanel == "editor") and (
                                                <div className={cn(
                                                    "h-full rounded-lg border border-border overflow-hidden bg-surface flex flex-col",
                                                    maximizedPanel == "editor" and "flex-1" or "w-1/2"
                                                )}>
                                                    <div className="h-8 px-3 flex items-center justify-between border-b border-border bg-surface-hover">
                                                        <span className="text-xs font-medium text-text-secondary">Editor</span>
                                                        <button
                                                            onClick={lambda -> None { setMaximizedPanel("graph"); }}
                                                            className="p-1 hover:bg-surface rounded text-text-secondary hover:text-text-primary"
                                                        >
                                                            {maximizedPanel == "editor" and (
                                                                <Minimize2 className="w-3.5 h-3.5" />
                                                            )}
                                                            {maximizedPanel != "editor" and (
                                                                <Maximize2 className="w-3.5 h-3.5" />
                                                            )}
                                                        </button>
                                                    </div>
                                                    <div className="flex-1 overflow-hidden">
                                                        <CodeEditorWrapper 
                                                            value={jacCode} 
                                                            onChange={lambda v: any -> None { setJacCode(v); }}
                                                            language="python"
                                                            showHeader={false}
                                                        />
                                                    </div>
                                                </div>
                                            )}
                                            
                                            {( maximizedPanel == "graph") and (
                                                <div className={cn(
                                                    "h-full rounded-lg border border-border overflow-hidden bg-surface flex flex-col",
                                                    maximizedPanel == "graph" and "flex-1" or "w-1/2"
                                                )}>
                                                    <div className="h-8 px-3 flex items-center justify-between border-b border-border bg-surface-hover">
                                                        <span className="text-xs font-medium text-text-secondary">Graph Visualizer</span>
                                                        <button
                                                            onClick={lambda -> None { setMaximizedPanel("editor"); }}
                                                            className="p-1 hover:bg-surface rounded text-text-secondary hover:text-text-primary"
                                                        >
                                                            {maximizedPanel == "graph" and (
                                                                <Minimize2 className="w-3.5 h-3.5" />
                                                            )}
                                                            {maximizedPanel != "graph" and (
                                                                <Maximize2 className="w-3.5 h-3.5" />
                                                            )}
                                                        </button>
                                                    </div>
                                                    <div className="flex-1 overflow-hidden">
                                                        <Visualizer graphData={graphData} showHeader={false} />
                                                    </div>
                                                </div>
                                            )}
                                        </div>
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