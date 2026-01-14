cl import from react { useEffect, useCallback, useRef }
cl import from "..lib.python_thread" { PythonThread }

cl {
  
    def: pub usePlayground(props: dict) -> dict {
        # ===========================================
        # CORE STATE
        # ===========================================
        
        # Theme state
        has theme: str = "light";
        
        # Mode state
        has mode: str = "jac";
        
        # Code state
        editorRef = useRef(null);
        has jacCode: str = "";
        has pythonCode: str = "";
        has outputCode: str = "";
        
        # Output state (separated for console tabs)
        has output: str = "";
        has errors: str = "";
        has logs: str = "";
        
        # Examples data
        [examples, setExamples] = useState(props.examples or []);
        
        # Execution state
        has pythonThread: any = None;
        has isRunning: bool = false;
        has isConverting: bool = false;
        has isDebugging: bool = false;
        has breakpoints: list = [];
        
        # Desktop-specific UI state
        has activityBarCollapsed: bool = false;
        has rightPanelOpen: bool = true;
        has rightPanelSection: str = "examples";
        has consoleOpen: bool = true;
        has consoleHeight: int = 200;
        
        # Mobile-specific UI state
        has activePanel: str = "code";

        # Graph data state
        has graphData: dict | None = None;
        
        has envReady: bool = props.envReady or false;
        
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
                envReady = loaded;
            }]);
            pythonThread = newPythonThread;
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
                outputCode = "";
                jacCode = "";
                pythonCode = "";  # Clear Python input when entering py2jac
            } 
            
            mode = newMode;
            output = "";
            errors = "";
            outputCode = "";
        }
        
        # Handle theme toggle
        def handleToggleTheme() -> None {
            theme = theme == "dark" and "light" or "dark";
        }
        
        # Handle example selection
        def handleSelectExample(exampleId: str) -> None {
            for ex in examples {
                if ex["id"] == exampleId {
                    jacCode = ex["code"];
                    mode = "jac";
                    logs = f"✓ Loaded example: {ex['title']}";
                    # Navigate to code panel on mobile
                    activePanel = "code";
                }
            }
        }

        def runJacCodes(jac_code: str) -> None {
            pythonThread.callbackBreakHit = lambda lineNumber: int -> None {
                console.log(f"⚠️ Hit breakpoint at line {lineNumber}. Execution paused.");
                editorRef.current?.highlightExecutionLine(lineNumber);
            };
            pythonThread.callbackStdout = lambda outputText: str -> None {
                output = lambda prev: str -> str {
                    return prev + outputText;
                };
            };
            pythonThread.callbackStderr = lambda errorText: str -> None {
                output = lambda prev: str -> str {
                    return prev + errorText;
                };
            };
            pythonThread.callbackExecEnd = lambda -> None {
                isRunning = false;
                console.log("Execution ended");
                editorRef.current?.clearExecutionHighlight();
            };
            pythonThread.callbackJacGraph = lambda graph_str: any -> None {
                graph = JSON.parse(graph_str);
                graphData = graph;
            };
            try {
                pythonThread.startExecution(jac_code);
            } except err {
                console.error("Error starting Jac code execution:", err);
            }
        }

        def handleBreakpointsChange(breakpoints: list) -> None {
            breakpoints = breakpoints;
            if (pythonThread) {
                setTimeout(lambda -> None {
                    pythonThread.setBreakpoints(breakpoints);
                }, 100);
            }
        }

        def runPythonCodes(python_code: str) -> None {
            pythonThread.callbackStdout = lambda outputText: str -> None {
                output = lambda prev: str -> str {
                    return prev + outputText;
                };
            };
            pythonThread.callbackStderr = lambda errorText: str -> None {
                output = lambda prev: str -> str {
                    return prev + errorText;
                };
            };
            try {
                pythonThread.startPythonExecution(python_code);
            } except err {
                console.error("Error starting Python code execution:", err);
            }
        }

        def performConversion(code: str, conversionType: str) -> None {
            pythonThread.callbackConversionResult = lambda result: str -> None {
                outputCode = lambda prev: str -> str {
                    return prev + result;
                };
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
            isRunning = true;
            output = "";
            errors = "";
            graphData = None;
            
            # Navigate to output panel on mobile for immediate feedback
            activePanel = "output";

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
            isRunning = false;
        }
        
        # Convert code based on mode
        async def handleConvert() -> None {
            isConverting = true;
            output = "";
            outputCode = "";
            
            if mode == "jac2py" {
                logs = "Converting Jac to Python...";
                performConversion(jacCode, "jac2py");
                logs = "✓ Conversion complete.";
            } else {
                logs = "Converting Python to Jac...";
                performConversion(pythonCode, "py2jac");
                logs = "✓ Conversion complete.";
            }
            isConverting = false;
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
                output = "";
                pythonThread.startExecution(jacCode);
                isRunning = true;
            }
            elif (action == "stop") {
                console.log("stop");
                pythonThread.terminate();
            }
        }, [breakpoints, pythonThread, jacCode]);
        
        # Reset editor
        def handleReset() -> None {
            jacCode = "";
            pythonCode = "";
            outputCode = "";
            output = "";
            errors = "";
            logs = "";
        }
        
        # Toggle debug mode
        def handleDebug() -> None {
            isDebugging = not isDebugging;
            logs = isDebugging and "Debug mode disabled." or "Debug mode enabled. Set breakpoints in the editor.";
        }
        
        # Clear handlers
        def handleClearOutput() -> None {
            output = "";
        }
        
        def handleClearErrors() -> None {
            errors = "";
        }
        
        def handleClearLogs() -> None {
            logs = "";
        }
        
        # Code change handlers
        def handleJacCodeChange(v: any) -> None {
            jacCode = v;
        }
        
        def handlePythonCodeChange(v: any) -> None {
            pythonCode = v;
        }
        
        # Desktop UI handlers
        def handleToggleActivityBar() -> None {
            activityBarCollapsed = not activityBarCollapsed;
        }
        
        def handleToggleRightPanel() -> None {
            rightPanelOpen = not rightPanelOpen;
        }
        
        def handleToggleConsole() -> None {
            consoleOpen = not consoleOpen;
        }
        
        # Mobile navigation handlers
        def handleNavigateToCode() -> None {
            activePanel = "code";
        }
        
        def handleNavigateToOutput() -> None {
            activePanel = "output";
        }
        
        def handleNavigateToGraph() -> None {
            activePanel = "graph";
        }
        
        def handleNavigateToExamples() -> None {
            activePanel = "examples";
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
