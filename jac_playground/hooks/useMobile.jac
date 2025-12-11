
cl import from react {useState, useEffect}

# Breakpoint constants
# Mobile: <= 767px
# Tablet: 768px - 1023px  
# Desktop: >= 1024px

cl {
    let MOBILE_BREAKPOINT = 768;
    let TABLET_BREAKPOINT = 1024;
    
    def useIsMobile() -> bool {
        let [isMobile, setIsMobile] = useState(false);

        useEffect(lambda -> any {
            def checkMobile() -> None {
                setIsMobile(window.innerWidth < MOBILE_BREAKPOINT);
            }
            
            # Check on mount
            checkMobile();
            
            # Listen for resize
            window.addEventListener("resize", checkMobile);
            
            return lambda -> None {
                window.removeEventListener("resize", checkMobile);
            };
        }, []);

        return isMobile;
    }
    
    def useIsTablet() -> bool {
        let [isTablet, setIsTablet] = useState(false);

        useEffect(lambda -> any {
            def checkTablet() -> None {
                let width = window.innerWidth;
                setIsTablet(width >= MOBILE_BREAKPOINT and width < TABLET_BREAKPOINT);
            }
            
            checkTablet();
            window.addEventListener("resize", checkTablet);
            
            return lambda -> None {
                window.removeEventListener("resize", checkTablet);
            };
        }, []);

        return isTablet;
    }
    
    def useIsDesktop() -> bool {
        let [isDesktop, setIsDesktop] = useState(true);

        useEffect(lambda -> any {
            def checkDesktop() -> None {
                setIsDesktop(window.innerWidth >= TABLET_BREAKPOINT);
            }
            
            checkDesktop();
            window.addEventListener("resize", checkDesktop);
            
            return lambda -> None {
                window.removeEventListener("resize", checkDesktop);
            };
        }, []);

        return isDesktop;
    }
    
    def useBreakpoint() -> str {
        let [breakpoint, setBreakpoint] = useState("desktop");

        useEffect(lambda -> any {
            def checkBreakpoint() -> None {
                let width = window.innerWidth;
                if width < MOBILE_BREAKPOINT {
                    setBreakpoint("mobile");
                } elif width < TABLET_BREAKPOINT {
                    setBreakpoint("tablet");
                } else {
                    setBreakpoint("desktop");
                }
            }
            
            checkBreakpoint();
            window.addEventListener("resize", checkBreakpoint);
            
            return lambda -> None {
                window.removeEventListener("resize", checkBreakpoint);
            };
        }, []);

        return breakpoint;
    }
}