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

**Nota:** A diferencia del diseño original de MiMo (que usaba `String` para `categoria`/`rareza`), la implementación real usa **enums tipados** (`ItemData.Categoria`, `ItemData.Rareza`, `ItemData.Interaccion`) — más seguro en tiempo de compilación y acorde a `GUIA-GODOT/INDICE.md` (convención `PascalCase` → `CamelCase` para enums).

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
- Log 388: Iteración 1 — .tres x29, checklist ampliado
- Log 477: Iteración 2 — .tres x65 adicionales + tests ItemDatabase

## 6. Notas del Agente

**Modelo:** stepfun-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 22:51
**Estado:** Iter 2 completada — catálogo ampliado a 94 .tres + tests ItemDatabase

### Lo que hice
- Creé 65 archivos `.tres` adicionales en `data/items/` cubriendo COCINA (10), TALLER (5), EXTERIORES (5), NATURALEZA (5), CONSTRUCCION (5), HERRAMIENTAS (5), ITEMS (10), ROPA (5), ARTE_ANCESTRAL (5), EVENTO (5) y SECRETO (5).
- Amplié `tests/unit/data/test_item_data.gd` con 7 tests de `ItemDatabase`: autoload disponible, carga con items, `get_item`, `get_items_by_category`, `get_items_by_rarity` y `validar_ids_unicos`.
- Actualicé `05-Checklist.md` marcando `[x]` tests de catálogo y `[?]` honestos para integraciones pendientes.

### Lo que NO pudo hacer (honestidad obligatoria)
- No completé el 100% de objetos por categoría (quedan subcategorías y variantes pendientes).
- No cubrí `get_items_by_source` en tests.
- No integré consumos reales con M14/M16/M18/M39/M155 (dependen de módulos externos).

### Recomendaciones para el próximo agente
- Completar catálogo por categoría hasta >=300 objetos.
- Agregar tests de `get_items_by_source` y carga headless Godot.
- Integrar catálogo con M14/M16/M18/M39 cuando estén listos.

## 7. Integracion y Validacion (lote DeepSeek-V4.1-Flash, 2026-10-11)

Implementa la seccion "Integracion y Validacion" del `05-Checklist.md` (L210-L219).

- Validador: `scripts/data/validar_catalogo_m159.gd` (exit 0 sin hallazgos, 1 con hallazgos, 3 ciego).
- Suite headless: `scripts/data/test_catalogo_m159.gd` (17 checks / 0 fallos / EXIT 0 x3).

### 7.1 Medicion del catalogo (Godot 4.7.2 headless, 2026-10-11)

| Condicion (checklist) | Linea | Resultado medido | Estado |
|---|---|---|---|
| IDs unicos | L210 | 121 IDs / 0 duplicados / 0 sin id | OK |
| Toda categoria con objetos | L211 | 16/16 categorias (minimo 3 objetos) | OK |
| Todo objeto con icono | L212 | 0/121 con icono (`icono == null` en todos) | GAP |
| Interactivo con interaccion | L213 | 0 violaciones | OK |
| Colocable con tamano | L214 | 0 violaciones (todos `tamano >= (1,1)`) | OK |
| Objeto de tienda con precio | L215 | 0 sin ningun precio; 121 con `precio_venta>0`, 93 con `precio_compra>0` | OK |
| Total >= 300 objetos | L216 | 121 / 300 (faltan 179) | GAP |

**Gaps abiertos (medidos, no bloquean la suite):**
- L212: ningun `.tres` tiene `icono` asignado (M45 debe producir los `icon_*.png`).
- L216: el catalogo tiene 121 objetos; el objetivo de diseno es >= 300.

### 7.2 Integracion con M14 (Inventario)

Consumo REAL y medido: `scripts/inventario/inventario_service.gd` resuelve cada slot con
`get_node_or_null("/root/ItemDatabase")` + `db.get_item(s.item_id)` (L171-172 y L305-307).
Contrato: `ItemDatabase.get_item(id: String) -> ItemData` (null si el id no existe).

### 7.3 Integracion con M16 (Crafting)

`scripts/crafting/crafting_recipe.gd` declara `materiales: {item_id: cantidad}` y
`resultado_id: String` (L21, L23): todos los ids son ids del catalogo M159.
`crafting_service.gd` NO llama a `ItemDatabase` directamente; opera contra el inventario
(`inv.count_item(id)`), asi que la integracion es INDIRECTA (el id existe porque M14 lo
resolvio contra el catalogo). **No hay validacion** de que `materiales`/`resultado_id`
existan en `data/items/` -> deuda (validador de recetas).

### 7.4 Integracion con M18 (Casas)

**NO implementada.** `scripts/houses/furniture_data.gd` (`FurnitureData`) define su propio
esquema (`nombre`, `categoria: String`, `capacidad_slots`, `ancho/profundo/alto`,
`requiere_superficie`, `requiere_pared`) y **no tiene `item_id`**: el mueble de M18 no esta
vinculado a un `ItemData` de M159. `scripts/houses/house_decor.gd` (`HouseDecor`) coloca por
`mueble_id: String` (L72) contra ese esquema propio, sin consultar `ItemDatabase`.
La tabla de la seccion 1 afirmaba que `scripts/house/house_decor.gd` "coloca objetos del
catalogo" — es drift: la ruta real es `scripts/houses/house_decor.gd` y no hay vinculo por id.
Para cerrar la integracion, M18 debe agregar `item_id: String` a `FurnitureData` y validarlo
contra `ItemDatabase`.

