#!/usr/bin/env python3
# M127: Copyright - Test de tools/legal/generate_copyright_register.py (iter. 2).
# Verifica: generacion, secciones, contenido data-driven, determinismo,
# --check (al dia / desactualizado) y rechazo de catalogos invalidos.
# Uso: python tools/legal/test_generate_register.py   (exit 0 = OK)

import os
import sys
import json
import shutil
import tempfile
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
GEN = os.path.join(HERE, "generate_copyright_register.py")
PROJECT_ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
COPYRIGHT_JSON = os.path.join(
    PROJECT_ROOT, "game", "isla-ancestral", "data", "legal", "copyright.json"
)

_checks = 0
_fallos = 0


def check(nombre, cond, detalle=""):
    global _checks, _fallos
    _checks += 1
    if cond:
        print(f"  [OK] {nombre}")
    else:
        _fallos += 1
        print(f"  [FALLO] {nombre} {detalle}")


def run(args, cwd=None):
    return subprocess.run(
        [sys.executable, GEN] + args,
        cwd=cwd or PROJECT_ROOT,
        capture_output=True,
        text=True,
    )


def main():
    tmp = tempfile.mkdtemp(prefix="m127_register_")
    try:
        print("--- generate_copyright_register: generacion ---")
        r = run(["--out-dir", tmp])
        dest = os.path.join(tmp, "legal", "copyright_register.md")
        check("exit 0 al generar", r.returncode == 0, r.stderr.strip())
        check("crea legal/copyright_register.md", os.path.exists(dest))

        contenido = ""
        if os.path.exists(dest):
            with open(dest, "r", encoding="utf-8") as f:
                contenido = f.read()

        # --- secciones que exige 03-Diseno.md §2 ---
        for seccion in (
            "## 1. Copyright automatico",
            "## 2. Registro formal (opcional)",
            "## 3. Evidencia de autoria",
        ):
            check(f"tiene la seccion '{seccion}'", seccion in contenido)

        # --- contenido data-driven: todos los elementos del catalogo ---
        with open(COPYRIGHT_JSON, "r", encoding="utf-8") as f:
            data = json.load(f)
        ids = [e["id"] for e in data["elementos"]]
        faltan = [i for i in ids if f"`{i}`" not in contenido]
        check(f"lista los {len(ids)} elementos del catalogo", not faltan, f"faltan={faltan}")
        check("cita el titular del catalogo", data["elementos"][0]["titular"] in contenido)

        # --- los pendientes de registro formal se derivan del catalogo ---
        pend = [e["id"] for e in data["elementos"]
                if str(e.get("registro", "")).lower() == "pendiente"]
        check("marca los pendientes de registro formal", all(f"`{p}`" in contenido for p in pend),
              f"pendientes={pend}")

        # --- determinismo (para poder verificarlo en CI con un diff) ---
        print("--- generate_copyright_register: determinismo ---")
        tmp2 = tempfile.mkdtemp(prefix="m127_register2_")
        try:
            run(["--out-dir", tmp2])
            dest2 = os.path.join(tmp2, "legal", "copyright_register.md")
            with open(dest2, "rb") as f:
                b2 = f.read()
            with open(dest, "rb") as f:
                b1 = f.read()
            check("dos corridas producen bytes identicos", b1 == b2)
            check("sin BOM", not b1.startswith(b"\xef\xbb\xbf"))
        finally:
            shutil.rmtree(tmp2, ignore_errors=True)

        # --- --check: al dia vs desactualizado ---
        print("--- generate_copyright_register: --check ---")
        r = run(["--out-dir", tmp, "--check"])
        check("--check exit 0 si esta al dia", r.returncode == 0, r.stderr.strip())
        with open(dest, "a", encoding="utf-8") as f:
            f.write("\nlinea intrusa\n")
        r = run(["--out-dir", tmp, "--check"])
        check("--check exit 1 si esta desactualizado", r.returncode == 1)
        r = run(["--out-dir", tmp, "--check"])
        check("--check nombra el archivo desactualizado", "desactualizado" in r.stderr)

        # --- catalogo invalido: debe fallar sin escribir ---
        print("--- generate_copyright_register: catalogo invalido ---")
        tmp3 = tempfile.mkdtemp(prefix="m127_register3_")
        try:
            malo = {"version": 1, "elementos": [{"id": "x", "elemento": "X"}]}  # sin titular/year
            malo_path = os.path.join(tmp3, "malo.json")
            with open(malo_path, "w", encoding="utf-8") as f:
                json.dump(malo, f)
            # el generador lee una ruta fija: se invoca su validador directamente
            sys.path.insert(0, HERE)
            import generate_copyright_register as gen
            errores = gen.validar(malo)
            check("el validador rechaza un elemento sin titular", any("titular" in e for e in errores),
                  str(errores))
            check("el validador rechaza un elemento sin year", any("year" in e for e in errores),
                  str(errores))
            check("el validador reporta ids duplicados",
                  any("duplicado" in e for e in gen.validar(
                      {"elementos": [{"id": "a", "elemento": "A", "titular": "T", "year": 2026},
                                     {"id": "a", "elemento": "A2", "titular": "T", "year": 2026}]})))
            check("el validador rechaza 'elementos' vacio", bool(gen.validar({"elementos": []})))
            check("el validador acepta el catalogo real", gen.validar(data) == [],
                  str(gen.validar(data)))
        finally:
            shutil.rmtree(tmp3, ignore_errors=True)

    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print(f"=== Resumen M127 generate_register: {_checks - _fallos}/{_checks} OK ===")
    return 1 if _fallos else 0


if __name__ == "__main__":
    sys.exit(main())
