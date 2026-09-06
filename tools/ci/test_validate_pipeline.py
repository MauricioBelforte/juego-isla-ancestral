#!/usr/bin/env python3
# M118 iter 4: Test del validador de JSONs.

import os
import sys
import json
import subprocess
import tempfile
import shutil

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "validate_pipeline.py")
    with tempfile.TemporaryDirectory() as tmp:
        # Crear JSONs validos
        valid_path = os.path.join(tmp, "valid.json")
        with open(valid_path, "w", encoding="utf-8") as f:
            json.dump({"version": 1, "ok": True}, f)
        # Crear JSON invalido
        invalid_path = os.path.join(tmp, "invalid.json")
        with open(invalid_path, "w", encoding="utf-8") as f:
            f.write("{ esto no es json valido")
        # Crear JSON sin 'version' (para test strict)
        no_version_path = os.path.join(tmp, "no_version.json")
        with open(no_version_path, "w", encoding="utf-8") as f:
            json.dump({"sin_version": True}, f)
        # Tests (cada uno usa su propio tmp para no contaminar)
        tests = []
        # Test 1: in-dir con validos -> exit 0
        with tempfile.TemporaryDirectory() as tmp1:
            valid_path = os.path.join(tmp1, "valid.json")
            with open(valid_path, "w", encoding="utf-8") as f:
                json.dump({"version": 1, "ok": True}, f)
            in_dir_arg = tmp1.replace(os.sep, "/")
            r1 = subprocess.run(["python", script, "--in-dir", in_dir_arg], capture_output=True, text=True, timeout=10)
            tests.append((r1.returncode == 0, f"in-dir validos: exit {r1.returncode} (esperado 0)"))
        # Test 2: in-dir con invalido -> exit 1
        with tempfile.TemporaryDirectory() as tmp2:
            invalid_path = os.path.join(tmp2, "invalid.json")
            with open(invalid_path, "w", encoding="utf-8") as f:
                f.write("{ esto no es json valido")
            in_dir_arg = tmp2.replace(os.sep, "/")
            r2 = subprocess.run(["python", script, "--in-dir", in_dir_arg], capture_output=True, text=True, timeout=10)
            tests.append((r2.returncode == 1, f"in-dir con invalido: exit {r2.returncode} (esperado 1)"))
            tests.append((r2.returncode == 1, f"detecta JSON invalido (exit={r2.returncode})"))
        # Test 3: strict + sin version -> exit 1
        with tempfile.TemporaryDirectory() as tmp3:
            no_version_path = os.path.join(tmp3, "no_version.json")
            with open(no_version_path, "w", encoding="utf-8") as f:
                json.dump({"sin_version": True}, f)
            in_dir_arg = tmp3.replace(os.sep, "/")
            r3 = subprocess.run(["python", script, "--in-dir", in_dir_arg, "--strict"], capture_output=True, text=True, timeout=10)
            tests.append((r3.returncode == 1, f"strict + sin version: exit {r3.returncode} (esperado 1)"))
        # Test 4: in-dir inexistente -> exit 0 (no falla)
        no_exist = os.path.join(tempfile.gettempdir(), "no_existe_xyz_" + str(os.getpid()))
        in_dir_arg = no_exist.replace(os.sep, "/")
        r4 = subprocess.run(["python", script, "--in-dir", in_dir_arg], capture_output=True, text=True, timeout=10)
        tests.append((r4.returncode == 0, f"in-dir inexistente: exit {r4.returncode} (esperado 0)"))
        tests.append((r4.returncode == 0, f"informa que no existe (no falla)"))
        # Test 5: array como raiz es valido
        with tempfile.TemporaryDirectory() as tmp5:
            array_path = os.path.join(tmp5, "array.json")
            with open(array_path, "w", encoding="utf-8") as f:
                json.dump([1, 2, 3], f)
            in_dir_arg = tmp5.replace(os.sep, "/")
            r5 = subprocess.run(["python", script, "--in-dir", in_dir_arg], capture_output=True, text=True, timeout=10)
            tests.append((r5.returncode == 0, f"array como raiz: exit {r5.returncode} (esperado 0)"))
        # Test 6: tipo no soportado (string solo) -> fail
        with tempfile.TemporaryDirectory() as tmp6:
            string_path = os.path.join(tmp6, "string.json")
            with open(string_path, "w", encoding="utf-8") as f:
                f.write('"solo un string"')
            in_dir_arg = tmp6.replace(os.sep, "/")
            r6 = subprocess.run(["python", script, "--in-dir", in_dir_arg], capture_output=True, text=True, timeout=10)
            tests.append((r6.returncode == 1, f"raiz string: exit {r6.returncode} (esperado 1)"))
        fallos = 0
        for ok, msg in tests:
            if ok:
                print(f"  [OK] {msg}")
            else:
                print(f"  [FAIL] {msg}")
                fallos += 1
        print(f"=== Resumen M118 validate_pipeline_test: {len(tests) - fallos}/{len(tests)} OK ===")
        return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
