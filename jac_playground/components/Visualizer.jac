# import React from "react";
# import GraphRenderer from "./GraphRenderer";

# export type VisualizerProps = {
#   graphData?: any;
#   loading?: boolean;
#   error?: string | null;
# };

# export default function Visualizer({ graphData, loading, error }: VisualizerProps) {
#   return (
#     <div className="h-full flex flex-col">
#       <div className="px-4 py-3 border-b border-border bg-panel text-sm text-text-secondary">Graph Visualizer</div>

#       <div className="flex-1 flex items-center justify-center bg-panel">
#         {loading ? (
#           <div className="text-text-secondary">Loading graph…</div>
#         ) : error ? (
#           <div className="text-error">{error}</div>
#         ) : graphData ? (
#           <GraphRenderer data={graphData} />
#         ) : (
#           <div className="text-text-secondary text-center px-6">
#             <div className="mb-3 text-3xl">🔗</div>
#             <div>Jac Graph Visualizer</div>
#             <div className="text-sm text-text-secondary mt-2">Execute your Jac code to see the graph visualization.</div>
#           </div>
#         )}
#       </div>
#     </div>
#   );
# }

cl import from "lucide-react" { Waypoints }

cl {
    def Visualizer(props:dict) -> any {
        let graphData = props.graphData;
        let loading = props.loading;
        let error = props.error;

        return (
            <div className="h-full flex flex-col">
                <div className="px-4 py-3 border-b border-border bg-panel text-sm text-text-secondary">Graph Visualizer</div>
                <div className="flex items-center gap-2 px-3 py-2 border-b border-border bg-panel">
                    <div className="text-xs text-text-secondary">Graph Visualizer</div>
                    <div className="flex-1" />
                    <div className="text-xs text-text-secondary">Jac</div>
                </div>
                <div className="flex-1 flex items-center justify-center bg-panel">
                <div className="text-text-secondary text-center px-6 flex flex-col items-center justify-center">
                        <div className="mb-3 text-3xl text-center"><Waypoints/></div >
                        <div>Jac Graph Visualizer</div >
                        <div className="text-sm text-text-secondary mt-2">Execute your Jac code to see the graph visualization.</div >
                    </div > 
              
                </div>
            </div>
        );
    }
}
