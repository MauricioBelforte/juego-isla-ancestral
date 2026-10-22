#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
#
# M102-Bug-Tracking / Log 2120 (DeepSeek-V4.1-Flash, 2026-10-22)
#
#   python scripts/probar_gate_metricas.py
#
# QUE PRUEBA
# ----------
# Que el gate `metricas_bugs.py --check` DISCRIMINA sobre el registro REAL:
# inyecta UN defecto nuevo en una COPIA de `DOCUMENTACION/11-BUGS.md`, exige
# que el gate se ponga ROJO nombrando ese defecto, y exige que el registro real
# quede BYTE A BYTE igual (sha256 antes == despues).
#
# POR QUE SOBRE UNA COPIA Y NO EDITANDO EL REGISTRO
# ------------------------------------------------
# El worktree es COMPARTIDO con otros agentes: escribir y restaurar el registro
# real abre una ventana en la que otro proceso lo lee a medias, y un corte de
# energia en esa ventana deja el registro corrupto. La copia da la misma
# evidencia (el contenido inyectado es el registro real + 1 fila) sin esa
# ventana. La restauracion byte-exacta se sigue verificando, y de la forma mas
# fuerte posible: el archivo real NUNCA se toca, y su sha256 se compara.
#
# Un "0 defectos" no se hereda: si el gate no se pone rojo ante una inyeccion,
# es un detector muerto y su verde no vale nada.

import hashlib
import io
import os
import shutil
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "scripts"))

import metricas_bugs as mod  # noqa: E402

REGISTRO = RAIZ / "DOCUMENTACION" / "11-BUGS.md"

# Fila sintetica: un id que NO existe en el registro, con la forma exacta de una
# fila valida. Si el parser la lee, la tabla tendra un id sin entrada canonica
# -> `fila_sin_entrada:BUG-999` -> firma NUEVA fuera de DEUDA_CONOCIDA.
FILA_INYECTADA = ("| BUG-999 | Fila inyectada por la sonda del gate (M102) | M102 | "
                  "\U0001F7E1 Menor | [ ] Abierto | sonda | 2026-10-22 |\n")

PASS = 0
FAIL = 0


def check(cond, desc):
    global PASS, FAIL
    if cond:
        PASS += 1
        print("  [OK]   %s" % desc)
    else:
        FAIL += 1
        print("  [FALLO] %s" % desc)


def sha256(ruta):
    return hashlib.sha256(io.open(ruta, "rb").read()).hexdigest()


def main():
    print("=" * 68)
    print("SONDA — gate de metricas_bugs.py probado EN ROJO por inyeccion")
    print("=" * 68)
    print()

    if not REGISTRO.is_file():
        print("  [FALLO] no existe %s" % REGISTRO)
        return 1

    hash_antes = sha256(REGISTRO)
    crudo = io.open(REGISTRO, "rb").read()
    check(not crudo.startswith(b"\xef\xbb\xbf"), "el registro real no lleva BOM")

    tmp = tempfile.mkdtemp(prefix="sonda_gate_")
    try:
        # --- copia SIN inyectar: control negativo ---
        limpia = os.path.join(tmp, "sin_inyectar.md")
        shutil.copyfile(str(REGISTRO), limpia)
        d0 = mod.leer_registro(limpia, None)
        check(d0["ciego"] is None, "la copia se lee (no es ciega): %s" % d0["ciego"])
        codigo0, lineas0 = mod._gate(d0)
        check(codigo0 == 0,
              "copia SIN inyectar -> gate VERDE (exit %d): el rojo de abajo no es del copiado"
              % codigo0)

        # --- copia CON la fila inyectada: tiene que ponerse ROJA ---
        texto = crudo.decode("utf-8")
        lineas = texto.split("\n")
        destino = None
        # OJO: el registro tiene tablas ANTES de la seccion 5 (plantillas de
        # entrada). Hay que anclar en el separador que sigue al encabezado de la
        # tabla resumen, no en el primer "|----" del archivo: si no, la fila cae
        # fuera del rango que el parser lee y la sonda "pasa" sin inyectar nada.
        seccion = None
        for i, l in enumerate(lineas):
            if l.startswith("## 5."):
                seccion = i
                break
        if seccion is not None:
            for i in range(seccion, len(lineas)):
                if lineas[i].startswith("|----"):
                    destino = i + 1
                    break
        if destino is None:
            print("  [FALLO] no se encontro el separador de la tabla resumen")
            return 1
        lineas.insert(destino, FILA_INYECTADA.rstrip("\n"))
        inyectada = os.path.join(tmp, "inyectada.md")
        io.open(inyectada, "wb").write("\n".join(lineas).encode("utf-8"))

        d1 = mod.leer_registro(inyectada, None)
        codigo1, lineas1 = mod._gate(d1)
        texto1 = "\n".join(lineas1)

        check(codigo1 == 1, "con 1 defecto inyectado -> gate ROJO (exit %d, esperado 1)" % codigo1)
        check("GATE ROJO" in texto1, "el veredicto dice GATE ROJO")
        check("BUG-999" in texto1, "el veredicto NOMBRA el bug inyectado (BUG-999)")
        check("fila_sin_entrada:BUG-999" in texto1,
              "el veredicto NOMBRA la firma exacta (fila_sin_entrada:BUG-999)")
        check("NUEVO" in texto1, "el veredicto distingue NUEVO de deuda conocida")

        # el defecto inyectado es UNO solo: la fila nueva no debe arrastrar otros
        tipos1 = d1["metricas"]["defectos_por_tipo"]
        tipos0 = d0["metricas"]["defectos_por_tipo"]
        delta = {k: tipos1.get(k, 0) - tipos0.get(k, 0) for k in set(tipos0) | set(tipos1)}
        delta = {k: v for k, v in delta.items() if v}
        check(delta == {"fila_sin_entrada": 1},
              "la inyeccion produce EXACTAMENTE 1 defecto nuevo, medido %s" % delta)

        # --- el registro real queda intacto ---
        check(sha256(REGISTRO) == hash_antes, "sha256 del registro real sin cambios")
        check("BUG-999" not in io.open(REGISTRO, encoding="utf-8").read(),
              "el registro real no tiene residuo de la inyeccion")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print()
    print("=" * 68)
    print("RESULTADO SONDA: %d OK, %d FALLO" % (PASS, FAIL))
    print("=" * 68)
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
