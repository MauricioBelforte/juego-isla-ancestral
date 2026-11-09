# Reporte: Economía, comercio y tiendas (`game/isla-ancestral/scripts`)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09  
**Alcance:** análisis estático de scripts GDScript relacionados con economía/comercio/tiendas/monedas.

## Archivos analizados

| Área | Archivo | Rol principal |
|---|---|---|
| Economía (núcleo) | `game/isla-ancestral/scripts/economia/economy_manager.gd` | Autoload: saldo, retirar/depositar, historial, reputación, persistencia (M59), delega precios a `PriceManager`. |
| Economía (precios) | `game/isla-ancestral/scripts/economia/price_manager.gd` | Cálculo de precios vigentes (compra/venta), descuentos amistad/volumen, estacionalidad, ferias, límites diarios, ventana de oferta. |
| Economía (catálogo) | `game/isla-ancestral/scripts/economia/economy_price_catalog.gd` | Carga/cachea `econ_prices.tres`, índice O(1), validación básica de overrides. |
| Economía (datos) | `game/isla-ancestral/scripts/economia/price_definition.gd` | `Resource` de override por `item_id` (compra/venta/rareza/temporada/variabilidad/revendible). |
| Economía (trueque) | `game/isla-ancestral/scripts/economia/barter_offer.gd` | `Resource` para ofertas de trueque sin moneda (RF7), amistad mínima, estaciones, salvavidas. |
| Economía (test smoke) | `game/isla-ancestral/scripts/economia/test_m38_economia_smoke.gd` | Verifica saldo/pago/retiro/depósito y existencia de métodos de precio consumidos por M39. |
| Tiendas (orquestador) | `game/isla-ancestral/scripts/shops/shop_manager.gd` | Autoload: registro, horario, compra/venta atómica con señales, restock, reputación de tienda, persistencia. |
| Tiendas (estado) | `game/isla-ancestral/scripts/shops/shop.gd` | Estado runtime por tienda: stock mutable, consultas de horario, serialización. |
| Tiendas (definición) | `game/isla-ancestral/scripts/shops/shop_data.gd` | `Resource` data-driven (tipo, dueño, horarios, catálogos, flags de mercader/festivales). |
| Tiendas (stock) | `game/isla-ancestral/scripts/shops/stock_generator.gd` | Generación/restock determinista por PRNG, filtros por estación/evento, básicos garantizados. |
| Tiendas (reputación) | `game/isla-ancestral/scripts/shops/reputacion_tienda.gd` | XP/niveles 0–5 sin decaimiento; desbloqueos/multiplicadores. |
| Tiendas (catálogo oficial) | `game/isla-ancestral/scripts/shops/catalogo_tiendas.gd` | Registra tiendas del prototipo (general, herrería, mercader viajero) y valida definiciones. |
| Tiendas (UI) | `game/isla-ancestral/scripts/shops/shop_ui.gd` | Panel modal: lista stock/precios, compra 1x/máx, venta 1x/máx; consume managers/autoloads, no muta inventario directo. |
| Contrato | `game/isla-ancestral/scripts/interfaces/i_tienda.gd` | Interfaz `ITienda` (superficie nueva, compatibilidad por defaults). |
| Datos | `game/isla-ancestral/data/economy/econ_prices.tres` | Overrides de precios (instancias `PriceDefinition` + `EconomyPriceCatalog`). |

Búsquedas realizadas: `glob` por `*economia*/*tienda*/*comercio*/*moneda*/*shop*/*trade*.gd` y `grep` por términos económicos en `game/isla-ancestral/scripts` (100 coincidencias devueltas por el límite de la herramienta; se priorizó lectura de núcleo economía/tiendas).

## 1) ¿Cómo se gestiona la economía interna?

### Núcleo monetario y transacciones
- `EconomyManager` es el autoload responsable del **saldo**, **retiros/depósitos**, **historial acotado** y **reputación con el pueblo**; explícitamente *no* conoce tiendas/trueques (`economy_manager.gd:5-11`).
- Estado y límites: saldo inicial `100`, tope `MAX_SALDO = 999999`, historial en anillo `HISTORIAL_MAX = 200`, reputación `0..100` (`:21-41`).
- Inicialización: crea/asegura `PriceManager` vía `preload` (evita race de autoloads), recalcula tabla diaria y vincula eventos; también conecta señales de amistad M20 por *duck-typing* y se registra como proveedor de guardado M59 (`:43-79,191-227`).
- API consumida por M39 (contrato citado en cabecera): `precio_compra_vigente`, `precio_venta_vigente`, `puede_pagar`, `retirar_monedas`, `depositar_monedas` (`:8-9,82-137`).
- `puede_pagar` solo acepta `total >= 0` y saldo suficiente (`:92-93`).
- `retirar_monedas` rechaza `total <= 0` o saldo insuficiente; si procede, descuenta, emite `saldo_cambiado` y registra transacción (`:99-111`).
- `depositar_monedas` rechaza `total <= 0`; si el saldo ya está en tope rechaza (evita “evaporar” monedas); aplica `mini(..., MAX_SALDO)`, cuenta recortes, emite cambio, registra **monto realmente acreditado** y suma reputación (`:113-137`).
- Historial: cada tx guarda `tipo/monto/saldo/dia/ts`, recorta a `HISTORIAL_MAX`, loguea `[DOM-ECO-TRX]` y emite `transaccion_registrada` (`:139-155`). `obtener_historial` devuelve copia/últimas N (`:164-169`).
- Persistencia: guarda saldo, estado serializado de precios, historial y reputación; restaura con clamp/saneamiento defensivo (`:192-227`).

### Cálculo de precios
- `PriceManager` (`class_name`, `RefCounted`) calcula precios con reglas “cozy” y anti-arbitraje: base desde catálogo/ItemData, **venta tope 50–60% de compra**, límite diario, ventana de oferta 3 días, descuentos por amistad/volumen, estacionalidad y ferias (`price_manager.gd:5-12,26-50,105-181`).
- Compra vigente (`precio_compra_vigente`): parte de base, aplica ajuste estacional/feria, interpola por `variabilidad_mercado`, combina descuento amistad+volumen con tope total 20%, aplica recargo opcional (`recargo_pct`, usado por mercader viajero) y clampa a `>= 1` (`:108-124`).
- Venta vigente (`precio_venta_vigente`): usa `_precio_venta_base` (tope 60% de compra, estacional, feria, oferta; maneja items solo-vendibles con `precio_venta` del catálogo), aplica rebaja al 50% si se excedió límite diario, y **clampa a no superar la compra vigente** cuando hay tope > 0 (anti-reventa rentable, fix BUG-047 v3) (`:146-181,183-195`).
- Límites diarios por banda de rareza (`comun/poco_comun/raro/epico`) y registro de ventas; al cruzar el límite emite `precio_rebajado` una vez (`:51-61,197-263`).
- Oferta/mercado: ventana de 3 días reduce precio hasta -10%; ferias aplican multiplicadores clampados 0.1–5.0; estación puede forzarse; caches de tabla/día y amistad se invalidan en eventos relevantes (`:32-34,398-424,486-549`).
- Fuente de precio base: override de `econ_prices.tres` primero, luego ItemData (M159) (`:468-484`); ítem solo-vendible usa `precio_venta` del catálogo (`:167-176`).

### Comercio/tiendas
- `ShopManager` coordina tiendas: registro, sincronización con `TimeCalendar`/`GameTime` (hora/día/estación), apertura/cierre, restock, mercader viajero, compra/venta y persistencia (`shop_manager.gd:48-116,147-206,298-346`).
- Compra (`comprar`): valida tienda existente, abierta, `cantidad > 0`, stock, presencia de `EconomyManager`/`Inventario` y método de precio; obtiene precio unitario de M38 (incluye NPC dueño y recargo de mercader, clamp `>=1`), calcula total, retira monedas; **transacción con reversión**: quita stock, intenta `inventario.agregar_items`; si falla, revierte stock y devuelve monedas (`:214-251`).
- Venta (`vender`): valida tienda/abierta/`cantidad > 0`/recompra permitida/sistemas; quita items del jugador primero; obtiene precio de M38 (clamp), deposita monedas y acumula stock en tienda; registra venta para mercado anti-grind si hay calendario; suma reputación de tienda (`:254-296`).
- `Shop` mantiene `stock_actual` y consultas puras de horario; `remover_stock`/`acumular_stock` solo mutan bajo flujo validado (nota en código) y `acumular_stock` respeta `catalogo_recompra` (`shop.gd:30-44,46-60`).
- `StockGenerator` genera/restocka con PRNG determinista, respeta básicos, filtros de estación/evento y tope por rareza; no corre por frame (`stock_generator.gd:6-8,18-98`).
- `catalogo_tiendas.gd` registra tiendas oficiales y hace validación dura al boot (errores bloquean registro); advierte si item IDs no existen en M15; mapea IDs históricos por BUG-106 (`:44-87,102-168`).
- `ShopUI` solo orquesta acciones sobre managers y refresca vista; no muta inventario/contenedores directamente (`shop_ui.gd:5-9,269-301,342-354`).

## 2) ¿Hay validación de precios y transacciones?

### Validaciones presentes
- **Montos/transacciones monetarias:** `retirar_monedas`/`depositar_monedas` rechazan `<= 0`; `puede_pagar` exige total no negativo y saldo suficiente; depósito en tope se rechaza con warning; recorte al tope contabiliza monto real (`economy_manager.gd:92-137`).
- **Cantidad de comercio:** `ShopManager.comprar` y `vender` rechazan `cantidad <= 0` antes de tocar stock/inventario (`shop_manager.gd:220-223,260-262`).
- **Precondiciones de tienda:** existencia, estado abierto (horario/festival/mercader presente), stock disponible, pertenencia a `catalogo_recompra`, disponibilidad de sistemas dependientes (`:159-172,214-231,254-270`).
- **Precio mínimo defensivo:** precios de compra/venta se fuerzan a `>= 1` en `PriceManager` y también en `ShopManager` (`price_manager.gd:124,159,162; shop_manager.gd:236,276`).
- **Reglas económicas de precio:** venta base limitada al 60% de compra; rebaja por exceso diario; venta vigente no puede superar compra vigente (cuando aplica); descuentos amistad+volumen tope 20%; feria clamp 0.1–5.0 (`price_manager.gd:26-49,146-161,398-401`).
- **Catálogo de overrides:** `EconomyPriceCatalog._validate` marca error si ítem comprable tiene `venta >= compra`, y si ítem solo-vendible tiene `precio_venta <= 0` (`economy_price_catalog.gd:46-56`). **Nota:** `_validate` está definido pero no se invoca desde `get_catalog`/`_ready` en el código leído; la protección depende de que otro flujo la ejecute.
- **Registro de tiendas oficiales:** `catalogo_tiendas._validar_tienda` exige `shop_id`, dueño (salvo mercader), calendario de mercader, catálogo no vacío, horario completo, sin duplicados; existencia M15 es warning (`catalogo_tiendas.gd:49-86`).

### Límites de validación observados
- No hay validación explícita de **límite superior** de `cantidad` (ej. tope razonable o contra `stock_actual` máximo lógico) en `ShopManager`; depende de que `cantidad` sea coherente y de las capacidades de `Inventario`/stock.
- `ShopManager.vender` no verifica el retorno de `depositar_monedas` (`:280`), por lo que una transacción puede quedar parcialmente aplicada si el depósito es rechazado (ver sección 3).
- La coherencia de IDs entre `econ_prices.tres` y catálogos de tienda/M15 muestra desajustes históricos (BUG-106 mapeado en `catalogo_tiendas.gd`, pero `econ_prices.tres` conserva IDs como `madera_roble/piedra_caliza/...`); esto afecta precios efectivos/validación de negocio, no la integridad de tipos.
- `Shop.acumular_stock` acepta `stock_max_cap` por parámetro (default 999) sin cap global de tienda derivado de definición/balance (`shop.gd:40-44`).
- No se observan **IDs de transacción/idempotencia** en compras/ventas; la atomicidad es procedimental y síncrona.

## 3) ¿Hay problemas de duplicación de monedas o items?

### Protecciones contra duplicación
- **Compra con rollback:** en `ShopManager.comprar`, el dinero se retira tras validar fondos; luego se quita stock y se intenta agregar al inventario. Si `agregar_items` falla, se revierte stock y se ejecuta `depositar_monedas(total)` para devolver el dinero (`shop_manager.gd:238-248`). Esto reduce riesgo de pérdida de monedas por inventario lleno y evita que el jugador quede con ítem sin haber pagado/stock inconsistente en ese fallo.
- `depositar_monedas`/`retirar_monedas` rechazan montos `<= 0`, evitando transacciones nulas que antes generaban efectos secundarios (comentarios de corrección 2026-11-08 en `economy_manager.gd:100-103,114-118`).
- `Shop.acumular_stock` solo acepta ítems presentes en `catalogo_recompra` (`shop.gd:41-42`), limitando inserción arbitraria en stock de recompra.

### Riesgos / hallazgos
1. **Pérdida de ítems del jugador en venta cuando el depósito monetario falla (integridad, no duplicación de monedas).**  
   - Flujo: `inventario.remover_items` ocurre primero (`shop_manager.gd:271-272`); luego se calcula precio, se llama `economia.depositar_monedas(total)` sin comprobar retorno, y se acumula stock en tienda (`:276-281`).  
   - `EconomyManager.depositar_monedas` devuelve `false` si `saldo >= MAX_SALDO` (tope lleno) o `total <= 0` (`economy_manager.gd:121-125,118-119`).  
   - Resultado posible: el jugador pierde ítems, la tienda gana stock, pero **no recibe monedas**. No duplica monedas, pero es una inconsistencia económica grave en borde de tope.

2. **Dependencia fuerte de la atomicidad/correctitud de `Inventario` (M14).**  
   - La compra asume que `agregar_items({item_id:cantidad})` es la fuente de verdad del éxito; si M14 reporta éxito sin agregar realmente, o falla parcialmente, la protección se degrada. No se observa verificación posterior de contenido del inventario tras el agregado.
   - La venta asume que `remover_items` quita exactamente la cantidad solicitada; igual dependencia.

3. **Sin protección explícita contra doble ejecución/UI repetida.**  
   - `ShopUI` conecta botones a `_comprar/_vender` que llaman directamente a `ShopManager` (`shop_ui.gd:269-301`). GDScript ejecuta en el hilo principal, pero un doble disparo rápido (doble señal, input duplicado, o reentrada por lógica futura) podría intentar dos operaciones antes de refresco visual. `ShopManager` revalida stock/fondos en cada llamada, lo que mitiga, pero no hay *debounce*/bloqueo transitorio ni token de operación.

4. **No se detectó duplicación directa por rollback de compra.**  
   - El patrón actual de compra revierte stock y monedas ante fallo de inventario (`shop_manager.gd:244-248`), que es el caso clásico de duplicación/pérdida en comercios mal ordenados.

## 4) Sugerencias de mejora (2)

### Mejora 1 — Hacer la venta verdaderamente atómica ante fallo de depósito
**Problema:** `vender()` puede retirar ítems del jugador y no acreditar monedas si `depositar_monedas` falla (ej. saldo en `MAX_SALDO`), dejando una transacción parcial (`shop_manager.gd:271-281`, `economy_manager.gd:121-125`).  
**Sugerencia:**
- Antes de remover ítems, calcular total y validar capacidad de acreditación. Como `depositar_monedas` puede recortar al tope, exponer un método como `puede_acreditar(total) -> {ok, acreditable}` o `simular_deposito(total)` en `EconomyManager`.
- Alternativamente, cambiar el orden/rollback: intentar depósito y, solo si acredita lo esperado (o aceptar política explícita de recorte), confirmar; si no, no remover ítems. Si se remueven primero, capturar retorno de `depositar_monedas` y **revertir** `inventario.agregar_items` + `shop.remover_stock` cuando retorne `false` o cuando `acreditado < total` y la política no lo permita.
- Emitir `venta_rechazada` con un motivo específico (p. ej. `SALDO_TOPE`/`DEPOSITO_RECHAZADO`) para feedback claro en UI/M43.

**Impacto:** elimina pérdida silenciosa de ítems y alinea la venta con la garantía de rollback ya aplicada en compra.

### Mejora 2 — Endurecer validación de catálogo y coherencia de IDs/precios
**Problema:** `EconomyPriceCatalog._validate` no se invoca en carga (`economy_price_catalog.gd:46-56,29-37`), y existen desajustes de `item_id` entre `econ_prices.tres` (IDs tipo `madera_roble`, `fibra_algodon`, `herramienta_basica`) y `catalogo_tiendas.gd` (mapea a IDs M15 tipo `wood`, `grass`, `OBJ-HER-001`) documentados por BUG-106. Esto puede dejar overrides sin efecto, provocar warnings tardíos o precios inesperados.
**Sugerencia:**
- Invocar `_validate()` tras cargar/construir índice en `get_catalog()` (o en un paso de arranque controlado) y registrar `[DOM-ECO-*]` con resultado.
- Añadir una verificación de consistencia en arranque (script de validación o en `catalogo_tiendas`/economía): cruzar IDs de `catalogo_venta`/`recompra` y claves de `econ_prices.tres` contra `ItemDatabase` (M15), reportando faltantes/huérfanos.
- Definir una fuente canónica de IDs (M15) y migrar `econ_prices.tres` a esos IDs, o mantener una tabla de alias explícita versionada. Incluir prueba automatizada que falle ante IDs desconocidos en catálogos oficiales.

**Impacto:** reduce errores de balance/precio por datos desalineados y hace que las reglas de validación de overrides sean efectivas en runtime/editor.

## Conclusión final

La economía interna está **bien separada por responsabilidades**: `EconomyManager` gestiona saldo/transacciones/persistencia, `PriceManager` centraliza precios con reglas anti-abuso (tope venta/compra, límites diarios, descuentos acotados, estacionalidad/ferias), y `ShopManager` orquesta tiendas con validaciones de estado, stock y cantidad, delegando siempre el precio a M38. La **compra** implementa un rollback razonable ante fallo de inventario, lo que mitiga duplicación/pérdida en ese caso. Sin embargo, la **venta** no revierte si el depósito monetario es rechazado (caso borde de saldo al tope), lo que puede provocar **pérdida de ítems sin pago**. También hay margen de mejora en la **validación efectiva del catálogo de precios** (`_validate` no se ejecuta en carga) y en la **coherencia de IDs** entre `econ_prices.tres`, catálogos de tienda y M15, que puede degradar la confiabilidad de precios y diagnósticos. No se observaron mecanismos directos de duplicación de monedas en el flujo normal leído; los riesgos principales son de integridad transaccional en bordes y de consistencia de datos.
