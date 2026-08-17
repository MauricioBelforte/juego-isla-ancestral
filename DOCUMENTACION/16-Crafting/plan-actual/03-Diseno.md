**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 16: Crafting

## 1. Arquitectura General

Separación estricta por capas (AGENTS.md sección 9): la lógica de crafting vive en el **dominio** (Recursos + Servicio) y la presentación en la **UI**. La UI nunca toca inventario directamente: siempre a través del servicio.

```
┌──────────────────────────────────────────────────────────────┐
│                        Capa de Presentación                   │
│  CraftingUI (Control)  ·  ExperimentUI opcional en CraftingUI │
└──────────────▲───────────────────────────────────────────────┘
               │ consume (señales + API de solo lectura)
┌──────────────┴───────────────────────────────────────────────┐
│                       Capa de Dominio                         │
│  CraftingStation (Node3D, interactuable M11)                  │
│  CraftingService (Autoload singleton)  ·  CraftingRecipe (Resource) │
└──────────────▲───────────────────────────────────────────────┘
               │ API (consumir/entregar) y señales
┌──────────────┴───────────────────────────────────────────────┐
│                      Capa de Integración                      │
│  M14 InventoryService  ·  M17 ConstructionService             │
│  M13 ToolService  ·  M15 ResourceRegistry  ·  SaveManager     │
└───────────────────────────────────────────────────────────────┘
```

### 1.1 Clases

| Clase | Tipo | Responsabilidad |
|---|---|---|
| `CraftingRecipe` | `Resource` (`class_name`) | Datos inmutables de una receta |
| `CraftingStation` | `Node3D` (componente en voxel interactuable) | Identidad de estación, set de recetas, apertura de UI, punto de spawn del resultado |
| `CraftingService` | `Node` (Autoload `Crafting`) | Registro global de recetas, conocimiento, experimentación, fabricación, eventos, persistencia |
| `CraftingUI` | `Control` | Lista de recetas, detalle de materiales, preview, crear 1x/N, modo experimentar |

### 1.2 Modelo de datos (CraftingRecipe)
```
id: String                    # "rec_mesa_robusta"
nombre: String                # "Mesa robusta"
descripcion: String
categoria: RecipeCategory     # enum: herramientas, estructura, textiles, cocina, decoracion, ancestral, oculta
nivel: int                    # 1..5
estacion: StationType         # enum: mesa_trabajo, fogata, telar
materiales: Array[RecipeMaterial]   # [{item_id, cantidad}]
resultado_id: String          # id del ítem (M14/M15 para materiales)
resultado_cantidad: int
origen: RecipeSource          # enum: experimentacion, compra, evento
precio_pergamino: int         # moneda M37, 0 si no comprable
tags: Array[String]           # "secreta", "ancestral", "estacional:primavera", "regional:volcan"
pista: String                 # texto cozy de pista de obtención
duracion_estacion: Array[String]  # temporadas en que es fabricable (vacío = siempre)
```

### 1.3 Reglas de dominio (invariantes)
1. Una receta pertenece a exactamente una estación.
2. La experimentación nunca consume materiales (D: gasto solo en éxito).
3. Fabricar consume materiales **solo si** la entrega del resultado está garantizada (inventario o almacenamiento disponible).
4. El conocimiento de recetas es acumulativo y persistente; nada lo borra.
5. Toda receta con origen "experimentacion" debe tener una única combinación canónica y ser alcanzable (validación automática contra M15).
6. No hay dos recetas con el mismo material objetivo para el mismo resultado sin diferencia funcional (anti-redundancia).

## 2. Diagramas de Flujo (texto)

### 2.1 Flujo principal: fabricar en estación
```
Jugador se acerca a estación voxel (M11 Interactuable)
   │  [Interactuar]
   ▼
CraftingStation.open_ui() → CraftingService.get_known_recipes(station.tipo)
   ▼
CraftingUI muestra lista (conocidas) + pestañas (categorías) + modo experimentar
   ▼
Jugador selecciona receta → detalle de materiales vs inventario (M14)
   ├─ ¿Faltan materiales? → UI muestra faltantes (rojo + origen M15) · botón crear deshabilitado
   └─ OK → botón Crear 1x / Crear N
              ▼
   CraftingService.craft(recipe_id, cantidad)
      ├─ validar materiales → si NO: señal crafting_failed (materiales) · sin consumo · log
      └─ si OK: M14.consume(materiales×N)
              ▼
   lugar = M14.find_free_slot(resultado) → ¿Hay espacio?
      ├─ NO y hay almacenamiento doméstico → M14 deposit_en_casa(resultado)
      └─ NO y sin almacenamiento → ROLLBACK: M14.reembolso(materiales×N) · señal inventario_lleno
              ▼
   entrega → señal crafting_completed(recipe, cantidad) → SFX/VFX + animación breve
      ▼
   cierre de UI opcional (R sin cerrar) — sin penalización
```

### 2.2 Flujo de experimentación
```
CraftingUI (pestaña Experimentar) — solo visible si la estación admite descubrimiento
   ▼
Jugador asigna hasta 3 materiales libres (cantidad 1) + un "intención" (opcional: qué quiere hacer)
   ▼
CraftingService.experimentar(estacion, combinacion)
   ├─ normaliza combinación (Diccionario item_id→cantidad, orden estable)
   ├─ busca receta_oculta: origen==experimentacion y materiales==combinacion y estacion==estacion
   │    ├─ NO encontrada → señal experimento_fallido · respuesta cozy ("Nada parece encajar...")
   │    │      └─ sin consumo · el jugador recupera todo
   │    └─ encontrada → conocer(receta) → señal receta_descubierta(receta)
   │          └─ fabricación opcional inmediata (flujo 2.1)
   ▼
```

### 2.3 Flujo de compra de receta (pergamino)
```
NPC (M20) ofrece pergamino de receta (M38: ítem "pergamino_receta.rec_id")
   ▼
Jugador usa el ítem desde inventario (M14 uso)
   ▼
CraftingService.learn_from_item(item_id)
   ├─ item válido y receta no conocida → conocer(receta) · consumir ítem · señal receta_aprendida
   └─ ya conocida → mensaje cálido ("Ya conoces esa receta") · NO consume el pergamino (honesto)
   ▼
```

### 2.4 Flujo de persistencia
```
SaveManager.guardar()
   ▼
CraftingService.build_save_data() → { recetas_conocidas: Array[String] }
   ▼
SaveManager.cargar()
   ▼
CraftingService.restore_save_data(data)  ·  recomputa cache por estación
```

## 3. Contratos de API (GDScript, Godot 4)

### 3.1 CraftingService (Autoload `Crafting`)
```
# --- Registro y consulta ---
func register_recipe(recipe: CraftingRecipe) -> void
func get_all_recipes() -> Array[CraftingRecipe]
func get_recipes_for_station(station_type: StationType) -> Array[CraftingRecipe]
func get_known_recipes(station_type: StationType) -> Array[CraftingRecipe]
func is_known(recipe_id: String) -> bool
func get_recipe(recipe_id: String) -> CraftingRecipe

# --- Conocimiento ---
func learn_record(recipe_id: String) -> void            # interno
func learn_from_item(pergamino_item_id: String) -> void # M14 usa
func get_unknown_for(station_type: StationType) -> Array[CraftingRecipe]

# --- Fabricación y experimentación ---
func craft(recipe_id: String, cantidad: int = 1) -> CraftResult
func experimentar(estacion: StationType, combinacion: Dictionary) -> ExperimentResult

# --- Persistencia ---
func build_save_data() -> Dictionary
func restore_save_data(data: Dictionary) -> void

# --- Señales ---
signal recipe_learned(recipe: CraftingRecipe)          # por compra o evento
signal recipe_discovered(recipe: CraftingRecipe)       # por experimentación
signal crafting_completed(recipe: CraftingRecipe, cantidad: int)
signal crafting_failed(recipe_id: String, reason: CraftError)
signal experiment_failed(station_type: StationType)
signal inventory_full(recipe_id: String, cantidad: int)
```

### 3.2 CraftingStation
```
@export var station_type: StationType
@export var open_ui: bool = true          # permite abrir la UI
@export var point_of_spawn: Node3D        # donde aparece el resultado

func interact(player: Node) -> void       # implementa IInteractable (M11)
func close() -> void
signal ui_closed
```

### 3.3 CraftingUI
```
func open(station: CraftingStation) -> void
func close() -> void
func set_known_recipes(recipes: Array[CraftingRecipe]) -> void
func set_favorites(fav_ids: Array[String]) -> void        # favoritos M14
func is_open() -> bool
signal closed_by_player
```

### 3.4 Tipos de resultado
```
class CraftResult:
    var recipe: CraftingRecipe
    var success: bool
    var reason: CraftError          # enum: ok, material_insuficiente, inventario_lleno, desconocida, temporada_cerrada
    var cantidad_fabricada: int
    var consumo: Array[RecipeMaterial]

class ExperimentResult:
    var success: bool
    var discovered: CraftingRecipe   # null si falla
```

## 4. Integración con Otros Módulos

### 4.1 M14 Inventario (dependencia dura)
- `CraftingService.craft` llama a `InventoryService.consume(materiales)`, `InventoryService.get_amount(item_id)`, `InventoryService.add_item(resultado_id, cantidad)`.
- Política de llenado: intentar mochila → almacenamiento doméstico → rollback honesto.
- Favoritos y "fabricables ahora" se alimentan del estado de M14 vía señales `inventory_changed`.

### 4.2 M15 Recursos (dependencia dura)
- Los `item_id` de materiales/resultados referencian el catálogo de M15 y ítems M14.
- `ResourceRegistry.get_origen(item_id)` alimenta la sección "dónde se consigue" del detalle.
- Los materiales ancestrales/estacionales/regionales (M15) habilitan tags equivalentes en recetas.

### 4.3 M13 Herramientas (dependencia)
- Las recetas de herramientas se marcan `categoria=herramientas`; fabricar una herramienta llama a `ToolService.register_tool(id, nivel)` tras la entrega si aplica.
- La durabilidad (si existe) se inicializa al fabricar vía `ToolService`; reparación puede ser una receta de estación (fogata) con materiales del mismo tipo.
- El desbloqueo de herramientas (niveles) puede requerir nivel de receta (bloqueo cascada: nivel 2 requiere conocer receta nivel 1).

### 4.4 M17 Construcción (dependencia)
- Los resultados de mobiliario son ítems que M17 coloca: `crafting_completed` → si el resultado es constructible, M17 recibe la notificación para el modo decoración (preview del ítem=preview 3D de la receta).
- La receta "estación de crafting" (fabricar otra mesa/telar/fogata) es una receta de mesa de trabajo que coloca una nueva `CraftingStation` en el mundo (M17 placement).

### 4.5 M29 Tiempo/Estaciones, M73 Eventos (relaciones)
- `duracion_estacion` filtra fabricables; el conocimiento persiste; la señal `season_changed` (M29) refresca el cache por estación.
- Eventos/festivales pueden desbloquear recetas temporales vía `learn_record` por evento (no por dinero).

### 4.6 M20 Diálogos/NPCs y M38 Tiendas (relaciones)
- NPCs venden pergaminos (M38) con `pergamino_receta_*`; `lear_from_item` los consume.
- Pistas cozy de recetas por conocer se exponen a M20 para diálogos de NPC ("Dicen que con arcilla y fuego...").