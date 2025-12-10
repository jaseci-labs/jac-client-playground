cl import from "...lib.utils" { cn }
cl import from "lucide-react" { Play, Copy, Check }
cl import from react { useState }

cl {
    def Panel(props: dict) -> any {
        let title = props.title or "";
        let subtitle = props.subtitle or "";
        let className = props.className or "";
        let headerClassName = props.headerClassName or "";
        let children = props.children;
        let onRun = props.onRun;
        
        let onCopy = props.onCopy;
        let codeValue = props.codeValue or "";
        
        let [copied, setCopied] = useState(false);
        
        def handleCopy() -> None {
            if codeValue {
                navigator.clipboard.writeText(codeValue);
                setCopied(true);
                setTimeout(lambda -> None { setCopied(false); }, 2000);
            }
            if onCopy {
                onCopy();
            }
        }
        
        return (
            <div className={cn(
                "flex flex-col h-full bg-surface border border-border rounded-md overflow-hidden",
                className
            )}>
                <div className={cn(
                    "flex items-center gap-2 px-3 py-2 border-b border-border bg-background",
                    headerClassName
                )}>
                    <div className="text-xs font-medium text-text-primary">{title}</div>
                    <div className="flex-1" />
                    
                    {props.showActions and (
                        <div className="flex items-center gap-1">
                             <button
                                onClick={onRun}
                                className="p-1.5 rounded hover:bg-primary/10 text-text-secondary hover:text-primary transition-colors"
                                title="Run Code"
                                >
                                    <Play className="w-3.5 h-3.5" />
                            </button>
                            <button
                                onClick={handleCopy}
                                className="p-1.5 rounded hover:bg-primary/10 text-text-secondary hover:text-primary transition-colors"
                                title={copied and "Copied!" or "Copy Code"}
                            >
                                {copied and <Check className="w-3.5 h-3.5 text-success" />}
                                {(not copied) and <Copy className="w-3.5 h-3.5" />}
                            </button>
                        </div>
                    )}
                    
                    {(not props.showActions) and subtitle and (
                        <div className="text-xs text-text-secondary">{subtitle}</div>
                    )}
                </div>
                <div className="flex-1 overflow-auto">
                    {children}
                </div>
            </div>
        );
    }
}
