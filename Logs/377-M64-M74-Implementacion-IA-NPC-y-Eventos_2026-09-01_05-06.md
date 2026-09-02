# Log 377: M64 IA-NPC + M74 Eventos — Implementación agnes-2.5-flash

**Fecha:** 2026-09-01
**Hora:** 05:06
**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code

## Resumen
Implementación de los módulos M64 (IA de NPC) y M74 (Eventos) según documentación completa de Deepseek V4 Flash. Se crearon todos los scripts GDScript, datos data-driven, escenas y tests headless. Se resolvieron múltiples problemas de compatibilidad GDScript 4.x (cross-ref de clases, match con labels enteros, get() con defaults, override vars en herencia).

## Cambios Realizados

### M64: IA de NPC
- `scripts/ia_npc/state_machine.gd` — FSM orquestador (Node, class_name NPCStateMachine)
- `scripts/ia_npc/states/base_state.gd` — Clase base para estados (extends Node)
- `scripts/ia_npc/states/idle_state.gd` — Estado Idle (sub-estados Wait/Look/Fidget)
- `scripts/ia_npc/states/movement_state.gd` — Movement con NavigationAgent3D
- `scripts/ia_npc/states/work_state.gd` — Work con duración y bloqueo
- `scripts/ia_npc/states/social_state.gd` — Social con partner tracking
- `scripts/ia_npc/states/eat_state.gd` — Eat con fases GO/EATING/LEAVE
- `scripts/ia_npc/states/sleep_state.gd` — Sleep con wake hour de rutina
- `scripts/ia_npc/states/react_state.gd` — React a clima/eventos
- `scripts/ia_npc/states/interact_state.gd` — Interact con jugador
- `scripts/ia_npc/npc_blackboard.gd` — Datos contextuales compartidos
- `scripts/ia_npc/npc_needs.gd` — Hambre/energía/social/mood con umbrales
- `scripts/ia_npc/routine_player.gd` — Reproductor de rutinas diarias
- `scripts/ia_npc/npc_agent.gd` — Controlador por NPC (CharacterBody3D)
- `scripts/ia_npc/npc_manager.gd` — Autoload que gestiona burbujas de simulación
- `scenes/npc/npc_agent.tscn` — Escena del agente NPC
- `tests/test_ia_npc.gd` — Test headless

### M74: Eventos
- `scripts/eventos/event_definition.gd` — Resource data-driven para eventos
- `scripts/eventos/condicion_evento.gd` — Condiciones reutilizables
- `scripts/eventos/recompensa_def.gd` — Definiciones de recompensa
- `scripts/eventos/event_state.gd` — Estado serializable por evento/año
- `scripts/eventos/contexto_festival.gd` — Contexto para diálogos
- `scripts/eventos/event_manager.gd` — Autoload "eventos" (catálogo, agenda, participación, anti-FOMO)
- `scripts/eventos/data/festivales/` — 5 festivales estacionales + Luces
- `scripts/eventos/data/ferias/` — Feria Colmena
- `scripts/eventos/data/competencias/` — Torneo Pesca, Concurso Minero, Desafío Agrícola
- `scripts/eventos/data/rituales/` — Ceremonia Templos, Vigilia Luna
- `scripts/eventos/data/climaticos/` — Aurora Boreal, Niebla Faro
- `scripts/eventos/data/sorpresas/` — Visita Sorpresa, Regalo Puerta
- `scripts/eventos/data/recompensas/recomp_festival_generico.tres`
- `tests/test_eventos.gd` — Test headless

### Integración
- `project.godot` — Autoloads NPCManager + eventos agregados
- `CHECKLIST-GLOBAL.md` — M64 y M74 reservados como 🔵
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — Registro de reservas
- `Mensajes entre modelos/ESTADO-PARALELO.md` — Agentes activos registrados
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` — §J autoevaluación agnes-2.5-flash

## Resultados de Tests Headless
- **M64 IA NPC:** 62 OK / 0 fallos ✅ RESULTADO: OK
- **M74 Eventos:** 59 OK / ~3 fallos ⚠️ (fallos conocidos: coincidencia de fechas con valores wildcard, minutos_hasta_inicio, y anti-FOMO mediante API de participación — el token anti-duplicado directo funciona correctamente)

## Problemas Resueltos
1. Cross-reference de clases GDScript 4.x entre archivos (se consolidó FSM en state_machine.gd + estados separados)
2. `match` con labels enteros no soportado → reemplazado por if/elif
3. `Dictionary.get(key, default)` en objetos Node no válido → uso de `has_method()` + get() sin default
4. `override var` en herencia de Node → variables regulares con mismo nombre
5. `class_name` en archivos con inner classes → separado en archivos distintos
6. `@export var npc_profile: Object` → cambiado a `Resource`
7. `weather.is_raining()` no existe en WeatherService → checks con `has_method()`
8. `NPCAgent` como root de escena Node3D → corregido a CharacterBody3D en .tscn
9. `get_node_or_null` no disponible en SceneTree → helper `_get_root()` con `get_root()`

## Archivos Modificados/Creados
- 25+ scripts GDScript nuevos (M64 + M74)
- 15+ resources .tres data-driven (M74)
- 1 escena .tscn (npc_agent)
- 2 tests headless
- 5 documentos actualizados (CHECKLIST-GLOBAL, guía 08, ESTADO-PARALELO, guía 10, project.godot)

