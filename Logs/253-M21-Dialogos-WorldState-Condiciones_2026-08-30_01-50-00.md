# Log 253: M21 Diálogos — WorldStateService + condiciones de mundo + relevamiento checklist

**Fecha:** 2026-08-30
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 2 del M21 (Diálogos), relevo autorizado por el usuario de Hy3 (Kilo). Se implementó el
WorldStateService (RF5: variables de estado del mundo como condiciones/efectos de ramas), se
integró con el DialogueManager existente, se creó suite de tests de condiciones y se relevó el
05-Checklist.md contra el código real (59/133 [x], 14 [?], 60 [ ]).

## Cambios Realizados

### Código (Godot)
- `game/isla-ancestral/scripts/dialogos/world_state_service.gd` — **NUEVO autoload "WorldState"**:
  - `get_value(clave, default)` delega en TimeCalendar (M29) y Friendship (M20): hora, minuto,
    dia, mes, anio, estacion, es_de_dia, es_noche, dia_absoluto, clima (placeholder M32),
    amistad_<npc_id>, eventos/festivales del día.
  - `get_snapshot(claves)` para evaluaciones en lote.
  - `set_flag`/`get_flag`/`has_flag` para banderas propias `flag_*` persistibles.
  - Proveedor de guardado M59 (sección "world_state").
- `game/isla-ancestral/scripts/dialogos/dialogue_manager.gd`:
  - `_entrar_nodo()` evalúa condiciones contra estado combinado (sesión + mundo) y salta el nodo
    si no se cumplen.
  - `_combinar_estado(nodo)` resuelve claves de condiciones del nodo y sus opciones.
  - `choose_option()` aplica efectos del nodo y de la opción elegida.
  - Guard `is_inside_tree()` para tests headless (evita get_node fuera del árbol).
- `game/isla-ancestral/scripts/dialogos/dialogue_node.gd` — `apply_effects` con destino
  "world"/flag_* → escribe en WorldState.
- `game/isla-ancestral/scripts/dialogos/dialogue_option.gd` — nuevo `apply_effects` (mismo contrato).
- `game/isla-ancestral/project.godot` — autoload WorldState registrado antes de DialogueManager.
- `game/isla-ancestral/scripts/dialogos/test_condiciones_mundo.gd` — **NUEVO test**: condiciones
  por estación, efectos world (set/increment flags), condiciones por sesión (amistad). 0 fallos.

### Documentación
- `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` — relevado: 59 [x], 14 [?], 60 [ ].
- `DOCUMENTACION/21-Dialogos/plan-actual/04-Codigo.md` — Notas del Agente iteración 2.
- `CHECKLIST-GLOBAL.md` — fila M21 actualizada (progreso 59/133, nota de relevamiento).
- `Mensajes entre modelos/ESTADO-PARALELO.md` — entrada M21 actualizada.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/dialogos/world_state_service.gd` | Creado |
| `scripts/dialogos/test_condiciones_mundo.gd` | Creado |
| `scripts/dialogos/dialogue_manager.gd` | Modificado |
| `scripts/dialogos/dialogue_node.gd` | Modificado |
| `scripts/dialogos/dialogue_option.gd` | Modificado |
| `project.godot` | Modificado (autoload WorldState) |
| `DOCUMENTACION/21-Dialogos/plan-actual/05-Checklist.md` | Modificado (relevamiento) |
| `DOCUMENTACION/21-Dialogos/plan-actual/04-Codigo.md` | Modificado (notas iteración 2) |
| `CHECKLIST-GLOBAL.md` | Modificado |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | Modificado |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (252 → 253) |
| `Logs/253-M21-Dialogos-WorldState-Condiciones_2026-08-30_01-50-00.md` | Creado (este log) |

## Validación
- `test_dialogos.gd` headless: 0 fallos (regresión).
- `test_condiciones_mundo.gd` headless: 0 fallos.
- Arranque del juego con MCP Godot (run_project + get_debug_output): 0 errores nuevos; diálogo
  con Catalina inicia correctamente en runtime.
- `--check-only` en scripts modificados: sin errores de parse.
