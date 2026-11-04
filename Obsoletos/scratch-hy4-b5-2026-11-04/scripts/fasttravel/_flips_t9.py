# -*- coding: utf-8 -*-
# Flips M69 tanda 9 (items 30 y 31) + contadores
import io, re

P = r"DOCUMENTACION\69-Fast-Travel\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()

F = []
F.append(("- [ ] Test de coherencia: 1000 teleports consecutivos [M]",
    "- [x] Test de coherencia: 1000 teleports consecutivos [M] → **G-5.3-Flash-Agente (2026-10-19):** `test_fast_travel_headless.gd` `_b9_mil_teleports` — 1000 `solicitar_viaje` consecutivas concedidas, señal `viaje_solicitado` emitida 1000 veces, desbloqueos sin drift, presupuesto **2 ms** (< 500 ms). Evidencia: «Teleports: 1000 consecutivos concedidos» + «presupuesto < 500 ms (2 ms)» + «sin drift de estado». CHECKS_MINIMOS 44→50 (medido 51)."))
F.append(("- [ ] Test de día/noche: comportamiento en diferentes horas [M]",
    "- [x] Test de día/noche: comportamiento en diferentes horas [M] → **G-5.3-Flash-Agente (2026-10-19):** `_b10_dia_noche` — barrido de las 24 horas con `GameTime.avanzar_hasta` real: `restriccion_temporal_activa()` == (noche **o** tormenta) hora por hora, hora restaurada al final. Evidencia: «Día/Noche: 24 horas consistentes con GameTime+Weather (0 desvíos)». Lección registrada: el esperado del test debía incluir la rama tormenta (el primer FALLO fue el TEST, no el servicio — corregido y documentado)."))

for old, new in F:
    assert s.count(old) == 1, "no unico: " + old
    s = s.replace(old, new)

old_totales = "**Totales:** 145 ítems · Completados: 120 · Pendientes: 18 · No resueltos: 7."
new_totales = "**Totales:** 145 ítems · Completados: 122 · Pendientes: 16 · No resueltos: 7."
assert s.count(old_totales) == 1
s = s.replace(old_totales, new_totales)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,re.M)); o=len(re.findall(r'^\- \[ \]',s,re.M)); q=len(re.findall(r'^\- \[\?\]',s,re.M))
print("checklist:", x, o, q, "total", x+o+q)

PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
pares = [
    ("30. - [ ] [69] Test de coherencia: 1000 teleports consecutivos [M]",
     " · [x] T9-M69 2026-10-19 (G-5.3-Flash-Agente): 1000 solicitudes en 2 ms sin drift — 51/0 PASS."),
    ("31. - [ ] [69] Test de día/noche: comportamiento en diferentes horas [M]",
     " · [x] T9-M69 2026-10-19 (G-5.3-Flash-Agente): barrido 24 h coherente con GameTime+Weather (0 desvíos) — 51/0 PASS; flips 05-Checklist (122/16/7)."),
]
for old, ev in pares:
    assert b.count(old) == 1, "no unico: " + old
    b = b.replace(old, old.replace("- [ ]", "- [x]") + ev)
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)

PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
old_cell = "🟡 Con dudas | 120/145 |"
new_cell = "🟡 Con dudas | 122/145 |"
assert g.count(old_cell) == 1
g = g.replace(old_cell, new_cell)
g = g.replace("+ K.24 portal-fail + K.29 carga)", "+ K.24 portal-fail + K.29 carga + K.30/K.31 tests)")
g = g.replace("→ 36/0 → 37/0 → 47/0;", "→ 36/0 → 37/0 → 47/0 → 51/0;")
g = g.replace("120/18/7=145 en disco = fila.", "122/16/7=145 en disco = fila.")
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("backlog + fila ok")
