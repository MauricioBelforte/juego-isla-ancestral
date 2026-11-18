import os, re

ROOT = "game/isla-ancestral"
PROJ = os.path.abspath(ROOT)

ASSET_EXT = re.compile(r'\.(png|jpg|jpeg|glb|gltf|ogg|wav|mp3|webp)$', re.IGNORECASE)

def is_literal_asset_path(p):
    if any(ch in p for ch in ['%','{','}','<','>','*','`','\\','"']):
        return False
    if not ASSET_EXT.search(p):
        return False
    if '/addons/' in p or '/tests/' in p:
        return False
    return True

def extract_res_paths(text):
    paths = set()
    for m in re.finditer(r'res://[^\s"\'\)\]\}]+', text):
        p = m.group(0).rstrip('",)')
        while p and p[-1] in '.,;:':
            p = p[:-1]
        paths.add(p)
    return paths

# case-sensitive existence check
def exists_case_sensitive(res_path):
    if not res_path.startswith("res://"):
        return True, "not-res"
    rel = res_path[len("res://"):]
    parts = rel.split("/")
    cur = PROJ
    for part in parts:
        if not os.path.isdir(cur):
            return False, "parent-missing"
        # list entries with exact case
        try:
            entries = os.listdir(cur)
        except OSError:
            return False, "oserror"
        if part not in entries:
            # case-insensitive match?
            lower = part.lower()
            matches = [e for e in entries if e.lower() == lower]
            if matches:
                return False, "CASE_MISMATCH (found: %s)" % matches
            return False, "MISSING"
        cur = os.path.join(cur, part)
    return os.path.exists(cur), "OK"

files_to_scan = []
for dirpath, _, files in os.walk(PROJ):
    for f in files:
        if f.endswith((".tscn",".tres")):
            files_to_scan.append(os.path.join(dirpath, f))

case_issues = []
total = 0
for f in files_to_scan:
    with open(f, "r", encoding="utf-8", errors="replace") as fh:
        text = fh.read()
    refs = extract_res_paths(text)
    for ref in refs:
        if not is_literal_asset_path(ref):
            continue
        total += 1
        ok, reason = exists_case_sensitive(ref)
        if not ok:
            case_issues.append((f, ref, reason))

print("FILES scanned:", len(files_to_scan))
print("TOTAL literal asset refs:", total)
print("CASE/EXISTENCE issues:", len(case_issues))
for r in case_issues:
    print(r[0].replace(PROJ,""), "|", r[1], "|", r[2])
