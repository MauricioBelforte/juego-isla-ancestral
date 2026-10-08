# -*- coding: utf-8 -*-
import re, os, glob
base = None
for d in os.listdir("DOCUMENTACION"):
    if d.startswith("37-"):
        base = "DOCUMENTACION/" + d + "/plan-actual"
        break
print("M37 carpeta:", base)
ck = base + "/05-Checklist.md"
c = open(ck, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x|X| |\?)\]", c)
print("M37 [x]=%d [?]=%d [ ]=%d" % (sum(1 for m in mk if m in ("x","X")), sum(1 for m in mk if m=="?"), sum(1 for m in mk if m==" ")))
xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
arts = sorted(set(re.findall(r"([A-Za-z0-9_./-]+\.(?:gd|json|tres|gdl))", " ".join(xs))))
print("M37 [x] citan %d artefactos:" % len(arts))
for a in arts:
    ex = glob.glob("game/isla-ancestral/**/" + os.path.basename(a), recursive=True)
    print("  %s %s" % (("OK " if ex else "X  "), a))
pend = [L[2:].strip() for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[ \]", L)]
print("M37 [ ] = %d, sample:" % len(pend))
for p in pend[:6]:
    print("   -", p[:72])
