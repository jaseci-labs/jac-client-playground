cl import from react { useState }
cl import from "lucide-react" { Maximize2, Minimize2, Columns2, Code2, GitGraph }
cl import from "..lib.utils" { cn }
cl import from ".ui.Panel" { Panel }
cl import from "@monaco-editor/react" { Editor }
cl import from ".Visualizer" { Visualizer }

cl {
    def JacWorkspace(props: dict) -> any {
        let value = props.value or "";
        let onChange = props.onChange;
        let graphData = props.graphData;
        let className = props.className or "";
        
        # View state: "split" | "editor" | "graph"
        let [viewMode, setViewMode] = useState("split");
        
        let showEditor = viewMode == "split" or viewMode == "editor";
        let showGraph = viewMode == "split" or viewMode == "graph";
        
        return (
            <div className={cn("h-full w-full flex flex-col", className)}>
                <div className="flex-1 flex gap-3 min-h-0">
                    {showEditor and (
                        <div className={cn(
                            "h-full rounded-lg border border-border overflow-hidden bg-surface flex flex-col",
                            viewMode == "split" and "w-1/2" or "flex-1"
                        )}>
                            <div className="h-9 px-3 flex items-center justify-between border-b border-border bg-surface-hover">
                                <div className="flex items-center gap-2">
                                    <Code2 className="w-4 h-4 text-primary" />
                                    <span className="text-xs font-medium text-text-primary">Editor</span>
                                </div>
                                <div className="flex items-center gap-1">
                                    {viewMode == "editor" and (
                                        <button
                                            onClick={lambda -> None { setViewMode("split"); }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Split View"
                                        >
                                            <Columns2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                    {viewMode != "editor" and (
                                        <button
                                            onClick={lambda -> None { setViewMode("editor"); }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Maximize Editor"
                                        >
                                            <Maximize2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                </div>
                            </div>
                            <div className="flex-1 overflow-hidden">
                                <Editor
                                    height="100%"
                                    width="100%"
                                    language="python"
                                    value={value}
                                    onChange={onChange}
                                    theme={props.editorTheme or "vs-light"}
                                    options={{
                                        "fontSize": 14,
                                        "minimap": {"enabled": false},
                                        "scrollBeyondLastLine": false,
                                        "automaticLayout": true,
                                        "padding": {"top": 12}
                                    }}
                                />
                            </div>
                        </div>
                    )}
                    
                    {showGraph and (
                        <div className={cn(
                            "h-full rounded-lg border border-border overflow-hidden bg-surface flex flex-col",
                            viewMode == "split" and "w-1/2" or "flex-1"
                        )}>
                            <div className="h-9 px-3 flex items-center justify-between border-b border-border bg-surface-hover">
                                <div className="flex items-center gap-2">
                                    <GitGraph className="w-4 h-4 text-primary" />
                                    <span className="text-xs font-medium text-text-primary">Graph Visualizer</span>
                                </div>
                                <div className="flex items-center gap-1">
                                    {viewMode == "graph" and (
                                        <button
                                            onClick={lambda -> None { setViewMode("split"); }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Split View"
                                        >
                                            <Columns2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                    {viewMode != "graph" and (
                                        <button
                                            onClick={lambda -> None { setViewMode("graph"); }}
                                            className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                            title="Maximize Graph"
                                        >
                                            <Maximize2 className="w-3.5 h-3.5" />
                                        </button>
                                    )}
                                </div>
                            </div>
                            <div className="flex-1 overflow-hidden">
                                <Visualizer graphData={graphData} showHeader={false} />
                            </div>
                        </div>
                    )}
                </div>
            </div>
        );
    }
}
