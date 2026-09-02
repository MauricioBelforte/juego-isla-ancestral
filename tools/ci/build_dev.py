#!/usr/bin/env python3
# M118: build_dev.py - script de build de desarrollo (< 10 min, RF3).
# Uso: python tools/ci/build_dev.py [--godot path]
# Exit 0 si todo OK, 1 si fallo.
#
# Pipeline:
#   1. lint_check.py: lint de .gd files
#   2. run_tests.py: tests headless de los modulos data-driven
#   3. build_dev.gd: exporta el juego a build/dev/ (modo debug)

import os
import sys
import argparse

# Permitir importar pipeline.py desde tools/ci/
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from pipeline import Pipeline, Step


PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    parser = argparse.ArgumentParser(description="Build de desarrollo M118")
    parser.add_argument("--godot", help="Path al binario de Godot (default: $GODOT_BIN o autodetect)")
    parser.add_argument("--no-fail-fast", action="store_true", help="Continuar aunque un step falle")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "out", "ci-report-dev.json"), help="Path al reporte JSON")
    args = parser.parse_args()

    # Steps del pipeline de dev
    steps = [
        Step(
            name="lint-check",
            cmd=["python", os.path.join(HERE, "lint_check.py")],
            type="python",
            description="Lint de .gd (sintaxis, class_name, snake_case)",
        ),
        Step(
            name="tests-headless",
            cmd=["python", os.path.join(HERE, "run_tests.py")],
            type="python",
            description="Ejecuta los tests headless de los modulos",
        ),
    ]

    # Si hay un script de build Godot, agregarlo
    build_dev_gd = os.path.join(PROJECT_ROOT, "tools", "ci", "build_dev.gd")
    if os.path.exists(build_dev_gd):
        godot_cmd = args.godot or "godot"
        steps.append(Step(
            name="export-build-dev",
            cmd=[godot_cmd, "--headless", "--script", "res://tools/ci/build_dev.gd"],
            type="godot_test",
            timeout=600,
            description="Exporta el juego a build/dev/ via Godot",
        ))

    p = Pipeline(
        name="ci-build-dev",
        steps=steps,
        project_root=PROJECT_ROOT,
        fail_fast=not args.no_fail_fast,
    )
    results = p.run()
    p.write_report(results, args.out)
    failed = any(r.returncode != 0 for r in results)
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
