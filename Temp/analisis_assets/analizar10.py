import os

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

ASSET_EXT = ('.png','.jpg','.jpeg','.glb','.gltf','.ogg','.wav','.mp3','.webp')

assets = []
for dirpath, _, files in os.walk(PROJ):
    # skip .godot imported cache
    if ".godot" in dirpath.split(os.sep):
        continue
    for f in files:
        if f.lower().endswith(ASSET_EXT):
            assets.append(os.path.join(dirpath, f))

missing_import = []
for a in assets:
    if not os.path.exists(a + ".import"):
        missing_import.append(a)

print("TOTAL assets (png/jpg/glb/ogg/etc):", len(assets))
print("assets SIN .import:", len(missing_import))
# show by extension
from collections import Counter
c = Counter(os.path.splitext(a)[1].lower() for a in missing_import)
print("by ext:", dict(c))
print("--- primeros 40 ---")
for a in missing_import[:40]:
    print(a.replace(PROJ,""))
