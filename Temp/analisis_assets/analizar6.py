import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

ASSET_EXT = re.compile(r'\.(png|jpg|jpeg|glb|gltf|ogg|wav|mp3|webp|ttf|otf)$', re.IGNORECASE)

def is_literal_asset_path(p):
    # exclude placeholders/globs/templates
    if any(ch in p for ch in ['%','{','}','<','>','*','`','\\','"']):
        return False
    if not ASSET_EXT.search(p):
        return False
    # exclude addon third-party and tests
    if '/addons/' in p or '/tests/' in p:
        return False
    return True

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

# Analizar .tscn + .tres + .gd
files_to_scan = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith((".tscn",".tres",".gd")):
            files_to_scan.append(os.path.join(dirpath, f))

missing = []
total_asset_refs = 0
for f in files_to_scan:
    with open(f, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    refs = extract_res_paths(text)
    for ref in refs:
        if not is_literal_asset_path(ref):
            continue
        total_asset_refs += 1
        p = res_to_path(ref)
        if p is not None and not os.path.exists(p):
            missing.append((f, ref))

print("FILES scanned:", len(files_to_scan))
print("TOTAL literal asset refs:", total_asset_refs)
print("MISSING:", len(missing))
from collections import Counter
c = Counter(r[1] for r in missing)
print("UNIQUE missing:", len(c))
for ref, n in c.most_common():
    print("  ", n, ref)
print("--- detalle (primeros 80) ---")
for r in missing[:80]:
    print(r[0].replace(PROJ,""), "|", r[1])
