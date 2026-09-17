**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 04-Codigo.md — Módulo 27: Islas del Mundo

> **Iter. 1 (2026-09-11)** — implementado por **DeepSeek-V4.1-Flash / WorkBuddy**.
> El módulo tenía diseño completo pero **cero código** salvo un schema JSON de 4
> islas (`islas_schema.gd` + `data/islas/islas.json`, iter. 1–2 del dueño
> anterior `deepseek-v4-flash-vision-exp`). Esta iteración implementa el núcleo
> data-driven del archipiélago 1 + 12.
>
> **Iter. 2 (2026-09-15)** — **DeepSeek-V4.1-Flash / WorkBuddy**, Log 912.
> Cierra los **16 `[ ]` propios** que quedaban: los **9 edge cases (K)** y el
> **catálogo de los 26 puntos de la sección 26 (A)**. La iter. 1 dejó K y A sin
> tocar; esta iteración los implementa como **lógica pura headless** (sin
> geometría propia, sin `IslandLoading`, que sigue siendo de M63).

## 1. Archivos reales

| Archivo | Tipo | Rol |
|---|---|---|
| `res://scripts/islas/island_ring.gd` | RefCounted | Enum de anillos + radios de vecindad/distancia máxima |
| `res://scripts/islas/island_definition.gd` | Resource | Datos inmutables de una isla (losa, biomas, contenido, puertos) + catálogo de biomas M09 |
| `res://scripts/islas/archipielago.gd` | Resource | Índice del archipiélago: qué islas DEBEN existir (detección de faltantes) |
| `res://scripts/islas/island_registry.gd` | **Autoload `IslandRegistry`** | Catálogo, ids únicos, orden determinista, anclas (M10), validación, descubrimiento, persistencia |
| `res://scripts/islas/island_props.gd` | RefCounted | Spawn declarativo del contenido exclusivo (spawners registrados por M50/M36/M15/M64) |
| `res://scripts/islas/island_ops.gd` | RefCounted | **(iter. 2)** Cola de operaciones de isla: prioridad, etapas 60/25/10/5, idempotencia, cancelación |
| `res://scripts/islas/island_travel_guard.gd` | RefCounted | **(iter. 2)** Guardia de viaje: los 9 edge cases K1–K9 como lógica pura |
| `res://scripts/islas/island_design_catalog.gd` | RefCounted (todo `static`) | **(iter. 2)** Catálogo de los 26 puntos reales de la §26 del plan maestro |
| `res://scripts/islas/test_islas_m27_iter2.gd` | `SceneTree` | **(iter. 2)** Suite headless de la iter. 2 (238 checks, bloques A–H) |
| `res://scripts/islas/generar_islas.gd` | SceneTree | **Generador** del dataset (13 `.tres` + índice). No se edita a mano |
| `res://scripts/islas/test_islas_m27.gd` | SceneTree | Test headless: **171 checks / 0 fallos** |
| `res://data/islas/definiciones/<id>.tres` | Data | **13 definiciones** (aurora + 12 satélites) |
| `res://data/islas/archipielago.tres` | Data | Índice: 13 ids esperados, `id_principal = aurora` |
| `res://data/islas/islas.json` | Data (legacy) | Config de 4 islas del dueño anterior — **se conserva**, no se rompe |
| `res://scripts/islas/islas_schema.gd` | RefCounted (legacy) | Validador del JSON legacy — **se conserva** |
| `res://scripts/islas/sincronizar_islas_mapa.gd` | SceneTree (legacy) | Verificador islas ↔ mapa — **sigue verde** |
| `res://scripts/islas/test_islas_headless.gd` | SceneTree (legacy) | Test del schema legacy — **5/0** |

## 2. Firmas clave (reales)

### 2.1 IslandRing

```gdscript
class_name IslandRing
extends RefCounted

enum { NUCLEO, CERCANO, MEDIO, LEJANO }   # anónimo: se usa IslandRing.CERCANO

const NOMBRES: Array[String] = ["NUCLEO", "CERCANO", "MEDIO", "LEJANO"]
const RADIO_VECINDAD: Array[int] = [0, 2200, 4400, 6400]      # streaming por anillo (m)
const REQUIERE_PROGRESO: Array[bool] = [false, false, true, true]

static func nombre(valor: int) -> String
static func desde_nombre(texto: String) -> int      # -1 si no existe
static func es_valido(valor: int) -> bool
static func radio_vecindad(valor: int) -> int
static func distancia_max_anillo(valor: int) -> int # 0 / 1600 / 3200 / 6400
```

### 2.2 IslandDefinition

```gdscript
class_name IslandDefinition
extends Resource

const BIOMAS: Array[String] = ["Costa","Pradera","Bosque","Humedal","Valle",
    "Montaña","Cumbre","Desierto","Nevado","Volcánico","Tropical","Ruinas","Resonancia"]

@export var id: StringName
@export var nombre_clave: String            # M87: "M27.ISLA.<ID>.NOMBRE"
@export var nombre_display: String          # fallback ES
@export_multiline var descripcion: String   # lore M55
@export var radio: int = 160
@export var altura_min: int = 10
@export var altura_max: int = 96
@export var playa_ancho: int = 8
@export var bioma_base: int = 0             # índice de BIOMAS
@export var biomas_mezcla: Array[int] = []
@export var proporciones_mezcla: Array[float] = []
@export var clima_tendencia: int = 0        # id M32
@export var musica_clave: StringName = &""  # id M41
@export var recursos_exclusivos: PackedStringArray
@export var flora_endemica: PackedStringArray
@export var fauna_endemica: PackedStringArray
@export var puzzles: PackedStringArray
@export var npc_residentes: PackedStringArray
@export var punto_llegada: Vector3i = Vector3i.ZERO   # local al ancla
@export var punto_partida: Vector3i = Vector3i.ZERO
@export var anillo: int = IslandRing.CERCANO
@export var es_secreta: bool = false
@export var es_flotante: bool = false
@export var desbloqueo_flag: StringName = &""   # M22 (ver §6 desviaciones)
@export var orden_anillo: int = 0

# RUNTIME — NO serializado; lo puebla M10
var ancla: Vector3i = Vector3i.ZERO
var semilla_isla: int = 0
var ancla_asignada: bool = false

static func bioma_nombre(indice: int) -> String
func bioma_base_nombre() -> String
func bounds_locales() -> Rect2i      # world-relative (incluye el ancla)
func centro_mundo() -> Vector3
func punto_llegada_mundo() -> Vector3
func punto_partida_mundo() -> Vector3
func distancia_a(otro: IslandDefinition) -> float
func anillo_nombre() -> String
func validar() -> Array[String]      # vacío = válida
func es_valida() -> bool
func huella() -> String              # huella determinista para CI
func a_diccionario() -> Dictionary
```

**Reglas de `validar()`** (todas verificadas en el test): id no vacío · nombre
(display o clave) · `radio > 0` · `altura_min >= 0` · `altura_max > altura_min` ·
`playa_ancho >= 0` y `playa_ancho*2 < radio` · `bioma_base` dentro de `BIOMAS` ·
`biomas_mezcla` y `proporciones_mezcla` alineados y sumando ≈1.0 (±0.05) ·
`anillo` válido · NÚCLEO no puede ser secreta · isla flotante con
`punto_llegada.y > altura_max` · puertos dentro del disco `radio - playa_ancho`.

### 2.3 Archipielago

```gdscript
class_name Archipielago
extends Resource

@export var version: int = 1
@export var islas_esperadas: PackedStringArray   # Aurora primera
@export var id_principal: StringName = &"aurora"

func comparar(encontradas: Array) -> Dictionary  # {faltantes, extra, ok}
func contar_esperadas() -> int
```

### 2.4 IslandRegistry (autoload, SIN `class_name`)

```gdscript
extends Node     # autoload "IslandRegistry" en project.godot

signal archipielago_cargado(cantidad: int)
signal anclas_validadas(errores: Array)
signal isla_descubierta(id: StringName)

const ISLA_PRINCIPAL_ID := &"aurora"
const RUTA_DEFINICIONES := "res://data/islas/definiciones"
const RUTA_ARCHIPIELAGO := "res://data/islas/archipielago.tres"
const MARGEN_MAR_ENTRE_ISLAS := 64
const SECCION_GUARDADO := "islas"

# Carga
func cargar_definiciones() -> Dictionary   # {ok, cargadas, esperadas, faltantes, extra, duplicados, errores}
# Consultas
func get_isla(id: StringName) -> IslandDefinition        # null + WARN si no existe
func tiene_isla(id: StringName) -> bool
func todas_las_islas() -> Array[IslandDefinition]        # orden determinista por id
func isla_principal() -> IslandDefinition
func ids() -> Array[StringName]
func contar() -> int
func errores_carga() -> Array[String]
func duplicados() -> Array[String]
func esta_cargado() -> bool
# Anclas (M10)
func anclar(id: StringName, ancla: Vector3i, semilla_isla: int) -> bool
func posicion_ancla(id: StringName) -> Vector3i           # con cache
func tiene_ancla(id: StringName) -> bool
static func semilla_de_isla(semilla_partida: int, id: StringName) -> int
func coordenadas_por_isla(id: StringName) -> Rect2i
func vecinas(id: StringName, corte_anillo: int = -1) -> Array[IslandDefinition]
func validar_anclas() -> Array[String]
func anclas_validas() -> bool
# Descubrimiento / visita (M54 + M59)
func esta_descubierta(id: StringName) -> bool
func esta_visitada(id: StringName) -> bool
func descubrir(id: StringName) -> bool                    # true sólo la 1ª vez
func visitar(id: StringName) -> bool
func visible_en_mapa(id: StringName) -> bool              # secretas ocultas
func islas_descubiertas() -> Array[String]
func islas_visitadas() -> Array[String]
func esta_desbloqueada(id: StringName) -> bool            # M22 vía WorldState.has_flag
# ISaveProvider (M59)
func get_section_name() -> String      # "islas"
func get_save_data() -> Dictionary     # {descubiertas, visitadas} — copias, nunca referencias
func restore_save_data(datos: Dictionary) -> void
# Hooks de test
func _test_limpiar() -> void
func _test_definir(def: IslandDefinition) -> bool
func _test_rutas(defs: String, arch: String) -> void      # apunta la carga a rutas temporales
```

### 2.5 IslandProps

```gdscript
class_name IslandProps
extends RefCounted

const TIPO_FLORA := &"flora"
const TIPO_FAUNA := &"fauna"
const TIPO_RECURSO := &"recurso"
const TIPO_POI := &"poi"
const TIPOS: Array[StringName] = [TIPO_POI, TIPO_FLORA, TIPO_FAUNA, TIPO_RECURSO]

func registrar_spawner(tipo: StringName, callable: Callable) -> bool
func tiene_spawner(tipo: StringName) -> bool
func tipos_registrados() -> Array[StringName]
func semilla_props(isla: IslandDefinition) -> int
func materializar(isla: IslandDefinition, zona: int = -1) -> Dictionary
func conteo_props(id: StringName) -> Dictionary
func esta_materializada(id: StringName) -> bool
func informe(id: StringName) -> Dictionary
func limpiar(id: StringName) -> bool
func limpiar_todo() -> void
```

**Contrato del spawner:** `Callable(isla: IslandDefinition, ctx: Dictionary) -> Variant`.
`ctx` = `{items, bounds, centro, zona, semilla_zona, es_flotante, playa_ancho}`.
El spawner devuelve `{"spawneados": int}` o un `int`; M27 sólo contabiliza.

### 2.6 IslandOps (iter. 2) — cola de operaciones de isla

Lógica pura, sin nodos ni `await`: la consumen M63 (streaming) y M28 (barco).
**Sólo una operación en curso a la vez** — es lo que impide que un viaje se pise
con una descarga.

```gdscript
class_name IslandOps extends RefCounted

const TIPO_CARGA / TIPO_DESCARGA / TIPO_PRECARGA : StringName
const EST_PENDIENTE / EN_CURSO / HECHA / CANCELADA / FALLIDA : StringName
const ETAPAS: Array[String] = ["losa", "props", "audio", "navmesh"]
const PESOS: Array[float]  = [0.60, 0.25, 0.10, 0.05]     # suman 1.0
const PRIORIDAD_VIAJE = 0 / CARGA = 1 / DESCARGA = 2 / PRECARGA = 3
const MAX_OPS_POR_FRAME: int = 1                          # nunca congela

static func suma_pesos() -> float
static func progreso_hasta(indice: int) -> float          # -1 → 0.0
static func etapa_nombre(indice: int) -> String           # fuera de rango → ""

func encolar(tipo, isla_id, prioridad := -1) -> int       # IDEMPOTENTE: devuelve el id existente
func iniciar() -> int                                     # 0 si no hay nada que arrancar
func avanzar_etapa() -> Dictionary                        # cierra sola al pasar la 4ª
func completar_actual() / fallar(motivo := "") -> ...
func cancelar(op_id) -> bool / cancelar_por_isla(isla_id) -> int
func pendientes() / vivas() / historial() -> Array[Dictionary]   # COPIAS, nunca referencias
func estado(id) / info(id) / progreso() / en_curso_id() / esta_ocupada()
func islas_con_ops_vivas() / islas_con_tipo(tipo) / primera_de_tipo(tipo)
func validar() -> Array[String] / informe() / resumen()
```

### 2.7 IslandTravelGuard (iter. 2) — los 9 edge cases

```gdscript
class_name IslandTravelGuard extends RefCounted

const ID_PRINCIPAL = "aurora" / RADIO_SEGURIDAD_M = 1200.0
const MARGEN_BORDE_M = 256.0 / TOPE_MEMORIA_MB = 2048.0
const COSTE_MB_POR_ISLA = 320.0 / MAX_ISLAS_EN_MEMORIA = 2

func configurar(vista: Dictionary, opciones := {}) -> void
static func vista_desde_registry(reg: Node) -> Dictionary        # duck-typing
static func registro_desde_definicion(id, d: IslandDefinition) -> Dictionary
func sincronizar_estado_partida(reg: Node) -> int                # M59 → vista

func debe_precargar(pos, isla_actual, presupuesto := -1) -> Array[String]   # K1
func coste_por_frame() -> Dictionary                                        # K1
func estado_destino(destino) -> Dictionary                                  # K4
func evaluar_viaje(destino, isla_actual, ops) -> Dictionary                 # K2
func evaluar_naufrago(pos, en_barco := false) -> Dictionary                 # K3
func respawn_cozy(pos) -> Dictionary                                        # K8
func punto_seguro(destino, pos_deseada) -> Dictionary                       # K5
func cancelar_viaje(destino, ops) -> Dictionary                             # K6
func evaluar_guardado(ops) -> Dictionary                                    # K7
func descarga_forzada(memoria_mb, ops, isla_actual, tope_mb := -1.0)        # K9
func snapshot_estado() / islas_cargadas() / isla_en / mas_cercana
func es_tierra_firme / es_agua / es_playa
func validar() -> Array[String] / informe() / resumen()
```

**Reglas que codifica (todas verificadas por test):**

| Regla | Dónde | Por qué |
|---|---|---|
| 1 operación por frame, margen de borde declarado | K1 | precargar al navegar el borde no puede congelar |
| El destino NO se toca si se está descargando: se encola | K2 | cargar y descargar la misma isla a la vez es una carrera |
| Isla secreta sin descubrir → `secreta_no_descubierta` | K4 | requisitos 119/132: una isla oculta no es viajable |
| Sin ancla → `ancla_pendiente` con `espera_coherente: true` | K4 | M10 puede no haber anclado aún: **esperar**, no bloquear |
| `punto_seguro` proyecta al interior del disco (`radio - playa - 1`) | K5 | el borde exacto cae fuera del disco por redondeo float |
| `limpio` es **por destino** | K6 | cancelar coral no debe declarar libre la cola de verde |
| Guardar con cola → `esperar: true`, nunca `puede_guardar` | K7 | un guardado a medias pierde estado |
| Nunca descarga la isla principal ni la actual | K9 | anti-softlock cozy |
| Descargar sólo toca `cargada`; el estado de partida es de M59 | K9 | descargar no puede perder descubrimiento/visitas |

### 2.8 IslandDesignCatalog (iter. 2) — los 26 puntos de la §26

Todo `static`. **26** puntos reales (el checklist decía 24: el plan tiene 26).

```gdscript
class_name IslandDesignCatalog   # TOTAL_PLAN := 26, RUTA_PLAN = Plan-inicial-minimo.md
const LINEA_INICIO_PLAN = 796 / LINEA_FIN_PLAN = 821
const GRUPO_ISLAS / GRUPO_RUTAS / GRUPO_ATRIBUTOS
const EST_RESUELTO / EST_DECLARATIVO / EST_EXTERNO

static func puntos() / contar() / punto(n) -> Dictionary
static func por_estado(estado) / por_grupo(grupo) -> Array[Dictionary]
static func resoluciones(p) -> Array[String]     # "dataset:<id>" | "campo:<nombre>" | "externo:M##"
static func cobertura() -> Dictionary            # 26 total / 15 resueltos / 7 declarativos / 4 externos
static func claves_localizacion() -> Array[String]   # M27.DISENO.P01..P26
static func validar(defs) / campos_faltantes(defs) / islas_faltantes(defs) -> Array[String]
static func informe(defs) / resumen() -> Dictionary
```

`validar()` **falla si el plan deja de tener 26 puntos**: el catálogo no acepta
en silencio un plan distinto al que codifica, y `informe()` expone el desajuste
(`plan_dice` vs `plan_tiene`).


## 3. Dataset — 13 islas (diseño §5 / sección 26)

| id | Nombre | Anillo | radio | alt min–max | playa | bioma base | flotante | secreta | flag desbloqueo |
|---|---|---|---|---|---|---|---|---|---|
| `aurora` | Isla Aurora | NUCLEO | 256 | 0–140 | 10 | Bosque | — | — | — |
| `coral` | Isla de Coral | CERCANO | 200 | 0–40 | 12 | Tropical | — | — | — |
| `verde` | Isla Verde | CERCANO | 190 | 0–70 | 10 | Tropical | — | — | — |
| `pequena` | Isla Pequeña | CERCANO | 96 | 0–30 | 10 | Costa | — | — | — |
| `cenizas` | Isla de las Cenizas | MEDIO | 200 | 0–120 | 8 | Volcánico | — | — | `progreso_medio` |
| `desierto` | Isla del Desierto | MEDIO | 180 | 0–50 | 14 | Desierto | — | — | `progreso_medio` |
| `flotante` | Isla Flotante | MEDIO | 140 | 40–90 | 6 | Pradera | ✔ | — | `progreso_medio` |
| `cielo` | Islas del Cielo | LEJANO | 160 | 60–130 | 6 | Cumbre | ✔ | — | `progreso_lejano` |
| `nieve` | Isla de Nieve | LEJANO | 190 | 0–130 | 10 | Nevado | — | — | `progreso_lejano` |
| `volcanica` | Isla Volcánica | LEJANO | 210 | 0–150 | 8 | Volcánico | — | — | `progreso_lejano` |
| `submarina` | Isla Submarina | LEJANO | 170 | 0–20 | 16 | Costa | — | — | `progreso_lejano` |
| `misteriosa` | Isla Misteriosa | LEJANO | 200 | 0–110 | 8 | Ruinas | — | — | `progreso_lejano` |
| `secreta` | Isla Secreta | LEJANO | 150 | 0–80 | 8 | Resonancia | — | ✔ | `pista_secreta` |

Cada isla lleva además: `nombre_clave` (`M27.ISLA.<ID>.NOMBRE`), `descripcion`
(lore M55), `clima_tendencia`, `musica_clave`, y las 5 listas de contenido
exclusivo (`recursos_exclusivos`, `flora_endemica`, `fauna_endemica`, `puzzles`,
`npc_residentes`). Los ids de contenido son **declarativos** y provisionales: los
dueños reales son M15/M50/M36/M23-M24/M19; si un id no existe, el spawner
correspondiente simplemente no spawnea (no rompe).

### 3.1 Disposición de anclas de referencia (NO serializada)

Las anclas las pone **M10** en runtime. Para poder validar geometría sin M10, el
generador documenta y el test reproduce esta disposición:

| Anillo | Radio al centro | Islas |
|---|---|---|
| NUCLEO | 0 | aurora |
| CERCANO | 1100 m | coral (90°), verde (210°), pequena (330°) |
| MEDIO | 2400 m | cenizas (30°), desierto (150°), flotante (270°) |
| LEJANO | 4400 m | cielo (0°), nieve (60°), volcanica (120°), submarina (180°), misteriosa (240°), secreta (300°) |

Cumple `distancia_min = radio_a + radio_b + 64` en todos los pares y
`distancia <= distancia_max_anillo(anillo)` para cada isla. El test verifica
ambas cosas y además que `validar_anclas()` detecte las violaciones cuando se
introducen a propósito.

## 4. Integración con otros módulos

| Módulo | Contrato real |
|---|---|
| M10 (Generación) | Llama `IslandRegistry.anclar(id, ancla, semilla)` por isla; `semilla_de_isla(semilla_partida, id)` deriva la semilla. Sin ancla, `IslandProps.materializar()` se **niega** a spawnear |
| M63 (Streaming) | `coordenadas_por_isla(id) -> Rect2i` (bounds XZ world-relative) y `vecinas(id, corte_anillo)` |
| M28 (Viajes) | `posicion_ancla(destino)`, `punto_llegada_mundo()`, `punto_partida_mundo()`, `esta_desbloqueada(id)` |
| M54 (Mapa) | `visible_en_mapa(id)` (secretas ocultas), `esta_descubierta/visitada`, señal `isla_descubierta` |
| M59 (Guardado) | ISaveProvider sección `"islas"` → `{descubiertas, visitadas}` |
| M22 (Historia) | `desbloqueo_flag` evaluado contra `WorldState.has_flag()` |
| M09 (Terreno) | `bioma_base` = índice de `IslandDefinition.BIOMAS` (ver §6) |
| M32 (Clima) | `clima_tendencia` (id de M32) |
| M41 (Música) | `musica_clave` |
| M50/M36/M15/M64 | Se registran como spawners vía `IslandProps.registrar_spawner()` |
| M87 (Localización) | `nombre_clave`; `nombre_display` es el fallback ES |

## 5. Logs reales

| Nivel | Mensaje |
|---|---|
| INFO | `[Islands] Registry cargado: 13 islas (principal: OK)` |
| ERROR | `[Islands] no existe la carpeta de definiciones: <ruta>` |
| ERROR | `[Islands] FALTA la isla principal (aurora): el archipiélago es inválido` |
| ERROR | `[Islands] .tres faltante: <id> (definido en archipielago.tres)` |
| ERROR | `[Islands] id duplicado en .tres: <id> (se conserva el primero)` |
| ERROR | `[Islands] definición ilegible: <ruta>` |
| WARN | `[Islands] isla desconocida: <id>` |
| WARN | `[Islands] isla <id> sin ancla en M10` |
| WARN | `[Islands] tipo de spawner desconocido: <tipo>` |

## 6. Desviaciones del diseño (documentadas)

1. **`desbloqueo: Callable` → `desbloqueo_flag: StringName`.** Un `Callable` no
   es serializable en `.tres`; una flag de `WorldState` (M22) es equivalente y
   editable por datos.
2. **`class_name IslandRegistry` → autoload sin `class_name`** (convención del
   proyecto: los autoloads no llevan `class_name`). `IslandRing` vive en su
   propio archivo para que M28/M54/M63 lo usen sin arrastrar `IslandDefinition`.
3. **`musica_theme` → `musica_clave`** (coherencia con `nombre_clave` de M87).
4. **`IslandProps extends Node` → `RefCounted`.** Es un registro de spawners sin
   estado de escena; el registro se inyecta desde quien materializa. Evita un
   autoload más.
5. **`init(anclas: Dictionary)` → `anclar()` por isla.** M10 genera las anclas de
   a una; un `init` monolítico obligaba a M10 a construir un diccionario
   completo antes de emitir nada.
6. **`bounds_locales()` devuelve bounds WORLD-relative** (incluye el ancla), no
   centrados en el origen. El diseño los describía centrados en 0, pero M63 los
   consume como `Rect2i` absolutos; devolverlos centrados obligaba a cada
   consumidor a sumar el ancla.
7. **`bioma_base: int` con catálogo propio.** M09 documenta 13 biomas por nombre
   pero **no expone ids numéricos**. M27 fija el mapeo en
   `IslandDefinition.BIOMAS` (mismo orden que el catálogo de M09) y lo expone con
   `bioma_nombre()`. Si M09 publica ids propios, hay que alinear y bumpear el
   schema del dataset.
8. **`es_flotante` con `altura_min > 0`** para las islas del cielo/flotante: la
   losa "flota" a 40–60 m. `altura_min < 0` se rechaza por validación; la
   profundidad submarina es responsabilidad de M51, no de la losa.

## 7. Pendientes reales (honestidad)

| Pendiente | Dueño | Motivo |
|---|---|---|
| **`IslandLoading`** (carga/descarga/streaming, pesos 60/25/10/5, LRU) | M63 + M61 | Requiere el sistema de streaming y presupuesto de memoria. M27 ya expone `coordenadas_por_isla` y `vecinas` |
| Capa de anclas real de M10 | M10 | M27 consume `anclar()`; hoy sólo hay la disposición de referencia del test |
| Puertos/muelles físicos | M17/M40 | M27 define `punto_llegada`/`punto_partida`; la geometría es de infraestructura |
| Ids reales de contenido (flora/fauna/recursos/puzzles/NPC) | M50/M36/M15/M23/M19 | Los `.tres` declaran ids provisionales; hay que reconciliarlos cuando esos módulos publiquen catálogo |
| Re-roll de ancla con misma semilla (máx 8 intentos) | M10 | M27 **detecta** el solapamiento (`validar_anclas`); re-rollear es de M10 |
| Migrar el JSON legacy a las 13 definiciones | M54 | `islas.json` (4 islas) sigue alimentando el mapa; hay que migrar M54 al nuevo catálogo |
| `IslandProps` no pasa `ancla` al spawner | — | El `ctx` pasa `bounds`/`centro`; si un spawner necesita el ancla cruda, hay que añadirla |
| **`IslandOps` / `IslandTravelGuard` no los llama nadie todavía** | M63 + M28 | Son lógica pura: M63 debe consumir la cola en su `_process` y M28 consultar `evaluar_viaje` antes de zarpar. Sin ese cableado no hay efecto en el juego |
| **Asimetría de descubrimiento en M59** | M59 / M54 | `esta_descubierta(&"aurora")` devuelve `true` por definición (`or id == ISLA_PRINCIPAL_ID`) pero `islas_descubiertas()` **no la lista**. Cualquier consumidor que compare ambas fuentes ve un desajuste |
| **Los 4 puntos externos de la §26 siguen sin dueño vivo** | M19 / M23 / M28 | El catálogo los atribuye y `validar()` no falla por ellos, pero nadie los implementa aún |

## 8. Trampas encontradas (reutilizables)

1. **`DirAccess.open("user://…")` devuelve `null` en este entorno**, y
   `ProjectSettings.globalize_path("user://…")` devuelve una ruta **relativa**
   (`./Godot/app_userdata/…`). `ResourceLoader.load()` sí funciona con
   `user://`. Solución: recomponer una ruta absoluta con
   `globalize_path("res://")` + la ruta relativa (helper `_abrir_dir()`).
2. **Godot cachea los `Resource` por ruta**: `ResourceLoader.load()` sobre un
   `.tres` ya cargado devuelve **la misma instancia**, así que las variables de
   script (no exportadas) **sobreviven a un reload**. `cargar_definiciones()`
   debe resetear explícitamente `ancla` / `semilla_isla` / `ancla_asignada`.
3. **Las lambdas de GDScript capturan por VALOR**: para observar desde el test
   lo que un spawner recibe, hay que capturar un `Dictionary`/`Array` (tipo
   referencia), no una variable suelta.
4. **Un autoload no es identificador global en modo `--script`**: el test usa
   `root.get_node_or_null("IslandRegistry")`. Los `class_name` sí lo son (tras
   `--editor --quit`).
5. **`as` liga más flojo que `==`** (iter. 2): `x == ["coral"] as Array[String]`
   se parsea como `(x == ["coral"]) as Array[String]` →
   `Parse Error: Invalid cast. Cannot convert from "bool" to "Array[String]"`.
   Nunca castear el resultado de una comparación. (Y un `Array[String]`
   devuelto por una función compara bien con `== ["coral"]` sin cast.)
6. **El orden de evaluación de los argumentos muerde** (iter. 2):
   `_check("…", ops.iniciar() == ops.pendientes()[0]["id"])` falla aunque el
   código esté bien — `iniciar()` saca la operación de `pendientes()`, así que
   la segunda lectura ya ve **otro** elemento. La esperada se captura ANTES.
7. **Un empate de distancia hace que "la más cercana" dependa del orden de
   iteración** (iter. 2): en la disposición de referencia, `nieve` y
   `volcanica` están exactamente a la misma distancia de (0,0,9000). Los puntos
   de prueba deben ser **inequívocos**, no "el primero que parece".
8. **`get_node_or_null()` no existe en `SceneTree`** (iter. 2): en modo
   `--script` el script **es** el árbol, así que hay que usar
   `root.get_node_or_null(...)`. El error es de parseo
   (`Function "get_node_or_null()" not found in base self`), no de runtime.

## Notas del Agente — iter. 1

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11
**Log:** `Logs/830-M32-Iter2-Auditoria-Consumidores_2026-09-12_03-20-00.md`

### Lo que hice
- Implementé el núcleo data-driven completo: `IslandRing`, `IslandDefinition`
  (con catálogo de biomas M09), `Archipielago`, `IslandRegistry` (autoload),
  `IslandProps`.
- Generé el dataset de **13 islas** con un generador validante
  (`generar_islas.gd`) — nunca a mano.
- Registré `IslandRegistry` como autoload y como ISaveProvider (sección `islas`).
- Escribí `test_islas_m27.gd`: **171 checks / 0 fallos**, estable en 3 corridas.
- Verifiqué regresiones: legacy M27 5/0 · `sincronizar_islas_mapa` OK (4 islas +
  9 POIs) · M60 iter.3 132/0 · M60 base 94/0 · M68 177/0 · auditor de aliasing
  OK(9).
- Documenté 8 desviaciones del diseño y 4 trampas de Godot reutilizables.

### Lo que NO hice (honestidad obligatoria)
- **No implementé `IslandLoading`**: es territorio de M63 (streaming, pesos,
  LRU) y depende de presupuestos M61. El diseño lo listaba en M27, pero su
  implementación real necesita M63 vivo.
- **No hay anclas reales**: sin M10, las islas quedan sin anclar y
  `IslandProps.materializar()` se niega (por diseño). El test usa una
  disposición de referencia documentada.
- **Los ids de contenido exclusivo son provisionales** (inventados con criterio):
  no existen todavía los catálogos de M50/M36/M15/M23/M19 para validarlos.
- **No migré el JSON legacy** ni toqué M54: `islas.json` (4 islas) sigue vivo y
  el mapa sigue leyéndolo. La coexistencia es intencional para no romper M54.
- **No verifiqué visualmente** nada (no soy aprobador visual): el módulo no tiene
  geometría propia todavía.

### Recomendaciones para el próximo agente
1. **M10 → M27**: implementar la capa de anclas y llamar
   `IslandRegistry.anclar()`; después correr `validar_anclas()` y registrar el
   re-roll de 8 intentos.
2. **M63 → M27**: implementar `IslandLoading` sobre `coordenadas_por_isla()` y
   `vecinas()`; los pesos 60/25/10/5 son del diseño y no se tocan.
3. **M54 → M27**: migrar el mapa de `islas.json` (4) al catálogo de 13 y usar
   `visible_en_mapa()` para las secretas.
4. Reconciliar los ids de contenido con los catálogos reales cuando existan.
5. Si M09 publica ids numéricos de bioma, alinear `IslandDefinition.BIOMAS` y
   regenerar el dataset (el generador valida el rango y aborta si no cuadra).

---

## Notas del Agente — iter. 2

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Log:** `Logs/912-Islas-Del-Mundo-Iter2_2026-09-15.md`
**Reserva:** `Logs/reservas/912-DSV41F-M27.txt`

### Alcance real de la iteración

La iter. 1 dejó el checklist en `83 [x]` · `93 [?]` · `16 [ ]`. Los 16 `[ ]`
propios eran **K = 9 edge cases**, **A = 4 requisitos** y **M = 3 documentos**.
Nada de eso requería geometría ni M10: es lógica pura, así que se pudo cerrar
headless. La iter. 2 **no toca `IslandLoading`** (19 ítems `[?]`, dueño M63/M61).

### Lo que hice

- **`IslandOps`** — cola de operaciones de isla: 4 etapas con pesos 60/25/10/5,
  prioridad (viaje > carga > descarga > precarga), **idempotencia por
  (tipo, isla)**, una sola operación en curso, cancelación por id y por isla,
  `validar()`/`informe()`.
- **`IslandTravelGuard`** — los 9 edge cases K1–K9 como lógica pura sobre una
  vista de islas (duck-typing sobre el registry real), más
  `sincronizar_estado_partida()` (M59 → vista) y `snapshot_estado()`.
- **`IslandDesignCatalog`** — los **26** puntos reales de la §26 del plan
  (líneas 796–821), cada uno con su grupo, estado y resolución declarada
  (`dataset:` / `campo:` / `externo:M##`), `claves_localizacion()` para M87 y
  `validar(defs)` que **falla si el plan deja de tener 26 puntos**.
- **`test_islas_m27_iter2.gd`** — 8 bloques (A–H), **238 checks / 0 fallos**,
  estable en 3 corridas, `EXIT 0`, 0 `SCRIPT ERROR`.
- Regresiones: `test_islas_m27.gd` **171/0** · `test_islas_headless.gd` **5/0** ·
  `sincronizar_islas_mapa.gd` OK (4 islas + 9 POIs).

### Dos hallazgos que valen más que el código

1. **La guardia no podía cumplir su propia promesa de K9.** `registro_desde_definicion()`
   fijaba `descubierta`/`visitada` en `false` y `vista_desde_registry()` no leía
   el registry: el estado de partida **no entraba nunca** en la vista, así que
   "descargar sin perder estado" era inverificable. Se corrigió: la vista lo lee
   del registry (duck-typed) y `sincronizar_estado_partida()` lo refresca. El
   test ahora **prueba el camino completo** M59 → guardia.
2. **El checklist decía 24 puntos y el plan tiene 26.** El catálogo codifica los
   26 y `validar()`/`informe()` **exponen el desajuste** (`plan_dice` vs
   `plan_tiene`) en vez de aceptarlo en silencio.

### Lo que NO hice (honestidad obligatoria)

- **No implementé `IslandLoading`**: sigue siendo de M63 (streaming) + M61
  (presupuestos). `IslandOps` es la cola que M63 debe consumir, no el streaming.
- **No cableé nada al juego**: nadie llama todavía a `IslandOps` ni a
  `IslandTravelGuard`. Son lógica pura verificada, sin efecto en runtime hasta
  que M63/M28 las usen. **No es un módulo terminado, es un módulo con la lógica
  de sus edge cases terminada.**
- **No hay anclas reales** (M10 no existe): el test usa la disposición de
  referencia documentada, igual que la iter. 1. Medido: las 13 islas del
  registry real están **sin ancla** y la guardia reporta `ancla_pendiente` sin
  crashear (verificado en el bloque H).
- **No verifiqué visualmente nada** (no soy aprobador visual, §15.3).
- **No toqué M54 ni el JSON legacy**: `islas.json` (4 islas) sigue vivo.

### Recomendaciones para el próximo agente

1. **M63 → M27**: consumir `IslandOps` en el `_process` del streaming
   (`MAX_OPS_POR_FRAME == 1` es deliberado: nunca congelar). Al terminar cada
   etapa, llamar a `avanzar_etapa()` para que la barra de carga avance.
2. **M28 → M27**: consultar `evaluar_viaje()` **antes** de zarpar y
   `cancelar_viaje()` al abortar. El destino en descarga **se encola**, no se
   cancela (cancelar dejaría chunks a medio liberar).
3. **M59/M54 → M27**: resolver la asimetría `esta_descubierta(aurora) == true`
   vs `islas_descubiertas()` que no la lista. Hoy obliga a que la guardia
   sincronice contra el registry y no contra la lista.
4. **M10 → M27**: cuando existan anclas reales, correr
   `IslandTravelGuard.vista_desde_registry()` y `validar()`; el bloque H ya
   prueba que la guardia es válida **con y sin** anclas.
5. **M19/M23/M28 → M27**: los 4 puntos externos de la §26 siguen sin
   implementación; el catálogo los tiene atribuidos y listos para cerrar.
