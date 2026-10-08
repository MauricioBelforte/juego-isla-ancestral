# -*- coding: utf-8 -*-
import re, os, glob
B = "DOCUMENTACION/120-DLC-Y-Expansiones/plan-actual"
# 04-Codigo file list
f = B + "/04-Codigo.md"
t = open(f, "rb").read().decode("utf-8", "replace")
files = set(re.findall(r"([A-Za-z0-9_./\\-]+\.(?:gd|json|tres|tscn))", t))
print("M120 04-Codigo cita %d archivos:" % len(files))
missing = []
for x in sorted(files):
    base = os.path.basename(x)
    hit = glob.glob("game/isla-ancestral/**/" + base, recursive=True)
    mark = "OK " if hit else "X  "
    if not hit:
        missing.append(x)
    print("  %s %s" % (mark, x))
print("--- AUSENTES (04-Codigo): %d ---" % len(missing), missing[:8])
# 07-Resultados
r = B + "/07-Resultados-Testings.md"
if os.path.exists(r):
    rt = open(r, "rb").read().decode("utf-8", "replace")
    exit_n = len(re.findall(r"EXIT", rt))
    print("M120 07-Resultados: %d lineas, %d menciones EXIT -> " % (len(rt.splitlines()), exit_n),
          "VACIO/TEMPLATE" if ("PENDIENTE" in rt and exit_n <= 6) else "con EXIT reales")
else:
    print("M120 07-Resultados: AUSENTE")
# 05-Checklist [x] that say Implement
c = open(B + "/05-Checklist.md", "rb").read().decode("utf-8")
imp = [m.group(1)[:48] for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines())
       if m and re.search(r"[Ii]mplement", m.group(1))]
print('M120 [x] "implementar": %d' % len(imp))
for x in imp[:4]:
    print("   -", x)
# the 59 [ ] pending sample
pend = [m.group(1)[:55] for m in (re.match(r"^\s*[-*]\s*\[ \]\s*(.*)", L) for L in c.splitlines()) if m]
print("M120 [ ] pendientes: %d (muestreo: %s)" % (len(pend), pend[:3]))
