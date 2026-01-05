cl import from react { useState, useEffect, useCallback, useRef }
cl import from "..lib.python_thread" { PythonThread }

cl {
  
    def: pub usePlayground(props: dict) -> dict {
        # ===========================================
        # CORE STATE
        # ===========================================
        
        # Theme state
        [theme, setTheme] = useState("light");
        
        # Mode state
        [mode, setMode] = useState("jac");
        
        # Code state
        editorRef = useRef(null);
        [jacCode, setJacCode] = useState("");
        [pythonCode, setPythonCode] = useState("");
        [outputCode, setOutputCode] = useState("");
        
        # Output state (separated for console tabs)
        [output, setOutput] = useState("");
        [errors, setErrors] = useState("");
        [logs, setLogs] = useState("");
        
        # Examples data
        [examples, setExamples] = useState([]);
        
        # Execution state
        [pythonThread, setPythonThread] = useState(None);
        [isRunning, setIsRunning] = useState(false);
        [isConverting, setIsConverting] = useState(false);
        [isDebugging, setIsDebugging] = useState(false);
        [breakpoints, setBreakpoints] = useState([]);
        
        # Desktop-specific UI state
        [activityBarCollapsed, setActivityBarCollapsed] = useState(false);
        [rightPanelOpen, setRightPanelOpen] = useState(true);
        [rightPanelSection, setRightPanelSection] = useState("examples");
        [consoleOpen, setConsoleOpen] = useState(true);
        [consoleHeight, setConsoleHeight] = useState(200);
        
        # Mobile-specific UI state
        [activePanel, setActivePanel] = useState("code");

        # Graph data state
        [graphData, setGraphData] = useState(None);
        
        [envReady, setEnvReady] = useState(props.envReady or false);
        
        # ===========================================
        # DERIVED VALUES
        # ===========================================
        
        # Determine which code value to use based on mode
        codeValue = mode == "py2jac" and pythonCode or jacCode;
        
        # Calculate Monaco editor theme based on app theme
        editorTheme = theme == "dark" and "vs-dark" or "vs-light";
        
        # Calculate badges for problems
        problemsBadge = errors != "" and errors.split("\n").length or 0;
        
        # ===========================================
        # EFFECTS
        # ===========================================
        
        # Inject viewport meta tag for proper mobile rendering
        useEffect(lambda -> None {
            existingViewport = document.querySelector("meta[name='viewport']");
            if not existingViewport {
                meta = document.createElement("meta");
                meta.name = "viewport";
                meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no";
                document.head.appendChild(meta);
            }
        }, []);
        
        # Apply theme class to document
        useEffect(lambda -> None {
            if theme == "dark" {
                document.documentElement.classList.add("dark");
            } else {
                document.documentElement.classList.remove("dark");
            }
        }, [theme]);

        useEffect(lambda -> None {
            console.log("App mounted");
            newPythonThread = Reflect.construct(PythonThread, [lambda loaded: bool -> None {
                setEnvReady(loaded);
            }]);
            setPythonThread(newPythonThread);
        }, []);

        useEffect(lambda -> None {
            if (pythonThread) {
                console.log("Syncing breakpoints to Python thread:", breakpoints);
                pythonThread.setBreakpoints(breakpoints);
            }
        }, [breakpoints, pythonThread]);

        
        # ===========================================
        # HANDLERS - Business Logic
        # ===========================================
        
        # Handle mode change
        def handleModeChange(newMode: str) -> None {
            # Clear conversion inputs when switching between conversion modes
            # This prevents stale data from showing in the wrong input field
            if newMode == "py2jac" {
                setOutputCode("");
                setJacCode("");
                setPythonCode("");  # Clear Python input when entering py2jac
            } 
            
            setMode(newMode);
            setOutput("");
            setErrors("");
            setOutputCode("");
        }
        
        # Handle theme toggle
        def handleToggleTheme() -> None {
            setTheme(theme == "dark" and "light" or "dark");
        }
        
        # Handle example selection
        def handleSelectExample(exampleId: str) -> None {
            for ex in examples {
                if ex["id"] == exampleId {
                    setJacCode(ex["code"]);
                    setMode("jac");
                    setLogs(f"✓ Loaded example: {ex['title']}");
                    # Navigate to code panel on mobile
                    setActivePanel("code");
                }
            }
        }

        def runJacCodes(jac_code: str) -> None {
            pythonThread.callbackBreakHit = lambda lineNumber: int -> None {
                console.log(f"⚠️ Hit breakpoint at line {lineNumber}. Execution paused.");
                editorRef.current?.highlightExecutionLine(lineNumber);
            };
            pythonThread.callbackStdout = lambda outputText: str -> None {
                setOutput(lambda prev: str -> str {
                    return prev + outputText;
                });
            };
            pythonThread.callbackStderr = lambda errorText: str -> None {
                setOutput(lambda prev: str -> str {
                    return prev + errorText;
                });
            };
            pythonThread.callbackExecEnd = lambda -> None {
                setIsRunning(false);
                console.log("***** Execution ended");
                editorRef.current?.clearExecutionHighlight();
            };
            pythonThread.callbackJacGraph = lambda graph_str: any -> None {
                graph = JSON.parse(graph_str);
                setGraphData(graph);
            };
            try {
                pythonThread.startExecution(jac_code);
            } except err {
                console.error("Error starting Jac code execution:", err);
            }
        }

        def handleBreakpointsChange(breakpoints: list) -> None {
            console.log("Breakpoints updated:", breakpoints);
            setBreakpoints(breakpoints);
            console.log("**** hitting this");
            if (pythonThread) {
                setTimeout(lambda -> None {
                    pythonThread.setBreakpoints(breakpoints);
                }, 100);
            }
        }

        def runPythonCodes(python_code: str) -> None {
            pythonThread.callbackStdout = lambda outputText: str -> None {
                setOutput(lambda prev: str -> str {
                    return prev + outputText;
                });
            };
            pythonThread.callbackStderr = lambda errorText: str -> None {
                setOutput(lambda prev: str -> str {
                    return prev + errorText;
                });
            };
            try {
                pythonThread.startPythonExecution(python_code);
            } except err {
                console.error("Error starting Python code execution:", err);
            }
        }

        def performConversion(code: str, conversionType: str) -> None {
            pythonThread.callbackConversionResult = lambda result: str -> None {
                setOutputCode(lambda prev: str -> str {
                    return prev + result;
                });
            };
            try {
                pythonThread.startConversion(conversionType, code);
            } except err {
                console.error("Error starting code conversion:", err);
            }
        }
        
        # Run code - unified handler for all modes
        async def handleRun(title: str = "") -> None {
            result = [];
            graph = [];
            setIsRunning(true);
            setOutput("");
            setErrors("");
            setGraphData(None);
            
            # Navigate to output panel on mobile for immediate feedback
            setActivePanel("output");

            if title == "Python Input" {
                runPythonCodes(pythonCode);
            }
            elif title == "Jac Input" {
                runJacCodes(jacCode);
            }
            elif title == "Python Output" {
                runPythonCodes(outputCode);
            }
            elif title == "Jac Output" {
                runJacCodes(outputCode);
            }
            else {
                runJacCodes(jacCode);
            }
            setIsRunning(false);
        }
        
        # Convert code based on mode
        async def handleConvert() -> None {
            setIsConverting(true);
            setOutput("");
            setOutputCode("");
            
            if mode == "jac2py" {
                setLogs("Converting Jac to Python...");
                performConversion(jacCode, "jac2py");
                setLogs("✓ Conversion complete.");
            } else {
                setLogs("Converting Python to Jac...");
                performConversion(pythonCode, "py2jac");
                setLogs("✓ Conversion complete.");
            }
            setIsConverting(false);
        }
        
        handleDebugAction = useCallback(lambda action: str -> None {
            if (action == "continue") {
                console.log("continue");
                pythonThread.continueExecution();
            }
            elif (action == "stepOver") {
                console.log("stepOver");
                pythonThread.stepOver();
            }
            elif (action == "stepInto") {
                console.log("stepInto");
                pythonThread.stepInto();
            } 
            elif (action == "stepOut") {
                console.log("stepOut");
                pythonThread.stepOut();
            } 
            elif (action == "restart") {
                console.log("restart");
                editorRef.current?.clearExecutionHighlight();
                if (isRunning) {
                    pythonThread.terminate();
                    Reflect.construct(Promise, [
                        lambda resolve: any -> None {
                            setTimeout(resolve, 1000);
                        }
                    ]);
                }
                setOutput("");
                pythonThread.startExecution(jacCode);
                setIsRunning(true);
            }
            elif (action == "stop") {
                console.log("stop");
                pythonThread.terminate();
            }
        }, [breakpoints, pythonThread, jacCode]);
        
        # Reset editor
        def handleReset() -> None {
            setJacCode("");
            setPythonCode("");
            setOutputCode("");
            setOutput("");
            setErrors("");
            setLogs("");
        }
        
        # Toggle debug mode
        def handleDebug() -> None {
            setIsDebugging(not isDebugging);
            setLogs(isDebugging and "Debug mode disabled." or "Debug mode enabled. Set breakpoints in the editor.");
        }
        
        # Clear handlers
        def handleClearOutput() -> None {
            setOutput("");
        }
        
        def handleClearErrors() -> None {
            setErrors("");
        }
        
        def handleClearLogs() -> None {
            setLogs("");
        }
        
        # Code change handlers
        def handleJacCodeChange(v: any) -> None {
            setJacCode(v);
        }
        
        def handlePythonCodeChange(v: any) -> None {
            setPythonCode(v);
        }
        
        # Desktop UI handlers
        def handleToggleActivityBar() -> None {
            setActivityBarCollapsed(not activityBarCollapsed);
        }
        
        def handleToggleRightPanel() -> None {
            setRightPanelOpen(not rightPanelOpen);
        }
        
        def handleToggleConsole() -> None {
            setConsoleOpen(not consoleOpen);
        }
        
        # Mobile navigation handlers
        def handleNavigateToCode() -> None {
            setActivePanel("code");
        }
        
        def handleNavigateToOutput() -> None {
            setActivePanel("output");
        }
        
        def handleNavigateToGraph() -> None {
            setActivePanel("graph");
        }
        
        def handleNavigateToExamples() -> None {
            setActivePanel("examples");
        }
        
        # ===========================================
        # RETURN ALL STATE AND HANDLERS
        # ===========================================
        
        return {
            # Theme
            "theme": theme,
            "editorTheme": editorTheme,
            "onToggleTheme": handleToggleTheme,
            
            # Mode
            "mode": mode,
            "onModeChange": handleModeChange,
            
            # Code state
            "jacCode": jacCode,
            "pythonCode": pythonCode,
            "outputCode": outputCode,
            "codeValue": codeValue,
            "onJacCodeChange": handleJacCodeChange,
            "onPythonCodeChange": handlePythonCodeChange,
            
            # Output state
            "output": output,
            "errors": errors,
            "logs": logs,
            "onClearOutput": handleClearOutput,
            "onClearErrors": handleClearErrors,
            "onClearLogs": handleClearLogs,
            
            # Examples
            "examples": examples,
            "setExamples": setExamples,
            "onSelectExample": handleSelectExample,
            
            # Execution
            "isRunning": isRunning,
            "isConverting": isConverting,
            "isDebugging": isDebugging,
            "onRun": handleRun,
            "onConvert": handleConvert,
            "onReset": handleReset,
            "onDebug": handleDebug,
            "onhandleDebugAction": handleDebugAction,
            
            # Derived
            "problemsBadge": problemsBadge,
            
            # Props passthrough
            "envReady": envReady,
            "graphData": graphData,
            
            # Desktop UI state
            "activityBarCollapsed": activityBarCollapsed,
            "onToggleActivityBar": handleToggleActivityBar,
            "rightPanelOpen": rightPanelOpen,
            "onToggleRightPanel": handleToggleRightPanel,
            "rightPanelSection": rightPanelSection,
            "onRightPanelSectionChange": setRightPanelSection,
            "consoleOpen": consoleOpen,
            "onToggleConsole": handleToggleConsole,
            "consoleHeight": consoleHeight,
            "onConsoleHeightChange": setConsoleHeight,
            "onBreakpointsChange": handleBreakpointsChange,
            
            # Mobile UI state
            "activePanel": activePanel,
            "onPanelChange": setActivePanel,
            "onNavigateToCode": handleNavigateToCode,
            "onNavigateToOutput": handleNavigateToOutput,
            "onNavigateToGraph": handleNavigateToGraph,
            "onNavigateToExamples": handleNavigateToExamples,

            "editorRef": editorRef
        };
    }
}
