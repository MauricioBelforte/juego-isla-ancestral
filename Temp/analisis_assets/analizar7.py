import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

import_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".import"):
            import_files.append(os.path.join(dirpath, f))

# dest_files missing (the imported .godot/... file)
missing_dest = []
total_dest = 0
for imp in import_files:
    with open(imp, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    m = re.search(r'dest_files=\["([^"]+)"\]', text)
    if m:
        dest = m.group(1)
        total_dest += 1
        p = os.path.join(PROJ, dest.replace("res://","").replace("/", os.sep))
        if not os.path.exists(p):
            missing_dest.append((imp, dest))

print("TOTAL .import:", len(import_files))
print("TOTAL dest_files parsed:", total_dest)
print("MISSING dest_files:", len(missing_dest))
from collections import Counter
c = Counter(r[1] for r in missing_dest)
print("UNIQUE missing dest:", len(c))
for ref, n in c.most_common(20):
    print("  ", n, ref)
