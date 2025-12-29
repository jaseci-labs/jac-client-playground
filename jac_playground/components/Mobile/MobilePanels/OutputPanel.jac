cl import from react { useState }
cl import from "lucide-react" { Terminal, AlertCircle, FileText, Eraser }
cl import from "....lib.utils" { cn }

cl {
    def OutputPanel(props: dict) -> any {
        let output = props.output or "";
        let errors = props.errors or "";
        let logs = props.logs or "";
        let onClearOutput = props.onClearOutput;
        let onClearErrors = props.onClearErrors;
        let onClearLogs = props.onClearLogs;
        let className = props.className or "";
        
        let [activeTab, setActiveTab] = useState("output");
        
        let tabs = [
            { "id": "output", "icon": Terminal, "label": "Output", "content": output, "onClear": onClearOutput },
            { "id": "problems", "icon": AlertCircle, "label": "Problems", "content": errors, "onClear": onClearErrors, "badge": errors != "" and errors.split("\n").length or 0 },
            { "id": "logs", "icon": FileText, "label": "Logs", "content": logs, "onClear": onClearLogs }
        ];
        
        let activeTabData = tabs.find(lambda t: dict -> bool { return t["id"] == activeTab; });
        
        return (
            <div className={cn("h-full flex flex-col bg-background", className)}>
                <div className="flex items-center justify-between h-11 px-2 border-b border-border bg-surface">
                    <div className="flex items-center gap-0.5">
                        {tabs.map(lambda tab: dict -> any {
                            let Icon = tab["icon"];
                            let isActive = activeTab == tab["id"];
                            let badge = "badge" in tab and tab["badge"] or 0;
                            let hasBadge = badge > 0;
                            
                            return (
                                <button
                                    key={tab["id"]}
                                    onClick={lambda -> None { setActiveTab(tab["id"]); }}
                                    className={cn(
                                        "flex items-center gap-1.5 px-3 py-2 text-xs font-medium rounded-md transition-colors",
                                        isActive and "bg-background text-text-primary" or "text-text-secondary"
                                    )}
                                    aria-selected={isActive}
                                    role="tab"
                                >
                                    <Icon className="w-3.5 h-3.5" />
                                    <span>{tab["label"]}</span>
                                    {hasBadge and (
                                        <span className="px-1.5 py-0.5 bg-error text-error-foreground text-[10px] rounded-full min-w-[18px] text-center">
                                            {badge}
                                        </span>
                                    )}
                                </button>
                            );
                        })}
                    </div>
                    
                    {activeTabData and activeTabData["onClear"] and (
                        <button
                            onClick={activeTabData["onClear"]}
                            className="p-2 rounded-md text-text-secondary hover:bg-background transition-colors"
                            aria-label="Clear output"
                        >
                            <Eraser className="w-4 h-4" />
                        </button>
                    )}
                </div>
                
                <div 
                    className="flex-1 overflow-auto p-3 bg-console font-mono text-sm"
                    role="tabpanel"
                >
                    {activeTabData and activeTabData["content"] and (
                        <pre className={cn(
                            "whitespace-pre-wrap break-words",
                            activeTab == "problems" and "text-error" or "text-console-text"
                        )}>
                            {activeTabData["content"]}
                        </pre>
                    )}
                    
                    {activeTabData and (not activeTabData["content"]) and (
                        <div className="h-full flex items-center justify-center">
                            <p className="text-text-secondary text-center">
                                {activeTab == "output" and "No output yet. Run your code to see results."}
                                {activeTab == "problems" and "No problems detected."}
                                {activeTab == "logs" and "No logs available."}
                            </p>
                        </div>
                    )}
                </div>
            </div>
        );
    }
}
