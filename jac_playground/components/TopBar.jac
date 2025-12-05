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
        let mode = props.mode or "jac2py";
        let onModeChange = props.onModeChange;

        return <header className="w-full flex items-center gap-3 px-4 py-3 bg-background border-b border-border">
            <div className="flex items-center gap-3">
                <div className="w-9 h-9 rounded-md bg-primary text-primary-foreground flex items-center justify-center font-bold">
                    J
                </div>
                <div className="text-sm font-semibold text-primary">
                    Jac Playground
                </div>
            </div>
            <div className="flex items-center gap-2 ml-4">
                

                <Button variant="primary" size="sm" onClick={onRun}>
                    <Play className="w-4 h-4" />
                    <span>Run</span>
                </Button>

                <Button variant="outline" size="sm" onClick={onReset}>
                    <RotateCcw className="w-4 h-4" />
                    <span>Reset</span>
                </Button>

                <div className="flex items-center border border-border rounded-md overflow-hidden">
                <Button
                        variant={props.mode == "run" and "primary" or "ghost"}
                        size="sm"
                        onClick={lambda -> None {props.onModeChange and props.onModeChange("run");}}
                        className="rounded-none border-0"
                    >
                        Run
                    </Button>
                    <Button
                        variant={props.mode == "jac2py" and "primary" or "ghost"}
                        size="sm"
                        onClick={lambda -> None {props.onModeChange and props.onModeChange("jac2py");}}
                        className="rounded-none border-0"
                    >
                        jac2py
                    </Button>
                    <Button
                        variant={props.mode == "py2jac" and "primary" or "ghost"}
                        size="sm"
                        onClick={lambda -> None {props.onModeChange and props.onModeChange("py2jac");}}
                        className="rounded-none border-0 border-l border-border"
                    >
                        py2jac
                    </Button>
                </div>
                <IconButton
                    icon={<Moon className="w-4 h-4" />}
                    label="Toggle Theme"
                    onClick={onToggleTheme}
                />
            </div>
            <div className="flex-1" />
            <div className="flex items-center gap-3">
               
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