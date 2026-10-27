import os, re, glob, collections
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
game = os.path.join(root, "game", "isla-ancestral")
# M110 2 files
for f in ["debug_menu.gd", "test_debug_menu_config_m110.gd"]:
    hit = glob.glob(os.path.join(game, "**", f), recursive=True)
    hit = [h for h in hit if "addons" not in h]
    if hit:
        print("%-32s OK %d bytes %s" % (f, os.path.getsize(hit[0]), os.path.relpath(hit[0], root)))
    else:
        print("%-32s AUSENTE" % f)
# M110 05 body
doc = os.path.join(root, "DOCUMENTACION")
for dd in os.listdir(doc):
    if dd.startswith("110-"):
        p = os.path.join(doc, dd, "plan-actual", "05-Checklist.md")
        if os.path.exists(p):
            cc = collections.Counter()
            for l in open(p, encoding="utf-8-sig", errors="ignore").read().splitlines():
                m = re.match(r"^\s*-\s*\[(.)\]", l)
                if m:
                    cc[m.group(1)] += 1
            print("M110 cuerpo: x=%d [ ]=%d [?]=%d total=%d" % (cc.get("x", 0), cc.get(" ", 0), cc.get("?", 0), sum(cc.values())))
            break
# M110 global row
g = open(os.path.join(root, "CHECKLIST-GLOBAL.md"), encoding="utf-8-sig", errors="ignore").read().splitlines()
for l in g:
    if re.match(r"^\|\s*110\s*\|", l):
        c = [x.strip() for x in l.split("|")]
        print("GLOBAL M110: prog=%s estado=%s agente=%s" % (c[4], c[3], c[9] if len(c) > 9 else "?"))
        break
