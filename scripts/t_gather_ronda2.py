# -*- coding: utf-8 -*-
import re, os, glob
mods = {
 "105": "105-Telemetria-De-Gameplay",
 "104": "104-Analytics",
 "107": "107-Backups",
 "110": "110-Debug-Menu",
 "108": "108-Pipeline-De-Assets",
}
for mid, name in mods.items():
    base = "DOCUMENTACION/" + name + "/plan-actual"
    ck = base + "/05-Checklist.md"
    if not os.path.exists(ck):
        # try to find the real folder
        cand = [d for d in os.listdir("DOCUMENTACION") if d.startswith(mid + "-")]
        if cand:
            name = cand[0]; base = "DOCUMENTACION/" + name + "/plan-actual"; ck = base + "/05-Checklist.md"
        else:
            print("M%s AUSENTE" % mid); continue
    c = open(ck, "rb").read().decode("utf-8")
    mk = re.findall(r"(?m)^\s*[-*]\s*\[(x|X| |\?)\]", c)
    nx = sum(1 for m in mk if m in ("x", "X")); nq = sum(1 for m in mk if m == "?"); np_ = sum(1 for m in mk if m == " ")
    tot = nx + nq + np_
    print("\n=== M%s %s ===" % (mid, name))
    print("  [x]=%d [?]=%d [ ]=%d  total=%d" % (nx, nq, np_, tot))
    # 04-Codigo files
    f = base + "/04-Codigo.md"
    if os.path.exists(f):
        t = open(f, "rb").read().decode("utf-8", "replace")
        files = sorted(set(re.findall(r"([A-Za-z0-9_./\\-]+\.(?:gd|json|tres|tscn))", t)))
        abs_ = [x for x in files if not glob.glob("game/isla-ancestral/**/" + os.path.basename(x), recursive=True)]
        print("  04-Codigo: %d archivos, %d AUSENTES: %s" % (len(files), len(abs_), abs_[:6]))
    else:
        print("  04-Codigo: AUSENTE")
    # 07
    r = base + "/07-Resultados-Testings.md"
    if os.path.exists(r):
        rt = open(r, "rb").read().decode("utf-8", "replace")
        print("  07-Resultados: %d lineas, %d EXIT" % (len(rt.splitlines()), len(re.findall("EXIT", rt))))
    else:
        print("  07-Resultados: AUSENTE")
    # implement [x]
    imp = [m2.group(1)[:40] for m2 in (re.match(r"^\s*[-*]\s*\[x\]\s*(.*)", L, re.I) for L in c.splitlines())
           if m2 and re.search(r"[Ii]mplement", m2.group(1))]
    print('  [x] "implementar": %d %s' % (len(imp), imp[:2]))
    # suite
    s = glob.glob("game/isla-ancestral/**/test_*%s*.gd" % mid.lower(), recursive=True) + \
        glob.glob("game/isla-ancestral/**/*test*%s*.gd" % mid.lower(), recursive=True)
    s = [x for x in s if re.search("m%s" % mid, x, re.I)]
    print("  suite M%s: %s" % (mid, [x.split("isla-ancestral/")[-1] for x in s][:4] or "ninguna"))
