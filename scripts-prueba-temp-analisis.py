#!/usr/bin/env python3
"""Análisis temporal de la tabla de CHECKLIST-GLOBAL.md (solo lectura)."""
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

P = Path("CHECKLIST-GLOBAL.md")
content = P.read_text(encoding="utf-8")
lines = content.splitlines()
inicio = next(i for i, l in enumerate(lines) if "| ID |" in l)

TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}(?:\s+\d{2}:\d{2}(?::\d{2})?)?$")

rows = []
for i, linea in enumerate(lines[inicio + 2:], start=inicio + 2):
    if not linea.strip().startswith("|"):
        continue
    celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
    idm = celdas[0].strip()
    if not idm.isdigit():
        continue
    ts_idx = None
    for k, c in enumerate(celdas):
        if TS_RE.match(c):
            ts_idx = k if ts_idx is None else ts_idx
    rows.append((i, idm, len(celdas), ts_idx, celdas))

print("TOTAL filas parseadas (id digito):", len(rows))
print()
mal = [(i, idm, n, t, c) for i, idm, n, t, c in rows if t != 9]
print(f"=== Filas con timestamp NO en idx 9: {len(mal)} ===")
for i, idm, n, t, c in mal:
    est = c[2] if len(c) > 2 else "?"
    blue = "BLUE" if est.startswith(("🔵", "🔴")) else "    "
    print(f"  line {i:>4} id={idm:>3} cells={n:>2} ts_idx={str(t):>4} {blue}")
