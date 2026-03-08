"""Bundle JacLang source into a zip for Pyodide.

Creates a minimal jaclang.zip containing only the files needed to compile
and execute Jac code in a browser environment. Includes precompiled .jir
bytecode when available for faster browser loading.

Usage:
    python scripts/bundle_jaclang.py
    python scripts/bundle_jaclang.py /path/to/jaseci/jac
    python scripts/bundle_jaclang.py -o assets/jaclang.zip
    python scripts/bundle_jaclang.py --no-precompile
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

# Directory basenames to exclude
EXCLUDE_DIRS = {"__pycache__", ".pytest_cache", ".git", "tests"}
# File extensions to exclude
EXCLUDE_EXTENSIONS = {".pyc", ".pyo", ".pyi"}
# Subdirectory paths within jaclang to exclude entirely
EXCLUDE_SUBDIRS = {
    os.path.join("compiler", "passes", "native"),
    os.path.join("vendor", "typeshed"),
}

JASECI_REPO_URL = "https://github.com/jaseci-labs/jaseci.git"
JASECI_BRANCH = "main"


def clone_jaseci_repo(dest: str) -> str:
    """Shallow-clone the jaseci repo and return the path to jac/."""
    print(f"Cloning {JASECI_REPO_URL} (branch: {JASECI_BRANCH})...")
    subprocess.run(
        ["git", "clone", "--depth", "1",
         "--branch", JASECI_BRANCH, JASECI_REPO_URL, dest],
        check=True,
    )
    return os.path.join(dest, "jac")


def find_jaclang_dir(source_dir: str) -> str:
    """Find the jaclang package directory within the source."""
    if os.path.isfile(os.path.join(source_dir, "jac0.py")):
        return source_dir

    candidate = os.path.join(source_dir, "jaclang")
    if os.path.isdir(candidate) and os.path.isfile(
        os.path.join(candidate, "jac0.py")
    ):
        return candidate

    print(f"Error: Cannot find jaclang package in '{source_dir}'", file=sys.stderr)
    sys.exit(1)


def find_jac_root(source_dir: str) -> str:
    """Find the jac project root (parent of jaclang/) for precompilation."""
    jaclang_dir = find_jaclang_dir(source_dir)
    return os.path.dirname(jaclang_dir)


def should_exclude(path: str, jaclang_dir: str) -> bool:
    """Check if file/directory should be excluded."""
    if os.path.basename(path) in EXCLUDE_DIRS:
        return True
    if os.path.splitext(path)[1] in EXCLUDE_EXTENSIONS:
        return True
    rel = os.path.relpath(path, jaclang_dir)
    for ex in EXCLUDE_SUBDIRS:
        # Match source paths (e.g. compiler/passes/native)
        if rel == ex or rel.startswith(ex + os.sep):
            return True
        # Match precompiled mirror paths (e.g. _precompiled/cpython-312/compiler/passes/native)
        if os.sep + ex + os.sep in os.sep + rel or rel.endswith(os.sep + ex):
            return True
    return False


def precompile_jaclang(source_dir: str) -> None:
    """Run the jaclang precompilation script to generate .jir bytecode."""
    jac_root = find_jac_root(source_dir)
    script_path = os.path.join(jac_root, "scripts", "precompile_bytecode.jac")

    if not os.path.exists(script_path):
        print(f"  Precompile script not found at {script_path}. Skipping.")
        return

    print("Precompiling jaclang bytecode for playground...")
    try:
        subprocess.run(
            ["jac", "run", "scripts/precompile_bytecode.jac", "."],
            check=True,
            cwd=jac_root,
        )
        print("Precompilation complete.")
    except subprocess.CalledProcessError as e:
        print(f"  WARNING: Precompilation failed: {e}. "
              "Playground will use on-the-fly compilation.")
    except FileNotFoundError:
        print("  WARNING: 'jac' command not found. Skipping precompilation.")


def create_zip(jaclang_dir: str, output_zip: str) -> None:
    """Create a zip file from the jaclang directory with exclusions."""
    files_added = 0
    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(jaclang_dir):
            dirs[:] = [d for d in dirs
                       if not should_exclude(os.path.join(root, d), jaclang_dir)]

            for f in files:
                file_path = os.path.join(root, f)
                if not should_exclude(file_path, jaclang_dir):
                    arcname = os.path.join(
                        "jaclang", os.path.relpath(file_path, jaclang_dir)
                    )
                    zipf.write(file_path, arcname)
                    files_added += 1

    # Verify and report
    with zipfile.ZipFile(output_zip, "r") as zf:
        names = zf.namelist()
        native = [n for n in names if "/passes/native/" in n]
        typeshed = [n for n in names if "/typeshed/" in n]
        pyi_files = [n for n in names if n.endswith(".pyi")]
        jir_files = [n for n in names if n.endswith(".jir")]

        if native or typeshed or pyi_files:
            issues = []
            if native:
                issues.append(f"{len(native)} native codegen files")
            if typeshed:
                issues.append(f"{len(typeshed)} typeshed files")
            if pyi_files:
                issues.append(f"{len(pyi_files)} .pyi stub files")
            print(f"  WARNING: Zip contains unnecessary files: {', '.join(issues)}")
        else:
            print("  Verified: zip is clean (no native/typeshed/pyi files)")

        zip_size = os.path.getsize(output_zip) / 1024 / 1024
        print(f"  Precompiled .jir files: {len(jir_files)}")
        print(f"  Total files: {len(names)}, Size: {zip_size:.1f} MB")


def main() -> None:
    parser = argparse.ArgumentParser(description="Bundle JacLang source for Pyodide")
    parser.add_argument(
        "source_dir", nargs="?", default=None,
        help="Path to JacLang source. If omitted, clones from GitHub.",
    )
    parser.add_argument(
        "-o", "--output",
        default=os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "assets", "jaclang.zip",
        ),
        help="Output zip path (default: jac_playground/assets/jaclang.zip)",
    )
    parser.add_argument(
        "--no-precompile", action="store_true",
        help="Skip precompilation of .jir bytecode",
    )
    args = parser.parse_args()

    clone_dir = None
    if args.source_dir is None:
        clone_dir = tempfile.mkdtemp(prefix="jaseci_clone_")
        source_dir = clone_jaseci_repo(clone_dir)
    else:
        source_dir = args.source_dir

    try:
        jaclang_dir = find_jaclang_dir(source_dir)
        print(f"Found jaclang at: {jaclang_dir}")

        if not args.no_precompile:
            precompile_jaclang(source_dir)
        else:
            print("Skipping precompilation (--no-precompile)")

        os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
        print(f"Creating zip: {args.output}")
        create_zip(jaclang_dir, args.output)

        print("Bundle created successfully.")

    finally:
        if clone_dir is not None:
            shutil.rmtree(clone_dir, ignore_errors=True)


if __name__ == "__main__":
    main()
