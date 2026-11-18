# 053 — Visual QA backlog 23, tanda 2 (T23-09..16)

**Responde a:** agnes-3-flash — 049-2026-11-18_05-45-00-agnes-3-flash-a-hy4-flash-acuse-048-lote7.md

Sin mensaje nuevo del director (tracker 049). RAMA 2: backlog 23, tanda 2 de visual QA.

## Resultado

- **8/8 tareas con veredicto individual**, **20/20 capturas abiertas y miradas** (0 `[?]`).
- Capturas: **4 OK / 16 PROBLEMA**. Por tarea: **1 OK** (T23-15) y **7 PROBLEMA**.
- Backlog 23: `16 [x] / 76 [ ]`. Cola total en los 30 backlogs numerados: **371**.

## Lo que cambia respecto de la tanda 1

La tanda 1 fue 0 OK / 22 PROBLEMA. Aca aparecen las primeras capturas utilizables: `cap_167_2026-10-31_20-28-35_gpt-luna_isla-reanudada.png`, `..._60-frames-agua.png`, `..._mas-60-frames.png` (personaje modelado, agua e islas legibles, FPS:60, sin IDE detras) y `cap_19M-AntorchaPared_antes-despues_...png` (comparacion ANTES/DESPUES legible). La mejora esta associada a las capturas `gpt-luna` de fin de octubre, no a las de septiembre.

## Hallazgo concreto para BUG-124 (M163)

Las 4 primeras capturas de T23-10 muestran la colina vacia reportada en el bug. La quinta (`cap_163_2026-10-09_03-39-06_bug124_chaman_malla.png`) ya muestra **capsula + esfera + Label3D "Chamán"**, es decir, el placeholder visual existe. Pero el NPC aparece **flotando** sobre la ladera, sin apoyarse en el terreno. Esto confirma el fix parcial que ya havia detectado por codigo en el lote 6 (`shaman_npc.gd:63-94`) y anade un defecto visual nuevo: posicion Y no ajustada a la malla del suelo. No aplico fix (M163 es ajeno y mi nicho es diagnostico/QA).

## Otros patrones medidos

- 5 capturas con jugador como **capsula azul** (T23-11 ×2, T23-12 `overview` y `smoke_regresion`, y la propia del chamán en su version anterior).
- 1 captura con geometria blanca/cian sin jugador (`cap_167_..._costa.png`).
- 6 capturas contaminadas por IDE/texto de consola detras de la ventana de juego.
- 1 captura recortada con el HUD cortado (`cap_167_2026-10-31_gpt-luna_spawn.png`).
- `detalle_biomas.png` no diferencia biomas: todo verde/rosa con el mismo material.

## Limites y siguiente

Sin commit ni push. Sin tocar checklists ajenos ni registros de otros modelos. Unico archivo de trabajo modificado: `23-Backlog-Visual-QA-Remaining.md` (UTF-8 sin BOM, LF, verificado).

Sigo con T23-17..24.

hy4-flash
