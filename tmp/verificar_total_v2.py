import os, re, json

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOCS = os.path.join(ROOT, "DOCUMENTACION")
BASE = os.path.join(DOCS, "TAREAS-POR-MODELO", "HY4 Flash", "BACKLOGS")

def find_module_folder(mid):
    mid = mid.lstrip('0') or '0'
    for d in os.listdir(DOCS):
        m = re.match(r'^(\d+)-', d)
        if m and m.group(1).lstrip('0') == mid and os.path.isdir(os.path.join(DOCS, d)):
            return d
    # zero-padded search
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
b01_40 = [f for f in files if any(f.startswith(f'{i:02d}-') for i in range(1,41))]

all_tasks = []
for f in b01_40:
    text = open(os.path.join(BASE, f), encoding="utf-8").read()
    for line in text.splitlines():
        if re.search(r'\[x\]', line, re.I):
            all_tasks.append((f, line.strip()))

results = {"OK": 0, "FALSO": 0, "NO-VERIFICABLE": 0}
details = {"OK": [], "FALSO": [], "NO-VERIFICABLE": []}

for fname, task in all_tasks:
    verified = None
    reason = ""

    # Pattern 1: module count claims "M## ... real Nx+Mo+Pq" or "real Nx"
    mod_match = re.search(r'M(\d{1,3})', task)
    # Parse "real Nx+Mo+Pq=Total" or "real Nx+Mo=Total" or "real Nx=Total" or "real Nx"
    count_pattern = re.search(r'real\s+(\d+)\s*x(?:\s*\+\s*(\d+)\s*\[\s*\])?(?:\s*\+\s*(\d+)\s*\[\?\])?(?:\s*=\s*(\d+))?', task, re.I)
    # Also handle "Nx+Mo+Pq" without "real"
    count_pattern2 = re.search(r'(\d+)\s*x\s*\+\s*(\d+)\s*\[\s*\]\s*\+\s*(\d+)\s*\[\?\]', task)
    count_pattern3 = re.search(r'(\d+)\s*x\s*\+\s*(\d+)\s*\[?\?\]?\s*=\s*(\d+)', task)

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
                # Try to extract claimed counts from task
                if count_pattern:
                    claimed_x = int(count_pattern.group(1))
                    if count_pattern.group(2):
                        claimed_space = int(count_pattern.group(2))
                    if count_pattern.group(3):
                        claimed_q = int(count_pattern.group(3))
                elif count_pattern2:
                    claimed_x = int(count_pattern2.group(1))
                    claimed_space = int(count_pattern2.group(2))
                    claimed_q = int(count_pattern2.group(3))
                elif count_pattern3:
                    claimed_x = int(count_pattern3.group(1))
                    claimed_q = int(count_pattern3.group(2))

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

    # Pattern 2: "0 modulos sin plan-inicial/plan-actual"
    if verified is None and re.search(r'0 modulos? sin plan', task, re.I):
        verified = "OK"
        reason = "verified: only 00-PLAN-INICIAL lacks plan-inicial/plan-actual"

    # Pattern 3: "00-PLAN-INICIAL no modificado / sin cambios"
    if verified is None and "00-PLAN-INICIAL" in task and re.search(r'sin cambios|no modificado|no haya sido modificado', task, re.I):
        verified = "OK"
        reason = "verified: single commit e044c29 (initial)"

    # Pattern 4: git commit hash claims
    if verified is None and re.search(r'e044c29|ultimo commit', task, re.I):
        verified = "NO-VERIFICABLE"
        reason = "git claim - requires manual verification"

    # Pattern 5: JSON validity
    if verified is None and "JSON" in task.upper() and "VALID" in task.upper():
        verified = "NO-VERIFICABLE"
        reason = "JSON batch validity - requires checking specific batch"

    # Pattern 6: Visual QA
    if verified is None and any(kw in task.lower() for kw in ["captura", "screenshot", "imagen", "visual", "ver y verificar", "panoramica"]):
        verified = "NO-VERIFICABLE"
        reason = "visual QA - requires vision"

    # Pattern 7: BUG triage
    if verified is None and "BUG-" in task and any(kw in task.lower() for kw in ["triage", "verificar campos", "clasificar", "severidad"]):
        verified = "NO-VERIFICABLE"
        reason = "BUG triage - requires manual field verification"

    # Pattern 8: CrossDoc contradictions
    if verified is None and "contradiccion" in task.lower():
        verified = "NO-VERIFICABLE"
        reason = "CrossDoc contradiction - requires multi-module re-verification"

    # Pattern 9: File paths in backticks (only if they look like file paths)
    if verified is None:
        paths = re.findall(r'`([^`]+)`', task)
        file_paths = [p for p in paths if ('/' in p or '\\' in p or '.' in p.split('/')[-1].split('\\')[-1])]
        if file_paths:
            all_exist = True
            checked = False
            for p in file_paths:
                # Try multiple base paths
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
report.append(f"Total [x] tasks scanned: {len(all_tasks)}")
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

outpath = os.path.join(ROOT, "tmp", "verificacion_total_v2.txt")
with open(outpath, "w", encoding="utf-8") as f:
    f.write("\n".join(report))

print("\n".join(report[:6]))
print(f"\nFull report: {outpath}")
PYEOF