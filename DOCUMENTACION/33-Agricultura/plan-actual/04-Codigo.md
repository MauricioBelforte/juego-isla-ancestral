**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code

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

**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)
**Plataforma:** Kilo Code
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

---

## Notas del Agente — Iteración puente M32→M33 (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 23:15:00
**Estado:** Parcial (puente lluvia implementado y verificado; módulo liberado 🟡)

### Lo que hice
- Puente M32→M33 (checklist "Implementar apply_rain (puente M32)"): FarmService suscribe `EventBus.weather.clima_cambio` y llama `apply_rain()` con LLUVIA/TORMENTA/TROPICAL (consumidores escuchan señales — diseño M32 §6; sin acoplamiento al WeatherService).
- `apply_rain()` ahora es idempotente por tile: no excede el máximo (agua 2), no toca cultivos listos y NO emite `tile_watered` redundante cuando el nivel ya está al máximo (checklist G "no excede" + menor overhead).
- Hook `_tile_expuesto(voxel_pos)` centralizado: hoy devuelve true (sin sistema de techos); M17/M18 podrán marcar cobertura tocando UNA función.
- Test nuevo `scripts/farm/test_farm_clima.gd` (complementa test_farm.gd, no lo reemplaza): riego 0→2 por lluvia, cultivos secos con 5 climas sin riego, tormenta/tropical riegan, sin señal redundante a máximo → **0 fallos**.
- Regresiones: test_farm.gd (núcleo Deepseek) **0 fallos**, test_clima.gd (M32) **0 fallos**.
- Checklist: 5 ítems marcados (RF6, P6, apply_rain-puente, lluvia-expuestos, no-excede); progreso real 37/153.

### Lo que NO pude hacer (honestidad obligatoria)
- "Expuestos sin techo" real: no existe sistema de techos (M17/M18); el hook devuelve true siempre.
- Nieve sobre tierra arada (G): requiere cubierta visual M08/M32 — con dueño.
- Till voxel real, MultiMesh pool, HUD, pisoteo: con dueño (M08/M61/M53/M64).

### Intentos fallidos / decisiones
- El test inicial esperaba una emisión "a máximo": el diseño correcto es CERO señales redundantes (idempotencia), corregido junto con apply_rain.
- Pitfall repetido: lambdas GDScript capturan por valor — el contador del test usa Array mutable (ya documentado en Log 306; aplica a todos los tests).

### Recomendaciones para el próximo agente
- M17/M18: al implementar techos, que marquen cobertura consultando `Farm._tile_expuesto` (o que Farm exponga `set_cubierta(pos, bool)`).
- MultiMesh (M61): partir de `_crear_visual`/`_actualizar_visual` existentes; presupuesto 1 ms.

---

## Notas del Agente — Deep work M33 (atria-dawn, Kilo Code, 2026-10-12)

**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 00:50:00
**Estado:** Lote grande cerrado (67 → ~105/153 pendientes de confirmación del director)

### Lo que hice
- **Fix `apply_daily_tick` (crop_tile.gd):** el estado LISTA ahora es estable —
  sale temprano antes de consumir agua o evaluar pausas (03-Diseno §6:
  "LISTA no requiere agua; espera al jugador sin penalización"). Antes un
  cultivo listo consumía 1 de agua por día y podía caer en SIN_AGUA estando
  cosechable.
- **Fix consumo de agua (crop_tile.gd):** ahora resta exactamente 1 por día
  (03-Diseno §2.4.5: "resta 1 de agua"), no `water_need` (que podía ser 2).
- **Fix `harvest()` (farm_service.gd):** `agregar_items` es atómica (reverte y
  devuelve false si no cabe todo). Antes se ignoraba el retorno → el cultivo se
  borraba y la cosecha se perdía. Ahora: si falla, se emite la nueva señal
  `crop_harvest_blocked(voxel_pos, items)` y el tile **se conserva** en LISTA
  (regla cozy M152: cero pérdidas). Cierra el edge case K "inventario lleno".
- **Idempotencia del tick diario (farm_service.gd):** nueva variable
  `_ultimo_dia_avanzado` persistida en el save data (`ultimo_dia`). Si
  `advance_day()` se llama dos veces para el mismo día absoluto (guardado a
  mitad del avance + recarga), la segunda es no-op. Cierra el edge case K
  "guardado a mitad del avance de día".
- **Señal 8/8 del contrato:** añadida `crop_harvest_blocked` a las 7 existentes.
- **Tests nuevos (`scripts/farm/test_farm_m33_lote.gd`, 6 bloques):**
  determinismo serializar/deserializar + round-trip FarmStateStore + tile
  corrupto aislado; 4 estaciones con calabaza de ventana parcial (DORMANTE
  fuera de ventana, retoma sin pérdida); 30 días sin agua (SIN_AGUA, nunca
  muerte, reanuda al regar); inventario lleno con stub atómico de Inventario
  (tile conservado + señal emitida); pisoteo NPC (shake, cero pérdida de
  estado); stress 400 cultivos + `advance_day` temporizado + `apply_rain`
  idempotente.
- **Docs:** añadí §5 "Prototipo sugerido" a 02-Analisis (3 cultivos + riego
  manual + avance diario); actualicé firmas.

### Lo que NO pude hacer (honestidad obligatoria)
- **No ejecuté los tests localmente:** Godot no es ejecutable desde este
  sandbox. Los tests están escritos con la guardia anti-falso-verde
  (CHECKS_MINIMOS + bloques _WB) y deben correrse via CI o `--headless`.
- **Items que requieren módulos externos (dejados [ ]):** HUD/notificaciones
  (M53), iconos (M45/M46), venta con precios por calidad (M38/M39), bloque
  TIERRA_ARADA del catálogo M08 (dif de chunk, variante húmeda, nieve),
  audio (M43/M44), VFX de gotas reales (M52), navegación M64 (coste alto),
  selector de semillas interactivo (M70/M53).
- **MultiMesh/LOD (L):** el visual actual es placeholder BoxMesh por planta;
  el pool MultiMesh queda para la integración con M50/M61.

### Intentos fallidos / decisiones
- Primera versión del test de inventario lleno usaba variables bool capturadas
  en lambdas — GDScript captura por valor y el flag nunca propagaba. Corregido
  con el patrón Array mutable (`var flag := [false]`) documentado en Log 306.
- El stress test siembra en lotes de 5 semillas porque `agregar_items` es
  atómica y respeta el límite de stacks; un lote único de 400 puede rechazarse.
- Umbral de stress del test: 50 ms (headless holgado) — M61 pide ≤2 ms en
  runtime; el placeholder por-nodo no cumple eso, el MultiMesh sí lo hará.

### Recomendaciones para el próximo agente
- Correr `test_farm_m33_lote.gd` en CI/headless y reportar los ms reales de
  `advance_day` con 400 cultivos (dato para M61).
- El siguiente bloque natural es M08 (bloque TIERRA_ARADA + dif de chunk) que
  desbloquea 6+ items de la sección I.


---

## Notas del Agente — Integracion M08 TIERRA_ARADA (atria-dawn, Kilo Code)

**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 03:40:00
**Estado:** 7 items cerrados (106/153); pendiente verificacion del director

### Lo que hice
- **M08 block_type.gd:** constantes `TIERRA_ARADA = 31` y
  `TIERRA_ARADA_HUMEDA = 32` + casos en `create_default` (nombres, pala,
  colores). IDs 31/32 libres (no colisionan con 0..30 existentes).
- **M08 main_island.gd:** dos `_add_block` al FINAL de la VoxelBlockyLibrary
  (modelos 31 y 32). **Invariante critico verificado:** el indice del modelo
  == block id para los 33 modelos (el canal CHANNEL_TYPE guarda el id y
  VoxelMesherBlocky lo usa como indice). Anadirlos al final no desplazo
  ningun indice existente (0..30 intocados).
- **M33 farm_service.gd:**
  - `till_tile()` escribe el voxel TIERRA_ARADA via `_escribir_bloque()`.
  - Nuevos helpers `_leer_bloque()` / `_escribir_bloque()` (VoxelTool con
    `channel = VoxelBuffer.CHANNEL_TYPE`) y `_actualizar_voxel_suelo()`
    (humeda si water_level >= 1, seca si no; solo escribe si el voxel difiere
    -> evita re-mesh innecesario, presupuesto M61).
  - `water()`, `apply_rain()` y `advance_day()` actualizan la variante.
  - `harvest()` escribe TIERRA_ARADA al borrar el cultivo (la tierra queda
    arada y reutilizable; nunca vuelve a DIRT).
  - **Fix del lookup del terreno:** `_buscar_terreno()` usaba la ruta
    `IslaRaiz/VoxelTerrain` que NO existe en main_island.tscn (el
    VoxelTerrain cuelga de la raiz), de modo que la validacion de bloque
    natural nunca se activaba en el juego real. Ahora usa el criterio
    canonico de TerrainLocator/tool_controller (hijos de la escena actual mas
    fallback recursivo).
  - Seam de test `set_terrain_para_tests(t)` (duck-typed) para headless.
- **Test nuevo `scripts/farm/test_farm_voxel_m33.gd`** (6 bloques, guardia
  anti-falso-verde): arar escribe 31, regar a 32, advance_day seca a 31,
  lluvia a 32, cosecha conserva arada, nieve externa no borra el estado,
  modo logico sin terrain. **No ejecutado**: Godot no es ejecutable desde
  este sandbox; delegar a CI/headless.

### Lo que NO pude hacer (honestidad obligatoria)
- **No ejecute los tests** (Godot no ejecutable en el sandbox).
- No verifique visualmente el dif de chunk en el juego (M08 es V2 en la guia
  08; requiere correr el juego). La correccion es logica/datos verificada
  estaticamente (invariante indice==id + grep de simbolos).
- Quedan 47 `[ ]`, casi todos de modulos externos (M53/M45/M38/M39/M43/M61/
  M64/M17/M70).

### Decision de diseno
- La tierra arada es un **bloque solido** (VoxelBlockyModelCube): la colision
  la genera VoxelTools igual que DIRT/GRASS (item I4). La variante humeda es
  otro bloque solido de color mas oscuro (feedback visual del riego, item G).
- El estado agricola vive en los diccionarios `_arados`/`_tiles` del
  FarmService, **no** en el voxel: cualquier escritura externa (nieve M32,
  construccion M17) no borra el estado (item I6).
