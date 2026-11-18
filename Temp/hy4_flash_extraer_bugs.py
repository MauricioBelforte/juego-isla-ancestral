#!/usr/bin/env python3
"""Extrae del registro de bugs las entradas 042-062 con su titulo y cuerpo resumido."""
import re

RUTA = "DOCUMENTACION/11-BUGS.md"
lineas = open(RUTA, encoding="utf-8", errors="replace").read().split("\n")
ids = ["%03d" % n for n in range(42, 63)]
hdr = re.compile(r"^(#{2,4})\s+(?:BUG-)?(\d{3})\b")

entradas = []
for i, ln in enumerate(lineas):
    m = hdr.match(ln)
    if m and m.group(2) in ids:
        nivel = len(m.group(1))
        j = i + 1
        while j < len(lineas):
            m2 = hdr.match(lineas[j])
            if m2 and len(m2.group(1)) <= nivel:
                break
            j += 1
        entradas.append((m.group(2), i + 1, lineas[i:j]))

vistos = {}
for bug, lineno, cuerpo in entradas:
    vistos.setdefault(bug, []).append((lineno, cuerpo))

for bug in ids:
    if bug not in vistos:
        print("=" * 70)
        print("BUG-%s: SIN ENTRADA EN 11-BUGS.md" % bug)
        continue
    for k, (lineno, cuerpo) in enumerate(vistos[bug]):
        print("=" * 70)
        print("BUG-%s  entrada %d/%d  L%d  (%d lineas)" % (bug, k + 1, len(vistos[bug]), lineno, len(cuerpo)))
        for ln in cuerpo[:32]:
            print(ln[:240])
        if len(cuerpo) > 32:
            print("... [%d lineas mas]" % (len(cuerpo) - 32))
