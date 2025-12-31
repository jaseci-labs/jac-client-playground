cl import from "monaco-textmate" { Registry }
cl import from "onigasm" { loadWASM }
cl import from "monaco-editor-textmate" { wireTmGrammars }

cl {
    glob ONIG_WASM_PATH = "/static/assets/onigasm.wasm";
    glob LANGUAGE_CONFIG_PATH = "/static/assets/language-configuration.json";
    glob grammarConfig = {
        "jac": "source.jac"
    };

    glob wasmInitialized = false;
    glob languageRegistered = false;
    glob grammarLoaded = false;
    glob cachedGrammarConfig: any = null;

    async def loadSyntax(monaco:any, editor:any) -> any | None {
        if (not languageRegistered) {
            monaco.languages.register({ id: "jac" });
            languageRegistered = true;
        }

        if (not wasmInitialized) {
            try {
                await loadWASM(ONIG_WASM_PATH);
                wasmInitialized = true;
            } except Exception {
                console.error("Failed to load Onigasm WASM:", Exception);
                return;
            }
        }

        if (not grammarLoaded) {
            response = await fetch("https://raw.githubusercontent.com/jaseci-labs/jac-vscode/main/syntaxes/jac.tmLanguage.json");
            grammerConfigRes = await fetch(LANGUAGE_CONFIG_PATH);
            jacGrammer = await response.json();
            cachedGrammarConfig = await grammerConfigRes.json();

            registry = Reflect.construct(Registry, [{
                getGrammarDefinition: lambda -> None {
                    return {
                        format: "json",
                        content: JSON.stringify(jacGrammer)
                    };
                }
            }]);

            grammar = Reflect.construct(Map, []);
            grammar.set("jac", "source.jac");

            await wireTmGrammars(monaco, registry, grammar, editor);
            grammarLoaded = true;
        }
        return cachedGrammarConfig;
    }

    async def configureTheme(monaco:any, grammarConfig:any) -> None {
        monaco.languages.setLanguageConfiguration("jac", grammarConfig);
        monaco.editor.defineTheme("jac-theme", {
            base: "vs",
            inherit: true,
            rules: [
                { token: "storage.type.class.jac", foreground: "569CD6" },
                { token: "storage.type.function.jac", foreground: "569CD6" },
                { token: "keyword.control.flow.jac", foreground: "C678DD" },
                { token: "entity.name.type.class.jac", foreground: "3ac9b0" },
            ],
            colors: {
            },
        });
        monaco.editor.setTheme("jac-theme");
        console.log("Jac language successfully registered");
    }
}
