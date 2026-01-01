cl import from "..hooks.useMobile" { useIsMobile }
cl import from "..hooks.usePlayground" { usePlayground }

cl import from ".Layout.DesktopLayout" { DesktopLayout }
cl import from ".Mobile.MobileLayout" { MobileLayout }

cl {

    def: pub PlayGroundLayout(props: dict) -> any {
        # Single source of truth - ALL logic in one hook
        playground = usePlayground(props);
        
        # Check if mobile viewport
        isMobile = useIsMobile();
        
        # Render appropriate layout based on viewport
        if isMobile {
            return (
                <MobileLayout
                    theme={playground.theme}
                    editorTheme={playground.editorTheme}
                    onToggleTheme={playground.onToggleTheme}
                    mode={playground.mode}
                    onModeChange={playground.onModeChange}
                    jacCode={playground.jacCode}
                    pythonCode={playground.pythonCode}
                    outputCode={playground.outputCode}
                    codeValue={playground.codeValue}
                    onJacCodeChange={playground.onJacCodeChange}
                    onPythonCodeChange={playground.onPythonCodeChange}
                    output={playground.output}
                    errors={playground.errors}
                    logs={playground.logs}
                    onClearOutput={playground.onClearOutput}
                    onClearErrors={playground.onClearErrors}
                    onClearLogs={playground.onClearLogs}
                    graphData={playground.graphData}
                    examples={playground.examples}
                    onSelectExample={playground.onSelectExample}
                    onRun={playground.onRun}
                    onConvert={playground.onConvert}
                    onReset={playground.onReset}
                    onDebug={playground.onDebug}
                    isRunning={playground.isRunning}
                    isConverting={playground.isConverting}
                    isDebugging={playground.isDebugging}
                    envReady={playground.envReady}
                    activePanel={playground.activePanel}
                    onPanelChange={playground.onPanelChange}
                    problemsBadge={playground.problemsBadge}
                    onNavigateToCode={playground.onNavigateToCode}
                    onNavigateToOutput={playground.onNavigateToOutput}
                />
            );
        }
        
        # Desktop layout
        return (
            <DesktopLayout
                theme={playground.theme}
                editorTheme={playground.editorTheme}
                onToggleTheme={playground.onToggleTheme}
                mode={playground.mode}
                onModeChange={playground.onModeChange}

                jacCode={playground.jacCode}
                pythonCode={playground.pythonCode}
                outputCode={playground.outputCode}
                onJacCodeChange={playground.onJacCodeChange}
                onPythonCodeChange={playground.onPythonCodeChange}
                output={playground.output}
                errors={playground.errors}
                logs={playground.logs}
                onClearOutput={playground.onClearOutput}
                onClearErrors={playground.onClearErrors}
                onClearLogs={playground.onClearLogs}
                graphData={playground.graphData}
                examples={playground.examples}
                onSelectExample={playground.onSelectExample}
                onRun={playground.onRun}
                onConvert={playground.onConvert}
                onReset={playground.onReset}
                onDebug={playground.onDebug}
                isRunning={playground.isRunning}
                isConverting={playground.isConverting}
                isDebugging={playground.isDebugging}
                onhandleDebugAction={playground.onhandleDebugAction}
                envReady={playground.envReady}
                activityBarCollapsed={playground.activityBarCollapsed}
                onToggleActivityBar={playground.onToggleActivityBar}
                rightPanelOpen={playground.rightPanelOpen}
                onToggleRightPanel={playground.onToggleRightPanel}
                rightPanelSection={playground.rightPanelSection}
                onRightPanelSectionChange={playground.onRightPanelSectionChange}
                consoleOpen={playground.consoleOpen}
                onToggleConsole={playground.onToggleConsole}
                consoleHeight={playground.consoleHeight}
                onConsoleHeightChange={playground.onConsoleHeightChange}
                onBreakpointsChange={playground.onBreakpointsChange}

                editorRef={playground.editorRef}
            />
        );
    }
}