# -*- coding: utf-8 -*-
"""Diff detector v42 vs v43: identificar las lineas que cambiaron (flips post-v42)."""
import io, os

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()

a = rd(RAIZ + u"\\Temp\\kilo\\v42_detector_delta.txt").split(u"\n")
b = rd(RAIZ + u"\\Temp\\kilo\\v43_detector.txt").split(u"\n")
sa, sb = set(a), set(b)
new = [l for l in b if l not in sa]
gone = [l for l in a if l not in sb]
print(u"v42 lines=%d v43 lines=%d" % (len(a), len(b)))
print(u"--- NUEVAS en v43 (%d) ---" % len(new))
for l in new[:80]:
    print(l[:220])
print(u"--- ELIMINADAS de v42 (%d) ---" % len(gone))
for l in gone[:80]:
    print(l[:220])
