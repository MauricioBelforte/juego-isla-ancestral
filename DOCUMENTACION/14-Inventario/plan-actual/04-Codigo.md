**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 14: Inventario

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/inventario/item_data.gd` | Resource (class_name `ItemData`) | Definición de un ítem: id, claves de localización, icono, categoría, stack, rareza, precio |
| `res://src/inventario/item_catalog.gd` | Data | Registro central `id → ItemData`; carga bajo demanda del catálogo de `res://data/items/*.tres` |
| `res://src/inventario/inventory_slot.gd` | RefCounted (class_name `InventorySlot`) | Slot: item_id + cantidad + favorito + bloqueado |
| `res://src/inventario/inventory.gd` | RefCounted (class_name `Inventory`) | Contenedor genérico de slots con tamaño dinámico |
| `res://src/inventario/inventory_service.gd` | Autoload | Única autoridad de ítems; orquesta contenedores, validaciones e integraciones |
| `res://src/inventario/inventory_storage.gd` | Node | Gestión de cofres colocables (M17) y almacén del pueblo con ids del mundo |
| `res://src/inventario/inventory_save.gd` | Util | Serialización/deserialización con versión y validación (M59) |
| `res://src/inventario/inventory_ui.gd` | Control (class_name `InventoryUI`) | Panel principal: grilla, pestañas, filtros, sort, acciones |
| `res://src/inventario/inventory_slot_ui.gd` | Control | Slot visual de la grilla (escena `slot.tscn`) |
| `res://src/inventario/hotbar_ui.gd` | Control | Hotbar fija de 6 slots + contadores |
| `res://src/inventario/tooltip_ui.gd` | Control | Tooltip y panel de detalle lazzy (delay 0.5 s) |
| `res://src/inventario/inventory_tutorial.gd` | Util | Gatillos didácticos de M92 (primer recogido, primer lleno) |
| `res://ui/inventario/inventory_panel.tscn` | Escena | Panel completo del inventario |
| `res://ui/inventario/slot.tscn` | Escena | Slot reutilizable por contenedor y hotbar |
| `res://ui/inventario/tooltip.tscn` / `hotbar.tscn` | Escenas | HUD asociado |
| `res://data/items/*.tres` | Data | Catálogo de ítems (recursos M15, herramientas M13, espóras, etc.) |
| `res://src/inventario/container_type.gd` | Enum/class_name | `BOLSILLO, MOCHILA, CASA, COFRE, ALMACEN, CORREO` |

## 2. Funciones clave (firmas GDScript)

```
# item_data.gd (Resource)
@export var id: String                    # id inmutable (requisito M59/M87)
@export var display_name_key: String      # clave de localizacion M87
@export var description_key: String
@export var icon: Texture2D
@export var category: ItemCategory        # enum de 9 categorias
@export var stack_max: int = 99
@export var rarity: Rarity                # enum: comun, raro, ancestral, divino
@export var base_price: int
@export var protected_from_discard: bool  # esporas, regalos, objetos de mision
@export var recipes_key: Array[String]    # ids de recetas M16 donde interviene
# --- Nuevos campos (2026-08-23) ---
@export var item_type: ItemType           # enum: TOOL, RESOURCE, FOOD, FISH, MATERIAL, GIFT, SPORE, FURNITURE, QUEST, CLOTHING, ENCHANTMENT
@export var tool_type: String             # "pickaxe", "axe", "hoe", "shovel", "watering_can", "fishing_rod", "hammer", "scissors", "magnifying_glass" (vacio si no es herramienta)
@export var tool_tier: int = 0            # 0=none, 1=T1_cobre, 2=T2_hierro, 3=T3_oro, 4=T4_cristal
@export var enchantment: String           # "ancestral_cobre", "prospero_hierro", "brillante_oro", "caverna_cristal" (vacio si no esta encantada)
@export var is_enchanted: bool = false
@export var durability: int = -1          # -1 = infinita (solo para herramientas)
@export var durability_max: int = -1
@export var tags: Array[String]           # para filtrado: "mineral", "madera", "comida", "regalo", etc.
@export var is_quest_item: bool = false
# --- Campos visuales (M161) ---
@export var visual_mesh: Mesh             # mesh 3D si el item se muestra en el mundo
@export var visual_color: Color           # color base del item

# inventory.gd (RefCounted)
var slots: Array[InventorySlot]
var size: int = 24
signal changed(slot_index: int)
func add(item_id: String, amount: int) -> int            # sobrante no aceptado
func can_add(item_id: String, amount: int) -> bool
func remove(item_id: String, amount: int) -> bool
func count(item_id: String) -> int
func first_free_slot() -> int
func find_slot_with(item_id: String) -> int
func move_to(other: Inventory, slot: int, amount: int) -> bool
func split(slot: int, amount: int) -> bool
func sort_by(mode: SortMode) -> void
func set_size(new_size: int) -> void                     # con preservación de ítems
func to_dict() -> Dictionary
static func from_dict(data: Dictionary) -> Inventory     # con validación

# inventory_service.gd (autoload)
const BOLSILLO := ContainerType.BOLSILLO
var bolsillo: Inventory
var casa: Inventory
var cofres: Dictionary[String, Inventory]                # id_cofre → contenedor
const LOG_TAG := "[DOM-14]"
func _ready() -> void: _connect_integrations()
func add_item(item_id: String, amount: int, container: int) -> int
func remove_item(item_id: String, amount: int, container: int) -> bool
func count_item(item_id: String, include_house: bool = false) -> int
func has_free_space(container: int) -> bool
func move_all(from: int, to: int) -> int
func move_amount(from: int, slot: int, to: int, amount: int) -> bool
func split_stack(container: int, slot: int, amount: int) -> bool
func sort_container(container: int, mode: int) -> void
func toggle_favorite(container: int, slot: int) -> void
func discard(container: int, slot: int, confirmed: bool) -> bool
func open_chest(chest_id: String) -> void
func close_chest() -> void
signal slot_changed(container: int, slot: int)
signal item_added(item_id: String, amount: int, container: int)
signal item_removed(item_id: String, amount: int, container: int)
signal inventory_full(container: int, item_id: String, amount: int)
signal storage_opened(chest_id: String)
signal storage_closed
```

## 3. Suscripciones e integración

- `M13/M15`: señal de cosecha → `InventoryService.add_item()`; si devuelve sobrante > 0 → el mundo deja pickup flotante (nunca se pierde) + señal `inventory_full`.
- `M16`: crafting consulta `count_item(id, include_house=true)` para validar recetas; `remove_item` de materiales; `add_item` del resultado (si el bolsillo está lleno → intenta casa → si no, pickup en el suelo del banco de trabajo).
- `M19/M20`: entregar regalo → `remove_item` + señal; recibir paquete → `add_item` a correo si el bolsillo está lleno.
- `M39`: vender → `remove_item` + crédito de economía (M38); comprar → `add_item`.
- `M37`: donar → `remove_item` + registrar en museo/colección.
- `M53`: la UI escucha `slot_changed` y refresca solo el slot afectado; el HUD usa fábricas de escenas `slot.tscn`.
- `M29`: con el inventario abierto el mundo puede pausarse de forma suave (UI-only); los contenedores siguen operativos (validación sin física).
- `M87`: todos los textos muestran claves de localización, nunca cadenas crudas.
- `M55`: el diario lee `count_item("espora_luz", true)` para el contador global.

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| `InventoryService` + `Inventory` + `InventorySlot` | Núcleo de datos; independiente de la UI (prototipable de inmediato) |
| Catálogo `ItemData.tres` de recursos M15 y espóras | Requiere los primeros ítems definidos por M15 |
| `InventoryUI` + hotbar + tooltip | Requiere M53 (UI base) |
| Serialización y guardado | Junto a M59; versión de esquema y validación |
| Integraciones M16/M19/M39/M37 | Cuando existan esos módulos implementados |
| Tests M112 y QA M114 | Matriz de operaciones y recorrido cozy |

## Análisis previo a la implementación — Hallazgos (2026-08-26)

**Modelo:** ox-alpha
**Plataforma:** Cline

> Fase de documentación de hallazgos previa a codificar (directiva del usuario). Cruce del diseño vigente contra los módulos YA implementados en `game/isla-ancestral/` (M59 Guardado, M159 Catálogo, M13 Herramientas, M39 Tiendas) y la skill `godot-inventory-system`.

### H1 — Colisión de `class_name ItemData` ⚠️ CRÍTICO
El diseño prevé un `ItemData.gd` propio del módulo en `res://src/inventario/`, pero **M159 ya creó `class_name ItemData extends Resource`** en `scripts/data/item_data.gd` (con id, stack_max, rareza, precio_compra/venta, categoria, apilable — gran solapamiento).
**Decisión:** NO duplicar la clase. Extender el `ItemData` de M159 con los campos faltantes del diseño (`display_name_key`, `description_key`, `protected_from_discard`, `item_type`, `tags`). Duplicarlo rompería el catálogo y la preview de M13.

### H2 — Nombre del autoload fijado por M39 ⚠️ CRÍTICO
ShopManager (implementado, log 167) resuelve dependencias vía `get_node_or_null("/root/Inventario")` esperando los métodos `agregar_items({item_id: cantidad}) -> bool` y `remover_items({...}) -> bool`.
El diseño llama al autoload `InventoryService` con otra API (`add_item(id, amount, container) -> int`).
**Decisión:** el autoload se registra como **`Inventario`** (nombre que M39 ya espera) y expone adaptadores `agregar_items()`/`remover_items()` encima de la API rica del servicio. No se toca M39.

### H3 — El catálogo ya existe: reutilizar ItemDatabase
El diseño prevé `item_catalog.gd` propio. Ya existe el autoload **`ItemDatabase` (M159)** en `/root/ItemDatabase` con `get_item(id)` cargando `data/items/*.tres`.
**Decisión:** usar ItemDatabase como fuente única (regla §15 anti-duplicación); el módulo NO crea su propio catálogo.

### H4 — Durabilidad por instancia (M13) exige slots con instancia
ToolData lleva `durabilidad_actual` por instancia + `serializar()/deserializar()`. Un slot no puede ser solo `(item_id, cantidad)` para herramientas.
**Decisión:** `InventorySlot` = `{item_id, cantidad, favorito, bloqueado, instancia: Dictionary}`. Herramientas: `apilable=false`, 1 por slot, `instancia = tool.serializar()`. Al equipar/deserializar se reconstruye con `ToolData.deserializar(instancia)`.

### H5 — Patrones de la skill `godot-inventory-system` que se adoptan
- Ítems SIEMPRE Resources, nunca Nodes.
- Add en **dos pasadas**: 1) llenar stacks parciales, 2) slots vacíos; devolver **sobrante como int** (encaja con el fallback bolsillo→casa→mundo del diseño).
- Una sola señal `inventario_actualizado` batcheada tras operaciones múltiples (además de las `slot_changed` por-slot del diseño).
- Cantidades siempre `int`; validar capacidad ANTES de mutar; la UI jamás muta contenedores (coincide con la regla de capas del diseño).
- Persistencia: serializar solo `item_id` + `cantidad` (+ instancia para herramientas), nunca Resources anidados.
- `duplicate(true)` al instanciar desde un `.tres` compartido (evita corromper el blueprint).

### H6 — Primer `ISaveProvider` real (valida M59 end-to-end)
SaveManager (log 163) expone `register_provider(ISaveProvider)` sin proveedores todavía.
**Decisión:** el inventario implementa `ISaveProvider` con `get_section_name() == "inventory"` → será el primer sistema persistente real, probando checksum/backups/recuperación con datos verdaderos. La sección `inventory` debe agregarse al schema de M59 (hoy existe como default vacío — compatible).

### H7 — Rutas: adaptar diseño a la convención real
El diseño usa `res://src/inventario/...`; la convención real del repo es `res://scripts/inventario/...` (igual que saving/, shops/, core/). Los archivos se crearán allí.

### H8 — Alcance de la primera iteración (propuesto)
1. `scripts/inventario/container_type.gd` + `inventory_slot.gd` + `inventario_contenedor.gd` (núcleo puro, testeable)
2. `scripts/inventario/inventario_service.gd` → autoload **Inventario** con API rica + adaptadores M39
3. `scripts/inventario/inventario_save.gd` → ISaveProvider registrado en SaveManager
4. UI/hotbar/tooltip/cofres: iteración posterior (requiere M53/M17)

---

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 12:00:00
**Estado:** Documentación de diseño completa (módulo delegable; bloqueado por M13/M15/M53)

### Lo que hice
- 24/24 puntos de la sección 13 del plan maestro resueltos.
- Arquitectura por contenedores (bolsillo, mochila, casa, cofres, almacén, correo) con servicio único y UI desacoplada.
- Regla de oro anti-frustración: ningún ítem se pierde jamás (fallbacks en cadena bolsillo → casa → mundo).
- Espóras de luz y regalos integrados como categorías de protección especial (descarte con confirmación).
- Contratos de API e integraciones con M13/M15/M16/M19/M20/M37/M39/M53/M55/M59 firmados.

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M13/M15 (recolección) y M53 (UI base) para una integración verosímil.
- Balancear cantidades exactas de slots de cofres/almacén: pendiente de pruebas manuales; los valores propuestos son punto de partida.

### Recomendaciones para el próximo agente
- Prototipar primero el núcleo de datos (InventoryService + Inventory) con tests unitarios antes de tocar la UI: es la parte más crítica y la más fácil de verificar.
- Probar el overflow en cadena (bolsillo lleno → casa llena → mundo) con al menos 3 contenedores: es el flujo con más edge cases.
- No instanciar escenas por ítem bajo ninguna circunstancia; si se necesita visual, usar pooling de la escena `slot.tscn`.