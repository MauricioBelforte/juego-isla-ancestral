**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 03-Diseno.md — Modulo 157: Medios de Transporte

## Arquitectura General

```
┌─────────────────────────────────────────────────────┐
│                  TransportManager                    │
│  (Singleton - Orquestador Central)                  │
├─────────────────────────────────────────────────────┤
│  - active_journeys: Array[JourneyInstance]          │
│  - transport_types: Dictionary[String, TransportDef]│
│  - journey_events: Dictionary[String, Array[Event]] │
│  - mysteries_pool: Array[MysteryDef]                │
├─────────────────────────────────────────────────────┤
│  + start_journey(origin, dest, transport) → Journey │
│  + cancel_journey(journey_id) → bool                │
│  + get_available_transports(pos) → Array[Transport] │
│  + register_transport(type, definition) → void      │
│  + get_journey_events(transport_type) → Array[Event]│
└─────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│                  JourneyInstance                     │
│  (Node3D - Representación en el mundo)              │
├─────────────────────────────────────────────────────┤
│  - journey_id: String                               │
│  - transport_type: TransportDef                     │
│  - origin: Vector3                                  │
│  - destination: Vector3                             │
│  - current_progress: float (0.0 - 1.0)             │
│  - elapsed_time: float                              │
│  - events_triggered: Array[JourneyEvent]            │
│  - active_mystery: MysteryInstance                  │
│  - state: JourneyState (IDLE/TRAVELING/EVENT/END)   │
├─────────────────────────────────────────────────────┤
│  + _process(delta) → void                           │
│  + trigger_event(event) → void                      │
│  + advance_progress(delta) → void                   │
│  + getEstimatedTimeRemaining() → float              │
│  + get_current_biome() → BiomeDef                   │
│  + apply_event_choice(choice) → void                │
└─────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────┐
│                  JourneyEvent                        │
│  (Resource - Definición de evento)                   │
├─────────────────────────────────────────────────────┤
│  - event_id: String                                 │
│  - event_type: EventType (COMBAT/DIALOGUE/PUZZLE/   │
│                   DISCOVERY/EMERGENCY/MYSTERY)       │
│  - transport_types: Array[String] (qué transportes)  │
│  - biomes: Array[String] (en qué biomas)            │
│  - weight: float (probabilidad relativa)            │
│  - cooldown: float (segundos entre repeticiones)    │
│  - narrative_text: String                           │
│  - choices: Array[EventChoice]                      │
│  - rewards: Array[Reward]                           │
│  - mystery_puzzle: MysteryPuzzle (opcional)         │
├─────────────────────────────────────────────────────┤
│  + can_trigger(context) → bool                      │
│  + execute(journey) → void                          │
│  + get_choices() → Array[EventChoice]               │
└─────────────────────────────────────────────────────┘
```

## Tabla de Tipos de Transporte

| ID | Tipo | Velocidad | Capacidad | Costo base | Desbloqueo | Eventos max/viaje |
|----|------|-----------|-----------|------------|------------|-------------------|
| T01 | Barco | 1.0x | Alta (50 items) | 100 monedas | Inicio del juego | 8-12 |
| T02 | Tren | 1.5x | Media (30 items) | 150 monedas | Estación ferroviaria | 6-10 |
| T03 | Avión | 2.5x | Baja (10 items) | 300 monedas | Hangar | 4-8 |
| T04 | Carreta | 0.5x | Media (25 items) | 25 monedas | Inicio del juego | 10-15 |
| T05 | A pie | 0.3x | Baja (15 items) | 0 monedas | Inicio del juego | 12-18 |

### Definición de TransportDef (Resource)

```gdscript
class_name TransportDef
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var speed_multiplier: float
@export var max_carry_capacity: int
@export var base_cost: int
@export var unlock_condition: String
@export var icon: Texture2D
@export var scene_path: String  # Escena 3D del transporte
@export var journey_events_pool: Array[JourneyEvent]
@export var supported_biomes: Array[String]
```

## Sistema de Eventos de Viaje

### Tipo de Evento (Enum)

```gdscript
enum EventType {
    COMBAT,      # Combate con enemigos
    DIALOGUE,    # Conversación con NPC
    PUZZLE,      # Acertijo o problema lógico
    DISCOVERY,   # Hallazgo de recurso o lugar
    EMERGENCY,   # Situación de peligro
    MYSTERY,     # Pista de misterio narrativo
    TRADE,       # Comercio con NPC
    REST         # Punto de descanso/reabastecimiento
}
```

### Tabla de Eventos por Transporte

#### Barco (8 eventos base)

| ID | Nombre | Tipo | Bioma | Peso | Cooldown | Recompensa |
|----|--------|------|-------|------|----------|------------|
| EVT-B01 | Tormenta Eléctrica | EMERGENCY | Océano | 8 | 120s | -20% duración, posibilidad de daño |
| EVT-B02 | Naufragio a la Vista | DISCOVERY | Costa | 5 | 300s | Recurso raro (50%) |
| EVT-B03 | Isla Misteriosa | MYSTERY | Océano | 3 | 600s | Pista de misterio |
| EVT-B04 | Ballena Varada | DIALOGUE | Costa | 4 | 240s | Recurso marino |
| EVT-B05 | Piratas | COMBAT | Océano | 6 | 180s | Botín (monedas + items) |
| EVT-B06 | Contrabando | DIALOGUE | Costa | 3 | 400s | Decisión moral + recompensa |
| EVT-B07 | Niebla Densa | EMERGENCY | Océano | 7 | 150s | Riesgo de desvío |
| EVT-B08 | Pescador NPC | TRADE | Costa | 5 | 200s | Comercio de peces raros |

#### Tren (8 eventos base)

| ID | Nombre | Tipo | Bioma | Peso | Cooldown | Recompensa |
|----|--------|------|-------|------|----------|------------|
| EVT-T01 | Asalto en Curva | COMBAT | Bosque | 7 | 150s | Defender carga |
| EVT-T02 | Pasajero Misterioso | MYSTERY | Montaña | 4 | 300s | Pista de misterio |
| EVT-T03 | Túnel Oscuro | EMERGENCY | Montaña | 6 | 180s | Evento de horror |
| EVT-T04 | Estación Abandonada | DISCOVERY | Llanura | 3 | 400s | Exploración rápida |
| EVT-T05 | Vías Dañadas | EMERGENCY | Bosque | 5 | 240s | Reparación = recompensa |
| EVT-T06 | Comerciante Ambulante | TRADE | Llanura | 6 | 160s | Comercio variado |
| EVT-T07 | Fugitivo | DIALOGUE | Bosque | 4 | 350s | Decisión moral |
| EVT-T08 | Accidente Ferroviario | EMERGENCY | Montaña | 2 | 600s | Consecuencias narrativas |

#### Avión (8 eventos base)

| ID | Nombre | Tipo | Bioma | Peso | Cooldown | Recompensa |
|----|--------|------|-------|------|----------|------------|
| EVT-A01 | Falla de Motor | EMERGENCY | Cualquier | 5 | 200s | Reparación urgente |
| EVT-A02 | Ruinas Aéreas | DISCOVERY | Montaña | 3 | 400s | Descubrimiento de lore |
| EVT-A03 | Nube Tóxica | EMERGENCY | Bosque | 4 | 300s | Decisión de ruta |
| EVT-A04 | Aterrizaje Forzado | EMERGENCY | Desierto | 2 | 500s | Supervivencia |
| EVT-A05 | Señal de Radio | MYSTERY | Cualquier | 3 | 450s | Investigación |
| EVT-A06 | Turbulencia | EMERGENCY | Cualquier | 7 | 120s | Estrés físico |
| EVT-A07 | Carga Sospechosa | DIALOGUE | Costa | 3 | 350s | Decisión legal |
| EVT-A08 | Panorama de Lore | DISCOVERY | Cualquier | 5 | 250s | Revelación narrativa |

#### Carreta (8 eventos base)

| ID | Nombre | Tipo | Bioma | Peso | Cooldown | Recompensa |
|----|--------|------|-------|------|----------|------------|
| EVT-C01 | Bandidos | COMBAT | Bosque | 8 | 120s | Botín o pérdida |
| EVT-C02 | Caravana | TRADE | Llanura | 6 | 180s | Comercio variado |
| EVT-C03 | Mercado Ambulante | TRADE | Llanura | 5 | 240s | Objetos raros |
| EVT-C04 | Animal Enfermo | EMERGENCY | Bosque | 4 | 300s | Cuidar = lealtad |
| EVT-C05 | Fauna Salvaje | DIALOGUE | Montaña | 6 | 150s | Observación o peligro |
| EVT-C06 | Campamento Nómada | DIALOGUE | Desierto | 4 | 350s | Hospitalidad + misiones |
| EVT-C07 | Camino Bloqueado | EMERGENCY | Montaña | 5 | 200s | Buscar desvío |
| EVT-C08 | Ruinas del Camino | DISCOVERY | Bosque | 3 | 400s | Exploración |

#### A Pie (8 eventos base)

| ID | Nombre | Tipo | Bioma | Peso | Cooldown | Recompensa |
|----|--------|------|-------|------|----------|------------|
| EVT-W01 | Recurso Raro | DISCOVERY | Cualquier | 5 | 240s | Recurso valioso |
| EVT-W02 | Fauna Peligrosa | COMBAT | Bosque | 7 | 150s | Combate o huida |
| EVT-W03 | Atajo Secreto | DISCOVERY | Montaña | 3 | 500s | Desbloqueo de ruta |
| EVT-W04 | NPC Viajero | DIALOGUE | Llanura | 6 | 180s | Diálogo + comercio |
| EVT-W05 | Ruinas Olvidadas | MYSTERY | Cualquier | 4 | 400s | Pista de misterio |
| EVT-W06 | Tormenta | EMERGENCY | Costa | 6 | 160s | Buscar refugio |
| EVT-W07 | Pista de Misterio | MYSTERY | Cualquier | 3 | 450s | Avance narrativo |
| EVT-W08 | Fatiga Extrema | EMERGENCY | Desierto | 5 | 200s | Necesita descanso |

### Estructura de EventChoice

```gdscript
class_name EventChoice
extends Resource

@export var choice_id: String
@export var display_text: String
@export var required_item: String  # Item necesario (opcional)
@export var required_stat: String  # Stat necesario (opcional)
@export var success_chance: float  # 0.0 - 1.0
@export var rewards: Array[Reward]
@export var penalties: Array[Penalty]
@export var next_event_id: String  # Encadenamiento (opcional)
```

## Sistema de Misterios

### Estructura de MysteryDef

```gdscript
class_name MysteryDef
extends Resource

@export var mystery_id: String
@export var display_name: String
@export var description: String
@export var total_clues: int
@export var clues: Array[MysteryClue]
@export var final_choice: MysteryFinalChoice
@export var rewards: Array[Reward]
@export var required_transport: String  # Transporte necesario (vacío = cualquiera)
@export var difficulty: int  # 1-5
```

### MysteryClue

```gdscript
class_name MysteryClue
extends Resource

@export var clue_id: String
@export var clue_order: int
@export var narrative_text: String
@export var found_in_events: Array[String]  # IDs de eventos donde puede aparecer
@export var hint_text: String  # Pista para encontrarla
```

### MysteryFinalChoice

```gdscript
class_name MysteryFinalChoice
extends Resource

@export var description: String
@export var options: Array[MysteryOption]
```

```gdscript
class_name MysteryOption
extends Resource

@export var option_id: String
@export var display_text: String
@export var required_clues: Array[String]
@export var outcome: MysteryOutcome
```

### MysteryOutcome

```gdscript
class_name MysteryOutcome
extends Resource

@export var outcome_type: String  # REWARD/UNLOCK/NPC_ALLIANCE/NARRATIVE
@export var description: String
@export var rewards: Array[Reward]
@export var unlocked_content: String  # ID de contenido desbloqueado
```

## Integración con Otros Módulos

### M69 (Inventario)
- **Interfaz:** `InventoryManager.add_item(item_id, quantity)` / `remove_item(item_id, quantity)` / `has_item(item_id)`
- **Uso:** Consumo de recursos durante viaje, obtención de items en eventos.
- **Contrato:** El sistema de viaje NUNCA modifica inventario directamente; usa APIs de M69.

### M22 (NPCs)
- **Interfaz:** `NPCManager.spawn_npc(npc_id, position)` / `NPCManager.get_dialogue(npc_id)`
- **Uso:** Spawning de NPCs en eventos de diálogo, obtención de diálogos.
- **Contrato:** Los NPCs de viaje son instancias temporales, no persisten fuera del viaje.

### M24 (Misiones)
- **Interfaz:** `MissionManager.complete_objective(mission_id, objective_id)` / `MissionManager.check_condition(condition)`
- **Uso:** Eventos de viaje pueden completar objetivos de misiones activas.
- **Contrato:** El sistema de viaje consulta M24 para verificar si un evento afecta misiones.

### M19 (Combate)
- **Interfaz:** `CombatManager.start_combat(enemies, player_party)` / `CombatManager.get_result()`
- **Uso:** Eventos de combate delegan al sistema de combate existente.
- **Contrato:** El combate en viaje usa las mismas reglas que combate terrestre.

### M29 (Economía)
- **Interfaz:** `EconomyManager.get_player_coins()` / `EconomyManager.spend_coins(amount)` / `EconomyManager.earn_coins(amount)`
- **Uso:** Costos de viaje, comercio durante viaje, recompensas económicas.
- **Contrato:** Todos los intercambios monetarios pasan por M29.

## Diagrama de Flujo del Viaje

```
[Jugador selecciona destino y transporte]
         │
         ▼
[TransportManager.start_journey()]
         │
         ├─ Verificar costos (M29)
         ├─ Verificar disponibilidad de transporte
         ├─ Crear JourneyInstance
         ├─ Instanciar escena del transporte
         └─ Iniciar proceso de viaje
         │
         ▼
[JourneyInstance._process(delta)]
         │
         ├─ Avanzar progreso según velocidad
         ├─ Verificar bioma actual
         ├─ Calcular probabilidad de evento
         │     │
         │     ▼
         │   [¿Evento posible?]
         │     │ SÍ → Seleccionar evento de pool
         │     │       │
         │     │       ▼
         │     │     [¿Es misterio?]
         │     │       │ SÍ → Agregar pista al misterio activo
         │     │       │ NO → Ejecutar evento normal
         │     │       │
         │     │       ▼
         │     │     [Mostrar interfaz de evento]
         │     │       │
         │     │       ▼
         │     │     [Jugador elige opción]
         │     │       │
         │     │       ▼
         │     │     [Aplicar consecuencias]
         │     │       │
         │     │       ▼
         │     │     [¿Misterio completo?]
         │     │       │ SÍ → Ejecutar resolución
         │     │       │ NO → Continuar viaje
         │     │
         │     ▼ NO
         │   [Continuar viaje]
         │
         ├─ Verificar tiempo restante
         │     │
         │     ▼
         │   [¿Viaje completado?]
         │     │ SÍ → Finalizar viaje
         │     │ NO → Continuar loop
         │
         ▼
[Finalizar viaje]
         │
         ├─ Transportar jugador al destino
         ├─ Entregar recompensas pendientes
         ├─ Guardar estado del viaje
         ├─ Destruir JourneyInstance
         └─ Notificar a sistemas dependientes (M24, M29)
```

## Estructura de Archivos (Propuesta)

```
Assets/_Project/Scripts/Transport/
├── TransportManager.gd          # Singleton principal
├── JourneyInstance.gd            # Instancia de viaje (Node3D)
├── JourneyEvent.gd               # Resource de evento
├── EventChoice.gd                # Resource de opción de evento
├── MysteryDef.gd                 # Resource de misterio
├── MysteryClue.gd                # Resource de pista
├── MysteryInstance.gd            # Instancia activa de misterio
├── TransportDef.gd               # Resource de definición de transporte
├── TransportTypes/
│   ├── ShipTransport.gd          # Lógica específica del barco
│   ├── TrainTransport.gd         # Lógica específica del tren
│   ├── PlaneTransport.gd         # Lógica específica del avión
│   ├── CartTransport.gd          # Lógica específica de la carreta
│   └── WalkingTransport.gd       # Lógica específica de a pie
├── Events/
│   ├── CombatEvent.gd            # Evento de combate
│   ├── DialogueEvent.gd          # Evento de diálogo
│   ├── DiscoveryEvent.gd         # Evento de descubrimiento
│   ├── EmergencyEvent.gd         # Evento de emergencia
│   ├── MysteryEvent.gd           # Evento de misterio
│   ├── TradeEvent.gd             # Evento de comercio
│   └── RestEvent.gd              # Evento de descanso
├── UI/
│   ├── JourneyHUD.gd             # HUD principal del viaje
│   ├── EventPanel.gd             # Panel de eventos
│   ├── MysteryPanel.gd           # Panel de misterios
│   └── ProgressBar.gd            # Barra de progreso del viaje
└── Data/
    ├── transport_definitions/     # Resources de TransportDef
    ├── journey_events/            # Resources de JourneyEvent
    └── mysteries/                 # Resources de MysteryDef
```
