from pathlib import Path
import re

REPO = Path(r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral")
DOC = REPO / "DOCUMENTACION"
GLOBAL = REPO / "CHECKLIST-GLOBAL.md"

# --- integridad de la fuente compartida (no se edita) ---
gb = GLOBAL.read_bytes()
assert len(gb) > 100000 and not gb.startswith(b"\xef\xbb\xbf")
gtext = gb.decode("utf-8", errors="replace")

rows = {}
for line in gtext.splitlines():
    if not line.startswith("| "):
        continue
    cells = line.split("|")
    if len(cells) < 5:
        continue
    mid = cells[1].strip()
    if not mid.isdigit():
        continue
    rows[int(mid)] = (cells[4].strip(), line)

RE_MARK = re.compile(r"^\s*(?:\d+\.|[-*])\s+\[([ x?>-])\]")

def checklist_path(mid):
    cands = [d for d in DOC.iterdir() if d.is_dir() and d.name.startswith(f"{mid}-")]
    if not cands:
        return None
    d = cands[0]
    p = d / "plan-actual" / "05-Checklist.md"
    if p.exists():
        return p
    found = sorted(d.glob("**/05-Checklist.md"))
    return found[0] if found else None

def count_marks(p):
    raw = p.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        raw = raw[3:]
    txt = raw.decode("utf-8", errors="replace")
    from collections import Counter
    c = Counter(m.group(1) for m in (RE_MARK.match(l) for l in txt.splitlines()) if m)
    return c

result = []
for mid in range(41, 121):
    p = checklist_path(mid)
    prog, line = rows.get(mid, ("", ""))
    m = re.match(r"(\d+)\s*/\s*(\d+)", prog)
    gx, gt = (int(m.group(1)), int(m.group(2))) if m else (None, None)
    if p is None:
        result.append((mid, None, None, gx, gt, "SIN 05-Checklist", ""))
        continue
    c = count_marks(p)
    rx = c.get("x", 0)
    rt = rx + c.get(" ", 0) + c.get("?", 0)
    drift = (rx - gx) if gx is not None else None
    result.append((mid, rx, rt, gx, gt, drift, str(p.relative_to(REPO))))

print("=== MODULOS CON DRIFT > 5 (|real_x - global_x|) ===")
n_big = 0
for mid, rx, rt, gx, gt, d, path in result:
    if isinstance(d, int) and abs(d) > 5:
        n_big += 1
        print(f"M{mid}: real {rx}/{rt} | GLOBAL {gx}/{gt} | drift {d:+d}")
print("total drift>5:", n_big, "de", len(result))

print("\n=== 7 DRIFTS REPORTADOS EN BACKLOG 09 ===")
for mid in [46, 63, 66, 69, 94, 104, 106]:
    rx, rt, gx, gt, d, path = next((r[1], r[2], r[3], r[4], r[5], r[6]) for r in result if r[0] == mid)
    print(f"M{mid}: real {rx}/{rt} | GLOBAL {gx}/{gt} | drift {d:+d} | {path}")

print("\n=== RESUMEN POR RANGO ===")
for a, b, label in [(41,60,"M41-M60"),(61,80,"M61-M80"),(81,100,"M81-M100"),(101,120,"M101-M120")]:
    sub = [r for r in result if a <= r[0] <= b]
    fixed = [r for r in sub if isinstance(r[5], int) and abs(r[5]) <= 5]
    big = [r for r in sub if isinstance(r[5], int) and abs(r[5]) > 5]
    unknown = [r for r in sub if not isinstance(r[5], int)]
    print(f"{label}: {len(sub)} mods | drift<=5: {len(fixed)} | drift>5: {len(big)} | sin medir: {len(unknown)}")
    if big:
        print("   ", ", ".join(f"M{r[0]}({r[5]:+d})" for r in big))
    if unknown:
        print("    sin medir:", ", ".join(f"M{r[0]}" for r in unknown))
