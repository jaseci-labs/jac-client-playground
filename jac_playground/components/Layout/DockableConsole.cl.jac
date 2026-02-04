import from react { useMemo }
import from "lucide-react" { 
    Terminal, 
    AlertCircle, 
    FileText, 
    ChevronUp, 
    ChevronDown,
    X,
    Eraser,
    Maximize2,
    Minimize2
}
import from "...lib.utils" { cn }


def: pub DockableConsole(props: dict) -> JsxElement {
    isOpen = props.isOpen;
    if isOpen == None {
        isOpen = true;
    }
    onToggle = props.onToggle;
    height = props.height or 200;
    onHeightChange = props.onHeightChange;
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

    has activeTab: str = "output";
    has isMaximized: bool = false;
    has isDragging: bool = false;
    
    tabs = [
        { "id": "output", "icon": Terminal, "label": "Output", "content": output, "onClear": onClearOutput },
        { "id": "errors", "icon": AlertCircle, "label": "Problems", "content": errors, "onClear": onClearErrors, "badge": errors != "" and errors.split("\n").length or 0 },
        { "id": "logs", "icon": FileText, "label": "Logs", "content": logs, "onClear": onClearLogs }
    ];
    
    activeTabData = tabs.find(lambda t: dict -> bool { return t["id"] == activeTab; });
    
    def handleMouseDown(e: any) -> None {
        isDragging = true;
        startY = e.clientY;
        startHeight = height;
        
        def onMouseMove(moveE: any) -> None {
            deltaY = startY - moveE.clientY;
            newHeight = startHeight + deltaY;
            newHeight = Math.max(100, Math.min(500, newHeight));
            onHeightChange(newHeight);
        }
        
        def onMouseUp() -> None {
            isDragging = false;
            document.removeEventListener("mousemove", onMouseMove);
            document.removeEventListener("mouseup", onMouseUp);
        }
        
        document.addEventListener("mousemove", onMouseMove);
        document.addEventListener("mouseup", onMouseUp);
    }
    
    if not isOpen {
        return (
            <div className="h-8 bg-surface border-t border-border flex items-center px-3 gap-2">
                {tabs.map(lambda tab: dict -> any {
                    Icon = tab["icon"];
                    badgeValue = "badge" in tab and tab["badge"] or 0;
                    hasBadge = badgeValue > 0;
                    
                    return (
                        <button
                            key={tab["id"]}
                            onClick={lambda -> None { activeTab = tab["id"]; onToggle(); }}
                            className="flex items-center gap-1.5 px-2 py-1 text-xs text-text-secondary hover:text-text-primary transition-colors"
                        >
                            <Icon size={12} />
                            <span>{tab["label"]}</span>
                            {hasBadge and (
                                <span className="px-1 py-0.5 bg-error text-error-foreground text-[10px] rounded-full min-w-[16px] text-center">
                                    {badgeValue}
                                </span>
                            )}
                        </button>
                    );
                })}
                
                <button
                    onClick={onToggle}
                    className="ml-auto p-1 text-text-secondary hover:text-text-primary transition-colors"
                >
                    <ChevronUp size={14} />
                </button>
            </div>
        );
    }
    
    panelHeight = isMaximized and "h-[60vh]" or f"h-[{height}px]";
    
    return (
        <div 
            className={cn(
                "bg-surface border-t border-border flex flex-col transition-all",
                isMaximized and "h-[60vh]" or ""
            )}
            style={isMaximized and {} or { "height": f"{height}px" }}
        >
            <div 
                className={cn(
                    "h-1 cursor-ns-resize hover:bg-primary/30 transition-colors",
                    isDragging and "bg-primary/50"
                )}
                onMouseDown={handleMouseDown}
            />
            
            <div className="flex items-center justify-between h-8 px-2 border-b border-border">
                <div className="flex items-center gap-1">
                    {tabs.map(lambda tab: dict -> any {
                        Icon = tab["icon"];
                        isActive = activeTab == tab["id"];
                        hasBadge = ("badge" in tab and tab["badge"] or 0) > 0;
                        
                        return (
                            <button
                                key={tab["id"]}
                                onClick={lambda -> None { activeTab = tab["id"]; }}
                                className={cn(
                                    "flex items-center gap-1.5 px-2.5 py-1 text-xs rounded-t transition-colors",
                                    isActive and "bg-background text-text-primary border-t-2 border-primary" or "text-text-secondary hover:text-text-primary"
                                )}
                            >
                                <Icon size={12} />
                                <span>{tab["label"]}</span>
                                {hasBadge and (
                                    <span className="px-1 py-0.5 bg-error text-error-foreground text-[10px] rounded-full min-w-[14px] text-center">
                                        {tab["badge"]}
                                    </span>
                                )}
                            </button>
                        );
                    })}
                </div>
                
                <div className="flex items-center gap-1">
                    {activeTabData and activeTabData["onClear"] and (
                        <button
                            onClick={activeTabData["onClear"]}
                            className="p-1 text-text-secondary hover:text-text-primary transition-colors"
                            title="Clear"
                        >
                            <Eraser size={12} />
                        </button>
                    )}
                    
                    <button
                        onClick={lambda -> None { isMaximized = not isMaximized; }}
                        className="p-1 text-text-secondary hover:text-text-primary transition-colors"
                        title={isMaximized and "Restore" or "Maximize"}
                    >
                        {isMaximized and (<Minimize2 size={12} />) or (<Maximize2 size={12} />)}
                    </button>
                    
                    <button
                        onClick={onToggle}
                        className="p-1 text-text-secondary hover:text-text-primary transition-colors"
                        title="Minimize"
                    >
                        <ChevronDown size={14} />
                    </button>
                </div>
            </div>
            
            <div className="flex-1 overflow-auto bg-background">
                <pre className="p-3 text-xs font-mono text-text-secondary whitespace-pre-wrap">
                    {activeTabData and activeTabData["content"] or "No output"}
                </pre>
            </div>
        </div>
    );
}
