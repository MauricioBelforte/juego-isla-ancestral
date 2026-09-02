#!/usr/bin/env python3
# M118: run_tests.py - corre todos los tests headless de los modulos.
# Descubre automaticamente archivos test_*.gd en scripts/ y los corre con godot --headless.
# Genera reporte JSON con resultados por test.
# Exit 0 si todos pasan, 1 si alguno falla.

import os
import sys
import json
import argparse
import subprocess
import time
from typing import List, Dict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from pipeline import Pipeline, Step

PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
# Godot --path debe apuntar al project, no al repo
GODOT_PROJECT_PATH = os.path.join(PROJECT_ROOT, "game", "isla-ancestral")


def find_godot_bin() -> str:
    env = os.environ.get("GODOT_BIN")
    if env and os.path.exists(env):
        return env
    candidates = [
        r"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe",
        r"C:\Program Files\Godot\godot.exe",
        r"/usr/bin/godot",
        r"/usr/local/bin/godot",
    ]
    for c in candidates:
        if os.path.exists(c):
            return c
    return "godot"


def find_test_files(root: str) -> list:
    """Encuentra test_*.gd bajo scripts/ y tests/ (carpetas principales de tests)."""
    out = []
    candidates = [
        os.path.join(root, "game", "isla-ancestral", "scripts"),
        os.path.join(root, "game", "isla-ancestral", "tests"),
    ]
    skip = {".import", "test_temp"}
    for scripts_root in candidates:
        if not os.path.isdir(scripts_root):
            continue
        for dirpath, dirnames, filenames in os.walk(scripts_root):
            dirnames[:] = [d for d in dirnames if d not in skip]
            for f in filenames:
                if f.startswith("test_") and f.endswith(".gd"):
                    # res:// = game/isla-ancestral/scripts/... o game/isla-ancestral/tests/...
                    rel = os.path.relpath(os.path.join(dirpath, f), os.path.join(root, "game", "isla-ancestral"))
                    rel = rel.replace(os.sep, "/")
                    out.append("res://" + rel)
    return sorted(set(out))


def main() -> int:
    parser = argparse.ArgumentParser(description="Run all headless tests")
    parser.add_argument("--godot", help="Path al binario de Godot")
    parser.add_argument("--module", help="Solo tests del modulo dado (ej: mineria)")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "out", "test-report.json"))
    parser.add_argument("--timeout", type=int, default=120, help="Timeout por test (segundos)")
    args = parser.parse_args()

    godot_bin = args.godot or find_godot_bin()
    if not godot_bin:
        print("[tests] ERROR: godot no encontrado", file=sys.stderr)
        return 1

    test_files = find_test_files(PROJECT_ROOT)
    if args.module:
        test_files = [t for t in test_files if args.module in t]
    if not test_files:
        print(f"[tests] no se encontraron tests" + (f" para {args.module}" if args.module else ""))
        return 0

    print(f"[tests] {len(test_files)} tests a ejecutar con {godot_bin}")

    steps = [
        Step(
            name=f"test-{os.path.basename(t).replace('.gd', '').replace('test_', '')}",
            cmd=[godot_bin, "--headless", "--path", GODOT_PROJECT_PATH, "--script", t],
            type="godot_test",
            timeout=args.timeout,
            description=t,
        )
        for t in test_files
    ]
    p = Pipeline(
        name="ci-tests",
        steps=steps,
        project_root=PROJECT_ROOT,
        fail_fast=False,  # Queremos ejecutar TODOS los tests aunque uno falle
    )
    results = p.run()
    p.write_report(results, args.out)

    # Resumen
    passed = sum(1 for r in results if r.returncode == 0)
    failed = len(results) - passed
    print(f"[tests] Resumen: {passed} OK, {failed} FAIL")
    return 1 if failed > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
