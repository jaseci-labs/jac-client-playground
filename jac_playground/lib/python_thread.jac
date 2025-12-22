cl {
    obj PythonThread {

        def constructor(loadedCallback: lambda -> None {} ) {
            let sharedBuffer = Reflect.construct(SharedArrayBuffer, [4 * 3]);
            self.sharedInts = Reflect.construct(Int32Array, [sharedBuffer]);

            self.pythonThread = Reflect.construct(Worker, ["/static/assets/python.js"]);
            console.log("Python Worker initialized");
            
            self.callbackLoaded = loadedCallback;
            self.pythonThread.onmessage = self.messageHandler.bind(self);
            self.pythonThread.postMessage({ "type": "initialize", "sharedBuffer": sharedBuffer });
        }

        async def messageHandler(event: any) -> None {
            let data = event.data;

            if (data.type == "initialized") {
                console.log("Python Thread initialized");
                if (data.success) {
                    console.log("Python environment is ready");
                } else {
                    console.error("Failed to initialize Python environment");
                }
            } 
            elif (data.type == "stdout") {
                if (self.callbackStdout != None) {
                    self.callbackStdout(data.output);
                }
            } 
            elif (data.type == "stderr") {
                if (self.callbackStderr != None) {
                    self.callbackStderr(data.output);
                }
            } 
            elif (data.type == "conversionResult") {
                if (self.callbackConversionResult != None) {
                    self.callbackConversionResult(data.result);
                }
            } 
            elif (data.type == "breakHit") {
                if (self.callbackBreakHit != None) {
                    self.callbackBreakHit(data.line);
                }
            } 
            elif (data.type == "execEnd") {
                if (self.callbackExecEnd != None) {
                    self.callbackExecEnd();
                }
            } 
            elif (data.type == "jacGraph") {
                if (self.callbackJacGraph != None) {
                    self.callbackJacGraph(data.graph);
                }
            }
        }

        async def startExecution(code: str) -> None {
            self.pythonThread.postMessage({ 
                "type": "startExecution", 
                "code": code 
            });
        }

        async def startConversion(conversionType: str, inputCode: str) -> None {
            self.pythonThread.postMessage({ 
                "type": "convertCode", 
                "conversionType": conversionType,
                "inputCode": inputCode 
            });
        }

        async def startPythonExecution(code: str) -> None {
            self.pythonThread.postMessage({ 
                "type": "executePython", 
                "code": code 
            });
        }

        async def setBreakpoints(breakpoints: list) -> None {
            self.pythonThread.postMessage({ 
                "type": "setBreakpoints", 
                "breakpoints": breakpoints 
            });
        }

        async def continueExecution() -> None {
            self.sharedInts[0] = 1;
            self.sharedInts[1] = 3;
            Atomics.notify(self.sharedInts, 0, 1);
        }

        async def stepOver() -> None {
            self.sharedInts[0] = 1;
            self.sharedInts[1] = 4;
            Atomics.notify(self.sharedInts, 0, 1);
        }

        async def stepInto() -> None {
            self.sharedInts[0] = 1;
            self.sharedInts[1] = 5;
            Atomics.notify(self.sharedInts, 0, 1);
        }

        async def stepOut() -> None {
            self.sharedInts[0] = 1;
            self.sharedInts[1] = 6;
            Atomics.notify(self.sharedInts, 0, 1);
        }

        async def terminate() -> None {
            # self.isRunning = false;
            self.sharedInts[0] = 1;
            self.sharedInts[1] = 7;
            Atomics.notify(self.sharedInts, 0, 1);
        }
    }
}