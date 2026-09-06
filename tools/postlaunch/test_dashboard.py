#!/usr/bin/env python3
# M144: Test del generador de dashboard.

import os
import sys
import json
import subprocess
import tempfile
import glob

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "dashboard.py")
    out_dir = os.path.join(PROJECT_ROOT, "out")
    if not os.path.isdir(out_dir):
        os.makedirs(out_dir, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        # Copia algunos JSONs reales a tmp
        import shutil
        n = 0
        for src in glob.glob(os.path.join(out_dir, "*.json")):
            if n >= 3:
                break
            shutil.copy(src, tmp)
            n += 1
        result = subprocess.run(
            ["python", script, "--in-dir", tmp, "--out-dir", tmp],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode != 0:
            print(f"FAIL returncode={result.returncode}")
            print(result.stderr)
            return 1
        json_path = os.path.join(tmp, "dashboard.json")
        alerts_path = os.path.join(tmp, "alerts.json")
        html_path = os.path.join(tmp, "dashboard.html")
        if not os.path.exists(json_path) or not os.path.exists(alerts_path) or not os.path.exists(html_path):
            print("FAIL archivos no generados")
            return 1
        with open(html_path, "r", encoding="utf-8") as f:
            html = f.read()
        with open(json_path, "r", encoding="utf-8") as f:
            jd = json.load(f)
        checks = [
            ("DOCTYPE" in html, "HTML tiene DOCTYPE"),
            ("Isla Ancestral" in html, "HTML contiene 'Isla Ancestral'"),
            ("<style>" in html, "HTML tiene <style> (CSS inline)"),
            ("Sin CDN" in html or "https://cdn" not in html, "HTML sin CDN externo (100% offline)"),
            ("indicators" in jd, "JSON tiene 'indicators'"),
            ("alerts" in jd, "JSON tiene 'alerts'"),
            ("timestamp" in jd, "JSON tiene 'timestamp'"),
            ("data_sources" in jd, "JSON tiene 'data_sources'"),
        ]
        fallos = 0
        for ok, msg in checks:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M144 dashboard: {len(checks) - fallos}/{len(checks)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
