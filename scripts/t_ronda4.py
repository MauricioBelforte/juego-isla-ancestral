# -*- coding: utf-8 -*-
import re, os, glob
mods = ["83-Licencias-De-Software", "126-Marketing-Legal", "128-Identidad-De-Marca",
        "72-Sistema-De-Logros", "106-Seguridad"]
for mid in mods:
    base = None
    for d in os.listdir("DOCUMENTACION"):
        if d.startswith(mid.split("-")[0] + "-") and (mid in d or d.split("-")[0] == mid.split("-")[0]):
            base = "DOCUMENTACION/" + d + "/plan-actual"
    ck = base + "/05-Checklist.md" if base else None
    if not ck or not os.path.exists(ck):
        print("=== %s: NO encontrado ===" % mid)
        continue
    c = open(ck, "rb").read().decode("utf-8")
    mk = re.findall(r"(?m)^\s*[-*]\s*\[(x|X| |\?)\]", c)
    nx = sum(1 for m in mk if m in ("x", "X")); nq = sum(1 for m in mk if m == "?"); np = sum(1 for m in mk if m == " ")
    print("=== %s (%s): [x]=%d [?]=%d [ ]=%d (total %d) ===" % (mid, os.path.basename(os.path.dirname(base)), nx, nq, np, nx+nq+np))
    xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
    arts = sorted(set(re.findall(r"([A-Za-z0-9_./-]+\.(?:gd|json|tres|md|py|cfg))", " ".join(xs))))
    abs_ = [a for a in arts if not glob.glob("game/isla-ancestral/**/" + os.path.basename(a), recursive=True) and not glob.glob("DOCUMENTACION/**/" + os.path.basename(a), recursive=True)]
    print("   [x] citan %d artefactos, AUSENTES(repo): %d %s" % (len(arts), len(abs_), [os.path.basename(a) for a in abs_][:5]))
    qs = [L[2:].strip()[:55] for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[\?\]", L)]
    print("   [?]=%d sample: %s" % (len(qs), qs[:2]))
    mn = mid.split("-")[0]
    st = [x.split("isla-ancestral/")[-1] for x in glob.glob("game/isla-ancestral/**/*m%s*test*.gd" % mn, recursive=True)]
    print("   suite: %s" % (st[:2] or "ninguna"))
    print()
