#!/usr/bin/env python3
# Copyright (c) 2026 Isla Ancestral Team. Todos los derechos reservados.
# SPDX-License-Identifier: LicenseRef-Propietaria
# Este archivo es parte de "Isla Ancestral". Ver LICENSE en la raiz.
# -*- coding: utf-8 -*-
"""Format strings de GDScript que tiran ERROR en runtime y no rompen la suite.

Motivo (2026-11-25, Deepseek V4.1 Flash-DeepAI): al correr el gate completo, 24
suites imprimian errores y salian con exit 0. Uno de esos errores era real y
silencioso:

    _check(p0 >= 0.02, "piso 2% al iniciar cola (%.2f)" % p0)

El `% a` de `2% al` no es un especificador valido, asi que Godot imprime
`ERROR: String formatting error: unsupported format character.` y la cadena
sale vacia. La suite sigue en VERDE porque el booleano del check se evalua
igual: el defecto queda tapado y, si el check falla, el mensaje de diagnostico
tambien se pierde. En `test_stream.gd:81` y `:94` llevaba ahi desde la version
inicial (2 errores por corrida).

Este detector mira SOLO literales que son operando de `%` (formateo real): un
`%` suelto en un print sin formatear no es un bug. Valida los especificadores
siguiendo la sintaxis de Godot (`%[flags][ancho][.precision]<conv>`), donde las
conversiones validas son `s d f x X o c v e E %`.

Uso:
    python tools/quality/detectar_format_invalido.py
    python tools/quality/detectar_format_invalido.py --check   # exit 1 si hay hallazgos

Exit codes: 0 = sin hallazgos; 1 = hay especificadores invalidos (modo --check);
2 = no se encontro el proyecto.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path
from typing import List, Tuple

PROYECTO = Path(__file__).resolve().parents[2] / "game" / "isla-ancestral"

CONVERSIONES = set("sdfxXocveE%")
FLAGS = set("-+ 0#")
LITERAL = re.compile(r'"(?:[^"\\]|\\.)*"')


def _es_formateo(texto: str, fin_literal: int) -> bool:
    """True si el literal que termina en `fin_literal` es operando de `%`."""
    resto = texto[fin_literal:]
    # El argumento puede ser un array, un identificador, una llamada o un literal
    # numerico (`% 0.5`): con solo `[A-Za-z_(]` se escapaban los casos reales.
    m = re.match(r"\s*%\s*\S", resto)
    return bool(m)


def especificadores_invalidos(literal: str) -> List[str]:
    """Devuelve los especificadores `%` invalidos del literal (sin las comillas)."""
    s = literal
    malos: List[str] = []
    i = 0
    while i < len(s):
        if s[i] != "%":
            i += 1
            continue
        ini = i
        j = i + 1
        while j < len(s) and s[j] in FLAGS:
            j += 1
        while j < len(s) and s[j].isdigit():
            j += 1
        if j < len(s) and s[j] == ".":
            j += 1
            while j < len(s) and s[j].isdigit():
                j += 1
        if j >= len(s):
            break
        c = s[j]
        if not (c.isalpha() or c == "%"):
            i = j + 1
            continue
        if c not in CONVERSIONES:
            malos.append(s[ini : j + 1])
        i = j + 1
    return malos


def escanear(raiz: Path) -> Tuple[int, List[Tuple[str, int, str, str]]]:
    archivos = 0
    hallazgos: List[Tuple[str, int, str, str]] = []
    for p in sorted(raiz.rglob("*.gd")):
        if "addons" in p.parts:
            continue
        try:
            texto = p.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        archivos += 1
        for lit in LITERAL.finditer(texto):
            if not _es_formateo(texto, lit.end()):
                continue
            contenido = lit.group(0)[1:-1]
            malos = especificadores_invalidos(contenido)
            if malos:
                linea = texto.count("\n", 0, lit.start()) + 1
                rel = str(p.relative_to(raiz)).replace("\\", "/")
                hallazgos.append((rel, linea, lit.group(0)[:90], ", ".join(malos)))
    return archivos, hallazgos


def main(argv: List[str]) -> int:
    ap = argparse.ArgumentParser(description="Detecta format strings invalidos en GDScript")
    ap.add_argument("--check", action="store_true", help="exit 1 si hay hallazgos")
    args = ap.parse_args(argv)

    if not PROYECTO.is_dir():
        print(f"[format] no se encontro el proyecto: {PROYECTO}", file=sys.stderr)
        return 2

    archivos, hallazgos = escanear(PROYECTO)
    print(f"[format] {archivos} archivos .gd revisados (addons/ excluido)")
    if not hallazgos:
        print("[format] OK: ningun especificador invalido en literales formateados.")
        return 0
    for rel, linea, lit, malos in hallazgos:
        print(f"[format] {rel}:{linea}  especificador(es) {malos}  en {lit}")
    print(f"[format] {len(hallazgos)} hallazgo(s). Escapar el % literal como %% (p.ej. '2%% al 100').")
    return 1 if args.check else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))