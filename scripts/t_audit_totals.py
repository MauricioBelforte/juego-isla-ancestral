# -*- coding: utf-8 -*-
import re, glob

def set_totales(rid, comps, nores):
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0]
    p = g + "/plan-actual/05-Checklist.md"
    c = open(p, "rb").read().decode("utf-8")
    # first Totales line: patch Completados + No resueltos
    lines = c.splitlines(keepends=True)
    for i, L in enumerate(lines):
        if "Totales:" in L:
            L2 = re.sub(r"Completados: \d+", "Completados: %d" % comps, L)
            L2 = re.sub(r"No resueltos: \d+", "No resueltos: %d" % nores, L2)
            lines[i] = L2
            break
    open(p, "w", encoding="utf-8", newline="").write("".join(lines))
    print("M%s Totales: Completados=%d No resueltos=%d" % (rid, comps, nores))

set_totales("77", 0, 4)
set_totales("45", 20, 2)

# GLOBAL rows
P = "CHECKLIST-GLOBAL.md"
c = open(P, "rb").read().decode("utf-8")
c = c.replace("| 77 | 77-Online-Y-Red | 🟡 Con dudas | 4/130 |", "| 77 | 77-Online-Y-Red | 🟡 Con dudas | 0/130 |")
c = c.replace("| 45 | 45-Arte-3D | 🟡 Con dudas | 22/171 |", "| 45 | 45-Arte-3D | 🟡 Con dudas | 20/171 |")
open(P, "w", encoding="utf-8", newline="").write(c)
gc = open(P, "rb").read()
print("GLOBAL CRLF=%d CR-suelto=%d NUL=%d" % (gc.count(b"\r\n"), gc.count(b"\r") - gc.count(b"\r\n"), gc.count(b"\x00")))
for pat in ["| 77 | 77-Online-Y-Red | 🟡 Con dudas | 0/130 |", "| 45 | 45-Arte-3D | 🟡 Con dudas | 20/171 |"]:
    print(pat, "->", pat in open(P,"rb").read().decode("utf-8"))
