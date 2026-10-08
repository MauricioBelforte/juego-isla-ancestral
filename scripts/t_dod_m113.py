# -*- coding: utf-8 -*-
import re, os, glob
B = "DOCUMENTACION/113-Pruebas-De-Stress/plan-actual"
t = open(B + "/04-Codigo.md", "rb").read().decode("utf-8", "replace")
files = sorted(set(re.findall(r"([A-Za-z0-9_./\\-]+\.(?:gd|json|tres|tscn))", t)))
abs_ = [x for x in files if not glob.glob("game/isla-ancestral/**/" + os.path.basename(x), recursive=True)]
print("M113 04-Codigo: %d archivos, %d AUSENTES: %s" % (len(files), len(abs_), abs_[:10]))
r = B + "/07-Resultados-Testings.md"
if os.path.exists(r):
    rt = open(r, "rb").read().decode("utf-8", "replace")
    print("M113 07-Resultados: %d lineas, %d EXIT -> %s" % (
        len(rt.splitlines()), len(re.findall("EXIT", rt)),
        "TEMPLATE/VAZIO" if "PENDIENTE" in rt else "con EXIT"))
else:
    print("M113 07-Resultados: AUSENTE")
c = open(B + "/05-Checklist.md", "rb").read().decode("utf-8")
imp = [m.group(1)[:46] for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines())
       if m and re.search(r"[Ii]mplement", m.group(1))]
print('M113 [x] "implementar": %d' % len(imp), imp[:3])
# the [ ] pending
pend = [m.group(1)[:50] for m in (re.match(r"^\s*[-*]\s*\[ \]\s*(.*)", L) for L in c.splitlines()) if m]
print("M113 [ ] pendientes: %d (muestreo: %s)" % (len(pend), pend[:3]))
# framework files
fw = [x.split("isla-ancestral/")[-1] for x in glob.glob("game/isla-ancestral/scripts/stress/*.gd")]
print("M113 framework scripts/stress/:", fw)
