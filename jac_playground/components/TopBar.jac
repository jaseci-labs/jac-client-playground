cl import from "..lib.utils" { cn }
cl import from "lucide-react" { Play, RotateCcw, Moon, HelpCircle }
cl import from ".ui.Button" { Button }
cl import from ".ui.IconButton" { IconButton }
cl import from ".ui.Badge" { Badge }

cl {
    def TopBar(props:dict)->None{
        let onRun = props.onRun;
        let onReset = props.onReset;
        let onToggleTheme = props.onToggleTheme;
        let envReady = props.envReady or false;

        return <header className="w-full flex items-center gap-3 px-4 py-3 bg-panel border-b border-border">
            <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-md bg-primary text-primary-foreground flex items-center justify-center font-bold">
                    J
                </div>
                <div className="text-sm font-semibold text-primary">
                    Jac Playground
                </div>
            </div>
            <div className="flex items-center gap-2 ml-4">
                # <button
                #     onClick={onRun}
                #     className="inline-flex items-center gap-2 px-3 py-2 rounded-lg bg-primary text-primary-foreground text-sm font-semibold shadow-sm hover:bg-primary-600"
                # >
                #     <Play className="w-4 h-4" />
                #     <span>Run</span>
                # </button>

                # <button
                #     onClick={onReset}
                #     className="inline-flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-semibold text-text-primary border border-border"
                # >
                #     <RotateCcw className="w-4 h-4" />
                #     <span>Reset</span>
                # </button>

                # <button
                #     onClick={onToggleTheme}
                #     className="w-9 h-9 rounded-lg flex items-center justify-center border border-border text-primary"
                # >
                #     <Moon className="w-4 h-4" />
                # </button>

                <Button variant="primary" size="sm" onClick={onRun}>
                    <Play className="w-4 h-4" />
                    <span>Run</span>
                </Button>

                <Button variant="outline" size="sm" onClick={onReset}>
                    <RotateCcw className="w-4 h-4" />
                    <span>Reset</span>
                </Button>
                <IconButton
                    icon={<Moon className="w-4 h-4" />}
                    label="Toggle Theme"
                    onClick={onToggleTheme}
                />
            </div>
            <div className="flex-1" />
            <div className="flex items-center gap-3">
                # <div className="px-3 py-1 rounded-lg text-xs font-medium bg-secondary text-secondary-foreground">
                #     Examples
                # </div>
                # <div
                #     className={cn(
                #         "px-3 py-1 rounded-lg text-xs font-medium",
                #         envReady and "bg-primary text-primary-foreground" or "bg-surface text-text-secondary"
                #     )}
                # >
                #     {envReady and "Environment Ready" or "Not Ready"}
                # </div>

                <Badge variant="secondary" size="sm">
                    Examples
                </Badge>
                <Badge
                    variant={envReady and "primary" or "neutral"}
                    size="sm"
                >
                    {envReady and "Environment Ready" or "Not Ready"}
                </Badge>
                # <button className="w-9 h-9 rounded-lg border border-border flex items-center justify-center text-text-primary">
                #     <HelpCircle className="w-4 h-4" />
                # </button>
                <IconButton
                    icon={<HelpCircle className="w-4 h-4" />}
                    label="Help"
                />
            </div>
        </header>;
    }
}