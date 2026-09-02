#!/usr/bin/env python3
# M118: build_release.py - script de build release (RF4, optimizado).
# Uso: python tools/ci/build_release.py [--version v1.0.0]
# Genera build/release/<game>-v<version>.exe

import os
import sys
import argparse

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from pipeline import Pipeline, Step

PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    parser = argparse.ArgumentParser(description="Build release M118")
    parser.add_argument("--version", default="0.0.0-dev", help="Version semver (default: 0.0.0-dev)")
    parser.add_argument("--godot", help="Path al binario de Godot")
    parser.add_argument("--no-fail-fast", action="store_true")
    parser.add_argument("--out", default=os.path.join(PROJECT_ROOT, "out", "ci-report-release.json"))
    args = parser.parse_args()

    build_release_gd = os.path.join(PROJECT_ROOT, "tools", "ci", "build_release.gd")
    steps = [
        Step(
            name="lint-check",
            cmd=["python", os.path.join(HERE, "lint_check.py")],
            type="python",
            description="Lint completo",
        ),
        Step(
            name="tests-headless",
            cmd=["python", os.path.join(HERE, "run_tests.py")],
            type="python",
            description="Todos los tests deben pasar antes de release",
        ),
    ]
    if os.path.exists(build_release_gd):
        godot_cmd = args.godot or "godot"
        steps.append(Step(
            name="export-build-release",
            cmd=[godot_cmd, "--headless", "--script", "res://tools/ci/build_release.gd", "--version", args.version],
            type="godot_test",
            timeout=900,  # 15 min para release optimizado
            description=f"Exporta el juego a build/release/ con version {args.version}",
        ))

    p = Pipeline(
        name="ci-build-release",
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
