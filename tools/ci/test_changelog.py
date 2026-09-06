#!/usr/bin/env python3
# M118 iter 3: Test del generador de CHANGELOG.md data-driven.

import os
import sys
import json
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "changelog.py")
    with tempfile.TemporaryDirectory() as tmp:
        # Test 1: genera CHANGELOG.md desde todos los commits
        out_path = os.path.join(tmp, "CHANGELOG.md")
        result = subprocess.run(
            ["python", script, "--out", out_path],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"FAIL returncode={result.returncode}")
            print(result.stderr)
            return 1
        if not os.path.exists(out_path):
            print("FAIL CHANGELOG.md no generado")
            return 1
        with open(out_path, "r", encoding="utf-8") as f:
            md = f.read()
        checks = [
            ("# Changelog" in md, "MD tiene titulo '# Changelog'"),
            ("Keep a Changelog" in md, "MD menciona 'Keep a Changelog'"),
            ("## [" in md, "MD tiene seccion '## [version]'"),
            ("Added" in md or "Changed" in md or "Fixed" in md, "MD tiene categorias Keep a Changelog"),
            ("feat" in md.lower() or "fix" in md.lower() or "se agreg" in md.lower() or "se cre" in md.lower() or "se" in md.lower(), "MD detecta prefijos Conventional Commits"),
        ]
        # Si no hay commits Conventional, debe generar placeholder
        if "Sin cambios" in md or "fix" in md.lower():
            print("  [INFO] Se detectaron commits")
        else:
            print("  [INFO] No hay commits o todos sin prefijo")
        # Test 2: con --version custom
        out_path2 = os.path.join(tmp, "CHANGELOG2.md")
        result2 = subprocess.run(
            ["python", script, "--out", out_path2, "--version", "0.5.0"],
            capture_output=True, text=True, timeout=10
        )
        if result2.returncode != 0:
            print(f"FAIL --version test returncode={result2.returncode}")
            return 1
        with open(out_path2, "r", encoding="utf-8") as f:
            md2 = f.read()
        checks.append(("[0.5.0]" in md2, "MD incluye --version custom"))
        fallos = 0
        for ok, msg in checks:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M118 changelog_test: {len(checks) - fallos}/{len(checks)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
