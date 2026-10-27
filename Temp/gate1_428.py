import os, re, glob, collections
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
game = os.path.join(root, "game", "isla-ancestral")
tdir = game + "/scripts/animacion/validacion"
print("== M48 validacion dir: %s exists=%s ==" % (tdir, os.path.isdir(tdir)))
if os.path.isdir(tdir):
    for f in sorted(os.listdir(tdir)):
        p = os.path.join(tdir, f)
        print("   %-32s %6d bytes" % (f, os.path.getsize(p)))
# the 4 claimed files
for need in ["animation_validator.gd", "import_animation_defaults.gd", "validate_animation_cli.gd", "test_validacion_m48.gd"]:
    hit = glob.glob(os.path.join(game, "**", need), recursive=True)
    print("   need %-32s -> %s" % (need, "OK " + os.path.relpath(hit[0], root) if hit else "AUSENTE"))

# M60 05 counts
doc = os.path.join(root, "DOCUMENTACION")
for pref in ["60", "48"]:
    for dd in os.listdir(doc):
        if dd.startswith(pref + "-"):
            p = os.path.join(doc, dd, "plan-actual", "05-Checklist.md")
            if os.path.exists(p):
                L = open(p, encoding="utf-8-sig", errors="ignore").read().splitlines()
                cc = collections.Counter()
                tot = []
                for l in L:
                    m = re.match(r"^\s*-\s*\[(.)\]", l)
                    if m:
                        cc[m.group(1)] += 1
                    if "**Totales:**" in l:
                        tot.append(l.strip()[:70])
                print("M%s: cuerpo x=%d [ ]=%d [?]=%d | Totales lines: %s" % (pref, cc.get("x", 0), cc.get(" ", 0), cc.get("?", 0), tot))
            break
# M60 L184/L186/L191 current state (the 3 M08)
p = None
for dd in os.listdir(doc):
    if dd.startswith("60-"):
        p = os.path.join(doc, dd, "plan-actual", "05-Checklist.md")
if p:
    L = open(p, encoding="utf-8-sig", errors="ignore").read().splitlines()
    for ln in [184, 186, 191]:
        if len(L) > ln - 1:
            print("M60 L%d: %s" % (ln, L[ln - 1].strip()[:80]))
