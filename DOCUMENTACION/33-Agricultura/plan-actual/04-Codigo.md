**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 33: Agricultura

> Este archivo documenta la **estructura de código planificada** (módulo delegable para implementación). Las rutas, firmas y eventos son el contrato de referencia; el código real se reflejará en `plan-actual/04-Codigo.md` cuando el agente delegado implemente.

## 1. Estructura de carpetas (`res://`)

```
res://src/farm/
├── farm_service.gd          # Autoload (Service Locator, M07) — orquestación y API pública
├── farm_service.tscn        # Escena autoload (registra el servicio)
├── crop_tile.gd             # CropTile (RefCounted): estado por voxel cultivado
├── crop_definition.gd       # CropDefinition (Resource): datos por cultivo
├── crop_catalog.gd          # Catálogo: carga los .tres y resuelve por crop_id
├── growth_stage.gd          # enum GrowthStage + helpers de nombre/estado
├── farm_state_store.gd      # Persistencia (serialización con GameState M59)
├── crop_tile_visual.gd      # CropTileVisual (Node3D): MultiMesh, LOD, animación sway
├── farm_plot.gd             # Reserva de parcelas (integración M17)
├── farm_weather_link.gd     # Puente Clima (M32): lluvia aplicada al regado automático
└── farm_hud_bridge.gd       # Puente UI (M53): expone datos de solo lectura al HUD

res://data/farm/
├── crops/                   # un .tres por cultivo (CropDefinition)
│   ├── tomate.tres
│   ├── maiz.tres
│   ├── trigo_invernal.tres
│   ├── calabaza.tres
│   ├── zanahoria.tres
│   ├── uva.tres
│   ├── algodon.tres
│   ├── flor_coral.tres
│   ├── crisantemo.tres
│   ├── margarita.tres
│   ├── rosa_hibrida.tres
│   ├── manzano.tres
│   ├── duraznero.tres
│   ├── palma_coco.tres
│   ├── lumina_ancestral.tres
│   └── helecho_decorativo.tres
└── farm_defaults.gd        # Constantes: límites de cultivos, capacidad de regadera
```

## 2. Firmas de funciones clave (contrato)

```gdscript
# ─────────────────────────────────────────────
# farm_service.gd  (autoload FARM)
# ─────────────────────────────────────────────
class_name FarmService extends Node

const MAX_ACTIVE_CROPS := 400
const MAX_WATER_LEVEL := 2

var _tiles: Dictionary = {}                    # Vector3i -> CropTile
var _plots: Array = []                         # reserves M17
var _catalog: CropCatalog

signal crop_planted(crop_id: StringName, voxel_pos: Vector3i)
signal crop_stage_changed(voxel_pos: Vector3i, stage: int)
signal crop_ready(voxel_pos: Vector3i)
signal crop_harvested(voxel_pos: Vector3i, items: Array)
signal tile_tilled(voxel_pos: Vector3i)
signal tile_watered(voxel_pos: Vector3i, water_level: int)
signal day_advanced(day_index: int)

func _ready() -> void:
    _catalog = CropCatalog.load_all("res://data/farm/crops")
    GameClock.day_advanced.connect(_on_calendar_day_advanced)   # M29

func till_tile(voxel_pos: Vector3i) -> bool:
    # valida bloque TIERRA (M08), parcela (M17), escribe TIERRA_ARADA via VoxelAPI
    pass

func plant(crop: CropDefinition, voxel_pos: Vector3i) -> bool:
    # valida tierra arada, cupo MAX_ACTIVE_CROPS y parcela; consume semilla via InventoryService
    pass

func water(voxel_pos: Vector3i) -> void:
    # water_level = min(MAX_WATER_LEVEL, water_level + 1)
    pass

func apply_rain(voxel_pos: Vector3i) -> void:
    # puente M32: rellena agua (no excede el nivel máximo)
    pass

func can_harvest(voxel_pos: Vector3i) -> bool:
    return _tiles.has(voxel_pos) and _tiles[voxel_pos].is_ready()

func harvest(voxel_pos: Vector3i) -> Array[Dictionary]:
    # calcula yields (+ calidad), entrega a InventoryService.try_add, resuelve árboles
    pass

func get_tile(voxel_pos: Vector3i) -> CropTile:
    return _tiles.get(voxel_pos)

func get_growth_hint(voxel_pos: Vector3i) -> String:
    # "Echó de menos el agua" / "Descansa hasta primavera" / "Lista para cosechar"
    pass

func advance_day() -> void:
    # itera CropTile activos: agua -1; pausa SIN_AGUA/DORMANTE; grown_days += 1; etapa
    pass

func reserve_plot(owner_id: int, center: Vector3i, radius: int) -> bool:
    pass

func get_active_farm_stats() -> Dictionary:
    # para M113/M104: cantidad por especie, por etapa, pausados, sin agua
    pass

func _on_calendar_day_advanced(day_index: int) -> void:
    advance_day()

func _serialize() -> Dictionary:      # delega a FarmStateStore
    pass

func _deserialize(data: Dictionary) -> void:
    pass

# ─────────────────────────────────────────────
# crop_tile.gd
# ─────────────────────────────────────────────
class_name CropTile extends RefCounted

var voxel_pos: Vector3i
var crop_def: CropDefinition
var stage: int
var grown_days: int
var water_level: int
var fertilized: bool
var quality: int
var planted_at_day: int

func is_ready() -> bool
func is_paused() -> bool
func current_stage_index() -> int
func can_advance_today(season: int, rain: bool) -> bool
func apply_daily_tick(season: int, rain: bool) -> bool

# ─────────────────────────────────────────────
# crop_definition.gd
# ─────────────────────────────────────────────
class_name CropDefinition extends Resource

@export var crop_id: StringName
@export var display_name: String
@export var description: String
@export var seasons: Array[int]                     # enum Season de GameClock (M29)
@export var grow_days: int
@export var stage_count: int
@export var water_need: int
@export var yields: Array[Dictionary]               # {item_id, amount}
@export var yield_seeds: Dictionary                 # {item_id: amount}
@export var quality_levels: bool
@export var is_tree: bool
@export var is_flower: bool
@export var is_ancestral: bool
@export var decorative_only: bool
@export var fertilizer_bonus: int

func get_stage_visual_key() -> StringName
func is_season_allowed(season: int) -> bool

# ─────────────────────────────────────────────
# crop_tile_visual.gd
# ─────────────────────────────────────────────
class_name CropTileVisual extends Node3D

func refresh() -> void            # re-consume MultiMesh por especie/etapa
func shake(duration_s: float) -> void
func play_water_fx() -> void
func play_harvest_fx() -> void

# ─────────────────────────────────────────────
# farm_state_store.gd
# ─────────────────────────────────────────────
class_name FarmStateStore extends RefCounted

func to_save_dict() -> Dictionary
func from_save_dict(data: Dictionary) -> void
func validate(data: Dictionary) -> bool
```

## 3. Eventos y logs

### 3.1 EventBus (M07, dominio `FARM`)

| Evento | Emisor | Consumidores típicos |
|---|---|---|
| `FARM.crop_planted` | FarmService | HUD, audio (M43), VFX (M52), analytics (M104) |
| `FARM.crop_stage_changed` | FarmService | CropTileVisual, audio de etapa final (campana suave) |
| `FARM.crop_ready` | FarmService | HUD (notificación cozy), M52 (brillo), sonido |
| `FARM.crop_harvested` | FarmService | Inventario M14, M104 |
| `FARM.tile_tilled` | FarmService | M08 (actualiza dif), M44 (ASMR tierra), M52 |
| `FARM.tile_watered` | FarmService | M43 (agua), M52 (gotas), HUD |
| `FARM.day_advanced` | FarmService | M113 (medición), HUD de despertar |

### 3.2 Logger (M103)

Categoría: `FARM`. Niveles y ejemplos (respeta sanitización de datos — sin coordenadas personales):

| Nivel | Mensaje | Cuándo |
|---|---|---|
| DEBUG | `[FARM] tile 12,4,7: agua 1->2 (regadera)` | Riego en debug |
| INFO | `[FARM] day 84 (invierno): 23 tiles a DORMANTE` | Cambio estacional masivo |
| WARN | `[FARM] intento de sembrar sin parcelas libres (cupo)` | Validación fallida esperada |
| ERROR | `[FARM] CropDefinition nula al plantar en 9,2,5 — uso del catálogo verificado` | Estado inválido |
| CRITICAL | `[FARM] FARM_STATE corrupto: tile sin crop_def (guardado v3)` | Corrupción detectada por `FarmStateStore.validate()` |

Regla: los logs de FARM nunca contienen `item_id` con fines de spoiler (plantas ancestrales); el debugger los censura vía M103.

## 4. Llamadas cross-módulo (referencia rápida)

```gdscript
# M08 Mundo Voxel (Voxel Tools): cambiar bloque y registrar instancia
VoxelAPI.set_voxel(voxel_pos, VoxelBlockID.TIERRA_ARADA)          # disparamos dif de chunk
VoxelAPI.instance_add(crop_transform, instance_key_per_specie)    # o VoxelInstanceModifier

# M29 GameClock: suscripción y estación actual
GameClock.day_advanced.connect(farm_service._on_calendar_day_advanced)
var season: int = GameClock.get_season()

# M14/M15: inventario y recursos
if InventoryService.try_remove(seed_item_id, 1):
    farm_service.plant(def, pos)
var result_items: Array = farm_service.harvest(pos)
InventoryService.try_add(result_items)                             # devuelve sobrante si hubiera

# M32 Clima: lluvia
if WeatherService.is_raining_today():
    farm_service.apply_rain(pos)                                   # exclusión por techo: deja M08 decidir
```

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Documentación de diseño completa (módulo delegable para implementación)

### Lo que hice
- Documenté el módulo 33 (plan inicial completo, 5 archivos) según la sección 32 del plan maestro (25 puntos) y el estándar de las secciones 3 y 11 de AGENTS.md.
- Diseñé la arquitectura CropDefinition/CropTile/FarmService/GrowthStage con capas desacopladas y API estable.
- Resolví edge cases cozy (invierno, sequía, pisoteo NPC) con reglas sin castigo irreversible.
- Diseñé los contratos de integración con M08, M29, M14/M15, M13, M16, M17, M32, M59 y M61.

### Lo que NO hice (honestidad obligatoria)
- No implementé código (módulo es DELEGABLE; depende de M08, M14, M29 implementados).
- No generé Logs/ ni toqué CHECKLIST-GLOBAL.md (fuera del alcance de esta tarea).
- No validé contra el 06-Plan-Testings (el módulo no requiere archivos de testing en plan-inicial por su complejidad media; se recomienda agregarlos en plan-actual).

### Intentos fallidos / decisiones
- Ningún fallo técnico: el único matiz es que la numeración del plan maestro (sección 32) difiere del ID de módulo del proyecto (33). Se documentó el mapeo explícito en 01-Requerimientos.

### Recomendaciones para el próximo agente
- Al implementar: priorizar `FarmService.advance_day()` y `FarmStateStore` antes que visuales; el visual se puede aproximar con placeholders si M08 aún no valida instancias.
- Verificar el presupuesto de 400 cultivos con MultiMesh (M61) antes de la versión final.
- Agregar el 06-Plan-Testings/07-Resultados en `plan-actual/` (pruebas de determinismo entre guardados y de estaciones).