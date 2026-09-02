**Modelo:** glm-5.3
**Plataforma:** Cline

**Módulo:** 64-IA-De-NPC (64)

# Checklist personal tareas — 64-IA-De-NPC

> Extraídas del `05-Checklist.md` del módulo (49 pendientes de 110 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [ ] T-001 Implementar MovementState con sub-estados (WalkTo, RunTo, Avoid, Wander) *[?]*
- [ ] T-002 Implementar InteractState con sub-estados (TalkToPlayer, GiveGift, Trade) *[?]*
- [ ] T-003 Crear tests unitarios de transiciones de estado *[?]*
- [ ] T-004 Verificar que las transiciones respetan la animación actual *[?]*
- [ ] T-005 Verificar que el FSM funciona con 60+ NPCs simultáneos *[?]*
- [ ] T-006 Documentar estados y transiciones en 03-Diseno.md *[?]*
- [ ] T-007 Crear RoutineDefinition.gd como Resource *[?]*
- [ ] T-008 Crear RoutineSlot.gd con hour, minute, action, location *[?]*
- [ ] T-009 Verificar que las rutinas se resetean al cambio de día (M29) *[?]*
- [ ] T-010 Implementar variación aleatoria en rutinas (±15 min) *[?]*
- [ ] T-011 Documentar rutinas en 03-Diseno.md *[?]*
- [ ] T-012 Verificar que las necesidades no causan comportamiento errático *[?]*
- [ ] T-013 Crear config de necesidades (.tres) para ajustar velocidades *[?]*
- [ ] T-014 Documentar sistema de necesidades en 03-Diseno.md *[?]*
- [ ] T-015 Implementar separación entre NPCs (fuerza de separación) *[?]*
- [ ] T-016 Implementar navmesh del mundo (M08) *[?]*
- [ ] T-017 Verificar pathfinding en terreno irregular *[?]*
- [ ] T-018 Verificar pathfinding con obstáculos dinámicos (otros NPCs) *[?]*
- [ ] T-019 Medir rendimiento de pathfinding con 60 NPCs *[?]*
- [ ] T-020 Documentar configuración de navegación en 03-Diseno.md *[?]*
- [ ] T-021 Implementar selectividad social (mismo trabajo, vecinos, amistad) *[?]*
- [ ] T-022 Integrar con M20 (amistad afecta socialización) *[?]*
- [ ] T-023 Integrar con M21 (diálogos de socialización) *[?]*
- [ ] T-024 Verificar que las socializaciones no bloquean la rutina *[?]*
- [ ] T-025 Implementar límite de socializaciones simultáneas *[?]*
- [ ] T-026 Documentar reglas sociales en 03-Diseno.md *[?]*
- [ ] T-027 Implementar reacción a construcciones del jugador (M17) *[?]*
- [ ] T-028 Implementar reacción a recursos agotados (comentario) *[?]*
- [ ] T-029 Verificar que las reacciones interrumpen correctamente *[?]*
- [ ] T-030 Documentar reacciones en 03-Diseno.md *[?]*
- [ ] T-031 Verificar que NPCs lejanos no consumen pathfinding *[?]*
- [ ] T-032 Verificar presupuesto de agentes (M61: 60 NPCs máx) *[?]*
- [ ] T-033 Implementar pausa con GameClock (M29) *[?]*
- [ ] T-034 Documentar NPCManager en 04-Codigo.md *[?]*
- [ ] T-035 Integrar con M21 (diálogos según estado) *[?]*
- [ ] T-036 Integrar con M65 (animales IA) *[?]*
- [ ] T-037 Integrar con M08 (navmesh del mundo voxel) *[?]*
- [ ] T-038 Integrar con M20 (amistad afecta socialización) *[?]*
- [ ] T-039 Verificar integración completa con todos los módulos *[?]*
- [ ] T-040 Crear test de FSM: transiciones entre todos los estados *[?]*
- [ ] T-041 Crear test de rutinas: ejecución correcta de agenda diaria *[?]*
- [ ] T-042 Crear test de necesidades: decremento y recuperación *[?]*
- [ ] T-043 Crear test de navegación: llegada a destino sin atascos *[?]*
- [ ] T-044 Crear test de social: interacciones entre NPCs *[?]*
- [ ] T-045 Crear test de rendimiento: 60 NPCs con IA completa *[?]*
- [ ] T-046 Crear test de rendimiento: 100+ NPCs con simulación parcial *[?]*
- [ ] T-047 Crear test de persistencia: guardar/cargar estado de IA *[?]*
- [ ] T-048 Crear test de edge case: NPC sin rutina definida *[?]*
- [ ] T-049 Crear test de edge case: todos los NPCs durmiendo simultáneamente *[?]*
