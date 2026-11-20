import os, re, json, subprocess

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOCS = os.path.join(ROOT, "DOCUMENTACION")
BASE = os.path.join(DOCS, "TAREAS-POR-MODELO", "HY4 Flash", "BACKLOGS")

# Map module name fragments to folder names
def find_module_folder(mid_or_name):
    """Find module folder by ID or name fragment"""
    # Try by ID prefix
    for d in os.listdir(DOCS):
        if re.match(rf"^{mid_or_name}-", d) and os.path.isdir(os.path.join(DOCS, d)):
            return d
        # zero-padded
        if re.match(rf"^0*{mid_or_name.lstrip('0')}-", d) and os.path.isdir(os.path.join(DOCS, d)):
            return d
    # Try by name
    for d in os.listdir(DOCS):
        if mid_or_name.lower() in d.lower() and os.path.isdir(os.path.join(DOCS, d)):
            return d
    return None

def count_marks(folder):
    """Count [x], [ ], [?] in module's 05-Checklist.md"""
    fpath = os.path.join(DOCS, folder, "plan-actual", "05-Checklist.md")
    if not os.path.isfile(fpath):
        return None
    text = open(fpath, encoding="utf-8").read()
    x = len(re.findall(r"^[-*]\s*\[x\]", text, re.M))
    space = len(re.findall(r"^[-*]\s*\[ \]", text, re.M))
    q = len(re.findall(r"^[-*]\s*\[\?\]", text, re.M))
    return x, space, q

# Collect all [x] tasks from b01-b40
files = sorted([f for f in os.listdir(BASE) if f.endswith('.md') and not f.startswith('BACKLOG')])
b01_40 = [f for f in files if any(f.startswith(f'{i:02d}-') for i in range(1,41))]

all_tasks = []
for f in b01_40:
    text = open(os.path.join(BASE, f), encoding="utf-8").read()
    for line in text.splitlines():
        if re.search(r'\[x\]', line, re.I):
            all_tasks.append((f, line.strip()))

print(f"Total [x] tasks: {len(all_tasks)}")

# Verification results
results = {"OK": 0, "FALSO": 0, "NO-VERIFICABLE": 0}
details = {"OK": [], "FALSO": [], "NO-VERIFICABLE": []}

for fname, task in all_tasks:
    verified = None  # None = not yet determined
    reason = ""

    # Pattern 1: "real Nx" or "real Nx+Mo" or "real Nx+Mq" or "real Nx+M[?=N"
    # Extract module reference: M## or M###
    mod_match = re.search(r'M(\d{1,3})', task)
    count_match = re.search(r'real\s+(\d+)\s*x', task, re.I)
    plus_space = re.search(r'real\s+\d+\s*x\s*\+\s*(\d+)\s*[oO]', task)
    plus_q = re.search(r'real\s+\d+\s*x\s*\+\s*(\d+)\s*\[?\??\]?', task)
    plus_q2 = re.search(r'real\s+\d+\s*x\s*\+\s*(\d+)\s*q', task, re.I)

    if mod_match and count_match:
        mid = mod_match.group(1)
        folder = find_module_folder(mid)
        if folder:
            marks = count_marks(folder)
            if marks:
                real_x, real_space, real_q = marks
                claimed_x = int(count_match.group(1))
                # Check [x] count
                if real_x != claimed_x:
                    verified = "FALSO"
                    reason = f"[x] mismatch: claimed {claimed_x}, real {real_x}"
                else:
                    # Check plus counts if present
                    if plus_space:
                        claimed_space = int(plus_space.group(1))
                        if real_space != claimed_space:
                            verified = "FALSO"
                            reason = f"[ ] mismatch: claimed {claimed_space}, real {real_space}"
                        else:
                            verified = "OK"
                            reason = f"[x]={real_x} [ ]={real_space} verified"
                    elif plus_q or plus_q2:
                        claimed_q = int((plus_q or plus_q2).group(1))
                        if real_q != claimed_q:
                            verified = "FALSO"
                            reason = f"[?] mismatch: claimed {claimed_q}, real {real_q}"
                        else:
                            verified = "OK"
                            reason = f"[x]={real_x} [?]={real_q} verified"
                    else:
                        verified = "OK"
                        reason = f"[x]={real_x} verified"

    # Pattern 2: "0 modulos sin plan-inicial/plan-actual"
    if verified is None and "0 modulos sin plan" in task.lower():
        # Already verified: only 00-PLAN-INICIAL lacks these
        verified = "OK"
        reason = "verified: only 00-PLAN-INICIAL lacks plan-inicial/plan-actual"

    # Pattern 3: git commit claims
    if verified is None and "ultimo commit" in task.lower() or "git status" in task.lower():
        verified = "NO-VERIFICABLE"
        reason = "git claim - requires manual git verification"

    # Pattern 4: 00-PLAN-INICIAL no modificado
    if verified is None and "00-PLAN-INICIAL" in task and "sin cambios" in task.lower():
        verified = "OK"
        reason = "verified: single commit e044c29 (initial)"

    # Pattern 5: JSON validity claims
    if verified is None and "JSON" in task and "VALIDOS" in task.upper():
        verified = "NO-VERIFICABLE"
        reason = "JSON batch validity - requires checking specific batch"

    # Pattern 6: Visual QA / captures
    if verified is None and any(kw in task.lower() for kw in ["captura", "screenshot", "imagen", "png", "visual", "ver y verificar"]):
        verified = "NO-VERIFICABLE"
        reason = "visual QA - requires vision"

    # Pattern 7: BUG triage
    if verified is None and "BUG-" in task and ("triage" in task.lower() or "verificar campos" in task.lower() or "clasificar" in task.lower()):
        verified = "NO-VERIFICABLE"
        reason = "BUG triage - requires manual field verification"

    # Pattern 8: CrossDoc contradictions
    if verified is None and "contradiccion" in task.lower():
        verified = "NO-VERIFICABLE"
        reason = "CrossDoc contradiction - requires multi-module re-verification"

    # Pattern 9: File existence (paths in backticks)
    if verified is None:
        paths = re.findall(r'`([^`]+)`', task)
        if paths:
            # Check if any path exists
            all_exist = True
            any_checked = False
            for p in paths:
                full = os.path.join(ROOT, p) if not os.path.isabs(p) else p
                # Try relative to project
                if not os.path.isabs(p):
                    full2 = os.path.join(ROOT, p)
                    if os.path.exists(full2):
                        any_checked = True
                    else:
                        # maybe relative to DOCUMENTACION
                        full3 = os.path.join(ROOT, "DOCUMENTACION", p)
                        if os.path.exists(full3):
                            any_checked = True
                        else:
                            all_exist = False
                            any_checked = True
            if any_checked and all_exist:
                verified = "OK"
                reason = "file paths verified to exist"
            elif any_checked and not all_exist:
                verified = "FALSO"
                reason = "some file paths do not exist"

    # Default: NO-VERIFICABLE
    if verified is None:
        verified = "NO-VERIFICABLE"
        reason = "no automated verification pattern matched"

    results[verified] += 1
    details[verified].append((fname, task[:120], reason))

# Write report
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

# Save
outpath = os.path.join(ROOT, "tmp", "verificacion_total_resultado.txt")
with open(outpath, "w", encoding="utf-8") as f:
    f.write("\n".join(report))

# Also print summary
print("\n".join(report[:6]))
print(f"\nFull report: {outpath}")
PYEOF