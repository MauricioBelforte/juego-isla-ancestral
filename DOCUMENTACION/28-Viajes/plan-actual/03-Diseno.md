**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 28: Viajes

## 1. Arquitectura General

Separación por responsabilidades (sección 9 AGENTS.md): la lógica de viaje vive en nodos y autoloads desacoplados de la capa UI.

```
Autoload
└── TravelService        (singleton global: orquesta viajes, rutas, reservas)

Escena del Gran Vapor
├── Boat                 (Node3D: estados, animación, cubierta navegable)
│   ├── BoatVisual       (malla voxel del vapor + chimenea/humo)
│   ├── BoatDeck         (área caminable del jugador)
│   └── WakeFX           (partículas de estela, M51)

Rutas (Resources)
└── BoatRoute            (curva + metadatos de un trayecto origen → destino)

Puertos (una instancia por isla, M27)
├── Harbor               (Node3D: muelles, docks, zona de embarque)
│   ├── HarborDock       (punto de atraque con lock/liberación)
│   └── EmbarkTrigger    (Area3D de interacción: "Hablar con el conserje")
```

## 2. Diagrama de Componentes

```
M27 Islas ── define ──► Harbor (puerto de cada isla)
M29 Reloj ── entrega horario ──► TravelService (ventana de salida)
M32 Clima ── entrega estado ──► TravelService (retraso, sin bloqueo)
M38 Economía ── cobra ──► TravelService (boleto y viaje rápido)
M63 Streaming ── precarga ──► TravelService (isla destino)
TravelService ── controla ──► Boat (sigue BoatRoute)
TravelService ── notifica ──► TravelUI (pantallas y avisos)
TravelService ── guarda/restaura ──► M58 Guardado
```

## 3. Flujos en Texto

### 3.1 Flujo de embarque
1. Jugador entra al `EmbarkTrigger` del `Harbor` y pulsa interactuar.
2. `TravelUI` abre la pantalla de reserva: lista de destinos (M27) con coste (M38) y horarios (M29).
3. El jugador confirma el destino. `TravelService.request_travel(destino)`.
4. Validaciones: destino desbloqueado, boleto pagado, horario vigente, muelle libre.
5. Si el clima M32 es adverso → aviso amable + retraso programado de 5–15 s. El jugador puede esperar o cancelar.
6. Embarque: cámara a cinematográfica, el jugador camina solo hasta su asiento/cubierta.
7. `TravelService` reserva el dock de salida y el dock de llegada (`HarborDock.lock()`), y dispara la precarga de la isla destino (M63).

### 3.2 Flujo de travesía
1. El `Boat` entra en estado `SAILING` y avanza por la curva de `BoatRoute` (20–60 s según distancia).
2. El jugador camina libre por la cubierta (`BoatDeck`).
3. Durante el trayecto pueden dispararse eventos suaves (NPC viajeros, coleccionables, diálogos breves).
4. Si el clima es adverso: olas más altas, balanceo mayor, barra de progreso más lenta (retraso del 25 %).
5. `TravelUI` muestra barra de progreso "Llegando a [isla]..." (sección 8 AGENTS.md).

### 3.3 Flujo de llegada
1. El `Boat` reduce velocidad y se aproxima al muelle (estado `ARRIVING`).
2. Si el dock de destino está libre → atraque directo. Si está ocupado → espera en el agua (giro visible) hasta 10 s, o muelle secundario; nunca soft-lock.
3. Atraque: `HarborDock.lock()` → animación de amarre, pasarela.
4. El jugador desembarca con transición suave (fade 0.5 s) y aparece en el muelle de destino.
5. `TravelService` libera los docks, cierra el estado de viaje y guarda (M58).

### 3.4 Flujo de cancelación
1. Antes de zarpar, el jugador pulsa "Cancelar viaje".
2. Si aún no embarcó → devolución 100 % (M38). Si ya embarcó y el barco sigue en puerto → devolución 50 %.
3. El jugador vuelve al muelle; el estado de viaje vuelve a `IDLE`.

### 3.5 Flujo de viaje rápido (M69)
1. El jugador abre la pantalla de viaje rápido (mapa M53 + puntos desbloqueados).
2. Requisitos: destino ya visitado + coste alto en monedas.
3. Confirmación con coste explícito → fade directo (2–3 s) → llegada al muelle del destino.
4. No disponible con clima extremo: se muestra aviso descriptivo (no bloquea la opción de viajar en vapor).

### 3.6 Flujo nocturno y estacional (M29)
1. En horario nocturno el vapor ofrece línea nocturna (misma ruta, ambientación oscura con faroles).
2. En festivales (M73) y estaciones hay viajes estacionales: misma mecánica, destino o decorado especial.
3. Expediciones secretas requieren desbloqueo (M22/M70) y usan el mismo `TravelService` con ruta reservada.

## 4. Contratos API GDScript

```gdscript
# travel_service.gd — Autoload "TravelService"
class_name TravelService
extends Node

signal travel_started(route: BoatRoute)
signal travel_progress(progress: float)          # 0.0 a 1.0
signal travel_arrived(island_id: String)
signal travel_cancelled(refund: int)
signal travel_delayed(delay_seconds: float, reason: String)

enum TravelState { IDLE, BOARDING, WAITING_DEPARTURE, SAILING, ARRIVING }

func request_travel(destination_island_id: String) -> Dictionary
func cancel_travel() -> Dictionary                 # {refund: int}
func get_available_destinations() -> Array[BoatRoute]
func is_traveling() -> bool
func get_current_state() -> TravelState
func get_travel_progress() -> float
func apply_weather_delay(weather: Dictionary) -> void   # M32: retrasa, no bloquea
func serialize() -> Dictionary                     # para M58
func restore(state: Dictionary) -> void            # para M58
```

```gdscript
# boat.gd — Escena del Gran Vapor
class_name Boat
extends Node3D

enum BoatState { DOCKED, BOARDING, SAILING, ARRIVING }

func set_route(route: BoatRoute) -> void
func start_sailing() -> void
func stop_at_dock(dock: HarborDock) -> void
func set_weather_factor(factor: float) -> void     # 0.0=calma, 1.0=tormenta
func get_deck_position() -> Vector3
```

```gdscript
# boat_route.gd — Resource
class_name BoatRoute
extends Resource

@export var route_id: StringName
@export var origin_island_id: String
@export var destination_island_id: String
@export var base_duration_seconds: float = 30.0
@export var curve: Curve3D                        # trayectoria por el mar
@export var cost_coins: int = 0
@export var required_quest: StringName = &""      # desbloqueo por M22
@export var is_secret: bool = false
@export var is_night_line: bool = false

func sample_position(t: float) -> Vector3
func compute_duration_with_weather(weather_factor: float) -> float
```

```gdscript
# harbor.gd — Puerto de cada isla
class_name Harbor
extends Node3D

@export var island_id: String
@export var docks: Array[HarborDock]

func find_free_dock() -> HarborDock
func is_dock_available() -> bool
func lock_dock(dock: HarborDock) -> bool
func release_dock(dock: HarborDock) -> void
func get_embark_area() -> Area3D
```

```gdscript
# harbor_dock.gd — Punto de atraque
class_name HarborDock
extends Marker3D

var docked_boat: Boat = null

func lock(boat: Boat) -> bool
func release() -> void
```

```gdscript
# travel_ui.gd — Capa UI (CanvasLayer). Sin lógica de gameplay.
class_name TravelUI
extends CanvasLayer

signal confirm_reservation(route_id: StringName)
signal confirm_cancel()
signal confirm_fast_travel(destination_id: String)

func show_reservation_screen(routes: Array[BoatRoute]) -> void
func show_travel_progress(progress: float, label: String) -> void
func show_weather_delay_notice(seconds: float, reason: String) -> void
func show_refund_notice(coins: int) -> void
func set_interactive(enabled: bool) -> void         # sección 8 AGENTS.md
```

## 5. Integración con Otros Módulos

| Módulo | Integración |
|---|---|
| M27 Islas | Cada isla define su `Harbor`; `island_id` une `BoatRoute` e `Harbor` |
| M32 Clima | `apply_weather_delay()` consulta el estado del clima; retraso calculado, jamás cancelación |
| M69 Fast Travel | Reutiliza destinos y puertos; fade directo; coste alto; requisito de visita previa |
| M63 Streaming | Precarga de la escena de la isla destino al confirmar boleto; liberación de la isla origen al zarpar |
| M29 Tiempo/Reloj | Ventanas de salida del vapor, líneas nocturnas y estacionales |
| M38 Economía | Coste de boletos, viajes rápidos y devoluciones |
| M58 Guardado | `serialize()` / `restore()` del estado de travesía (incluso a mitad de ruta) |
| M50 Agua | Estela y boyantes del barco; el mar es decorativo (el vapor no colisiona con el océano voxel) |
| M40/41/42 Audio | Silbato del vapor, olas, ambiente de cubierta |
| M51 VFX | Estela, humo de chimenea, lluvia/nieve sobre cubierta |
| M52/M56 UI/UX | Pantallas de reserva, progreso y confirmaciones reutilizando el tema visual |
| M73 Eventos | Viajes estacionales y de festival reutilizan `TravelService` |
| M22 Historia | Rutas secretas y expediciones condicionadas a la progresión narrativa |

## 6. Manejo de Estados y Exclusividad

- `TravelService` garantiza **un solo viaje activo**: `request_travel()` falla si `is_traveling()`.
- Los docks se reservan al zarpar y se liberan al atracar; la cola de espera evita soft-locks (sección 02-Análisis D4).
- La travesía es serializable: si se guarda en `SAILING`, al restaurar el barco reaparece en `sample_position(t)` con el tiempo restante intacto.