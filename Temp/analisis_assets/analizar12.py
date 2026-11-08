import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

import_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".import"):
            import_files.append(os.path.join(dirpath, f))

# Check: .import filename should match source_file basename
mismatched = []
for imp in import_files:
    with open(imp, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    m = re.search(r'source_file="([^"]+)"', text)
    if not m:
        continue
    src = m.group(1)
    src_basename = os.path.basename(src.replace("res://",""))
    imp_basename = os.path.basename(imp)  # foo.png.import
    expected_imp = src_basename + ".import"
    if imp_basename != expected_imp:
        mismatched.append((imp, src, imp_basename, expected_imp))

print("TOTAL .import:", len(import_files))
print("MISMATCHED name:", len(mismatched))
for r in mismatched[:30]:
    print(r[0].replace(PROJ,""), "| imp=", r[2], "expected=", r[3], "| src=", r[1])
