#!/usr/bin/env python3
# M144 iter 3: Test del format_changelog.py (Keep a Changelog 1.1.0).

import os
import sys
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "format_changelog.py")
    tests = []
    r1 = subprocess.run(["python", script, "--help"], capture_output=True, text=True, timeout=10)
    tests.append((r1.returncode == 0, f"--help: exit {r1.returncode}"))
    # Test 1: con version explicita
    r2 = subprocess.run(
        ["python", script, "--version", "9.9.9-test"],
        capture_output=True, text=True, timeout=10,
        cwd=PROJECT_ROOT,
    )
    tests.append((r2.returncode == 0, f"version 9.9.9-test: exit {r2.returncode}"))
    tests.append(("9.9.9-test" in r2.stdout, f"output reporta la version 9.9.9-test"))
    # Test 2: el CHANGELOG.md generado tiene formato Keep a Changelog
    r3 = subprocess.run(
        ["python", script, "--version", "1.0.0"],
        capture_output=True, text=True, timeout=10,
        cwd=PROJECT_ROOT,
    )
    tests.append((r3.returncode == 0, "CHANGELOG generado OK"))
    tests.append((os.path.exists(os.path.join(PROJECT_ROOT, "CHANGELOG.md")), "CHANGELOG.md existe"))
    with open(os.path.join(PROJECT_ROOT, "CHANGELOG.md"), "r", encoding="utf-8") as f:
        ch = f.read()
    checks = [
        ("# Changelog" in ch, "MD tiene titulo '# Changelog'"),
        ("Keep a Changelog 1.1.0" in ch, "MD referencia Keep a Changelog 1.1.0"),
        ("Semantic Versioning" in ch, "MD referencia Semantic Versioning"),
        ("[1.0.0]" in ch, "MD tiene [1.0.0]"),
        ("## [" in ch, "MD tiene seccion ## [version]"),
    ]
    tests.extend(checks)
    # Test 3: con tempdir y git-like repo, commits simulados
    with tempfile.TemporaryDirectory() as tmp:
        os.makedirs(os.path.join(tmp, ".git"), exist_ok=True)
        # Crear scripts/changelog commits-like con conventional format
        # (no podemos usar git log real, pero podemos probar --from / --to con refs que no existen)
        r4 = subprocess.run(
            ["python", script, "--from", "v0.0.1", "--to", "v0.0.2", "--version", "0.0.2"],
            capture_output=True, text=True, timeout=10,
            cwd=tmp,
        )
        # git log falla pero el script sigue (genera "Sin cambios")
        tests.append((r4.returncode == 0, f"sin git: exit {r4.returncode}"))
        tests.append(("Sin cambios" in r4.stdout or "no se encontraron" in r4.stdout, "informa sin commits"))
    fallos = 0
    for ok, msg in tests:
        if ok:
            print(f"  [OK] {msg}")
        else:
            print(f"  [FAIL] {msg}")
            fallos += 1
    print(f"=== Resumen M144 format_changelog_test: {len(tests) - fallos}/{len(tests)} OK ===")
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
