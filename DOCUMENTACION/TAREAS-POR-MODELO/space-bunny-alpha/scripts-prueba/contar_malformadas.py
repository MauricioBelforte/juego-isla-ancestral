# -*- coding: utf-8 -*-
"""SB-02: por que el script principal cuenta 58 mal formadas y este 54.

Compara las dos convenciones de split y lista las filas donde discrepan.
"""
import io
import os
import re
import sys

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                     "..", "..", "..", ".."))
GLOBAL = os.path.join(RAIZ, "CHECKLIST-GLOBAL.md")


def main():
    with io.open(GLOBAL, "r", encoding="utf-8", newline="") as f:
        t = f.read()
    NCOL = 11
    a, b = {}, {}
    for i, l in enumerate(t.split("\n"), 1):
        s = l.strip()
        if not s.startswith("|"):
            continue
        # convencion A: partir_filas (quita el primero si vacio y el ultimo si vacio)
        partes = s.split("|")
        if partes and partes[0].strip() == "":
            partes = partes[1:]
        if partes and partes[-1].strip() == "":
            partes = partes[:-1]
        ca = [x.strip() for x in partes]
        # convencion B: split("|")[1:-1] (quita primero y ultimo siempre)
        cb = [x.strip() for x in s.split("|")[1:-1]]
        if not ca or not re.match(r"^\d{1,3}$", ca[0]):
            continue
        if len(ca) != NCOL:
            a[i] = (len(ca), ca)
        if len(cb) != NCOL:
            b[i] = (len(cb), cb)
    print("convencion A (partir_filas, quita extremos solo si vacios): %d mal formadas" % len(a))
    print("convencion B (split('|')[1:-1], quita extremos siempre)     : %d mal formadas" % len(b))
    solo_a = sorted(set(a) - set(b))
    solo_b = sorted(set(b) - set(a))
    print()
    print("solo en A (%d):" % len(solo_a))
    for i in solo_a:
        n, c = a[i]
        print("  L%-5d n=%d  ultima_celda_A=%r  (empieza=%r, termina=%r)"
              % (i, n, c[-1][:60],
                 t.split("\n")[i - 1].strip()[:14],
                 t.split("\n")[i - 1].strip()[-14:]))
    print()
    print("solo en B (%d):" % len(solo_b))
    for i in solo_b:
        n, c = b[i]
        print("  L%-5d n=%d" % (i, n))
    print()
    print("AMBAS (%d):" % len(set(a) & set(b)))


if __name__ == "__main__":
    main()