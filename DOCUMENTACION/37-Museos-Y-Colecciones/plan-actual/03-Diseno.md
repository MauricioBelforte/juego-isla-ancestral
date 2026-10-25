**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md â€” MÃ³dulo 37: Museos y Colecciones

## 1. Arquitectura General

```
                    +---------------------------+
                    |    CollectionRegistry     |
                    |   (autoload, autoridad de  |
                    |   progreso y persistencia) |
                    +-------------+--------------+
                                  ^
        registra / consulta       | senales de progreso
                                  |
+------------------+      +-------+-------+      +------------------+
|  DonationService |<---->|    Museum     |<---->|  ExhibitSlot     |
| (validacion y    |      | (escena,      |      | (vitrina por     |
|  consumo)        |      |  salas,       |      |  pieza)          |
+--------+---------+      |  curador NPC) |      +-------^----------+
         |                +-------+-------+              |
         |                        |                      |
         v                        v                      v
+------------------------------------------+   +------------------+
|  M36 Fauna / M34 Pesca / M25 Ruinas      |   |  UI Museo        |
|  (inventario y datos de piezas)          |   |  (panel, barras, |
+------------------------------------------+   |   tooltips)      |
                                               +------------------+
```
A la derecha del flujo, el evento de cada donacion llega a M55 Diario por senal (sin acoplamiento).

## 2. Componentes

### 2.1 CollectionRegistry (autoload "CollectionRegistry")
- Unica autoridad de progreso: que piezas estan registradas en cada exposicion.
- Persiste el estado (piezas registradas + recompensas otorgadas) con la partida.
- Emite senales de progreso y de exposicion completada.

### 2.2 Museum (escena `museum.tscn`, componente `Museum.gd`)
- Nodo raiz del edificio: controla salas, puertas, cartel de progreso y curador NPC.
- Instancia y posiciona ExhibitSlots segun la configuracion de cada ExhibitionData.
- Reconstruye el estado visual al cargar partida consultando al Registry.

### 2.3 ExhibitSlot (escena `exhibit_slot.tscn`, componente `ExhibitSlot.gd`)
- Hueco fisico de exhibicion con estado libre/ocupado.
- Variantes visuales por familia: diorama (fauna), acuario (peces), pedestal (fosiles), marco (arte).
- Interactuable: al inspeccionar abre la descripcion de la pieza.

### 2.4 DonationService (autoload "DonationService")
- Valida la donacion (propiedad, duplicado, sala correcta) y consume el item del inventario.
- Devuelve un resultado estructurado y emite senales de aceptacion/rechazo.
- Entrega recompensas de exposicion (idempotente).

## 3. Datos (Resources)

- `ExhibitionData` (Resource): id, nombre de sala, lista de `ExhibitData`, id de recompensa, descripcion de la exposicion.
- `ExhibitData` (Resource): id, nombre, descripcion, procedencia, escena/modelo voxel, icono, categoria.
- Archivos `.tres` por exposicion en `res://data/museum/` (fauna, peces, fosiles, arte) generados desde los catalogos de M36/M34/M25 y el arte definido para M37.

## 4. Flujos (Texto)

### 4.1 Flujo de donacion feliz
1. El jugador habla con el curador en el mostrador.
2. La UI del museo lista los items donables del inventario filtrados por exposicion.
3. El jugador selecciona un item y confirma.
4. DonationService valida: item existe, es del jugador, no esta registrado, pertenece a la exposicion correcta.
5. Si OK: el item se consume del inventario.
6. CollectionRegistry.register_item actualiza el registro y el progreso.
7. Museum rellena el ExhibitSlot correspondiente (animacion de colocacion + audio).
8. Se emiten senales (UI, audio, M55 Diario) y el curador agradece con un mensaje cozy.
9. Si la exposicion quedo completa, se dispara el Flujo 4.2.

### 4.2 Flujo de exposicion completada y recompensa
1. Registry detecta que la ultima pieza fue registrada.
2. Emite `exhibition_completed(exhibition_id)` (una sola vez; guarda la marca).
3. Museum muestra notificacion especial y abre la vitrina del premio.
4. DonationService entrega la recompensa unica al inventario si no fue otorgada antes.
5. M55 Diario registra "Exposicion completada" y "Recompensa recibida".

### 4.3 Flujo de rechazo (duplicado o invalido)
1. El jugador intenta donar un item ya registrado / de otra exposicion / inexistente.
2. DonationService devuelve `DonationResult` con motivo de rechazo.
3. La UI muestra el motivo (ej. "Ya donaste esta pieza") y el inventario NO se consume.
4. No se emite evento de diario; solo feedback local.

### 4.4 Flujo de vitrina ocupada
1. Un ExhibitSlot puede estar ocupado (pieza registrada) o libre.
2. La colocacion de una pieza solo opera sobre el slot libre esperado de esa pieza.
3. Si el slot ya esta ocupado por la misma pieza, la operacion es no-op (idempotente).
4. Nunca se sobrescribe una pieza diferente: la clave (exposicion, indice) garantiza unicidad.

### 4.5 Flujo de carga de partida
1. El juego carga el estado guardado.
2. CollectionRegistry.restore_from_save reconstruye piezas registradas y recompensas otorgadas.
3. Museum recorre cada ExhibitionData y completa los ExhibitSlots con las piezas registradas.
4. Los slots sin pieza quedan libres (silueta + etiqueta "Por donar").
5. UI de progreso se refresca desde el Registry (fuente unica).

### 4.6 Flujo de registro en M55 Diario
1. Cada accion relevante emite senales tipadas (donacion, exposicion completada, recompensa).
2. El consumidor de M55 escucha esas senales y escribe la entrada con fecha del reloj M29/M31.
3. M37 no conoce la UI del diario: solo emite eventos con payload minimo.

## 5. Contratos API (GDScript)

### ExhibitionData (Resource)
```gdscript
class_name ExhibitionData extends Resource
@export var id: String
@export var display_name: String
@export var room_scene: PackedScene
@export var items: Array[ExhibitData]
@export var reward_item_id: String
@export var reward_display_name: String
```

### ExhibitData (Resource)
```gdscript
class_name ExhibitData extends Resource
@export var id: String                      # "fauna_03"
@export var display_name: String
@export var description: String
@export var origin: String                  # procedencia (M36/M34/M25/arte)
@export var slot_scene: PackedScene         # variante visual (diorama/acuario/...)
@export var model_scene: PackedScene        # pieza en si (voxel)
@export var icon: Texture2D
```

### Museum.gd (Node3D, scene "museum")
```gdscript
class_name Museum extends Node3D

signal exhibition_completed(exhibition_id: String)
signal museum_total_progress_changed(percent: float)
signal donation_feedback(accepted: bool, reason: String)

func get_room(exhibition_id: String) -> Node3D
func get_curator() -> Node3D
func fill_slot(exhibition_id: String, item_id: String) -> bool
func clear_slot(exhibition_id: String, item_id: String) -> void
func refresh_from_registry() -> void
func request_donation_ui(exhibition_id: String) -> void
```

### CollectionRegistry.gd (autoload)
```gdscript
class_name CollectionRegistry extends Node

signal item_registered(exhibition_id: String, item_id: String)
signal exhibition_completed(exhibition_id: String)

func register_item(exhibition_id: String, item_id: String) -> bool
func is_registered(exhibition_id: String, item_id: String) -> bool
func is_exhibition_completed(exhibition_id: String) -> bool
func get_registered(exhibition_id: String) -> Array[String]
func get_exhibition_progress(exhibition_id: String) -> Dictionary   # {registered, total, percent}
func get_total_progress() -> float
func mark_reward_claimed(exhibition_id: String) -> void
func is_reward_claimed(exhibition_id: String) -> bool
func restore_from_save(data: Dictionary) -> void
func to_save_data() -> Dictionary
```

### ExhibitSlot.gd (Node3D, scene "exhibit_slot")
```gdscript
class_name ExhibitSlot extends Node3D

signal occupied(item: ExhibitData)
signal vacated

var exhibit: ExhibitData
var occupied: bool

func setup(exhibit: ExhibitData) -> void
func place_item(item: ExhibitData) -> bool
func clear() -> void
func inspect() -> void          # abre panel de descripcion
func is_occupied() -> bool
```

### DonationService.gd (autoload)
```gdscript
class_name DonationService extends Node

signal donation_accepted(exhibition_id: String, item_id: String)
signal donation_rejected(exhibition_id: String, item_id: String, reason: String)
signal reward_granted(exhibition_id: String, reward_item_id: String)

class DonationResult:
    var accepted: bool
    var reason: String          # "", "duplicate", "not_owned", "wrong_exhibition", "invalid_item"
    var item_id: String
    var exhibition_id: String

func donate(exhibition_id: String, item_id: String) -> DonationResult
func validate(exhibition_id: String, item_id: String) -> DonationResult
func get_donatable_items(exhibition_id: String) -> Array[Dictionary]
func grant_exhibition_reward(exhibition_id: String) -> bool
```

## 6. Integracion con Otros Modulos

### M36 Fauna (avistamientos)
- M36 registra avistamientos y entrega `ExhibitData` de fauna al completar un avistamiento.
- M37 recibe la lista de especies avistadas (`get_avistadas()`) para filtrar donables.
- La donacion de fauna consume el "registro de avistamiento", no un item fisico.

### M34 Pesca (peces capturados)
- M34 posee el inventario de peces; M37 dona el pez fisico desde el inventario.
- Los peces donados se reflejan en acuarios con nado simplificado (sin fisicas).

### M25 Ruinas (fosiles y piezas)
- M25 entrega fosiles y piezas de ruinas como items; M37 los monta en pedestales.
- Las piezas de una misma excavacion pueden completar subconjuntos de la exposicion.

### M55 Diario
- M37 emite senales tipadas; un adaptador de M55 escucha y escribe entradas con fecha del reloj M29/M31.
- Las entradas incluyen: pieza donada, exposicion completada, recompensa recibida.

## 7. Interfaz de Usuario (desacoplada)

- Panel de donacion (lista de donables del inventario + confirmacion).
- Vista de exposicion con barra de progreso y siluetas de piezas faltantes.
- Tooltip de vitrina (nombre y estado) al pasar el cursor.
- Cartel de progreso global en la entrada del museo.
- Notificacion especial de exposicion completada y entrega de recompensa.
- Feedback de rechazo con motivo visible y sin consumir inventario.

## 8. Persistencia

- `CollectionRegistry.to_save_data()` -> `{exposicion: [piesas], recompensas: [ids]}` integrado al guardado general del juego.
- `restore_from_save()` reconstruye el estado y la escena consulta al Registry.
- Escritura atomica: donacion o recompensa se persisten como bloque unico.
- Versionado del bloque para migraciones futuras (agregar exposiciones nuevas no rompe guardados).
## Specs Museos (Beam 505)

### Acuario con nado animado por spline (peces)
- Spec: variante para peces: acuario con nado animado por spline. Coherente con M37 (museos) y M34 (pesca).

## Specs Museos (Beam 635)

### Escena museum.tscn creada con entrada, mostrador y cartel de progreso
- Spec: escena museum.tscn creada con entrada, mostrador y cartel de progreso. Coherente with M37 (museos) and M08 (terreno).

### Sala de fauna con dioramas para avistamientos de M36
- Spec: sala de fauna con dioramas para avistamientos de M36. Coherente with M37 (museos) and M36 (fauna).

### Sala de fosiles con pedestales y montajes de M25
- Spec: sala de fosiles con pedestales y montajes de M25. Coherente with M37 (museos) and M25 (templo).

### Curador NPC con dialogo de recepcion y agradecimientos cozy
- Spec: curador NPC con dialogo de recepcion y agradecimientos cozy. Coherente with M37 (museos) and M18 (NPC).

### Iluminacion interior calida y estatica (horneada)
- Spec: iluminacion interior calida y estatica (horneada). Coherente with M37 (museos) and M48 (iluminacion).


## Specs Museos (Beam 636)

### Sala de fauna con dioramas para avistamientos de M36
- Spec: sala de fauna con dioramas para avistamientos de M36. Coherente with M37 (museos) and M36 (fauna).

### Sala de fosiles con pedestales y montajes de M25
- Spec: sala de fosiles con pedestales y montajes de M25. Coherente with M37 (museos) and M25 (templo).

### Curador NPC con dialogo de recepcion y agradecimientos cozy
- Spec: curador NPC con dialogo de recepcion y agradecimientos cozy. Coherente with M37 (museos) and M18 (NPC).

### Navegabilidad completa de salas sin colisiones molestas
- Spec: navegabilidad completa de salas sin colisiones molestas. Coherente with M37 (museos) and M08 (terreno).

### Inspeccion de pieza abre panel con nombre, procedencia y curiosidad
- Spec: inspeccion de pieza abre panel con nombre, procedencia y curiosidad. Coherente with M37 (museos) and M53 (UI).


## Specs Museos (Beam 637)

### Variante para fosiles: montaje en pedestal con iluminacion suave
- Spec: variante para fosiles: montaje en pedestal con iluminacion suave. Coherente with M37 (museos) and M25 (templo).

### Variante para fauna: diorama estatico con el modelo avistado
- Spec: variante para fauna: diorama estatico con el modelo avistado. Coherente with M37 (museos) and M36 (fauna).

### Variante para arte: cuadro en marco sobre pared
- Spec: variante para arte: cuadro en marco sobre pared. Coherente with M37 (museos) and M45 (arte 2D).

### Pool de slots libres con prefab ligero (sin modelos pesados)
- Spec: pool de slots libres con prefab ligero (sin modelos pesados). Coherente with M37 (museos) and M61 (rendimiento).

### Mensajes cozy del curador al aceptar cada pieza
- Spec: mensajes cozy del curador al aceptar cada pieza. Coherente with M37 (museos) and M18 (NPC).


## Specs Museos (Beam 638)

### Trofeo final por museo 100% completado
- Spec: trofeo final por museo 100% completado. Coherente with M37 (museos) and M72 (logros).

### Pieza secreta opcional desbloqueable por descubrimiento (plan futuro)
- Spec: pieza secreta opcional desbloqueable por descubrimiento (plan futuro). Coherente with M37 (museos) and M71 (progresion).

### Vinculo bidireccional: consultar piezas del museo desde el diario
- Spec: vinculo bidireccional: consultar piezas del museo desde el diario. Coherente with M37 (museos) and M55 (diario).

### El diario no interrumpe el flujo de donacion (receptor async)
- Spec: el diario no interrumpe el flujo de donacion (receptor async). Coherente with M37 (museos) and M55 (diario).

### Items donables registrados antes de restaurar el museo (cola pendiente)
- Spec: items donables registrados antes de restaurar el museo (cola pendiente). Coherente with M37 (museos) and M59 (guardado).


## Specs Museos (Beam 639)

### Inventario vacio al abrir el panel de donacion (UI vacia elegante)
- Spec: inventario vacio al abrir el panel de donacion (UI vacia elegante). Coherente with M37 (museos) and M53 (UI).

### Cierre del juego entre consumo y escritura de guardado (rollback)
- Spec: cierre del juego entre consumo y escritura de guardado (rollback). Coherente with M37 (museos) and M59 (guardado).

### Doble interaccion simultanea sobre la misma vitrina
- Spec: doble interaccion simultanea sobre la misma vitrina. Coherente with M37 (museos) and M53 (UI).

### Recompensa otorgada con inventario lleno (cola o correo de items)
- Spec: recompensa otorgada con inventario lleno (cola o correo de items). Coherente with M37 (museos) and M14 (recursos).

### Restauracion de curaduria (nombres y descripciones) al cargar
- Spec: restauracion de curaduria (nombres y descripciones) al cargar. Coherente with M37 (museos) and M59 (guardado).


## Specs Museos (Beam 640)

### Panel de donacion con lista filtrada de items donables
- Spec: panel de donacion con lista filtrada de items donables. Coherente with M37 (museos) and M53 (UI).

### Barra de progreso por exposicion con contador de piezas
- Spec: barra de progreso por exposicion con contador de piezas. Coherente with M37 (museos) and M53 (UI).

### Tooltip de vitrina al pasar el cursor (nombre y estado)
- Spec: tooltip de vitrina al pasar el cursor (nombre y estado). Coherente with M37 (museos) and M53 (UI).

### Feedback visual al donar (particulas y brillo en la vitrina)
- Spec: feedback visual al donar (particulas y brillo en la vitrina). Coherente with M37 (museos) and M52 (particulas).

### Feedback de rechazo con motivo visible
- Spec: feedback de rechazo con motivo visible. Coherente with M37 (museos) and M53 (UI).


## Specs Museos (Beam 641)

### Cartel de recompensa al completar exposicion
- Spec: cartel de recompensa al completar exposicion. Coherente with M37 (museos) and M53 (UI).

### Navegacion completa por mando y teclado en la UI
- Spec: navegacion completa por mando y teclado en la UI. Coherente with M37 (museos) and M56 (interfaz).

### Mensajes de estado durante la carga del edificio
- Spec: mensajes de estado durante la carga del edificio. Coherente with M37 (museos) and M63 (streaming).

### Vitrinas instanciadas solo para piezas registradas
- Spec: vitrinas instanciadas solo para piezas registradas. Coherente with M37 (museos) and M61 (rendimiento).

### Culling de salas distantes desde el jugador
- Spec: culling de salas distantes desde el jugador. Coherente with M37 (museos) and M61 (rendimiento).


## Specs Museos (Beam 642)

### Iluminacion estatica horneada en interiores
- Spec: iluminacion estatica horneada en interiores. Coherente with M37 (museos) and M48 (iluminacion).

### Acuarios con simulacion de nado ligera sin fisicas por pez
- Spec: acuarios con simulacion de nado ligera sin fisicas por pez. Coherente with M37 (museos) and M34 (pesca).


## Specs Museos (Beam 643)

### Carga de sala bajo 250 ms medido con Profiler
- Spec: carga de sala bajo 250 ms medido con Profiler. Coherente with M37 (museos) and M61 (rendimiento).

### Inspeccion y UI sin micro-stutter en el frame budget
- Spec: inspeccion y UI sin micro-stutter en el frame budget. Coherente with M37 (museos) and M61 (rendimiento).

### Test: vitrina ocupada nunca sobrescrita
- Spec: test: vitrina ocupada nunca sobrescrita. Coherente with M37 (museos) and M112 (testing).

### Test: museo 100% desbloquea el trofeo final
- Spec: test: museo 100% desbloquea el trofeo final. Coherente with M37 (museos) and M72 (logros).

### Test: integracion de senales con M36/M34/M25/M55
- Spec: test: integracion de senales con M36/M34/M25/M55. Coherente with M37 (museos) and M112 (testing).

### Test: edge cases (inventario vacio, sala incorrecta, item inexistente)
- Spec: test: edge cases (inventario vacio, sala incorrecta, item inexistente). Coherente with M37 (museos) and M112 (testing).

### Recorrido manual: visitar el museo completo tres veces seguidas
- Spec: recorrido manual: visitar el museo completo tres veces seguidas. Coherente with M37 (museos) and M114 (playtest).
