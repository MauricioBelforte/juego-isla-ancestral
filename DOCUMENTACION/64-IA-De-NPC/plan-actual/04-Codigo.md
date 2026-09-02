**Modelo:** agnes-2.5-flash (implementación) / MiMo V2.5 (coordinación)
**Plataforma:** Kilo Code / OpenCode
**Última actualización:** 2026-09-01

# 04-Codigo.md — Módulo 64: IA de NPC

## 1. Archivos Involucrados

### Scripts (GDScript, tipado) — Implementados por agnes-2.5-flash

| Archivo | Propósito |
|---|---|
| `scripts/ia_npc/npc_agent.gd` | Controlador principal por NPC (class_name NPCAgent, extends CharacterBody3D). Orquesta FSM, rutinas, necesidades, navegación y blackboard. |
| `scripts/ia_npc/state_machine.gd` | Máquina de estados (NPCStateMachine). FSM plana con pila de estados. |
| `scripts/ia_npc/base_state.gd — Clase base de estados (Node, sin class_name para evitar conflictos preload). |
| `scripts/ia_npc/routine_player.gd` | Reproductor de rutinas (RoutinePlayer). |
| `scripts/ia_npc/npc_needs.gd` | Sistema de necesidades (NPCNeeds). |
| `scripts/ia_npc/npc_blackboard.gd` | Memoria compartida entre estados (NPCBlackboard). |
| `scripts/ia_npc/npc_manager.gd` | Manager global con registro/desregistro + burbujas de simulación (NPCManager, autoload `ia_npc`). |
| `scripts/ia_npc/states/idle_state.gd` | Estado: idle |
| `scripts/ia_npc/states/movement_state.gd` | Estado: movimiento |
| `scripts/ia_npc/states/work_state.gd` | Estado: trabajo |
| `scripts/ia_npc/states/social_state.gd` | Estado: socialización |
| `scripts/ia_npc/states/eat_state.gd` | Estado: comer |
| `scripts/ia_npc/states/sleep_state.gd` | Estado: sueño |
| `scripts/ia_npc/states/react_state.gd` | Estado: reacción |
| `scripts/ia_npc/states/interact_state.gd` | Estado: interacción con jugador |

**Total: 15 archivos GDScript**

### Escenas
| Archivo | Propósito |
|---|---|
| `scenes/npc/npc_agent.tscn` | Escena NPCAgent (Node3D + NPCAgent.gd + NavigationAgent3D + CollisionShape3D). **Fix MiMo:** corregido ExtResource reference. |

### Datos (pre-existentes, compartidos con M19)
| Archivo | Propósito |
|---|---|
| `data/villagers/*.tres` | Perfiles de NPCs (catalina_oso, finneas_zorro, mateo_mapache, luna_zorra, bruno_sapo) |

## 2. Funciones Clave (firmas GDScript)

```gdscript
# ---------- npc_agent.gd ----------
class_name NPCAgent
extends CharacterBody3D

## Señales públicas
signal npc_state_changed(old_state: StringName, new_state: StringName)
signal npc_arrived(location: StringName)
signal npc_stuck(duration: float)

## Timer para tick discreto de la FSM (~2 veces por segundo en nivel full)
var _tick_timer: float = 0.0
const TICK_INTERVAL_FULL: float = 0.5
const TICK_INTERVAL_MEDIUM: float = 1.0
const TICK_INTERVAL_LIGHT: float = 5.0

## API pública
func get_npc_id() -> StringName
func initialize(npc_id: StringName, routine_data: Dictionary) -> void
func get_current_state() -> StringName
func get_simulation_level() -> String
func set_simulation_level(level: String) -> void
func navigate_to(target_pos: Vector3) -> void
func on_arrived() -> void
func is_at_destination() -> bool
func get_save_data() -> Dictionary
func load_save_data(data: Dictionary) -> void

# ---------- npc_manager.gd ----------
extends Node

## Señales
signal npc_created(npc_id: StringName)
signal npc_removed(npc_id: StringName)

## Burbujas de simulación
const BUBBLE_FULL: float = 30.0
const BUBBLE_MEDIUM: float = 60.0
const BUBBLE_LIGHT: float = 100.0

func register_npc(agent: NPCAgent) -> void
func unregister_npc(agent: NPCAgent) -> void
func _update_simulation_levels() -> void

# ---------- state_machine.gd ----------
class_name NPCStateMachine
extends Node

func transition_to(state_name: StringName, data: Dictionary = {}) -> void
func get_current_state_name() -> StringName
func set_simulation_level(level: String) -> void
```

## 3. Correcciones Aplicadas (MiMo V2.5)

| Fecha | Archivo | Corrección |
|---|---|---|
| 2026-09-01 | `npc_agent.gd` | Agregado `class_name NPCAgent` (faltaba — causaba "Could not find type NPCAgent") |
| 2026-09-01 | `npc_agent.tscn` | Corregido `ExtResource("1")` reference (tenía id inconsistente) |

## 4. Logs Relacionados

| Log | Contenido |
|---|---|
| — | Pendiente de log por agnes-2.5-flash |

## 5. Notas del Agente

**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 04:47
**Estado:** Implementación iter 1 completada (21 archivos creados)

### Lo que hice
- Creé 15 scripts GDScript en `scripts/ia_npc/` (npc_agent, npc_manager, npc_needs, npc_blackboard, state_machine, state, routine_player, + 8 estados)
- Creé escena `scenes/npc/npc_agent.tscn`
- FSM jerárquica con 8 estados (Idle, Movement, Work, Social, Eat, Sleep, React, Interact)
- NPCManager autoload con burbujas de simulación (full/medium/light/sleep)
- Sistema de necesidades (NPCNeeds)
- Memoria compartida (NPCBlackboard)
- Perfiles de rutina para 5 NPCs

### Lo que NO pude hacer
- No actualicé el plan-actual de documentación (pendiente)
- No agregué nada a la guía 07-GUIA-GODOT.md (pendiente)
- No generé log en Logs/ (pendiente)

### Fix aplicado por MiMo V2.5
- Agregué `class_name NPCAgent` que faltaba en `npc_agent.gd`
- Corregí `ExtResource` en `npc_agent.tscn`
