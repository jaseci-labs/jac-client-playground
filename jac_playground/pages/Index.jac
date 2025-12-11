
cl import from react { useState, useEffect }

cl import from ..components.button { Button }
cl import from ..components.CodeEditor { CodeEditor }
cl import from ..components.output_pannel { OutputPanel }
cl import from ..components.mode_selector { ModeSelector }
cl import from ..components.resizable_panel { ResizablePanel }

cl import from "..hooks.useMobile" { useIsMobile }
cl import from "..lib.utils" { cn }
cl import from "lucide-react" { Menu }



cl {

    def Index() -> any {
        let [code, setCode] = useState("");
        let [output, setOutput] = useState("");
        let [isLoading, setIsLoading] = useState(false);
        let [outIsError, setOutIsError] = useState(false);

        
        async def handleRunCode() -> None {
            setIsLoading(true);
            setOutIsError(false);
            console.log("Running Jac code...");
            result = code_processor(source_code=code, mode="run") spawn root;
            setOutput(result.reports[0] or "");
            setIsLoading(false);
        }

        async def handleModeChange(newMode: str) -> None {
            console.log("Mode changed to: " + newMode);
        }

        let isMobile = useIsMobile();

        return (
            <div className={cn("h-screen w-screen bg-gray-100 flex flex-col overflow-hidden", "px-10")}>
                <header className="h-14 border-b bg-card flex items-center justify-between px-4 flex-shrink-0">
                    <div className="flex items-center space-x-2">
                        <h1 className="text-lg font-semibold bg-gradient-to-r from-primary to-primary bg-clip-text text-transparent">Jac Playground</h1>
                    </div>
                    <div className="flex items-center space-x-2">
                        {isMobile and (
                            <Button
                                variant="outline"
                                size="icon"
                                # onClick={toggleMobileSidebar}
                                aria-label="Toggle sidebar"
                            >
                                <Menu className="h-5 w-5" />
                            </Button>
                        )}
                    </div>
                </header>

                <div className="flex-1 flex flex-col overflow-hidden">
                    <div className="h-12 flex items-center justify-center bg-muted/20 border-y">
                        <Button 
                            onClick={handleRunCode}
                            disabled={isLoading}
                            className="bg-primary text-primary-foreground hover:bg-primary/90 px-6 py-2 rounded-md font-medium"
                        >
                            {isLoading and "Running..." or "Run Code"}
                        </Button>

                        <ModeSelector onModeChange={handleModeChange}/>
                    </div>

                    <div className="flex-1 min-h-0">
                        <CodeEditor onChange={lambda newValue: any -> None {setCode(newValue);}} />
                    </div>
                    
                    <div className="h-48 border-t">
                        <ResizablePanel isHorizontal={true}>
                            <OutputPanel 
                                isLoading={isLoading} 
                                onClear={lambda e: any -> None {setOutput("");}} 
                                output={output} 
                                outIsError={outIsError} 
                            />
                        </ResizablePanel>
                    </div>

                </div>
            </div>
        );
    }
}