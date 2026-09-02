# Log 384: M61 Rendimiento — Iteración 2 (benchmark visual): bench_scene_a + recorder + fix de boot; medición bloqueada por regresiones ajenas

**Fecha:** 2026-09-01
**Hora:** 17:05
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 2 del módulo M61 (Rendimiento, V2 — benchmark visual) implementada en su parte de herramienta: el bench oficial `bench_scene_a.tscn` + `bench_recorder.gd` (recorrido 90 s con 6 waypoints, overlay FPS/draw calls/objetos, muestreo, JSON en user://logs/bench/ y sección `render` con BudgetProfile). Se aplicó además un fix de mantenimiento crítico (indentación de equipment_manager.gd) que desbloqueó el boot del proyecto, y se documentaron las regresiones ajenas que aún impiden la ejecución real de la medición.

## Cambios Realizados

### M61 — iter 2 (bench visual)
- `game/isla-ancestral/scenes/bench_scene_a.tscn` — escena de benchmark oficial: terreno voxel M08 (world_generator seed 42, radio 256, altura 40, paleta Maldivas completa), VoxelViewer 256, Camera3D con 6 waypoints (norte, NE, este, sur, oeste, cenital) mirando al centro.
- `game/isla-ancestral/scripts/performance/bench_recorder.gd` — recorder: interpolación 15 s/waypoint (90 s total), Label overlay con `FPS | Draw calls | Objetos | Waypoint N/6` (evidencia visual en capturas), muestreo cada 30 frames (`Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME`, `RENDER_TOTAL_OBJECTS_IN_FRAME`, `TIME_PROCESS`), sección `render` con `BudgetProfile.begin/end_section` + `frame_post_draw`, JSON final `user://logs/bench/bench_AAAAMMDD.json` (medias, draw_calls_max, hardware vía RenderingServer, veredicto `OK >=60 FPS`/`WARN`).
- Metodología RF D.55 (etiquetas Profiler) cumplida con BudgetProfile; RF4/E: draw calls/objetos medibles desde la escena.

### Fix de boot (regresión global)
- `scripts/player/equipment_manager.gd` — 35 líneas con indentación de ESPACIOS convertidas a TABS (conversión mecánica, sin cambio de lógica). Causa del `Parser Error: Used space character for indentation instead of tab as used before in the file` que bloqueaba el arranque de CUALQUIER escena (Debugger Break verificado 2 veces). Documentado en guía 07 §9.60.

### Verificación
- Post-fix: `godot --headless -s res://tools/asset_validator.gd` → 198/198 OK sin break (el proyecto vuelve a compilar en modo script).
- El run de la escena bench intentado 2 veces: bloqueado por regresiones ajenas (ver abajo).

## Lo que NO pude hacer (honestidad obligatoria)

- **[?] Ejecución del bench + mediciones reales** — bloqueada por regresiones ajenas sin dueño activo:
  1. `scripts/fauna/fauna_manager.gd:79/92/116` (M36/M37) — `Parser Error: Function "_get_registry()" not found in base self`.
  2. `scripts/player/equipment_manager.gd:106/122` (M13/M155) — `Key "body_vest_explorer" / "acc_backpack" was already used in this dictionary`.
  No las pisé (regla §21.4.2: trabajo de módulos con dueño); se documentan en guía 07 §9.60 y con AVISO GLOBAL en ESTADO-PARALELO (el árbol dev no compila hasta corregirlas).

## Archivos Modificados/Creados

- Creados: `scenes/bench_scene_a.tscn`, `scripts/performance/bench_recorder.gd`, capturas intento `tools/mcp/godot-mcp/capturas/61-Rendimiento/`
- Modificados: `scripts/player/equipment_manager.gd` (indent 35 líneas), `DOCUMENTACION/07-GUIA-GODOT.md` (§9.60), `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` (bloque iter 2), `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` (sección iter 2), `CHECKLIST-GLOBAL.md` (fila 61 → 🟡 27/130), `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M61), `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M61 + AVISO GLOBAL), `Logs/ULTIMO_NUMERO.txt` (→384 según reserva consumida)

## Verificación final

- Bench implementado y documentado; ejecución pendiente de que M36/M13/M155 corrijan sus parse errors (90 s de corrida una vez compilado — quedó el camino en 04-Codigo iter 2).
