import os, re, glob

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

def res_to_path(res_path):
    # res://foo -> PROJ/foo
    if res_path.startswith("res://"):
        rel = res_path[len("res://"):]
        return os.path.join(PROJ, rel.replace("/", os.sep))
    return None

# 1. Analisis .import -> source_file
import_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".import"):
            import_files.append(os.path.join(dirpath, f))

missing_import_sources = []
for imp in import_files:
    try:
        with open(imp, "r", encoding="utf-8", errors="replace") as fh:
            content = fh.read()
    except Exception as e:
        missing_import_sources.append((imp, "ERROR_READ", str(e)))
        continue
    m = re.search(r'source_file="([^"]+)"', content)
    if not m:
        missing_import_sources.append((imp, "NO_SOURCE_FILE", ""))
        continue
    src = m.group(1)
    src_path = res_to_path(src)
    if src_path is None:
        missing_import_sources.append((imp, "BAD_RES_PATH", src))
        continue
    if not os.path.exists(src_path):
        missing_import_sources.append((imp, "MISSING", src))

print("TOTAL .import:", len(import_files))
print("IMPORT PROBLEMAS:", len(missing_import_sources))
for x in missing_import_sources[:60]:
    print(x)
