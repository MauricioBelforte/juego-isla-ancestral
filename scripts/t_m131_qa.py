# -*- coding: utf-8 -*-
import re, os, glob
B = "DOCUMENTACION/131-Creditos/plan-actual"
ck = B + "/05-Checklist.md"
c = open(ck, "rb").read().decode("utf-8")
mk = re.findall(r"(?m)^\s*[-*]\s*\[(x|X| |\?)\]", c)
print("M131 [x]=%d [?]=%d [ ]=%d" % (sum(1 for m in mk if m in ("x", "X")), sum(1 for m in mk if m == "?"), sum(1 for m in mk if m == " ")))
print("=== los [ ] (son KnownIssue?) ===")
for L in c.splitlines():
    if re.match(r"^\s*[-*]\s*\[\s\]", L, re.I):
        print("  ", L.strip()[:100])
xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
arts = sorted(set(re.findall(r"([A-Za-z0-9_./-]+\.(?:gd|json|tres|tscn))", " ".join(xs))))
print("M131 [x] citan %d artefactos:" % len(arts))
for a in arts:
    ex = glob.glob("game/isla-ancestral/**/" + os.path.basename(a), recursive=True)
    print("  %s %s" % (("OK " if ex else "X  "), a))
