# -*- coding: utf-8 -*-
import re, os, glob, json
B = "DOCUMENTACION/131-Creditos/plan-actual"
t = open(B + "/04-Codigo.md", "rb").read().decode("utf-8", "replace")
files = sorted(set(re.findall(r"([A-Za-z0-9_./\\-]+\.(?:gd|json|tres|tscn))", t)))
abs_ = [x for x in files if not glob.glob("game/isla-ancestral/**/" + os.path.basename(x), recursive=True)]
print("M131 04-Codigo: %d archivos, %d AUSENTES: %s" % (len(files), len(abs_), abs_[:8]))
r = B + "/07-Resultados-Testings.md"
print("M131 07-Resultados:", "AUSENTE" if not os.path.exists(r) else "presente")
# creditos.json sections
try:
    j = json.load(open("game/isla-ancestral/data/legal/creditos.json", encoding="utf-8"))
    n = len(j) if isinstance(j, (list, dict)) else "?"
    print("M131 creditos.json secciones:", n)
except Exception as e:
    print("M131 creditos.json:", e)
# "Implementar [x]"
c = open(B + "/05-Checklist.md", "rb").read().decode("utf-8")
imp = [m.group(1)[:46] for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines())
       if m and re.search(r"[Ii]mplement", m.group(1))]
print('M131 [x] "implementar": %d' % len(imp), imp[:3])
# "7 secciones" claim
sev = [m.group(1)[:60] for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines()) if m and "seccion" in m.group(1).lower()]
print('M131 [x] que citan secciones:', sev[:2])
