# -*- coding: utf-8 -*-
# Flip M16 item 11 (rollback lleno) + Totales + fila
import io, re

P = r"DOCUMENTACION\16-Crafting\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()
old = "- [ ] Test: rollback exacto ante inventario lleno en ambos destinos [C] [S]"
if s.count(old) == 0:
    old = "- [ ] Test: rollback exacto ante inventario lleno en ambos destinos [C]"
assert s.count(old) == 1, s.count(old)
new = ("- [x] Test: rollback exacto ante inventario lleno en ambos destinos [C] → **G-5.3-Flash-Agente (2026-10-19):** "
       "el `[C]` era sobreestimado — determinista headless con el Inventario REAL. QA `scripts/crafting/qa_m16_rollback_lleno.gd` "
       "**8/0, EXIT 0**: BOLSILLO+MOCHILA+CASA llenos hasta el último slot (junk único por slot, contados con total_slots/slots_usados), "
       "materiales de la receta presentes en su propio slot → craft falla con motivo **'inventario_lleno'** (sin señal completed) y el "
       "**rollback conserva el conteo EXACTO de cada material** (diff 0) sin resultado fabricado. El `[C]` temía el caso dual-destino: "
       "el fallback bolsa→casa de M14 y el reembolso atómico de M39 D8 (todo-o-nada) aguantan el caso límite.")
s = s.replace(old, new)

old_totales = "**Totales:** 203 items - Completados: 167 - Pendientes: 23 - No resueltos: 13."
new_totales = "**Totales:** 203 items - Completados: 168 - Pendientes: 22 - No resueltos: 13."
assert s.count(old_totales) == 1
s = s.replace(old_totales, new_totales)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,re.M)); o=len(re.findall(r'^\- \[ \]',s,re.M)); q=len(re.findall(r'^\- \[\?\]',s,re.M))
print("checklist:", x, o, q, "total", x+o+q)

PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
import re as r2
m = r2.search(r'\d+\. - \[ \] \[16\] Test: rollback exacto ante inventario lleno en ambos destinos \[C\]', b)
assert m, "item 11 no encontrado"
oldb = m.group(0)
b = b.replace(oldb, oldb.replace("- [ ]", "- [x]") +
    " · [x] T27-M16 (G-5.3): 3 contenedores llenos + rollback exacto (diff 0, motivo inventario_lleno) — qa_m16_rollback_lleno.gd 8/0; flips 16-Crafting/05 (168/22/13).")
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)

PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
assert g.count("| 167/203 |") == 1
g = g.replace("| 167/203 |", "| 168/203 |")
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("backlog + fila ok")
