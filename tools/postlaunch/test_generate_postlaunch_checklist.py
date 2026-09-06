#!/usr/bin/env python3
# M144 iter 3: Test del generador de checklist operacional.
# Valida que el JSON se procesa correctamente y que el markdown se genera.

import os
import sys
import json
import subprocess
import tempfile
import shutil

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "generate_postlaunch_checklist.py")
    data_path = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data", "operaciones", "postlaunch_checks.json")
    if not os.path.exists(data_path):
        print(f"FAIL {data_path} no existe")
        return 1
    with tempfile.TemporaryDirectory() as tmp:
        result = subprocess.run(
            ["python", script, "--out-dir", tmp],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"FAIL returncode={result.returncode}")
            print(result.stderr)
            return 1
        md_path = os.path.join(tmp, "POSTLAUNCH_CHECKLIST.md")
        json_path = os.path.join(tmp, "postlaunch_checklist.json")
        if not os.path.exists(md_path) or not os.path.exists(json_path):
            print("FAIL archivos no generados")
            return 1
        with open(md_path, "r", encoding="utf-8") as f:
            md = f.read()
        with open(json_path, "r", encoding="utf-8") as f:
            jd = json.load(f)
        checks = [
            ("POSTLAUNCH" in md or "post-lanzamiento" in md.lower(), "MD contiene titulo"),
            ("Salud General" in md, "MD tiene seccion 'Salud General'"),
            ("| `rev_001`" in md, "MD tiene tabla con id rev_001"),
            ("| `fix_001`" in md, "MD tiene tabla con id fix_001 (hotfix)"),
            ("[DIARIA]" in md, "MD tiene marcador [DIARIA]"),
            ("[SEMANAL]" in md, "MD tiene marcador [SEMANAL]"),
            (len(jd.get("checks", {})) >= 5, f"JSON tiene >=5 categorias (got {len(jd.get('checks', {}))})"),
            (len(jd.get("checks", {}).get("salud_general", {}).get("items", [])) >= 1, "salud_general tiene items"),
            ("politicas" in jd, "JSON tiene 'politicas'"),
            (jd.get("politicas", {}).get("frecuencia_minima_diaria", []) is not None, "JSON tiene politica 'frecuencia_minima_diaria'"),
            (jd.get("politicas", {}).get("frecuencia_minima_semanal", []) is not None, "JSON tiene politica 'frecuencia_minima_semanal'"),
            (jd.get("politicas", {}).get("alertas_inmediatas", []) is not None, "JSON tiene politica 'alertas_inmediatas'"),
            ("# Isla Ancestral" in md, "MD empieza con titulo '# Isla Ancestral'"),
            ("Politicas generales" in md, "MD tiene seccion 'Politicas generales'"),
        ]
        fallos = 0
        for ok, msg in checks:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M144 generate_postlaunch_test: {len(checks) - fallos}/{len(checks)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
