# -*- coding: utf-8 -*-
"""SB-02: verificacion manual de los 16 'Totales que mienten'.

El script-automatico puede producir falsos positivos al parsear lineas de
Totales whose format is not the usual one (p.ej. '158 items (diseno A-M) +
21 items (implementacion N) = 179 items'). Este script reimprime, para cada
modulo marcado: (a) la linea TOTALES exacta, (b) el conteo real de marcas,
(c) la celda N/M de CHECKLIST-GLOBAL.md, para poder distinguir DRIFT REAL de
FALSO POSITIVO DEL PARSER.
"""
import io
import os
import re
import sys

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "..", "..", "..", ".."))
DOC = os.path.join(RAIZ, "DOCUMENTACION")
GLOBAL = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")

RE_ITEM = re.compile(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]")


def leer(p):
    with io.open(p, "r", encoding="utf-8", newline="") as f:
        return f.read()


def global_rows():
    t = leer(GLOBAL)
    out = {}
    for l in t.split("\n"):
        s = l.strip()
        if not s.startswith("|"):
            continue
        c = [x.strip() for x in s.split("|")[1:-1]]
        if c and re.match(r"^\d{1,3}$", c[0]):
            out[c[0]] = c
    return out


def main():
    mods = sys.argv[1:]
    g = global_rows()
    for mid in mods:
        d = None
        for x in sorted(os.listdir(DOC)):
            if x.split("-")[0] == mid:
                d = x
                break
        if d is None:
            print("!! modulo %s no encontrado" % mid)
            continue
        p = os.path.join(DOC, d, "plan-actual", "05-Checklist.md")
        t = leer(p)
        marcas = RE_ITEM.findall(t)
        x = sum(1 for m in marcas if m in ("x", "X"))
        q = sum(1 for m in marcas if m == "?")
        e = sum(1 for m in marcas if m == " ")
        print("=" * 92)
        print("M%s  %s" % (mid, d))
        print("  conteo REAL de marcas: [x]=%d  [?]=%d  [ ]=%d   -> total=%d"
              % (x, q, e, x + q + e))
        row = g.get(mid)
        if row:
            print("  CHECKLIST-GLOBAL fila: Progreso=%s  Estado=%s"
                  % (row[3], row[2][:44]))
        else:
            print("  CHECKLIST-GLOBAL: sin fila")
        print("  lineas 'Totales' en el archivo:")
        for m in re.finditer(r"(?mi)^\s*\*{0,2}Totales\*{0,2}\s*:.*$", t):
            ln = t[:m.start()].count("\n") + 1
            print("    L%-5d %s" % (ln, m.group(0).strip()[:150]))
        print()


if __name__ == "__main__":
    main()