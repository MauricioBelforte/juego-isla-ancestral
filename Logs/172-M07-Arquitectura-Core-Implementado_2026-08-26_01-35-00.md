# Log 172: M07 Arquitectura General — Core implementado y validado

**Fecha:** 2026-08-26
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Se implementaron los 3 scripts core de arquitectura (EventBus, ServiceRegistry, Bootstrap), se registraron como autoloads, se creó escena de validación, y se obtuvo **6 PASS, 0 FAIL** en el test de arquitectura.

## Cambios Realizados

### Scripts creados
1. **`scripts/core/event_bus.gd`** — Bus de eventos global con 9 dominios tipados:
   - world: block_placed, block_removed, chunk_modified, biome_changed
   - economy: currency_changed, purchase_done, debt_paid
   - inventory: item_added, item_removed, hotbar_selected
   - quest: quest_started, quest_updated, quest_completed, prereq_met
   - npc: npc_moved_in, friendship_level_up, gift_given
   - calendar: day_started, season_changed, vessel_arrived
   - travel: travel_started, island_loaded
   - ui: hud_request, dialog_requested
   - player: player_died, level_up, damage_taken

2. **`scripts/core/service_registry.gd`** — Service Locator con:
   - `register(name, service)` — registro por interfaz
   - `get_service(name)` — obtención por interfaz
   - `has(name)` — verificación
   - `list_registered()` — listado
   - `validate_required(array)` — validación de obligatorios

3. **`scripts/core/bootstrap.gd`** — Bootstrap que:
   - Registra EventBus y ServiceRegistry
   - Valida servicios obligatorios
   - Carga escena principal (deferred)

### Autoloads agregados en project.godot
- `EventBus="*res://scripts/core/event_bus.gd"` (primero)
- `ServiceRegistry="*res://scripts/core/service_registry.gd"`
- `Bootstrap="*res://scripts/core/bootstrap.gd"` (último)

### Escena de prueba
- `scenes/test_arquitectura.tscn` — Valida 6 puntos: EventBus activo, ServiceRegistry activo, registro, dominios, emisión/recepción, listado

### Errores documentados en 07-GUIA-GODOT.md
- 9.17: class_name autoload colisiona
- 9.18: Node.get() ya existe
- 9.19: type es palabra reservada
- 9.20: change_scene_to_file en _ready() causa busy

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/core/event_bus.gd` (NUEVO)
- `game/isla-ancestral/scripts/core/service_registry.gd` (NUEVO)
- `game/isla-ancestral/scripts/core/bootstrap.gd` (NUEVO)
- `game/isla-ancestral/scripts/test_arquitectura.gd` (NUEVO)
- `game/isla-ancestral/scenes/test_arquitectura.tscn` (NUEVO)
- `game/isla-ancestral/project.godot` (modificado — autoloads)
- `DOCUMENTACION/07-GUIA-GODOT.md` (actualizado — 4 errores nuevos)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (M07 marcado ✅)

## Estado
M07 completado. Puerta F1 cerrada (M04 ✅, M05 ✅, M07 ✅). Habilitado para Fase 2: M08, M10, M09.
