cl import from react { useState }
cl import from "lucide-react" { X, Plus, Code2, Network, TreeDeciduous, FileText }
cl import from "...lib.utils" { cn }

cl {
    def WorkspaceTabs(props: dict) -> any {
        let tabs = props.tabs or [];
        let activeTab = props.activeTab or "";
        let onTabChange = props.onTabChange;
        let onTabClose = props.onTabClose;
        let onAddTab = props.onAddTab;
        
        # Default tab icons based on type
        def getTabIcon(tabType: str) -> any {
            if tabType == "editor" {
                return Code2;
            } elif tabType == "graph" {
                return Network;
            } elif tabType == "ast" {
                return TreeDeciduous;
            } else {
                return FileText;
            }
        }
        
        return (
            <div className="flex items-center bg-surface border-b border-border h-9 overflow-x-auto">
                <div className="flex items-center h-full">
                    {tabs.map(lambda tab: dict -> any {
                        let Icon = tab["icon"] or getTabIcon(tab["type"] or "editor");
                        let isActive = activeTab == tab["id"];
                        
                        return (
                            <div
                                key={tab["id"]}
                                className={cn(
                                    "group flex items-center gap-2 h-full px-3 border-r border-border cursor-pointer transition-colors",
                                    isActive and "bg-background text-text-primary border-t-2 border-t-primary" or "text-text-secondary hover:bg-background/50"
                                )}
                                onClick={lambda -> None { onTabChange(tab["id"]); }}
                            >
                                <Icon size={14} className={isActive and "text-primary" or ""} />
                                <span className="text-xs font-medium whitespace-nowrap">{tab["label"]}</span>
                                
                                {tab["closable"] != false and (
                                    <button
                                        onClick={lambda e: any -> None { 
                                            e.stopPropagation(); 
                                            onTabClose(tab["id"]); 
                                        }}
                                        className="opacity-0 group-hover:opacity-100 p-0.5 rounded hover:bg-red-500/20 hover:text-red-500 transition-all"
                                    >
                                        <X size={12} />
                                    </button>
                                )}
                            </div>
                        );
                    })}
                </div>
                
                {onAddTab and (
                    <button
                        onClick={onAddTab}
                        className="flex items-center justify-center w-8 h-full text-text-secondary hover:text-text-primary hover:bg-background/50 transition-colors"
                        title="New tab"
                    >
                        <Plus size={14} />
                    </button>
                )}
            </div>
        );
    }
}
