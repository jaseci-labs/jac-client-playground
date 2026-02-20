"""Bundle JacLang source into a zip for Pyodide.

Creates a minimal jaclang.zip containing only the files needed to compile
and execute Jac code in a browser environment.

Usage:
    python scripts/bundle_jaclang.py
    python scripts/bundle_jaclang.py /path/to/jaseci/jac
    python scripts/bundle_jaclang.py -o jac_playground/assets/jaclang.zip
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

EXCLUDE_DIRS = {"__pycache__", ".pytest_cache", "tests", "_precompiled"}
EXCLUDE_JACLANG_SUBDIRS = {
    os.path.join("compiler", "passes", "native"),
    os.path.join("vendor", "typeshed"),
}
EXCLUDE_EXTENSIONS = {".pyc", ".pyo"}

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


def should_exclude(path: str, jaclang_dir: str) -> bool:
    """Check if a path should be excluded from the bundle."""
    if os.path.basename(path) in EXCLUDE_DIRS:
        return True
    if os.path.splitext(path)[1] in EXCLUDE_EXTENSIONS:
        return True
    rel = os.path.relpath(path, jaclang_dir)
    return any(
        rel == ex or rel.startswith(ex + os.sep)
        for ex in EXCLUDE_JACLANG_SUBDIRS
    )


def patch_compiler_jac(content: str) -> str:
    """Remove native pass imports from compiler.jac."""
    lines = content.split("\n")
    patched = []
    skip_next = False
    for line in lines:
        stripped = line.strip()
        if "jaclang.compiler.passes.native" in stripped:
            skip_next = True
            continue
        if skip_next and "NaIRGenPass" in stripped:
            skip_next = False
            continue
        skip_next = False
        patched.append(line)
    return "\n".join(patched)


def patch_init_py(content: str) -> str:
    """Wrap setuptools entrypoint loading in try/except for Pyodide."""
    old = "    plugin_manager.load_setuptools_entrypoints(\"jac\")"
    new = (
        "    try:\n"
        "        plugin_manager.load_setuptools_entrypoints(\"jac\")\n"
        "    except Exception:\n"
        "        pass"
    )
    if new in content:
        return content
    return content.replace(old, new)


def fetch_lark_source(dest_vendor_dir: str) -> None:
    """Download lark source when the vendored copy only has .pyc bytecodes."""
    lark_dir = os.path.join(dest_vendor_dir, "lark")
    if os.path.isdir(lark_dir):
        if any(f.endswith(".py") for f in os.listdir(lark_dir)):
            return

    print("  Downloading lark source (vendored copy is bytecode-only)...")
    with tempfile.TemporaryDirectory() as pip_tmp:
        for pip_cmd in [[sys.executable, "-m", "pip"], ["pip3"], ["pip"]]:
            try:
                subprocess.run(
                    pip_cmd + ["install", "lark==1.2.2",
                               "--target", pip_tmp,
                               "--no-deps", "--no-cache-dir", "--quiet"],
                    check=True, capture_output=True,
                )
                break
            except (subprocess.CalledProcessError, FileNotFoundError):
                continue
        else:
            print("  WARNING: Could not install lark via pip", file=sys.stderr)
            return

        src_lark = os.path.join(pip_tmp, "lark")
        if os.path.isdir(src_lark):
            if os.path.isdir(lark_dir):
                shutil.rmtree(lark_dir)
            shutil.copytree(
                src_lark, lark_dir,
                ignore=shutil.ignore_patterns("__pycache__", "*.pyc"),
            )
            print(f"  Lark source installed ({len(os.listdir(lark_dir))} files)")
        else:
            print("  WARNING: Failed to download lark source", file=sys.stderr)


def copy_jaclang_tree(jaclang_dir: str, dest_dir: str) -> None:
    """Copy the jaclang package tree, applying exclusions and patches."""
    dest_jaclang = os.path.join(dest_dir, "jaclang")

    for root, dirs, files in os.walk(jaclang_dir):
        dirs[:] = [d for d in dirs
                   if not should_exclude(os.path.join(root, d), jaclang_dir)]

        rel_root = os.path.relpath(root, jaclang_dir)
        dest_root = dest_jaclang if rel_root == "." else os.path.join(dest_jaclang, rel_root)
        os.makedirs(dest_root, exist_ok=True)

        for f in files:
            src_file = os.path.join(root, f)
            if should_exclude(src_file, jaclang_dir):
                continue

            dest_file = os.path.join(dest_root, f)
            rel_file = os.path.relpath(src_file, jaclang_dir)

            if rel_file == os.path.join("jac0core", "compiler.jac"):
                with open(src_file, "r", encoding="utf-8") as fh:
                    content = patch_compiler_jac(fh.read())
                with open(dest_file, "w", encoding="utf-8") as fh:
                    fh.write(content)
            elif rel_file == "__init__.py":
                with open(src_file, "r", encoding="utf-8") as fh:
                    content = patch_init_py(fh.read())
                with open(dest_file, "w", encoding="utf-8") as fh:
                    fh.write(content)
            else:
                shutil.copy2(src_file, dest_file)


def create_zip(source_dir: str, output_zip: str) -> None:
    """Create a zip file from the prepared directory."""
    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, _, files in os.walk(source_dir):
            for f in files:
                file_path = os.path.join(root, f)
                zf.write(file_path, os.path.relpath(file_path, source_dir))


def main() -> None:
    parser = argparse.ArgumentParser(description="Bundle JacLang source for Pyodide")
    parser.add_argument(
        "source_dir", nargs="?", default=None,
        help="Path to JacLang source. If omitted, clones from GitHub.",
    )
    parser.add_argument(
        "-o", "--output", default="jac_playground/assets/jaclang.zip",
        help="Output zip path (default: jac_playground/assets/jaclang.zip)",
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

        with tempfile.TemporaryDirectory() as tmpdir:
            print("Copying and patching files...")
            copy_jaclang_tree(jaclang_dir, tmpdir)
            fetch_lark_source(os.path.join(tmpdir, "jaclang", "vendor"))

            os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
            print(f"Creating zip: {args.output}")
            create_zip(tmpdir, args.output)

        zip_size = os.path.getsize(args.output)
        print(f"Bundle created: {args.output} ({zip_size / 1024 / 1024:.1f} MB)")

        with zipfile.ZipFile(args.output, "r") as zf:
            names = zf.namelist()
            native = [n for n in names if "/native/" in n]
            typeshed = [n for n in names if "/typeshed/" in n]
            if native:
                print(f"WARNING: {len(native)} native files found in zip!")
            if typeshed:
                print(f"WARNING: {len(typeshed)} typeshed files found in zip!")
            if not native and not typeshed:
                print("Verified: no native/ or typeshed/ files in zip.")
            print(f"Total files in zip: {len(names)}")
    finally:
        if clone_dir is not None:
            shutil.rmtree(clone_dir, ignore_errors=True)


if __name__ == "__main__":
    main()
