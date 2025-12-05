cl import from .button { Button }
cl import from react { useState, useEffect }

cl {
    def ModeSelector(props: dict) -> any {
        let modes = [
            { "key": "debug", "label": "Run", "description": "Execute Jac code with debug visualization" },
            { "key": "jac2py", "label": "Jac2Py", "description": "Convert Jac to Python" },
            { "key": "py2jac", "label": "Py2Jac", "description": "Convert Python to Jac" }
        ];
        
        return (
            <div className="flex items-center gap-1 bg-muted/50 p-1 rounded-lg">
                {
                    modes.map(lambda mode: any -> None {
                        return (
                            <Button
                                key={mode["key"]}
                                size="sm"
                                onClick={lambda e: any -> None { props.onModeChange(mode["key"]); }}
                            >
                                {mode["label"]}
                            </Button>
                        );
                    })
                }
            </div>
        );
    }
}      