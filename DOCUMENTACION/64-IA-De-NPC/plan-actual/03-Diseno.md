**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Última actualización:** 2026-09-18

# 03-Diseno.md — Módulo 64: IA de NPC

## 1. Arquitectura del Sistema

### 1.1 Componentes Principales (implementados)

```
NPCAgent (CharacterBody3D, por cada NPC)
├── NPCStateMachine (Node, FSM plana)
│   ├── IdleState        — Espera, mira alrededor, rutina
│   ├── MovementState    — Pathfinding con NavigationAgent3D
│   ├── WorkState        — Trabajo según profession
│   ├── SocialState      — Greet/Chat/GroupChat
│   ├── EatState         — GoToEat/Eating/LeaveEat
│   ├── SleepState       — GoToSleep/Sleeping/WakeUp
│   ├── ReactState       — ReactRain/ReactEvent/ReactPlayer/ReactDanger
│   └── InteractState    — TalkToPlayer/GiveGift/Trade
├── NPCPlanStack (RefCounted, pila de planes)
│   └── Push/Pop/Peek + recovery a Idle + MAX_DEPTH=8
├── NPCWatchdog (Node, anti-atascos)
│   └── Per-state timeouts + transition burst detection
├── RoutinePlayer (Node, agenda diaria)
│   └── Lee VillagerProfile.rutina_diaria (Dictionary)
├── NPCNeeds (RefCounted, hambre/energía/social/mood)
│   └── Configurable via npc_needs_config.tres
├── NPCBlackboard (RefCounted, datos compartidos)
│   └── player_position, is_raining, is_night, nearby_npcs, etc.
├── NavigationAgent3D (pathfinding)
└── NPCBudgetRegistry (en NPCManager, 32MB global)
```

### 1.2 FSM — Flujo de Control

El FSM es **plano** (no jerárquico). Cada estado tiene `enter()`, `exit()`, `update(delta)`, `tick(delta)`. La pila de planes (`NPCPlanStack`) permite recordar el estado anterior y hacer fallback:

```
Estado actual falla → pop plan → recuperar estado anterior → o Idle
```

El `NPCWatchdog` monitorea cada NPC con timeouts por estado:
- Movement > 30s → stuck (pathfinding roto)
- Work > 120s → warning
- Social > 90s → stuck
- Eat > 60s → warning
- Idle > 60s → posible fallo de rutina
- Más de 10 transiciones en 5s → bucle detectado

### 1.3 Rutinas

Las rutinas se almacenan en `VillagerProfile.rutina_diaria` como **Dictionary** (no como Resource separado):

```gdscript
# VillagerProfile.rutina_diaria:
{
    "06:00": "despertar",
    "07:00": "ir_a_trabajar",
    "07:30": "trabajar",
    "12:00": "comer",
    "13:00": "trabajar",
    "18:00": "ir_a_casa",
    "18:30": "socializar",
    "22:00": "dormir"
}
```

`RoutinePlayer.get_next_action()` compara hora:minuto actual con las keys del Dictionary. No hay randomización ±15min (pendiente).

### 1.4 Necesidades

Cuatro barras 0-100 con prioridad: `hunger > energy > social`. Cuando una cae bajo el umbral, se emite `need_urgent` y el FSM transiciona al estado correspondiente.

**Configuración configurable** (`npc_needs_config.tres`):

| Parámetro | Default | Descripción |
|-----------|---------|-------------|
| hunger_rate | 1.0 | Decremento por segundo |
| energy_rate | 0.5 | Decremento por segundo |
| social_rate | 0.3 | Decremento por segundo |
| hunger_urgency | 20.0 | Umbral de urgencia |
| energy_urgency | 15.0 | Umbral de urgencia |
| social_urgency | 20.0 | Umbral de urgencia |

### 1.5 Navegación

- **NavigationAgent3D** integrado en cada NPCAgent
- `path_desired_distance = 1.0`, `target_desired_distance = 0.5`, `radius = 0.4`
- Anti-atasco: stuck detection > 2s, respawn de emergencia > 10s
- **Separación entre NPCs**: `SEPARATION_FORCE=1.5`, `SEPARATION_RADIUS=1.5`
- Límite: 60 paths simultáneos

### 1.6 Social

- **Selectividad**: prioriza NPCs con mismo trabajo (`_select_social_partner()`)
- **Límite**: `MAX_SIMULTANEOUS_SOCIALS=3`
- Saludo breve 2-3s, charla > 30s, conversación grupal 3+ NPCs

### 1.7 Reacciones Ambientales

| Condición | Reacción | Estado |
|-----------|----------|--------|
| Lluvia | Buscar refugio | ✅ |
| Tormenta | Volver a casa | ✅ |
| Noche > 22:00 | Dormir | ✅ |
| Evento/festival | Ir al lugar | ✅ |
| Jugador pasa | Mirar, comentario | ✅ |
| Recurso agotado | Comentario | [?] pendiente M17 |
| Construcción nearby | Mirar, comentar | [?] pendiente M17 |

## 2. Transiciones de Estado

### 2.1 Reglas Implementadas

| Desde | Hacia | Condición |
|-------|-------|-----------|
| Idle | Movement | Rutina dice ir a otro lugar |
| Idle | Eat/Sleep | Necesidad urgente |
| Idle | Social | Necesidad social + NPC cercano |
| Movement | Work/Eat/Sleep | Llegó al destino |
| Work | Eat | Hora de comer |
| Work | Idle | Jornada terminada |
| Cualquiera | React | Evento urgente (lluvia, festival) |
| Cualquiera | Sleep | Energy urgente |
| Cualquiera | Eat | Hunger urgente |
| React → anterior | — | Evento terminado, pop del plan_stack |

### 2.2 Prioridad de Transiciones

1. **Urgente**: Lluvia, tormenta, festival, peligro → interrumpe todo
2. **Alta**: Hunger/energy urgente → transición inmediata
3. **Media**: Rutina (hora de trabajar, comer) → sigue agenda
4. **Baja**: Idle, mirar alrededor → solo si no hay nada mejor

### 2.3 Fallback y Recovery

Cuando un estado falla o el target no existe:
1. `state_machine.gd` detecta con `is_fallback` (variable `fell_back`)
2. Hace pop del plan_stack
3. Si el stack tiene un plan previo → recuperar ese estado
4. Si no → transicionar a Idle
5. `clear_plans()` resetea la pila completa

## 3. GameClock Integration (M29)

El FSM se pausa/resume con `GameTime.pausa()` / `GameTime.resume()`:

```gdscript
# En NPCAgent o NPCManager:
func pause_ai() -> void:
    var gt = get_node_or_null("/root/GameTime")
    if gt != null:
        gt.pausa()
    # El FSM deja de hacer update() en _process

func resume_ai() -> void:
    var gt = get_node_or_null("/root/GameTime")
    if gt != null:
        gt.resume()
```

GameClock (`GameTime` autoload):
- `_pausado = true` → `_process()` retorna sin avanzar tiempo
- `pausa()` / `resume()` son las API públicas
- `dia_cambio` signal → conectable para reset de rutinas diarias
- `hora_cambio` signal → conectable para rutinas por hora
- 1s real = 1 min de juego, día = 24 min reales

## 4. Persistencia

NPCAgent expone `get_save_data()` / `restore_save_data()`:
- Serializa: npc_id, state, needs (to_dict), sim_level
- NPCBlackboard: `to_dict()` / `from_dict()` (static)
- NPCPlanStack: `to_dict()` / `from_dict()` con key `"stack"`
- NPCNeeds: `to_dict()` / `from_dict()` con keys hunger/energy/social/mood
