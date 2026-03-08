"""Bundle JacLang source into a zip for Pyodide.

Creates a minimal jaclang.zip from the installed jaclang package (pip).
Includes precompiled .jir bytecode shipped with the package for faster
browser loading.

Usage:
    python scripts/bundle_jaclang.py
    python scripts/bundle_jaclang.py -o assets/jaclang.zip
"""

import argparse
import os
import sys
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


def find_installed_jaclang() -> str:
    """Find the installed jaclang package directory."""
    try:
        import jaclang
        return os.path.dirname(jaclang.__file__)
    except ImportError:
        print("Error: jaclang is not installed. Run: pip install jaclang", file=sys.stderr)
        sys.exit(1)


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
    parser = argparse.ArgumentParser(description="Bundle JacLang for Pyodide")
    parser.add_argument(
        "-o", "--output",
        default=os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            "assets", "jaclang.zip",
        ),
        help="Output zip path (default: jac_playground/assets/jaclang.zip)",
    )
    args = parser.parse_args()

    jaclang_dir = find_installed_jaclang()
    print(f"Found jaclang at: {jaclang_dir}")

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    print(f"Creating zip: {args.output}")
    create_zip(jaclang_dir, args.output)

    print("Bundle created successfully.")


if __name__ == "__main__":
    main()
