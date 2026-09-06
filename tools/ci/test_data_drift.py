#!/usr/bin/env python3
# M118 iter 7: Test del data_drift_detector.

import os
import sys
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))


def main() -> int:
    script = os.path.join(HERE, "data_drift_detector.py")
    tests = []
    r1 = subprocess.run(["python", script, "--help"], capture_output=True, text=True, timeout=10)
    tests.append((r1.returncode == 0, f"--help: exit {r1.returncode}"))
    with tempfile.TemporaryDirectory() as tmp:
        snap = os.path.join(tmp, "snap.json")
        data_dir = os.path.join(tmp, "data")
        os.makedirs(data_dir, exist_ok=True)
        with open(os.path.join(data_dir, "a.json"), "w") as f:
            f.write("{}")
        with open(os.path.join(data_dir, "b.json"), "w") as f:
            f.write("{}")
        r2 = subprocess.run(
            ["python", script, "--snapshot", snap, "--data-dir", data_dir, "--init"],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r2.returncode == 0, f"--init: exit {r2.returncode}"))
        tests.append(("inicializado" in r2.stdout, f"reporta inicializacion"))
        tests.append((os.path.exists(snap), f"snapshot {snap} existe"))
        r3 = subprocess.run(
            ["python", script, "--snapshot", snap, "--data-dir", data_dir],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r3.returncode == 0, f"sin cambios: exit {r3.returncode}"))
        tests.append(("0 cambios" in r3.stdout, f"reporta 0 cambios"))
        with open(os.path.join(data_dir, "a.json"), "w") as f:
            f.write("{\"v\":2}")
        r4 = subprocess.run(
            ["python", script, "--snapshot", snap, "--data-dir", data_dir],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r4.returncode == 1, f"archivo modificado: exit {r4.returncode}"))
        tests.append(("MODIFICADO" in r4.stdout, f"reporta MODIFICADO"))
        tests.append(("a.json" in r4.stdout, f"menciona el archivo"))
        with open(os.path.join(data_dir, "c.json"), "w") as f:
            f.write("{}")
        r5 = subprocess.run(
            ["python", script, "--snapshot", snap, "--data-dir", data_dir],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r5.returncode == 1, f"archivo nuevo: exit {r5.returncode}"))
        tests.append(("NUEVO" in r5.stdout, f"reporta NUEVO"))
        os.remove(os.path.join(data_dir, "b.json"))
        r6 = subprocess.run(
            ["python", script, "--snapshot", snap, "--data-dir", data_dir],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r6.returncode == 1, f"archivo eliminado: exit {r6.returncode}"))
        tests.append(("ELIMINADO" in r6.stdout, f"reporta ELIMINADO"))
        r7 = subprocess.run(
            ["python", script, "--snapshot", snap, "--data-dir", data_dir, "--update"],
            capture_output=True, text=True, timeout=10,
        )
        tests.append((r7.returncode == 0, f"--update: exit {r7.returncode}"))
        tests.append(("actualizado" in r7.stdout, f"reporta actualizado"))
        with tempfile.TemporaryDirectory() as tmp7:
            snap7 = os.path.join(tmp7, "snap.json")
            no_exist = os.path.join(tmp7, "no_existe")
            r8 = subprocess.run(
                ["python", script, "--snapshot", snap7, "--data-dir", no_exist],
                capture_output=True, text=True, timeout=10,
            )
            tests.append((r8.returncode == 0, f"data_dir inexistente: exit {r8.returncode}"))
        with tempfile.TemporaryDirectory() as tmp9:
            snap9 = os.path.join(tmp9, "no_existe.json")
            data_dir9 = os.path.join(tmp9, "data")
            os.makedirs(data_dir9, exist_ok=True)
            r9 = subprocess.run(
                ["python", script, "--snapshot", snap9, "--data-dir", data_dir9],
                capture_output=True, text=True, timeout=10,
            )
            tests.append((r9.returncode == 0, f"snapshot inexistente: exit {r9.returncode}"))
            tests.append(("Usa --init" in r9.stdout, f"sugiere --init"))
    fallos = 0
    for ok, msg in tests:
        if ok:
            print(f"  [OK] {msg}")
        else:
            print(f"  [FAIL] {msg}")
            fallos += 1
    print(f"=== Resumen M118 data_drift_test: {len(tests) - fallos}/{len(tests)} OK ===")
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
