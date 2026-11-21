import os, re

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOCS = os.path.join(ROOT, "DOCUMENTACION")
BASE = os.path.join(DOCS, "TAREAS-POR-MODELO", "HY4 Flash", "BACKLOGS")

def find_module_folder(mid):
    mid = mid.lstrip('0') or '0'
    for d in os.listdir(DOCS):
        m = re.match(r'^(\d+)-', d)
        if m and m.group(1).lstrip('0') == mid and os.path.isdir(os.path.join(DOCS, d)):
            return d
    for d in os.listdir(DOCS):
        m = re.match(r'^0*(\d+)-', d)
        if m and m.group(1) == mid and os.path.isdir(os.path.join(DOCS, d)):
            return d
    return None

def count_marks(folder):
    fpath = os.path.join(DOCS, folder, "plan-actual", "05-Checklist.md")
    if not os.path.isfile(fpath):
        return None
    text = open(fpath, encoding="utf-8").read()
    x = len(re.findall(r"^[-*]\s*\[x\]", text, re.M))
    space = len(re.findall(r"^[-*]\s*\[ \]", text, re.M))
    q = len(re.findall(r"^[-*]\s*\[\?\]", text, re.M))
    return x, space, q

files = sorted([f for f in os.listdir(BASE) if f.endswith('.md') and not f.startswith('BACKLOG')])
b42_55 = [f for f in files if any(f.startswith(f'{i:02d}-') for i in range(42,56))]

all_tasks = []
for f in b42_55:
    text = open(os.path.join(BASE, f), encoding="utf-8").read()
    for line in text.splitlines():
        if re.search(r'\[x\]', line, re.I):
            all_tasks.append((f, line.strip()))

results = {"OK": 0, "FALSO": 0, "NO-VERIFICABLE": 0}
details = {"OK": [], "FALSO": [], "NO-VERIFICABLE": []}

for fname, task in all_tasks:
    verified = None
    reason = ""

    # Pattern 1: module count claims
    mod_match = re.search(r'M(\d{1,3})', task)
    count_pattern = re.search(r'real\s+(\d+)\s*x(?:\s*\+\s*(\d+)\s*\[\s*\])?(?:\s*\+\s*(\d+)\s*\[\?\])?(?:\s*=\s*(\d+))?', task, re.I)

    if mod_match:
        mid = mod_match.group(1)
        folder = find_module_folder(mid)
        if folder:
            marks = count_marks(folder)
            if marks:
                real_x, real_space, real_q = marks
                claimed_x = None
                claimed_space = None
                claimed_q = None
                if count_pattern:
                    claimed_x = int(count_pattern.group(1))
                    if count_pattern.group(2):
                        claimed_space = int(count_pattern.group(2))
                    if count_pattern.group(3):
                        claimed_q = int(count_pattern.group(3))
                if claimed_x is not None:
                    if real_x != claimed_x:
                        verified = "FALSO"
                        reason = f"[x] mismatch: claimed {claimed_x}, real {real_x} in M{mid}"
                    elif claimed_space is not None and real_space != claimed_space:
                        verified = "FALSO"
                        reason = f"[ ] mismatch: claimed {claimed_space}, real {real_space} in M{mid}"
                    elif claimed_q is not None and real_q != claimed_q:
                        verified = "FALSO"
                        reason = f"[?] mismatch: claimed {claimed_q}, real {real_q} in M{mid}"
                    else:
                        verified = "OK"
                        reason = f"M{mid}: [x]={real_x} [ ]={real_space} [?]={real_q} verified"

    # Pattern 2: file existence claims (only .gd, .tscn, .md, .json, .tres, .cfg, .py files)
    if verified is None:
        paths = re.findall(r'`([^`]+)`', task)
        file_paths = [p for p in paths if any(p.endswith(ext) for ext in ['.gd','.tscn','.md','.json','.tres','.cfg','.py','.png','.glb','.blend'])]
        if file_paths:
            all_exist = True
            checked = False
            for p in file_paths:
                candidates = [
                    os.path.join(ROOT, p),
                    os.path.join(ROOT, "DOCUMENTACION", p),
                    os.path.join(ROOT, "game", "isla-ancestral", p),
                ]
                found = any(os.path.exists(c) for c in candidates)
                checked = True
                if not found:
                    all_exist = False
            if checked:
                if all_exist:
                    verified = "OK"
                    reason = "file paths verified to exist"
                else:
                    verified = "FALSO"
                    reason = "some file paths do not exist"

    # Default
    if verified is None:
        verified = "NO-VERIFICABLE"
        reason = "no automated verification pattern matched"

    results[verified] += 1
    details[verified].append((fname, task[:150], reason))

# Report
report = []
report.append(f"Total [x] tasks scanned (b42-55): {len(all_tasks)}")
report.append(f"OK: {results['OK']} ({results['OK']*100//len(all_tasks)}%)")
report.append(f"FALSO: {results['FALSO']} ({results['FALSO']*100//len(all_tasks)}%)")
report.append(f"NO-VERIFICABLE: {results['NO-VERIFICABLE']} ({results['NO-VERIFICABLE']*100//len(all_tasks)}%)")
report.append("")
report.append("=== FALSO (detalles) ===")
for fname, task, reason in details["FALSO"]:
    report.append(f"  [{fname}] {task}")
    report.append(f"    -> {reason}")
report.append("")
report.append("=== NO-VERIFICABLE (resumen por razon) ===")
from collections import Counter
reasons = Counter(r for _, _, r in details["NO-VERIFICABLE"])
for r, c in reasons.most_common():
    report.append(f"  {r}: {c}")

outpath = os.path.join(ROOT, "tmp", "verificacion_b42_55.txt")
with open(outpath, "w", encoding="utf-8") as f:
    f.write("\n".join(report))

print("\n".join(report[:6]))
print(f"\nFull report: {outpath}")
PYEOF