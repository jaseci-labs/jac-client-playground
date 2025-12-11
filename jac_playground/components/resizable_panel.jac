cl import from "..lib.utils" { cn }
cl import from react { useState, useRef, useCallback, useEffect }
cl import from "lucide-react" { GripVertical, GripHorizontal }

cl {
    def ResizablePanel(props: dict) -> any {
        let initialSize = props.initialSize or 25;
        let [size, setSize] = useState(initialSize);
        let isDragging = useRef(false);
        let containerRef = useRef(null);
        
        let isHorizontal = props.isHorizontal or false;
        let minSize = props.minSize or 10;
        let maxSize = props.maxSize or 90;
        let className = props.className or "";
        
        let sizeStyle = isHorizontal and { "height": f"{size}%" } or { "width": f"{size}%" };
        let resizerClassName = isHorizontal and "horizontal-resizer" or "vertical-resizer";

        let handleMouseDown = useCallback(lambda e: any -> None {
            e.preventDefault();
            e.stopPropagation();
            isDragging.current = true;
            document.body.style.cursor = (not isHorizontal) and "col-resize" or "row-resize";
            document.body.style.userSelect = "none";
        }, [isHorizontal]);

        let onMouseMove = useCallback(lambda e: any -> None {
            if not isDragging.current {
                return {};
            }
            
            let container = containerRef.current?.parentElement;
            if not container {
                return {};
            }
            
            let containerRect = container.getBoundingClientRect();
            let newSize = 0;
            
            if isHorizontal {
                # For horizontal (height): calculate from bottom of container
                # Panel is at bottom, so size = distance from cursor to bottom / total height
                let distanceFromBottom = containerRect.bottom - e.clientY;
                newSize = (distanceFromBottom / containerRect.height) * 100;
            } else {
                # For vertical (width): calculate from left of container
                let distanceFromLeft = e.clientX - containerRect.left;
                newSize = (distanceFromLeft / containerRect.width) * 100;
            }
            
            # Clamp to min/max
            newSize = Math.max(minSize, Math.min(maxSize, newSize));
            setSize(newSize);
        }, [isHorizontal, minSize, maxSize]);

        let onMouseUp = useCallback(lambda e: any -> None {
            isDragging.current = false;
            document.body.style.cursor = "";
            document.body.style.userSelect = "";
        }, []);

        # Setup global event listeners
        useEffect(lambda -> any {
            document.addEventListener("mousemove", onMouseMove);
            document.addEventListener("mouseup", onMouseUp);
            
            return lambda -> None {
                document.removeEventListener("mousemove", onMouseMove);
                document.removeEventListener("mouseup", onMouseUp);
            };
        }, [onMouseMove, onMouseUp]);

        # Resizer position: 
        # - Vertical (width): resizer on the RIGHT edge
        # - Horizontal (height): resizer on the TOP edge (for bottom panels like output console)
        let resizerPositionClass = (not isHorizontal) and "w-1 h-full right-0 top-0" or "h-0 w-full top-0 left-0";
        
        return (
            <div ref={containerRef} className={cn("relative flex flex-col", className)} style={sizeStyle}>
                <div
                    className={cn(
                        "absolute flex items-center justify-center z-10",
                        "bg-border hover:bg-primary transition-colors",
                        (not isHorizontal) and "cursor-col-resize" or "cursor-row-resize",
                        resizerPositionClass,
                        resizerClassName
                    )}
                    onMouseDown={handleMouseDown}
                >
                    {(not isHorizontal) and (<GripVertical className="w-3 h-3 text-text-secondary bg-background" />)}
                    {isHorizontal and (<GripHorizontal className="w-3 h-3 text-text-secondary bg-background" />)}
                </div>
                <div className="flex-1 overflow-auto pt-2">
                    {props.children}
                </div>
            </div>
        );
    }
}