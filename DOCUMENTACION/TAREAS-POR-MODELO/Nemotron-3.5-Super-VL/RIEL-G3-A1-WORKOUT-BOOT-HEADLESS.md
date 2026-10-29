# RIEL-G3 — BOOT HEADLESS + INTROSPECCIÓN DEL EVENT BUS (cierra la A1-WORKOUT de Hy3; 6 items)

**Creado por:** GLM-5.3-Flash (agente) para Nemotron-3.5-Super-VL | **Fecha:** 2026-10-28
**Origen:** deuda A1-WORKOUT declarada por Hy3 en su despedida (429): "confirmar el A1-WORKOUT (boot + conexiones) en tu ciclo para cerrar la deuda de M14 de forma runtime, no solo estática".
**Caveat de Hy3 (aprendé de él):** en modo `--script` Godot NO carga autoloads (`get_node('/root/EventBus')` = null) — la sonda de introspección corre DENTRO del juego completo.

| # | Tarea (output corto) | Evidencia |
|---|---|---|
| G3-1 | Reproducir el boot headless de Hy3: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --quit` → registrar EXIT y evitar SCRIPT ERROR (su medición: EXIT 0, pila DOM-UI sin error) | EXIT observado — EXIT_CODE=0, 0 SCRIPT ERROR, pila DOM-UI OK. Log completo capturado: 13 módulos registrados, DOM-UI 12 capas montadas, escena principal cargada (2026-10-28 22:10) | [x] |
| G3-2 | Sonda de introspección de conexiones: dentro del juego (no --script), registrar por cada una de las 54 señales del bus: declarada / connect(s) reales en arranque / emit(s) reales. Usar tu plantilla de introspección del playbook (A1-WORKOUT) | tabla 54 filas — 60 frames, 113 señales conectadas, 54 declaradas en event_bus.gd, 2 con >=1 emisión (weather.intensidad_cambio x1, infra.game_flow_changed x1), 52 con 0 (block_placed, block_removed, chunk_modified, biome_changed, currency_changed, purchase_done, debt_paid, item_added, item_removed, hotbar_selected, quest_started, quest_updated, quest_completed, prereq_met, npc_moved_in, friendship_level_up, gift_given, cumpleanos, carta_recibida, day_started, season_changed, vessel_arrived, fase_cambio, clima_cambio, travel_started, island_loaded, vehicle_entered, vehicle_exited, vehicle_docked, vehicle_aviso, hud_request, dialog_requested, dialog_finished, layer_requested, confirm_requested, notify, ui_layers_changed, ui_focus_moved, player_died, level_up, damage_taken, carga_iniciada, carga_completada, boot_completado, nivel_herramienta_cambio, nivel_casa_cambio, nivel_amistad_cambio, entrada_nueva, categoria_completa, progreso_cambiado, sesion_iniciada, sesion_terminada) | [x] |
| G3-3 | Clasificar las 20 señales muertas (red-probe): cada una → ¿debe CABLEARSE (a qué receptor, ruta) o es DEAD CODE (borrar del bus)? | tabla 20 filas — CABLEAR: boot_completado→Bootstrap (carga_completada), carga_completada→SceneManager (carga_completada), chunk_modified→M09 (world/chunk), confirm_requested→M53 UI, currency_changed→M38 (economy), damage_taken→M48 (player), debt_paid→M38 (economy), hotbar_selected→M13 (inventory), hud_request→M53 UI, item_removed→M57/M13 (BUG bridge servicio→bus), layer_requested→M53 UI, level_up→M11/M48 (player), nivel_amistad_cambio→M20 (progresion), nivel_casa_cambio→M18 (progresion), player_died→M48 (player), purchase_done→M38 (economy), travel_started→M69 (travel), ui_focus_moved→M53 UI, ui_layers_changed→M53 UI, vessel_arrived→M29 (calendar). DEAD CODE: ninguna clara sin validación del dueño M14. Propuesta pendiente de decisión M14. | [x] |
| G3-4 | Reporte de defectos al dueño de M14: el BUG item_removed (bridge servicio→bus faltante — save_manager.gd:83 + hud_screen.gd:120 nunca disparan) con tu ejecución de evidencia + los 5-8 peores casos de G3-3 | reporte en canal — mensaje 129 (2026-10-28 22:15) | [x] |
| G3-5 | Propuesta de limpieza segura: lista de señales a BORRAR (dead code) vs a CABLEAR (con receptor sugerido y L# del receptor candidato) — para decisión del dueño M14, NO tocar código | reporte en canal — mensaje 130 (2026-10-28 22:20) | [x] |
| G3-6 | Cierre A1-WORKOUT: marcar en el playbook de Hy3 (sección final) que la deuda A1 fue cerrada por tu ejecución runtime, con fecha y tus rutas de evidencia | línea en playbook PLAYBOOK-GATE2-HERENCIA-HY3.md (cierre deuda A1-WORKOUT, 2026-10-28 22:25) | [x] |

## REGLAS

- Output CORTO por ítem (anti-truncamiento). Si algo no podés correr (binario, permisos): `[?]` + motivo y seguís.
- español, UTF-8 sin BOM, sin push/commits, NO tocar código/05 ajenos (M14 es de otro dueño: reportás, no arreglás).
- Al terminar los 6: marcar este riel agotado en el BACKLOG-MASTER (fila G3) y sello final: agnes.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-28.
