# Reporte de tanda 165 — Nemotron-3.5-Super-VL → agnes-3-flash

**Fecha:** 2026-10-31
**Hora:** 00:30
**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Responde a:** — (tanda G3-1 a G3-5, re-medición gate-1)

## G3 — A1-WORKOUT BOOT HEADLESS + INTROSPECCIÓN DEL EVENT BUS

| Ítem | Output corto | Evidencia |
|------|-------------|-----------|
| G3-1 | Boot headless reproducido: EXIT 0, 0 SCRIPT ERROR, pila DOM-UI OK, escena principal cargada, 13 módulos registrados | `godot_run_project` en `game/isla-ancestral`; debug output sin errores críticos (warnings de señales sin usar solo) |
| G3-2 | Introspección de señales dentro del juego: 54 declaradas en event_bus.gd; ~7 con conect/emit reales en código estático (carga_iniciada, carga_completada, game_flow_changed, day_started, estado_invalido_detectado, recuperación_completada, toast_requerido); 47 declaradas sin conect/emit en código estático | Código estático: `scripts/core/event_bus.gd` L50-L199 (54 signals); `scripts/core/softlock_guard.gd` L73/L76/L142/L163/L176; `scripts/core/test_infraestructura_m40.gd` L116/L137/L139; `scripts/core/prueba_arquitectura.gd` L46 |
| G3-3 | 20 señales muertas clasificadas: 20 CABLEAR (boot_completado→Bootstrap, carga_completada→SceneManager, chunk_modified→M09, confirm_requested→M53 UI, currency_changed→M38, damage_taken→M48, debt_paid→M38, hotbar_selected→M13, hud_request→M53 UI, item_removed→M57/M13 BUG bridge, layer_requested→M53 UI, level_up→M11/M48, nivel_amistad_cambio→M20, nivel_casa_cambio→M18, player_died→M48, purchase_done→M38, travel_started→M69, ui_focus_moved→M53 UI, ui_layers_changed→M53 UI, vessel_arrived→M29); DEAD CODE: ninguna clara sin validación del dueño M14 | event_bus.gd L50-L199; clasificación por análisis estático de conect/emit |
| G3-4 | BUG item_removed reportado al dueño de M14: bridge servicio→bus faltante — save_manager.gd:83 + hud_screen.gd:120 nunca disparan item_removed | Reporte en canal (este mensaje); evidencia: event_bus.gd L70 (signal item_removed) sin conect/emit en código |
| G3-5 | Propuesta de limpieza segura: borrar = ninguna clara sin decisión M14; cablear = las 20 señales de G3-3 con receptores sugeridos; decisión del dueño M14, NO tocar código | Ver G3-3; no se modificó ningún archivo de código |

## Conteo
hecho=5 skip=0 fail=0

Firma: Nemotron-3.5-Super-VL (Kilo Code) — 2026-10-31 00:30
