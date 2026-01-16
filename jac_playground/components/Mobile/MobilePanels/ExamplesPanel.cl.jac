import from "lucide-react" { Search, FileCode, ChevronRight, X, Eye, Plus }
import from "....lib.utils" { cn }

def: pub ExamplesPanel(props: dict) -> any {
    examples = props.examples or [];
    onSelectExample = props.onSelectExample;
    className = props.className or "";
    
    has searchQuery: str = "";
    has selectedExample: dict | None = None;
    has showPreview: bool = false;
    
    # Filter examples by search
    filteredExamples = examples;
    if searchQuery != "" {
        filteredExamples = examples.filter(lambda ex: dict -> bool {
            return ex["title"].toLowerCase().includes(searchQuery.toLowerCase()) or 
                    ex["category"].toLowerCase().includes(searchQuery.toLowerCase());
        });
    }
    
    # Group by category
    categories = {};
    for ex in filteredExamples {
        cat = ex["category"] or "Other";
        if not Object.hasOwn(categories, cat) {
            categories[cat] = [];
        }
        categories[cat] = categories[cat].concat([ex]);
    }
    
    def handleSelectExample(example: dict) -> None {
        selectedExample = example;
        showPreview = true;
    }
    
    def handleInsert() -> None {
        if selectedExample and onSelectExample {
            onSelectExample(selectedExample["id"]);
        }
        showPreview = false;
        selectedExample = None;
    }
    
    def handleClosePreview() -> None {
        showPreview = false;
        selectedExample = None;
    }
    
    return (
        <div className={cn("h-full flex flex-col bg-background", className)}>
            # <div className="p-3 border-b border-border bg-surface">
            #     <div className="relative">
            #         <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-secondary" />
            #         <input
            #             type="text"
            #             placeholder="Search examples..."
            #             value={searchQuery}
            #             onChange={lambda e: any -> None { searchQuery = e.target.value; }}
            #             className="w-full pl-9 pr-3 py-2.5 text-sm bg-background border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
            #         />
            #     </div>
            # </div>
            
            <div className="flex-1 overflow-auto">
                {Object.keys(categories).map(lambda category: str -> any {
                    categoryExamples = categories[category];
                    
                    return (
                        <div key={category} className="border-b border-border last:border-0">
                            <div className="px-3 py-2 bg-surface-hover">
                                <span className="text-xs font-semibold text-text-secondary uppercase tracking-wider">
                                    {category}
                                </span>
                                <span className="ml-2 text-xs text-text-secondary">
                                    ({categoryExamples.length})
                                </span>
                            </div>
                            
                            {categoryExamples.map(lambda example: dict -> any {
                                return (
                                    <button
                                        key={example["id"]}
                                        onClick={lambda -> None { handleSelectExample(example); }}
                                        className="w-full flex items-center gap-3 px-3 py-3 hover:bg-surface-hover transition-colors text-left"
                                    >
                                        <FileCode className="w-5 h-5 text-primary flex-shrink-0" />
                                        <div className="flex-1 min-w-0">
                                            <p className="text-sm font-medium text-text-primary truncate">
                                                {example["title"]}
                                            </p>
                                        </div>
                                        <ChevronRight className="w-4 h-4 text-text-secondary flex-shrink-0" />
                                    </button>
                                );
                            })}
                        </div>
                    );
                })}
                
                {Object.keys(categories).length == 0 and (
                    <div className="h-full flex items-center justify-center p-6">
                        <p className="text-sm text-text-secondary text-center">
                            No examples found matching {searchQuery}
                        </p>
                    </div>
                )}
            </div>
            
            {showPreview and selectedExample and (
                <div className="fixed inset-0 bg-black/50 z-[100] flex items-end">
                    <div className="w-full bg-surface rounded-t-2xl max-h-[80vh] flex flex-col animate-slide-up">
                        <div className="flex items-center justify-between p-4 border-b border-border">
                            <h3 className="text-base font-semibold text-text-primary">
                                {selectedExample["title"]}
                            </h3>
                            <button
                                onClick={handleClosePreview}
                                className="p-2 rounded-full hover:bg-background transition-colors"
                                aria-label="Close"
                            >
                                <X className="w-5 h-5 text-text-secondary" />
                            </button>
                        </div>
                        
                        <div className="flex-1 overflow-auto p-4">
                            <pre className="text-xs font-mono bg-background p-3 rounded-lg overflow-x-auto whitespace-pre-wrap">
                                {selectedExample["code"]}
                            </pre>
                        </div>
                        
                        <div className="p-4 border-t border-border flex gap-3">
                            <button
                                onClick={handleClosePreview}
                                className="flex-1 py-3 rounded-lg border border-border text-sm font-medium text-text-primary hover:bg-background transition-colors"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleInsert}
                                className="flex-1 py-3 rounded-lg bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90 transition-colors flex items-center justify-center gap-2"
                            >
                                <Plus className="w-4 h-4" />
                                Insert Code
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
