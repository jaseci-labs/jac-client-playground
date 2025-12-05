
cl import from react {useState, useEffect}

cl {
    def useIsMobile() -> bool {
        let MOBILE_BREAKPOINT = 768;
        let [isMobile, setIsMobile] = useState(None);

        useEffect(lambda -> None {
            let mql = window.matchMedia(f"(max-width: {MOBILE_BREAKPOINT - 1}px)");
            console.log(f"(max-width: {MOBILE_BREAKPOINT - 1}px)", window.innerWidth);
            let onChange =lambda -> None {
                setIsMobile(window.innerWidth < MOBILE_BREAKPOINT);
            };
            mql.addEventListener("change", onChange);
            setIsMobile(window.innerWidth < MOBILE_BREAKPOINT);
            return mql.removeEventListener("change", onChange);
        }, []);

        return isMobile;
    }
}