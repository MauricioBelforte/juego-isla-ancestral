**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 54: Mapa

> **Estado: PARCIALMENTE IMPLEMENTADO** (2026-09-14, mimo-v2.5-free) — Existente: `mapa_manager.gd` (autoload), `mapa_markers.gd`, `mapa_busqueda.gd`, `minimap_widget.gd`, `full_map_layer.gd`, `map_canvas.gd`, `fog_renderer.gd`, `map_data_service.gd`, `map_schema.gd`. Config: `data/mapa/map_config.json`. Tests: 5 archivos headless. Pendiente: `player_pins_service.gd` separado (actualmente integrado en manager), `markers_catalog.gd` separado, `region_glyph_layer.gd`, `map_ui.gd` (panel de filtros).

## 1. Ubicación de archivos (plan previsto — Pendiente de implementación)

```
res://mapa/
├── core/
│   ├── mapa_manager.gd              # Autoload MapManager (datos de mapa)
│   ├── mapa_config.gd               # Configuración (tamaños, radio revelado, colores)
│   └── mapa_constants.gd            # enums (MarkerType, IslandId), límites
├── data/
│   ├── region_data.gd               # Resource RegionData (M09/M27)
│   ├── region_state.gd              # estado seen/visited por región/celda
│   ├── pin_data.gd                  # Resource PinData (pines del jugador)
│   └── map_baker.gd                 # Bake del mundo voxel a ImageTexture (M10)
├── fog/
│   └── explorer.gd                  # Niebla de guerra (lógica de datos)
├── markers/
│   └── markers_catalog.gd           # Marcadores del mundo + clusterización
├── pins/
│   └── player_pins_service.gd       # CRUD de pines del jugador
└── views/                           # Capa de presentación (M53)
    ├── minimap_view.gd             # Widget Control del HUD
    ├── minimap_view.tscn
    ├── full_map_layer.gd           # UILayer MODAL_FULL
    ├── full_map_layer.tscn
    ├── map_canvas.gd               # Zoom/pan + clamp
    ├── marker_pool.gd              # Pool de sprites (marcadores/clusters/pines)
    ├── region_glyph_layer.gd       # Nombres y bordes de región (M88)
    ├── map_ui.gd                   # Panel: leyenda, filtros, pines, viaje
    └── fog_renderer.gd             # FogTextureRect (mosaicos sucios)
```

## 2. Autoloads registrados (project.godot — Pendiente de implementación)

```
[autoload]
UIManager="*res://ui/core/ui_manager.gd"     # M53
MapManager="*res://mapa/core/mapa_manager.gd" # M54 — después de UIManager y EventBus
```
Orden de carga: Bootstrap(M07) > EventBus(M07) > ActionLayer(M57) > UIManager(M53) > MapManager(M54).

## 3. Firmas clave (GDScript, Godot 4.x)

```gdscript
## mapa_manager.gd
class_name MapManager
extends Node

signal exploration_changed(region_ids: Array[int])
signal markers_changed
signal pins_changed
signal map_texture_ready(texture: ImageTexture)
signal travel_state_changed(state: String)

var regions: Array[RegionData] = []
var explorer: Explorer
var markers: MarkersCatalog
var pins_service: PlayerPinsService
var _map_texture: ImageTexture
var _fog_provider: Callable               # interfaz de M69 (jamás un nodo)

func _ready() -> void:
    _load_regions()                       # desde M09/M27
    _load_saved_state()                   # desde M60 (exploración, pines, caché)
    _map_texture = _load_or_bake_texture()  # bake en background si no hay caché (M63)

func get_map_texture() -> ImageTexture: ...
func get_fog_image() -> Image: ...
func get_region_at(world_pos: Vector3) -> RegionData: ...
func is_explored(region_id: int) -> bool: ...
func is_visited(region_id: int) -> bool: ...
func reveal_area(center: Vector3, radius: float) -> void:
    # marca celdas; si cambió algo -> exploration_changed
func register_fast_travel_provider(provider: Callable) -> void:
    _fog_provider = provider              # M69 la registra en su _ready
func request_travel(destino_id: String) -> void:
    if _fog_provider.is_valid():
        _fog_provider.call(destino_id)    # sin import de nodos de M69
func save_state() -> void: ...            # M60
func load_state() -> void: ...            # M60

## data/region_data.gd
class_name RegionData
extends Resource

@export var region_id: int
@export var region_name: String
@export var biome_id: int                 # enum de M09/M27
@export var polygon: PackedVector2Array   # coordenadas del mundo (2D)
@export var bounds: Rect2
@export var is_water: bool = false

## data/pin_data.gd
class_name PinData
extends Resource

@export var pin_id: int
@export var world_pos: Vector3
@export var label: String
@export var created_day: int              # M29 (día de creación)

## data/map_baker.gd
class_name MapBaker
extends RefCounted

func bake(seed_value: int, size: Vector2i) -> Image:
    # recorre el chunk data del mundo (M10/M08) y pinta biomas con
    # paleta cozy de M53; sin tocar meshes ni escena
func is_seed_valid(seed_value: int) -> bool   # M60: coincidencia con la semilla guardada

## fog/explorer.gd
class_name Explorer
extends Node

var _states: Dictionary = {}              # region_id -> RegionState

func reveal_around(center: Vector3, radius: float) -> Array[int]:
    # devuelve regiones cuyo estado cambió (mosaicos sucios)
func state_for(region_id: int) -> RegionState: ...
func mark_visited(region_id: int) -> void: ...
func build_fog_image(map_size: Vector2i) -> Image: ...
func mark_dirty(region_ids: Array[int]) -> void: ...

## markers/markers_catalog.gd
class_name MarkersCatalog
extends Node

func register_world_marker(type: MarkerType, region_id: int,
        local_pos: Vector2, label: String) -> int: ...
func set_visible_types(types: Array[MarkerType]) -> void: ...
func markers_visible(explorer: Explorer) -> Array[MapMarkerData]: ...
func build_clusters(scale: float, capacity: int) -> Array[ClusterData]: ...

## pins/player_pins_service.gd
class_name PlayerPinsService
extends Node

var max_pins: int = 50                    # MapaConfig

func add_pin(world_pos: Vector3, label: String) -> int: ...
func remove_pin(pin_id: int) -> void: ...
func rename_pin(pin_id: int, label: String) -> void: ...
func pins() -> Array[PinData]: ...
func validate_on_load() -> void:          # pines fuera de rango -> marcados, no borrados (M60)

## views/minimap_view.gd
class_name MinimapView
extends Control

var _source: MapManager
var _player_icon: TextureRect
var _edge_arrow: TextureRect

func set_source(source: MapManager) -> void:
    _source = source; _rebake()
func _rebake() -> void:
    # textura base + niebla recortada; se ejecuta solo ante señales
func update_player(world_pos: Vector3, heading: float) -> void:
    # mueve el ícono y la flecha de borde; sin regenerar textura
func set_map_visible(visible: bool) -> void: ...
func _on_exploration_changed(region_ids: Array[int]) -> void: ...
func _on_travel_state_changed(state: String) -> void: ...

## views/full_map_layer.gd
class_name FullMapLayer
extends UILayer                            # M53

func open_map() -> void: ...
func _on_zoom_step(delta: float) -> void: ...     # M57: map_zoom_in/out
func _on_pan(offset: Vector2) -> void: ...        # M57: map_pan_* / arrastre
func _on_center_player() -> void: ...             # M57: map_center_player
func _on_new_pin() -> void: ...                   # M57: map_new_pin
func _on_travel_confirm(destino: MapMarkerData) -> void: ...

## views/map_canvas.gd
class_name MapCanvas
extends Control

var zoom: float = 1.0                     # 0.6 .. 3.0
func apply_zoom(delta: float, anchor: Vector2) -> void:
    # zoom anclado al cursor: mantiene el punto bajo el cursor estable
func apply_pan(offset: Vector2) -> void: ...
func _clamp_to_bounds() -> void: ...

## views/marker_pool.gd
class_name MarkerPool
extends Node2D

func ensure_sprites(count: int) -> void: ...   # pool pre-instanciado
func show_marker(slot: int, texture: Texture2D, pos: Vector2) -> void: ...
func hide_all() -> void: ...
func build_clusters(markers: Array[MapMarkerData], zoom_index: int) -> void: ...

## views/fog_renderer.gd
class_name FogRenderer
extends TextureRect

func refresh(explorer: Explorer, map_size: Vector2i, dirty: Array[int]) -> void:
    # ImageTexture solo con mosaicos sucios; modulate por reduce_motion (M58)

## views/region_glyph_layer.gd
class_name RegionGlyphLayer
extends Control

func refresh(regions: Array[RegionData], zoom_index: int) -> void:
    # nombres (M88) y bordes (M53) solo en cambios de zoom/pan
```

## 4. Eventos consumidos (EventBus, dominio `map` y externos)

| Evento | Emisor | Acción en el Mapa |
|---|---|---|
| `player.position_changed(world_pos, heading)` | M11 (baja frecuencia, ~2 Hz) | ícono del jugador + reveal_area ligero |
| `world.region_entered(region_id)` | M09/M27 | mark_visited + revelado de región + toast de nombre |
| `map.exploration_changed` | MapManager | MinimapView y FogRenderer refrescan mosaicos sucios |
| `map.travel_state_changed(state)` | M69 (vía interfaz) | estado del planificador de viaje en el mapa |
| `stores.registered(tienda_id, pos, label)` | M39 | registro automático de marcador de tienda |
| `npc.registered_home(npc_id, pos, label)` | M19 | registro de marcador de casa de NPC |
| `puzzles.poi_registered(tipo, pos, label)` | M24/M25 | registro de marcador de templo/ruina |
| `input.device_changed` / acciones M57 | M57 | prompts dinámicos del pie del mapa |
| `accessibility.settings_changed` | M58 | re-aplicar reducción de movimiento/contraste |
| `graphics.resolution_changed` | M90 | validar layout del mapa completo |
| `save.saved` / `save.loaded` | M60 | persistencia de exploración/pines/caché |

## 5. Logs relevantes (convención `DOM-MAP`)

- `[DOM-MAP] bake iniciado (semilla={s}, size={w}x{h})` / `[DOM-MAP] bake completado en {ms} ms` — generación de textura (M63).
- `[DOM-MAP] caché de textura válida (semilla={s})` — reutilización de la textura en disco.
- `[DOM-MAP] región {id} marcada visited` — cruce de borde de región (M09/M27).
- `[DOM-MAP] mosaicos sucios: {ids}` tras `exploration_changed` — refresh de niebla acotado.
- `[DOM-MAP] pin creado/renombrado/eliminado (id={id})` — PlayerPinsService.
- `[DOM-MAP] viaje solicitado a {destino} (provider válido={b})` — request_travel.
- `[DOM-MAP] cluster {n} marcadores -> 1 (escala={z})` — clusterización del pool.
- Mensajes de debug en `Logs/aplicacion.log` (fuera de `res://`, ver AGENTS 18).

## 6. Dependencias de código (imports permitidos/prohibidos)

- `res://mapa/**` importa: `res://core/**` (EventBus, Logger/ErrorHandler, tr_local), `res://data/**` (recursos serializables M60), `res://ui/core/ui_layer.gd` — SOLO las vistas `views/**` (presentación); `res://world/**` o `res://gameplay/**` SOLO estructuras de datos (chunk data de M10 para el bake), jamás nodos de escena.
- El dominio (`core/data/fog/markers/pins`) NO importa nada de `res://ui/**`.
- **Prohibido:** importar nodos de M11 (jugador), M19 (NPCs), M39 (tiendas) o M69 (fast travel) — todo acceso por eventos/Callable/recursos.
- Verificación estática del desacople en CI (M01/M07), como en M53.

## Notas del Agente

**Modelo:** mimo-v2.5-free
**Plataforma:** OpenCode
**Fecha:** 2026-09-14
**Estado:** Implementación parcial — core funcional, vistas básicas creadas

### Lo que hice (2026-09-14)
- Verifiqué que el código core ya existía (mapa_manager.gd, mapa_markers.gd, mapa_busqueda.gd, minimap_widget.gd) — no era "Pendiente" como decía la doc.
- Creé `full_map_layer.gd` (modal layer con leyenda y cierre con Esc).
- Creé `map_canvas.gd` (zoom/pan con mouse wheel y drag, renderizado de islas y marcadores).
- Creé `fog_renderer.gd` (textura de niebla de guerra con unfog por región).
- Actualicé el header de 04-Codigo.md para reflejar el estado real.

### Lo que queda pendiente
- `player_pins_service.gd` como clase separada (actualmente los pines están en mapa_manager.gd).
- `markers_catalog.gd` como clase separada (actualmente en mapa_markers.gd).
- `region_glyph_layer.gd` (nombres de región con fuentes M88).
- `map_ui.gd` (panel de filtros y leyenda interactiva).
- Integración real con M69 (fast travel provider).
- Test de integración del full_map_layer con el minimapa.

### Recomendaciones para el próximo agente
- El core del mapa funciona: autoload MapManager, datos JSON, exploración, pines, persistencia.
- Las vistas básicas (minimap + full map) están creadas pero necesitan integración con la escena principal.
- Priorizar la conexión del minimap_widget.gd con el HUD existente (M53).
- El fog_renderer es simplificado — necesita integración real con el Explorer del mapa.

### Notas del Agente anterior (Deepseek V4 Flash, 2026-08-17)
- Creé la documentación completa del módulo. El código fue implementado posteriormente por deepseek-v4-flash y agnes.