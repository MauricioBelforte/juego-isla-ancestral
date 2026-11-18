import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

ASSET_EXT = re.compile(r'\.(png|jpg|jpeg|glb|gltf|ogg|wav|mp3|webp)$', re.IGNORECASE)

tscn_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".tscn"):
            tscn_files.append(os.path.join(dirpath, f))

refs = []
for tscn in tscn_files:
    with open(tscn, "r", encoding="utf-8", errors="replace") as fh:
        lines = fh.readlines()
    for i, line in enumerate(lines, 1):
        for m in re.finditer(r'res://[^\s"\'\)\]\}]+', line):
            p = m.group(0).rstrip('",)')
            if ASSET_EXT.search(p):
                refs.append((tscn, i, p, line.strip()))

print("asset refs in .tscn:", len(refs))
for r in refs:
    print(r[0].replace(PROJ,""), "L"+str(r[1]), "|", r[2])
    print("   ", r[3][:120])
