#!/usr/bin/env python3
# M118: run_tests.py - corre todos los tests headless de los modulos.
# Descubre automaticamente archivos test_*.gd en scripts/ y los corre con godot --headless.
# Genera reporte JSON con resultados por test.
# Exit 0 si todos pasan, 1 si alguno falla.
#
# 2026-11-25 (Deepseek V4.1 Flash-DeepAI, Log 2458): antes incluia tambien suites que
# NO se pueden correr con --script (GdUnit4: exit 1 "doesn't inherit from SceneTree",
# y helpers/mocks que extienden Node3D/RefCounted). Con ~11 fallos garantizados el
# exit code era 1 SIEMPRE, y dev-build lo tapaba con `|| echo "Some tests failed"`:
# el step se volvio ruido permanente y nadie lo miraba. Ahora se filtran por cabecera
# (`extends SceneTree|MainLoop`), se informan como omitidas y `--incluir-gdunit`
# permite forzarlas para diagnostico.

import os
import re
import sys
import json
import argparse
import subprocess
import time
from typing import List, Dict, Tuple

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


def es_ejecutable_con_script(path_abs: str) -> bool:
    """True si el script es un SceneTree/MainLoop (corrible con --script).

    Las suites GdUnit4 (`extends GdUnitTestSuite`) NO se pueden correr asi: Godot
    sale con exit 1 y el mensaje "doesn't inherit from SceneTree or MainLoop".
    El runner las incluia igual, asi que su exit code era 1 SIEMPRE y el step de
    dev-build lo tapaba con `|| echo "Some tests failed"`. Un gate que siempre
    esta rojo no es un gate: se dejo de mirar. Se filtran por cabecera (2026-11-25).
    """
    try:
        with open(path_abs, "r", encoding="utf-8", errors="replace") as fh:
            # Archivo completo: hay suites con 200 lineas de cabecera/comentarios antes
            # del `extends` (ej. scripts/historias/test_historias.gd). Con una ventana
            # corta se clasificaban mal y se omitian suites validas.
            cabecera = fh.read(200_000)
    except OSError:
        return False
    return bool(re.search(r"^extends\s+(SceneTree|MainLoop)\b", cabecera, re.M))


def find_test_files(root: str) -> Tuple[list, list]:
    """Encuentra test_*.gd corribles con --script bajo scripts/ y tests/.

    Devuelve (ejecutables, omitidas). Las omitidas se reportan: no se descartan
    en silencio (son suites GdUnit4, las corre el job GdUnit4 de testing.yml).
    """
    out = []
    omitidas = []
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
                    abs_path = os.path.join(dirpath, f)
                    rel = os.path.relpath(abs_path, os.path.join(root, "game", "isla-ancestral"))
                    rel = rel.replace(os.sep, "/")
                    if es_ejecutable_con_script(abs_path):
                        out.append("res://" + rel)
                    else:
                        omitidas.append("res://" + rel)
    return sorted(set(out)), sorted(set(omitidas))


def main() -> int:
    parser = argparse.ArgumentParser(description="Run all headless tests")
    parser.add_argument("--godot", help="Path al binario de Godot")
    parser.add_argument("--module", help="Solo tests del modulo dado (ej: mineria)")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "out", "test-report.json"))
    parser.add_argument("--timeout", type=int, default=120, help="Timeout por test (segundos)")
    parser.add_argument("--incluir-gdunit", action="store_true",
                        help="incluir suites GdUnit4 (fallan con --script: solo para diagnostico)")
    args = parser.parse_args()

    godot_bin = args.godot or find_godot_bin()
    if not godot_bin:
        print("[tests] ERROR: godot no encontrado", file=sys.stderr)
        return 1

    test_files, omitidas = find_test_files(PROJECT_ROOT)
    if args.incluir_gdunit:
        test_files = sorted(set(test_files) | set(omitidas))
        omitidas = []
    if args.module:
        test_files = [t for t in test_files if args.module in t]
        omitidas = [t for t in omitidas if args.module in t]
    if omitidas:
        print(f"[tests] {len(omitidas)} suites GdUnit4 omitidas (no corren con --script; "
              f"las ejecuta el job GdUnit4 de testing.yml). Ver --incluir-gdunit.")
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
