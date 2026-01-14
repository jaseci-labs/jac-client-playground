cl import from react { useMemo }
cl import from "lucide-react" { Terminal, AlertCircle, FileText, Eraser }
cl import from "....lib.utils" { cn }

cl {
    def: pub OutputPanel(props: dict) -> any {
        original_output = props.output or "";
        
        output = useMemo(lambda -> str {
            pattern = Reflect.construct(RegExp, ['<==START PRINT GRAPH==>.*?<==END PRINT GRAPH==>', 'gs']);
            return original_output.replace(pattern, '');
        }, [original_output]);
        
        errors = props.errors or "";
        logs = props.logs or "";
        onClearOutput = props.onClearOutput;
        onClearErrors = props.onClearErrors;
        onClearLogs = props.onClearLogs;
        className = props.className or "";

        has activeTab: str = "output";
        
        tabs = [
            { "id": "output", "icon": Terminal, "label": "Output", "content": output, "onClear": onClearOutput },
            { "id": "problems", "icon": AlertCircle, "label": "Problems", "content": errors, "onClear": onClearErrors, "badge": errors != "" and errors.split("\n").length or 0 },
            { "id": "logs", "icon": FileText, "label": "Logs", "content": logs, "onClear": onClearLogs }
        ];
        
        activeTabData = tabs.find(lambda t: dict -> bool { return t["id"] == activeTab; });
        
        return (
            <div className={cn("h-full flex flex-col bg-background", className)}>
                <div className="flex items-center justify-between h-11 px-2 border-b border-border bg-surface">
                    <div className="flex items-center gap-0.5">
                        {tabs.map(lambda tab: dict -> any {
                            Icon = tab["icon"];
                            isActive = activeTab == tab["id"];
                            badge = "badge" in tab and tab["badge"] or 0;
                            hasBadge = badge > 0;
                            
                            return (
                                <button
                                    key={tab["id"]}
                                    onClick={lambda -> None { activeTab = tab["id"]; }}
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
