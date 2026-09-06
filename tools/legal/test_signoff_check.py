#!/usr/bin/env python3
# M127 iter 4: Test del signoff_check.

import os
import sys
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "signoff_check.py")
    # Test 1: project root -> todos los docs existen
    r1 = subprocess.run(
        ["python", script],
        capture_output=True, text=True, timeout=30,
        cwd=PROJECT_ROOT
    )
    tests = [
        (r1.returncode == 0, f"project root: exit {r1.returncode} (esperado 0)"),
        ("OK" in r1.stdout, "reporta OK en stdout"),
        ("NOTICE.md" in r1.stdout, "verifica NOTICE.md"),
        ("LICENSE" in r1.stdout, "verifica LICENSE"),
        ("AUTHORS.md" in r1.stdout, "verifica AUTHORS.md"),
        ("CONTRIBUTING.md" in r1.stdout, "verifica CONTRIBUTING.md"),
        ("data/legal/copyright.json" in r1.stdout, "verifica copyright.json"),
    ]
    # Test 2: --strict debe funcionar
    r2 = subprocess.run(
        ["python", script, "--strict"],
        capture_output=True, text=True, timeout=30,
        cwd=PROJECT_ROOT
    )
    tests.append((r2.returncode == 0, f"--strict: exit {r2.returncode}"))
    # Test 3: help funciona
    r3 = subprocess.run(
        ["python", script, "--help"],
        capture_output=True, text=True, timeout=10
    )
    tests.append((r3.returncode == 0, "--help funciona"))
    tests.append(("signoff" in r3.stdout.lower() or "legal" in r3.stdout.lower(), "--help describe el script"))
    # Test 4: dir temporal vacio -> falla
    with tempfile.TemporaryDirectory() as tmp:
        # crear estructura fake minima
        os.makedirs(os.path.join(tmp, "game", "isla-ancestral", "data", "legal"))
        with open(os.path.join(tmp, "NOTICE.md"), "w") as f:
            f.write("x" * 250 + " Copyright Attribut")
        with open(os.path.join(tmp, "LICENSE"), "w") as f:
            f.write("x" * 600 + " Copyright Propietaria")
        with open(os.path.join(tmp, "AUTHORS.md"), "w") as f:
            f.write("x" * 250 + " ## Contribuidores commits")
        with open(os.path.join(tmp, "CONTRIBUTING.md"), "w") as f:
            f.write("x" * 350 + " ## Como ## Convenciones")
        r4 = subprocess.run(
            ["python", script],
            capture_output=True, text=True, timeout=10,
            cwd=tmp
        )
        tests.append((r4.returncode == 0, f"dir temporal con docs: exit {r4.returncode}"))
    # Test 5: dir sin docs -> exit 0 (no hay nada que firmar = release OK sin docs)
    with tempfile.TemporaryDirectory() as tmp2:
        r5 = subprocess.run(
            ["python", script],
            capture_output=True, text=True, timeout=10,
            cwd=tmp2
        )
        tests.append((r5.returncode == 0, f"dir vacio (sin docs): exit {r5.returncode} (esperado 0 = sin firmas)"))
    fallos = 0
    for ok, msg in tests:
        if ok:
            print(f"  [OK] {msg}")
        else:
            print(f"  [FAIL] {msg}")
            fallos += 1
    print(f"=== Resumen M127 signoff_check_test: {len(tests) - fallos}/{len(tests)} OK ===")
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
