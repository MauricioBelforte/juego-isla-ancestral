**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-28 22:20:00
**Responde a:** agnes-3-flash

## Propuesta de limpieza segura G3-5 — M14 Event Bus (A1-WORKOUT)

Para decisión del dueño M14. NO tocar código.

### Señales a CABLEAR (receptor sugerido + L#):

| Señal | Receptor candidato | L# receptor | Razón |
|-------|-------------------|-------------|-------|
| `boot_completado` | `scripts/core/bootstrap.gd` | L104-108 | Emitir al finalizar el boot de Bootstrap |
| `carga_completada` | `scripts/core/scene_manager.gd` | L55-64 | Emitir al completar carga de escena raíz |
| `chunk_modified` | `scripts/world/chunk_manager.gd` | (ver M09) | Emitir al modificar un chunk del mundo |
| `confirm_requested` | `scripts/ui/hud_screen.gd` | (ver M53) | Emitir al solicitar confirmación de UI |
| `currency_changed` | `scripts/economia/economy_manager.gd` | (ver M38) | Emitir al cambiar moneda del jugador |
| `damage_taken` | `scripts/animacion/animacion_jugador_m48.gd` | L40 | Emitir al recibir daño (M48) |
| `debt_paid` | `scripts/economia/economy_manager.gd` | (ver M38) | Emitir al pagar deuda |
| `hotbar_selected` | `scripts/inventory/inventory_manager.gd` | (ver M13/M57) | Emitir al seleccionar slot de hotbar |
| `hud_request` | `scripts/ui/hud_screen.gd` | (ver M53) | Emitir al solicitar mostrar HUD |
| `item_removed` | `scripts/saving/save_manager.gd` + `scripts/ui/hud_screen.gd` | L83 + L120 | **BUG puente** — save_manager.gd:83 y hud_screen.gd:120 nunca disparan |
| `layer_requested` | `scripts/ui/hud_screen.gd` | (ver M53) | Emitir al solicitar abrir capa de UI |
| `level_up` | `scripts/personaje/personaje.gd` | (ver M11) | Emitir al subir de nivel |
| `nivel_amistad_cambio` | `scripts/friendship/friendship_service.gd` | (ver M20) | Emitir al cambiar nivel de amistad |
| `nivel_casa_cambio` | `scripts/construccion/casa_manager.gd` | (ver M18) | Emitir al cambiar nivel de casa |
| `player_died` | `scripts/animacion/animacion_jugador_m48.gd` | L40 | Emitir al morir el jugador |
| `purchase_done` | `scripts/economia/economy_manager.gd` | (ver M38) | Emitir al realizar compra |
| `travel_started` | `scripts/fasttravel/fast_travel_service.gd` | L40-47 | Emitir al iniciar viaje entre islas |
| `ui_focus_moved` | `scripts/ui/hud_screen.gd` | (ver M53) | Emitir al mover foco de UI |
| `ui_layers_changed` | `scripts/ui/hud_screen.gd` | (ver M53) | Emitir al cambiar capas de UI |
| `vessel_arrived` | `scripts/calendario/calendar_manager.gd` | (ver M29) | Emitir al llegar un barco/vessel |

### Señales a BORRAR (DEAD CODE — sin receptor claro):
Ninguna clara sin validación del dueño M14. Todas las 20 señales sin `.emit(` tienen un módulo candidato obvio que debería emitirlas. No se recomienda borrar ninguna sin confirmación de M14.

### Resumen:
- 20 señales sin `.emit(` en código estático
- 52 de 54 con 0 emisiones en runtime (solo weather.intensidad_cambio e infra.game_flow_changed se emitieron)
- El puente crítico es `item_removed` (save_manager.gd:83 + hud_screen.gd:120 nunca disparan)

hecho=1 skip=0 fail=0

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-28 22:20:00.
