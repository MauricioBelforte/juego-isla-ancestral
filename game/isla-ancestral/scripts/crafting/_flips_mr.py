# -*- coding: utf-8 -*-
# Flips M16 N.1 (RF-MR1..MR7) + Totales + fila + cola
import io, re

P = r"DOCUMENTACION\16-Crafting\plan-actual\05-Checklist.md"
s = io.open(P, encoding="utf-8").read()

EVID = ("**G-5.3-Flash-Agente (2026-10-19, tanda 28): rebanada service-layer del bloque MR — "
        "QA `scripts/crafting/qa_m16_mejora_reparacion.gd` **15/0, EXIT 0** (Inventario real) + regresión `test_crafting.gd` 0 fallos. "
        "Implementado: `crafting_service.gd` (mejorar_herramienta/reparar_herramienta, señales RF-MR6, balance MR4, YAML/MR3 data-driven desde "
        "`data/crafting/mejora_herramienta.json`, persistencia aditiva RF-MR7) ")

F = []
F.append(("- [ ] RF-MR1: `mejorar_herramienta(item_id: String) -> Dictionary` en `CraftingService` con\n  retorno honesto `{ok, motivo, nivel_anterior, nivel_nuevo}` (sin consumir si falla) [M]",
    "- [x] RF-MR1: `mejorar_herramienta(item_id: String) -> Dictionary` en `CraftingService` con\n  retorno honesto `{ok, motivo, nivel_anterior, nivel_nuevo}` (sin consumir si falla) [M] → " + EVID +
    "— «mejora 0->1 con retorno honesto» + «sin materiales: no consume ni emite» + techo «motivo nivel_maximo» + «item no-herramienta rechazado»."))
F.append(("- [ ] RF-MR2: `reparar_herramienta(item_id: String) -> Dictionary` — restaura la durabilidad\n  de la herramienta al maximo de su nivel actual, retorno honesto idem [M]",
    "- [x] RF-MR2: `reparar_herramienta(item_id: String) -> Dictionary` — restaura la durabilidad\n  de la herramienta al maximo de su nivel actual, retorno honesto idem [M] → " + EVID +
    "— «reparar OK con señal» + «durabilidad objetivo = máximo del nivel actual» (M13 aplica el techo real en MR16)."))
F.append(("- [ ] RF-MR3: schema `data/crafting/mejora_herramienta.json`: tabla por tipo de herramienta\n  (hacha/martillo/azada/machete) con `coste_nivel[N]` (materiales por nivel) y `nivel_maximo`\n  por tipo [M]",
    "- [x] RF-MR3: schema `data/crafting/mejora_herramienta.json`: tabla por tipo de herramienta\n  (hacha/martillo/azada/machete) con `coste_nivel[N]` (materiales por nivel) y `nivel_maximo`\n  por tipo [M] → " + EVID +
    "— schema creado (4 tipos, 3 niveles c/u, coste_reparacion por tipo, duracion_base/por_nivel, efectividad_por_nivel); «inventario + schema MR3 cargados»."))
F.append(("- [ ] RF-MR4: funciones de balance `durabilidad_maxima(tipo, nivel)` y\n  `efectividad(tipo, nivel)` — curva por tipo que M13 consume para escalado [M]",
    "- [x] RF-MR4: funciones de balance `durabilidad_maxima(tipo, nivel)` y\n  `efectividad(tipo, nivel)` — curva por tipo que M13 consume para escalado [M] → " + EVID +
    "— «durabilidad_maxima curva nivel 3 (250)» + «efectividad nivel 2 = 1.30»."))
F.append(("- [ ] RF-MR5: integracion con M14 — mejorar/reparar consumen materiales del inventario via\n  `InventoryService`; fallo con motivo `materiales_insuficientes` **sin consumo parcial** [M]",
    "- [x] RF-MR5: integracion con M14 — mejorar/reparar consumen materiales del inventario via\n  `InventoryService`; fallo con motivo `materiales_insuficientes` **sin consumo parcial** [M] → " + EVID +
    "— «materiales descontados exactos (RF-MR5)» (coste por nivel exacto) + fallo sin consumo («sin materiales: no consume ni emite»)."))
F.append(("- [ ] RF-MR6: senales `herramienta_mejorada(item_id, nivel)` y\n  `herramienta_reparada(item_id, durabilidad)` emitidas solo en exito [S]",
    "- [x] RF-MR6: senales `herramienta_mejorada(item_id, nivel)` y\n  `herramienta_reparada(item_id, durabilidad)` emitidas solo en exito [S] → " + EVID +
    "— «señal herramienta_mejorada emitida 1 vez» (y 0 con fallo) + «reparar OK con señal»."))
F.append(("- [ ] RF-MR7: persistencia del `nivel_mejora` por item en el save de M59 (campo aditivo,\n  sin romper partidas existentes) [M]",
    "- [x] RF-MR7: persistencia del `nivel_mejora` por item en el save de M59 (campo aditivo,\n  sin romper partidas existentes) [M] → " + EVID +
    "— «save contiene nivel_mejora» + «restore de save viejo (sin campo) no rompe» + «restore recupera nivel»."))

for old, new in F:
    assert s.count(old) == 1, "no unico: " + old[:60]
    s = s.replace(old, new)

old_totales = "**Totales:** 203 items - Completados: 167 - Pendientes: 23 - No resueltos: 13."
new_totales = "**Totales:** 203 items - Completados: 175 - Pendientes: 15 - No resueltos: 13. (item 11 flipado en el mismo dia por la tanda 27.)"
assert s.count(old_totales) == 1
s = s.replace(old_totales, new_totales)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
x=len(re.findall(r'^\- \[x\]',s,re.M)); o=len(re.findall(r'^\- \[ \]',s,re.M)); q=len(re.findall(r'^\- \[\?\]',s,re.M))
print("checklist:", x, o, q, "total", x+o+q)

PB = r"DOCUMENTACION\TAREAS-POR-MODELO\G-5.3-Flash-Agente\BACKLOG-MASTER.md"
b = io.open(PB, encoding="utf-8").read()
import re as r2
for n in [13, 14, 15, 16, 17, 18, 19]:
    m = r2.search(r'%d\. - \[ \] \[16\] RF-MR[^\n]*' % n, b)
    assert m, "no: %d" % n
    ev = {13: "QA 15/0 ( retorno honesto + techo + no-herramienta)",
          14: "QA 15/0 (señal + durabilidad objetivo)",
          15: "schema data/crafting/mejora_herramienta.json (4 tipos × 3 niveles)",
          16: "QA 15/0 (curvas 250/1.30)",
          17: "QA 15/0 (descuento exacto RF-MR5)",
          18: "QA 15/0 (señales solo-éxito)",
          19: "QA 15/0 (persistencia aditiva: save viejo no rompe)"}
    b = b.replace(m.group(0), m.group(0).replace("- [ ]", "- [x]") + " · [x] T28-M16 (G-5.3): " + ev[n] + " (T28).")
io.open(PB, "w", encoding="utf-8", newline="\n").write(b)
print("backlog ok")

PG = "CHECKLIST-GLOBAL.md"
g = io.open(PG, encoding="utf-8").read()
assert g.count("| 168/203 |") == 1
g = g.replace("| 168/203 |", "| 175/203 |")
io.open(PG, "w", encoding="utf-8", newline="\n").write(g)
print("fila global 175/203 ok")
