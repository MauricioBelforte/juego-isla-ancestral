# Tareas módulo 64 64-IA-De-NPC

**Estado:** 🟢 Disponible

**Items pendientes:** 49

[ ] T-64-001: Implementar MovementState con sub-estados (WalkTo, RunTo, Avoid, Wander)
[ ] T-64-002: Implementar InteractState con sub-estados (TalkToPlayer, GiveGift, Trade)
[ ] T-64-003: Crear tests unitarios de transiciones de estado
[ ] T-64-004: Verificar que las transiciones respetan la animación actual
[ ] T-64-005: Verificar que el FSM funciona con 60+ NPCs simultáneos
[ ] T-64-006: Documentar estados y transiciones en 03-Diseno.md
[ ] T-64-007: Crear RoutineDefinition.gd como Resource
[ ] T-64-008: Crear RoutineSlot.gd con hour, minute, action, location
[ ] T-64-009: Verificar que las rutinas se resetean al cambio de día (M29)
[ ] T-64-010: Implementar variación aleatoria en rutinas (±15 min)
[ ] T-64-011: Documentar rutinas en 03-Diseno.md
[ ] T-64-012: Verificar que las necesidades no causan comportamiento errático
[ ] T-64-013: Crear config de necesidades (.tres) para ajustar velocidades
[ ] T-64-014: Documentar sistema de necesidades en 03-Diseno.md
[ ] T-64-015: Implementar separación entre NPCs (fuerza de separación)
[ ] T-64-016: Implementar navmesh del mundo (M08)
[ ] T-64-017: Verificar pathfinding en terreno irregular
[ ] T-64-018: Verificar pathfinding con obstáculos dinámicos (otros NPCs)
[ ] T-64-019: Medir rendimiento de pathfinding con 60 NPCs
[ ] T-64-020: Documentar configuración de navegación en 03-Diseno.md
[ ] T-64-021: Implementar selectividad social (mismo trabajo, vecinos, amistad)
[ ] T-64-022: Integrar con M20 (amistad afecta socialización)
[ ] T-64-023: Integrar con M21 (diálogos de socialización)
[ ] T-64-024: Verificar que las socializaciones no bloquean la rutina
[ ] T-64-025: Implementar límite de socializaciones simultáneas
[ ] T-64-026: Documentar reglas sociales en 03-Diseno.md
[ ] T-64-027: Implementar reacción a construcciones del jugador (M17)
[ ] T-64-028: Implementar reacción a recursos agotados (comentario)
[ ] T-64-029: Verificar que las reacciones interrumpen correctamente
[ ] T-64-030: Documentar reacciones en 03-Diseno.md
[ ] T-64-031: Verificar que NPCs lejanos no consumen pathfinding
[ ] T-64-032: Verificar presupuesto de agentes (M61: 60 NPCs máx)
[ ] T-64-033: Implementar pausa con GameClock (M29)
[ ] T-64-034: Documentar NPCManager en 04-Codigo.md
[ ] T-64-035: Integrar con M21 (diálogos según estado)
[ ] T-64-036: Integrar con M65 (animales IA)
[ ] T-64-037: Integrar con M08 (navmesh del mundo voxel)
[ ] T-64-038: Integrar con M20 (amistad afecta socialización)
[ ] T-64-039: Verificar integración completa con todos los módulos
[ ] T-64-040: Crear test de FSM: transiciones entre todos los estados
[ ] T-64-041: Crear test de rutinas: ejecución correcta de agenda diaria
[ ] T-64-042: Crear test de necesidades: decremento y recuperación
[ ] T-64-043: Crear test de navegación: llegada a destino sin atascos
[ ] T-64-044: Crear test de social: interacciones entre NPCs
[ ] T-64-045: Crear test de rendimiento: 60 NPCs con IA completa
[ ] T-64-046: Crear test de rendimiento: 100+ NPCs con simulación parcial
[ ] T-64-047: Crear test de persistencia: guardar/cargar estado de IA
[ ] T-64-048: Crear test de edge case: NPC sin rutina definida
[ ] T-64-049: Crear test de edge case: todos los NPCs durmiendo simultáneamente
