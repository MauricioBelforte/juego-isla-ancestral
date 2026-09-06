#!/usr/bin/env python3
# M127 iter 3: Test del generador de AUTHORS.md y CONTRIBUTING.md.

import os
import sys
import json
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "generate_authors.py")
    out_dir = os.path.join(PROJECT_ROOT, "out")
    os.makedirs(out_dir, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        result = subprocess.run(
            ["python", script, "--out-dir", tmp],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"FAIL returncode={result.returncode}")
            print(result.stderr)
            return 1
        authors_path = os.path.join(tmp, "AUTHORS.md")
        contrib_path = os.path.join(tmp, "CONTRIBUTING.md")
        if not os.path.exists(authors_path) or not os.path.exists(contrib_path):
            print("FAIL archivos no generados")
            return 1
        with open(authors_path, "r", encoding="utf-8") as f:
            am = f.read()
        with open(contrib_path, "r", encoding="utf-8") as f:
            cm = f.read()
        checks = [
            ("# juego-isla-ancestral" in am or "AUTHORS" in am, "AUTHORS.md tiene titulo"),
            ("## Contribuidores" in am, "AUTHORS.md tiene seccion 'Contribuidores'"),
            ("Total" in am, "AUTHORS.md tiene 'Total'"),
            ("| # | Nombre" in am, "AUTHORS.md tiene tabla con #, Nombre, ..."),
            ("# Contributing" in cm, "CONTRIBUTING.md tiene titulo 'Contributing'"),
            ("Godot" in cm, "CONTRIBUTING.md menciona 'Godot'"),
            ("Conventional Commits" in cm or "commit" in cm.lower(), "CONTRIBUTING.md menciona convencion de commits"),
            ("## Estructura" in cm, "CONTRIBUTING.md tiene seccion 'Estructura'"),
            ("Fork" in cm, "CONTRIBUTING.md menciona 'Fork'"),
            ("Pull Request" in cm, "CONTRIBUTING.md menciona 'Pull Request'"),
        ]
        # Si no hay commits, los archivos tendran placeholders
        if "1 contribuidor" in am.lower() or "0 contribuidor" in am.lower():
            print("  [INFO] No hay commits reales (generando placeholders)")
        fallos = 0
        for ok, msg in checks:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M127 generate_authors_test: {len(checks) - fallos}/{len(checks)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
