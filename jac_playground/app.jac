import tempfile;
import subprocess;
import sys;
import os;

import from pathlib { Path }
import from jaclang.cli.cli { run }
import from jaclang.runtimelib.builtin { printgraph }

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
        if visitor.mode == "pyrun" {
            file_type = ".py";
        } elif visitor.mode == "jacrun" {
            file_type = ".jac";
        }
        output = self.process_code(visitor.source_code, "run", file_type=file_type);
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
    has mode: str = "jacrun";
    has mode_node_map: dict = {
        "jacrun": RunNode,
        "pyrun": RunNode,
        "jac2py": Jac2PyNode,
        "py2jac": Py2JacNode,
    };

    
    can execute with `root entry {
        if self.mode in self.mode_node_map {
            node_type = self.mode_node_map[self.mode];
            if routed_nodes := [root --> (`?node_type)] {
                visit routed_nodes[0];
            } else {
                routed_node = root ++> node_type();
                visit routed_node;
            }
        }
    }
}

walker load_example_list {
    has example_path: str = "examples";
    has examples_list: list = [];

    def id_to_title(id_str: str) -> str {
        return " ".join(word.capitalize() for word in id_str.replace("_", " ").split());
    }
    can execute with `root entry {
        root_path = Path(self.example_path);
        
        for subfolder in root_path.iterdir() {
            if subfolder.is_dir() {
                for jac_file in subfolder.glob("*.jac") {
                    file_id = jac_file.stem;
                    title = self.id_to_title(file_id);
                    category = jac_file.parent.name;
                    with open(jac_file, "r", encoding="utf-8") as f {
                        code = f.read();
                    }

                    self.examples_list.append({
                        "id": file_id,
                        "title": title,
                        "category": category,
                        "code": code
                    });
                }
            }
        }
        report self.examples_list;
    }
}   

walker load_graph {
    has source_code: str = "";

    can load with `root entry {

        # report "start report";

        # with tempfile.NamedTemporaryFile(suffix=".jac", delete=False) as f {
        #     f.write(self.source_code.encode("utf-8"));
        #     temp_path = f.name;
        # }
        # with open("test_file.jac", "w") as f {
        #     f.write(self.source_code);
        # }
        # temp_path = "test_file.jac";
        # run(temp_path);

        # graph =  printgraph( 
        #     file = temp_path,
        #     format = "json"
        # );
        # os.remove(temp_path);

        import json;

        # Read graph from json file
        with open("graph_output.json", "r") as f {
            graph_data = json.load(f);
        }
        
        print(graph_data);
        report graph_data;

    }
}

