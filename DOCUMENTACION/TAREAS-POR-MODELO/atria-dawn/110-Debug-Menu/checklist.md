**Modelo:** atria-dawn (Atria Dawn Preview, Shanghai AI Laboratory)
**Plataforma:** Kilo Code
**Módulo:** 110-Debug-Menu
**Fecha:** 2026-09-16 (reserva log 928)

# Checklist personal tareas — 110-Debug-Menu

> **Fuente:** `DOCUMENTACION/110-Debug-Menu/plan-actual/05-Checklist.md` (revertido por auditoría 2026-09-14).
> Marcadores: `[ ]` pendiente · `[x]` completado (con evidencia) · `[?]` no resuelto (con dueño) · `[→]` movida a otro modelo.

## Evidencia base (verificación del código real) — HECHA

- [x] T-001 Ejecutar `test_debug_m110.gd` headless → **18 checks / 0 fallos, EXIT 0** (Log `_m110_a.txt`)
- [x] T-002 Ejecutar `test_debug_menu_headless.gd` headless → **22 checks / 0 fallos, EXIT 0** (Log `_m110_b.txt`)
- [x] T-003 Verificar **0 SCRIPT ERROR** en ambas suites (leaks de shutdown del motor no son de M110)
- [x] T-004 Leer `debug_menu.gd` (457 l) + config JSON: 3 pestañas, 15 comandos, RF1-RF10/RF14/16/18/RF20/RF-H/F12/solo-debug implementados

## Gaps cerrables con test (implementación nueva)

- [ ] T-005 RF4: implementar `set_season(temporada)` — duck-typing a `GameTime`/`WeatherService` (M29/M32) con alias `_season_verano` para test
- [ ] T-006 RF11: implementar `reset_npc(npc_id)` — duck-typing a `VillagerManager`/`NPCManager` (M19) con fallback honesto
- [ ] T-007 RF12: implementar `reset_puzzle(puzzle_id)` — duck-typing a `PuzzleRoom`/M24 con fallback honesto
- [ ] T-008 RF13: implementar `regenerar_chunk(cx, cz)` real — duck-typing a `VoxelTerrain`/M08 (reemplazar stub "chunks regenerados")
- [ ] T-009 RF15: implementar `toggle_fps(enabled)` — emite señal `fps_overlay_toggled` para M53 + métrica existente
- [ ] T-010 RF17: implementar `toggle_navigation(enabled)` — completa el par de RF16/RF18 ya existentes
- [ ] T-011 RF19: implementar `toggle_ai_states(enabled)` — completa la terna de toggles visuales
- [ ] T-012 Cablear RF4/RF11/RF12/RF13/RF15/RF17/RF19 en `ejecutar_comando()` match (acciones nuevas)

## Test nuevo con guardián anti-falso-verde

- [ ] T-013 Crear `test_m110_iter_atria.gd` (SceneTree + `_fin()` por bloque + `_summary()`) cubriendo los 7 gaps nuevos
- [ ] T-014 Guardián anti-falso-verde: inyección de aborto en un bloque → nombra el bloque y sale código 1 (probado en vivo)
- [ ] T-015 Ejecutar suite nueva headless **×3 corridas** → 0 fallos, 0 SCRIPT ERROR
- [ ] T-016 Cablear `test_m110_iter_atria.gd` en `.github/workflows/quality.yml`
- [ ] T-017 Regresión: re-ejecutar `test_debug_m110` + `test_debug_menu_headless` tras los gaps → siguen 0 fallos

## Reconciliación del checklist revertido (auditoría código↔código)

- [ ] T-018 Marcar `[x]` en 05-Checklist con evidencia de código real: RF1, RF2, RF3, RF5, RF6, RF7, RF8, RF9, RF10 (test b prueba cada uno)
- [ ] T-019 Marcar `[x]` RF14/RF16/RF18 (stubs + límites MAX_* + handler en match) con nota de que la integración visual es externa
- [ ] T-020 Marcar `[x]` RF20 (export ZIP+TXT + metadata + logs + screenshot opcional), RF H (consola 100 líneas + GameLogger), F12, solo-debug-build
- [ ] T-021 Marcar `[x]` secciones K (API: ya implementadas las que existen), M (security: is_debug_build + set_process(false)), O (limits), P (ServiceRegistry), Q (debug_menu.gd + config JSON existen)
- [ ] T-022 Dejar `[?]` con dueño: paneles UI C/D/E/F/G → M53; DebugVisualizer I → módulo visual nuevo; DiagnosticExporter J separado (hoy vive en debug_menu.gd); poi_list.tres → M54; debug_config.json N (hoy debug_menu_config.json cubre pestañas)
- [ ] T-023 Cerrar el sobre-cierre del `Totales` (138/138 "0 pendientes" → cuenta real `[x]`/`[?]`/`[ ]`)
- [ ] T-024 Actualizar header del 05-Checklist (firma agnes-2.5 → atria-dawn iter)

## Cierre administrativo

- [ ] T-025 Actualizar `04-Codigo.md` con las funciones nuevas + rutas reales
- [ ] T-026 Escribir `## Notas del Agente` en 04-Codigo.md (qué hice / qué no pude / recomendaciones)
- [ ] T-027 Generar log 928 con firma + evidencia
- [ ] T-028 Liberar M110 en los 4 registros (05-Checklist, CHECKLIST-GLOBAL, guía 08 si aplica, ESTADO-PARALELO)
- [ ] T-029 Actualizar BACKLOG-MASTER (iter 1 completada, siguiente en cola)
- [ ] T-030 Verificación UTF-8 final de todos los archivos tocados (0 mojibake)
