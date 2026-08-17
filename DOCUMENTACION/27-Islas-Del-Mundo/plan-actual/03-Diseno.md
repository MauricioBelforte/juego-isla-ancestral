**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 27: Islas del Mundo

## 1. Arquitectura

Componentes (patrón Service Locator M07; sin acoplar gameplay en UI):

```
IslandDefinition (Resource)          → datos inmutables de una isla
IslandRegistry (autoload/servicio)   → catálogo del archipiélago + anclas (M10) + validación
IslandLoading (servicio)             → carga/descarga/streaming de islas (M63) + puntos de llegada
IslandProps (servicio)               → contenido exclusivo por isla (spawn declarativo)
```

### 1.1 IslandDefinition (Resource `island_definition.gd`)
- `id` (StringName), `nombre_display` (String), `descripcion` (String, lore).
- `bioma_base` (Bioma M09) y `biomas_mezcla` (Array, proporciones).
- `radio` (int, metros voxel), `altura_min/max` (int), `playa_ancho` (int).
- `ancla` (Vector3i, centro de la losa en el mundo mundo-mundo M08).
- `semilla_isla` (int, derivada de semilla de partida + id → PRNG M10).
- `clima_tendencia` (M32), `musica_theme` (M41), `fauna_endemica` (Array id M36), `flora_endemica` (Array id M50), `recursos_exclusivos` (Array id M15).
- `puzzles` (Array id M23/M24), `npc_residentes` (Array id M19).
- `punto_llegada` (Vector3i local: puerto/muelle/faro) y `punto_partida` (Vector3i local).
- `anillo` (enum: NUCLEO / CERCANO / MEDIO / LEJANO → controla distancia y requisito de viaje M28).
- `desbloqueo` (condición: semilla de historia M22, sello M22/M26, expedición M28, viaje estacional).
- `es_secreta` (bool: no aparece en mapa M54 hasta descubrirse), `es_flotante` (bool: islas del cielo sin océano debajo).

### 1.2 IslandRegistry (autoload `island_registry.gd`)
- `get_isla(id) -> IslandDefinition`
- `todas_las_islas() -> Array[IslandDefinition]` (orden determinista por id).
- `isla_principal() -> IslandDefinition` (Aurora).
- `posicion_ancla(id) -> Vector3i` (delega a M10 con cache).
- `vecinas(id, corte_anillo) -> Array[IslandDefinition]` (islas dentro de radio de streaming).
- `validar_anclas() -> Array[String]` (errores de solapamiento/distancia mínima).
- `coordenadas_por_isla(id) -> Rect2i` (bounds en voxels para streaming M63).
- Señal: `archipielago_cargado`.

### 1.3 IslandLoading (servicio `island_loading.gd`)
- `cargar_isla(id, preferencia: PRELOAD/DESCARGA) -> Task` (async, progreso por pesos).
- `descargar_isla(id)` (LRU de M63; nunca descarga Aurora ni la isla actual).
- `isla_actual() -> StringName` (isla donde está el jugador).
- `punto_de_llegada(id) -> Vector3` (world-space del muelle).
- `punto_de_partida(id) -> Vector3`.
- `cacheado(id) -> bool`.
- Señales: `isla_cargando(id, progreso_float, etapa)`, `isla_cargada(id)`, `isla_descargada(id)`.

### 1.4 IslandProps (servicio `island_props.gd`)
- `materializar(isla, zona: EnumWorld) -> void` (spawn de flora/fauna/POI contra generadores M50/M36/M19 mediante contratos).
- `registrar_spawner(tipo, callable)` (permite que otros módulos registren sus spawner sin acoplarse).
- `pois_isla(id) -> Array[POI]` (muelle, plaza, faro, templo, mirador — consumido por M64).
- `limpiar(isla)` (descarga segura de props).

## 2. Flujos en texto

### Flujo F1 — Inicio de partida / generación (M10)
1. M10 genera la losa del mundo con 8 capas; la **capa de anclas** sitúa Aurora (centro) y 12 satélites por PRNG de contexto 2.
2. M27 lee las anclas generadas → `IslandRegistry.init(anclas)` → valida solapamientos (mínimo `radio_a + radio_b + 64 m` de mar) → `archipielago_cargado` emitido; errores → log y corrección de ancla (re-roll con misma semilla).
3. `IslandLoading` marca Aurora como `isla_actual` y solicita su carga a M63 (siempre cargada).

### Flujo F2 — Viaje por barco (M28 → M27 → M63)
1. Jugador en muelle de Aurora → M28 inicia travesía (pantalla de viaje con progreso real).
2. M28 consulta `IslandRegistry.posicion_ancla(destino)` para la ruta.
3. `IslandLoading.cargar_isla(destino, PRELOAD)` con progreso (pesos: losa voxel 60%, props 25%, audio 10%, navmesh 5%) → `isla_cargada`.
4. Al desembarcar: posición = `punto_de_llegada(destino)`, `isla_actual = destino`, marcado visitada en M59/M54.
5. Aurora queda en LRU (no se descarga nunca de disco, sí de memoria si hay presión M62).

### Flujo F3 — Navegación oceánica libre (M28 + M51)
1. El jugador zarpa sin destino fijo: el océano voxel (M51) es navegable continuamente.
2. Al acercarse al radio de streaming de una isla vecina → `IslandLoading` precarga (borde + chunk de margen, M63).
3. Al alejarse → LRU descarga; `IslandProps.limpiar`.
4. Al entrar en aguas de isla → detección de llegada (M28) → `punto_de_llegada`.

### Flujo F4 — Regreso a Aurora (anti-frustración)
1. Cualquier muelle de satélite ofrece viaje de regreso (gratis, M28).
2. Aurora siempre `isla_actual` carga → sin esperas; contenido asegurado.

## 3. Contratos API GDScript

```gdscript
# island_definition.gd (Resource)
class_name IslandDefinition
extends Resource

@export var id: StringName
@export var nombre_display: String
@export var bioma_base: int            # id bioma M09
@export var biomas_mezcla: Array[int]  # proporción implícita por orden
@export var radio: int = 160           # metros voxel (losa 1 m)
@export var altura_min: int = 10
@export var altura_max: int = 96
@export var playa_ancho: int = 8
var ancla: Vector3i                    # puesta por M10 al generar
var semilla_isla: int                  # PRNG derivado (M10)
@export var clima_tendencia: int       # id M32
@export var musica_theme: StringName   # id M41
@export var recursos_exclusivos: PackedStringArray
@export var flora_endemica: PackedStringArray
@export var fauna_endemica: PackedStringArray
@export var puzzles: PackedStringArray
@export var npc_residentes: PackedStringArray
@export var punto_llegada: Vector3i    # local
@export var punto_partida: Vector3i    # local
@export var anillo: int                # IslandRing.NUCLEO..LEJANO
@export var es_secreta: bool = false
@export var es_flotante: bool = false
var desbloqueo: Callable               # evaluada por M28/M22

func bounds_locales() -> Rect2i:
    return Rect2i(Vector2i(-radio, -radio), Vector2i(radio * 2, radio * 2))

func centro_mundo() -> Vector3:
    return Vector3(ancla.x * 1.0, (altura_min + altura_max) * 0.5, ancla.z * 1.0)
```

```gdscript
# island_registry.gd (autoload)
func init(anclas: Dictionary) -> void
func get_isla(id: StringName) -> IslandDefinition
func todas_las_islas() -> Array[IslandDefinition]
func isla_principal() -> IslandDefinition
func posicion_ancla(id: StringName) -> Vector3i
func vecinas(id: StringName, corte_anillo: int = -1) -> Array[IslandDefinition]
func validar_anclas() -> Array[String]
func coordenadas_por_isla(id: StringName) -> Rect2i

signal archipielago_cargado
```

```gdscript
# island_loading.gd (servicio)
func cargar_isla(id: StringName, preferencia: int = IslandPref.PRELOAD) -> bool
func descargar_isla(id: StringName) -> void
func isla_actual() -> StringName
func cacheado(id: StringName) -> bool
func punto_de_llegada(id: StringName) -> Vector3
func punto_de_partida(id: StringName) -> Vector3

signal isla_cargando(id: StringName, progreso: float, etapa: String)
signal isla_cargada(id: StringName)
signal isla_descargada(id: StringName)
```

```gdscript
# island_props.gd (servicio)
func registrar_spawner(tipo: StringName, callable: Callable) -> void
func materializar(isla: IslandDefinition, zona: int) -> void
func pois_isla(id: StringName) -> Array
func limpiar(id: StringName) -> void
```

## 4. Integración con otros módulos

| Módulo | Relación |
|---|---|
| M08 (Mundo Voxel) | Tamaño de losa global = archipiélago dentro de `world_size` máximo; islas como "islas de terreno" generadas por Voxel Tools; agua de mar como bloque especial |
| M09 (Terreno/Geografía) | Bioma base + mezcla por isla; playas, acantilados y costas por recetas de formaciones de M09 |
| M10 (Generación del Mundo) | Capa de anclas posiciona islas; semilla dev; regen 80/0 recalcula anclas; estructuras ancladas respetan islas |
| M28 (Viajes) | Constructo de ruta por ancla; pantalla de viaje con progreso real; barco zarpa del muelle (`punto_partida`); llega a `punto_llegada` |
| M29 (Tiempo y Calendario) | Viajes estacionales (solo en ciertos días festivos); ninguna isla bloqueada permanentemente (anti-FOMO) |
| M32 (Clima) | Clima por isla (cada satélite tiene microclima); lluvia/nieve según tendencia |
| M51 (Agua) | Océano navegable entre islas; nivel de mar global M51; profundidades; espuma de costas |
| M54 (Mapa) | Marca islas descubiertas/visitadas; islas secretas ocultas hasta descubrimiento |
| M59 (Guardado) | `islas_descubiertas`, `islas_visitadas` en GameState versionado |
| M61/M62 (Rendimiento/Memoria) | Presupuesto: máx 2 islas completas en memoria; LRU; prefetch |
| M63 (Cargas y Streaming) | Streaming de islas: progreso por pesos, precarga de vecina al cruzar borde, descarga LRU |
| M64 (IA de NPC) | NPCs residentes se instancian solo si su isla está cargada; receta ligera fuera de isla |

## 5. Catálogo inicial de islas (sección 26)

| Isla | Anillo | Bioma base M09 | Contenido exclusivo |
|---|---|---|---|
| Aurora (principal) | NUCLEO | Templado/Verde | Hogar, puerto central |
| Isla de Coral | CERCANO | Costero/Coral | Fauna marina, buceo M34, conchas |
| Isla Verde | CERCANO | Bosque tropical | Árboles únicos, flora rara |
| Isla de las Cenizas | MEDIO | Volcánico | Minerales, plantas de fuego |
| Islas del Cielo | LEJANO | Flotante/Alpino | Recursos aéreos, vista |
| Isla de Nieve | LEJANO | Nieve | Flora de clima frío, expedición |
| Isla del Desierto | MEDIO | Desierto | Arena única, cactus |
| Isla Volcánica | LEJANO | Volcánico activo | Recompensa de expedición M28 |
| Isla Submarina | LEJANO | Subacuático | Buceo profundo, coleccionables M36 |
| Isla Flotante | MEDIO | Flotante | Juego de plataformas cozi |
| Isla Misteriosa | LEJANO | Mixto | Puzzle narrativo M23 |
| Isla Pequeña | CERCANO | Costero | Miniescapada rápida |
| Isla Secreta | LEJANO | Mixto | Se descubre por pistas (es_secreta) |

## 6. Puerto y puntos de llegada (contrato con M28)

- Cada isla define `punto_llegada` y `punto_partida` (vecinos del muelle).
- El muelle se construye por M17/M40 (infraestructura) siguiendo la definición de M27.
- Al desembarcar, el jugador aparece sobre el muelle mirando a tierra; suena música de la isla (M41).