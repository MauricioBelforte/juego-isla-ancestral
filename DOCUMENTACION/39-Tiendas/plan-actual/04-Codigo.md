**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 39: Tiendas

> Rutas previstas dentro de `res://tiendas/` (estructura del proyecto Godot 4.x).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Scripts (GDScript, tipado)

| Archivo | Propósito | Estado |
|---|---|---|
| `res://tiendas/shop_manager.gd` | Autoload `ShopManager`: registro de tiendas, compra, venta, restock, mercaderes | Pendiente de implementación |
| `res://tiendas/shop.gd` | Clase `Shop` (RefCounted): estado runtime de una tienda (definición + stock) | Pendiente de implementación |
| `res://tiendas/stock_generator.gd` | Clase `StockGenerator`: canalización de stock en 5 etapas | Pendiente de implementación |
| `res://tiendas/shop_definition.gd` | Resource `ShopDefinition` (`.tres`): datos de una tienda | Pendiente de implementación |
| `res://tiendas/shop_catalog.gd` | Resource `ShopCatalog` (`.tres`): catálogo por NPC (venta + recompra) | Pendiente de implementación |
| `res://tiendas/stock_entry.gd` | Resource `StockEntry` (`.tres`): ítem del catálogo con rangos y rotación | Pendiente de implementación |
| `res://tiendas/shop_validation.gd` | Helper de validación de catálogos y tiendas en editor | Pendiente de implementación |
| `res://tiendas/ui/shop_ui.gd` | Script de capa UI (M53): consume señales de ShopManager, muestra catálogo | Pendiente de implementación |

### 1.2 Recursos de datos (`.tres`) — editor

| Archivo | Propósito | Estado |
|---|---|---|
| `res://tiendas/data/puesto_semillas.tres` | Puesto de semillas (dueña: NPC agricultora) | Pendiente de implementación |
| `res://tiendas/data/pescaderia.tres` | Pescadería del pueblo | Pendiente de implementación |
| `res://tiendas/data/ferreteria.tres` | Ferretería (herramientas y materiales) | Pendiente de implementación |
| `res://tiendas/data/tienda_general.tres` | Tienda general | Pendiente de implementación |
| `res://tiendas/data/mercader_viajero.tres` | Mercader viajero (calendario + pool rodante) | Pendiente de implementación |
| `res://tiendas/data/catalogos/catalogo_semillas.tres` | Catálogo del puesto de semillas (ejemplo) | Pendiente de implementación |
| `res://tiendas/data/catalogos/catalogo_pesca.tres` | Catálogo de la pescadería (ejemplo) | Pendiente de implementación |
| `res://tiendas/data/catalogos/catalogo_ferreteria.tres` | Catálogo de la ferretería (ejemplo) | Pendiente de implementación |

### 1.3 Señales externas consumidas

| Señal | Origen | Uso |
|---|---|---|
| `nuevo_dia_laborable(fecha)` | M29 | Restock diario + evaluación de mercaderes |
| `estacion_cambio(estacion)` | M29 | Rotación estacional del catálogo efectivo |
| `prng_del_dia(prng)` | M29 | Semilla determinista para StockGenerator |
| `hora_actual(hora)` / `dia_actual(dia)` | M30 | Estado abierto/cerrado (consulta pura) |
| `evento_iniciado(evento_id)` / `evento_finalizado(evento_id)` | M73 | Etapa de eventos de la canalización |
| `agregar_items(entrega)` / `remover_items(pedido)` | M14 | Movimientos de ítems en transacciones |
| `saldo_cambiado(saldo)` | M38 | ShopUI actualiza saldo visible |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- shop_definition.gd ----------
class_name ShopDefinition
extends Resource

enum TipoTienda { SEMILLAS, PESCADERIA, FERRETERIA, GENERAL, VIAJERO }

@export var shop_id: StringName
@export var npc_duenio_id: StringName               # ref. M19/M20
@export var tipo_tienda: TipoTienda = TipoTienda.GENERAL
@export var nombre_clave_i18n: String                # clave de traducción
@export var dias_abierto: Array[int] = [1, 2, 3, 4, 5, 6]
@export var dias_descanso: Array[int] = []          # días cerrados (1-7)
@export var hora_apertura: int = 9
@export var hora_cierre: int = 17
@export var catalogo: ShopCatalog
@export var prob_diaria_aparicion: float = 0.0      # solo VIAJERO
@export var dias_fijos_aparicion: Array[int] = []   # solo VIAJERO
@export var recargo_compra: int = 0                 # % extra al jugador (VIAJERO)
@export var recargo_venta: int = 0                  # % descuento al jugador (VIAJERO)

func validar() -> Array[String]:
    # Errores accionables: npc_duenio_id vacío, horarios válidos, catálogo no nulo...
    pass
```

```gdscript
# ---------- shop_catalog.gd ----------
class_name ShopCatalog
extends Resource

@export var items_venta: Array[StockEntry] = []          # lo que la tienda vende
@export var items_recompra: Array[StringName] = []       # lo que la tienda recompra
@export var pool_rodante: Array[StockEntry] = []         # solo mercaderes viajeros

func validar() -> Array[String]:
    pass
```

```gdscript
# ---------- stock_entry.gd ----------
class_name StockEntry
extends Resource

@export var item_id: StringName
@export var stock_min: int = 1
@export var stock_max: int = 10
@export var restock_diario: int = 5
@export var peso_rareza: float = 1.0                   # >1 = más escaso
@export var temporadas: Array[StringName] = []         # vacío = todas
@export var solo_evento: StringName = &""              # "" = normal
```

```gdscript
# ---------- shop.gd (clase runtime) ----------
class_name Shop
extends RefCounted

var definicion: ShopDefinition
var stock_actual: Dictionary = {}                      # item_id -> cantidad
var fecha_ultimo_restock: int = -1
var mer_activo: bool = false                           # mercader viajero presente hoy
var catalogo_rodante: Dictionary = {}                  # VIAJERO: stock materializado

func obtener_stock(item_id: StringName) -> int:
    pass    # O(1); 0 si no está en el catálogo

func listar_stock() -> Array:
    pass    # [{item_id, cantidad}] ordenado por catálogo

func descontar_stock(item_id: StringName, cantidad: int) -> bool:
    pass    # false si stock < cantidad

func acumular_stock(item_id: StringName, cantidad: int) -> void:
    pass    # usa: recompra del jugador y restock

func esta_abierta(dia: int, hora: int) -> bool:
    pass    # consulta pura a definicion (dias_abierto/descanso/horario)
```

```gdscript
# ---------- stock_generator.gd (canalización) ----------
class_name StockGenerator
extends RefCounted

enum Modo { INICIAL, RESTOCK, APARICION }

func generar(definicion: ShopDefinition, contexto: Dictionary, modo: Modo) -> Dictionary:
    pass    # canalización completa: base → estación → eventos → aforo → PRNG

func generar_catalogo_rodante(definicion: ShopDefinition, contexto: Dictionary) -> Dictionary:
    pass    # pool_rodante → filtros → aforo por rareza → PRNG

func _etapa_base(entradas: Array[StockEntry]) -> Dictionary:
    pass

func _etapa_estacion(stock: Dictionary, estacion: StringName) -> Dictionary:
    pass    # descarta temporadas que no coinciden; sin borrar básicos garantizados

func _etapa_eventos(stock: Dictionary, eventos: Array) -> Dictionary:
    pass    # agrega solo_evento activos; reversible (D10)

func _etapa_aforo(stock: Dictionary, entradas: Array[StockEntry]) -> Dictionary:
    pass    # clamp min/max + peso_rareza

func _etapa_prng(stock: Dictionary, prng: RandomNumberGenerator) -> Dictionary:
    pass    # variación determinista dentro de rangos
```

```gdscript
# ---------- shop_manager.gd (autoload "ShopManager") ----------
extends Node

signal compra_exitosa(shop_id: StringName, item_id: StringName, cantidad: int, total: int, precio: int)
signal compra_rechazada(shop_id: StringName, item_id: StringName, motivo: StringName)
signal venta_exitosa(shop_id: StringName, item_id: StringName, cantidad: int, total: int, precio: int)
signal venta_rechazada(shop_id: StringName, item_id: StringName, motivo: StringName)
signal inventario_tienda_cambio(shop_id: StringName, item_id: StringName, stock: int)
signal tienda_abierta(shop_id: StringName)
signal tienda_cerrada(shop_id: StringName, proxima_apertura: String)
signal mercader_aparecio(npc_id: StringName, catalogo: Dictionary)
signal mercader_parto(npc_id: StringName)

const MOTIVOS := {
    "TIENDA_INEXISTENTE": &"tienda_inexistente",
    "CERRADA": &"cerrada",
    "SIN_STOCK": &"sin_stock",
    "SIN_FONDOS": &"sin_fondos",
    "INVENTARIO_LLENO": &"inventario_lleno",
    "NO_RECOMPRA": &"no_recompra",
    "SIN_ITEMS_JUGADOR": &"sin_items_jugador",
    "CANTIDAD_INVALIDA": &"cantidad_invalida",
}

var _tiendas: Dictionary = {}                          # shop_id -> Shop
var _stock_generator := StockGenerator.new()

func _ready() -> void:
    pass    # carga .tres de res://tiendas/data/ y valida catálogos

func _registrar_tienda(definicion: ShopDefinition) -> void:
    pass    # instancia Shop, stock inicial (INICIAL) y alta en _tiendas

func esta_abierta(shop_id: StringName) -> bool:
    pass    # delega a Shop.esta_abierta(dia M29, hora M30)

func stock_de(shop_id: StringName, item_id: StringName) -> int:
    pass

func listar_stock(shop_id: StringName) -> Array:
    pass

func lista_tiendas() -> Array:
    pass    # Array[Shop] activas (o todas, según flag)

func comprar(shop_id: StringName, item_id: StringName, cantidad: int) -> Dictionary:
    pass    # flujo 2.1: validaciones → M38 precio → transacción atómica → señales

func vender(shop_id: StringName, item_id: StringName, cantidad: int) -> Dictionary:
    pass    # flujo 2.2: recompra → M14 → M38 precio → depósito → señales

func reabastecer_diario(fecha: int) -> void:
    pass    # idempotente por fecha (Riesgo restock duplicado) + mercaderes

func actualizar_mercaderes(fecha: int, contexto: Dictionary) -> void:
    pass    # flujo 2.4: decide aparición/partida y regenera catálogo rodante

func guardar_estado() -> Dictionary:
    pass

func cargar_estado(data: Dictionary) -> void:
    pass    # recupera días perdidos: reabastecer_diario hasta fecha actual
```

```gdscript
# ---------- ui/shop_ui.gd (capa M53, desacoplado) ----------
extends Node

signal intencion_comprar(shop_id: StringName, item_id: StringName, cantidad: int)
signal intencion_vender(shop_id: StringName, item_id: StringName, cantidad: int)

func abrir_tienda(shop_id: StringName) -> void:
    pass    # pide listar_stock + precios (M38) + saldo (M38) y muestra

func _on_compra_exitosa(shop_id: StringName, item_id: StringName, cantidad: int, total: int, precio: int) -> void:
    pass    # feedback positivo + sonido (M43)

func _on_compra_rechazada(shop_id: StringName, item_id: StringName, motivo: StringName) -> void:
    pass    # feedback con motivo legible (nunca mensajes duros)

func _on_inventario_tienda_cambio(shop_id: StringName, item_id: StringName, stock: int) -> void:
    pass    # refresca fila del catálogo
```

## 3. Logs Relacionados (propuestos)

| Log | Contenido |
|---|---|
| `DOM-TIEN-COMPRA` | Compra: shop_id, item_id, cantidad, precio unitario, total, saldo resultante, npc_duenio |
| `DOM-TIEN-VENTA` | Venta: shop_id, item_id, cantidad, precio unitario, total, saldo resultante |
| `DOM-TIEN-RESTOCK` | Resumen diario por tienda: ítems repuestos, montos máximos alcanzados |
| `DOM-TIEN-MERCADER` | Aparición/partida de mercaderes: npc_id, día, catálogo rodante generado |
| `DOM-TIEN-CONFIG` | Advertencias de configuración: máximos gigantes, catálogos vacíos, ids inválidos |
| `DOM-TIEN-VALIDACION` | Errores de data en editor: tiendas sin dueño, horarios inválidos, ítems inexistentes |

Formato de línea de ejemplo: `[DOM-TIEN-COMPRA] compra shop=puesto_semillas item=semilla_zanahoria cant=5 pu=12 total=60 saldo=340 npc=luciana`

## 4. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el diseño completo del módulo 39 (Tiendas): tiendas como atributos de NPCs, cinco tipos (semillas, pescadería, ferretería, general, mercader viajero), catálogos por NPC, horarios y días de descanso (M29/M30), canalizaciones de stock (StockGenerator), compra/venta con precios delegados a M38 y mercaderes viajeros.
- Definí la arquitectura: `ShopManager` (autoload), `Shop` (RefCounted), `StockGenerator` (RefCounted) y `ShopUI` (capa M53 desacoplada), con contrato de señales hacia M14/M19/M29/M30/M38/M53/M73.
- Especifiqué rutas previstas (`res://tiendas/...`), firmas GDScript tipadas, persistencia con recuperación de días perdidos y logs `DOM-TIEN-*`.
- Creada la dupla plan-inicial/plan-actual con los 5 archivos obligatorios del estándar (checklist de 181 ítems).

### Lo que NO pude hacer (honestidad obligatoria)
- No hay código runtime: todo lo listado es diseño previsto, marcado "Pendiente de implementación".
- No se definieron los valores concretos de stock por ítem (dependen del catálogo final de M15 y de decisión del diseñador de balance).
- Los nombres y la cantidad exacta de tiendas/NPCs dependen de la población definitiva del pueblo (M19/M20).
- No se verificó la estructura de carpetas final del proyecto Godot: `res://tiendas/` es la ruta propuesta; puede requerir ajuste a la convención global del repo.
- La interfaz de M38 (`precio_compra_vigente`, `precio_venta_vigente`) se asume según el diseño de 38-Economia; si el nombre real de funciones difiere, ajustar.

### Recomendaciones para el próximo agente
- Implementar primero `ShopDefinition`/`ShopCatalog`/`StockEntry` y la validación en editor (dueño existente en M19, ítems existentes en M15, horarios válidos).
- Segundo: `StockGenerator` con sus 5 etapas y tests de determinismo (misma semilla → mismo stock): es el núcleo más riesgoso.
- Tercero: `Shop` + `ShopManager` con el flujo de compra y venta contra M14 y M38; confirmar los nombres reales de sus señales/funciones antes de conectar.
- Al conectar M29/M30, verificar los nombres reales de `nuevo_dia_laborable`, `estacion_cambio` y el PRNG del día.
- El autoload debe registrarse en `project.godot` con nombre `ShopManager` para que la UI (M53) y M38 lo consuman sin ciclos.
- En `plan-actual/` copiar estos archivos y actualizarlos contra el código real a medida que se implemente.