# Reporte — IA de NPCs (M64) / Sistemas NPC

**Fecha:** 2026-11-09  
**Modelo:** Glyph Cluster  
**Alcance:** `game/isla-ancestral/scripts/ia_npc/**/*.gd` y `game/isla-ancestral/scripts/npc/**/*.gd` (y referencias a `scripts/world/npc/*`)

## 1) Cómo funciona la state machine de NPCs

### Arquitectura principal (M64)
- **Orquestador FSM:** `game/isla-ancestral/scripts/ia_npc/state_machine.gd` (271 líneas).
  - Mantiene `_states: Dictionary` (nombre `StringName` → nodo de estado), `current_state`, historial (`_history`, máx. 10), y una pila de planes (`plan_stack`).
  - **Registro:** `register_state(state, name, priority)` (líneas 37–49) asigna `state_name/priority/controller`, y si el estado no tiene padre lo agrega como hijo con `add_child(state)` (líneas 46–47). Esto corrige BUG-129 (huérfanos al cerrar).
  - **Transición:** `transition_to(target, data)` (54–98): llama `exit()` del estado actual, resuelve el estado destino (fallback a `Idle` si no existe, 68–76), llama `enter(data)`, gestiona `plan_stack` (push en transiciones normales, pop + señal `plan_failed` en fallback a Idle, 78–96), emite `state_changed` y registra log.
  - **Update:** `update(delta)` (103–112) ejecuta anti-atasco, `current_state.update(delta)` y, si `check_transitions()` retorna `{"target": ...}`, hace `transition_to(...)`.
  - **Tick discreto:** `tick(delta)` (117–121) delega a `current_state.tick(delta)`.
  - **Simulación por nivel:** `set_simulation_level(level)` (126–142); si pasa a `sleep` y el estado actual es `Movement/Work/Social/Eat`, fuerza transición a `Sleep`.
  - **Anti-atascos:** `_update_stuck_detection` (153–193) solo aplica a estados que deberían moverse (`Movement/Work`, 164–170). Si está “atascado” > 2s emite `stuck_detected` y fuerza nuevo objetivo; > 10s hace respawn de emergencia al hogar (via `VillagerManager.get_hogares()`).

### Clase base de estado
- **Base canónica usada por la FSM:** `game/isla-ancestral/scripts/ia_npc/states/base_state.gd` (18 líneas). Extiende `Node` (no `RefCounted`) para permitir `get_node_or_null/get_tree`. Define `controller`, `state_name`, `priority`, hooks `enter/update/tick/exit/check_transitions` y `get_state_name_raw()`.
- **Base alternativa (no usada por el orquestador actual):** `game/isla-ancestral/scripts/ia_npc/state.gd` (43 líneas) define `class_name NPCState` con la misma interfaz conceptual; los estados concretos en `states/*.gd` extienden `base_state.gd`, no `state.gd`.

### Controlador por NPC
- **`NPCAgent`** (`game/isla-ancestral/scripts/ia_npc/npc_agent.gd`, 479 líneas, `class_name NPCAgent`, `CharacterBody3D`).
  - En `_ready()` crea componentes, navegación, carga rutina y conecta `GameTime.dia_cambio` (51–61).
  - `_setup_components()` (63–99) instancia `state_machine.gd`, registra 8 estados: `Idle, Movement, Work, Social, Eat, Sleep, React, Interact` con prioridades 10–50; crea `NPCNeeds`, `NPCBlackboard`, `RoutinePlayer`; inicia en `Idle`.
  - `_process()` (110–124): si no está posando foto ni pausado, actualiza blackboard, llama `state_machine.update()` en `full/medium`, y ejecuta ticks discretos según nivel (`0.5s/1s/5s`).
  - `_update_blackboard()` (127–153): escribe `player_position`, clima (`Weather.is_raining/is_storming`), noche (`GameTime`), evento activo (`/root/eventos.get_evento_actual()`), `nearby_npcs` (< 5m via `VillagerManager.obtener_activos()`), y `needs_urgent`.
  - `_on_need_urgent()` (177–195): hambre→`Eat`, energía→`Sleep`, social→`Social` (elige partner con `_select_social_partner` priorizando mismo trabajo) o `Idle` si no hay nadie.
  - Navegación: crea `NavigationAgent3D` (101–107), `navigate_to()` (309–312), `is_at_destination()` (393–396). Ubicaciones: casa (hogar en `VillagerManager`), trabajo por profesión, comedor `(30,1,64)`, plaza `(64,1,64)`, refugio=casa (320–361).
  - Rutinas: `check_routine_transition()` (364–386) consulta `RoutinePlayer.get_next_action()` y mapea acciones a estados (`Work/Eat/Sleep/Social/Movement`).

### Estados concretos (comportamiento resumido)
- `idle_state.gd` (68 l.): detiene movimiento, cicla subestados (`Wait/Look/Fidget`), en `tick()` reacciona a necesidades urgentes, eventos, noche+energía baja, tormenta, y consulta rutina (`check_routine_transition`). **No implementa `check_transitions()`** (usa `base_state` vacío).
- `movement_state.gd` (70 l.): mueve con `NavigationAgent3D` (`velocity = dir*speed`, `move_and_slide`), resetea stuck timer mientras navega. Al llegar, transiciona según `current_destination` (`work/eat/sleep/social`→estado, resto→`Idle`). En `tick()` interrumpe por hambre/energía/tormenta.
- `work_state.gd` (47 l.): dura `duration` (def. 300s), marca ocupado, al completar→`Idle`. Interrumpe por energía crítica (<10) o tormenta.
- `eat_state.gd` (72 l.): fases `GO→EATING→LEAVE` (comedor→come 30s→casa→`Idle`), restaura hambre/mood.
- `sleep_state.gd` (82 l.): fases `GO→SLEEPING→WAKE`, duerme mínimo 180s y despierta al `wake_hour` de rutina o `GameTime`; restaura energía, reduce hambre.
- `social_state.gd` (60 l.): duración según `partner_count` (saludo 3s / charla 45s), se acerca al partner (<2.5m), termina si partner desaparece, tiempo acaba o hay necesidad urgente.
- `react_state.gd` (79 l.): tipos `RAIN/EVENT/PLAYER/DANGER` (por `data.type`); navega a refugio/plaza/casa o se detiene; en `exit()` limpia flags del blackboard y vuelve a `Idle`. **Nota:** su lógica de “terminar reacción” llama `exit()` internamente en `tick()` (58–68), lo que puede duplicar limpieza/transición (ver sección 2).
- `interact_state.gd` (53 l.): estado para hablar con jugador (temporizador 10s, marca ocupado, termina si jugador se aleja >5m).

### Gestor global y soporte
- `npc_manager.gd` (385 l., autoload): registra/desregistra agentes según `VillagerManager.poblacion_cambio`, crea `NPCAgent` si falta (instancia `scenes/npc/npc_agent.tscn` o fallback por script), ajusta niveles de simulación por distancia al jugador (burbujas `full<30m, medium<60m, light<100m`, máx. 60 full), conecta watchdog, reporta presupuesto a `MemoryMonitor/BudgetRegistry` (“ia_npc” 32MB), suscribe `PhotoService.photo_pose_request` para `pose_foto()`, y persiste sección `npc_ai` (ISaveProvider M59).
- `npc_watchdog.gd` (153 l.): timeouts por estado (Movement 30s, Work 120s, Social 90s, Eat 60s, Sleep 300s, React 45s, Interact 120s, Idle 60s) y detección de ráfagas de transiciones (>10 en 5s). Emite `stuck_detected/recovery_forced`; `NPCManager` responde forzando `Idle`, `recover_plan`, `work_complete` o `wake_up`.
- `npc_needs.gd` (129 l.): hambre/energía/social/mood (0–100), decrementos configurables, urgencias con prioridad hambre > energía > social, señal `need_urgent`.
- `npc_blackboard.gd` (79 l.): diccionario compartido (`player_position`, clima, evento, noche, destino, `needs_urgent`, `nearby_npcs`, etc.).
- `plan_stack.gd` (142 l.): pila de planes (máx. 8) para recovery tras fallos/desvíos.
- `routine_player.gd` (115 l.): interpreta `VillagerProfile.rutina_diaria` según `GameTime` y mapea acciones a ubicaciones/estados.

### Sistemas NPC paralelos (fuera de `ia_npc`)
- `scripts/npc/villager.gd` + `villager_manager.gd` + `villager_dialogue_hook.gd` + `villager_mood.gd` + `villager_profile.gd`: capa de población/vecinos (M19), interacción con tecla `F`, catálogo en `data/villagers`, mudanzas, hogares, memoria, agenda horaria, línea de visión por muestreo voxel, persistencia sección `npc`. `VillagerDialogueHook` resuelve diálogo (M162 contextual → fallback `dialogue_id`) e inicia `/root/DialogueManager`.
- `scripts/world/npc/rutina_ia.gd` + `npc_profile.gd`: plantilla/IA de rutina ligera (M139) con estados `IDLE/CAMINANDO/ESPERANDO/EN_PUESTO/RECUPERANDO`, waypoints por franja horaria y anti-stuck conceptual; `_mover_hacia()` es stub (“movimiento real es de M64”). Es un **sistema distinto** al FSM de `ia_npc`.

## 2) Estados inalcanzables o transiciones rotas

### Hallazgos
1. **`InteractState` no se alcanza desde la FSM/M64 por flujo normal.**
   - `NPCAgent.check_routine_transition()` (364–386) no mapea ninguna acción a `Interact`.
   - `IdleState.tick()` (38–64) no transiciona a `Interact`.
   - `_on_need_urgent()` (177–195) no transiciona a `Interact`.
   - Búsqueda de `transition_to(&"Interact")` en `scripts/` no muestra llamadas desde la IA/rutinas. `InteractState` está registrado (npc_agent.gd:78/87) y tiene lógica para conversación con jugador, pero **no hay disparador**. La interacción del jugador con vecinos pasa por `VillagerManager._unhandled_input` (KEY_F, villager_manager.gd:341–349) → `villager.interactuar()` → `VillagerDialogueHook.solicitar_dialogo()` (villager_dialogue_hook.gd:36+), que usa `DialogueManager` (M21/M162), **sin entrar al estado `Interact` del FSM M64**. Resultado: estado efectivamente huérfano respecto al pipeline M64.

2. **`ReactState` hace transición desde `exit()` y también invoca `exit()` desde `tick()` — riesgo de doble salida/limpieza.**
   - `react_state.gd:53–69`: en varias ramas llama `exit(); return`.
   - `react_state.gd:71–79`: `exit()` limpia blackboard y ejecuta `controller.get_state_machine().transition_to(&"Idle")`.
   - `state_machine.transition_to()` (54–61) ya llama `current_state.exit()` antes de cambiar de estado. Si `tick()` invoca `exit()` y este hace `transition_to(&"Idle")`, se produce una transición anidada/limpieza duplicada y flujo difícil de razonar. Puede generar efectos secundarios (limpieza repetida, historial/plan_stack inconsistente, logs confusos).

3. **Transición `Sleep` condicionada a `sleep` level puede quedar “pegada”.**
   - `state_machine.set_simulation_level()` (126–142) fuerza `Sleep` solo si el nivel pasa a `"sleep"` y el estado actual está en `Movement/Work/Social/Eat`. **No** contempla `React` o `Interact`.
   - `npc_manager._update_simulation_levels()` asigna `"sleep"` cuando la distancia al jugador no cae en `full/medium/light` (>= 100m, 241–255). Un NPC reaccionando o interactuando lejos podría no ser forzado a `Sleep` por el cambio de nivel de simulación (depende de la lógica interna del estado).

4. **Fallback de transición oculta errores de mapeo.**
   - `state_machine.transition_to()` cae a `Idle` si el destino no existe (68–76). Esto evita crashes, pero puede **enmascarar estados/acciones mal configuradas** (p. ej. rutina devuelve acción no soportada y el sistema “parece” funcionar volviendo a `Idle`).

5. **Plan stack interpreta fallback a Idle como fallo de plan.**
   - `state_machine.gd:78–96`: si hay fallback o transición a `Idle` desde un estado no-Idle, hace `pop_plan()` y emite `plan_failed`. Esto es útil para recovery, pero también puede disparar `plan_failed` en retornos legítimos a `Idle` (finalización normal de muchos estados termina en `Idle` vía transición explícita; aquí el criterio es amplio: `target == &"Idle" and old_sn != "" and old_sn != "Idle"`). Puede contaminar métricas/recovery si no se distingue “completado” de “fallido”.

6. **Doble sistema de IA/rutinas no integrado.**
   - `scripts/world/npc/rutina_ia.gd` es una máquina de estados alternativa (stub de movimiento) y no se observa integrada con `NPCAgent`/`NPCStateMachine`. Puede quedar como código muerto o fuente de confusión si se espera que gobierne NPCs reales.

## 3) Problemas de rendimiento en la IA

1. **Escaneo global de NPCs por cada agente/cada actualización de blackboard.**
   - `NPCAgent._update_nearby_npcs()` (155–174) llama `VillagerManager.obtener_activos()` y recorre todos los activos, calculando distancia para llenar `nearby_npcs`. Se ejecuta desde `_update_blackboard()` en cada `_process()` (115). Con N agentes, el costo tiende a **O(N²)** por frame (cada uno compara contra todos). El `tick` está escalonado por nivel, pero el blackboard se actualiza siempre (salvo pausa/pose).

2. **Búsquedas repetidas de autoloads y nodos en runtime.**
   - En varios puntos se hace `get_node_or_null("/root/Weather")`, `/root/GameTime`, `/root/eventos`, `/root/VillagerManager`, `/root/PhotoService` desde estados/agentes por tick/update (p. ej. idle 51–59, react 59–66, npc_agent 130–149, sleep 40–49). Son lookups baratos individualmente, pero repetidos a escala. Cachear referencias (con validación) reduciría overhead.

3. **`NPCManager._update_performance_metrics()` recorre agentes sin hacer trabajo útil.**
   - `npc_manager.gd:265–295`: mide tiempo con un loop que solo hace `pass` (“El tick real lo hace el NPCAgent…”). Aporta poco como métrica real y consume ciclos cada frame. Además emite `performance_tick` cuando hay >=10 muestras, pero la medición no refleja el costo real de la IA.

4. **Creación de arrays/objetos frecuentes.**
   - `_get_nearby_node()` (228–235) y `_update_nearby_npcs()` iteran activos; `_select_social_partner` puede buscar nodos por id. `obtener_activos()` devuelve `duplicate()` (villager_manager.gd:417–418). En escenas con muchos NPCs, esto genera asignaciones frecuentes.

5. **Simulación por burbujas bien planteada, pero con límites.**
   - `NPCManager` limita `full` a 60 (`MAX_AGMPS_FULL`) y degrada niveles por distancia; `NPCAgent` reduce frecuencia de tick en `medium/light`. Sin embargo, `state_machine.update()` corre en `full/medium` (npc_agent.gd:116–117) y el blackboard se refresca siempre, por lo que NPCs `medium` aún pagan costo de blackboard + update cada frame.

6. **Logs de `print()` abundantes en runtime.**
   - FSM, estados, watchdog y manager imprimen en transiciones/ticks/eventos (muchas rutas). En builds con muchos NPCs, el I/O de consola puede afectar rendimiento y dificultar profiling.

## 4) NPCs que no reaccionan al jugador

1. **No existe reacción de IA al jugador dentro del FSM M64.**
   - `NPCAgent._update_blackboard()` guarda `player_position` (130–132), pero **ningún estado** en `scripts/ia_npc/states/*.gd` consulta `player_position` para saludar, mirar, acercarse, huir o iniciar `Interact`. `react_state.gd` define `Type.PLAYER` (7) y un caso que detiene movimiento (43–45), pero no hay código que transicione a `React` con `type=PLAYER` al detectar proximidad del jugador.
   - `npc_blackboard.gd` documenta `player_position` (21) y tiene helper `get_player_position()` (44–45), pero no se usa para decisiones de comportamiento.

2. **La interacción “al jugador” está desacoplada del FSM.**
   - El jugador interactúa con vecinos via `VillagerManager` (tecla `F`, rango 3m, línea de visión voxel; villager_manager.gd:341–400). Esto abre diálogo M21/M162 mediante `VillagerDialogueHook`. Los NPCs **no “reaccionan” por IA**; responden cuando el sistema de interacción los selecciona. `NPCAgent` sí escucha `PhotoService.photo_pose_request` para posar (npc_agent.gd:67–74, npc_manager.gd:127–137), pero eso no es reacción general al jugador.

3. **`InteractState` no conecta el flujo real jugador↔NPC.**
   - Aunque `interact_state.gd` comprueba distancia al jugador (>5m cancela), no hay ruta que lo active desde la detección de interacción del jugador. Por tanto, el estado existe pero no participa en la reacción observable al jugador.

4. **Riesgo de “NPC inerte” si falta perfil/rutina o navegación.**
   - `_get_profile()` (268–277) devuelve `null` si `VillagerManager.obtener_perfil()` no encuentra el perfil; en ese caso `profile_id` es `unknown` y `check_routine_transition()` puede devolver `{}` (364–367), dejando al NPC mayormente en `Idle` salvo necesidades urgentes. Esto no es “no reaccionar al jugador” específicamente, pero sí reduce comportamiento visible.
   - Si no hay `NavigationAgent3D` válido/navmesh, `MovementState`/destinos pueden no progresar; el watchdog/atascos intentan recuperar, pero la experiencia puede verse como NPCs que no responden.

## 5) Sugerencias de mejora (2)

1. **Unificar la reacción/interacción al jugador con el FSM M64 (activar `Interact`/`React PLAYER`).**
   - Agregar un disparador explícito: cuando `VillagerManager`/hook inicia diálogo o cuando el jugador entra en rango de interacción, notificar al `NPCAgent` (p. ej. `agent.request_interaction(player)` → `state_machine.transition_to(&"Interact", {...})` o `React` tipo `PLAYER`). Alternativamente, en `IdleState.tick()`/`NPCAgent` detectar proximidad del jugador (`player_position` del blackboard) y transicionar a un estado de reacción (mirar/saludar) respetando prioridades/ocupación.
   - Corregir `ReactState` para no llamar `exit()` manualmente desde `tick()` cuando se va a transicionar; usar un único camino de salida (retornar `{"target": &"Idle"}` desde `check_transitions()` o dejar que `state_machine.transition_to()` gestione `exit()`).
   - **Archivos:** `scripts/ia_npc/states/react_state.gd` (53–79), `interact_state.gd`, `idle_state.gd` (38–64), `npc_agent.gd` (127–153, 364–386), integración con `scripts/npc/villager_manager.gd` / `villager_dialogue_hook.gd`.

2. **Optimizar el costo por agente (blackboard/NPC cercanos) y reducir ruido de logs.**
   - Evitar O(N²) en proximidad: que `VillagerManager` mantenga una estructura espacial simple (grid/celdas por zona) o cache de vecinos cercanos por tick global; o que `NPCManager` calcule `nearby_npcs` una vez por intervalo para agentes `full/medium` en lugar de que cada `NPCAgent` recorra todos los activos en cada frame.
   - Actualizar blackboard pesado (cercanos, evento, clima) en el intervalo de `tick` del nivel, no en cada `_process()` para todos los niveles. Cachear referencias a autoloads (`GameTime/Weather/EventBus/VillagerManager`) en `_ready()` con revalidación defensiva.
   - Reemplazar `print()` frecuentes por un logger con niveles (debug/info/warn) o guardas `OS.is_debug_build()`; mantener señales/métricas para observabilidad sin saturar consola.
   - **Archivos:** `scripts/ia_npc/npc_agent.gd` (110–174, 228–235), `scripts/ia_npc/npc_manager.gd` (265–295), `scripts/npc/villager_manager.gd` (417–426), estados con `print()` en `enter/exit/tick`.

## Conclusión final

La IA de NPCs (M64) tiene una base sólida: **FSM explícita** (`state_machine.gd` + estados en `states/`), controlador por NPC (`NPCAgent`), necesidades/blackboard/plan stack/watchdog, integración con rutinas (`RoutinePlayer` + perfil), escalado por burbujas y persistencia. Los fixes documentados (BUG-129 huérfanos, BUG-011 atascos en estados estáticos/perfil) muestran madurez en el manejo de errores.

Sin embargo, hay **desconexiones funcionales importantes**: `InteractState` está registrado pero no se activa desde el flujo M64, y los NPCs **no reaccionan proactivamente al jugador** (solo responden a la interacción `F` vía `VillagerManager`/`DialogueManager`). `ReactState` tiene un patrón de salida riesgoso (llama `exit()` que a su vez transiciona). En rendimiento, el principal riesgo es el costo **O(N²)**/trabajo repetido al calcular NPCs cercanos y refrescar blackboard por frame, junto con lookups repetidos y logging verboso.

Las dos mejoras prioritarias son: (1) **conectar la reacción/interacción al jugador al FSM** y sanear el ciclo de salida de `ReactState`; (2) **optimizar la detección de cercanía/blackboard y el logging** para escalar con más NPCs sin degradar frames.