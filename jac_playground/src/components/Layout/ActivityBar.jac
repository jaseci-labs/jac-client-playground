cl import from "lucide-react" { 
    Code2, 
    ArrowRightLeft, 
    Settings, 
    FileCode,
    Braces,
    Layers,
    ChevronLeft,
    ChevronRight
}
cl import from "...lib.utils" { cn }

cl {
    def: pub ActivityBar(props: dict) -> any {
        mode = props.mode or "jac";
        onModeChange = props.onModeChange;
        collapsed = props.collapsed or false;
        onToggleCollapse = props.onToggleCollapse;
        
        modeItems = [
            { 
                "id": "jac", 
                "icon": Code2, 
                "label": "Jac Playground",
                "description": "Write and run Jac code"
            },
            { 
                "id": "jac2py", 
                "icon": Braces, 
                "label": "Jac → Python",
                "description": "Convert Jac to Python"
            },
            { 
                "id": "py2jac", 
                "icon": FileCode, 
                "label": "Python → Jac",
                "description": "Convert Python to Jac"
            }
        ];
        
        # bottomItems = [
        #     { 
        #         "id": "settings", 
        #         "icon": Settings, 
        #         "label": "Settings",
        #         "description": "Playground settings"
        #     }
        # ];
        
        return (
            <div className={cn(
                "h-full flex flex-col bg-surface border-r border-border transition-all duration-200",
                collapsed and "w-12" or "w-48"
            )}>
                <div className="flex-1 flex flex-col py-2">
                    <div className="px-2 mb-2">
                        {not collapsed and (
                            <span className="text-[10px] font-medium text-text-secondary uppercase tracking-wider px-2">
                                Modes
                            </span>
                        )}
                    </div>
                    
                    {modeItems.map(lambda item: dict -> any {
                        Icon = item["icon"];
                        isActive = mode == item["id"];
                        
                        return (
                            <button
                                key={item["id"]}
                                onClick={lambda -> None { onModeChange(item["id"]); }}
                                className={cn(
                                    "flex items-center gap-3 px-3 py-2.5 mx-1 rounded-md transition-all",
                                    "hover:bg-primary/10",
                                    isActive and "bg-primary/15 text-primary border-l-2 border-primary" or "text-text-secondary"
                                )}
                                title={item["description"]}
                            >
                                <Icon size={18} className={isActive and "text-primary" or ""} />
                                {not collapsed and (
                                    <span className={cn(
                                        "text-sm font-medium truncate",
                                        isActive and "text-primary" or ""
                                    )}>
                                        {item["label"]}
                                    </span>
                                )}
                            </button>
                        );
                    })}
                </div>
                
                <div className="border-t border-border py-2">
                    # {bottomItems.map(lambda item: dict -> any {
                    #     Icon = item["icon"];
                        
                    #     return (
                    #         <button
                    #             key={item["id"]}
                    #             className="flex items-center gap-3 px-3 py-2.5 mx-1 rounded-md text-text-secondary hover:bg-primary/10 transition-all"
                    #             title={item["description"]}
                    #         >
                    #             <Icon size={18} />
                    #             {not collapsed and (
                    #                 <span className="text-sm font-medium">
                    #                     {item["label"]}
                    #                 </span>
                    #             )}
                    #         </button>
                    #     );
                    # })}
                    
                    <button
                        onClick={onToggleCollapse}
                        className="flex items-center justify-center gap-3 px-3 py-2 mx-1 rounded-md text-text-secondary hover:bg-primary/10 transition-all"
                        title={collapsed and "Expand sidebar" or "Collapse sidebar"}
                    >
                        {collapsed and (<ChevronRight size={18} />) or (<ChevronLeft size={18} />)}
                        {not collapsed and (
                            <span className="text-sm font-medium">Collapse</span>
                        )}
                    </button>
                </div>
            </div>
        );
    }
}
