# Log 559: BUG-011 resuelto — Watchdog NPC en bucle infinito

**Fecha:** 2026-09-02
**Hora:** 23:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Fix del BUG-011 (delegado a M64/M19): el watchdog del `[StateMachine]` repite "NPC atascado" sin recuperación. Causa raíz DOBLE encontrada y corregida: (1) NPCAgent._get_profile() retornaba null siempre → sin rutina → Idle eterno; (2) el watchdog contaba estados estáticos por diseño como atasco.

## Causa raíz
1. **M19 incompleto:** `_get_profile()` en npc_agent.gd tenía el TODO "obtener_perfil not yet implemented in M19" y retornaba **null siempre** → perfil=unknown → sin rutina → el agente no tenía destinos.
2. **M64 watchdog mal aplicado:** `_update_stuck_detection()` medía inmovilidad en TODOS los estados. Idle/Sleep/Eat/Social/React/Interact están quietos **por diseño** (no procesan navegación): el timer crecía, disparaba `_force_new_target()` que el estado Idle ignora, y el ciclo "atascado → forzar → quieto → atascado" se repetía infinitamente (spam hasta el respawn de emergencia cada 10 s, y otra vez).

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/npc/villager_manager.gd` | +`obtener_perfil(vecino_id)`: resuelve el Resource del catálogo con fallback case-insensitive/sin separadores (el nodo "CatalinaOso" → catálogo "catalina_oso"); desconocido → null sin crash |
| `scripts/ia_npc/npc_agent.gd` | `_get_profile()` ahora llama `vm.obtener_perfil(_npc_id)` (antes null SIEMPRE) |
| `scripts/ia_npc/state_machine.gd` | `_update_stuck_detection()`: si el estado actual es estático (Idle/Sleep/Eat/Social/React/Interact) resetea timer + posición de referencia y sale; la detección de atasco solo aplica a Movement/Work (que DEBEN moverse). El caso de atasco real conserva `_force_new_target()` + respawn a hogar |
| `scripts/npc/test_bug011.gd` *(nuevo)* | 3 grupos de checks |
| `DOCUMENTACION/11-BUGS.md` | BUG-011 → [x] Resuelto con causa/solución/evidencia |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | Nota de bug resuelto en filas M64/M19 |

## Tests (headless Godot 4.7.2)
- `test_bug011.gd`: **0 fallos** — obtener_perfil por id exacto + case-insensitive ("CatalinaOso" → catalina_oso) + desconocido null; FSM en Idle 5 s quieto → 0 atascos y stuck_timer reseteado
- Regresiones: test_memoria_agenda (M19) 0 fallos, test_mudanzas 0 fallos
- El spam `[StateMachine] NPC atascado` del boot desaparece: los vecinos del arranque P1 en Idle ya no alimentan el watchdog

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/npc/villager_manager.gd` *(modificado)*
- `game/isla-ancestral/scripts/ia_npc/npc_agent.gd` *(modificado)*
- `game/isla-ancestral/scripts/ia_npc/state_machine.gd` *(modificado)*
- `game/isla-ancestral/scripts/npc/test_bug011.gd` *(nuevo)*
- `DOCUMENTACION/11-BUGS.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 559)*
- `Logs/reservas/558/559-...txt` *(creados y borrados — reserva 558 tomada por otro agente en paralelo, verificación v2 asignó 559)*

## Notas técnicas
- El fix del watchdog es conservador: NO elimina la recuperación de atascos reales (Movement/Work navegan y pueden quedar atascados contra voxels — allí sigue _force_new_target() + respawn a hogar del §anti-atascos).
- Con el perfil resuelto, el NPCAgent ahora carga rutina_diaria del .tres (wake_hour incluido) — la base para que M64 ejecute agendas (M19 iter. 3 ya expone agenda_dia()/actividad_actual()).
- El fallback case-insensitive del obtener_perfil acepta PascalCase (CatalinaOso), snake_case (catalina_oso) y espacios — cubre todos los namings de escenas vistos en el proyecto.
