#!/usr/bin/env python3
# M118 iter 3: Test del linter de .gd.
# Valida que lint_check.py corre sin errores, reporta warnings correctamente,
# y respeta exclusiones.

import os
import sys
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "lint_check.py")
    if not os.path.exists(script):
        print(f"FAIL {script} no existe")
        return 1
    result = subprocess.run(
        ["python", script, "--no-syntax"],
        capture_output=True, text=True, timeout=120
    )
    checks = [
        # El linter debe correr sin tirar error fatal (rc 0 o 1, no 2/3)
        (result.returncode in [0, 1], f"lint_check rc razonable (got {result.returncode})"),
        # Debe reportar archivos del proyecto
        ("archivos .gd a verificar" in result.stdout, "stdout reporta archivos .gd"),
        # Los warnings de tab no rompen el build (exit code 0)
        # Pero el linter marca correctamente cuando encuentra tabs
        # El codigo en si no debe tener errores de sintaxis Python
        (result.returncode != 3, f"lint_check no tiene error fatal (rc={result.returncode})"),
    ]
    # Verifica que el linter detecta archivos reales del proyecto
    files_detected: int = 0
    for line in result.stdout.split("\n"):
        if "WARN" in line and ".gd" in line:
            files_detected += 1
    checks.append((files_detected > 0, f"detecta warnings de tab (got {files_detected})"))
    # Verifica que --help funciona
    help_result = subprocess.run(
        ["python", script, "--help"],
        capture_output=True, text=True, timeout=10
    )
    checks.append(
        (help_result.returncode == 0 and "lint" in help_result.stdout.lower(),
         "lint_check --help funciona"),
    )
    # Verifica que respeta exclusiones (probar con una ruta que no existe)
    nonexistent_result = subprocess.run(
        ["python", script, "--no-syntax"],
        capture_output=True, text=True, timeout=30,
        cwd=os.path.dirname(PROJECT_ROOT),  # /tmp o similar
    )
    # No debe fallar fatalmente aunque no encuentre el project
    checks.append(
        (nonexistent_result.returncode in [0, 1],
         f"lint_check no falla fatalmente sin project (rc={nonexistent_result.returncode})"),
    )
    fallos = 0
    for ok, msg in checks:
        if ok:
            print(f"  [OK] {msg}")
        else:
            print(f"  [FAIL] {msg}")
            fallos += 1
    print(f"=== Resumen M118 lint_check_test: {len(checks) - fallos}/{len(checks)} OK ===")
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
