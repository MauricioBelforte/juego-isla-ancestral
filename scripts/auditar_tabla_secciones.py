# -*- coding: utf-8 -*-
"""auditar_tabla_secciones.py — audita filas de una tabla markdown por SECCION.

A diferencia de un detector con header fijo, este descubre el header de cada
seccion y mide cada fila contra EL HEADER DE SU SECCION. Ese era el fallo del
detector original (msg 84): tomaba filas de datos como headers y por eso no veia
las filas huerfanas ni las de formato mezclado.

Criterios por fila de dato:
  1. pipes sin escapar != pipes del header de su seccion  -> rota
  2. no cierra con '|'                                     -> truncada
  3. primera celda no numerica                              -> no es fila de dato

Uso:
    python scripts/auditar_tabla_secciones.py <archivo.md>
    python scripts/auditar_tabla_secciones.py CHECKLIST-QA-SEALS.md --json

Modelo: stepfun-step-5-preview | Plataforma: Kilo Code | Fecha: 2026-10-11
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def pipes_sin_escapar(s: str) -> int:
    """Pipes que no estan escapados con backslash."""
    return len([i for i, c in enumerate(s) if c == "|" and (i == 0 or s[i - 1] != "\\")])


def es_separador(s: str) -> bool:
    return bool(s) and set(s) <= set("-|: ")


def auditar(path: str) -> dict:
    with open(path, encoding="utf-8") as fh:
        lineas = fh.read().split("\n")

    secciones = []          # (nombre, linea_header, pipes_header)
    problemas = []          # (linea, mid, pipes, pipes_header, cierra)
    filas_ok = 0
    header_actual = None    # (nombre, pipes)
    en_tabla = False

    for n, ln in enumerate(lineas, 1):
        s = ln.strip()
        if s.startswith("#"):
            if header_actual:
                secciones.append(header_actual)
            header_actual = None
            en_tabla = False
            continue
        if not s.startswith("|"):
            continue
        if es_separador(s):
            continue
        celdas = [c.strip() for c in s.strip("|").split("|")]

        # Â¿Es un header? Primera celda NO numerica y no vacia.
        es_dato = bool(celdas) and celdas[0].isdigit()
        if not es_dato:
            # Si no estamos en tabla, esta linea es el header de la seccion.
            if not en_tabla:
                header_actual = (s, pipes_sin_escapar(s))
                en_tabla = True
            continue

        if not en_tabla or header_actual is None:
            # Fila de dato que aparece ANTES del header de su propia seccion
            # (formato mezclado, ej. QA-SEALS L84-86 con 7 pipes antes del
            # header de 4 columnas). Se mide contra el header de la seccion
            # anterior solo como REFERENCIA, pero se reporta igual: el hecho de
            # que preceda a su propio header ya es la anomalia.
            if secciones:
                ref = secciones[-1][1]
                p = pipes_sin_escapar(s)
                problemas.append((n, celdas[0], p, -ref, s.endswith("|")))
            else:
                problemas.append((n, celdas[0], pipes_sin_escapar(s), 0, s.endswith("|")))
            continue

        p = pipes_sin_escapar(s)
        ref = header_actual[1]
        if p != ref or not s.endswith("|"):
            problemas.append((n, celdas[0], p, ref, s.endswith("|")))
        else:
            filas_ok += 1

    if header_actual:
        secciones.append(header_actual)

    return {
        "archivo": os.path.relpath(path, RAIZ).replace("\\", "/"),
        "secciones": [{"header": h[:70], "pipes": p} for h, p in secciones],
        "filas_ok": filas_ok,
        "problemas": [
            {"linea": n, "mid": m, "pipes": p, "pipes_header": ph, "cierra": c}
            for n, m, p, ph, c in problemas
        ],
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Audita tablas markdown por seccion")
    ap.add_argument("archivo", help="ruta del .md a auditar (relativa o absoluta)")
    ap.add_argument("--json", action="store_true", help="salida en JSON")
    args = ap.parse_args()

    path = args.archivo
    if not os.path.isfile(path):
        cand = os.path.join(RAIZ, args.archivo)
        path = cand if os.path.isfile(cand) else path
    if not os.path.isfile(path):
        print("No existe: %s" % args.archivo)
        return 2

    r = auditar(path)
    if args.json:
        print(json.dumps(r, ensure_ascii=False, indent=2))
        return 1 if r["problemas"] else 0

    print("Archivo : %s" % r["archivo"])
    print("Secciones detectadas: %d" % len(r["secciones"]))
    for s in r["secciones"]:
        print("   [%d pipes] %s" % (s["pipes"], s["header"]))
    print("Filas OK: %d" % r["filas_ok"])
    if not r["problemas"]:
        print("SIN PROBLEMAS")
        return 0
    print("PROBLEMAS: %d" % len(r["problemas"]))
    for p in r["problemas"]:
        ph = p["pipes_header"]
        if ph == 0:
            ref = "sin header"
        elif ph < 0:
            ref = "antes de su header (ref %d)" % (-ph)
        else:
            ref = str(ph)
        print("   L%-4d MID=%-6s pipes=%-3d (header %s) cierra=%s"
              % (p["linea"], p["mid"], p["pipes"], ref, p["cierra"]))
    return 1


if __name__ == "__main__":
    sys.exit(main())
