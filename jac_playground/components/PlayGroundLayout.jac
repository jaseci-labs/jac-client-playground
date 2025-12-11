

cl import from react { useState }
cl import from ".TopBar" { TopBar }
cl import from ".CodeEditorWrapper" { CodeEditorWrapper }
cl import from ".Visualizer" { Visualizer }
cl import from ".OutputConsole" { OutputConsole }
cl import from ".resizable_panel" { ResizablePanel }
cl import from ".ConversionEditor" { ConversionEditor }
cl import from ".Controllers.context-toolbar" { ContextToolbar }
cl import from ".ui.Panel" { Panel }
cl import from ".Sidebar" { Sidebar }

cl {
    def PlayGroundLayout(props: dict) -> any {
        let [mode, setMode] = useState("jac");
        let [jacCode, setJacCode] = useState("");
        let [pythonCode, setPythonCode] = useState("");
        let [outputCode, setOutputCode] = useState("");
        let [logs, setLogs] = useState("");
        let [isRunning, setIsRunning] = useState(false);
        let [isConverting, setIsConverting] = useState(false);
        let [sidebarOpen, setSidebarOpen] = useState(true);

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
            }
        ];

        # Handle example selection - load code into Jac editor
        def onSelectExample(exampleId: str) -> None {
            for ex in examples {
                if ex["id"] == exampleId {
                    setJacCode(ex["code"]);
                    setMode("jac");
                    setLogs(f"Loaded example: {ex['title']}");
                }
            }
        }

        # Run Jac code
        async def onRun(title: str = "") -> None {
            let result = [];
            setIsRunning(true);

            if title == "Python Input" {
                result = code_processor(source_code=pythonCode, mode="pyrun") spawn root;
            } elif title == "Jac Input" {
                result = code_processor(source_code=jacCode, mode="jacrun") spawn root;
            } elif title == "Python Output" {
                result = code_processor(source_code=outputCode, mode="pyrun") spawn root;
            } elif title == "Jac Output" {
                result = code_processor(source_code=outputCode, mode="jacrun") spawn root;
            } else {
                result = ["Error code Execution"];
            }
            setLogs(result.reports[0] or "Execution complete.");
            setIsRunning(false);
        }

        # Reset editor
        def onReset() -> None {
            setJacCode("");
            setLogs("");
        }

        # Convert code based on mode
        async def onConvert() -> None {
            setIsConverting(true);
            if mode == "jac2py" {
                setLogs("Converting Jac to Python...");
                result = code_processor(source_code=jacCode, mode="jac2py") spawn root;
                setOutputCode(result.reports[0] or "// Conversion result");
                setLogs("Conversion complete.");
            } else {
                setLogs("Converting Python to Jac...");
                result = code_processor(source_code=pythonCode, mode="py2jac") spawn root;
                setOutputCode(result.reports[0] or "// Conversion result");
                setLogs("Conversion complete.");
            }
            setIsConverting(false);
        }

        let envReady = props.envReady or true;
        let graphData = props.graphData;

        return (
            <div className="h-screen flex flex-col bg-background text-text-primary">
                <TopBar 
                    envReady={envReady} 
                    mode={mode} 
                    onModeChange={lambda newMode: any -> None { setMode(newMode); setLogs(""); setOutputCode(""); }}
                />
                
                <ContextToolbar 
                    mode={mode}
                    onRun={onRun}
                    onReset={onReset}
                    onConvert={onConvert}
                    isRunning={isRunning}
                    isConverting={isConverting}
                />
                
                <div className="flex-1 flex overflow-hidden">
                    <div className="flex-1 flex flex-col overflow-hidden">
                        <div className="flex-1 p-3 overflow-hidden min-h-0">
                            {mode == "jac" and (
                                <div className="h-full grid grid-cols-2 gap-3">
                                    <Panel title="Jac Code Editor" subtitle="jac" showActions={false}>
                                        <CodeEditorWrapper 
                                            value={jacCode} 
                                            onChange={lambda v: any -> None { setJacCode(v); }}
                                            language="python"
                                            showHeader={false}
                                        />
                                    </Panel>
                                    
                                    <Panel title="Graph Visualizer" subtitle="output" showActions={false}>
                                        <Visualizer graphData={graphData} showHeader={false} />
                                    </Panel>
                                </div>
                            )}
                            
                            {mode == "jac2py" and (
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
                            )}
                            
                            {mode == "py2jac" and (
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
                            )}
                        </div>
                        
                        <ResizablePanel 
                            isHorizontal={true} 
                            initialSize={20}
                            minSize={10} 
                            maxSize={50}
                            className="border-t border-border"
                        >
                            <div className="h-full px-3 pb-3">
                                <OutputConsole logs={logs} onClear={lambda -> None { setLogs(""); }}/>
                            </div>
                        </ResizablePanel>
                    </div>
                    
                    <Sidebar 
                        examples={examples}
                        onSelectExample={onSelectExample}
                        version="v1.0.0"
                    />
                </div>
            </div>
        );
    }
}