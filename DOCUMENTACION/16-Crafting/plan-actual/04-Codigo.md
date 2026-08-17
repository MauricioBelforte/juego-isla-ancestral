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