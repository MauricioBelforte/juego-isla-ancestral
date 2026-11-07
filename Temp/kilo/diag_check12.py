# -*- coding: utf-8 -*-
"""Diagnosticar FAIL check 12: ¿detector no-determinista (muestras) o drift real?
Corre el detector 2 veces + compara contra snapshots v42/v43 guardados."""
import io, os, subprocess, re

RAIZ = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
def rd(p):
    return io.open(p, encoding=u"utf-8", errors=u"replace").read()
def nonblank(s):
    return set(l for l in s.split(u"\n") if l.strip())

def correr(tag):
    r = subprocess.run([u"python", u"-X", u"utf8", u"scripts/detectar_autocontradiccion.py"],
                       cwd=RAIZ, capture_output=True)
    out = r.stdout.decode(u"utf-8", u"replace")
    with io.open(RAIZ + u"\\Temp\\kilo\\diag_%s.txt" % tag, u"w", encoding=u"utf-8", newline=u"\n") as f:
        f.write(out)
    return out

c1 = correr(u"run1")
c2 = correr(u"run2")
v42 = rd(RAIZ + u"\\Temp\\kilo\\v42_detector_delta.txt")
v43 = rd(RAIZ + u"\\Temp\\kilo\\v43_detector.txt")

print(u"lineas totales: run1=%d run2=%d v42file=%d v43file=%d" % (
    len(c1.split(u"\n")), len(c2.split(u"\n")), len(v42.split(u"\n")), len(v43.split(u"\n"))))
print(u"nonblank sets: run1=%d run2=%d v42=%d v43=%d" % (
    len(nonblank(c1)), len(nonblank(c2)), len(nonblank(v42)), len(nonblank(v43))))

d12 = nonblank(c1) ^ nonblank(c2)
print(u"")
print(u"== determinismo run1 vs run2: diff=%d ==" % len(d12))
for l in sorted(d12)[:6]:
    print(u"   ", l[:150])

d13 = nonblank(c1) ^ nonblank(v43)
print(u"== run1 vs v43 file: diff=%d ==" % len(d13))
for l in sorted(d13)[:6]:
    print(u"   ", l[:150])

RES = (u"checklists escaneados", u"A1-GRAVE", u"R4-GRAVE", u"ambas familias", u"A3-PENDIENTE", u"A2-DEUDA", u"C2-RESUELTO", u"JSON:", u"### ")
d14 = set(l for l in (nonblank(c1) - nonblank(v42)) if not l.startswith(RES))
d41 = set(l for l in (nonblank(v42) - nonblank(c1)) if not l.startswith(RES))
print(u"")
print(u"== run1 vs v42 file (excl resumen+por-modulo): nuevas=%d desaparecidas=%d ==" % (len(d14), len(d41)))
for l in sorted(d14)[:8]:
    print(u"  NUEVA:", l[:170])
for l in sorted(d41)[:8]:
    print(u"  VIEJA:", l[:170])

m = re.search(r"JSON:(\{.*\})", c1, re.S)
import json
dj = json.loads(m.group(1)) if m else {}
print(u"")
print(u"conteos run1:", {k: dj.get(k) for k in [u"items_x", u"A1", u"R4", u"A2", u"A3", u"C2", u"SOS", u"FP", u"F", u"GRIS", u"checklists"]})
m2 = re.search(r"JSON:(\{.*\})", c2, re.S)
dj2 = json.loads(m2.group(1)) if m2 else {}
print(u"conteos run2:", {k: dj2.get(k) for k in [u"items_x", u"A1", u"R4", u"checklists"]})
