**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 04-Codigo.md — Módulo 159: Catálogo de Objetos

## 1. Archivos Relacionados

| Archivo | Módulo | Función | Estado |
|---------|--------|---------|--------|
| `scripts/data/item_data.gd` | M159 | Resource con 16 categorías, rarezas e interacciones como enum | ✅ Implementado |
| `scripts/data/item_database.gd` | M159 | Autoload con carga de `.tres`, 6 queries + debug | ✅ Implementado |
| `data/items/item_obj_pla_001.tres` | M159 | Placeholder de validación | ✅ Creado |
| `scripts/inventory/inventory_manager.gd` | M14 | Consumidor del catálogo *(no existe aún)* | Pendiente M14 |
| `scripts/crafting/crafting_recipe.gd` | M16 | Usa IDs del catálogo *(no existe aún)* | Pendiente M16 |
| `scripts/house/house_decor.gd` | M18 | Coloca objetos del catálogo *(no existe aún)* | Pendiente M18 |
| `scripts/shop/shop_inventory.gd` | M39 | Vende objetos del catálogo *(no existe aún)* | Pendiente M39 |
| `scripts/player/equipment.gd` | M155 | Equipa ropa del catálogo *(no existe aún)* | Pendiente M155 |
| `assets/models/objects/` | M45 | Modelos 3D de cada objeto *(no existe aún)* | Pendiente M45 |

## 2. Estructura de Datos Implementada

**Nota:** A diferencia del diseño original de MiMo (que usaba `String` para `categoria`/`rareza`), la implementación real usa **enums tipados** (`ItemData.Categoria`, `ItemData.Rareza`, `ItemData.Interaccion`) — más seguro en tiempo de compilación y acorde a `07-GUIA-GODOT.md` §2 (convención `PascalCase` → `CamelCase` para enums).

### ItemData.gd (Resource)

```gdscript
class_name ItemData
extends Resource

enum Categoria { MOBILIARIO_INTERIOR, DECORACION_PARED, ILUMINACION,
	PLANTAS_INTERIOR, ALFOMBRAS, COCINA, TRABAJO,
	EXTERIORES, NATURALEZA, CONSTRUCCION, HERRAMIENTAS,
	ITEMS, ROPA, ARTE_ANCESTRAL, EVENTO, SECRETO }

enum Rareza { COMUN, POCHO_COMUN, RARO, LEGENDARIO }

enum Interaccion { NINGUNA, SENTARSE, DORMIR, ALMACENAR, COCINAR,
	FABRICAR, ENCENDER, REGAR, COLOCAR_ITEM, MIRAR, ESCUCHAR,
	RECOGER, ROMPER, ABRIR_CERRAR }

@export var id: String
@export var categoria: Categoria
@export var rareza: Rareza
@export var interacciones: Array[Interaccion]
@export var tamano: Vector2i = Vector2i(1, 1)
@export var price_buy: int ...
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
