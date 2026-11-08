import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

ASSET_EXT = re.compile(r'\.(png|jpg|jpeg|glb|gltf|ogg|wav|mp3|webp)$', re.IGNORECASE)

def is_literal_asset_path(p):
    if any(ch in p for ch in ['%','{','}','<','>','*','`','\\','"']):
        return False
    if not ASSET_EXT.search(p):
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

# Solo .tres
tres_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".tres"):
            tres_files.append(os.path.join(dirpath, f))

missing = []
total = 0
for f in tres_files:
    with open(f, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    refs = extract_res_paths(text)
    for ref in refs:
        if not is_literal_asset_path(ref):
            continue
        total += 1
        p = res_to_path(ref)
        if p is not None and not os.path.exists(p):
            missing.append((f, ref))

print("TOTAL .tres:", len(tres_files))
print("TOTAL literal asset refs in .tres:", total)
print("MISSING:", len(missing))
for r in missing:
    print(r[0].replace(PROJ,""), "|", r[1])
