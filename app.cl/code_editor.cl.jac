import from "@monaco-editor/react" { Editor }

def CodeEditor(props: dict) -> any {
    return (
        <div className="h-full w-full">
            <Editor
                height="100%"
                width="100%"
                defaultLanguage="python"
                defaultValue="// Write your Jac code here"
                onChange={props.onChange}
                theme="vs-dark"
                options={{
                    "fontSize": 14,
                    "minimap": {"enabled": False},
                    "scrollBeyondLastLine": False,
                    "automaticLayout": True
                }}
            />
        </div>
    );
}