**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 37: Museos y Colecciones

## 1. Rutas de Archivos (res://)

### Scripts
| Ruta | Rol |
|---|---|
| `res://scripts/museum/exhibition_data.gd` | Resource de exposicion (lista de piezas, recompensa) |
| `res://scripts/museum/exhibit_data.gd` | Resource de pieza (nombre, descripcion, escena, icono) |
| `res://scripts/museum/collection_registry.gd` | Autoload: registro, progreso y persistencia |
| `res://scripts/museum/donation_service.gd` | Autoload: validacion, consumo y recompensas |
| `res://scripts/museum/museum.gd` | Nodo raiz del edificio: salas, slots y curador |
| `res://scripts/museum/exhibit_slot.gd` | Vitrina instanciable con variantes por familia |
| `res://scripts/museum/museum_curator.gd` | NPC curador: dialogo de entrada y recepcion |
| `res://scripts/museum/donation_result.gd` | Clase de resultado de donacion (aceptada/motivo) |
| `res://scripts/ui/museum/museum_panel.gd` | Panel de donacion de la UI |
| `res://scripts/ui/museum/exhibition_progress_bar.gd` | Barra de progreso por exposicion |

### Escenas
| Ruta | Rol |
|---|---|
| `res://scenes/interior/museum/museum.tscn` | Edificio completo con 4 salas |
| `res://scenes/interior/museum/rooms/room_fauna.tscn` | Sala de fauna (dioramas) |
| `res://scenes/interior/museum/rooms/room_fish.tscn` | Sala de peces (acuarios) |
| `res://scenes/interior/museum/rooms/room_fossils.tscn` | Sala de fosiles (pedestales) |
| `res://scenes/interior/museum/rooms/room_art.tscn` | Sala de arte (marcos) |
| `res://scenes/interior/museum/exhibit_slot.tscn` | Vitrina generica (variantes por recurso) |

### Datos (Resources .tres)
| Ruta | Rol |
|---|---|
| `res://data/museum/exhibitions/exhibition_fauna.tres` | Exposicion Fauna Avistada (M36) |
| `res://data/museum/exhibitions/exhibition_fish.tres` | Exposicion Peces del Archipielago (M34) |
| `res://data/museum/exhibitions/exhibition_fossils.tres` | Exposicion Fosiles y Ruinas (M25) |
| `res://data/museum/exhibitions/exhibition_art.tres` | Exposicion Arte de Aurora (M37) |

## 2. Firmas de Funciones Clave

### exhibition_data.gd
```gdscript
class_name ExhibitionData extends Resource
@export var id: String
@export var display_name: String
@export var room_scene: PackedScene
@export var items: Array[ExhibitData]
@export var reward_item_id: String
@export var reward_display_name: String

func get_item(item_id: String) -> ExhibitData
func get_item_index(item_id: String) -> int
func get_progress(registered: Array[String]) -> Dictionary
```

### exhibit_data.gd
```gdscript
class_name ExhibitData extends Resource
@export var id: String
@export var display_name: String
@export var description: String
@export var origin: String
@export var slot_scene: PackedScene
@export var model_scene: PackedScene
@export var icon: Texture2D

func to_save_dict() -> Dictionary
```

### collection_registry.gd
```gdscript
extends Node

signal item_registered(exhibition_id: String, item_id: String)
signal exhibition_completed(exhibition_id: String)

var _registered: Dictionary = {}
var _rewards_claimed: Dictionary = {}

func register_item(exhibition_id: String, item_id: String) -> bool
func is_registered(exhibition_id: String, item_id: String) -> bool
func is_exhibition_completed(exhibition_id: String) -> bool
func get_registered(exhibition_id: String) -> Array[String]
func get_exhibition_progress(exhibition_id: String) -> Dictionary
func get_total_progress() -> float
func mark_reward_claimed(exhibition_id: String) -> void
func is_reward_claimed(exhibition_id: String) -> bool
func restore_from_save(data: Dictionary) -> void
func to_save_data() -> Dictionary
```

### donation_service.gd
```gdscript
extends Node

signal donation_accepted(exhibition_id: String, item_id: String)
signal donation_rejected(exhibition_id: String, item_id: String, reason: String)
signal reward_granted(exhibition_id: String, reward_item_id: String)

func donate(exhibition_id: String, item_id: String) -> DonationResult
func validate(exhibition_id: String, item_id: String) -> DonationResult
func get_donatable_items(exhibition_id: String) -> Array[Dictionary]
func grant_exhibition_reward(exhibition_id: String) -> bool
```

### museum.gd
```gdscript
class_name Museum extends Node3D

signal exhibition_completed(exhibition_id: String)
signal museum_total_progress_changed(percent: float)

func get_room(exhibition_id: String) -> Node3D
func get_curator() -> Node3D
func fill_slot(exhibition_id: String, item_id: String) -> bool
func clear_slot(exhibition_id: String, item_id: String) -> void
func refresh_from_registry() -> void
```

### exhibit_slot.gd
```gdscript
class_name ExhibitSlot extends Node3D

signal occupied(item: ExhibitData)
signal vacated

var exhibit: ExhibitData
var current_item: ExhibitData

func setup(exhibit: ExhibitData) -> void
func place_item(item: ExhibitData) -> bool
func clear() -> void
func inspect() -> void
func is_occupied() -> bool
```

## 3. Logica de Negocio Clave

### Validacion de donacion (donation_service.gd)
```
1. item existe en el catalogo de la exposicion          -> si no: "invalid_item"
2. el jugador posee el item (inventario M34/M25 o avis. M36) -> si no: "not_owned"
3. item no registrado en CollectionRegistry             -> si no: "duplicate"
4. consumo del item del inventario (solo si 1-3 OK)
5. register_item + fill_slot + senales + diario M55
```

### Idempotencia de recompensa
```
al completarse la exposicion:
  si NOT is_reward_claimed(exhibition_id):
      grant_exhibition_reward -> inventario
      mark_reward_claimed(exhibition_id)
      senal reward_granted + entrada en M55
```

### Reconstruccion de vitrinas (museum.gd)
```
refresh_from_registry():
  para cada ExhibitionData:
    para cada item:
      slot = room.get_slot(item.id)
      if registry.is_registered(ex.id, item.id):
          slot.place_item(item)   # ocupado
      else:
          slot.setup(item)        # libre, silueta "Por donar"
  emitir museum_total_progress_changed(registry.get_total_progress())
```

## 4. Logs

Sistema de logging del juego (formato `[M37]` para filtrar el modulo). No se crean archivos dentro de `Assets/` (regla global): se escribe en el log centralizado del proyecto fuera de la escena.

| Evento | Nivel | Formato |
|---|---|---|
| Donacion aceptada | INFO | `[M37] DONATE ok exhibition=%s item=%s` |
| Donacion rechazada | INFO | `[M37] DONATE reject exhibition=%s item=%s reason=%s` |
| Exposicion completada | INFO | `[M37] EXHIBITION_COMPLETE exhibition=%s` |
| Recompensa otorgada | INFO | `[M37] REWARD exhibition=%s item=%s` |
| Recompensa duplicada bloqueada | WARN | `[M37] REWARD dup blocked exhibition=%s` |
| Slot ocupado inesperado | WARN | `[M37] SLOT already occupied exhibition=%s item=%s` |
| Carga de partida | INFO | `[M37] RESTORE exhibitions=%d items=%d rewards=%d` |
| Falta resource de exposicion | ERROR | `[M37] MISSING exhibition resource id=%s` |
| Guardado fallido | ERROR | `[M37] SAVE failed: %s` |

## 5. Rendimiento y Optimizacion

- Vitrinas instanciadas solo para piezas registradas; las libres usan una prefab ligera de silueta.
- Salas con culling (escena por sala, proximidad); luz estatica horneada en interiores.
- Acuarios: animacion de nado por spline, sin RigidBody por pez, maximo N peces activos por acuario.
- Consultas `is_registered` por Dictionary: O(1).
- Carga de sala < 250 ms; sin allocs en el loop de inspeccion.

## 6. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 (documentacion plan-inicial)
**Estado:** Plan inicial de diseno — sin codigo implementado aun (modulo sin iniciar en CHECKLIST-GLOBAL).

### Lo que se definio
- Arquitectura completa (Museum, CollectionRegistry, ExhibitSlot, DonationService) con contratos GDScript estables.
- Rutas res:// de scripts, escenas y resources; formato de logs `[M37]`.
- Reglas de negocio: validacion de donacion, idempotencia de recompensa, reconstruccion de vitrinas.

### Recomendaciones para el proximo agente
- Implementar primero CollectionRegistry y DonationService (autoloads sin escena), luego ExhibitSlot y Museum.
- Generar los 4 ExhibitionData.tres partiendo de los catalogos reales de M36/M34/M25.
- Conectar el adaptador de M55 Diario por senales antes de la UI de donacion.
- Ejecutar el plan de testings (seccion N del 05-Checklist) antes de la primera prueba manual.