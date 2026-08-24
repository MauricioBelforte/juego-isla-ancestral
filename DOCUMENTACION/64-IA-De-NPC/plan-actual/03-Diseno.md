**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 64: IA de NPC

## 1. Arquitectura del Sistema

### 1.1 Componentes Principales

```
NPCIAController (Componente en cada NPC)
├── HFSM (Máquina de estados jerárquica)
│   ├── Root State
│   │   ├── IdleState
│   │   │   ├── IdleWait (esperando en posición)
│   │   │   ├── IdleLook (mirando alrededor)
│   │   │   └── IdleFidget (movimiento idle: rascarse, estirarse)
│   │   ├── MovementState
│   │   │   ├── WalkTo (caminando a destino)
│   │   │   ├── RunTo (corriendo, si hay prisa)
│   │   │   ├── Avoid (esquivando NPC/obstáculo)
│   │   │   └── Wander (deambulando sin destino fijo)
│   │   ├── WorkState
│   │   │   ├── WorkAnimate (animación de trabajo)
│   │   │   ├── WorkPause (pausa breve en trabajo)
│   │   │   └── WorkComplete (trabajo terminado)
│   │   ├── SocialState
│   │   │   ├── Greet (saludo breve)
│   │   │   ├── Chat (charla con otro NPC)
│   │   │   └── GroupChat (conversación grupal)
│   │   ├── EatState
│   │   │   ├── GoToEat (ir a comer)
│   │   │   ├── Eating (comiendo)
│   │   │   └── LeaveEat (terminar de comer)
│   │   ├── SleepState
│   │   │   ├── GoToSleep (ir a dormir)
│   │   │   ├── Sleeping (durmiendo)
│   │   │   └── WakeUp (despertar)
│   │   ├── ReactState
│   │   │   ├── ReactRain (refugiarse por lluvia)
│   │   │   ├── ReactEvent (ir a evento)
│   │   │   ├── ReactPlayer (reaccionar al jugador)
│   │   │   └── ReactDanger (evitar zona peligrosa)
│   │   └── InteractState
│   │       ├── TalkToPlayer (hablando con jugador)
│   │       ├── GiveGift (recibiendo regalo)
│   │       └── Trade (comerciando)
│   ├── RoutineSystem (agenda diaria)
│   ├── NeedsSystem (hambre, energía, social)
│   └── Blackboard (datos compartidos)
├── NavigationAgent3D (pathfinding)
├── AnimationController (animator)
└── AudioController (sonidos ambientales del NPC)
```

### 1.2 Definición de Rutina

Cada NPC tiene una `RoutineDefinition` (Resource `.tres`):

```gdscript
class_name RoutineDefinition
extends Resource

@export var npc_id: StringName
@export var routine_slots: Array[RoutineSlot] = []

# Ejemplo de routine_slots:
# [
#   {hour: 6, minute: 0, action: "wake_up", location: "casa"},
#   {hour: 7, minute: 0, action: "go_to_work", location: "herreria"},
#   {hour: 7, minute: 30, action: "work", location: "herreria"},
#   {hour: 12, minute: 0, action: "go_to_eat", location: "casa"},
#   {hour: 12, minute: 30, action: "eat", location: "casa"},
#   {hour: 13, minute: 0, action: "go_to_work", location: "herreria"},
#   {hour: 18, minute: 0, action: "go_home", location: "casa"},
#   {hour: 18, minute: 30, action: "free_time", location: "pueblo"},
#   {hour: 22, minute: 0, action: "go_to_sleep", location: "casa"},
#   {hour: 22, minute: 30, action: "sleep", location: "casa"},
# ]

class_name RoutineSlot
extends Resource

@export var hour: int
@export var minute: int
@export var action: StringName
@export var location: StringName
@export var duration_minutes: int = 30
@export var optional: bool = False  # Si es True, el NPC puede ignorarlo
```

### 1.3 Sistema de Necesidades

```gdscript
class_name NPCNeeds
extends RefCounted

var hunger: float = 100.0    # 0-100, baja al pasar el tiempo
var energy: float = 100.0    # 0-100, baja con actividades
var social: float = 50.0     # 0-100, baja sin interacción social
var mood: float = 75.0       # 0-100, afecta diálogos

func _process(delta: float) -> void:
    hunger -= delta * 0.5     # Pierde 0.5 por segundo de juego
    energy -= delta * 0.3
    social -= delta * 0.1
    
    # Prioridades
    if hunger < 20: return "need_eat"
    if energy < 15: return "need_sleep"
    if social < 20: return "need_socialize"
    return "ok"
```

## 2. Transiciones de Estado

### 2.1 Reglas de Transición

| Desde | Hacia | Condición |
|-------|-------|-----------|
| Idle | Movement | La rutina dice que debería estar en otro lugar |
| Idle | Work | Es hora de trabajar |
| Idle | Sleep | Es hora de dormir |
| Idle | React | Lluvia, evento, peligro |
| Movement | Work | Llegó al destino de trabajo |
| Movement | Eat | Llegó al destino de comida |
| Movement | Sleep | Llegó a la cama |
| Movement | Idle | No hay más acciones en la rutina |
| Work | Social | Pausa de trabajo + NPC cercano |
| Work | Eat | Hora de comer |
| Work | Idle | Jornada terminada |
| Social | Work | Fin de la pausa |
| Social | Idle | No hay más acciones sociales |
| Eat | Work | Comida terminada |
| Eat | Sleep | Es noche |
| Sleep | Idle | Despertar (hora de la rutina) |
| Cualquiera | React | Evento urgente (lluvia, festival) |
| React | Estado anterior | Evento terminado |

### 2.2 Prioridad de Transiciones

1. **Urgente (interrumpe todo):** Lluvia intensa, evento de festival, peligro
2. **Alta (interrumpe si es necesario):** Hora de dormir, hora de comer
3. **Media (sigue la rutina):** Ir a trabajar, ir a socializar
4. **Baja (idle):** Mirar alrededor, fidget, deambular

## 3. Navegación y Pathfinding

### 3.1 Configuración de NavigationServer3D

```gdscript
# En el NPC
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
    nav_agent.path_desired_distance = 1.0
    nav_agent.target_desired_distance = 0.5
    nav_agent.radius = 0.4  # Radio del NPC

func navigate_to(target_pos: Vector3) -> void:
    nav_agent.target_position = target_pos
    # El pathfinding se procesa en el siguiente frame

func _physics_process(delta):
    if nav_agent.is_navigation_finished():
        return
    
    var next_pos = nav_agent.get_next_path_position()
    var direction = (next_pos - global_position).normalized()
    velocity = direction * move_speed
    move_and_slide()
```

### 3.2 Anti-Atascos

| Mecánica | Implementación |
|----------|---------------|
| Detección de stuck | Si no se mueve > 2 s intentando llegar → recalcula path |
| Desvío de obstáculos | Si chocó con otro NPC → buscar punto alternativo cercano |
| Separación | Fuerza de separación entre NPCs (evitar superposición) |
| Respawn de emergencia | Si lleva > 10 s atascado → teletransportar a destino más cercano |
| Límite de agentes | Máximo 60 paths simultáneos; el resto espera |

## 4. Comportamiento Social

### 4.1 Reglas de Socialización

| Evento | Acción | Duración |
|--------|--------|----------|
| Dos NPCs se cruzan | Saludo breve (asentir, grito) | 2-3 s |
| Dos NPCs están cerca > 30 s | Iniciar charla | 30-60 s |
| 3+ NPCs en zona social | Conversación grupal | 60-120 s |
| Jugador se acerca a NPC trabajando | Saludo rápido, continúa trabajando | 5 s |
| Jugador habla con NPC | Entrar en estado Interact | Variable |

### 4.2 Selectividad Social

Los NPCs no socializan con todos por igual:

| Condición | Probabilidad de socializar |
|-----------|---------------------------|
| Mismo trabajo | +30% |
| Vecinos de casa | +20% |
| Amistad alta (M20) | +40% |
| Mismo género | +10% |
| Sin relación | Base (50%) |

## 5. Reacciones Ambientales

| Condición | Reacción |
|-----------|----------|
| Lluvia | Buscar refugio (techo cercano) |
| Tormenta | Volver a casa inmediatamente |
| Noche (> 22:00) | Volver a dormir |
| Evento/festival | Ir al lugar del evento |
| Construction nearby (M17) | Mirar la construcción, comentar |
| Jugador pasa corriendo | Mirar al jugador, comentario rápido |
| Recurso agotado cerca | Comentario sobre el recurso |
