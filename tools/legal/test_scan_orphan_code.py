#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""M127 iter. 3 -- Test de tools/legal/scan_orphan_code.py.

Las 3 clases de huerfano se prueban sobre un repo git TEMPORAL de verdad, porque
la deteccion depende de `git ls-files` y de `git log`: mockearlas no probaria nada.
  * SIN_HISTORIAL     -> archivo no trackeado.
  * SIN_CABECERA      -> trackeado pero sin cabecera de copyright.
  * AUTOR_PLACEHOLDER -> commit con autor "unknown".
Y el caso limpio (trackeado + cabecera + autor real) NO debe aparecer.
"""

import importlib.util
import json
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(HERE, "..", ".."))
SCRIPT = os.path.join(HERE, "scan_orphan_code.py")

CHECKS_MINIMOS = 14
HDR = "# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.\n# SPDX-License-Identifier: LicenseRef-Propietaria\n"


def cargar_modulo():
    spec = importlib.util.spec_from_file_location("scan_m127", SCRIPT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def correr(*args):
    return subprocess.run([sys.executable, SCRIPT] + list(args),
                          capture_output=True, text=True, timeout=180, cwd=RAIZ)


def git(*args, cwd):
    return subprocess.run(["git"] + list(args), capture_output=True, text=True,
                          timeout=60, cwd=cwd)


def escribir(ruta, texto):
    with open(ruta, "w", encoding="utf-8") as f:
        f.write(texto)


def main():
    tests = []
    mod = cargar_modulo()

    # ---------- CLI sobre el repo real (sin assertear un exit concreto) ----------
    r = correr("--json")
    tests.append((r.returncode in (0, 1), f"--json corre y sale 0/1 (vio {r.returncode})"))
    try:
        data = json.loads(r.stdout)
        tests.append(("hallazgos" in data, "--json trae la clave 'hallazgos'"))
        tests.append((data.get("en_alcance", 0) >= 10, f"--json informa el alcance ({data.get('en_alcance')})"))
        tests.append((set(data["hallazgos"]) == {"sin_historial", "sin_cabecera", "autor_placeholder"},
                      "las 3 clases de hallazgo estan declaradas"))
    except json.JSONDecodeError as e:
        tests.append((False, f"--json produce JSON valido: {e}"))

    r = correr("--detalle")
    tests.append((r.returncode in (0, 1), f"--detalle corre y sale 0/1 (vio {r.returncode})"))
    tests.append(("trackeado=" in r.stdout, "--detalle muestra trackeado/cabecera/autores"))

    # ---------- repo git temporal ----------
    with tempfile.TemporaryDirectory() as tmp:
        git("init", "-q", cwd=tmp)
        os.makedirs(os.path.join(tmp, "src"))
        os.makedirs(os.path.join(tmp, "src", "vendor"))
        # limpio: trackeado + cabecera + autor real
        escribir(os.path.join(tmp, "src", "limpio.py"), HDR + "x = 1\n")
        # sin cabecera: trackeado, autor real
        escribir(os.path.join(tmp, "src", "sin_cabecera.py"), "y = 2\n")
        # autor placeholder: trackeado con autor 'unknown'
        escribir(os.path.join(tmp, "src", "placeholder.py"), HDR + "z = 3\n")
        # excluido por manifiesto
        escribir(os.path.join(tmp, "src", "vendor", "v.py"), HDR + "w = 4\n")
        # fuera de extension
        escribir(os.path.join(tmp, "src", "nota.md"), "# nota\n")
        git("add", "src/vendor/v.py", "src/nota.md", cwd=tmp)
        git("-c", "user.name=Real Dev", "-c", "user.email=real@example.com",
            "commit", "-q", "-m", "vendor + nota", cwd=tmp)
        git("add", "src/limpio.py", "src/sin_cabecera.py", cwd=tmp)
        git("-c", "user.name=Real Dev", "-c", "user.email=real@example.com",
            "commit", "-q", "-m", "limpio + sin cabecera", cwd=tmp)
        git("add", "src/placeholder.py", cwd=tmp)
        git("-c", "user.name=unknown", "-c", "user.email=unknown@example.com",
            "commit", "-q", "-m", "placeholder", cwd=tmp)
        # sin historial: queda sin trackear
        escribir(os.path.join(tmp, "src", "huerfano.py"), "nuevo = True\n")

        viejo_raiz = mod.RAIZ
        mod.RAIZ = tmp
        viejo_alcance = mod.cargar_alcance
        mod.cargar_alcance = lambda: ([".py"], ["src"], ["vendor"])
        try:
            archivos, hallazgos, detalle = mod.escanear()
        finally:
            mod.RAIZ = viejo_raiz
            mod.cargar_alcance = viejo_alcance

        tests.append(("src/limpio.py" in archivos, "el archivo limpio entra en el alcance"))
        tests.append(("src/nota.md" not in archivos, "la extension fuera del alcance queda fuera"))
        tests.append(("src/vendor/v.py" not in archivos, "el directorio excluido queda fuera"))

        tests.append((hallazgos["sin_historial"] == ["src/huerfano.py"],
                      f"SIN_HISTORIAL detecta el no trackeado: {hallazgos['sin_historial']}"))
        tests.append((hallazgos["sin_cabecera"] == ["src/huerfano.py", "src/sin_cabecera.py"],
                      f"SIN_CABECERA detecta los que no la llevan: {hallazgos['sin_cabecera']}"))
        tests.append((hallazgos["autor_placeholder"] == ["src/placeholder.py"],
                      f"AUTOR_PLACEHOLDER detecta el commit 'unknown': {hallazgos['autor_placeholder']}"))
        tests.append(("src/limpio.py" not in hallazgos["sin_historial"]
                      and "src/limpio.py" not in hallazgos["sin_cabecera"]
                      and "src/limpio.py" not in hallazgos["autor_placeholder"],
                      "el archivo limpio NO aparece en ninguna clase (sin falsos positivos)"))

        reg = {d["ruta"]: d for d in detalle}
        tests.append((reg["src/limpio.py"]["autores"] == ["Real Dev"],
                      f"mapa de autores correcto: {reg['src/limpio.py']['autores']}"))
        tests.append((reg["src/limpio.py"]["trackeado"] is True, "marca trackeado=True en el limpio"))
        tests.append((reg["src/huerfano.py"]["trackeado"] is False, "marca trackeado=False en el huerfano"))

    # ---------- helpers ----------
    tests.append((mod.tiene_cabecera(os.path.join(RAIZ, "tools", "legal", "signoff_check.py")) is True,
                  "tiene_cabecera=True en un archivo ya cabecereado"))
    tests.append((mod.es_excluido("a/vendor/b.py", ["vendor"]) is True, "es_excluido por directorio"))
    tests.append((mod.es_excluido("a/b.py", ["vendor"]) is False, "es_excluido no sobre-excluye"))

    fallos = 0
    for ok, msg in tests:
        print(f"  [{'OK' if ok else 'FAIL'}] {msg}")
        if not ok:
            fallos += 1
    print(f"=== Resumen M127 scan_orphan_code: {len(tests) - fallos}/{len(tests)} OK ===")
    if len(tests) < CHECKS_MINIMOS:
        print(f"  [FAIL] guardian: solo {len(tests)} checks (minimo {CHECKS_MINIMOS})")
        return 1
    return 1 if fallos > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
