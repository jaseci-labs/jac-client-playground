cl import from "..lib.utils" { cn }
cl import from "lucide-react" { Search, Settings, User, HelpCircle, Github }
cl import from ".ui.Badge" { Badge }

cl {
    def TopBar(props:dict) -> any {
        let envReady = props.envReady or true;
        let onOpenSettings = props.onOpenSettings;
        let onOpenHelp = props.onOpenHelp;

        return (
            <header className="w-full h-12 flex items-center gap-4 px-4 bg-surface border-b border-border justify-between">
                <div className="flex items-center gap-2">
                    <img src="/static/assets/jaseci.png" className="w-7 h-7" />
                    <span className="text-sm font-semibold text-text-primary">
                        Jac Playground
                    </span>
                </div>
                
                # <div className="flex-1 flex items-center justify-center max-w-md mx-auto">
                #     <div className="relative w-full">
                #         <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-text-secondary" />
                #         <input
                #             type="text"
                #             placeholder="Search commands, examples..."
                #             className="w-full pl-9 pr-3 py-1.5 text-xs bg-background border border-border rounded-md focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-text-secondary"
                #         />
                #         <kbd className="absolute right-2 top-1/2 -translate-y-1/2 px-1.5 py-0.5 text-[10px] bg-surface border border-border rounded text-text-secondary">
                #             ⌘K
                #         </kbd>
                #     </div>
                # </div>
                
                <div className="flex items-center gap-2">
                    <Badge
                        variant={envReady and "primary" or "neutral"}
                        size="sm"
                    >
                        {envReady and "Ready" or "Loading..."}
                    </Badge>
                    
                    <div className="w-px h-5 bg-border mx-1" />
                    
                    <a 
                        href="https://github.com/Jaseci-Labs/jaclang" 
                        target="_blank"
                        className="p-1.5 text-text-secondary hover:text-text-primary hover:bg-background rounded transition-colors"
                        title="GitHub"
                    >
                        <Github size={16} />
                    </a>
                    
                    <button
                        onClick={onOpenHelp}
                        className="p-1.5 text-text-secondary hover:text-text-primary hover:bg-background rounded transition-colors"
                        title="Help"
                    >
                        <HelpCircle size={16} />
                    </button>
                    
                    <button
                        onClick={onOpenSettings}
                        className="p-1.5 text-text-secondary hover:text-text-primary hover:bg-background rounded transition-colors"
                        title="Settings"
                    >
                        <Settings size={16} />
                    </button>
                </div>
            </header>
        );
    }
}