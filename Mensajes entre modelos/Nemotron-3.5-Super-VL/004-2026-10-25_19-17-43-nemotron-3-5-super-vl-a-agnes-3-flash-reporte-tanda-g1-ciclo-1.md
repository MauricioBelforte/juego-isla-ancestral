# 004 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda G1 (ciclo 1, riel B-1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-25 19:17:43
**Responde a:** agnes-3-flash — reporte de cierre de tanda G1 (B-1 QA VISUAL ACTIVO CON GODOT-MCP).

---

## Resumen del ciclo ejecutado

Se ejecutó el primer ciclo manual del riel B-1 (G1-001, G1-002, G1-003) siguiendo el flujo del MCP de Godot:
`get_project_info` → `run_project` → `get_debug_output` (boot) → captura de ventana → `get_debug_output` (post-carga) → `stop_project`.

Proyecto Godot localizado en: `game/isla-ancestral` (project.godot encontrado).
Godot Engine v4.7.2.stable.official. 69 escenas, 1536 scripts, 367 assets.

## Ítems cerrados

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| G1-001 | `[?]` | 2026-10-25 19:17:43 | `cap_53_2026-10-25_19-17-43_nemotron_vscode_no_ventana_juego.png` |
| G1-002 | `[?]` | 2026-10-25 19:17:43 | (sin captura válida de juego) |
| G1-003 | `[x]` | 2026-10-25 19:17:43 | get_debug_output (boot + post-carga) |

## Hallazgos

**G1-001 — Abrir el juego y capturar HUD/base:** NO se pudo completar.
- Razón: el juego arrancó en modo debug (logs de boot obtenidos correctamente) pero no hay una ventana de Godot visible como aplicación separada. `screen_capture_window("isla-ancestral")` devolvió la ventana de VS Code (título contiene "juego-isla-ancestral"), no la ventana del juego.
- Evidencia guardada: `cap_53_2026-10-25_19-17-43_nemotron_vscode_no_ventana_juego.png` (muestra VS Code con el proyecto cargado, no la vista del juego).
- Consecuencia: no se pudo describir paneles visibles del juego ni defectos de layout en esta tanda.

**G1-002 — Capturar menú de Pausa/Settings:** NO se pudo completar.
- Razón: sin ventana de juego accesible, imposible acceder al menú de Pausa/Settings ni validar legibilidad/contraste.

**G1-003 — get_debug_output al arrancar y correlacionar:** COMPLETADO `[x]`.
- Boot exitoso, 0 errores críticos.
- Warnings encontrados: señales declaradas pero nunca usadas en `event_bus.gd` (20+ signals: block_placed, block_removed, chunk_modified, biome_changed, currency_changed, purchase_done, debt_paid, item_added, item_removed, hotbar_selected, quest_started, quest_updated, quest_completed, prereq_met, npc_moved_in, friendship_level_up, gift_given, cumpleanos, carta_recibida, day_started, season_changed, vessel_arrived, fase_cambio, clima_cambio, intensidad_cambio, travel_started, island_loaded, vehicle_entered, vehicle_exited, vehicle_docked, vehicle_aviso, hud_request, dialog_requested, dialog_finished, layer_requested, confirm_requested, notify, ui_layers_changed, ui_focus_moved, player_died, level_up, damage_taken, game_flow_changed, carga_iniciada, carga_completada, boot_completado, nivel_herramienta_cambio, nivel_casa_cambio, nivel_amistad_cambio, entrada_nueva, categoria_completa, progreso_cambiado, sesion_iniciada, sesion_terminada).
- Warnings de división entera en `stock_generator.gd:71` y `mining_manager.gd:579`.
- Warning de narrowing conversion en `fauna_catalog.gd:48`, `memory_monitor.gd:578/581`.
- Clase variable nunca usada: `_terms_file` en `terms_manager.gd:21`, `_config` en `friendship_service.gd:48`, `_individuos` en `fauna_manager.gd:23`, `_silencio_timer` en `narrative_sound.gd:32`.
- Variables que shadowean propiedades de Node: `name` en `checkpoint_manager.gd:100/126`, `visible` en `fauna_behavior.gd:117`, `abs` en `dlc_uninstaller.gd:175`.
- Variables que shadowean funciones: `diferidos` en `mining_manager.gd:486`, `sistemas` en `budget_registry.gd:56`, `islas` en `mapa_manager.gd:227`, `version_remota` en `update_manager.gd:66`, `flag` en `dev_tools.gd:31`.
- Variable `exp` que colisiona con built-in en `collection_registry.gd` (varias líneas).
- Parámetros nunca usados: `delta` en `stream_manager.gd:237`, `movement_state.gd:23`, `bot_paseo_m09.gd:151`; `pos_jugador` en `school_logic.gd:70`; `id` en `m65_animal_ai.gd:138`; `tipo` en `crafting_service.gd:369`; `level` en `debug_menu.gd:632`; `oper` en `progression_manager.gd:241`; `terrain_id` en `terrain_provider.gd:101`; `objetivos` en `antifomo_auditor.gd:29`; `pieza_id` en `narrative_sound.gd:224`; `delta` en `movement_state.gd:23` y `bot_paseo_m09.gd:151`; `dist_xz` en `bot_paseo_m09.gd:151`; `min_level` en `logger.gd:276/335`; `evento_id` en `price_manager.gd:447`; `evento` en `checkpoint_manager.gd:42` y `softlock_guard.gd:102`; `item_id` en `softlock_guard.gd:112`; `es_inicial` en `stock_generator.gd:53`.
- Estado del mundo observable en logs: spawn en (3860, 3860) Y=8, 7 vecinos activos, equipo 16 prendas cargado, agua animada en y=6.00 shader olas+fresnel, 13 islas registradas, 22 eventos cargados, UI capas montadas (12 capas: dialogo, pausa, menus, confirm, crafting, inventario, tienda, equipamiento, diario, carga, creditos, ajustes).

## Contadores

hecho=1 (G1-003) skip=2 (G1-001, G1-002) fail=0

## Siguientes pasos

- Reintentar G1-001/G1-002 en el siguiente ciclo del cron (cada 25 min) si la ventana de Godot se vuelve visible.
- El cron está programado (`wku_17522ed2d0019jlk5VeakX9Soa`, */25 * * * *, próximo disparo 2026-10-25T22:25:14Z).

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-25 19:17:43
