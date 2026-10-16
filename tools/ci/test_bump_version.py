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
                capture_output=True, text=True, timeout=10, cwd=tmp,
                encoding="utf-8", errors="replace",
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
    # M117 iter. 3 (Log 946): el bump sincroniza #define AppVersion de installer/*.iss
    with tempfile.TemporaryDirectory() as tmp:
        proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
        os.makedirs(os.path.dirname(proj), exist_ok=True)
        with open(proj, "w", encoding="utf-8") as f:
            f.write('config/version="0.0.0-dev"\n')
        os.makedirs(os.path.join(tmp, "installer"), exist_ok=True)
        with open(os.path.join(tmp, "installer", "IslaAncestral.iss"), "w", encoding="utf-8") as f:
            f.write('#define AppVersion   "0.0.2"          ; DEBE coincidir\n')
        r = subprocess.run(["python", script, "patch"], capture_output=True, text=True, timeout=10, cwd=tmp)
        with open(os.path.join(tmp, "installer", "IslaAncestral.iss"), "r", encoding="utf-8") as f:
            iss = f.read()
        tests.append(('#define AppVersion   "0.0.1"' in iss, "real: el bump sincroniza el .iss a 0.0.1"))
        tests.append(("; DEBE coincidir" in iss, "real: conserva el comentario del .iss"))
    # DRY no modifica el .iss
    with tempfile.TemporaryDirectory() as tmp:
        proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
        os.makedirs(os.path.dirname(proj), exist_ok=True)
        with open(proj, "w", encoding="utf-8") as f:
            f.write('config/version="0.0.0-dev"\n')
        os.makedirs(os.path.join(tmp, "installer"), exist_ok=True)
        with open(os.path.join(tmp, "installer", "IslaAncestral.iss"), "w", encoding="utf-8") as f:
            f.write('#define AppVersion   "0.0.2"          ; DEBE coincidir\n')
        r = subprocess.run(["python", script, "patch", "--dry-run"], capture_output=True, text=True, timeout=10, cwd=tmp)
        with open(os.path.join(tmp, "installer", "IslaAncestral.iss"), "r", encoding="utf-8") as f:
            iss = f.read()
        tests.append(('#define AppVersion   "0.0.2"' in iss, "DRY no modifica el .iss"))
    # M117 iter. 4 (2026-10-16): el bump sincroniza application/file_version y
    # application/product_version de export_presets.cfg (metadatos del .exe Windows)
    with tempfile.TemporaryDirectory() as tmp:
        proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
        os.makedirs(os.path.dirname(proj), exist_ok=True)
        with open(proj, "w", encoding="utf-8") as f:
            f.write('config/version="0.0.0-dev"\n')
        preset = os.path.join(tmp, "game", "isla-ancestral", "export_presets.cfg")
        with open(preset, "w", encoding="utf-8") as f:
            f.write('[preset.1]\n\nname="Windows"\n[preset.1.options]\n\napplication/file_version="0.0.2"\napplication/product_version="0.0.2"\napplication/company_name="Isla Ancestral"\n')
        r = subprocess.run(["python", script, "patch"], capture_output=True, text=True, timeout=10, cwd=tmp)
        with open(preset, "r", encoding="utf-8") as f:
            cfg = f.read()
        tests.append((r.returncode == 0, f"preset: exit {r.returncode}"))
        tests.append(('application/file_version="0.0.1"' in cfg and 'application/product_version="0.0.1"' in cfg, "real: el bump sincroniza file_version/product_version del preset a 0.0.1"))
        tests.append(('application/company_name="Isla Ancestral"' in cfg, "real: conserva el resto del preset"))
    # DRY no modifica el preset
    with tempfile.TemporaryDirectory() as tmp:
        proj = os.path.join(tmp, "game", "isla-ancestral", "project.godot")
        os.makedirs(os.path.dirname(proj), exist_ok=True)
        with open(proj, "w", encoding="utf-8") as f:
            f.write('config/version="0.0.0-dev"\n')
        preset = os.path.join(tmp, "game", "isla-ancestral", "export_presets.cfg")
        with open(preset, "w", encoding="utf-8") as f:
            f.write('application/file_version="0.0.2"\napplication/product_version="0.0.2"\n')
        r = subprocess.run(["python", script, "patch", "--dry-run"], capture_output=True, text=True, timeout=10, cwd=tmp)
        with open(preset, "r", encoding="utf-8") as f:
            cfg = f.read()
        tests.append(('application/file_version="0.0.2"' in cfg, "DRY no modifica el preset"))
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
