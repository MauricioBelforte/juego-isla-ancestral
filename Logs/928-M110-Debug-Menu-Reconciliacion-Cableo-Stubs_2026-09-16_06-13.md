# Log 928: M110 Debug Menu — reconciliación de auditoría, cableado de 5 stubs falsos y gaps

**Fecha:** 2026-09-16
**Hora:** 06:13
**Modelo:** atria-dawn
**Plataforma:** Kilo Code

> **Nota de recuperación (2026-09-16 20:50):** este log fue borrado de `Logs/` por una operación
> git de otro agente (archivos no rastreados). Se recrea con el contenido original. El trabajo que
> documenta ya está registrado en `CHECKLIST-GLOBAL.md` fila 110 (🟡 121/225) y en el
> `05-Checklist.md` + `04-Codigo.md` del módulo, que sí sobrevivieron por estar rastreados.

## Resumen

Reconciliación completa del Módulo 110 (Debug Menu): descubrí y corregí **5 stubs de texto falsos**
en `ejecutar_comando()` (devolvían `ok:true` sin ejecutar nada), cableé a APIs reales, implementé
los gaps de la auditoría y reconcilié el checklist. Módulo liberado a 🟡.

## Hallazgo principal — 5 stubs de texto falsos

`debug_menu.gd::ejecutar_comando()` tenía 5 comandos (teleport, spawn, cambiar_hora, cambiar_clima,
exportar) que devolvían `{"ok": true}` **sin ejecutar nada**. Confirmado con `git show HEAD` (los
tests no podían detectarlos porque solo verificaban el formato de la respuesta).

## Cambios Realizados

- **5 stubs cableados a APIs reales:**
  - `set_game_time` → `GameClock.avanzar_hasta()` (no existe `set_hora`)
  - `set_weather` honesta: WeatherService es 100% determinista → reporta + emite señal
    `clima_solicitado` (no existe `set_clima`)
  - teleport / spawn / exportar → APIs reales
- **Gaps implementados:** RF4 (`set_season` honesta + señal `estacion_solicitada`), RF11
  (`reset_npc` duck-typing), RF12 (`reset_puzzle` + `_buscar_puzzle_room`), RF13 (`regenerar_chunk`
  + `_obtener_voxel_terrain`), RF15/RF17/RF19 (`toggle_fps`/`toggle_navigation`/`toggle_ai_states`
  + `_toggle_visual` + señal `toggle_visual_cambiado`), extras `set_vida`/`avanzar_dia`/
  `limpiar_cache`.
- **Helper `_obtener_player()`** con fallback al grupo `"player"` (el Player real vive anidado en
  `main_island`, no en `/root/Player`).
- **`debug_menu_config.json`:** pestañas 3→5 (añadidas `entidades` + `visualizacion`), comandos
  15→24.
- **3 suites headless nuevas: 18+22+27 = 67 checks, 0 fallos, 0 SCRIPT ERROR.**
- **`05-Checklist.md` reconciliado:** 225 ítems, **121 `[x]` con evidencia**, 104 `[?]` todos UI
  con dueño (M110-UI/M102/M64/M117/M103).
- **`04-Codigo.md`** con Notas del Agente (historial sin borrar).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/debug/debug_menu.gd` (730 líneas, 47 funciones, 3 señales)
- `game/isla-ancestral/scripts/debug/test_m110_iter_atria.gd`, `test_debug_m110.gd`,
  `test_debug_menu_headless.gd` (3 suites)
- `game/isla-ancestral/data/debug/debug_menu_config.json` (5 pestañas, 24 comandos)
- `DOCUMENTACION/110-Debug-Menu/plan-actual/05-Checklist.md` + `04-Codigo.md`

## Estado de M110

🟡 **Liberado — 121/225.** Los 104 `[?]` son todos dependencias de UI con dueño claro (M110-UI,
M102, M64, M117, M103). **No es ✅** hasta que esas dependencias se implementen.

## Lecciones aprendidas (para no repetir)

- **`String.join()` en GDScript 4.x es método del String separador**: `", ".join(PackedStringArray(arr))`,
  NO `arr.join(", ")`.
- **Inferencia de tipos con ternarias que devuelven `null`** falla: usar tipo explícito
  (`var npc: Node = ... if ... else null`).
- **Los tests headless cargan TODA la escena main_island** — cualquier comando que toque nodos de
  escena debe esperar a `current_scene` + grupo `"player"`.
- **`FileAccess.open` puede devolver null** — siempre null-check.
- **Git es la fuente de la verdad para "¿estaba implementado?"**: `git show HEAD:archivo` reveló
  los stubs falsos que los tests no podían detectar.
