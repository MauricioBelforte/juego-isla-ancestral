**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 64: IA de NPC

## 1. Archivos Involucrados

### Scripts (GDScript, tipado)
| Archivo | Propósito |
|---|---|
| `res://_Project/Scripts/AI/NPC/NPCIAController.gd` | Controlador principal de IA por NPC |
| `res://_Project/Scripts/AI/NPC/HFSM/StateMachine.gd` | Motor de FSM jerárquica |
| `res://_Project/Scripts/AI/NPC/HFSM/State.gd` | Clase base de estados |
| `res://_Project/Scripts/AI/NPC/HFSM/States/IdleState.gd` | Estado: idle |
| `res://_Project/Scripts/AI/NPC/HFSM/States/MovementState.gd` | Estado: movimiento |
| `res://_Project/Scripts/AI/NPC/HFSM/States/WorkState.gd` | Estado: trabajo |
| `res://_Project/Scripts/AI/NPC/HFSM/States/SocialState.gd` | Estado: socialización |
| `res://_Project/Scripts/AI/NPC/HFSM/States/SleepState.gd` | Estado: sueño |
| `res://_Project/Scripts/AI/NPC/HFSM/States/ReactState.gd` | Estado: reacción |
| `res://_Project/Scripts/AI/NPC/HFSM/States/InteractState.gd` | Estado: interacción con jugador |
| `res://_Project/Scripts/AI/NPC/Routine/RoutineDefinition.gd` | Resource de rutina diaria |
| `res://_Project/Scripts/AI/NPC/Routine/RoutinePlayer.gd` | Reproductor de rutinas |
| `res://_Project/Scripts/AI/NPC/Needs/NPCNeeds.gd` | Sistema de necesidades |
| `res://_Project/Scripts/AI/NPC/Blackboard/NPCBlackboard.gd` | Datos compartidos entre estados |
| `res://_Project/Scripts/AI/NPC/NPCManager.gd` | Manager global (autoload) |
| `res://_Project/Scripts/AI/NPC/SocialProximity.gd` | Detección de NPCs cercanos |

### Escenas y datos
| Archivo | Propósito |
|---|---|
| `res://_Project/Prefabs/NPC/NPCAgent.tscn` | NPC con IA integrada |
| `res://_Project/Config/AI/routines/*.tres` | Rutinas por NPC |
| `res://_Project/Config/AI/needs_config.tres` | Config de necesidades |

## 2. Funciones Clave (firmas GDScript)

```gdscript
# ---------- NPCIAController.gd ----------
class_name NPCIAController
extends Node3D

@export var npc_id: StringName
@export var routine: RoutineDefinition
@export var move_speed: float = 3.0

var state_machine: StateMachine
var needs: NPCNeeds
var blackboard: NPCBlackboard
var nav_agent: NavigationAgent3D

signal state_changed(old_state: StringName, new_state: StringName)
signal arrived_at_destination(location: StringName)
signal social_interaction(other_npc: StringName, interaction_type: StringName)

func _ready() -> void:
    _initStateMachine()
    _initNeeds()
    _initBlackboard()
    _initNavigation()

func _physics_process(delta: float) -> void:
    state_machine.update(delta)
    needs.update(delta)

func navigate_to(target_pos: Vector3) -> void:
    nav_agent.target_position = target_pos

func get_current_state() -> StringName:
    return state_machine.get_current_state_name()

func react_to_event(event_type: StringName, event_data: Dictionary) -> void:
    state_machine.transition_to("React", {"event_type": event_type, "data": event_data})

# ---------- StateMachine.gd ----------
class_name StateMachine
extends Node

var current_state: State
var states: Dictionary = {}
var history: Array[StringName] = []

func update(delta: float) -> void:
    if current_state:
        current_state.update(delta)
        var transition = current_state.check_transitions()
        if transition:
            transition_to(transition.target, transition.data)

func transition_to(state_name: StringName, data: Dictionary = {}) -> void:
    if current_state:
        current_state.exit()
        history.append(current_state.name)
    current_state = states.get(state_name)
    if current_state:
        current_state.enter(data)

func get_current_state_name() -> StringName:
    return current_state.name if current_state else &"None"

# ---------- State.gd ----------
class_name State
extends Node

var controller: NPCIAController

func enter(data: Dictionary) -> void:
    pass

func update(delta: float) -> void:
    pass

func exit() -> void:
    pass

func check_transitions() -> Dictionary:
    return {}  # {target: StringName, data: Dictionary}

# ---------- RoutinePlayer.gd ----------
class_name RoutinePlayer
extends Node

@export var routine: RoutineDefinition
var current_slot_index: int = 0

func get_next_action(current_hour: int, current_minute: int) -> RoutineSlot:
    # Retorna el próximo slot de rutina según la hora actual
    pass

func is_action_due(slot: RoutineSlot, current_hour: int, current_minute: int) -> bool:
    return slot.hour == current_hour and slot.minute <= current_minute

# ---------- NPCManager.gd (autoload) ----------
extends Node

var active_npcs: Array[NPCIAController] = []
var MAX_ACTIVE_AGENTS: int = 60
var SIMULATION_DISTANCES: Dictionary = {
    "full": 30.0,
    "medium": 60.0,
    "light": 100.0
}

func register_npc(controller: NPCIAController) -> void:
    active_npcs.append(controller)

func unregister_npc(controller: NPCIAController) -> void:
    active_npcs.erase(controller)

func _process(delta: float) -> void:
    _update_simulation_levels()

func _update_simulation_levels() -> void:
    var player_pos = _get_player_position()
    for npc in active_npcs:
        var dist = npc.global_position.distance_to(player_pos)
        if dist < SIMULATION_DISTANCES["full"]:
            npc.set_simulation_level("full")
        elif dist < SIMULATION_DISTANCES["medium"]:
            npc.set_simulation_level("medium")
        elif dist < SIMULATION_DISTANCES["light"]:
            npc.set_simulation_level("light")
        else:
            npc.set_simulation_level("sleep")

# ---------- NPCBlackboard.gd ----------
class_name NPCBlackboard
extends RefCounted

var data: Dictionary = {}

func set_value(key: StringName, value: Variant) -> void:
    data[key] = value

func get_value(key: StringName, default: Variant = null) -> Variant:
    return data.get(key, default)

func has_value(key: StringName) -> bool:
    return data.has(key)

# Keys comunes:
# "target_position" -> Vector3
# "current_destination" -> StringName
# "is_raining" -> bool
# "player_position" -> Vector3
# "nearby_npcs" -> Array[StringName]
# "current_event" -> StringName
```

## 3. Logs Relacionados

| Log | Contenido |
|---|---|
| `DOM-IA` | Cambios de estado, transiciones, llegadas a destino |
| `DOM-IA-SOCIAL` | Interacciones sociales, saludos, charlas |
- `DOM-IA-NAV` | Recálculos de path, atascos detectados, respawns |
| `DOM-IA-NEEDS` | Cambios de necesidades (hambre, energía, social) |
| `DOM-IA-PERF` | Métricas de rendimiento: NPCs activos, tiempo de tick, paths simultáneos |
