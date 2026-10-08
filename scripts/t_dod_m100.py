# -*- coding: utf-8 -*-
import re, os, glob
B = "DOCUMENTACION/100-Community-Management/plan-actual"
# 04-Codigo files
t = open(B + "/04-Codigo.md", "rb").read().decode("utf-8", "replace")
files = sorted(set(re.findall(r"([A-Za-z0-9_./\\-]+\.(?:gd|json|tres|tscn))", t)))
abs_ = [x for x in files if not glob.glob("game/isla-ancestral/**/" + os.path.basename(x), recursive=True)]
print("M100 04-Codigo: %d archivos, %d AUSENTES: %s" % (len(files), len(abs_), abs_[:10]))
# 07-Resultados
r = B + "/07-Resultados-Testings.md"
if os.path.exists(r):
    rt = open(r, "rb").read().decode("utf-8", "replace")
    print("M100 07-Resultados: %d lineas, %d EXIT -> %s" % (
        len(rt.splitlines()), len(re.findall("EXIT", rt)),
        "TEMPLATE/VAZIO" if ("PENDIENTE" in rt or all(set(l.strip()) <= set("-| ") for l in rt.splitlines()) ) else "con EXIT"))
else:
    print("M100 07-Resultados: AUSENTE")
# "Implementar [x]"
c = open(B + "/05-Checklist.md", "rb").read().decode("utf-8")
imp = [m.group(1)[:46] for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines())
       if m and re.search(r"[Ii]mplement", m.group(1))]
print('M100 [x] "implementar": %d' % len(imp), imp[:3])
# does the community system have code?
code = glob.glob("game/isla-ancestral/scripts/**/*communit*", recursive=True) + \
       glob.glob("game/isla-ancestral/scripts/**/*moderacion*", recursive=True)
print("M100 code files:", [x.split("isla-ancestral/")[-1] for x in code][:5] or "ninguno en scripts/")
# suite
print("M100 suite:", [x.split("isla-ancestral/")[-1] for x in glob.glob("game/isla-ancestral/**/test*communit*.gd", recursive=True)][:3])
