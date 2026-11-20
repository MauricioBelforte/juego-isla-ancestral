import os, re

ROOT = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral"
DOCS = os.path.join(ROOT, "DOCUMENTACION")
GLOBAL = os.path.join(ROOT, "CHECKLIST-GLOBAL.md")

with open(GLOBAL, encoding="utf-8") as f:
    global_text = f.read()
global_lines = global_text.splitlines()

global_map = {}
for line in global_lines:
    m = re.match(r"^\|\s*(\d+)\s*\|", line)
    if m:
        mid = m.group(1)
        pm = re.search(r"\|\s*(\d+)/(\d+)\s*\|", line)
        if pm:
            global_map[mid] = (int(pm.group(1)), int(pm.group(2)))

mods = []
for d in sorted(os.listdir(DOCS)):
    m = re.match(r"^(\d+)-", d)
    if not m:
        continue
    mid = m.group(1)
    cpath = os.path.join(DOCS, d, "plan-actual", "05-Checklist.md")
    if not os.path.isfile(cpath):
        continue
    with open(cpath, encoding="utf-8") as f:
        text = f.read()
    real_x = len(re.findall(r"^[-*]\s*\[x\]", text, re.M))
    real_space = len(re.findall(r"^[-*]\s*\[ \]", text, re.M))
    real_q = len(re.findall(r"^[-*]\s*\[\?\]", text, re.M))
    real_total = real_x + real_space + real_q
    totals_lines = [l for l in text.splitlines() if "Totales" in l]
    totals_line = totals_lines[-1] if totals_lines else None
    totals_completed = None
    totals_total = None
    if totals_line:
        cm = re.search(r"Completados:\s*(\d+)", totals_line)
        if cm:
            totals_completed = int(cm.group(1))
        tm = re.search(r"(\d+)\s*[íi]tems", totals_line)
        if tm:
            totals_total = int(tm.group(1))
    g = global_map.get(mid)
    g_completed = g[0] if g else None
    g_total = g[1] if g else None

    drift_totals = abs(real_x - totals_completed) if totals_completed is not None else None
    drift_global = abs(real_x - g_completed) if g_completed is not None else None

    has_contradiction = (totals_completed is not None and real_x != totals_completed) or (g_completed is not None and real_x != g_completed) or (totals_line is None)

    mods.append({
        "id": mid, "name": d,
        "real_x": real_x, "real_space": real_space, "real_q": real_q, "real_total": real_total,
        "totals_line": totals_line, "totals_completed": totals_completed, "totals_total": totals_total,
        "g_completed": g_completed, "g_total": g_total,
        "drift_totals": drift_totals, "drift_global": drift_global,
        "has_contradiction": has_contradiction,
        "no_totals": totals_line is None,
    })

big_drift = [m for m in mods if (m["drift_totals"] is not None and m["drift_totals"] > 5) or (m["drift_global"] is not None and m["drift_global"] > 5)]
small_drift = [m for m in mods if m["has_contradiction"] and not ((m["drift_totals"] is not None and m["drift_totals"] > 5) or (m["drift_global"] is not None and m["drift_global"] > 5))]
no_totals = [m for m in mods if m["no_totals"]]

print("Total modules scanned:", len(mods))
print("With contradiction:", sum(1 for m in mods if m["has_contradiction"]))
print("Drift > 5:", len(big_drift))
print("Drift <= 5 (contradiction):", len(small_drift))
print("No Totales line:", len(no_totals))
print()
print("=== DRIFT > 5 (reportar) ===")
for m in sorted(big_drift, key=lambda x: int(x["id"])):
    print(f"M{m['id']} {m['name']}: real={m['real_x']}/{m['real_total']} totals={m['totals_completed']} global={m['g_completed']}/{m['g_total']} drift_totals={m['drift_totals']} drift_global={m['drift_global']}")
print()
print("=== NO TOTALS LINE ===")
for m in sorted(no_totals, key=lambda x: int(x["id"])):
    print(f"M{m['id']} {m['name']}: real={m['real_x']}/{m['real_total']} global={m['g_completed']}/{m['g_total']}")
PYEOF