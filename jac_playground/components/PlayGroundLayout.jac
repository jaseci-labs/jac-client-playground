# import React from "react";
# import TopBar from "../TopBar/TopBar";
# import CodeEditorWrapper from "../Editor/CodeEditorWrapper";
# import Visualizer from "../Visualizer/Visualizer";
# import Sidebar from "../Sidebar/Sidebar";
# import OutputConsole from "../Output/OutputConsole";

# export type PlaygroundLayoutProps = {
#   code: string;
#   onCodeChange?: (v: string) => void;
#   onRun?: () => void;
#   onReset?: () => void;
#   examples?: { id: string; title: string; description?: string }[];
#   logs?: string[];
#   envReady?: boolean;
#   graphData?: any;
# };

# export default function PlaygroundLayout({
#   code,
#   onCodeChange,
#   onRun,
#   onReset,
#   examples = [],
#   logs = [],
#   envReady = false,
#   graphData,
# }: PlaygroundLayoutProps) {
#   return (
#     <div className="h-screen flex flex-col bg-background text-text-primary">
#       <TopBar onRun={onRun} onReset={onReset} envReady={envReady} />
#       <div className="flex-1 grid grid-cols-[1fr_520px_300px] gap-3 p-3">
#         <div className="col-span-1 panel bg-panel border border-border rounded-md overflow-hidden">
#           <CodeEditorWrapper value={code} onChange={onCodeChange} />
#         </div>

#         <div className="panel bg-panel border border-border rounded-md overflow-hidden">
#           <Visualizer graphData={graphData} />
#         </div>

#         <Sidebar examples={examples} onSelectExample={(id) => console.log("select", id)} />
#         <div className="col-span-3 mt-0">
#           <OutputConsole logs={logs} onClear={() => console.log("clear logs")} />
#         </div>
#       </div>
#     </div>
#   );
# }


cl import from ".TopBar" { TopBar }
cl import from  ".CodeEditorWrapper" { CodeEditorWrapper }
cl import from  ".Visualizer" { Visualizer }
cl import from  ".OutputConsole" { OutputConsole }
cl import from  ".Sidebar" { Sidebar }

cl {
    def PlayGroundLayout(props:dict) -> any {
        let code = props.code;
        let onCodeChange = props.onCodeChange;
        let onRun = props.onRun;
        let onReset = props.onReset;
        let examples = props.examples or [];
        let logs = props.logs or [];
        let envReady = props.envReady or false;
        let graphData = props.graphData;
        return (
            <div className="h-screen flex flex-col bg-background text-text-primary">
                <TopBar onRun={onRun} onReset={onReset} envReady={envReady} mode="run" />
                <div className="flex-1 grid grid-cols-[1fr_520px_300px] gap-3 p-3">
                    <div className="col-span-1 panel bg-panel border border-border rounded-md overflow-hidden">
                        <CodeEditorWrapper value={code} onChange={onCodeChange}/>
                    </div>

                    <div className="panel bg-panel border border-border rounded-md overflow-hidden">
                        <Visualizer graphData={graphData}/>
                    </div>

                    <Sidebar examples={examples} onSelectExample={lambda id:any -> None {console.log("select", id);}}/>
                    <div className="col-span-3 mt-0">
                        <OutputConsole logs={logs} onClear={lambda -> None {console.log("clear logs");}}/>
                    </div>
                </div>
            </div>
        );
    }
}