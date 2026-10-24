"""Diagnostico temporal: muestra las celdas de cada fila mal formada."""
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
GLOBAL = RAIZ / "CHECKLIST-GLOBAL.md"

lineas = GLOBAL.read_text(encoding="utf-8").split("\n")
# localizar encabezado
inicio = None
for i, l in enumerate(lineas):
    if l.startswith("| ID |") or l.startswith("| ID|"):
        inicio = i
        break
cab = lineas[inicio]
n_esp = len(cab.strip().strip("|").split("|"))
print("encabezado en L%d, columnas=%d" % (inicio + 1, n_esp))
print("COLUMNAS:", [c.strip() for c in cab.strip().strip("|").split("|")])
print()

for i in range(inicio + 2, len(lineas)):
    l = lineas[i]
    if not l.startswith("|"):
        continue
    cuerpo = l.strip()
    if not cuerpo.startswith("|"):
        continue
    celdas = cuerpo.strip("|").split("|")
    # el strip("|") se come el ultimo pipe; para medir igual que el gate:
    # el gate hace split sobre '|' tras quitar el primero y el ultimo
    n = len(celdas)
    if n == n_esp:
        continue
    print("=" * 70)
    print("L%d  celdas=%d  termina_en_pipe=%s  len=%d" % (i + 1, n, cuerpo.endswith("|"), len(l)))
    for j, c in enumerate(celdas):
        txt = c.strip()
        if len(txt) > 55:
            txt = txt[:55] + "..."
        print("   [%2d] %s" % (j, txt))
