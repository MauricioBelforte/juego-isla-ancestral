# Reporte IA de NPCs — Crouton Alpha — 2026-11-08

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** Solo análisis estático de `game/isla-ancestral/scripts/`. Sin ejecución en Godot.

## Archivos analizados

| Archivo | Rol |
|---|---|
| `scripts/ia_npc/npc_agent.gd` (479 líneas) | Controlador por NPC, registra estados, blackboard, necesidades, rutina |
| `scripts/ia_npc/state_machine.gd` (271 líneas) | FSM orquestadora: transiciones, stuck, plan stack, nivel de simulación |
| `scripts/ia_npc/states/base_state.gd` (18 líneas) | Interfaz `enter/update/tick/exit/check_transitions` |
| `scripts/ia_npc/states/idle_state.gd`, `movement_state.gd`, `work_state.gd`, `social_state.gd`, `eat_state.gd`, `sleep_state.gd`, `react_state.gd`, `interact_state.gd` | Los 8 estados |
| `scripts/ia_npc/npc_manager.gd` (385 líneas) | Autoload: registro de agentes, burbujas de simulación, métricas, watchdog |
| `scripts/ia_npc/npc_blackboard.gd` (79 líneas) | Diccionario compartido entre estados |
| `scripts/ia_npc/npc_needs.gd` (129 líneas) | Hambre/energía/social/mood y umbrales de urgencia |
| `scripts/ia_npc/npc_watchdog.gd` (153 líneas) | Timeouts por estado y detección de bucles |
| `scripts/npc/villager.gd` (234 líneas) | NPC M19: visuales, diálogo, `interactuar()`, `set_ocupado()` |
| `scripts/npc/villager_dialogue_hook.gd` (186 líneas) | Puente a DialogueManager M21/M162 |
| `scripts/world/npc/rutina_ia.gd` (80 líneas) | FSM secundaria de rutinas M139 |
| `scripts/fauna/fauna_behavior.gd` (284 líneas) | FSM de fauna M36, 8 estados |
| `scripts/utils/state_machine.gd` (32 líneas) | FSM genérica M111 (no usada por NPCAgent) |

## 1. ¿Cómo funciona la máquina de estados de NPCs?

Dos FSM principales coexistiendo, más una de fauna:

### 1.1 FSM principal M64 (NPCs aldeanos)

- `npc_agent.gd:63-98` `_setup_components()` instancia 8 estados y los registra en `NPCStateMachine` con prioridades: Idle 10, Social 20, Work 25, Movement 30, Eat 35, Sleep 40, Interact 45, React 50. Arranque siempre en Idle (`:98`).
- `state_machine.gd:54-98` `transition_to(target, data)`: llama `exit()` del estado viejo, guarda historial (máx. 10), si el destino no existe cae a Idle con warning, gestiona `plan_stack` (push en transición normal, pop+señal `plan_failed` en fallback a Idle), emite `state_changed`.
- `state_machine.gd:103-122`: `update(delta)` corre cada frame (detección de atasco + `update()` + `check_transitions()` del estado actual) y `tick(delta)` corre en intervalo discreto (0,5 s full / 1 s medium / 5 s light, `npc_agent.gd:35-37,118-124`).
- Entradas a estados no solo por `check_transitions`: cada estado se auto-transiciona en su `tick()`/`update()` (ej. `idle_state.gd:40-64`, `movement_state.gd:55-64`), y el agente reacciona a la señal `need_urgent` (`npc_agent.gd:177-195`).
- Contexto compartido: `NPCBlackboard` (`npc_blackboard.gd:14-27`) con claves `player_position`, `is_raining`, `is_storming`, `is_night`, `event_active`, `current_event`, `nearby_npcs`, `needs_urgent`, `current_destination`, `target_position`. Se rellena en `npc_agent.gd:127-174`.
- Necesidades: `npc_needs.gd:53-72` decrementa hambre/energía/social por segundo; umbrales Hunger <20, Energy <15, Social <20 (`:25-27,65-72`). Prioridad hunger > energy > social.
- Rutina: `npc_agent.gd:364-386` `check_routine_transition()` traduce la acción de `RoutinePlayer` a estados (trabajar→Work, comer→Eat, dormir→Sleep, socializar→Social, ir_a_casa/ir_a_trabajar→Movement). Idle la consulta en su tick (`idle_state.gd:60-64`).
- Escalado: `npc_manager.gd:27-30,230-255` burbujas por distancia al jugador (full <30 m, medium <60 m, light <100 m, resto sleep), tope 60 NPCs full. En sleep, `state_machine.gd:137-142` fuerza Sleep si estaba en Movement/Work/Social/Eat, y `update/tick` se detienen (`:104,118`).
- Supervisión: `npc_watchdog.gd:25-38` timeouts por estado (Movement 30 s, Work 120 s, Idle 60 s, etc.) y detección de bucles (>10 transiciones en 5 s, `:90-95`); el manager fuerza recovery (`npc_manager.gd:146-168`). `state_machine.gd:153-193` además detecta atasco físico solo en Movement/Work (excluye estáticos desde el fix BUG-011, `:159-170`).

### 1.2 FSM secundaria M139 (rutina por waypoints)

`rutina_ia.gd:18` enum `IDLE, CAMINANDO, ESPERANDO, EN_PUESTO, RECUPERANDO`. `tick(hora, delta)` (`:37-49`) elige waypoint por franja horaria y pone CAMINANDO. `recuperar()` (`:52-58`) retrocede al waypoint anterior (anti-stuck, máx. 3 reintentos).

### 1.3 FSM de fauna M36

`fauna_behavior.gd:20` enum de 8 estados (INACTIVO, DEAMBULAR, ALIMENTARSE, DESCANSAR, ALERTA, HUIDA, CURIOSA_ACERCARSE, OBSERVANDO_JUGADOR). `tick()` (`:90-113`) despacha por estado; `_process` (`:126-127`) auto-impulsa la FSM y emite `solicitar_movimiento` para que M65 mueva al animal. Es la única FSM que reacciona de forma continuada al jugador (ver §4).

## 2. Estados inalcanzables o transiciones rotas

Confirmados con grep sobre `scripts/ia_npc/`:

1. **Estado Interact: inalcanzable (el más grave).** Se registra en `npc_agent.gd:87` pero hay **0 llamadas** a `transition_to(&"Interact")` en todo `ia_npc/`. El diálogo con el jugador va por otro camino: `villager.gd:197-202` `interactuar()` → `villager_dialogue_hook.gd:36-70` → DialogueManager M21/M162, sin pasar por la FSM M64.
2. **Interact además está roto si se entrara:** `interact_state.gd:19,35,45,52` llama `controller.set_ocupado(...)` sin guarda `has_method`, pero `NPCAgent` **no define** `set_ocupado` (grep: 0 definiciones; sí la define `villager.gd:214-216`, que es otro nodo). Como `state_machine.gd:40` pone `controller = get_parent()` (el NPCAgent), entrar a Interact produciría error de método inexistente.
3. **React tipo PLAYER/DANGER muertos:** `react_state.gd:7,43-45` maneja `Type.PLAYER` (pararse) y `Type.DANGER` (ir a casa), pero todas las transiciones a React (`idle_state.gd:52,58`, `movement_state.gd:63`, `work_state.gd:40`) no pasan `data`, así que `enter()` (`react_state.gd:14`) usa el default `type=0` (lluvia). Esas ramas nunca se ejercen. Además `react_state.gd:65-66` el tipo 3 sale al instante en el primer tick.
4. **Clave `energy` fantasma en el blackboard:** `idle_state.gd:54` y `work_state.gd:36` leen `bb.get_value("energy", 100.0)`. El blackboard nunca escribe `energy` (solo `needs_urgent`, `npc_agent.gd:151-152`), así que siempre vale 100 y esas condiciones son muertas. La energía real vive en `_needs.energy` (`npc_needs.gd:15`).
5. **Señal `need_urgent` casi muerta:** solo se emite desde `eat()`/`socialize()` (`npc_needs.gd:79,92,95-98`), nunca desde `update()` (`:53-61`) al cruzar el umbral. El camino real de urgencias es el polling del blackboard en los ticks de Idle/Movement, no `_on_need_urgent` (`npc_agent.gd:177-195`).
6. **Movement pierde la intención de la rutina:** `npc_agent.gd:380-383` devuelve Movement para ir_a_casa/ir_a_trabajar sin fijar `current_destination`; `movement_state.gd:38-46` al llegar mira `current_destination` y cae a Idle. El destino se perdió en la transición.
7. **Fauna — ALIMENTARSE inalcanzable, INACTIVO sin retorno:** grep en `fauna_behavior.gd`: 0 `cambiar_estado(Estado.ALIMENTARSE)` y 0 `cambiar_estado(Estado.INACTIVO)` tras el arranque (`:79` entra directo a DEAMBULAR). `_tick_alimentarse` (`:164-167`) y `_tick_inactivo` (`:137-139`, un `pass`) son código muerto en práctica. DESCANSAR sí se alcanza vía `_on_dia_cambio` (`:261-275`).
8. **RutinaIA — ESPERANDO nunca se asigna y CAMINANDO nunca termina:** `rutina_ia.gd` no asigna `ESPERANDO` en ningún punto, y `_mover_hacia` (`:75-77`) es un stub (`pass` declarado: "el movimiento real es de M64"), así que EN_PUESTO solo se alcanza por `bucle_fijo` (`:40-42`).
9. **`apply_separation` nunca se llama:** se define en `npc_agent.gd:239-252` (grep: 1 sola aparición, la definición). Los NPCs no se separan y pueden solaparse visualmente.

## 3. Problemas de rendimiento en la IA

1. **Blackboard actualizado cada frame por cada NPC:** `npc_agent.gd:110-124` `_process` llama `_update_blackboard(delta)` siempre, incluidos niveles light/sleep. Eso implica por NPC y por frame: `get_tree().get_nodes_in_group("player")` (`:130`), 3× `get_node_or_null("/root/...")` (Weather, GameTime, eventos, `:133-141`), más `_update_nearby_npcs` (`:155-174`) que recorre **todos** los villagers activos y calcula distancia → coste O(N²) por frame en la aldea. Con N NPCs en full/medium, el tick discreto de 0,5/1 s no salva nada porque el blackboard ya corrió 30-60 veces.
2. **búsqueda del jugador sin cachear:** `get_nodes_in_group("player")` se repite en `npc_agent.gd:130`, `npc_manager.gd:259`, `interact_state.gd:39` y `get_first_node_in_group` en `fauna_behavior.gd:130`, cada frame.
3. **Manager también cada frame:** `npc_manager.gd:57-64` `_process` ejecuta `_update_simulation_levels` (recorre todos los agentes + distancia al jugador, `:230-255`) y `_update_performance_metrics` (recorre los agentes dos veces más y promedia el historial, `:265-294`, además hace `append` cada frame en `:274` aunque el promedio solo se emite cada ~10 frames). Las métricas miden un loop vacío (`pass` en `:272`), así que el promedio reportado no refleja el coste real de la IA.
4. **Watchdog cada frame:** `npc_watchdog.gd:48-50` recorre todos los NPCs registrados por frame solo para sumar `delta` a un timer; debería ser un tick a 1 Hz.
5. **Spam de `print`:** cada entrada/salida de estado y transición imprime (`state_machine.gd:49,98`, todos los estados). En una aldea activa son decenas de líneas por segundo de I/O de consola.
6. **Respaldo que no se usa:** `apply_separation` (punto 2.9) hace trabajo O(N) por llamada pero nunca se invoca; si se invocara desde Movement sin spatial partitioning, agravaría el O(N²).

El diseño de burbujas (`npc_manager.gd:27-30`) y del tick discreto (`npc_agent.gd:35-37`) es correcto en intención, pero queda invalidado porque el trabajo pesado (blackboard + nearby) corre a 60 Hz en todos los niveles.

## 4. NPCs que no reaccionan al jugador

- **Villagers M64: no reaccionan.** El blackboard guarda `player_position` (`npc_agent.gd:132`) pero **ningún estado la consume** para decidir: Idle, Movement, Work, Eat, Sleep y Social ignoran la distancia al jugador. La única reacción pensada era Interact (inaccesible, §2.1) y React tipo PLAYER (código muerto, §2.3). Resultado: un villager sigue trabajando/deambulando aunque el jugador esté pegado a él; solo reacciona el sistema M19/M21 al pulsar interactuar (`villager.gd:197-202`, diálogo y evento de regalo `recibir_regalo` `:205-211`), que además no pausa la FSM M64: el NPC puede estar en Work/Movement mientras "habla".
- **Fauna: sí reacciona.** `fauna_behavior.gd:146-158` pasa a HUIDA/ALERTA dentro de `radio_alarma` según `comportamiento`, `:205-220` la especie CURIOSA se acerca y OBSERVANDO_JUGADOR se queda mirando, con velocidad de huida multiplicada por `factor_miedo` (`:190-191`). Es el mejor ejemplo de reacción al jugador del proyecto.
- **Social solo mira NPC-NPC:** `social_state.gd` y `_select_social_partner` (`npc_agent.gd:210-225`) priorizan mismo oficio y vecinos a <5 m (`:167`); el jugador no entra en esa selección.

## 5. Dos mejoras sugeridas

### Mejora 1 — Cablear la reacción al jugador y resucitar Interact

- En `idle_state.gd` `tick()` (o en `_update_blackboard`), si `distance_to(player_position) < 3.0` m, transicionar a `Interact` con `{"partner_id": "player"}`. Hoy ese check no existe en ningún estado.
- Implementar `set_ocupado(bool)` en `NPCAgent` (hoy solo existe en `villager.gd:214`) delegando al padre Villager, y hacer que `villager.gd:197-202` `interactuar()` dispare `transition_to(&"Interact")` además de abrir el diálogo M21, para que el NPC deje de trabajar mientras habla.
- Alternativa honesta si se decide no usar la FSM para el diálogo: eliminar `interact_state.gd` y su registro (`npc_agent.gd:19,78,87`) para no dejar un estado con prioridad 45 que nunca se alcanza y que referencia un método inexistente.

### Mejora 2 — Percepción por tick y separación real (rendimiento)

- Mover `_update_blackboard` y `_update_nearby_npcs` de `_process` (60 Hz) al tick discreto existente (`npc_agent.gd:118-124`), con interval según nivel de simulación; cachear la referencia al jugador en `_ready` en vez de `get_nodes_in_group` por frame; y usar una grilla espacial o como mínimo radio de búsqueda acotado para `nearby_npcs` (hoy O(N²)).
- Invocar `apply_separation()` (`npc_agent.gd:239-252`, hoy muerto) desde `movement_state.gd`/`social_state.gd` sumándolo a la velocidad, para evitar solapamientos.
- Quitar o condicionar los `print` de transición a un flag de debug, y corregir la métrica vacía de `npc_manager.gd:265-274` midiendo el tiempo real de los ticks de la FSM.

## Conclusión final

La arquitectura M64 es sólida: FSM con prioridades, plan stack con recovery, watchdog con timeouts por estado, burbujas de simulación y persistencia M59. Pero en la práctica está **desconectada del jugador**: el estado que debería reaccionar (Interact) es inalcanzable y además llama a un método que NPCAgent no tiene, el blackboard guarda la posición del jugador sin que nadie la use, y la reacción real vive fuera de la FSM (M19/M21) sin pausarla. A eso se suman estados muertos (ALIMENTARSE en fauna, ESPERANDO en RutinaIA, ramas PLAYER/DANGER de React), una clave `energy` que nunca se escribe y una señal de urgencia que casi nunca se emite. En rendimiento, el coste dominante no es la FSM sino la percepción: blackboard + vecinos a 60 Hz por NPC (O(N²)) invalida el diseño de burbujas. Prioridad recomendada: (1) cablear Interact y la pausa de la FSM durante el diálogo, (2) pasar la percepción al tick discreto con jugador cacheado. Con esos dos cambios la IA pasa de "funciona en papel" a "reacciona y escala".
