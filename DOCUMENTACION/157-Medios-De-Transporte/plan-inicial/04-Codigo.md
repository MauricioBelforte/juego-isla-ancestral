**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 04-Codigo.md — Modulo 157: Medios de Transporte

## Archivos Involucrados

### Scripts Principales (A Crear)

| Archivo | Responsabilidad | Dependencias |
|---------|-----------------|--------------|
| `TransportManager.gd` | Singleton orquestador. Registra transportes, gestiona viajes activos, coordina eventos. | Autoload en project.godot |
| `JourneyInstance.gd` | Node3D que representa un viaje activo. Controla progreso, dispara eventos, gestiona estado. | TransportManager, JourneyEvent |
| `TransportDef.gd` | Resource con definición estática de un tipo de transporte. | Ninguna |
| `JourneyEvent.gd` | Resource con definición de un evento de viaje. | EventChoice, Reward |
| `EventChoice.gd` | Resource con definición de una opción de respuesta a evento. | Reward, Penalty |
| `MysteryDef.gd` | Resource con definición de un misterio narrativo. | MysteryClue, MysteryFinalChoice |
| `MysteryClue.gd` | Resource con definición de una pista de misterio. | Ninguna |
| `MysteryInstance.gd` | Clase que gestiona el estado de un misterio activo durante el viaje. | MysteryDef, MysteryClue |

### Scripts de Transporte (A Crear)

| Archivo | Transporte | Comportamiento específico |
|---------|------------|---------------------------|
| `ShipTransport.gd` | Barco | Velocidad base, eventos costeros, pesca |
| `TrainTransport.gd` | Tren | Velocidad alta, ruta fija, estaciones |
| `PlaneTransport.gd` | Avión | Velocidad máxima, combustible, vuelo libre |
| `CartTransport.gd` | Carreta | Velocidad baja, animal de tiro, caminos |
| `WalkingTransport.gd` | A Pie | Velocidad mínima, fatiga, exploración |

### Scripts de Eventos (A Crear)

| Archivo | Tipo de evento | Comportamiento |
|---------|----------------|----------------|
| `CombatEvent.gd` | COMBAT | Delega a M19 (CombatManager) |
| `DialogueEvent.gd` | DIALOGUE | Muestra opciones de diálogo, aplica consecuencias |
| `DiscoveryEvent.gd` | DISCOVERY | Otorga recursos, revela información |
| `EmergencyEvent.gd` | EMERGENCY | Situación de peligro, requiere acción inmediata |
| `MysteryEvent.gd` | MYSTERY | Agrega pista al misterio activo |
| `TradeEvent.gd` | TRADE | Interfaz de comercio con NPC |
| `RestEvent.gd` | REST | Pausa el viaje, restaura recursos |

### Scripts de UI (A Crear)

| Archivo | Función | Integración |
|---------|---------|-------------|
| `JourneyHUD.gd` | HUD principal: info del viaje, barra de progreso | CanvasLayer |
| `EventPanel.gd` | Panel de eventos: muestra evento activo y opciones | CanvasLayer |
| `MysteryPanel.gd` | Panel de misterios: muestra progreso de pistas | CanvasLayer |

### Scripts de Datos (A Crear)

| Carpeta | Contenido | Formato |
|---------|-----------|---------|
| `transport_definitions/` | Resources de TransportDef | .tres (Godot Resource) |
| `journey_events/` | Resources de JourneyEvent | .tres (Godot Resource) |
| `mysteries/` | Resources de MysteryDef | .tres (Godot Resource) |

## Contratos de Integración

### Contrato con M69 (Inventario)

```gdscript
# TransportManager.gd - Uso de Inventario
func _verify_travel_cost(transport: TransportDef) -> bool:
    return InventoryManager.has_item("coins", transport.base_cost)

func _deduct_travel_cost(transport: TransportDef) -> void:
    InventoryManager.remove_item("coins", transport.base_cost)

# Durante eventos
func _give_reward(reward: Reward) -> void:
    if reward.type == "item":
        InventoryManager.add_item(reward.item_id, reward.quantity)
    elif reward.type == "coins":
        EconomyManager.earn_coins(reward.amount)
```

### Contrato con M22 (NPCs)

```gdscript
# DialogueEvent.gd - Uso de NPCs
func _spawn_event_npc(npc_id: String, position: Vector3) -> void:
    var npc = NPCManager.spawn_npc(npc_id, position)
    npc.dialogue_completed.connect(_on_dialogue_completed)

func _get_npc_dialogue(npc_id: String) -> DialogueData:
    return NPCManager.get_dialogue(npc_id)
```

### Contrato con M24 (Misiones)

```gdscript
# JourneyInstance.gd - Uso de Misiones
func _check_mission_triggers(event: JourneyEvent) -> void:
    for mission_trigger in event.mission_triggers:
        if MissionManager.check_condition(mission_trigger.condition):
            MissionManager.complete_objective(
                mission_trigger.mission_id,
                mission_trigger.objective_id
            )
```

### Contrato con M19 (Combate)

```gdscript
# CombatEvent.gd - Uso de Combate
func _start_combat(enemies: Array[EnemyDef]) -> void:
    var result = await CombatManager.start_combat(enemies, _get_player_party())
    _apply_combat_result(result)

func _apply_combat_result(result: CombatResult) -> void:
    if result.victory:
        for reward in result.rewards:
            _give_reward(reward)
    else:
        _apply_penalty(result.failure_penalty)
```

### Contrato con M29 (Economía)

```gdscript
# TradeEvent.gd - Uso de Economía
func _get_player_coins() -> int:
    return EconomyManager.get_player_coins()

func _spend_coins(amount: int) -> bool:
    return EconomyManager.spend_coons(amount)

func _earn_coins(amount: int) -> void:
    EconomyManager.earn_coins(amount)
```

## Items Pendientes

### Fase 1: Core (Prioridad Alta)
- [ ] Crear TransportManager.gd como autoload
- [ ] Implementar TransportDef.gd (Resource)
- [ ] Implementar JourneyInstance.gd (Node3D)
- [ ] Implementar JourneyEvent.gd (Resource)
- [ ] Implementar EventChoice.gd (Resource)
- [ ] Crear flujo básico de viaje (iniciar → viajar → completar)
- [ ] Integrar con project.godot (autoload)

### Fase 2: Transportes (Prioridad Alta)
- [ ] Implementar los 5 tipos de transporte (Ship, Train, Plane, Cart, Walking)
- [ ] Crear 8 eventos base por tipo de transporte (40 eventos total)
- [ ] Implementar sistema de pool de eventos por transporte
- [ ] Integrar biomas en selección de eventos

### Fase 3: Eventos (Prioridad Media)
- [ ] Implementar CombatEvent.gd
- [ ] Implementar DialogueEvent.gd
- [ ] Implementar DiscoveryEvent.gd
- [ ] Implementar EmergencyEvent.gd
- [ ] Implementar TradeEvent.gd
- [ ] Implementar RestEvent.gd
- [ ] Integrar con M19 para combate

### Fase 4: Misterios (Prioridad Media)
- [ ] Implementar MysteryDef.gd (Resource)
- [ ] Implementar MysteryClue.gd (Resource)
- [ ] Implementar MysteryInstance.gd
- [ ] Implementar MysteryEvent.gd
- [ ] Crear 5 misterios base (1 por tipo de transporte)
- [ ] Implementar sistema de resolución de misterios

### Fase 5: UI (Prioridad Media)
- [ ] Implementar JourneyHUD.gd
- [ ] Implementar EventPanel.gd
- [ ] Implementar MysteryPanel.gd
- [ ] Crear escenas de UI para cada panel
- [ ] Integrar con sistema de input (teclado, mouse, gamepad)

### Fase 6: Integraciones (Prioridad Baja)
- [ ] Integrar con M69 (Inventario) - verificación de costos
- [ ] Integrar con M22 (NPCs) - spawning de NPCs en eventos
- [ ] Integrar con M24 (Misiones) - triggers de misiones
- [ ] Integrar con M29 (Economía) - comercio y costos
- [ ] Implementar persistencia de estado (save/load)

### Fase 7: Polish (Prioridad Baja)
- [ ] Animaciones de transición entre eventos
- [ ] Efectos de sonido para eventos
- [ ] Música contextual por tipo de transporte
- [ ] Optimización de rendimiento (pooling de eventos)
- [ ] Testing completo del sistema

## Notas del Agente

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

### Lo que hice
- Diseñé la arquitectura completa del sistema de transporte
- Definí 5 tipos de transporte con mecánicas únicas
- Creé 40 eventos base (8 por tipo de transporte)
- Diseñé el sistema de misterios narrativos por viaje
- Establecí contratos de integración con M69, M22, M24, M19, M29
- Propuse estructura de archivos y flujos de datos

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé código ejecutable (este es el plan inicial, no la implementación)
- No creé los Resources de Godot (.tres) para eventos y transportes
- No integré con sistemas existentes (M69, M22, etc.) ya que no están implementados
- No realicé testing (el sistema aún no existe)

### Intentos fallidos / decisiones
- No hubo intentos fallidos en esta fase de diseño
- Decisión principal: sistema de eventos por pool por transporte (no compartidos)
- Decisión secundaria: misterios por viaje (no acumulativos)

### Recomendaciones para el próximo agente
- **Empezar por TransportManager.gd** como autoload antes que cualquier otro script
- **Crear al menos 1 transporte funcional** (ej: Carreta, el más simple) para validar el flujo
- **Integrar con M69 primero** ya que es la dependencia más crítica (costos de viaje)
- **No crear todos los 40 eventos de golpe** - empezar con 2-3 por tipo y expandir
- **Los misterios son el feature premium** - invertir tiempo en que la narrativa sea buena
- **La UI debe ser minimalista al inicio** - solo barra de progreso y opciones de evento
- **Testing manual con PlayMode** antes de automatizar tests
