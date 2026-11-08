import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

ASSET_EXT = re.compile(r'\.(png|jpg|jpeg|glb|gltf|ogg|wav|mp3|ttf|otf|webp)$', re.IGNORECASE)

# 2 & 3: analisis .tscn
tscn_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".tscn"):
            tscn_files.append(os.path.join(dirpath, f))

missing_refs = []
total_refs = 0
for tscn in tscn_files:
    try:
        with open(tscn, "r", encoding="utf-8", errors="replace") as fh:
            lines = fh.readlines()
    except Exception as e:
        print("ERR", tscn, e)
        continue
    for i, line in enumerate(lines, 1):
        # find res://... paths
        for m in re.finditer(r'res://[^\s"\')\]]+', line):
            ref = m.group(0)
            # trim trailing punctuation
            ref = ref.rstrip('",)')
            if not ASSET_EXT.search(ref):
                continue
            total_refs += 1
            p = os.path.join(PROJ, ref[len("res://"):].replace("/", os.sep))
            if not os.path.exists(p):
                missing_refs.append((tscn, i, ref))

print("TOTAL .tscn:", len(tscn_files))
print("TOTAL asset refs en tscn:", total_refs)
print("MISSING refs:", len(missing_refs))
# dedupe by ref
from collections import Counter
c = Counter(r[2] for r in missing_refs)
print("UNIQUE missing:", len(c))
for ref, n in c.most_common():
    print("  ", n, ref)
print("--- detalle (primeros 80) ---")
for r in missing_refs[:80]:
    print(r)
