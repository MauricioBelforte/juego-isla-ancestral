#!/usr/bin/env python3
# M118 iter 6: Test del data_validator.

import os
import sys
import json
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "data_validator.py")
    tests = []
    # Test 1: --help funciona
    r1 = subprocess.run(["python", script, "--help"], capture_output=True, timeout=10)
    tests.append((r1.returncode == 0, f"--help: exit {r1.returncode}"))
    # Test 2: data_dir real del proyecto (puede tener errores -> exit 1)
    data_dir = os.path.join(PROJECT_ROOT, "game", "isla-ancestral", "data")
    r2 = subprocess.run(
        ["python", script, "--data-dir", data_dir],
        capture_output=True, timeout=30,
        cwd=PROJECT_ROOT
    )
    out2 = r2.stdout.decode("latin-1", errors="replace") + r2.stderr.decode("latin-1", errors="replace")
    tests.append((r2.returncode in [0, 1], f"data dir real: exit {r2.returncode} (0=OK, 1=errores)"))
    tests.append(("JSONs" in out2, f"reporta numero de JSONs"))
    # Test 3: data_dir vacio -> exit 0
    with tempfile.TemporaryDirectory() as tmp:
        r3 = subprocess.run(
            ["python", script, "--data-dir", tmp],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r3.returncode == 0, f"dir vacio: exit {r3.returncode} (esperado 0)"))
        tests.append(("no JSONs" in r3.stdout or "no se encontraron" in r3.stdout, "informa sin JSONs"))
    # Test 4: data_dir inexistente -> exit 0
    no_exist = os.path.join(tempfile.gettempdir(), "no_existe_xyz_" + str(os.getpid()))
    r4 = subprocess.run(
        ["python", script, "--data-dir", no_exist],
        capture_output=True, text=True, timeout=10,
    )
    tests.append((r4.returncode == 0, f"dir inexistente: exit {r4.returncode}"))
    # Test 5: tmp con un JSON valido con esquema conocido
    with tempfile.TemporaryDirectory() as tmp5:
        ok_path = os.path.join(tmp5, "creditos.json")
        with open(ok_path, "w", encoding="utf-8") as f:
            json.dump({"secciones": [], "idiomas": ["es"], "version": 1}, f)
        in_dir_arg = tmp5.replace(os.sep, "/")
        r5 = subprocess.run(
            ["python", script, "--data-dir", in_dir_arg],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r5.returncode == 0, f"JSON valido con esquema: exit {r5.returncode}"))
    # Test 6: tmp con un JSON invalido (sin claves requeridas)
    with tempfile.TemporaryDirectory() as tmp6:
        bad_path = os.path.join(tmp6, "creditos.json")
        with open(bad_path, "w", encoding="utf-8") as f:
            json.dump({"secciones": []}, f)  # falta idiomas y version
        in_dir_arg = tmp6.replace(os.sep, "/")
        r6 = subprocess.run(
            ["python", script, "--data-dir", in_dir_arg],
            capture_output=True, timeout=10,
        )
        # Decodificar con latin-1 (PowerShell cp1252) y buscar palabras clave
        out6 = r6.stdout.decode("latin-1", errors="replace") + r6.stderr.decode("latin-1", errors="replace")
        tests.append((r6.returncode == 1, f"JSON sin claves: exit {r6.returncode} (esperado 1)"))
        tests.append(("idiomas" in out6 or "version" in out6 or "requerida" in out6, f"reporta claves faltantes (busca en latin-1)"))
    # Test 7: tmp con JSON raiz no es dict (deberia ser array segun schema)
    with tempfile.TemporaryDirectory() as tmp7:
        wrong_path = os.path.join(tmp7, "ores.json")  # ores.json es array
        with open(wrong_path, "w", encoding="utf-8") as f:
            json.dump({"no": "es array"}, f)
        in_dir_arg = tmp7.replace(os.sep, "/")
        r7 = subprocess.run(
            ["python", script, "--data-dir", in_dir_arg],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r7.returncode == 1, f"raiz no array para ores.json: exit {r7.returncode}"))
    # Test 8: --strict falla con JSON sin esquema
    with tempfile.TemporaryDirectory() as tmp8:
        unknown_path = os.path.join(tmp8, "unknown_schema.json")
        with open(unknown_path, "w", encoding="utf-8") as f:
            json.dump({"a": 1}, f)
        in_dir_arg = tmp8.replace(os.sep, "/")
        r8 = subprocess.run(
            ["python", script, "--data-dir", in_dir_arg, "--strict"],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r8.returncode == 1, f"--strict con unknown: exit {r8.returncode}"))
    fallos = 0
    for ok, msg in tests:
        if ok:
            print(f"  [OK] {msg}")
        else:
            print(f"  [FAIL] {msg}")
            fallos += 1
    print(f"=== Resumen M118 data_validator_test: {len(tests) - fallos}/{len(tests)} OK ===")
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
