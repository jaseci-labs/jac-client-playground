cl {
    obj PythonThread {

        def constructor(loadedCallback: lambda -> None {} ) {
            console.log("Initializing Python Worker");
            self.pythonThread = Reflect.construct(Worker, ["/static/assets/python.js"]);
            console.log("Python Worker initialized");
            
            self.callbackLoaded = loadedCallback;
            self.pythonThread.onmessage = self.messageHandler.bind(self);
            self.pythonThread.postMessage({ "type": "initialize" });
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
            } elif (data.type == "stdout") {
                if (self.callbackStdout != None) {
                    self.callbackStdout(data.output);
                }
            } elif (data.type == "stderr") {
                if (self.callbackStderr != None) {
                    self.callbackStderr(data.output);
                }
            } elif (data.type == "conversionResult") {
                if (self.callbackConversionResult != None) {
                    self.callbackConversionResult(data.result);
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
    }
}