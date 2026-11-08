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

names = [a[0] for a in autoloads]
name_set = set(names)

# read code
code = {}
for name, rel in autoloads:
    fp = os.path.join(root, rel.replace("res://",""))
    try:
        with open(fp, encoding="utf-8", errors="replace") as f:
            code[name] = f.read()
    except FileNotFoundError:
        code[name] = ""

# dependencies: A -> B if B name appears as token in A's code (excluding self)
deps = {n: set() for n in names}
for a in names:
    txt = code[a]
    for b in names:
        if a == b: continue
        # word boundary; avoid matching inside longer identifiers
        if re.search(r'(?<![A-Za-z0-9_])'+re.escape(b)+r'(?![A-Za-z0-9_])', txt):
            deps[a].add(b)

# find cycles via SCC (Tarjan)
import sys
sys.setrecursionlimit(10000)
index_counter = [0]
stack = []
lowlink = {}
index = {}
on_stack = {}
result = []
def strongconnect(v):
    index[v] = index_counter[0]
    lowlink[v] = index_counter[0]
    index_counter[0]+=1
    stack.append(v)
    on_stack[v]=True
    for w in deps[v]:
        if w not in index:
            strongconnect(w)
            lowlink[v]=min(lowlink[v], lowlink[w])
        elif on_stack.get(w):
            lowlink[v]=min(lowlink[v], index[w])
    if lowlink[v]==index[v]:
        comp=[]
        while True:
            w=stack.pop()
            on_stack[w]=False
            comp.append(w)
            if w==v: break
        result.append(comp)
for v in names:
    if v not in index:
        strongconnect(v)

cycles = [c for c in result if len(c)>1]
print("num SCC size>1:", len(cycles))
for c in cycles:
    print("CYCLE:", " -> ".join(sorted(c)))
# also self? no

# save deps
out = {"deps": {k: sorted(v) for k,v in deps.items()}, "cycles": [sorted(c) for c in cycles]}
with open(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Temp\deps.json","w",encoding="utf-8") as f:
    json.dump(out, f, indent=1, ensure_ascii=False)
# print top dependents (most incoming)
from collections import Counter
incoming = Counter()
for a in names:
    for b in deps[a]:
        incoming[b]+=1
print("\nTop 20 most-referenced autoloads:")
for n,c in incoming.most_common(20):
    print(f"  {c:3d}  {n}")
