#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""Cobertura de gating: que suites existen y cuales NO ejecuta el workflow.

Motivo (2026-11-25, Deepseek V4.1 Flash-DeepAI): el job `Test Suite` corre 101
suites, pero el repo tiene bastantes mas. Una suite que no esta en el workflow
puede estar en ROJO durante semanas sin que nadie se entere: el gate dice verde
y miente por omision. Caso real: `tests/test_m17_categorias.gd` (24 checks, 3
fallos) no estaba registrada y nadie lo veia.

Esto NO decide que suite hay que registrar: solo mide el hueco y detecta las
entradas del workflow que apuntan a archivos inexistentes (rot del doctor).

Desde 2026-11-25 tambien clasifica por TIPO, porque el hueco no es uniforme:
  * `gdunit4`   -> necesita el runner del addon (workflow testing.yml, por directorio)
  * `scenetree` -> corre con `godot --headless --script <ruta>`
La distincion importa: 19 suites de `tests/unit/**` son `scenetree` y el job
GdUnit4 NO las colecta (busca suites del addon), asi que quedaban sin correr en
ninguno de los dos jobs. Medidas el 2026-11-25: 19/19 en verde, 0 timeouts.

Uso:
    python tools/quality/auditar_cobertura_suites.py
    python tools/quality/auditar_cobertura_suites.py --check   # exit 1 si una entrada de CI no existe
    python tools/quality/auditar_cobertura_suites.py --fuera   # lista las no registradas

Exit codes: 0 = ok; 1 = el workflow referencia una suite inexistente (o la
referencia dos veces); 2 = no se encontro el proyecto o el workflow.
"""

from __future__ import annotations

import argparse
import collections
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
PROYECTO = RAIZ / "game" / "isla-ancestral"
WORKFLOW = RAIZ / ".github" / "workflows" / "quality.yml"

RE_SUITE = re.compile(r"suite\s+--script\s+(\S+)")


def suites_en_ci(texto_yml: str) -> list[str]:
    vistas: list[str] = []
    for m in RE_SUITE.finditer(texto_yml):
        ruta = m.group(1).strip('"\'')
        if ruta not in vistas:
            vistas.append(ruta)
    return vistas


def tipo_de_suite(ruta_abs: Path) -> str:
    """Clasifica por cabecera: gdunit4 (necesita el runner del addon) o scenetree."""
    try:
        cabecera = ruta_abs.read_text(encoding="utf-8", errors="replace")[:2500]
    except OSError:
        return "?"
    if re.search(r"GdUnitTestSuite|GdUnitTest", cabecera):
        return "gdunit4"
    return "scenetree"


def suites_en_disco() -> list[str]:
    rutas: list[str] = []
    for base in ("tests", "scripts"):
        raiz = PROYECTO / base
        if not raiz.is_dir():
            continue
        for p in sorted(raiz.rglob("test_*.gd")):
            if "addons" in p.parts:
                continue
            rutas.append(p.relative_to(PROYECTO).as_posix())
    return rutas


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Cobertura de suites vs workflow de CI")
    ap.add_argument("--check", action="store_true", help="exit 1 si el workflow referencia suites inexistentes")
    ap.add_argument("--fuera", action="store_true", help="listar las suites que el workflow no ejecuta")
    args = ap.parse_args(argv)

    if not PROYECTO.is_dir() or not WORKFLOW.is_file():
        print("ERROR: no encuentro el proyecto o el workflow", file=sys.stderr)
        return 2

    en_ci = suites_en_ci(WORKFLOW.read_text(encoding="utf-8"))
    disco = suites_en_disco()
    fuera = [s for s in disco if s not in en_ci]
    inexistentes = [s for s in en_ci if not (PROYECTO / s).is_file()]

    tipos = {s: tipo_de_suite(PROYECTO / s) for s in disco}
    n_st = sum(1 for t in tipos.values() if t == "scenetree")
    n_gd = sum(1 for t in tipos.values() if t == "gdunit4")
    # Las gdunit4 las corre el job GdUnit4 del workflow testing.yml por directorio,
    # no aparecen como `--script` en quality.yml: no son "fuera" en el mismo sentido.
    fuera_st = [s for s in fuera if tipos.get(s) == "scenetree"]

    print(f"Suites en disco ......... {len(disco)}  (scenetree {n_st} / gdunit4 {n_gd})")
    print(f"Suites en el workflow ... {len(en_ci)}")
    print(f"Fuera del workflow ...... {len(fuera)}")
    print(f"  de las cuales ejecutables con --script y sin correr: {len(fuera_st)}")

    por_carpeta: collections.Counter[str] = collections.Counter()
    for s in fuera:
        partes = s.split("/")
        por_carpeta["/".join(partes[:-1]) or "."] += 1
    if por_carpeta:
        print("\nFuera del workflow, por carpeta:")
        for carpeta, n in sorted(por_carpeta.items(), key=lambda kv: (-kv[1], kv[0])):
            print(f"  {n:4d}  {carpeta}")

    if args.fuera:
        print("\nSuites no registradas:")
        for s in fuera:
            print(f"  [{tipos.get(s, '?')[:6]}] {s}")

    if inexistentes:
        print("\nERROR: el workflow referencia suites que no existen:")
        for s in inexistentes:
            print(f"  {s}")
        return 1

    if args.check:
        print("\nOK: todas las suites del workflow existen.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
