**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 16: Crafting

## 1. Archivos Involucrados (rutas propuestas)

### 1.1 Scripts (capa de dominio y UI)
```
res://scripts/crafting/crafting_types.gd        # enums y clases ligeras (StationType, RecipeCategory, RecipeSource, CraftError, RecipeMaterial, CraftResult, ExperimentResult)
res://scripts/crafting/crafting_recipe.gd       # class_name CraftingRecipe extends Resource
res://scripts/crafting/crafting_service.gd      # class_name CraftingService extends Node (Autoload "Crafting")
res://scripts/crafting/crafting_station.gd      # class_name CraftingStation extends Node3D (componente de voxel interactuable M11)
res://scripts/crafting/crafting_ui.gd           # class_name CraftingUI extends Control (panel principal)
res://scripts/crafting/crafting_ui_experiment.gd # sub-panel experimentación (opcional, dentro de CraftingUI como Control)
```

### 1.2 Datos (Resources `.tres`)
```
res://resources/crafting/recetas/mesa_trabajo/    # recetas de mesa de trabajo (herramientas, estructura, decoración)
res://resources/crafting/recetas/fogata/          # recetas de fogata (cocina, metalurgia ligera, ancestral)
res://resources/crafting/recetas/telar/           # recetas de telar (textiles, ropa, decoración textil)
res://resources/crafting/recetas_catalog.tres     # (opcional) catálogo agregado si se usa import por lista
res://resources/crafting/items/pergamino_receta_x.tres  # ítems pergamino (cada receta comprable) — datos M14/M38
```

### 1.3 Escenas y prefabs
```
res://scenes/crafting/mesa_trabajo.tscn       # estación voxel + CraftingStation (mesa_trabajo)
res://scenes/crafting/fogata.tscn             # estación voxel + CraftingStation (fogata)
res://scenes/crafting/telar.tscn              # estación voxel + CraftingStation (telar)
res://scenes/crafting/ui/crafting_panel.tscn  # CraftingUI (instanciado en UI raíz, oculto por defecto)
res://scenes/crafting/ui/recipe_row.tscn      # fila de receta reutilizable (lista virtualizada)
```

### 1.4 Configuración
```
res://project.godot                              # Autoload: Crafting = res://scripts/crafting/crafting_service.gd
```

## 2. Funciones Clave (firmas GDScript)

### 2.1 crafting_types.gd
```gdscript
enum StationType { MESA_TRABAJO, FOGATA, TELAR }
enum RecipeCategory { HERRAMIENTAS, ESTRUCTURA, TEXTILES, COCINA, DECORACION, ANCESTRAL, OCULTA }
enum RecipeSource { EXPERIMENTACION, COMPRA, EVENTO }
enum CraftError { OK, MATERIAL_INSUFICIENTE, INVENTARIO_LLENO, DESCONOCIDA, TEMPORADA_CERRADA, ESTACION_INCORRECTA }

class RecipeMaterial:
    var item_id: String
    var cantidad: int

class CraftResult:
    var recipe: CraftingRecipe = null
    var success: bool = false
    var reason: CraftError = CraftError.OK
    var cantidad_fabricada: int = 0
    var consumo: Array[RecipeMaterial] = []

class ExperimentResult:
    var success: bool = false
    var discovered: CraftingRecipe = null
```

### 2.2 crafting_recipe.gd
```gdscript
class_name CraftingRecipe
extends Resource

@export var id: String
@export var nombre: String
@export var descripcion: String
@export var categoria: RecipeCategory = RecipeCategory.DECORACION
@export var nivel: int = 1
@export var estacion: StationType = StationType.MESA_TRABAJO
@export var materiales: Array[RecipeMaterial] = []
@export var resultado_id: String
@export var resultado_cantidad: int = 1
@export var origen: RecipeSource = RecipeSource.EXPERIMENTACION
@export var precio_pergamino: int = 0
@export var tags: Array[String] = []
@export var pista: String
@export var temporadas: Array[String] = []      # vacío = siempre

func materiales_dict() -> Dictionary            # {item_id: cantidad} normalizado
func es_estacional() -> bool
func es_secreta() -> bool
func es_ancestral() -> bool
```

### 2.3 crafting_service.gd
```gdscript
class_name CraftingService
extends Node

const ESTACIONES: Array[StationType] = [StationType.MESA_TRABAJO, StationType.FOGATA, StationType.TELAR]
const MAX_EXPERIMENT_MATERIALS: int = 3
const MASA_CREACION_LIMITE: int = 30

var _recipes: Dictionary = {}                   # recipe_id -> CraftingRecipe
var _by_station: Dictionary = {}                # StationType -> Array[CraftingRecipe]
var _known: Dictionary = {}                     # recipe_id -> bool (persistente)

# --- Registro ---
func register_recipe(recipe: CraftingRecipe) -> void
func _register_all_from_sources() -> void       # carga .tres desde carpetas al iniciar

# --- Consultas (con cache) ---
func get_recipes_for_station(st: StationType) -> Array[CraftingRecipe]
func get_known_recipes(st: StationType) -> Array[CraftingRecipe]
func get_unknown_for(st: StationType) -> Array[CraftingRecipe]
func is_known(rid: String) -> bool
func get_recipe(rid: String) -> CraftingRecipe
func _rebuild_cache(st: StationType) -> void    # cache + filtro temporada (M29)

# --- Conocimiento ---
func learn_record(rid: String) -> void
func learn_from_item(pergamino_id: String) -> void   # id del pergamino en M14

# --- Fabricación ---
func craft(rid: String, cantidad: int = 1) -> CraftResult
func _can_craft(recipe: CraftingRecipe, cantidad: int) -> CraftError
func _consume_and_deliver(recipe: CraftingRecipe, cantidad: int) -> bool  # rollback si entrega falla
func _deliver(resultado_id: String, cantidad: int) -> bool                # mochila → casa

# --- Experimentación ---
func experimentar(st: StationType, combinacion: Dictionary) -> ExperimentResult
func _normalizar_combinacion(combinacion: Dictionary) -> Dictionary

# --- Persistencia ---
func build_save_data() -> Dictionary            # {"recetas_conocidas": [...]}
func restore_save_data(data: Dictionary) -> void

# --- Señales (declaradas en 03-Diseno.md §3.1) ---
```

### 2.4 crafting_station.gd
```gdscript
class_name CraftingStation
extends Node3D

@export var station_type: StationType = StationType.MESA_TRABAJO
@export var allows_experiment: bool = true
@export var spawn_point: Node3D = null

func interact(player: Node) -> void              # contrato IInteractable (M11)
func _open_ui() -> void
func close() -> void
```

### 2.5 crafting_ui.gd
```gdscript
class_name CraftingUI
extends Control

@onready var _lista: ItemList            # o VBox virtualizado
@onready var _detalle_materiales: VBoxContainer
@onready var _btn_crear_1: Button
@onready var _btn_crear_n: Button
@onready var _btn_experimentar: Button

var _station: CraftingStation = null
var _receta_seleccionada: CraftingRecipe = null

func open(station: CraftingStation) -> void
func close() -> void
func _on_station_changed() -> void
func _refresh_list() -> void                     # cache listas + filtros
func _refresh_detail(rid: String) -> void        # materiales, faltantes (rojo+origen M15), preview
func _on_crear_1() -> void
func _on_crear_n() -> void
func _on_experimentar(combinacion: Dictionary) -> void
func _on_inventory_changed() -> void             # de M14: refresco de "fabricables ahora"
```

## 3. Mensajes de Log (runtime)

El servicio imprime logs de desarrollo (debug) para diagnóstico, con prefijo `[Crafting]`:

| Evento | Mensaje (ejemplo) |
|---|---|
| Registro fallido | `[Crafting] ERROR: receta duplicada 'id' (omitida)` |
| Receta aprendida | `[Crafting] receta aprendida: 'mesa_robusta' (origen: compra)` |
| Descubrimiento | `[Crafting] receta descubierta por experimentación: 'joya_de_ambar' en FOGATA` |
| Fabricación OK | `[Crafting] fabricado 'sillon' x2, consumido 2x{...}` |
| Materiales | `[Crafting] fabricación rechazada: materiales insuficientes para 'x' (faltan y)` |
| Inventario lleno | `[Crafting] rollback aplicado: inventario lleno al entregar 'x' (consumo revertido)` |
| Temporada | `[Crafting] receta 'x' oculta: temporada cerrada (M29)` |
| Persistencia | `[Crafting] conocimiento restaurado: N recetas` |
| Validación | `[Crafting] VALIDACIÓN: N recetas, M con combinación inalcanzable (M15)` |

En builds release los `print` se eliminan o se compilan condicionados (`if OS.is_debug_build()` o `is_editor_hint`), siguiendo la política de logs de producción del proyecto (AGENTS.md sección 18: sin cread-archivos con rotación; los mensajes van a la consola de Godot).

## 4. Notas de Implementación

- **Persistencia:** el conocimiento se guarda dentro del diccionario de guardado global (SaveManager); CraftingService solo expone `build_save_data/restore_save_data`.
- **Cache:** `_by_station` se construye una vez al registrar; la lista "conocidas por estación" se recalcula solo ante `recipe_learned`, `inventory_changed` (para "fabricables") o `season_changed`.
- **Anti-redundancia:** un script de validación (modo editor) recorre todas las recetas y emite warning si dos recetas producen el mismo resultado con la misma estación y coste similar (regla D7 de 02-Analisis).
- **Sin acoplamiento UI/dominio:** CraftingUI no instancia nodos del mundo; recibe listas serializables (id, nombre, categoria, pista) y delega la fabricación al servicio.
- **Rollback honesto:** `_consume_and_deliver` consume primero y, si la entrega falla (mochila y casa llenas), reembolsa exactamente lo consumido antes de emitir señal de error. Es la única transacción de dos pasos del módulo.

## 5. Historial de Cambios

- **2026-08-16:** Creación del plan inicial del módulo (documentación completa, código propuesto, sin implementación aún). Firmado por Deepseek V4 Flash (OpenCode).
- **2026-08-30:** Implementación del núcleo (iter 1-2) por Deepseek V4 Flash (Kilo): CraftingService, CraftingRecipe, CraftingStation, CraftingUI, test 0 fallos. Logs 269/270.
- **2026-08-31:** Iteración 3 por GLM (Kilo): resolución de los 4 pendientes. Log 303.
- **2026-08-31:** Iteración 3 cierre por GLM (Kilo): test season_changed runtime + decisión de nomenclatura M93. Log 304. Liberado a 🟡.

## Notas del Agente (iteración 3 — 2026-08-31)

**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Fecha:** 2026-08-31 07:10:00
**Estado:** Iter 3 cerrada. Módulo sigue 🔵 En curso (8 [?] con dueño).

### Lo que hice
- **RF5 estacional:** campo `temporadas: Array[String]` en `CraftingRecipe`, `es_fabricable_ahora(estacion)`, mapeo de claves (`primavera`/`verano`/`otono`/`invierno`) a enum M29, `ESTACIONES_ANYO_TEXTO` const. Plumbed en `_recipe_desde_datos`. Filtrado en `recetas_por_estacion` (oculta sin borrar conocimiento). `recetas_conocidas_estacion` devuelve TODAS las conocidas (incluso bloqueadas). `receta_bloqueada(rec_id)` para la UI. `max_craftable`/`puede_craft`/`craft` respetan temporada. Señal `receta_bloqueada_estacion`. Integración con M29 vía `get_node_or_null("/root/GameTime")` + `estacion_cambio` signal. Datos: `rec_ensalada_bayas` → [primavera, verano], `rec_talisman_ancestral` → [otono, invierno].
- **RF14 pergaminos M14:** helper `usar_pergamino(item_id: String) -> Dictionary` con prefijo `pergamino_rec_`. Señal `pergamino_consumido(rec_id, aprendido)` (false = ya conocida, NO consume el pergamino — honesto). Convencion documentada para M14.
- **RF12 SFX/VFX procedural:** `scripts/crafting/crafting_feedback.gd` (nuevo). Instanciado como hijo del servicio en `_ready`. SFX: `AudioStreamWAV` generado en memoria (seno 660Hz 180ms OK / 880Hz 280ms descubrimiento, envolvente attack/release anti-click). VFX: `CPUParticles2D` dorado (`emitting=true`, `one_shot`, 24 partículas, gravedad, color 1.0/0.85/0.35) en `CanvasLayer` propia con limpieza diferida por `SceneTreeTimer`. Notificación vía `NotificationService` (fallback a `print` si no existe).
- **RF9 preview V1:** `ColorRect` (28×28, color derivado por hash determinista del `resultado_id`) + Label `→ {resultado_id}` en `CraftingUI`. Reset cuando no hay selección. Aviso `FUERA_TEMPORADA` en ámbar cuando la receta está bloqueada.
- **Tests:** `_test_estacional_rf5` (RF5, 11 checks), `_test_pergamino_m14` (RF14, 4 checks), `_test_feedback_cargado` (RF12, 3 checks). `_test_coste_ao` actualizado para forzar `_gt._mes=9` (otoño) ya que el talismán ahora es estacional. Regresión M31 (ciclo día/noche) sigue 12/0 OK. **Total M16: 0 fallos. M31: 12/0 OK.**

### Lo que NO pude hacer (honestidad obligatoria)
- **M14 use_item → pergamino:** el helper `usar_pergamino` existe, pero la integración M14 (detectar item tipo pergamino y consumirlo al usar) requiere cambio en M14 (autoload 🟡, fuera de alcance M16 iter 3). Documentado como pendiente con dueño.
- **Preview 3D real:** el swatch V1 es honesto pero no es un modelo 3D rotable. Requiere M45 (🟢 sin núcleo).
- **SFX master bus + librería:** el beep es procedural; integrar con AudioBusSetup y SFX library de M91 cuando exista.
- **VFX avanzados:** las partículas CPU son placeholder; M52 está 🟢 sin núcleo.
- **Tiendas venden pergaminos:** M38 🟡; el `precio_pergamino` en el JSON ya existe pero no hay item `pergamino_rec_*` en el catálogo de tienda.
- **Migración `coste_recursos` → `materiales`:** el JSON usa `coste_recursos` (decisión de M93) y `_recipe_desde_datos` lo mapea; el diseño §1.2 dice `materiales`. Inconsistencia menor entre JSON y diseño. No bloquea.
- **Recetas secretas/ancestrales con feedback dorado adicional:** las partículas en descubrimiento son la base; el "feedback dorado" del RF3 (secreta vs ancestral) requiere distinguirlas por tag.
- **Test de cambio de temporada en runtime:** `estacion_cambio` actualiza `_estacion_actual`; falta test explícito que emita la señal y verifique el refresco.

### Intentos fallidos / decisiones
- `Signal.is_valid()` no existe en Godot 4. Resuelto eliminando la guarda y conectando directo a `timer.timeout`.
- El talismán (coste_ao=10) ahora falla en primavera porque es estacional [otono, invierno]. Actualicé el test para forzar `_gt._mes=9` (otoño) — comportamiento correcto de RF5.
- `recetas_por_estacion` filtra por temporada; las recetas conocidas pero fuera de temporada NO aparecen en la lista de fabricables. `recetas_conocidas_estacion` (nueva) devuelve todas las conocidas para que la UI pueda mostrar un aviso "fuera de temporada" sin perder la pista.
- `CraftingFeedback` se instancia como `child` del autoload `Crafting` (en el SceneTree). No requiere registro en `project.godot` ni nodo manual en la escena principal.

### Recomendaciones para el próximo agente
- Cuando M14 implemente `use_item`, agregar la convención: si el `item_id` empieza con `pergamino_rec_`, llamar a `Crafting.usar_pergamino(item_id)` y consumir el item tras `aprendido==true`.
- Reemplazar el swatch V1 por un `SubViewport` 3D cuando M45 provea `ItemData.preview_mesh`.
- Mover el array de partículas a una `MultiMesh` GPU cuando M52 exista.
- Documentar `coste_recursos` (JSON) vs `materiales` (diseño) como decisión de nomenclatura de M93 para alinear.
- Los 8 [?] con dueño están listados en la sección M.2 del 05-Checklist.

## Notas del Agente (iteración 3 cierre — 2026-08-31 07:50)

**Modelo:** GLM (Kilo)
**Plataforma:** Kilo
**Fecha:** 2026-08-31 07:50:00
**Estado:** Iter 3 cerrada por completo. Módulo liberado a 🟡.

### Lo que hice
- Test `_test_season_changed_runtime` (RF5): verifica que el servicio está conectado a `estacion_cambio` de M29 (via `get_connections()`), que la emisión no crashea, y que `get_estacion_actual()` es coherente con `GameTime._mes` después de la señal.
- **Decisión de nomenclatura `coste_recursos` → `materiales`:** NO se renombra. `coste_recursos` es la clave del schema de M93, usada por `crafting.json`, `construction.json`, `validate_balance.gd` y `balance_service.gd` (línea 180). M93 es la autoridad del schema. Renombrar rompería M93 y M17 (construcción). Se mantiene el mapeo: JSON `coste_recursos` → `CraftingRecipe.materiales` en `_recipe_desde_datos`. Documentado en sección M.3 del 05-Checklist.
- Liberación M16 a 🟡 en los 4 registros.
- Log 304 generado.

### Intento fallido
- `_refrescar_estacion_actual()` con "no-op si cache válido" sobrescribía la actualización de la señal al re-leer de `get_estacion()`. Se revirtió a "siempre re-leer de M29" (fuente de verdad). La señal mantiene el cache caliente pero la consulta siempre lee. Test ajustado para verificar conexión + emisión + coherencia, no que la señal sola cambie el cache sin que `_mes` cambie.

### Recomendaciones finales
- Los 6 [?] con dueño (M.2) requieren M14/M45/M38/M52/M91 con núcleo. M16 está funcional y bien testeado; los pendientes son integraciones cross-module legítimas.
- Al retomar M16, empezar por la integración M14 (RF17 pergaminos) que es la más valiosa y desbloquea economía.