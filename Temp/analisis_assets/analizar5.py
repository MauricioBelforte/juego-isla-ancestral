import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

def res_to_path(res_path):
    if res_path.startswith("res://"):
        rel = res_path[len("res://"):]
        return os.path.join(PROJ, rel.replace("/", os.sep))
    return None

def extract_res_paths(text):
    paths = set()
    for m in re.finditer(r'res://[^\s"\'\)\]\}]+', text):
        p = m.group(0).rstrip('",)')
        while p and p[-1] in '.,;:':
            p = p[:-1]
        paths.add(p)
    return paths

# Analizar .gd
gd_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".gd"):
            gd_files.append(os.path.join(dirpath, f))

missing_gd = []
total = 0
allrefs = set()
for f in gd_files:
    with open(f, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    refs = extract_res_paths(text)
    for ref in refs:
        total += 1
        allrefs.add(ref)
        p = res_to_path(ref)
        if p is not None and not os.path.exists(p):
            missing_gd.append((f, ref))

print("TOTAL .gd:", len(gd_files))
print("TOTAL unique res refs in gd:", len(allrefs))
print("MISSING in gd:", len(missing_gd))
from collections import Counter
c = Counter(r[1] for r in missing_gd)
print("UNIQUE missing:", len(c))
for ref, n in c.most_common():
    print("  ", n, ref)
print("--- detalle gd missing (primeros 60) ---")
for r in missing_gd[:60]:
    print(r[0].replace(PROJ,""), "|", r[1])
