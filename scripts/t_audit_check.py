# -*- coding: utf-8 -*-
import re, glob
for rid in ["77", "45"]:
    g = glob.glob("DOCUMENTACION/%s-*" % rid)[0]
    c = open(g + "/plan-actual/05-Checklist.md", "rb").read().decode("utf-8")
    mk = re.findall(r"(?m)^\s*[-*]\s*\[(x| |X|\?)\]", c)
    x = sum(1 for m in mk if m in ("x", "X"))
    q = sum(1 for m in mk if m == "?")
    e = sum(1 for m in mk if m == " ")
    tl = [L for L in c.splitlines() if "Totales:" in L]
    print("M%s: [x]=%d [?]=%d [ ]=%d" % (rid, x, q, e))
    print("  Totales actual:", (tl[0].strip()[:75] if tl else "NINGUNO"))
