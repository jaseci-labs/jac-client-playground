import tempfile;
import subprocess;
import sys;

walker run_jac_code {
    has source_code: str = "";
    has output: str = "";
    has error: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }
    can execute with `root entry {
        with tempfile.NamedTemporaryFile(mode="w", suffix=".jac", delete=False) as temp_jac {
            temp_jac.write(self.source_code);
            temp_jac.flush();
            temp_jac_path = temp_jac.name;
        }
        
        try {
            result = subprocess.run(
                ["jac", "run", temp_jac_path],
                capture_output=True,
                text=True,
                timeout=30
            );
            self.output = result.stdout;
            self.error = result.stderr;
        } except subprocess.TimeoutExpired {
            self.error = "Execution timed out";
        } except Exception as err {
            self.error = str(err);
        }
        
        if self.error != "" {
            self.output = self.error;
        }
        report self.output;
    }
}



