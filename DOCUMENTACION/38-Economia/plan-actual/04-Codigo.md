**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

# 04-Codigo.md — Módulo 38: Economía

> Rutas previstas dentro de `res://economia/` (estructura del proyecto Godot 4.x).
> ⚠️ **Actualizado (ox-alpha/Cline, 2026-08-29):** La implementación real vive en `scripts/economia/` y `scripts/shops/` (no `economia/`). Núcleo de moneda, precios, límites por banda y minorista/mayorista implementados y verificados headless (Godot 4.7.2). Pendiente de implementar: trueque (BarterSystem), mercado con tabla diaria de oferta, ferias y helper de validación de catálogos.

## 1. Archivos Previstos

### 1.1 Scripts (GDScript, tipado)

| Archivo | Propósito | Estado |
|---|---|---|
| `scripts/economia/economy_manager.gd` | Autoload `EconomyManager`: saldo, transacciones monetarias, persistencia | **Implementado** (M38) |
| `scripts/economia/price_manager.gd` | `PriceManager` (RefCounted): precios vigentes, minorista/mayorista, límites por banda, anti-arbitraje | **Implementado** (M38) |
| `res://economia/shop_manager.gd` | Autoload `ShopManager`: tiendas, stock, horarios, reabastecimiento | Pendiente de implementación |
| `res://economia/barter_system.gd` | Autoload `BarterSystem`: trueques, propuestas, límites diarios | Pendiente de implementación |
| `scripts/economia/test_edge_cases_precio.gd` | Test headless (SceneTree) de edge cases de precios | **Implementado** (log 235) |
| `scripts/economia/price_definition.gd` | Resource `PriceDefinition` (`.tres`): datos de precio de un ítem | **Implementado** (M38) |
| `res://economia/shop_definition.gd` | Resource `ShopDefinition` (`.tres`): datos de una tienda | Pendiente de implementación |
| `res://economia/barter_offer.gd` | Resource `BarterOffer` (`.tres`): propuesta de trueque | Pendiente de implementación |
| `res://economia/economy_validation.gd` | Helper de validación de catálogos en editor | Pendiente de implementación |

### 1.2 Recursos de datos (`.tres`) — editor

| Archivo | Propósito | Estado |
|---|---|---|
| `res://economia/data/economy_prices.tres` | Catálogo central de PriceDefinition | Pendiente de implementación |
| `res://economia/data/shops/tienda_pescaderia.tres` | Tienda del pueblo (ejemplo) | Pendiente de implementación |
| `res://economia/data/shops/tienda_agricola.tres` | Tienda agrícola (ejemplo) | Pendiente de implementación |
| `res://economia/data/shops/tienda_artesanias.tres` | Tienda de artesanías (ejemplo) | Pendiente de implementación |
| `res://economia/data/barter/trueque_cacao_lana.tres` | Oferta de trueque (ejemplo) | Pendiente de implementación |
| `res://economia/data/barter/trueque_pesca_herramienta.tres` | Oferta de trueque (ejemplo salvavidas) | Pendiente de implementación |

### 1.3 Señales externas consumidas

| Señal | Origen | Uso |
|---|---|---|
| `nivel_amistad_cambio(npc_id, nivel)` | M20 | Invalida caché de descuentos por amistad |
| `nuevo_dia_laborable(fecha)` | M29/M30 | Reabastece tiendas y recalcula mercado |
| `amanecer_hora(hora)` | M31 | Recalcular tabla del día (unión con M29) |
| `evento_iniciado(evento_id)` / `evento_finalizado(evento_id)` | M73 | Precios especiales de ferias |
| `agregar_items(entrega)` / `remover_items(pedido)` | M14 (via M15/M16) | Movimientos de inventario en transacciones |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- price_definition.gd ----------
class_name PriceDefinition
extends Resource

@export var item_id: StringName
@export var precio_compra_base: int = 0
@export var precio_venta_base: int = 0
@export var descuento_amistad_max: int = 15          # % tope (0-15)
@export var variabilidad_mercado: float = 0.5        # 0.0 (fijo) .. 1.0 (sensible)
@export var limite_venta_diario: int = 3
@export var temporada_bonus: StringName = &""        # "" = sin bono estacional
@export var revendible: bool = true

func validar() -> Array[String]:
    # Devuelve errores accionables (QA en editor); precio_venta < precio_compra, límites > 0...
    pass
```

```gdscript
# ---------- shop_definition.gd ----------
class_name ShopDefinition
extends Resource

@export var shop_id: StringName
@export var npc_duenio_id: StringName               # ref. M20
@export var nombre_clave_i18n: String                # clave de traducción
@export var dias_abierto: Array[int] = [1,2,3,4,5,6] # 1 = lunes (calendario M29)
@export var hora_apertura: int = 9                   # horas enteras
@export var hora_cierre: int = 17
@export var stock_por_estacion: Dictionary = {}      # estacion -> Array[{item_id, cantidad}]
@export var trueques: Array[Resource] = []           # BarterOffer
```

```gdscript
# ---------- barter_offer.gd ----------
class_name BarterOffer
extends Resource

@export var oferta_id: StringName
@export var amistad_minima: int = 0                  # nivel M20 (0-4)
@export var temporada: StringName = &""              # "" = todas
@export var pedido: Array[Dictionary] = []           # [{item_id, cantidad}]
@export var entregado: Array[Dictionary] = []        # [{item_id, cantidad}]
@export var limite_por_dia: int = 1                  # 0 = sin límite

func validar() -> Array[String]:
    pass
```

```gdscript
# ---------- economy_manager.gd (autoload "EconomyManager") ----------
extends Node

const MAX_SALDO: int = 999_999

signal saldo_cambiado(saldo_actual: int)
signal transaccion_registrada(tx: Dictionary)

var saldo: int = 0

func depositar_monedas(cantidad: int) -> void:
    pass    # clamp a MAX_SALDO + señal saldo_cambiado + log DOM-ECO-TRX

func retirar_monedas(cantidad: int) -> bool:
    pass    # false si saldo < cantidad; nunca negativo

func puede_pagar(cantidad: int) -> bool:
    return saldo >= cantidad

func guardar_estado() -> Dictionary:
    pass

func cargar_estado(data: Dictionary) -> void:
    pass
```

```gdscript
# ---------- price_manager.gd (autoload "PriceManager") ----------
extends Node

signal tabla_precios_actualizada(tabla: Dictionary)
signal precio_rebajado(item_id: StringName, antes: int, despues: int)

func precio_compra_vigente(item_id: StringName, npc_id: StringName) -> int:
    pass    # base + descuento amistad (M20) + ajuste mercado, clamp >= 1

func precio_venta_vigente(item_id: StringName) -> int:
    pass    # base + ajuste mercado + penalización por exceder límite diario

func limite_ventas_dia(item_id: StringName) -> int:
    pass

func ventas_hoy(item_id: StringName) -> int:
    pass

func registrar_venta(item_id: StringName, cantidad: int, fecha: int) -> void:
    pass    # actualiza ventana de oferta (3 días laborables)

func recalcular_tabla_dia() -> void:
    pass    # al amanecer/día laborable; PRNG M29; clamp [-10%, +10%] sobre base

func tabla_del_dia() -> Dictionary:
    pass    # item_id -> {compra, venta} vigentes (copia, solo lectura)
```

```gdscript
# ---------- shop_manager.gd (autoload "ShopManager") ----------
extends Node

signal compra_exitosa(shop_id: StringName, item_id: StringName, cantidad: int, total: int, precio: int)
signal compra_rechazada(shop_id: StringName, item_id: StringName, motivo: StringName)
signal venta_exitosa(vendedor_id: StringName, item_id: StringName, cantidad: int, total: int, precio: int)
signal inventario_tienda_cambio(shop_id: StringName, item_id: StringName, stock: int)

func esta_abierta(shop_id: StringName) -> bool:
    pass    # consulta pura al calendario/reloj (M29/M30/M31)

func stock_de(shop_id: StringName, item_id: StringName) -> int:
    pass

func comprar(shop_id: StringName, item_id: StringName, cantidad: int) -> Dictionary:
    pass    # validaciones → EconomyManager + M14; devuelve {ok, motivo?, total, precio}

func vender(vendedor_id: StringName, item_id: StringName, cantidad: int) -> Dictionary:
    pass    # limite diario → precio 50% de penalización; registro en PriceManager

func reabastecer_diario(fecha_laborable: int) -> void:
    pass    # repone stock base + rotación estacional (M29)

func lista_tiendas() -> Array:
    pass
```

```gdscript
# ---------- barter_system.gd (autoload "BarterSystem") ----------
extends Node

signal trueque_exitoso(npc_id: StringName, oferta_id: StringName, entregado: Array, recibido: Array)
signal trueque_rechazado(npc_id: StringName, oferta_id: StringName, motivo: StringName)

func propuestas_disponibles(npc_id: StringName) -> Array:
    pass    # filtra por amistad M20, temporada M29, límites diarios

func ejecutar_trueque(npc_id: StringName, oferta_id: StringName) -> Dictionary:
    pass    # validación atómica → M14 remover/agregar → señales

func limite_diario(npc_id: StringName) -> int:
    pass

func usos_hoy(npc_id: StringName) -> int:
    pass
```

## 3. Logs Relacionados (propuestos)

| Log | Contenido |
|---|---|
| `DOM-ECO-TRX` | Cada transacción monetaria: tipo (compra/venta), item_id, cantidad, precio unitario, total, saldo resultante, npc_id |
| `DOM-ECO-TRUEQUE` | Trueques: oferta_id, npc_id, pedido/entregado, amistad del momento |
| `DOM-ECO-MERCADO` | Recalculo diario: ajustes por ítem (base, estación, oferta, final), motivos |
| `DOM-ECO-SALDO` | Alertas: saldo máximo alcanzado, intentos de pago fallidos (solo debug) |
| `DOM-ECO-VALIDACION` | Errores de data en editor: precios inválidos, stock duplicado, trueques rotos |

Formato de línea de ejemplo: `[DOM-ECO-TRX] compra shop=tienda_pescaderia item=pescado_orilla cant=2 pu=20 total=40 saldo=310 npc=mareo`

## 4. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el diseño completo del módulo 38 (Economía): moneda única `monedas_aurora`, catálogo de precios data-driven, tiendas con horarios, trueque por amistad y mercado diario suave.
- Definí 4 autoloads desacoplados (`EconomyManager`, `PriceManager`, `ShopManager`, `BarterSystem`) con contratos de señales hacia M29/M30/M31/M73/M14/M20.
- Especifiqué rutas previstas (`res://economia/...`), firmas GDScript, persistencia y logs del módulo.
- Creada la dupla plan-inicial/plan-actual con los 5 archivos obligatorios del estándar (y checklist de 130 ítems).

### Lo que NO pude hacer (honestidad obligatoria)
- No hay código runtime: todo lo listado es diseño previsto, marcado "Pendiente de implementación".
- No se definieron los valores concretos de la tabla de balance (precios por ítem real): requieren decisión del diseñador de juego y el catálogo definitivo de M15/M16.
- La cantidad exacta de tiendas y sus dueños NPC depende de la población final del pueblo (M19/M20), no definida al 100% en este documento.
- No se verificó la estructura de carpetas final del proyecto Godot: `res://economia/` es la ruta propuesta por esta tarea; puede requerir ajuste a la convención global del repo.

### Recomendaciones para el próximo agente
- Implementar primero `PriceDefinition` + catálogo `economy_prices.tres` con 10-15 ítems de ejemplo de M15 (validación en editor incluida).
- Segundo: `EconomyManager` con persistencia mínima (saldo) y el flujo compra/venta contra M14.
- Depender de M29/M30/M31 para horarios y días laborables: confirmar los nombres reales de sus señales antes de conectar.
- Al conectar M20, verificar el nombre real de la señal de amistad y el rango de niveles (se asume 0-4).
- En `plan-actual/` copiar estos archivos y actualizarlos contra el código real a medida que se implemente.