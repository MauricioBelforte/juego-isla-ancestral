#!/usr/bin/env python3
# M144: Test del generador data-driven de postlaunch checklist.

import os
import sys
import subprocess
import tempfile

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
        checks = [
            ("Isla Ancestral" in md, "MD contiene 'Isla Ancestral'"),
            ("Post-Lanzamiento" in md, "MD contiene 'Post-Lanzamiento'"),
            ("Salud General" in md, "MD contiene 'Salud General'"),
            ("monitoreo de reviews" in md.lower() or "Monitoreo de reviews" in md, "MD tiene 'monitoreo de reviews'"),
            ("| `rev_001`" in md, "MD tiene tabla con id rev_001"),
            ("| `perf_001`" in md, "MD tiene tabla con id perf_001"),
            ("| `fix_001`" in md, "MD tiene tabla con id fix_001 (hotfix)"),
            ("[DIARIA]" in md, "MD tiene marcador [DIARIA]"),
            ("[SEMANAL]" in md, "MD tiene marcador [SEMANAL]"),
        ]
        with open(json_path, "r", encoding="utf-8") as f:
            jd = json.load(f) if hasattr(f, "read") else None
        # Recarga
        with open(json_path, "r", encoding="utf-8") as f:
            jd = json.loads(f.read())
        checks.extend([
            ("version" in jd, "JSON tiene 'version'"),
            ("checks" in jd, "JSON tiene 'checks'"),
            ("salud_general" in jd.get("checks", {}), "JSON tiene categoria salud_general"),
            ("bugs" in jd.get("checks", {}), "JSON tiene categoria bugs"),
            (len(jd.get("checks", {}).get("salud_general", {}).get("items", [])) >= 1, "salud_general tiene items"),
        ])
        fallos = 0
        for ok, msg in checks:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M144 generate: {len(checks) - fallos}/{len(checks)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    import json
    sys.exit(main())
