import from react { useEffect }

# Breakpoint constants
# Mobile: <= 767px
# Tablet: 768px - 1023px  
# Desktop: >= 1024px

glob MOBILE_BREAKPOINT = 768;
glob TABLET_BREAKPOINT = 1024;

def: pub useIsMobile() -> bool {
    has isMobile: bool = false;

    useEffect(lambda -> any {
        def checkMobile() -> None {
            isMobile = window.innerWidth < MOBILE_BREAKPOINT;
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

def: pub useIsTablet() -> bool {
    has isTablet: bool = false;

    useEffect(lambda -> any {
        def checkTablet() -> None {
            width = window.innerWidth;
            isTablet = width >= MOBILE_BREAKPOINT and width < TABLET_BREAKPOINT;
        }
        
        checkTablet();
        window.addEventListener("resize", checkTablet);
        
        return lambda -> None {
            window.removeEventListener("resize", checkTablet);
        };
    }, []);

    return isTablet;
}

def: pub useIsDesktop() -> bool {
    has isDesktop: bool = true;

    useEffect(lambda -> any {
        def checkDesktop() -> None {
            isDesktop = window.innerWidth >= TABLET_BREAKPOINT;
        }
        
        checkDesktop();
        window.addEventListener("resize", checkDesktop);
        
        return lambda -> None {
            window.removeEventListener("resize", checkDesktop);
        };
    }, []);

    return isDesktop;
}

def: pub useBreakpoint() -> str {
    has breakpoint: str = "desktop";

    useEffect(lambda -> any {
        def checkBreakpoint() -> None {
            width = window.innerWidth;
            if width < MOBILE_BREAKPOINT {
                breakpoint = "mobile";
            } elif width < TABLET_BREAKPOINT {
                breakpoint = "tablet";
            } else {
                breakpoint = "desktop";
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
