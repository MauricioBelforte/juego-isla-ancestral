#!/usr/bin/env python3
# M118 iter 5: Test del bump_version.

import os
import sys
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "bump_version.py")
    tests = []
    r1 = subprocess.run(["python", script, "--help"], capture_output=True, text=True, timeout=10)
    tests.append((r1.returncode == 0, f"--help: exit {r1.returncode}"))
    # Tests con tempdirs separados (cada uno empieza con 0.0.0-dev)
    for test_name, kind, initial_ver, expected_new in [
        ("minor", "minor", "0.0.0-dev", "0.1.0"),
        ("major 1.2.3", "major", "1.2.3", "2.0.0"),
        ("patch 0.5.0", "patch", "0.5.0", "0.5.1"),
    ]:
        with tempfile.TemporaryDirectory() as tmp:
            proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
            os.makedirs(os.path.dirname(proj), exist_ok=True)
            with open(proj, "w", encoding="utf-8") as f:
                f.write(f'config/version="{initial_ver}"\n')
            r = subprocess.run(
                ["python", script, kind, "--dry-run"],
                capture_output=True, text=True, timeout=10, cwd=tmp
            )
            tests.append((r.returncode == 0, f"{test_name}: exit {r.returncode}"))
            tests.append((f"{initial_ver} -> {expected_new}" in r.stdout, f"bump {initial_ver} -> {expected_new}"))
    # DRY no modifica
    with tempfile.TemporaryDirectory() as tmp:
        proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
        os.makedirs(os.path.dirname(proj), exist_ok=True)
        with open(proj, "w", encoding="utf-8") as f:
            f.write('config/version="0.0.0-dev"\n')
        os.makedirs(os.path.join(tmp, "game", "isla-ancestral", "data", "legal"), exist_ok=True)
        with open(os.path.join(tmp, "game", "isla-ancestral", "data", "legal", "copyright.json"), "w") as f:
            f.write('{"version": 1, "elementos": [{"id": "a", "year": 2024}]}')
        with open(os.path.join(tmp, "CHANGELOG.md"), "w") as f:
            f.write("# Changelog\n\n")
        r = subprocess.run(["python", script, "minor", "--dry-run"], capture_output=True, text=True, timeout=10, cwd=tmp)
        with open(proj, "r", encoding="utf-8") as f:
            content = f.read()
        tests.append(('config/version="0.0.0-dev"' in content, "DRY no modifica project.godot"))
    # Real (sin --dry-run) SI modifica
    with tempfile.TemporaryDirectory() as tmp:
        proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
        os.makedirs(os.path.dirname(proj), exist_ok=True)
        with open(proj, "w", encoding="utf-8") as f:
            f.write('config/version="0.0.0-dev"\n')
        os.makedirs(os.path.join(tmp, "game", "isla-ancestral", "data", "legal"), exist_ok=True)
        with open(os.path.join(tmp, "game", "isla-ancestral", "data", "legal", "copyright.json"), "w") as f:
            f.write('{"version": 1, "elementos": [{"id": "a", "year": 2024}]}')
        with open(os.path.join(tmp, "CHANGELOG.md"), "w") as f:
            f.write("# Changelog\n\n")
        r = subprocess.run(["python", script, "patch"], capture_output=True, text=True, timeout=10, cwd=tmp)
        tests.append((r.returncode == 0, f"real: exit {r.returncode}"))
        with open(proj, "r", encoding="utf-8") as f:
            content = f.read()
        tests.append(('config/version="0.0.1"' in content, "real actualiza project.godot a 0.0.1"))
    # Kind invalido
    r5 = subprocess.run(["python", script, "invalid"], capture_output=True, text=True, timeout=10)
    tests.append((r5.returncode != 0, f"kind invalido: exit != 0"))
    fallos = 0
    for ok, msg in tests:
        if ok:
            print(f"  [OK] {msg}")
        else:
            print(f"  [FAIL] {msg}")
            fallos += 1
    print(f"=== Resumen M118 bump_version_test: {len(tests) - fallos}/{len(tests)} OK ===")
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
