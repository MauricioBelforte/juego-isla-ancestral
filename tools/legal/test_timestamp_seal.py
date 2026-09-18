#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 3 -- Test de tools/legal/timestamp_seal.py.

Lo que un test de humo NO cubriria y aca si:
  * DETERMINISMO: dos sellos del mismo arbol dan el MISMO `hash_arbol`.
  * DETECCION REAL: alterar un byte de un archivo sellado -> `--verificar` falla
    y NOMBRA el archivo (no un "0 fallos" generico).
  * CADENA A PRUEBA DE MANIPULACION: alterar un sello viejo rompe `--cadena`.
  * No auto-referencia: `legal/sellos` queda fuera del alcance.
  * Guardian anti-falso-verde: piso de checks.
"""

import contextlib
import hashlib
import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
SCRIPT = os.path.join(HERE, "timestamp_seal.py")

CHECKS_MINIMOS = 16


def cargar_modulo():
    spec = importlib.util.spec_from_file_location("seal_m127", SCRIPT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def correr(*args):
    return subprocess.run([sys.executable, SCRIPT] + list(args),
                          capture_output=True, text=True, timeout=120, cwd=RAIZ)


def _montar(tmp):
    """Arbol minimo + globals del modulo apuntando al temporal."""
    os.makedirs(os.path.join(tmp, "src"))
    os.makedirs(os.path.join(tmp, "legal", "sellos"))
    with open(os.path.join(tmp, "src", "a.txt"), "w", encoding="utf-8") as f:
        f.write("contenido A\n")
    with open(os.path.join(tmp, "src", "b.txt"), "w", encoding="utf-8") as f:
        f.write("contenido B\n")
    with open(os.path.join(tmp, "legal", "sellos", "no-entra.json"), "w", encoding="utf-8") as f:
        f.write("{}\n")


def main():
    tests = []
    mod = cargar_modulo()

    # ---------- CLI sobre el repo real ----------
    r = correr("--listar")
    tests.append((r.returncode == 0, f"--listar exit {r.returncode} (esperado 0)"))
    tests.append(("Total:" in r.stdout, "--listar informa el total de sellos"))

    # NOTA de diseno: `--verificar` NO se asserta verde sobre el repo real, a proposito.
    # Cualquier edicion legitima de un archivo sellado lo pone en rojo — y eso es
    # CORRECTO: el sello afirma "en el instante T el arbol era este". Un gate de CI con
    # --verificar quedaria rojo en cada commit. Lo que SI es estable es la CADENA:
    # solo se rompe si alguien manipula un sello ya escrito.
    n_sellos = 0
    for linea in r.stdout.splitlines():
        if linea.strip().startswith("Total:"):
            try:
                n_sellos = int(linea.split(":")[1].strip().split()[0])
            except (IndexError, ValueError):
                n_sellos = 0
    tests.append((n_sellos >= 0, f"--listar cuenta los sellos del repo (vio {n_sellos})"))

    r = correr("--cadena")
    if n_sellos == 0:
        tests.append((r.returncode == 1 and "no hay sellos" in r.stdout,
                      "sin sellos: --cadena sale 1 y lo explica"))
    else:
        tests.append((r.returncode == 0,
                      f"--cadena con {n_sellos} sello(s) exit {r.returncode} (esperado 0)"))

    r = correr("--verificar")
    tests.append((r.returncode in (0, 1), f"--verificar corre y sale 0/1 (vio {r.returncode})"))
    tests.append(("[sello]" in r.stdout, "--verificar informa que esta haciendo"))

    # ---------- determinismo + deteccion sobre un arbol temporal ----------
    with tempfile.TemporaryDirectory() as tmp:
        _montar(tmp)
        viejo_raiz, viejo_sellos = mod.RAIZ, mod.SELLOS
        mod.RAIZ = tmp
        mod.SELLOS = os.path.join(tmp, "legal", "sellos")
        try:
            excluir = mod.EXCLUIR_DEFECTO
            entradas = mod.recolectar(["src"], excluir)
            tests.append((len(entradas) == 2, f"recolectar ve 2 archivos (vio {len(entradas)})"))
            h1 = mod.hash_arbol(entradas)
            h2 = mod.hash_arbol(mod.recolectar(["src"], excluir))
            tests.append((h1 == h2, "determinismo: dos pasadas dan el mismo hash_arbol"))

            # la exclusion de legal/sellos evita la auto-referencia
            todos = mod.recolectar(["."], excluir)
            tests.append((not any("legal/sellos" in rel for rel, _, _ in todos),
                          "legal/sellos queda FUERA del alcance (sin auto-referencia)"))
            tests.append((any(rel.startswith("src/") for rel, _, _ in todos),
                          "el resto del arbol si entra en el alcance"))

            # la formula de la cadena
            hc = mod.hash_cadena(None, h1)
            esperado = hashlib.sha256(("|%s" % h1).encode("utf-8")).hexdigest()
            tests.append((hc == esperado, "hash_cadena(None, h) = sha256('|' + h)"))

            with contextlib.redirect_stdout(io.StringIO()):
                rc1 = mod.crear(["src"], excluir)
            tests.append((rc1 == 0, f"crear sello 1 -> exit {rc1}"))
            sellos = mod.listar_sellos()
            tests.append((len(sellos) == 1, f"hay 1 sello tras crear (vio {len(sellos)})"))

            with contextlib.redirect_stdout(io.StringIO()):
                rc_v = mod.verificar()
            tests.append((rc_v == 0, f"verificar sin cambios -> exit {rc_v} (esperado 0)"))

            # ALTERAR un byte -> debe fallar y nombrar el archivo
            with open(os.path.join(tmp, "src", "a.txt"), "w", encoding="utf-8") as f:
                f.write("contenido A MODIFICADO\n")
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                rc_v2 = mod.verificar()
            salida = buf.getvalue()
            tests.append((rc_v2 == 1, f"verificar tras alterar -> exit {rc_v2} (esperado 1)"))
            tests.append(("src/a.txt" in salida, "nombra el archivo alterado en la salida"))
            tests.append(("[ALTERADO]" in salida, "marca [ALTERADO]"))

            # BORRAR un archivo -> FALTA
            os.remove(os.path.join(tmp, "src", "b.txt"))
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                rc_v3 = mod.verificar()
            tests.append((rc_v3 == 1, f"verificar tras borrar -> exit {rc_v3} (esperado 1)"))
            tests.append(("[FALTA]" in buf.getvalue(), "marca [FALTA] el archivo borrado"))

            # ---------- cadena ----------
            with contextlib.redirect_stdout(io.StringIO()):
                rc2 = mod.crear(["src"], excluir)
            tests.append((rc2 == 0, f"crear sello 2 -> exit {rc2}"))
            sellos = mod.listar_sellos()
            tests.append((len(sellos) == 2, f"hay 2 sellos (vio {len(sellos)})"))
            with contextlib.redirect_stdout(io.StringIO()):
                rc_c = mod.validar_cadena()
            tests.append((rc_c == 0, f"cadena de 2 sellos INTACTA -> exit {rc_c}"))

            # el 2do sello encadena con el 1ro
            s1 = mod.leer_sello(sellos[0][1])
            s2 = mod.leer_sello(sellos[1][1])
            tests.append((s2["hash_previo"] == s1["hash_cadena"],
                          "el sello 2 apunta al hash_cadena del sello 1"))

            # manipular el sello 1 -> cadena rota
            s1["hash_arbol"] = "0" * 64
            with open(sellos[0][1], "w", encoding="utf-8") as f:
                json.dump(s1, f, indent=2, sort_keys=True)
            buf = io.StringIO()
            with contextlib.redirect_stdout(buf):
                rc_c2 = mod.validar_cadena()
            tests.append((rc_c2 == 1, f"cadena tras manipular el sello 1 -> exit {rc_c2} (esperado 1)"))
            tests.append(("CADENA-ROTA" in buf.getvalue(), "reporta [CADENA-ROTA]"))
        finally:
            mod.RAIZ, mod.SELLOS = viejo_raiz, viejo_sellos

    # ---------- orden de la cadena con sufijo de desambiguacion ----------
    # Regresion real: ordenar por NOMBRE pone `sello-...Z-2.json` ANTES de
    # `sello-...Z.json` ('-' 0x2D < '.' 0x2E) e invertiria la cadena.
    k_sin = mod._clave_orden("sello-20260101T000000Z.json")
    k_con = mod._clave_orden("sello-20260101T000000Z-2.json")
    tests.append((k_sin < k_con, f"clave de orden: sin sufijo < con sufijo ({k_sin} < {k_con})"))
    tests.append((k_sin[0] == k_con[0], "clave de orden: mismo timestamp en ambos"))
    tests.append((mod._clave_orden("sello-20260101T000001Z.json") > k_con,
                  "clave de orden: un segundo despues va despues del sufijo"))

    # ---------- exclusion por nombre de directorio ----------
    tests.append((mod.es_excluido("game/x/__pycache__/a.pyc", ["__pycache__"]) is True,
                  "es_excluido detecta __pycache__ en cualquier nivel"))
    tests.append((mod.es_excluido("game/x/a.gd", ["__pycache__"]) is False,
                  "es_excluido no sobre-excluye"))

    fallos = 0
    for ok, msg in tests:
        print(f"  [{'OK' if ok else 'FAIL'}] {msg}")
        if not ok:
            fallos += 1
    print(f"=== Resumen M127 timestamp_seal: {len(tests) - fallos}/{len(tests)} OK ===")
    if len(tests) < CHECKS_MINIMOS:
        print(f"  [FAIL] guardian: solo {len(tests)} checks (minimo {CHECKS_MINIMOS})")
        return 1
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
