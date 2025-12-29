cl import from react { useState, Suspense, lazy }
cl import from "lucide-react" { Waypoints, ZoomIn, ZoomOut, Maximize2, Loader2 }
cl import from "....lib.utils" { cn }
cl import from "...Visualizer" { Visualizer }

cl {
    def GraphPanel(props: dict) -> any {
        let graphData = props.graphData;
        let className = props.className or "";
        let isDarkMode = props.isDarkMode or false;
        
        let [zoom, setZoom] = useState(1);
        let [isFullscreen, setIsFullscreen] = useState(false);
        
        let hasGraph = graphData and graphData.nodes and graphData.nodes.length > 0;
        
        def handleZoomIn() -> None {
            setZoom(Math.min(zoom + 0.25, 3));
        }
        
        def handleZoomOut() -> None {
            setZoom(Math.max(zoom - 0.25, 0.5));
        }
        
        def handleFullscreen() -> None {
            setIsFullscreen(not isFullscreen);
            # Could implement actual fullscreen API here
        }
        
        return (
            <div className={cn("h-full flex flex-col bg-background", className)}>
                <div className="h-11 px-3 flex items-center justify-between border-b border-border bg-surface">
                    <div className="flex items-center gap-2">
                        <Waypoints className="w-4 h-4 text-primary" />
                        <span className="text-sm font-medium text-text-primary">Graph Visualizer</span>
                    </div>
                    
                    <div className="flex items-center gap-1">
                        <button
                            onClick={handleZoomOut}
                            className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                            aria-label="Zoom out"
                            disabled={zoom <= 0.5}
                        >
                            <ZoomOut className="w-4 h-4" />
                        </button>
                        
                        <span className="text-xs text-text-secondary min-w-[40px] text-center">
                            {Math.round(zoom * 100)}%
                        </span>
                        
                        <button
                            onClick={handleZoomIn}
                            className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                            aria-label="Zoom in"
                            disabled={zoom >= 3}
                        >
                            <ZoomIn className="w-4 h-4" />
                        </button>
                        
                        <button
                            onClick={handleFullscreen}
                            className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                            aria-label="Toggle fullscreen"
                        >
                            <Maximize2 className="w-4 h-4" />
                        </button>
                    </div>
                </div>
                
                <div className="flex-1 overflow-hidden relative">
                    {hasGraph and (
                        <Visualizer 
                            graphData={graphData} 
                            showHeader={false} 
                            isDarkMode={isDarkMode}
                        />
                    )}
                    
                    {(not hasGraph) and (
                        <div className="h-full flex flex-col items-center justify-center text-center px-6">
                            <Waypoints className="w-12 h-12 text-text-secondary mb-4" />
                            <h3 className="text-base font-medium text-text-primary mb-2">No Graph Data</h3>
                            <p className="text-sm text-text-secondary max-w-[250px]">
                                Run your Jac code to visualize the graph structure here.
                            </p>
                        </div>
                    )}
                </div>
            </div>
        );
    }
}
