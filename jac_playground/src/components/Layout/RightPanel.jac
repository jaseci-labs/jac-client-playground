cl import from react { useState }
cl import from "lucide-react" { 
    PanelRightClose, 
    PanelRightOpen, 
    BookOpen, 
    Code2, 
    HelpCircle,
    Search,
    ChevronDown,
    ChevronRight,
    FileCode,
    ExternalLink
}
cl import from "...lib.utils" { cn }

cl {
    def: pub RightPanel(props: dict) -> any {
        isOpen = props.isOpen;
        if isOpen == None {
            isOpen = true;
        }
        onToggle = props.onToggle;
        examples = props.examples or [];
        onSelectExample = props.onSelectExample;
        activeSection = props.activeSection or "examples";
        onSectionChange = props.onSectionChange;
        
        [searchQuery, setSearchQuery] = useState("");
        [expandedCategories, setExpandedCategories] = useState({});
        
        # Filter examples by search
        filteredExamples = examples;
        if searchQuery != "" {
            filteredExamples = examples.filter(lambda ex: dict -> bool {
                return ex["title"].toLowerCase().includes(searchQuery.toLowerCase()) or 
                       ex["category"].toLowerCase().includes(searchQuery.toLowerCase());
            });
        }
        
        # Group examples by category
        categories = {};
        for ex in filteredExamples {
            cat = ex["category"] or "Other";
            if not Object.hasOwn(categories, cat) {
            categories[cat] = [];
            }

            categories[cat] = categories[cat].concat([ex]);
        }
        
        def toggleCategory(cat: str) -> None {
            newExpanded = {**expandedCategories};
            currentValue = true;
            newExpanded[cat] = not currentValue;
            setExpandedCategories(newExpanded);
        }
        
        sections = [
            { "id": "examples", "icon": Code2, "label": "Examples" },
            { "id": "docs", "icon": BookOpen, "label": "Docs" },
            { "id": "help", "icon": HelpCircle, "label": "Help" }
        ];

        
        if not isOpen {
            return (
                <div className="h-full w-10 bg-surface border-l border-border flex flex-col items-center py-2">
                    <button
                        onClick={onToggle}
                        className="p-2 rounded-md text-text-secondary hover:bg-primary/10 transition-all"
                        title="Open panel"
                    >
                        <PanelRightOpen size={18} />
                    </button>
                    
                    <div className="flex-1 flex flex-col items-center gap-1 mt-4">
                        {sections.map(lambda section: dict -> any {
                            Icon = section["icon"];
                            isActive = activeSection == section["id"];
                            
                            return (
                                <button
                                    key={section["id"]}
                                    onClick={lambda -> None { 
                                        onSectionChange(section["id"]); 
                                        onToggle(); 
                                    }}
                                    className={cn(
                                        "p-2 rounded-md transition-all",
                                        isActive and "bg-primary/15 text-primary" or "text-text-secondary hover:bg-primary/10"
                                    )}
                                    title={section["label"]}
                                >
                                    <Icon size={16} />
                                </button>
                            );
                        })}
                    </div>
                </div>
            );
        }
        
        return (
            <div className="h-full w-64 bg-surface border-l border-border flex flex-col">
                <div className="flex items-center justify-between px-3 h-10 border-b border-border">
                    <div className="flex items-center gap-1">
                        {sections.map(lambda section: dict -> any {
                            Icon = section["icon"];
                            isActive = activeSection == section["id"];
                            
                            return (
                                <button
                                    key={section["id"]}
                                    onClick={lambda -> None { onSectionChange(section["id"]); }}
                                    className={cn(
                                        "px-2 py-1 rounded text-xs font-medium transition-all",
                                        isActive and "bg-primary/15 text-primary" or "text-text-secondary hover:bg-background"
                                    )}
                                >
                                    {section["label"]}
                                </button>
                            );
                        })}
                    </div>
                    
                    <button
                        onClick={onToggle}
                        className="p-1 rounded text-text-secondary hover:bg-background transition-all"
                        title="Close panel"
                    >
                        <PanelRightClose size={16} />
                    </button>
                </div>
                
                {activeSection == "examples" and (
                    <div className="flex-1 flex flex-col overflow-hidden">
                        # <div className="p-2 border-b border-border">
                        #     <div className="relative">
                        #         <Search size={14} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-text-secondary" />
                        #         <input
                        #             type="text"
                        #             placeholder="Search examples..."
                        #             value={searchQuery}
                        #             onChange={lambda e: any -> None { setSearchQuery(e.target.value); }}
                        #             className="w-full pl-8 pr-3 py-1.5 text-xs bg-background border border-border rounded-md focus:outline-none focus:ring-1 focus:ring-primary"
                        #         />
                        #     </div>
                        # </div>
                        
                        <div className="flex-1 overflow-y-auto p-2">
                            {Object.keys(categories).map(lambda cat: str -> any {
                                isExpanded = true;
                                categoryExamples = categories[cat];
                                
                                return (
                                    <div key={cat} className="mb-2">
                                        <button
                                            onClick={lambda -> None { toggleCategory(cat); }}
                                            className="flex items-center gap-1 w-full px-2 py-1 text-xs font-medium text-text-secondary hover:text-text-primary transition-colors"
                                        >
                                            {isExpanded and (<ChevronDown size={12} />) or (<ChevronRight size={12} />)}
                                            <span>{cat}</span>
                                            <span className="ml-auto text-[10px] text-text-secondary">{categoryExamples.length}</span>
                                        </button>
                                        
                                        # {isExpanded and categoryExamples.length>0 and
                                        #     (<div className="ml-3 mt-1 space-y-0.5">
                                        #     {categoryExamples.map(lambda ex: dict -> any {
                                        #         return (
                                        #             <button
                                        #                 key={ex["id"]}
                                        #                 onClick={lambda -> None { onSelectExample(ex["id"]); }}
                                        #                 className="flex items-center gap-2 w-full px-2 py-1.5 text-xs text-text-secondary hover:text-text-primary hover:bg-background rounded transition-all"
                                        #             >
                                        #                 <FileCode size={12} />
                                        #                 <span className="truncate">{ex["title"]}</span>
                                        #             </button>
                                        #         );
                                        #     })}
                                        # </div>)}
                                         <div className="ml-3 mt-1 space-y-0.5">
                                                {categoryExamples.map(lambda ex: dict -> any {
                                                    return (
                                                        <button
                                                            key={ex["id"]}
                                                            onClick={lambda -> None { onSelectExample(ex["id"]); }}
                                                            className="flex items-center gap-2 w-full px-2 py-1.5 text-xs text-text-secondary hover:text-text-primary hover:bg-background rounded transition-all"
                                                        >
                                                            <FileCode size={12} />
                                                            <span className="truncate">{ex["title"]}</span>
                                                        </button>
                                                    );
                                                })}
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                )}
                
                {activeSection == "docs" and (
                    <div className="flex-1 overflow-y-auto p-3">
                        <div className="space-y-3">
                            <a 
                                href="https://www.jac-lang.org/docs/" 
                                target="_blank"
                                className="flex items-center gap-2 p-2 text-xs text-text-secondary hover:text-primary hover:bg-primary/5 rounded transition-all"
                            >
                                <BookOpen size={14} />
                                <span>Jac Documentation</span>
                                <ExternalLink size={12} className="ml-auto" />
                            </a>
                            <a 
                                href="https://www.jac-lang.org/docs/learn/jac-lang/" 
                                target="_blank"
                                className="flex items-center gap-2 p-2 text-xs text-text-secondary hover:text-primary hover:bg-primary/5 rounded transition-all"
                            >
                                <FileCode size={14} />
                                <span>Language Guide</span>
                                <ExternalLink size={12} className="ml-auto" />
                            </a>
                        </div>
                    </div>
                )}
                
                {activeSection == "help" and (
                    <div className="flex-1 overflow-y-auto p-3">
                        <div className="text-xs text-text-secondary space-y-3">
                            <div>
                                <h4 className="font-medium text-text-primary mb-1">Keyboard Shortcuts</h4>
                                <div className="space-y-1">
                                    <div className="flex justify-between">
                                        <span>Run code</span>
                                        <kbd className="px-1.5 py-0.5 bg-background rounded text-[10px]">Ctrl+Enter</kbd>
                                    </div>
                                    <div className="flex justify-between">
                                        <span>Save</span>
                                        <kbd className="px-1.5 py-0.5 bg-background rounded text-[10px]">Ctrl+S</kbd>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            
        );
    }
}
