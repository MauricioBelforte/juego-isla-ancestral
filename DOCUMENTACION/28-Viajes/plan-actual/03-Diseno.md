**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 28: Viajes

## 1. Arquitectura General

Separación por responsabilidades (sección 9 AGENTS.md): la lógica de viaje vive en nodos y autoloads desacoplados de la capa UI.

```
Autoload
â””â”€â”€ TravelService        (singleton global: orquesta viajes, rutas, reservas)

Escena del Gran Vapor
├── Boat                 (Node3D: estados, animación, cubierta navegable)
â”‚   â”œâ”€â”€ BoatVisual       (malla voxel del vapor + chimenea/humo)
│   ├── BoatDeck         (área caminable del jugador)
│   └── WakeFX           (partículas de estela, M51)

Rutas (Resources)
â””â”€â”€ BoatRoute            (curva + metadatos de un trayecto origen â†’ destino)

Puertos (una instancia por isla, M27)
â”œâ”€â”€ Harbor               (Node3D: muelles, docks, zona de embarque)
│   ├── HarborDock       (punto de atraque con lock/liberación)
│   └── EmbarkTrigger    (Area3D de interacción: "Hablar con el conserje")
```

## 2. Diagrama de Componentes

```
M27 Islas â”€â”€ define â”€â”€â–º Harbor (puerto de cada isla)
M29 Reloj â”€â”€ entrega horario â”€â”€â–º TravelService (ventana de salida)
M32 Clima â”€â”€ entrega estado â”€â”€â–º TravelService (retraso, sin bloqueo)
M38 Economía ── cobra ──► TravelService (boleto y viaje rápido)
M63 Streaming â”€â”€ precarga â”€â”€â–º TravelService (isla destino)
TravelService â”€â”€ controla â”€â”€â–º Boat (sigue BoatRoute)
TravelService â”€â”€ notifica â”€â”€â–º TravelUI (pantallas y avisos)
TravelService â”€â”€ guarda/restaura â”€â”€â–º M58 Guardado
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
## Specs Viajes (Beam 502)

### Diseño del barco (Gran Vapor)
- Spec: Gran Vapor con cubierta navegable y chimenea. Coherente con M28 (viajes) y M08 (terreno).

### Flujo completo embarque-travesía-llegada
- Spec: flujo completo: embarque, travesía y llegada de punta a punta. Coherente con M28 (viajes) y M27 (islas).

### Llegada con muelle ocupado (espera animada)
- Spec: flujo de llegada con muelle ocupado: espera animada de hasta 10 s. Coherente con M28 (viajes) y M63 (streaming).

### Precarga de la isla destino al confirmar boleto (M63)
- Spec: M63: precarga de la isla destino al confirmar el boleto. Coherente con M63 (streaming) y M28 (viajes).

### Llegada con muelle ocupado: espera visible, nunca soft-lock
- Spec: llegada con muelle ocupado: espera visible, nunca soft-lock. Coherente con M28 (viajes) y M63 (streaming).

### Fallo de streaming del destino (M63): espera en cubierta
- Spec: fallo de streaming del destino (M63): espera en cubierta con mensaje. Coherente con M63 (streaming) y M28 (viajes).

### Precarga de la escena destino durante la travesía (M63)
- Spec: precarga de la escena destino durante la travesía (M63). Coherente con M63 (streaming) y M28 (viajes).

### Budget de frame <= 16 ms durante la travesía
- Spec: budget de frame <= 16 ms durante la travesía. Coherente con M61 (rendimiento) y M28 (viajes).

## Specs Viajes (Beam 609)

### Definir el problema: desplazamiento cozy entre islas con el Gran Vapor
- Spec: definir el problema: desplazamiento cozy entre islas con el Gran Vapor. Coherente with M28 (viajes) and M27 (islas).

### Catalogar los 25 puntos de la seccion 27 del plan maestro
- Spec: catalogar los 25 puntos de la seccion 27 del plan maestro. Coherente with M28 (viajes) and M27 (islas).

### RF1: boleto y reserva con capacidad del vapor
- Spec: RF1: boleto y reserva con capacidad del vapor. Coherente with M28 (viajes) and M38 (comercio).

### RF3: travesia visible entre 20 y 60 segundos
- Spec: RF3: travesia visible entre 20 y 60 segundos. Coherente with M28 (viajes) and M61 (rendimiento).

### RF4: llegada con atraque automatico y desembarque suave
- Spec: RF4: llegada con atraque automatico y desembarque suave. Coherente with M28 (viajes) and M27 (islas).


## Specs Viajes (Beam 610)

### RF5: viaje rapido costoso via M69
- Spec: RF5: viaje rapido costoso via M69. Coherente with M28 (viajes) and M69 (viaje rapido).

### NFR: cozy, sin soft-locks, accesibilidad, guardado M58
- Spec: NFR: cozy, sin soft-locks, accesibilidad, guardado M58. Coherente with M28 (viajes) and M58 (guardado).

### P3: diseño del dirigible — vehículo opcional de contenido tardío, no bloqueante
- Spec: P3: diseño del dirigible — vehículo opcional de contenido tardío, no bloqueante. Coherente with M28 (viajes) and M67 (vehiculos).

### P4: diseño del submarino — vehículo opcional de expediciones, no bloqueante
- Spec: P4: diseño del submarino — vehículo opcional de expediciones, no bloqueante. Coherente with M28 (viajes) and M67 (vehiculos).

### P5: diseño del boleto — objeto comprado en M38, consumible por viaje
- Spec: P5: diseño del boleto — objeto comprado en M38, consumible por viaje. Coherente with M28 (viajes) and M38 (comercio).


## Specs Viajes (Beam 611)

### P10: diseño de la transición — fade de 0.5 s al desembarcar y al viaje rápido
- Spec: P10: diseño de la transición — fade de 0.5 s al desembarcar y al viaje rápido. Coherente with M28 (viajes) and M63 (streaming).

### P11: diseño de la llegada — atraque, pasarela y aparición en el muelle
- Spec: P11: diseño de la llegada — atraque, pasarela y aparición en el muelle. Coherente with M28 (viajes) and M27 (islas).

### P12: diseño de efectos de clima — olas, balanceo, lluvia y niebla en travesía
- Spec: P12: diseño de efectos de clima — olas, balanceo, lluvia y niebla en travesía. Coherente with M28 (viajes) and M31 (clima).

### P13: diseño del calendario — ventanas de salida del vapor según M29
- Spec: P13: diseño del calendario — ventanas de salida del vapor según M29. Coherente with M28 (viajes) and M29 (tiempo).

### P16: diseño de viajes nocturnos — ambientación con faroles y cielo estrellado
- Spec: P16: diseño de viajes nocturnos — ambientación con faroles y cielo estrellado. Coherente with M28 (viajes) and M31 (ciclo).


## Specs Viajes (Beam 612)

### P17: diseño de viajes estacionales — decorados y música por estación
- Spec: P17: diseño de viajes estacionales — decorados y música por estación. Coherente with M28 (viajes) and M29 (tiempo).

### P18: diseño de eventos en el trayecto — umbrales de progreso con NPC y diálogos
- Spec: P18: diseño de eventos en el trayecto — umbrales de progreso con NPC y diálogos. Coherente with M28 (viajes) and M20 (diálogos).

### P19: diseño de objetos coleccionables del viaje — ítems visibles junto a la ruta
- Spec: P19: diseño de objetos coleccionables del viaje — ítems visibles junto a la ruta. Coherente with M28 (viajes) and M73 (colección).

### P20: diseño de NPC viajeros — pasajeros con rutinas breves a cubierta
- Spec: P20: diseño de NPC viajeros — pasajeros con rutinas breves a cubierta. Coherente with M28 (viajes) and M18 (NPC).

### P21: diseño de transporte de recursos — almacén del vapor con capacidad limitada
- Spec: P21: diseño de transporte de recursos — almacén del vapor con capacidad limitada. Coherente with M28 (viajes) and M14 (recursos).


## Specs Viajes (Beam 613)

### P22: diseño de almacenamiento — inventario del barco separado del jugador
- Spec: P22: diseño de almacenamiento — inventario del barco separado del jugador. Coherente with M28 (viajes) and M14 (recursos).

### P23: definición de restricciones — un viaje activo, destinos desbloqueados, horarios
- Spec: P23: definición de restricciones — un viaje activo, destinos desbloqueados, horarios. Coherente with M28 (viajes) and M29 (tiempo).

### P24: definición de costes — boleto, viaje rápido y devoluciones en M38
- Spec: P24: definición de costes — boleto, viaje rápido y devoluciones en M38. Coherente with M28 (viajes) and M38 (comercio).

### P25: definición de desbloqueos — rutas progresivas ligadas a M22 y M70
- Spec: P25: definición de desbloqueos — rutas progresivas ligadas a M22 y M70. Coherente with M28 (viajes) and M70 (progresión).

### Balanceo y cabeceo suaves según weather_factor
- Spec: balanceo y cabeceo suaves según weather_factor. Coherente with M28 (viajes) and M31 (clima).


## Specs Viajes (Beam 614)

### Estela de particulas (WakeFX) activa solo en SAILING
- Spec: estela de particulas (WakeFX) activa solo en SAILING. Coherente with M28 (viajes) and M52 (particulas).

### Humo de chimenea con puffs periodicos (M51)
- Spec: humo de chimenea con puffs periodicos (M51). Coherente with M28 (viajes) and M51 (agua).

### Silbato del vapor al zarpar y al atracar (M42)
- Spec: silbato del vapor al zarpar y al atracar (M42). Coherente with M28 (viajes) and M42 (sonido).

### Teleport a punto de curva para restaurar guardado (M58)
- Spec: teleport a punto de curva para restaurar guardado (M58). Coherente with M28 (viajes) and M58 (guardado).

### Curva Curve3D baked para trayectoria estable por el mar
- Spec: curva Curve3D baked para trayectoria estable por el mar. Coherente with M28 (viajes) and M08 (terreno).


## Specs Viajes (Beam 615)

### sample_position(t) con interpolacion sobre longitud baked
- Spec: sample_position(t) con interpolacion sobre longitud baked. Coherente with M28 (viajes) and M08 (terreno).

### compute_duration_with_weather con tope maximo de 90 segundos
- Spec: compute_duration_with_weather con tope maximo de 90 segundos. Coherente with M28 (viajes) and M31 (clima).

### Reserva temprana del dock de destino al zarpar
- Spec: reserva temprana del dock de destino al zarpar. Coherente with M28 (viajes) and M27 (islas).

### Fallback de restore: ruta desconocida devuelve al muelle de origen
- Spec: fallback de restore: ruta desconocida devuelve al muelle de origen. Coherente with M28 (viajes) and M59 (guardado).

### Boton de cancelar visible hasta zarpar
- Spec: boton de cancelar visible hasta zarpar. Coherente with M28 (viajes) and M53 (UI).


## Specs Viajes (Beam 616)

### Confirmacion explicita del coste del viaje rapido (M69)
- Spec: confirmacion explicita del coste del viaje rapido (M69). Coherente with M28 (viajes) and M69 (viaje rapido).

### Flujo de llegada con muelle libre y atraque directo
- Spec: flujo de llegada con muelle libre y atraque directo. Coherente with M28 (viajes) and M27 (islas).

### Flujo de cancelacion antes del embarque con devolucion del 100%
- Spec: flujo de cancelacion antes del embarque con devolucion del 100%. Coherente with M28 (viajes) and M38 (comercio).

### Flujo de cancelacion en cubierta con devolucion del 50%
- Spec: flujo de cancelacion en cubierta con devolucion del 50%. Coherente with M28 (viajes) and M38 (comercio).

### Flujo de clima adverso: retraso visible, zarpe garantizado
- Spec: flujo de clima adverso: retraso visible, zarpe garantizado. Coherente with M28 (viajes) and M31 (clima).


## Specs Viajes (Beam 617)

### Flujo nocturno con ambientacion y faroles activos
- Spec: flujo nocturno con ambientacion y faroles activos. Coherente with M28 (viajes) and M31 (ciclo).

### Flujo de expedicion secreta con ruta is_secret
- Spec: flujo de expedicion secreta con ruta is_secret. Coherente with M28 (viajes) and M27 (islas).

### M32: consulta del estado del clima para calcular retraso sin bloqueo
- Spec: M32: consulta del estado del clima para calcular retraso sin bloqueo. Coherente with M28 (viajes) and M32 (clima).

### M69: viaje rapido con puntos desbloqueados, coste alto y visita previa
- Spec: M69: viaje rapido con puntos desbloqueados, coste alto y visita previa. Coherente with M28 (viajes) and M69 (viaje rapido).

### M63: liberacion de la isla origen al zarpar
- Spec: M63: liberacion de la isla origen al zarpar. Coherente with M28 (viajes) and M63 (streaming).


## Specs Viajes (Beam 618)

### M29: ventanas de salida y lineas nocturnas segun el reloj
- Spec: M29: ventanas de salida y lineas nocturnas segun el reloj. Coherente with M28 (viajes) and M29 (tiempo).

### M38: pago de boleto, viaje rapido y devoluciones
- Spec: M38: pago de boleto, viaje rapido y devoluciones. Coherente with M28 (viajes) and M38 (comercio).

### M58: guardado y restauracion a mitad de travesia
- Spec: M58: guardado y restauracion a mitad de travesia. Coherente with M28 (viajes) and M58 (guardado).

### M50: estela y boyantez sobre agua decorativa sin colisiones
- Spec: M50: estela y boyantez sobre agua decorativa sin colisiones. Coherente with M28 (viajes) and M50 (agua).

### Cancelacion con boleto consumido: devolucion calculada correcta
- Spec: cancelacion con boleto consumido: devolucion calculada correcta. Coherente with M28 (viajes) and M38 (comercio).


## Specs Viajes (Beam 619)

### Clima extremo: retraso maximo aplicado y zarpe garantizado
- Spec: clima extremo: retraso maximo aplicado y zarpe garantizado. Coherente with M28 (viajes) and M31 (clima).

### Doble pulsacion de abordar: exclusividad de estado lo descarta
- Spec: doble pulsacion de abordar: exclusividad de estado lo descarta. Coherente with M28 (viajes) and M53 (UI).

### Reserva duplicada del mismo destino: segundo intento rechazado
- Spec: reserva duplicada del mismo destino: segundo intento rechazado. Coherente with M28 (viajes) and M38 (comercio).

### Insuficiencia de monedas: aviso sin cobro parcial
- Spec: insuficiencia de monedas: aviso sin cobro parcial. Coherente with M28 (viajes) and M38 (comercio).

### Guardado durante SAILING: restaura en el punto medio de la curva
- Spec: guardado durante SAILING: restaura en el punto medio de la curva. Coherente with M28 (viajes) and M58 (guardado).


## Specs Viajes (Beam 620)

### Jugador fuera del barco al zarpar: reubicacion automatica a cubierta
- Spec: jugador fuera del barco al zarpar: reubicacion automatica a cubierta. Coherente with M28 (viajes) and M10 (personaje).

### Travesia con tope de 90 s para limitar tiempo de streaming
- Spec: travesia con tope de 90 s para limitar tiempo de streaming. Coherente with M28 (viajes) and M61 (rendimiento).

### Pool de particulas de estela y humo sin instancias dinamicas
- Spec: pool de particulas de estela y humo sin instancias dinamicas. Coherente with M28 (viajes) and M52 (particulas).

### Culling de la isla origen al alejarse de su puerto
- Spec: culling de la isla origen al alejarse de su puerto. Coherente with M28 (viajes) and M61 (rendimiento).

### Cache de nodos en _ready, sin get_node en bucles
- Spec: cache de nodos en _ready, sin get_node en bucles. Coherente with M28 (viajes) and M61 (rendimiento).


## Specs Viajes (Beam 621)

### Sin alocaciones en el bucle de progreso de la ruta
- Spec: sin alocaciones en el bucle de progreso de la ruta. Coherente with M28 (viajes) and M61 (rendimiento).

### Opcion de accesibilidad: travesia acelerada a la mitad del tiempo
- Spec: opcion de accesibilidad: travesia acelerada a la mitad del tiempo. Coherente with M28 (viajes) and M58 (accesibilidad).

### Silbato del vapor al zarpar y atracar (M42)
- Spec: silbato del vapor al zarpar y atracar (M42). Coherente with M28 (viajes) and M42 (sonido).

### Gaviotas y ambiente de puerto en el muelle
- Spec: gaviotas y ambiente de puerto en el muelle. Coherente with M28 (viajes) and M41 (sonido ambiental).

### Lluvia y nieve en cubierta con particulas (M51)
- Spec: lluvia y nieve en cubierta con particulas (M51). Coherente with M28 (viajes) and M51 (particulas).

### Faroles y luces calidas en linea nocturna
- Spec: faroles y luces calidas en linea nocturna. Coherente with M28 (viajes) and M48 (iluminacion).

### Confirmacion visual de llegada con banner del nombre de la isla
- Spec: confirmacion visual de llegada con banner del nombre de la isla. Coherente with M28 (viajes) and M53 (UI).

### Dialogo amable del capitan al retrasar por clima
- Spec: dialogo amable del capitan al retrasar por clima. Coherente with M28 (viajes) and M20 (dialogos).
