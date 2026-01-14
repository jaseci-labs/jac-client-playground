import from react { Suspense, lazy }
import from "lucide-react" { Waypoints, ZoomIn, ZoomOut, Maximize2, Loader2 }
import from "....lib.utils" { cn }
import from "...Visualizer" { Visualizer }

def: pub GraphPanel(props: dict) -> any {
    graphData = props.graphData;
    className = props.className or "";
    isDarkMode = props.isDarkMode or false;

    has zoom: float = 1.0;
    has isFullscreen: bool = false; 
    
    hasGraph = graphData and graphData.nodes and graphData.nodes.length > 0;
    
    def handleZoomIn() -> None {
        zoom = Math.min(zoom + 0.25, 3);
    }
    
    def handleZoomOut() -> None {
        zoom = Math.max(zoom - 0.25, 0.5);
    }
    
    def handleFullscreen() -> None {
        isFullscreen = not isFullscreen;
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
