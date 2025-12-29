cl import from "...lib.utils" { cn }
cl import from "lucide-react" { Play, Copy, Check, Code2, FileCode, FileOutput }
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
        let icon = props.icon;
        
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
        
        # Determine icon based on title if not provided
        def getIcon() -> any {
            if icon {
                return icon;
            }
            if title.includes("Input") {
                return (<FileCode className="w-4 h-4 text-primary" />);
            }
            if title.includes("Output") {
                return (<FileOutput className="w-4 h-4 text-primary" />);
            }
            return (<Code2 className="w-4 h-4 text-primary" />);
        }
        
        return (
            <div className={cn(
                "flex flex-col h-full bg-surface border border-border rounded-lg overflow-hidden",
                className
            )}>
                <div className={cn(
                    "h-9 px-3 flex items-center justify-between border-b border-border bg-surface-hover",
                    headerClassName
                )}>
                    <div className="flex items-center gap-2">
                        {getIcon()}
                        <span className="text-xs font-medium text-text-primary">{title}</span>
                    </div>
                    
                    <div className="flex items-center gap-1">
                        {props.showActions and (
                            <>
                                <button
                                    onClick={lambda -> None { onRun(props.title); }}
                                    className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                    title="Run Code"
                                >
                                    <Play className="w-3.5 h-3.5" />
                                </button>
                                <button
                                    onClick={handleCopy}
                                    className="p-1.5 hover:bg-surface rounded text-text-secondary hover:text-text-primary transition-colors"
                                    title={copied and "Copied!" or "Copy Code"}
                                >
                                    {copied and (<Check className="w-3.5 h-3.5 text-success" />)}
                                    {(not copied) and (<Copy className="w-3.5 h-3.5" />)}
                                </button>
                            </>
                        )}
                        
                        {(not props.showActions) and subtitle and (
                            <span className="text-xs text-text-secondary">{subtitle}</span>
                        )}
                    </div>
                </div>
                <div className="flex-1 overflow-auto">
                    {children}
                </div>
            </div>
        );
    }
}
