cl import from "..lib.utils" { cn }
cl import from "lucide-react" { HelpCircle }
cl import from ".ui.IconButton" { IconButton }
cl import from ".ui.Badge" { Badge }
cl import from ".Controllers.mode-selector" { ModeSelector }

cl {
    def TopBar(props:dict) -> any {
        let envReady = props.envReady or true;
        let mode = props.mode or "jac";
        let onModeChange = props.onModeChange;

        return <header className="w-full flex items-center gap-4 px-4 py-3 bg-background border-b border-border">
            <div className="flex items-center gap-3">
                <img src="/static/assets/jaseci.png" className="w-8 h-8 mr-2" />
                <div className="text-sm font-semibold text-text-primary">
                    Jac Playground
                </div>
            </div>
            
            <div className="flex-1 flex items-center justify-center">
                <ModeSelector 
                    mode={mode} 
                    onModeChange={onModeChange} 
                />
            </div>
            
            <div className="flex items-center gap-3 w-[26.25rem] justify-end">
                <Badge
                    variant={envReady and "primary" or "neutral"}
                    size="sm"
                >
                    {envReady and "Ready" or "Not Ready"}
                </Badge>
                <HelpCircle className="w-4 h-4" />
            </div>
        </header>;
    }
}