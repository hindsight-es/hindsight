#!/usr/bin/env python3
"""
Convert Literate Haskell (.lhs) files to reStructuredText (.rst) for Sphinx.
"""

import os
import subprocess
import sys
from pathlib import Path

# Directories
PROJECT_DIR = Path("../hindsight")
TUTORIALS_DIR = Path("../hindsight-tutorials/tutorials")
DOCS_SOURCE_DIR = Path("source")
TUTORIALS_OUTPUT_DIR = DOCS_SOURCE_DIR / "tutorials"

def ensure_dir(path):
    """Ensure directory exists."""
    path.mkdir(parents=True, exist_ok=True)

def convert_lhs_to_rst(lhs_file, output_dir):
    """Convert a single .lhs file to .rst using pandoc."""
    output_file = output_dir / (lhs_file.stem + ".rst")
    
    # Pandoc command to convert LHS to RST
    cmd = [
        "pandoc",
        "--from=markdown+lhs",
        "--to=rst",
        "--highlight-style=tango",
        "--standalone",
        str(lhs_file),
        "-o", str(output_file)
    ]
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"✓ Converted {lhs_file.name} → {output_file.name}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to convert {lhs_file.name}: {e}")
        print(f"  stdout: {e.stdout}")
        print(f"  stderr: {e.stderr}")
        return False
    except FileNotFoundError:
        print("✗ pandoc not found. Please install pandoc first.")
        sys.exit(1)

def generate_tutorials_index(output_dir, tutorial_files):
    """Generate an index.rst file for the tutorials section."""
    index_content = """Tutorials
=========

Learn Hindsight through these step-by-step tutorials:

.. toctree::
   :maxdepth: 2
   :numbered:
   
"""

    # Sort tutorial files by their number prefix
    sorted_files = sorted(tutorial_files, key=lambda x: x.stem)
    
    for rst_file in sorted_files:
        if rst_file.stem != "index":
            index_content += f"   {rst_file.stem}\n"
    
    index_file = output_dir / "index.rst"
    with open(index_file, 'w') as f:
        f.write(index_content)
    
    print(f"✓ Generated {index_file}")

def main():
    """Main conversion function."""
    print("Converting Literate Haskell files to reStructuredText...")

    # Convert tutorials
    print("\nConverting tutorials...")

    # Ensure output directory exists
    ensure_dir(TUTORIALS_OUTPUT_DIR)

    # Find all .lhs files in tutorials directory
    lhs_files = list(TUTORIALS_DIR.glob("*.lhs"))

    if not lhs_files:
        print(f"No .lhs files found in {TUTORIALS_DIR}")
        return

    print(f"Found {len(lhs_files)} tutorial files:")
    for lhs_file in sorted(lhs_files):
        print(f"  - {lhs_file.name}")

    # Convert each file
    converted_files = []
    for lhs_file in lhs_files:
        if convert_lhs_to_rst(lhs_file, TUTORIALS_OUTPUT_DIR):
            converted_files.append(TUTORIALS_OUTPUT_DIR / (lhs_file.stem + ".rst"))

    # Generate index file
    if converted_files:
        generate_tutorials_index(TUTORIALS_OUTPUT_DIR, converted_files)

    print(f"\nConversion complete: {len(converted_files)}/{len(lhs_files)} tutorials converted")

if __name__ == "__main__":
    main()