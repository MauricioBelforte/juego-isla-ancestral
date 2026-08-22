**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 04-Codigo.md — Módulo 159: Catálogo de Objetos

## 1. Archivos Relacionados

| Archivo | Módulo | Función |
|---------|--------|---------|
| `scripts/data/item_database.gd` | M159 | ResourceLoader del catálogo |
| `scripts/data/item_data.gd` | M159 | Resource de cada objeto |
| `scripts/inventory/inventory_manager.gd` | M14 | Consumidor del catálogo |
| `scripts/crafting/crafting_recipe.gd` | M16 | Usa IDs del catálogo |
| `scripts/house/house_decor.gd` | M18 | Coloca objetos del catálogo |
| `scripts/shop/shop_inventory.gd` | M39 | Vende objetos del catálogo |
| `scripts/player/equipment.gd` | M155 | Equipa ropa del catálogo |
| `assets/models/objects/` | M45 | Modelos 3D de cada objeto |

## 2. Estructura de Datos

### ItemData.gd (Resource)

```gdscript
class_name ItemData
extends Resource

@export var id: String = ""
@export var nombre: String = ""
@export var descripcion: String = ""
@export var categoria: String = ""
@export var subcategoria: String = ""
@export var tamano: Vector2i = Vector2i(1, 1)
@export var interactivo: bool = false
@export var accion: String = ""
@export var fuente: String = ""
@export var precio_compra: int = 0
@export var precio_venta: int = 0
@export var rareza: String = "Común"
@export var apilable: bool = true
@export var stack_max: int = 10
@export var material: String = ""
@export var color: String = ""
@export var variante: String = ""
@export var requiere_herramienta: String = ""
@export var exportable: bool = true
@export var icono: Texture2D = null
@export var modelo_3d: PackedScene = null
```

### ItemDatabase.gd (Autoload)

```gdscript
class_name ItemDatabase
extends Node

var items: Dictionary = {}

func _ready() -> void:
    _load_all_items()

func _load_all_items() -> void:
    var dir = DirAccess.open("res://data/items/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var item = load("res://data/items/" + file_name)
                if item is ItemData:
                    items[item.id] = item
            file_name = dir.get_next()

func get_item(id: String) -> ItemData:
    return items.get(id)

func get_items_by_category(cat: String) -> Array[ItemData]:
    var result: Array[ItemData] = []
    for item in items.values():
        if item.categoria == cat:
            result.append(item)
    return result

func get_items_by_rarity(rareza: String) -> Array[ItemData]:
    var result: Array[ItemData] = []
    for item in items.values():
        if item.rareza == rareza:
            result.append(item)
    return result
```

## 3. Integración con Módulos

| Módulo | Cómo consume el catálogo |
|--------|-------------------------|
| M14 (Inventario) | `ItemDatabase.get_item(id)` para saber propiedades |
| M16 (Crafting) | Recipes usan IDs del catálogo como input/output |
| M18 (Casas) | `ItemData.tamano` para grid de decoración |
| M39 (Tiendas) | `ItemData.precio_compra/venta` para economía |
| M45 (Arte 3D) | Lista de IDs para modelar assets |
| M58 (Guardado) | Serializa `ItemData.id` en saves |
| M155 (Vestimenta) | `ItemData.slot` y `bonificación` para equipamiento |

## 4. Convenciones de Nomenclatura

| Tipo | Formato | Ejemplo |
|------|---------|---------|
| ID de objeto | `OBJ-[CAT]-[NNN]` | OBJ-MES-001 |
| Archivo de data | `item_[id].tres` | item_obj_mes_001.tres |
| Modelo 3D | `obj_[id].glb` | obj_mes_001.glb |
| Icono | `icon_[id].png` | icon_obj_mes_001.png |
| Textura | `tex_[id].png` | tex_obj_mes_001.png |

## 5. Logs Relacionados

- Log 123: Expansiones cozy (Tsuki's Odyssey)
- Log 124: Mejora documentación cozy con investigación web
- Log 125: Creación de M159 (Catálogo de Objetos)
