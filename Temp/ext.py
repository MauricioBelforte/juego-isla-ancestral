import re, os, json
root = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral"
proj = os.path.join(root, "project.godot")
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
            val = val.strip().strip('"').lstrip("*")
            autoloads.append((name.strip(), val))

rows=[]
for name, rel in autoloads:
    fp = os.path.join(root, rel.replace("res://",""))
    try:
        txt = open(fp, encoding="utf-8", errors="replace").read()
    except FileNotFoundError:
        txt=""
    lines = txt.splitlines()
    # extends
    ext = ""
    m = re.search(r'^\s*extends\s+(\S+)', txt, re.M)
    if m: ext = m.group(1)
    addchild = len(re.findall(r'add_child', txt))
    ready = "_ready" in txt
    process = "_process" in txt or "_physics_process" in txt
    class_name_m = re.search(r'^\s*class_name\s+(\S+)', txt, re.M)
    cn = class_name_m.group(1) if class_name_m else ""
    rows.append((name, rel, len(lines), ext, addchild, ready, process, cn))

# group by extends
from collections import defaultdict
byext = defaultdict(list)
for r in rows:
    byext[r[3]].append(r[0])
print("By extends:")
for k,v in sorted(byext.items(), key=lambda x:-len(x[1])):
    print(f"  {k or '(none)'}: {len(v)}  {', '.join(v[:12])}{'...' if len(v)>12 else ''}")

# autoloads with add_child > 0
print("\nAutoloads with add_child:")
for r in sorted(rows, key=lambda x:-x[4]):
    if r[4]>0:
        print(f"  add_child={r[4]}  {r[0]} ({r[1]}) extends={r[3]}")
