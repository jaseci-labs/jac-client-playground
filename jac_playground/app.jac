import tempfile;
import subprocess;
import sys;

node ProcessNode {
    def process_code(source_code: str, mode: str, file_type: str) -> str {
        with tempfile.NamedTemporaryFile(mode="w", suffix=file_type, delete=False) as temp_file {
            temp_file.write(source_code);
            temp_file.flush();
            temp_path = temp_file.name;
        }
            
        try {
            result = subprocess.run(
                ["jac", mode, temp_path],
                capture_output=True,
                text=True,
                timeout=30
            );
            output = result.stdout;
            error = result.stderr;
        } except subprocess.TimeoutExpired {
            error = "Execution timed out";
        } except Exception as err {
            error = str(err);
        }
        
        if error != "" {
            output = error;
        }
        return output;
    }
}

node RunNode(ProcessNode) {
    can execute with code_processor entry {
        print("[run] Executing Jac code...");
        output = self.process_code(visitor.source_code, "run", ".jac");
        report output;
    }
}

node Jac2PyNode(ProcessNode) {
    can execute with code_processor entry {
        print("[jac2py] Converting Jac to Python...");
        output = self.process_code(visitor.source_code, "jac2py", ".jac");
        report output;
    }
}

node Py2JacNode(ProcessNode) {
    can execute with code_processor entry {
        print("[py2jac] Converting Python to Jac...");
        output = self.process_code(visitor.source_code, "py2jac", ".py");
        report output;
    }
}

walker code_processor {
    has source_code: str = "";
    has mode: str = "run";
    has mode_node_map: dict = {
        "run": RunNode,
        "jac2py": Jac2PyNode,
        "py2jac": Py2JacNode
    };

    obj __specs__ {
        static has auth: bool = False;
    }
    can execute with `root entry {
        if self.mode in self.mode_node_map {
            node_type = self.mode_node_map[self.mode];
            if [root --> (`?node_type)] {
                visit node_type;
            } else {
                routed_node = root ++> node_type();
                visit routed_node;
            }
        }
    }
}

# with entry {
#     code_processor(
#         source_code="with entry { print('Hello, Jac!'); }",
#         mode="run"
#     ) spawn root;

#     code_processor(
#         source_code="print('Hello, Jac!'",
#         mode="py2jac"
#     ) spawn root;

#     code_processor(
#         source_code="with entry { print('Hello, Jac!'); }",
#         mode="jac2py"
#     ) spawn root;
# }