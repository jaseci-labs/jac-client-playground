cl import from "lucide-react" { Sun, Moon }
cl import from "...lib.utils" { cn }


cl {
    def: pub ThemeToggle(props: dict) -> any {
        theme = props.theme or "light";
        onToggle = props.onToggleTheme;
        className = props.className or "";
        
        isDark = theme == "dark";
        
        return (
            <button
                onClick={onToggle}
                className={cn(
                    "p-2 rounded-lg transition-all duration-200",
                    "text-text-secondary hover:text-text-primary hover:bg-surface-hover",
                    className
                )}
                aria-label={isDark and "Switch to light mode" or "Switch to dark mode"}
                title={isDark and "Switch to light mode" or "Switch to dark mode"}
            >
                {isDark and (<Sun className="w-5 h-5" />)}
                {(not isDark) and (<Moon className="w-5 h-5" />)}
            </button>
        );
    }
}
