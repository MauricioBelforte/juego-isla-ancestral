import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

tscn_files = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith(".tscn") or f.endswith(".tres"):
            tscn_files.append(os.path.join(dirpath, f))

ext_res = 0
uid_only = 0
path_refs = 0
for f in tscn_files:
    with open(f, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    for m in re.finditer(r'\[ext_resource[^\]]*\]', text):
        ext_res += 1
        if 'path=' in m.group(0):
            path_refs += 1
        elif 'uid=' in m.group(0) and 'path=' not in m.group(0):
            uid_only += 1

print("files:", len(tscn_files))
print("ext_resource total:", ext_res)
print("con path=:", path_refs)
print("solo uid= (sin path):", uid_only)
