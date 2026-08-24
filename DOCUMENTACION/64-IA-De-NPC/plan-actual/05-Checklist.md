**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 64: IA de NPC

## Checklist de Implementación

### FSM y Estados (20 items)
- [ ] Crear clase base State.gd con enter/update/exit/check_transitions
- [ ] Implementar StateMachine.gd con update y transition_to
- [ ] Implementar IdleState con sub-estados (Wait, Look, Fidget)
- [ ] Implementar MovementState con sub-estados (WalkTo, RunTo, Avoid, Wander)
- [ ] Implementar WorkState con sub-estados (WorkAnimate, WorkPause, WorkComplete)
- [ ] Implementar SocialState con sub-estados (Greet, Chat, GroupChat)
- [ ] Implementar EatState con sub-estados (GoToEat, Eating, LeaveEat)
- [ ] Implementar SleepState con sub-estados (GoToSleep, Sleeping, WakeUp)
- [ ] Implementar ReactState con sub-estados (ReactRain, ReactEvent, ReactPlayer, ReactDanger)
- [ ] Implementar InteractState con sub-estados (TalkToPlayer, GiveGift, Trade)
- [ ] Definir reglas de transición para cada par de estados
- [ ] Implementar prioridad de transiciones (urgente > alta > media > baja)
- [ ] Implementar historial de estados (para debugging)
- [ ] Crear tests unitarios de transiciones de estado
- [ ] Verificar que ningún estado queda bloqueado permanentemente
- [ ] Implementar transición suave (no teletransporte entre estados)
- [ ] Verificar que las transiciones respetan la animación actual
- [ ] Implementar fallback a Idle si un estado falla
- [ ] Verificar que el FSM funciona con 60+ NPCs simultáneos
- [ ] Documentar estados y transiciones en 03-Diseno.md

### Rutinas (15 items)
- [ ] Crear RoutineDefinition.gd como Resource
- [ ] Crear RoutineSlot.gd con hour, minute, action, location
- [ ] Implementar RoutinePlayer.get_next_action()
- [ ] Implementar RoutinePlayer.is_action_due()
- [ ] Crear rutina de ejemplo para Luna (pintora)
- [ ] Crear rutina de ejemplo para Rocky (herrero)
- [ ] Crear rutina de ejemplo para Coral (exploradora)
- [ ] Crear rutina de ejemplo para Chef (cocinero)
- [ ] Crear rutina de ejemplo para Fin (pescador)
- [ ] Crear rutina de ejemplo para Flora (jardinera)
- [ ] Crear rutina de ejemplo para Sage (bibliotecario)
- [ ] Crear rutina de ejemplo para Merc (mercader)
- [ ] Verificar que las rutinas se resetean al cambio de día (M29)
- [ ] Implementar variación aleatoria en rutinas (±15 min)
- [ ] Documentar rutinas en 03-Diseno.md

### Necesidades (10 items)
- [ ] Crear NPCNeeds.gd con hunger, energy, social, mood
- [ ] Implementar decremento de necesidades por delta time
- [ ] Implementar recuperación de necesidades (comer, dormir, socializar)
- [ ] Implementar umbrales de necesidad (hunger < 20 → need_eat)
- [ ] Implementar prioridad de necesidades (hunger > energy > social)
- [ ] Integrar necesidades con FSM (necesidad → transición)
- [ ] Verificar que las necesidades no causan comportamiento errático
- [ ] Implementar persistencia de necesidades (guardado M59)
- [ ] Crear config de necesidades (.tres) para ajustar velocidades
- [ ] Documentar sistema de necesidades en 03-Diseno.md

### Navegación (15 items)
- [ ] Configurar NavigationAgent3D en NPCAgent.tscn
- [ ] Implementar navigate_to() con NavigationServer3D
- [ ] Implementar _physics_process() con pathfinding
- [ ] Configurar path_desired_distance y target_desired_distance
- [ ] Configurar radius del NPC
- [ ] Implementar anti-atasco (stuck detection > 2 s)
- [ ] Implementar desvío de obstáculos
- [ ] Implementar separación entre NPCs (fuerza de separación)
- [ ] Implementar respawn de emergencia (> 10 s atascado)
- [ ] Limitar paths simultáneos a 60
- [ ] Implementar navmesh del mundo (M08)
- [ ] Verificar pathfinding en terreno irregular
- [ ] Verificar pathfinding con obstáculos dinámicos (otros NPCs)
- [ ] Medir rendimiento de pathfinding con 60 NPCs
- [ ] Documentar configuración de navegación en 03-Diseno.md

### Social (10 items)
- [ ] Implementar detección de NPCs cercanos (proximity)
- [ ] Implementar saludo breve (2-3 s) al cruzarse
- [ ] Implementar charla (> 30 s cerca)
- [ ] Implementar conversación grupal (3+ NPCs)
- [ ] Implementar selectividad social (mismo trabajo, vecinos, amistad)
- [ ] Integrar con M20 (amistad afecta socialización)
- [ ] Integrar con M21 (diálogos de socialización)
- [ ] Verificar que las socializaciones no bloquean la rutina
- [ ] Implementar límite de socializaciones simultáneas
- [ ] Documentar reglas sociales en 03-Diseno.md

### Reacciones Ambientales (10 items)
- [ ] Implementar reacción a lluvia (buscar refugio)
- [ ] Implementar reacción a tormenta (volver a casa)
- [ ] Implementar reacción a noche (> 22:00 → dormir)
- [ ] Implementar reacción a eventos/festivals (ir al lugar)
- [ ] Implementar reacción a construcciones del jugador (M17)
- [ ] Implementar reacción al jugador (mirar, comentario)
- [ ] Implementar reacción a recursos agotados (comentario)
- [ ] Integrar con M31 (clima) y M32 (estaciones)
- [ ] Verificar que las reacciones interrumpen correctamente
- [ ] Documentar reacciones en 03-Diseno.md

### NPCManager (10 items)
- [ ] Crear NPCManager.gd como autoload
- [ ] Implementar registro y desregistro de NPCs
- [ ] Implementar niveles de simulación (full/medium/light/sleep)
- [ ] Implementar actualización por distancia al jugador
- [ ] Verificar que NPCs lejanos no consumen pathfinding
- [ ] Implementar métricas de rendimiento (tiempo de tick)
- [ ] Implementar logging de estado (DOM-IA)
- [ ] Verificar presupuesto de agentes (M61: 60 NPCs máx)
- [ ] Implementar pausa con GameClock (M29)
- [ ] Documentar NPCManager en 04-Codigo.md

### Integración (10 items)
- [ ] Integrar con M19 (datos de NPCs: position, home, job)
- [ ] Integrar con M29/M30 (hora/día para rutinas)
- [ ] Integrar con M31/M32 (clima/estaciones)
- [ ] Integrar con M21 (diálogos según estado)
- [ ] Integrar con M61 (rendimiento)
- [ ] Integrar con M65 (animales IA)
- [ ] Integrar con M08 (navmesh del mundo voxel)
- [ ] Integrar con M59 (guardado de estado de NPCs)
- [ ] Integrar con M20 (amistad afecta socialización)
- [ ] Verificar integración completa con todos los módulos

### Testing (10 items)
- [ ] Crear test de FSM: transiciones entre todos los estados
- [ ] Crear test de rutinas: ejecución correcta de agenda diaria
- [ ] Crear test de necesidades: decremento y recuperación
- [ ] Crear test de navegación: llegada a destino sin atascos
- [ ] Crear test de social: interacciones entre NPCs
- [ ] Crear test de rendimiento: 60 NPCs con IA completa
- [ ] Crear test de rendimiento: 100+ NPCs con simulación parcial
- [ ] Crear test de persistencia: guardar/cargar estado de IA
- [ ] Crear test de edge case: NPC sin rutina definida
- [ ] Crear test de edge case: todos los NPCs durmiendo simultáneamente
