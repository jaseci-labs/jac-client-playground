import from pathlib { Path }

walker: pub load_example_list {
    has example_path: str = "examples";
    has examples_list: list = [];

    def id_to_title(id_str: str) -> str {
        return " ".join(word.capitalize() for word in id_str.replace("_", " ").split());
    }
    can execute with Root entry {
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
