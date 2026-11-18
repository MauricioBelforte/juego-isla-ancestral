import re, os, pathlib

root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral"
proj = os.path.join(root, "project.godot")
# parse autoloads
autoloads = []
in_auto = False
with open(proj, encoding="utf-8") as f:
    for line in f:
        s = line.strip()
        if s == "[autoload]":
            in_auto = True; continue
        if s.startswith("["):
            in_auto = False; continue
        if in_auto and "=" in s:
            name, val = s.split("=",1)
            name = name.strip()
            val = val.strip().strip('"')
            # remove leading *
            val = val.lstrip("*")
            autoloads.append((name, val))

print("total", len(autoloads))
# resolve path
def full(p): return os.path.join(root, p.replace("res://",""))

# line counts
rows = []
for name, rel in autoloads:
    fp = full(rel)
    if os.path.exists(fp):
        with open(fp, encoding="utf-8", errors="replace") as f:
            lines = f.read().splitlines()
        lc = len(lines)
        # funcs
        funcs = [i+1 for i,l in enumerate(lines) if re.match(r'\s*(func|static func)\s', l)]
        # signals
        sigs = [i+1 for i,l in enumerate(lines) if re.match(r'\s*signal\s', l)]
        rows.append((name, rel, fp, lc, len(funcs), len(sigs)))
    else:
        rows.append((name, rel, fp, -1, 0, 0))

# sort by lines desc
rows_sorted = sorted(rows, key=lambda r: r[3], reverse=True)
for r in rows_sorted[:30]:
    print(f"{r[3]:5d}  funcs={r[4]:3d}  sigs={r[5]:2d}  {r[0]}  {r[1]}")
print("... total rows", len(rows))
# save
import json
with open(os.path.join(root, "..", "..", "..", "Temp", "autoloads.json"), "w", encoding="utf-8") as f:
    json.dump({"autoloads": autoloads, "rows": [{"name":r[0],"rel":r[1],"fp":r[2],"lines":r[3],"funcs":r[4],"sigs":r[5]} for r in rows]}, f, indent=1, ensure_ascii=False)
