import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

def res_to_path(res_path):
    if res_path.startswith("res://"):
        rel = res_path[len("res://"):]
        return os.path.join(PROJ, rel.replace("/", os.sep))
    return None

# Extract all res:// paths from a text file
def extract_res_paths(text):
    # match res://... up to quote/space/paren/bracket
    paths = set()
    for m in re.finditer(r'res://[^\s"\'\)\]\}]+', text):
        p = m.group(0).rstrip('",)')
        # strip trailing punctuation that may have been included
        while p and p[-1] in '.,;:':
            p = p[:-1]
        paths.add(p)
    return paths

# .tscn analysis: all res:// refs, check existence
tscn_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".tscn"):
            tscn_files.append(os.path.join(dirpath, f))

missing_tscn = []
total_tscn_refs = 0
all_tscn_refs = set()
for tscn in tscn_files:
    with open(tscn, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    refs = extract_res_paths(text)
    for ref in refs:
        total_tscn_refs += 1
        all_tscn_refs.add(ref)
        p = res_to_path(ref)
        if p is not None and not os.path.exists(p):
            missing_tscn.append((tscn, ref))

print("TOTAL .tscn:", len(tscn_files))
print("TOTAL unique res refs in tscn:", len(all_tscn_refs))
print("MISSING in tscn:", len(missing_tscn))
# dedupe
from collections import Counter
c = Counter(r[1] for r in missing_tscn)
print("UNIQUE missing:", len(c))
for ref, n in c.most_common():
    print("  ", n, ref)
print("--- detalle tscn missing (primeros 60) ---")
for r in missing_tscn[:60]:
    print(r[0].replace(PROJ, "res://.."), "|", r[1])
