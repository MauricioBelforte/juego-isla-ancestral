**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. previa por ox-alpha + Deepseek)

**Plataforma:**Kilo Code

# 04-Codigo.md — Módulo 38: Economía

> Rutas previstas dentro de `res://economia/` (estructura del proyecto Godot 4.x).
> ⚠️ **Actualizado (ox-alpha/Cline, 2026-08-29):** La implementación real vive en `scripts/economia/` y `scripts/shops/` (no `economia/`). Núcleo de moneda, precios, límites por banda y minorista/mayorista implementados y verificados headless (Godot 4.7.2). Pendiente de implementar: trueque (BarterSystem), mercado con tabla diaria de oferta, ferias y helper de validación de catálogos.

## 1. Archivos Previstos

### 1.1 Scripts (GDScript, tipado)

| Archivo | Propósito | Estado |
|---|---|---|
| `scripts/economia/economy_manager.gd` | Autoload `EconomyManager`: saldo, transacciones monetarias, persistencia | **Implementado** (M38) |
| `scripts/economia/economy_price_catalog.gd` | `EconomyPriceCatalog` (class_name): catálogo central de precios (`econ_prices.tres`). Resource cacheado. PriceManager consulta los overrides de aquí antes de caer al ItemData base (M159). Sin acoplamiento a autoloads | **Implementado** (M38) |
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

**Modelo:** glm-5.3-flash (último modificador; núcleo/iter. 1 por Deepseek V4 Flash)

**Plataforma:**Kilo Code
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

---

## Notas del Agente — Iteración BarterSystem (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31 24:05:00
**Estado:** Parcial (BarterSystem implementado y verificado; módulo liberado 🟡)

### Lo que hice
- BarterOffer (Resource, scripts/economia/barter_offer.gd): pedido/entregado {item_id: cantidad}, amistad_minima (M20/RF8), estaciones (M29/RF7), es_salvavidas (RF12), limite_diario por oferta.
- BarterSystem (autoload "Barter", scripts/economia/barter_system.gd) según 03-Diseno §2.3/§3.4: propuestas_disponibles(npc_id) con gating amistad+temporada+límite (salvavidas siempre visible), ejecutar_trueque(npc_id, oferta_id) con validación dura + intercambio atómico vía M14 (remover todo-o-nada; si lo recibido no entra → rollback cozy del pedido), límites diarios por npc_id reseteados por dia_absoluto (M29/M30), señales trueque_exitoso/trueque_rechazado, log DOM-ECO-TRUEQUE, persistencia ISaveProvider M59 sección "barter" {dia, usos}.
- 3 ofertas .tres en data/economia/barter/: trueque_salvavidas (RF12, sin amistad ni temporada, no consume límite), trueque_finneas_herramienta (amistad 2, RF8), trueque_catalina_fibra (amistad 1, verano, límite 2).
- Test scripts/economia/test_barter.gd: carga, salvavidas RF12 (disponible sin monedas/amistad), atomicidad (inventario intacto tras rechazo), límite diario con motivo, RF8 (amistad sube → oferta aparece), temporada RF7, saldo jamás tocado → **0 fallos**.
- Regresiones: test_minorista_mayorista 14/0, test_topos_banda 11/0, test_tiendas M39 0 fallos, test_calendario M29 OK.
- Checklist: 7 ítems marcados (RF7, RF8, RF12, H×4). Progreso real 26/160.

### Lo que NO pude hacer (honestidad obligatoria)
- UI de trueque (M53/M39-capas): las señales quedan listas para la capa UI.
- Mercado/tabla diaria, ferias (M74), DOM-ECO restante: con dueño/próxima iteración.
- Ofertas de producción: las 3 .tres son semilla; el contenido final pertenece a M93/M20-narrativa.

### Recomendaciones para el próximo agente
- UI: escuchar Barter.trueque_exitoso/trueque_rechazado; usar propuestas_disponibles(npc_id) para el panel del NPC.
- Al sumar ofertas nuevas: una BarterOffer .tres por archivo en data/economia/barter/ (se cargan solas).
- El rollback cozy agrega de vuelta el pedido si lo recibido no entra: mantener ese orden al tocar ejecutar_trueque.

---

## Notas del Agente — Iteración 2: tabla del día + transacciones (historial)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 18:30
**Estado:** Iter.2 completada (test headless 29/0, Godot 4.7.2)

### Lo que hice
- Verifiqué la iteración 2 dejada en curso por glm-5.3-flash (Cline): `EconomyManager.tabla_del_dia()` (RF10) ya delega en `PriceManager.tabla_del_dia()` y expone `{compra, venta, limite, vendidas_hoy, rebajado}`.
- `RF15` historial de transacciones: `_registrar_tx` + señal `transaccion_registrada` + anillo `HISTORIAL_MAX=200` + `obtener_historial(limite)` devuelve copia defensiva.
- `RF13` parcial: `get_save_data()/restore_save_data()` persisten `historial` acotado con saneamiento defensivo (descarta no-diccionarios, clamp a HISTORIAL_MAX).
- Corregí el test `test_tabla_dia_transacciones.gd` para usar un ítem real con override de catálogo (`madera_roble`, compra=10 → venta=6) en lugar de un id inexistente; el test ahora pasa 29/29.
- Ejecuté el test headless y confirmé 0 fallos (sin regresión en el código fuente: no edité `economy_manager.gd` ni `price_manager.gd`).

### Lo que NO pude hacer (honestidad obligatoria)
- No implementé la persistencia de reputación ni de inventarios de tienda (RF13 completo sigue pendiente en M39).
- No edité el código fuente de price/economy: la iteración ya estaba implementada; solo faltaba el cierre de verificación + documentación.

### Recomendaciones para el próximo agente
- UI (M53/M55): consumir `EconomyManager.tabla_del_dia(ids)` para el panel de precios del día; refrescar al amanecer (M31) vía `tabla_precios_actualizada` (aún no emitida en esta iteración — ver pendientes de la sección I).
- M104 (analytics) ya puede suscribirse a `transaccion_registrada`.
- Para cerrar RF13: M39 debe persistir stock de tiendas e inventarios bajo la sección "economy" o su propia sección.

---

## Notas del Agente — Iteración 3: estación (RF9), anti-grind (RF11), reputación (RF13), ferias (RF14)

**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 20:35
**Estado:** Iter.3 completada (test headless 23/0, Godot 4.7.2; sin regresión: test_tabla_dia 29/0)

### Lo que hice
- **RF9 (mercado/estación):** `PriceManager._ajuste_estacional(item_id, base)` aplica +5% en la temporada del ítem (desde `PriceDefinition.temporada_bonus` en el catálogo) y -10% fuera. `recalcular_tabla_dia()` recalcula y emite `tabla_precios_actualizada` (gancho para el amanecer de M31). Estación resuelta con duck-typing: autoload `/root/TimeCalendar` o `ServiceRegistry.get_service("time_calendar")`.
- **RF11 (anti-grind):** `precio_venta_vigente()` ahora garantiza `venta <= precio_compra_vigente` aunque haya feria agresiva (reventa nunca rentable). El límite diario por banda ya existía (log 191).
- **RF13 reputación:** `EconomyManager` ganó `reputacion` (0-100, inicial 50), `get_reputacion()`, `ajustar_reputacion(delta)`, señal `reputacion_cambiada`, y persistencia en `get_save_data()/restore_save_data()`. Cada `depositar_monedas` suma +1 (cozy: solo crece).
- **RF14 (ferias):** `PriceManager.vincular_eventos()` conecta `evento_iniciado`/`evento_terminado` de `EventManager` (M73) por duck-typing. Al iniciar una feria lee `EventDefinition.flags["precio_compra"]` / `["precio_venta"]` y aplica/limpia multiplicadores con `aplicar_precios_feria()` / `limpiar_precios_feria()`. No acopla M73 (usa solo `flags` libre).
- **Test:** `test_mercado_estacion_ferias.gd` (23 checks) cubre RF9/RF11/RF13-rep/RF14. Ambos tests de M38 en 0 fallos.

### Lo que NO pude hacer (honestidad obligatoria)
- **RF13 completo:** la persistencia de **inventarios de tienda** queda en M39 (`ShopManager` aún no es un autoload en este repo; no implementé lo ajeno para no romperlo). saldo + historial + reputación SÍ persisten.
- No cableé físicamente la señal de amanecer de M31 a `recalcular_tabla_dia()` (el calendario no expone una señal estable documentada en este momento); el método existe y es llamable; la UI/calendar pueden invocarlo.

### Recomendaciones para el próximo agente
- M39: al implementar `ShopManager`, persistir stock bajo la sección "economy" (o propia) para cerrar RF13.
- M53/M55: suscribirse a `tabla_precios_actualizada` y a `reputacion_cambiada` para refrescar la pizarra del mercado y el indicador de reputación.
- M73: para activar ferias con precios especiales, basta poner `flags = {"precio_compra": 0.9, "precio_venta": 1.15}` en la `EventDefinition` del evento tipo feria.
- M31: al amanecer, llamar `EconomyManager.precios.recalcular_tabla_dia()` para refrescar ajustes estacionales.
