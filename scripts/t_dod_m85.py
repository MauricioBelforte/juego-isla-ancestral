# -*- coding: utf-8 -*-
import re, os, glob
B = "DOCUMENTACION/85-Modelos-3D-Legal/plan-actual"
# 04-Codigo files
f = B + "/04-Codigo.md"
t = open(f, "rb").read().decode("utf-8", "replace") if os.path.exists(f) else ""
files = sorted(set(re.findall(r"([A-Za-z0-9_./\\-]+\.(?:gd|json|tres|tscn))", t)))
abs_ = [x for x in files if not glob.glob("game/isla-ancestral/**/" + os.path.basename(x), recursive=True)]
print("M85 04-Codigo: %d archivos, %d AUSENTES: %s" % (len(files), len(abs_), abs_[:8]))
# 07-Resultados
r = B + "/07-Resultados-Testings.md"
print("M85 07-Resultados:", "AUSENTE" if not os.path.exists(r) else "presente")
# does M85 have code at all? (legal/licensing - maybe pure doc)
code = glob.glob("game/isla-ancestral/scripts/**/*licen*", recursive=True) + \
       glob.glob("game/isla-ancestral/scripts/**/*credit*", recursive=True) + \
       glob.glob("game/isla-ancestral/data/legal/*", recursive=True)
print("M85 code/data:", [x.split("isla-ancestral/")[-1] for x in code][:8] or "ninguno")
# [x] and [ ] and [?]
c = open(B + "/05-Checklist.md", "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
print("M85 [x]=%d [?]=%d [ ]=%d" % (sum(1 for m in mk if m in ("x","X")), sum(1 for m in mk if m=="?"), sum(1 for m in mk if m==" ")))
imp = [m.group(1)[:46] for m in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines())
       if m and re.search(r"[Ii]mplement", m.group(1))]
print('M85 [x] "implementar": %d' % len(imp), imp[:3])
