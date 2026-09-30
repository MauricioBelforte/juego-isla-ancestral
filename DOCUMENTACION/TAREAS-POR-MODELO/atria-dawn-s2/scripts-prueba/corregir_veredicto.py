# -*- coding: utf-8 -*-
"""Corrige el veredicto de qa_documental.txt: M07 NO limpio (P-40)."""
import io, os

BASE = r"D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\TAREAS-POR-MODELO\atria-dawn-s2"
REP = os.path.join(BASE, "qa_documental.txt")

with io.open(REP, encoding="utf-8") as f:
    t = f.read()

i = t.find(u"VEREDICTO FINAL")
if i == -1:
    i = t.find(u"=== RESUMEN")
cuerpo = t[:i]

NUEVO = u"""======================================================================
VEREDICTO FINAL (corregido 2026-09-25, P-40 — el detalle manda)
======================================================================
REGLA: cuando el detalle diga "FALTA: X" y el resumen diga "limpio", el
detalle manda. El resumen es lo que lee el coordinador.

  M07   NO LIMPIO — drift doc<->codigo.
        105/105 [x], 0 [?], 0 [ ] EN EL CHECKLIST (eso no se discute).
        PERO 04-Codigo.md cita 9 rutas y 3 NO existen:
          scripts/core/thread_pool.gd
          scripts/world/voxel_world.gd
          scripts/data/game_state.gd
        Estaban bajo el titulo "Scripts implementados" (columna Estado
        "Pendiente", pero en una seccion de inventario de codigo).
        Verificado con `git log --all -- '*nombre*'`: NUNCA existieron en
        el historial; unicos matches = skills de terceros en .claude/skills.
        => plan aspiracional documentado como codigo. Patron M167/M119.
        ACCION: reubicadas a seccion "Scripts previstos (NO implementados)"
        con advertencia explicita. mimo notificado (su sello Log 1148
        cubrio over-mark si no reviso las 9 rutas). M07 baja a 🟡 si mimo
        no confirma. Nada de M07 se commitea sin visto bueno del
        coordinador.

  M133  LIMPIO  127/127 [x], 0 [?], 0 [ ]  - sello Hy3 (Log 219) valido
  M134  LIMPIO  100/100 [x], 0 [?], 0 [ ]  - sello Hy3 (Log 221) valido
  M135  LIMPIO  134/134 [x], 0 [?], 0 [ ]  - sello Hy3 (Log 197) valido
  M136  LIMPIO  199/199 [x], 0 [?], 0 [ ]  - sello Hy3 (Log 198) valido

Los 4 sellos de mimo sobre estos modulos son validos.

LECCION (auto): mi primer veredicto dijo "los 5 pasan" excusandome en que
la columna Estado decia "Pendiente" — pero el titulo de la seccion era
"Scripts implementados" y un archivo 04-Codigo.md es un inventario de
codigo. Eso es exactamente la misma trampa de T-101: cerrar con un resumen
que ignora los propios hallazgos del detalle. El falso verde es el riesgo,
no el detalle.
"""

with io.open(REP, "w", encoding="utf-8", newline="\n") as f:
    f.write(cuerpo + NUEVO)
print("veredicto corregido:", REP)
