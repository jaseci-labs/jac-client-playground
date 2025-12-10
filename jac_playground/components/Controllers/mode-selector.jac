cl import from "...lib.utils" { cn }
cl import from "..ui.Button" { Button }

cl {
    def ModeSelector(props: dict) -> any {
        let mode = props.mode or "jac";
        let onModeChange = props.onModeChange;
        let className = props.className or "";
        
        let modes = [
            { "id": "jac", "label": "Jac" },
            { "id": "jac2py", "label": "Jac → Py" },
            { "id": "py2jac", "label": "Py → Jac" }
        ];
        
        return (
            <div className={cn(
                "flex items-center bg-surface border border-border rounded-lg overflow-hidden",
                className
            )}>
                {modes.map(lambda m: dict, index:int -> any {
                    let isActive = mode == m["id"];
                    return (
                        <button
                            key={m["id"]}
                            onClick={lambda -> None { onModeChange and onModeChange(m["id"]); }}
                            className={cn(
                                "px-4 py-1.5 text-sm font-medium transition-all min-w-[88px]",
                                isActive and "bg-primary text-primary-foreground" or "hover:text-text-secondary text-text-primary bg-background hover:bg-surface",
                                "border-r border-border" if (index==0 or index==1) else ""
                            )}
                        >
                            {m["label"]}
                        </button>
                    );
                })}
            </div>
        );
    }
}
