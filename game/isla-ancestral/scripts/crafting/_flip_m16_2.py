# -*- coding: utf-8 -*-
# Pista general en BUG-138 + flip M16 item 2 (doble-craft) + contadores
import io

PB2 = r"DOCUMENTACION\11-BUGS.md"
s2 = io.open(PB2, encoding="utf-8").read()
ancla = "Descubierto al correr el QA del item 7 del plan"
ext = ("| | **PISTA GENERAL (agregada por encargo del director, canal G-5.3 #136, 2026-10-20):** las cadenas `call_deferred` de reintento "
       "SIN TOPE son un patrón a vigilar en TODO el codebase (churn + crash si el nodo se libera dentro de la ventana de reintento — "
       "caso BUG-138). Cualquier `func *_deferred()` que se re-arme a sí misma debe llevar tope de reintentos + guard `is_inside_tree()`. "
       "Sweep sugerido para el dueño M62/M99: grep `call_deferred(` en scripts/ y auditar los handlers que re-arman. | | |")
lineas = s2.split("\n")
idx = next(i for i, l in enumerate(lineas) if l.startswith("| BUG-138 |"))
assert ancla in lineas[idx], "ancla no en fila BUG-138"
lineas.insert(idx + 1, ext)
io.open(PB2, "w", encoding="utf-8", newline="\n").write("\n".join(lineas))
print("pista general en BUG-138 ok")

P = r"DOCUMENTACION\16-Crafting\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()
old = "- [ ] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M]"
new = ("- [x] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M] → **G-5.3-Flash-Agente (2026-10-19):** "
       "`crafting_service.gd` — implementado el RECHAZO SILENCIOSO (opción del ítem, mejor que cola para el cozy: log limpio): "
       "clave **(frame, rec_id, cantidad)** con `Engine.get_process_frames()`, la primera llamada gana, las siguientes devuelven false "
       "SIN emitir `crafting_failed`; solo cuenta el ÚLTIMO CRAFT EXITOSO (si el primero falló, el reintento pasa por validaciones normales). "
       "La clave incluye cantidad para no colisionar con el craft N (contrato del suite: rec_pico_cobre/1 en L67 y rec_pico_cobre/5 en L292 conviven). "
       "Evidencia: QA `scripts/crafting/qa_m16_doble_craft.gd` **8/0, EXIT 0** — «2do craft mismo frame rechazado en silencio», "
       "«señal completed exactamente 1 vez», «cero señales de fallo (log limpio)», «resultado entregado 1 sola vez» (Inventario real), "
       "«craft en frame nuevo funciona» (no bloqueo permanente), «otra cantidad en mismo frame valida normal». "
       "Regresión `test_crafting.gd` 0 fallos EXIT 0. Reemplaza el comentario muerto 'M16 L168' que describía el rechazo sin implementarlo.")
assert s.count(old) == 1, s.count(old)
s = s.replace(old, new)

old_totales = "**Totales:** 203 items - Completados: 162 - Pendientes: 28 - No resueltos: 13."
new_totales = "**Totales:** 203 items - Completados: 163 - Pendientes: 27 - No resueltos: 13."
assert s.count(old_totales) == 1
s = s.replace(old_totales, new_totales)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,re.M)); o=len(re.findall(r'^\- \[ \]',s,re.M)); q=len(re.findall(r'^\- \[\?\]',s,re.M))
print("checklist:", x, o, q, "total", x+o+q)

PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
oldb = "2. - [ ] [16] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M]"
newb = ("2. - [x] [16] Doble llamado a craft en el mismo frame: cola interna o rechazo silencioso [M] · [x] T15-M16 2026-10-19 (G-5.3-Flash-Agente): "
        "dedupe silencioso clave (frame,rec_id,cantidad) — qa_m16_doble_craft.gd 8/0 + regresión 0 fallos; flips 16-Crafting/05 (163/27/13).")
assert b.count(oldb) == 1
b = b.replace(oldb, newb)
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)

PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
assert g.count("| 162/203 |") == 1
g = g.replace("| 162/203 |", "| 163/203 |")
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("backlog + fila ok")
