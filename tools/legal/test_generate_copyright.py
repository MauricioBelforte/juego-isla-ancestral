#!/usr/bin/env python3
# M127: Test del generador data-driven de copyright docs.
# Valida que NOTICE.md y LICENSE se generan correctamente desde los JSONs.

import os
import sys
import subprocess
import tempfile
import json

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))  # tools/
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "generate_copyright_docs.py")
    copyright_json = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json")
    licencias_json = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "licencias.json")
    with tempfile.TemporaryDirectory() as tmp:
        result = subprocess.run(
            ["python", script, "--out-dir", tmp, "--year", "2026"],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"FAIL script returncode={result.returncode}")
            print(result.stderr)
            return 1
        # Verifica NOTICE.md
        notice_path = os.path.join(tmp, "NOTICE.md")
        if not os.path.exists(notice_path):
            print("FAIL NOTICE.md no generado")
            return 1
        with open(notice_path, "r", encoding="utf-8") as f:
            notice = f.read()
        checks = [
            ("Isla Ancestral" in notice, "NOTICE contiene 'Isla Ancestral'"),
            ("Copyright" in notice, "NOTICE contiene 'Copyright'"),
            ("2026" in notice, "NOTICE contiene el año 2026"),
            ("elementos protegidos" in notice.lower() or "Elementos protegidos" in notice, "NOTICE tiene seccion 'Elementos protegidos'"),
            ("terceros" in notice.lower() or "Software y assets" in notice, "NOTICE tiene seccion de terceros"),
            ("Godot Engine" in notice, "NOTICE menciona Godot Engine"),
            ("MIT" in notice, "NOTICE menciona MIT"),
            ("Voxel Tools" in notice, "NOTICE menciona Voxel Tools"),
        ]
        # Verifica LICENSE
        license_path = os.path.join(tmp, "LICENSE")
        if not os.path.exists(license_path):
            print("FAIL LICENSE no generado")
            return 1
        with open(license_path, "r", encoding="utf-8") as f:
            lic = f.read()
        checks.extend([
            ("LICENSE" in lic, "LICENSE tiene titulo"),
            ("Isla Ancestral" in lic, "LICENSE contiene 'Isla Ancestral'"),
            ("Copyright" in lic, "LICENSE tiene copyright"),
            ("Propietaria" in lic or "MIT" in lic, "LICENSE tiene texto de licencia"),
            ("Componentes" in lic, "LICENSE tiene seccion Componentes"),
        ])
        fallos = 0
        for ok, msg in checks:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M127 generate: {len(checks) - fallos}/{len(checks)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
