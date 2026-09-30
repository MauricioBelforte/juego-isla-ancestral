**Modelo:** MiMo V2.5 (coordinación) / agnes-2.5-flash (implementación inicial)
**Plataforma:** OpenCode / Kilo Code
**Última actualización:** 2026-09-18

# 04-Codigo.md — Módulo 64: IA de NPC

## 1. Archivos Involucrados

### Scripts Core (12 archivos)

| Archivo | class_name | Propósito | Líneas |
|---|---|---|---|
| `npc_agent.gd` | NPCAgent | Controlador principal por NPC. Orquesta FSM, rutinas, necesidades, navegación, social, separación. | 411 |
| `state_machine.gd` | NPCStateMachine | FSM plana con pila de planes. Fallback con `is_fallback` + `fell_back`. | ~180 |
| `base_state.gd` | — | Clase base de estados (Node). | ~30 |
| `routine_player.gd` | RoutinePlayer | Lee `VillagerProfile.rutina_diaria` y matchea hora:minute. | ~80 |
| `npc_needs.gd` | NPCNeeds | hunger/energy/social/mood. Config vía `set_config()`. | 129 |
| `npc_blackboard.gd` | NPCBlackboard | Datos compartidos. `to_dict()` / `from_dict()` (static). | 79 |
| `npc_manager.gd` | — | Autoload. Registro/desregistro, BudgetRegistry (32MB), watchdog. | ~200 |
| `plan_stack.gd` | NPCPlanStack | Pila de planes. push/pop/peek/recovery/clear/serialize. MAX_DEPTH=8. | 142 |
| `npc_watchdog.gd` | NPCWatchdog | Anti-atascos. Per-state timeouts + transition burst detection. | 153 |
| `npc_needs_config.gd` | NPCNeedsConfig | Resource configurable de rates/thresholds. | ~40 |

### Estados (8 archivos en `states/`)

| Archivo | Estado | Sub-estados |
|---|---|---|
| `idle_state.gd` | Idle | Espera, mira alrededor |
| `movement_state.gd` | Movement | WalkTo, RunTo, Avoid |
| `work_state.gd` | Work | WorkAnimate, WorkPause |
| `social_state.gd` | Social | Greet, Chat, GroupChat |
| `eat_state.gd` | Eat | GoToEat, Eating, LeaveEat |
| `sleep_state.gd` | Sleep | GoToSleep, Sleeping, WakeUp |
| `react_state.gd` | React | ReactRain, ReactEvent, ReactPlayer |
| `interact_state.gd` | Interact | TalkToPlayer, GiveGift, Trade |

### Tests (5 archivos)

| Archivo | Checks | Fallos | Tipo |
|---|---|---|---|
| `test_ia_npc_m64_iterN.gd` | 82 | 0 | Suite principal (plan_stack, watchdog, needs, blackboard, FSM, profiles) |
| `test_navegacion_m64.gd` | 9 | 0 | Watchdog + constantes separación |
| `test_social_m64.gd` | 14 | 0 | Needs + selectividad + límites |
| `test_rendimiento_m64.gd` | 8 | 0 | 60+100 NPCs performance |
| `test_persistencia_m64.gd` | 29 | 0 | Roundtrip Needs/Blackboard/PlanStack |
| **TOTAL** | **142** | **0** | |

### Datos

| Archivo | Propósito |
|---|---|
| `data/villagers/*.tres` | 6 perfiles con `rutina_diaria` (catalina, finneas, mateo, luna, bruno, mercedes) |
| `data/ia/npc_needs_config.tres` | Config default de necesidades |

### CI

| Workflow | Línea | Gate |
|---|---|---|
| `.github/workflows/quality.yml:327` | `test_ia_npc_m64_iterN.gd` | `|| FAIL=1` (duro) |
| `.github/workflows/quality.yml:328-331` | 4 suites nuevas | `|| FAIL=1` (duro) |

## 2. Funciones Clave

```gdscript
# ---------- npc_agent.gd ----------
class_name NPCAgent extends CharacterBody3D

signal npc_state_changed(old_state: StringName, new_state: StringName)
signal npc_arrived(location: StringName)
signal npc_stuck(duration: float)

const MAX_SIMULTANEOUS_SOCIALS: int = 3
const SEPARATION_FORCE: float = 1.5
const SEPARATION_RADIUS: float = 1.5

func _ready() -> void                    # Setup components, navigation, routine
func _process(delta: float) -> void      # Update blackboard, FSM, needs
func _select_social_partner(nearby: Array) -> StringName  # Job-matching priority
func apply_separation(all_npcs: Array) -> Vector3         # Repulsion force
func navigate_to(target: Vector3) -> void
func check_routine_transition() -> Dictionary
func get_save_data() -> Dictionary
func restore_save_data(data: Dictionary) -> void

# ---------- plan_stack.gd ----------
class_name NPCPlanStack extends RefCounted

func push_plan(state: StringName, data: Dictionary, source: StringName) -> bool
func pop_plan() -> Dictionary
func peek_current() -> Dictionary
func peek_previous() -> Dictionary
func has_state(state: StringName) -> bool
func clear_plans() -> void
func to_dict() -> Dictionary             # Key: "stack"
func from_dict(d: Dictionary) -> void

# ---------- npc_watchdog.gd ----------
class_name NPCWatchdog extends Node

func register_npc(npc_id: StringName) -> void
func unregister_npc(npc_id: StringName) -> void
func on_state_changed(npc_id: StringName, new_state: StringName) -> void
func get_npc_state_info(npc_id: StringName) -> Dictionary
func is_npc_registered(npc_id: StringName) -> bool

# ---------- npc_needs.gd ----------
class_name NPCNeeds extends RefCounted

var hunger: float = 100.0
var energy: float = 100.0
var social: float = 50.0
var mood: float = 75.0

func set_config(cfg: Resource) -> void    # Config override (1-arg get)
func update(delta: float) -> void         # Decrementa por tiempo
func get_urgent_need() -> StringName      # &"hunger" / &"energy" / &"social" / &""
func eat(amount: float = 30.0) -> void
func sleep(amount: float = 40.0) -> void
func socialize(amount: float = 20.0) -> void
func to_dict() -> Dictionary
func from_dict(d: Dictionary) -> void

# ---------- npc_blackboard.gd ----------
class_name NPCBlackboard extends RefCounted

func set_value(key: StringName, value: Variant) -> void
func get_value(key: StringName, default: Variant = null) -> Variant
func has_value(key: StringName) -> bool
func to_dict() -> Dictionary
static func from_dict(d: Dictionary) -> NPCBlackboard

# ---------- game_clock.gd (M29, autoload "GameTime") ----------
# API disponible para M64:
func pausa() -> void                     # Congela tiempo de juego
func resume() -> void                    # Reanuda tiempo de juego
func get_hora() -> int                   # 0-23
func get_minuto() -> int                 # 0-59
func es_de_dia() -> bool                 # 6 <= hora < 20
func dia_absoluto() -> int               # Día monótono (para restocks)
signal hora_cambio(hora: int)
signal dia_cambio(info: Dictionary)
```

## 3. Correcciones Aplicadas

| Fecha | Agente | Archivo | Corrección |
|---|---|---|---|
| 2026-09-01 | agnes-2.5-flash | `npc_agent.gd` | Agregado `class_name NPCAgent` |
| 2026-09-01 | agnes-2.5-flash | `npc_agent.tscn` | Corregido ExtResource reference |
| 2026-09-18 | mimo-v2.5 | `npc_needs.gd` | Fix `set_config()` — `Resource.get()` solo acepta 1 arg |
| 2026-09-18 | mimo-v2.5 | `state_machine.gd` | Fix `is_fallback` — detecta estados no existentes (var `fell_back`) |
| 2026-09-18 | mimo-v2.5 | `npc_agent.gd` | Added selectividad social, separación, MAX_SIMULTANEOUS_SOCIALS |
| 2026-09-18 | mimo-v2.5 | `test_persistencia_m64.gd` | Fix `BBScript.from_dict()` (static) + `stack` key |

## 4. Logs Relacionados

| Log | Agente | Contenido |
|---|---|---|
| 1040 | mimo-v2.5 | plan_stack.gd + npc_watchdog.gd + test_ia_npc_m64_iterN.gd (82/0) + fix is_fallback |
| 1046 | mimo-v2.5 | 4 suites nuevas (60/0) + npc_needs_config + selectividad social + fix set_config |

## 5. Notas del Agente (iter 1 — agnes-2.5-flash, 2026-09-01)

### Lo que hice
- 15 scripts GDScript, escena npc_agent.tscn, FSM con 8 estados
- NPCManager autoload con burbujas de simulación
- Sistema de necesidades, memoria compartida, perfiles de rutina

## 6. Notas del Agente (iter 2 — mimo-v2.5, 2026-09-18)

### Lo que hice
- plan_stack.gd: pila de planes con recovery, MAX_DEPTH=8
- npc_watchdog.gd: anti-atascos con per-state timeouts
- 5 suites de testing (142 checks, 0 fallos)
- npc_needs_config.gd/.tres: configuración de rates/thresholds
- npc_agent.gd: selectividad social, separación, límites
- state_machine.gd: fix is_fallback para estados no existentes
- 03-Diseno.md: reescrito para reflejar implementación real
- 04-Codigo.md: actualizado con archivos, firmas, correcciones
- CI: 5 tests wired en quality.yml con gate duro

### Lo que NO pude hacer
- GameClock pause: no integrado (pendiente)
- Group C: no marqué [?] con owners (pendiente)
- Runtime verification de social/rutina: requiere juego corriendo
