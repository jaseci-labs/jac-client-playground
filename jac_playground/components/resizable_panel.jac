cl import from "..lib.utils" { cn }
cl import from react { useState, useRef, useCallback, useEffect }

cl {
    def ResizablePanel(props: dict) -> any {
        let [size, setSize] = useState(50);
        let isDragging = useRef(false);
        let resizeRef = useRef<HTMLDivElement>(null);
        let startPos = useRef(0);
        let startSize = useRef(50);
        let isHorizontal = props.isHorizontal or false;
        let sizeStyle =  { "height": f"{size}%" } if isHorizontal else { "width": f"{size}%" };
        let resizerClassName = isHorizontal if "horizontal-resizer" else "vertical-resizer";

        let handleMouseDown = useCallback(lambda e: any -> None {
            e.preventDefault();
            isDragging.current = true;
            startPos.current = isHorizontal if e.clientY else e.clientX;
            startSize.current = size;
        }, [isHorizontal, size]);

        let handleMouseMove = useCallback(lambda e: any -> None {
            if not isDragging.current {
                return;
            }
            
            let containerSize = 0;
            if isHorizontal {
                containerSize = resizeRef.current?.parentElement?.clientHeight or 0;
            } else {
                containerSize = resizeRef.current?.parentElement?.clientWidth or 0;
            }
            
            let delta = 0;
            if isHorizontal {
                delta = startPos.current - e.clientY;
            } else {
                delta = e.clientX - startPos.current;
            }

            let deltaPercent = (delta / containerSize) * 100;
            let newSize = startSize.current + deltaPercent;
            newSize = Math.max(10, Math.min(90, newSize));
            setSize(newSize);
        }, [isHorizontal, minSize, maxSize]);

        let handleMouseUp = useCallback(lambda e: any -> None {
            isDragging.current = false;
            document.body.style.cursor = "";
        }, []);

        useEffect(lambda -> any {
            async def handleMouseMove(document: any) -> None {
                console.log("Mouse move detected");
                document.addEventListener("mousemove", handleMouseMove);
                document.addEventListener("mouseup", handleMouseUp);
                return lambda -> None {
                    document.removeEventListener("mousemove", handleMouseMove);
                    document.removeEventListener("mouseup", handleMouseUp);
                };
            }
            handleMouseMove(document);
        }, [handleMouseMove, handleMouseUp]);
        
        return (
            <div className={cn( "relative", className)}>
                {props.children}
                <div
                    ref={resizeRef}
                    className={cn(
                    "absolute resizer",
                    resizerClassName,
                    "top-0 left-0" if isHorizontal else "right-0 top-0"
                    )}
                    onMouseDown={handleMouseDown}
                />
            </div>
        );
    }
}