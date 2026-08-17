**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 27: Islas del Mundo

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/mundo/islas/island_definition.gd` | Resource | Datos inmutables de una isla (biomas, anclas, contenido exclusivo, puntos de llegada) |
| `res://src/mundo/islas/island_registry.gd` | Autoload/servicio | Catálogo del archipiélago, anclas M10, validación, vecinas |
| `res://src/mundo/islas/island_loading.gd` | Servicio | Carga/descarga/streaming M63, isla actual, puntos de llegada/partida |
| `res://src/mundo/islas/island_props.gd` | Servicio | Spawn declarativo de contenido exclusivo por isla (M50/M36/M19) |
| `res://data/islas/archipielago.tres` | Data | Definición del archipiélago + referencias a definiciones por isla |
| `res://data/islas/aurora.tres` | Data | Isla principal (NUCLEO, siempre cargada) |
| `res://data/islas/isla_coral.tres` | Data | Isla de Coral (CERCANO) |
| `res://data/islas/isla_verde.tres` | Data | Isla Verde (CERCANO) |
| `res://data/islas/isla_cenizas.tres` | Data | Isla de las Cenizas (MEDIO) |
| `res://data/islas/islas_cielo.tres` | Data | Islas del Cielo (LEJANO, es_flotante) |
| `res://data/islas/isla_nieve.tres` | Data | Isla de Nieve (LEJANO) |
| `res://data/islas/isla_desierto.tres` | Data | Isla del Desierto (MEDIO) |
| `res://data/islas/isla_volcanica.tres` | Data | Isla Volcánica (LEJANO) |
| `res://data/islas/isla_submarina.tres` | Data | Isla Submarina (LEJANO) |
| `res://data/islas/isla_flotante.tres` | Data | Isla Flotante (MEDIO, es_flotante) |
| `res://data/islas/isla_misteriosa.tres` | Data | Isla Misteriosa (LEJANO) |
| `res://data/islas/isla_pequena.tres` | Data | Isla Pequeña (CERCANO) |
| `res://data/islas/isla_secreta.tres` | Data | Isla Secreta (LEJANO, es_secreta) |
| `res://tests/unit/test_island_registry.gd` | Test M112 | Tests unitarios del registro y anclas |
| `res://tests/unit/test_island_loading.gd` | Test M112 | Tests de streaming y estados de carga |
| `res://tests/integration/test_isla_viaje.gd` | Test M112 | Test de integración viaje M28 → M27 → M63 |

## 2. Firmas clave

### 2.1 IslandDefinition

```gdscript
class_name IslandDefinition
extends Resource

@export var id: StringName
@export var nombre_display: String
@export var bioma_base: int
@export var biomas_mezcla: Array[int]
@export var radio: int = 160
@export var altura_min: int = 10
@export var altura_max: int = 96
@export var playa_ancho: int = 8
var ancla: Vector3i
var semilla_isla: int
@export var clima_tendencia: int
@export var musica_theme: StringName
@export var recursos_exclusivos: PackedStringArray
@export var flora_endemica: PackedStringArray
@export var fauna_endemica: PackedStringArray
@export var puzzles: PackedStringArray
@export var npc_residentes: PackedStringArray
@export var punto_llegada: Vector3i
@export var punto_partida: Vector3i
@export var anillo: int = IslandRing.CERCANO
@export var es_secreta: bool = false
@export var es_flotante: bool = false
var desbloqueo: Callable

func bounds_locales() -> Rect2i
func centro_mundo() -> Vector3
func validar() -> Array[String]   # errores de definición
```

### 2.2 IslandRegistry

```gdscript
class_name IslandRegistry
extends Node

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

### 2.3 IslandLoading

```gdscript
class_name IslandLoading
extends Node

enum IslandPref { PRELOAD, DESCARGA }

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

### 2.4 IslandProps

```gdscript
class_name IslandProps
extends Node

func registrar_spawner(tipo: StringName, callable: Callable) -> void
func materializar(isla: IslandDefinition, zona: int) -> void
func pois_isla(id: StringName) -> Array
func limpiar(id: StringName) -> void
```

### 2.5 Enums compartidos

```gdscript
enum IslandRing { NUCLEO, CERCANO, MEDIO, LEJANO }
```

## 3. Lógica de carga incremental (M63)

```
IslandLoading.cargar_isla(id):
  1. Si cacheado(id) o isla_actual == id → return true
  2. Solicitar weights a M63: losa 60% / props 25% / audio 10% / navmesh 5%
  3. Emitir isla_cargando(id, 0.0, "losa")
  4. M10 + Voxel Tools generan losa de la isla (offset = ancla)
  5. Emitir isla_cargando(id, 0.60, "props") → IslandProps.materializar
  6. Emitir isla_cargando(id, 0.85, "audio") → tema M41 + ambiente M42
  7. Emitir isla_cargando(id, 0.90, "navmesh") → navmesh M64
  8. Emitir isla_cargando(id, 1.0, "") e isla_cargada(id)
```

```
IslandLoading.descargar_isla(id):
  1. Si id == isla_principal().id → ignorar (nunca descargar Aurora)
  2. Si id == isla_actual() → ignorar (nunca descargar isla actual)
  3. Esperar fin de animaciones de props críticas (M44) si aplica
  4. IslandProps.limpiar(id) → M63 libera chunks/audio/navmesh
  5. Emitir isla_descargada(id)
```

## 4. Suscripciones e integración

- M10 generación: su señal `mundo_generado(anclas)` → `IslandRegistry.init(anclas)`.
- M28 viaje: `viaje_aprobado(origen, destino)` → `IslandLoading.cargar_isla(destino)`; `desembarco(destino)` → `isla_actual = destino`, registrar visita en M59/M54.
- M63 streaming: `borde_de_chunk_entrada(id)` → precarga de `vecinas`; `presion_memoria()` → LRU descarga de candidatas.
- M59 guardado: `islas_descubiertas` / `islas_visitadas` (PackedStringArray) en GameState.
- M54 mapa: `isla_descubierta(id)` / `isla_visitada(id)` para pintado de marcadores; secretas ocultas.
- M29: viajes estacionales preguntan al calendario; nunca bloquea regreso.
- M22/M26: sellos pueden desbloquear islas lejanas (`desbloqueo` Callable).

## 5. Logs (nivel y mensajes)

| Nivel | Mensaje |
|---|---|
| INFO | `[Islands] Registry cargado: 13 islas (Aurora + 12 satelites)` |
| INFO | `[Islands] Isla coral cargada (progreso 100%)` |
| INFO | `[Islands] Isla coral descargada (LRU)` |
| WARN | `[Islands] Ancla invalida: solapamiento coral/cenizas (d=92 < min=112)` |
| WARN | `[Islands] Carga de isla nieve dentro de travesia, esperando llegada` |
| ERROR | `[Islands] Isla secreta sin ancla en M10` |
| ERROR | `[Islands] Fallo streaming de isla cielo (sin disco/red)` |
| DEBUG | `[Islands] Vecinas de aurora por anillo: [coral, verde, pequena]` |
| DEBUG | `[Islands] props de isla desierto: 3 flora, 2 fauna, 1 POI` |

## 6. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| IslandRegistry + validación de anclas | Requiere M10 (capa de anclas) y M08 (losa global) |
| IslandLoading + streaming | Requiere M63 (pesos/LRU) y presupuestos M61 |
| IslandProps + spawner | Requiere contratos M50/M36/M19/M23/M24 |
| 13 definiciones `.tres` + archipiélago | Datos editables desde hoy; anclas las llena M10 |
| Puertos (M28) y navegación oceánica (M51) | Integración con barco y agua |
| Tests M112 + QA M114 | Determinismo, streaming, regen 80/0 |

## 7. Nombres y constantes

```gdscript
const ISLA_PRINCIPAL_ID := &"aurora"
const OCEANO_ALTURA := -4          # nivel de mar voxel (M51)
const MARGEN_MAR_ENTRE_ISLAS := 64 # metros mínimos de agua entre playas
const RADIO_PRECARGA_M63 := 96     # chunks de margen al precargar vecina
```

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Estado:** Documentación de diseño completa (módulo delegable; bloqueado por M10/M63/M61)

### Lo que hice
- Definí el archipiélago en mundo voxel continuo con océano navegable (M51) y streaming M63.
- IslandDefinition / IslandRegistry / IslandLoading / IslandProps con contratos GDScript.
- Catálogo 1+12 islas de la sección 26 con biomas de M09 y contenido exclusivo.
- Validación de anclas y reglas de no-solapamiento.

### Lo que NO hice (honestidad obligatoria)
- Implementación: requiere M08/M10 (anclas), M63 (streaming), M61 (presupuestos) y M28 (barco).
- No definí físicas del barco ni del agua: son M28/M51/M67.

### Recomendaciones para el próximo agente
- Implementar primero Registry + definiciones `.tres` (datos) y las pruebas de `validar_anclas`.
- Probar streaming con isla lejana y regreso a Aurora sin pérdida de frames (M61).
- Validar que el motivo "cargar isla vecina al cruzar borde" nunca bloquee la navegación (precarga).