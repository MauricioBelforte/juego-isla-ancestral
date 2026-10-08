# -*- coding: utf-8 -*-
import re, os, glob
mods = ["115-Hardware", "46-Arte-2D", "96-Plataformas", "61-Rendimiento", "117-Build-System"]
for mid in mods:
    base = None
    for d in os.listdir("DOCUMENTACION"):
        if d.startswith(mid.split("-")[0] + "-"):
            base = "DOCUMENTACION/" + d + "/plan-actual"
            break
    ck = base + "/05-Checklist.md" if base else None
    if not ck or not os.path.exists(ck):
        print("=== %s: carpeta/checklist no encontrado ===" % mid)
        continue
    c = open(ck, "rb").read().decode("utf-8")
    mk = re.findall(r"(?m)^\s*[-*]\s*\[(x|X| |\?)\]", c)
    nx = sum(1 for m in mk if m in ("x", "X")); nq = sum(1 for m in mk if m == "?"); np = sum(1 for m in mk if m == " ")
    print("=== %s: [x]=%d [?]=%d [ ]=%d (total %d) ===" % (mid, nx, nq, np, nx + nq + np))
    # [x] citan artefactos
    xs = [re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I).group(1) for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[x\]", L, re.I)]
    arts = sorted(set(re.findall(r"([A-Za-z0-9_./-]+\.(?:gd|json|tres|iss|py|sh|cfg))", " ".join(xs))))
    abs_ = [a for a in arts if not glob.glob("game/isla-ancestral/**/" + os.path.basename(a), recursive=True)]
    print("   [x] citan %d artefactos, AUSENTES: %d %s" % (len(arts), len(abs_), [os.path.basename(a) for a in abs_][:6]))
    # [?]
    qs = [L[2:].strip() for L in c.splitlines() if re.match(r"^\s*[-*]\s*\[\?\]", L)]
    print("   [?]=%d; sample: %s" % (len(qs), qs[:2] if qs else "ninguno"))
    # suite
    mn = re.match(r"(\d+)", mid).group(1)
    st = [x.split("isla-ancestral/")[-1] for x in glob.glob("game/isla-ancestral/**/*m%s*.gd" % mn, recursive=True)
          if "test" in x.lower() or "check" in x.lower()]
    print("   suite M%s: %s" % (mn, st[:3] or "ninguna"))
    print()
