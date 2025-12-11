
cl import from "lucide-react" { Waypoints }

cl {
    def Visualizer(props:dict) -> any {
        let graphData = props.graphData;
        let loading = props.loading;
        let error = props.error;
        let showHeader = props.showHeader;
        let shouldShowHeader = showHeader != false;

        return (
            <div className="h-full flex flex-col">
                {shouldShowHeader and (
                    <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-background">
                        <div className="text-xs text-text-secondary">Graph Visualizer</div>
                        <div className="flex-1" />
                        <div className="text-xs text-text-secondary">output</div>
                    </div>
                )}
                <div className="flex-1 flex items-center justify-center bg-surface">
                    <div className="text-text-secondary text-center px-6 flex flex-col items-center justify-center">
                        <div className="mb-3 text-3xl text-center"><Waypoints className="w-8 h-8" /></div>
                        <div className="font-medium">Jac Graph Visualizer</div>
                        <div className="text-sm text-text-secondary mt-2">Execute your Jac code to see the graph visualization.</div>
                    </div>
                </div>
            </div>
        );
    }
}
