"""Diagnostico temporal: filas con drift + valores medidos en disco."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import verificar_checklist as ver  # noqa: E402

RAIZ = Path(__file__).resolve().parent.parent
GLOBAL = RAIZ / "CHECKLIST-GLOBAL.md"
DOC = RAIZ / "DOCUMENTACION"

# ids con drift segun 11-Auditoria (26: 15 progreso + 10 estado + 1 prosa)
IDS = [10, 16, 40, 48, 68, 72, 77, 108, 138, 156,          # estado sobrescrito
       11, 15, 17, 20, 23, 24, 27, 45, 50, 62, 93, 104, 139, 161, 162,  # progreso
       73]                                                 # prosa anexa

lineas = GLOBAL.read_text(encoding="utf-8").split("\n")
inicio = next(i for i, l in enumerate(lineas) if l.startswith("| ID |"))
n_esp = len(lineas[inicio].strip().strip("|").split("|"))

for i in range(inicio + 2, len(lineas)):
    l = lineas[i]
    if not l.startswith("|"):
        continue
    celdas = l.strip().strip("|").split("|")
    celdas = [c.strip() for c in celdas]
    # buscar el id en cualquier posicion (las filas con celdas vacias al inicio)
    idx_id = None
    for j, c in enumerate(celdas[:3]):
        if c.isdigit() and int(c) in IDS:
            idx_id = j
            break
    if idx_id is None:
        continue
    mid = int(celdas[idx_id])
    nombre = celdas[idx_id + 1]
    cl = DOC / nombre / "plan-actual" / "05-Checklist.md"
    if cl.exists():
        x, p, d = ver.contar_checklist(cl)
        medido = "%d/%d" % (x, x + p + d)
    else:
        medido = "SIN-CHECKLIST"
    print("L%-4d id=%-4d n=%-2d %s" % (i + 1, mid, len(celdas), nombre))
    print("      [Estado]=%r  [Progreso]=%r  medido=%s" % (celdas[idx_id + 2], celdas[idx_id + 3], medido))
    print("      [4]=%r [5]=%r [6]=%r [7]=%r" % tuple(celdas[idx_id + 4:idx_id + 8]))
