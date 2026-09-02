# Log 368: M59 Guardado iter. auto-save/dirty/providers — glm-5.3-flash

**Fecha:** 2026-08-31
**Hora:** 21:50
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración del M59 Guardado (F5, V0) retomada del estado 🟡 de ox-alpha: dirty tracking vía EventBus M07, auto-save por fin de día / misión / cierre del juego, bloqueo durante diálogo, y primer provider de sección del schema ("player"). Dos fix latentes del núcleo. Módulo liberado 🟡 36/130.

## Cambios Realizados

### SaveManager (aditivo)
- Dirty tracking: escucha EventBus M07 (calendar/economy/inventory/quest/npc/world → mark_dirty), API `is_dirty()/mark_dirty()/clear_dirty()`; se limpia al completar un save. (El motivo previo "M07 no existe" estaba desactualizado — EventBus es operativo desde M53/M111.)
- Auto-save: `day_started` → "auto_dia"; `quest_completed` → "auto_mision"; cierre de ventana → escritura síncrona best-effort (NOTIFICATION_WM_CLOSE_REQUEST).
- Bloqueo B5-parcial: `dialog_requested`/`dialog_finished` (EventBus.ui) → set_save_blocked.
- FIX latente 1: `auto_save_skipped` se emitía sin estar declarada — declarada.

### save_snapshot.gd (FIX latente 2, preexistente)
- collect()/restore() tipaban el provider como `ISaveProvider` (RefCounted): todos los Node-providers reales (world_state_service, time_calendar, farm, fishing, mining, resource, friendship, tutorial, weather, etc.) rompían con "Trying to assign value of type...". Corregido a duck-typing (el registro ya era sin tipo).

### PlayerSaveProvider (nuevo, scripts/saving/player_save_provider.gd)
- Sección "player" del SaveSchema: guarda/restaura `position` y `spawn_position` del nodo Player (búsqueda perezosa desde root; zona queda "" hasta M09/M54).

### Tests
- `scripts/saving/test_autosave_m59.gd` (nuevo): dirty por item_added, save limpia dirty, bloqueo/aviso en diálogo, auto_dia por day_started, auto_mision por quest_completed, round-trip posición del jugador (stub si no hay escena), restore tolerante a datos vacíos → **0 fallos**.
- Regresión `validate_save.gd`: **VALIDACIÓN OK — 13/13 checks**.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/saving/save_manager.gd` (aditivo + fix señal)
- `game/isla-ancestral/scripts/saving/save_snapshot.gd` (fix typing Node-providers)
- `game/isla-ancestral/scripts/saving/player_save_provider.gd` (nuevo)
- `game/isla-ancestral/scripts/saving/test_autosave_m59.gd` (nuevo)
- `game/isla-ancestral/.godot/global_script_class_cache.cfg` (regenerado)
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md` (Notas del Agente iter.)
- `DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md` (36/130 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva → liberación)

## Verificación

- test_autosave_m59.gd: 0 fallos (Godot 4.5 headless).
- validate_save.gd: 13/13 OK (regresión del núcleo intacta).
