# Reporte: Economía, Comercio, Tiendas y Monedas (Glyph Cluster)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08  
**Alcance:** `game/isla-ancestral/scripts/economia/`, `game/isla-ancestral/scripts/shops/`, `game/isla-ancestral/scripts/interfaces/i_tienda.gd`, tests de integración/tienda relacionados.

---

## 1) ¿Cómo se gestiona la economía interna?

### 1.1 Moneda y saldo (M38 — `EconomyManager`)
- **Autoload Node** sin `class_name` (pitfall documentado): `game/isla-ancestral/scripts/economia/economy_manager.gd`.
- **Saldo interno**: `var saldo: int = SALDO_INICIAL` (100 AO, línea ~35). Tope `MAX_SALDO = 999999` (línea ~24).
- **Operaciones atómicas de moneda**:
  - `puede_pagar(total)` verifica `saldo >= total` (línea ~89).
  - `retirar_monedas(total)` descuenta solo si hay fondos; emite `saldo_cambiado` y registra transacción (líneas ~93–100).
  - `depositar_monedas(total)` rechaza negativos, hace `saldo = mini(saldo + total, MAX_SALDO)`, emite señal, registra transacción y ajusta reputación (+1 por ingreso honesto, líneas ~102–112).
- **Persistencia**: implementa `get_section_name()` / `get_save_data()` / `restore_save_data()` (sección `economy`), sanea historial y clamp de saldo/reputación al cargar (líneas ~166–200). Se registra como proveedor en `SaveManager` si existe (líneas ~69–72).
- **Historial**: anillo acotado `HISTORIAL_MAX = 200` con `{tipo, monto, saldo, dia, ts}`; log `DOM-ECO-TRX` (líneas ~27–29, 112–130).

### 1.2 Precios (M38 — `PriceManager`)
- `PriceManager` (`class_name PriceManager`, `RefCounted`) calcula precios vigentes; `EconomyManager` delega (`precio_compra_vigente` / `precio_venta_vigente`, `economy_manager.gd:79–87`).
- **Compra vigente** (`price_manager.gd:106–125`): parte de precio base (catálogo `econ_prices.tres` → `ItemData`), aplica ajuste estacional, feria, variabilidad por ítem, **descuento amistad (M20, cacheado)**, **descuento por volumen** (tramos 1/5/10/20, tope volumen 15%), tope total `DESCUENTO_TOTAL_MAX = 20%`, recargo opcional de mercader (`recargo_pct`, M39), clamp `maxi(1, final)`.
- **Venta vigente** (`price_manager.gd:141–155`): usa `_precio_venta_base` (tope 50–60% sobre compra, estacional, feria, oferta por ventana), aplica rebaja `FACTOR_EXCEDIDO_DIARIO = 0.5` si se superó límite diario; **anti-grind clave**: `if tope > 0 and final > tope: final = tope` donde `tope = precio_compra_vigente(item_id)` (línea ~151–154). Items sell-only usan precio de catálogo directo si no hay compra base (BUG-047 v3).
- **Límites diarios y oferta**: `LIMITE_VENTA_POR_BANDA` (común/poco_común/raro/épico), ventana de oferta 3 días con ajuste hasta -10% (`VENTANA_OFERTA_DIAS`, `AJUSTE_OFERTA_MAX`). `registrar_venta` invalida cache de tabla y emite `precio_rebajado` al cruzar límite (líneas ~258–272).
- **Cache**: tabla del día cacheada por día (`_cache_tabla_valida`, L.3), cache de descuento amistad invalidable por señal M20 (J.8).

### 1.3 Tiendas (M39 — `ShopManager` / `Shop` / `ShopData`)
- **`ShopManager`** (autoload Node, sin `class_name`, `scripts/shops/shop_manager.gd`): registra tiendas, sincroniza tiempo (M29/M30), controla apertura/cierre/festivales/mercader viajero, ejecuta **compra/venta**, restock diario/estacional, reputación de tienda del jugador (`ReputacionTienda`), persistencia de estado de tiendas.
- **`Shop`** (`RefCounted`, `shop.gd`): estado runtime mutable por tienda (`stock_actual` dict O(1), `fecha_ultimo_restock`, `mercader_presente`). Métodos: `tiene_stock`, `remover_stock` (clamp a 0), `acumular_stock` (solo si `catalogo_recompra` contiene el ítem, tope `stock_max_cap`), `esta_abierta` (días/franjas/descanso), serialización.
- **`ShopData`** (`Resource`, `shop_data.gd`): definición data-driven (tipo, NPC dueño, horarios, catálogos `StockEntry`, recompra, restock, recargo mercader, calendario aparición). `StockEntry` soporta estaciones, rareza, básicos garantizados y `evento_id`.
- **`CatalogoTiendas`** (`catalogo_tiendas.gd`): registra tiendas oficiales al arrancar (tienda general, herrería, mercader viajero). Validación dura `_validar_tienda`: exige `shop_id`, dueño en tiendas fijas, calendario para mercader, catálogos/horarios completos, sin duplicados; existencia en M15 se valida como warning.
- **UI** (`shop_ui.gd`): capa M53, solo consume `ShopManager/EconomyManager/Inventario`; botones 1x/máx; refresca saldo/catálogo/venta; no muta contenedores directamente.

### 1.4 Contrato y separación de responsabilidades
- M39 **no calcula precios**: delega en M38 (`precio_compra_vigente`/`precio_venta_vigente`). Referencias: `shop_manager.gd:165–168, 205–207`.
- Dependencias externas por `get_node_or_null` + `has_method` (duck-typing): `EconomyManager`, `Inventario`, `TimeCalendar`/`GameTime`, `SaveManager`, `ItemDatabase`, `Friendship`/M20, M73 eventos. El sistema degrada con rechazo `SISTEMA_NO_DISPONIBLE` o warnings.
- `ITienda` (`interfaces/i_tienda.gd`): interfaz `Resource` con defaults seguros (false/vacío/0) para implementadores parciales; **no está implementada directamente** por `Shop`/`ShopManager` actuales (superficie contractual nueva, sin romper consumidores).

---

## 2) ¿Hay validación de precios y transacciones?

### 2.1 Validaciones presentes (positivas)
| Área | Validación | Archivo:Línea |
|---|---|---|
| Compra M39 | Tienda existe, abierta (horario/festival/mercader), cantidad > 0, stock suficiente, sistemas M38/M14 disponibles, fondos suficientes | `shop_manager.gd:147–164` |
| Venta M39 | Tienda existe, abierta, cantidad > 0, ítem en `catalogo_recompra`, sistemas disponibles, jugador tiene ítems | `shop_manager.gd:186–202` |
| Precio M39 | Clamp defensivo `maxi(1, ...)` en compra y venta; precio siempre desde M38 | `shop_manager.gd:168, 207` |
| Moneda M38 | `puede_pagar` evita saldo negativo; `retirar_monedas` no descuenta si falla; `depositar_monedas` rechaza negativos y aplica `MAX_SALDO` | `economy_manager.gd:89–112` |
| Anti-arbitraje M38 | Venta nunca > compra vigente (`tope > 0`); tope base venta 50–60% compra | `price_manager.gd:62, 151–168` |
| Anti-grind M38 | Límite diario por banda, rebaja 50% al exceder, ventana oferta 3 días, tope descuentos totales 20% | `price_manager.gd:52–60, 70–71, 258–272, 112–120` |
| Catálogo M39 | Boot duro: dueño/horario/calendario mercader/catálogo vacío/duplicados; ítems M15 como warning | `catalogo_tiendas.gd:33–72` |
| Stock M39 | `remover_stock` usa `maxi(0, actual-cantidad)`; `acumular_stock` solo para ítems recomprables y con cap | `shop.gd:23–34` |
| UI M39 | Máximo compra calcula por stock, precio y saldo; no muta estado económico/inventario directamente | `shop_ui.gd:261–271` |

### 2.2 Transacción atómica (compra/venta)
- **Compra** (`shop_manager.gd:169–177`): orden cozy — monedas ya validadas; se remueve stock de tienda, se intenta `inventario.agregar_items`; si falla, **revierte stock y devuelve monedas** (`economia.depositar_monedas(total)`, BUG corregido según comentario). Emite éxito + cambio de inventario de tienda.
- **Venta** (`shop_manager.gd:199–220`): remueve ítems del inventario primero; si falla, no se deposita. Luego deposita monedas y acumula stock en tienda, emite éxito, registra venta para mercado (M38, día absoluto si disponible) y reputación.

### 2.3 Gaps / riesgos de validación
1. **No hay normalización estricta de montos en `EconomyManager`**: M39 filtra `cantidad <= 0`, pero otros consumidores podrían llamar APIs monetarias con montos borde. `retirar_monedas` permite `total == 0` (pasa `puede_pagar(0)` y descuenta 0), lo que puede ensuciar historial/telemetría sin efecto económico.
2. **Dependencia de contratos externos por duck-typing**: si `Inventario` o `EconomyManager` existen pero devuelven valores inesperados, el flujo puede comportarse mal. El código usa `bool(...)` en llamadas clave, lo cual mitiga parcialmente.
3. **`ITienda` no alineada con implementación real**: la interfaz expone `comprar/vender(item_id,cantidad)` devolviendo `bool`, pero `ShopManager` usa señales y `Shop` no implementa `ITienda`. No es bug activo; sí deuda contractual.
4. **Dominio temporal del restock**: `fecha_ultimo_restock`/recuperación de días perdidos usan contexto de día laborable; si cambia el dominio entre calendario/versiones, puede haber restocks inesperados. Riesgo bajo con M29 actual.
5. **Precio dinámico entre UI y ejecución**: la UI calcula máximos con precios vigentes; si el precio cambia antes del clic, `ShopManager` recalcula y puede rechazar por fondos. Consistente con “precio siempre de M38”, pero puede requerir feedback UX más específico.

---

## 3) ¿Hay problemas de duplicación de monedas o items?

### 3.1 Hallazgos: no se observó un exploit obvio de duplicación en el flujo normal
- **Compra**: las monedas se validan antes; el stock se remueve antes de agregar al inventario; si `agregar_items` falla, se hace rollback doble (stock + monedas). Esto evita perder dinero sin recibir ítem y evita duplicación en el camino feliz.
- **Venta**: se remueven ítems del inventario primero; si falla, no se deposita. Solo tras retiro exitoso se deposita y se acumula stock de tienda. Reduce riesgo de duplicar monedas sin consumir ítem.
- **Stock**: operaciones enteras con clamps (`maxi(0, ...)`, `mini(nuevo, stock_max_cap)`), diccionario por `item_id`.
- **Integración probada**: existe test headless `tests/integration/test_economy_npc_shop.gd` (guardia anti-falso-verde, 19 checks mínimos) que cubre compra/venta, fondos insuficientes, transacciones mixtas, señales y save/restore de economía.

### 3.2 Riesgos residuales (no confirmados como duplicación activa)
1. **Atomicidad depende de `Inventario.agregar_items/remover_items`**: si el inventario aplica cambios parciales y retorna un booleano ambiguo, M39 podría revertir/depositar incorrectamente. Se requiere contrato claro “todo o nada” o resultado con cantidades aplicadas. Punto sensible: `shop_manager.gd:171–175, 199–204`.
2. **Reentrada/concurrencia lógica**: no hay locks; en Godot el flujo típico de UI/señales corre en hilo principal. Riesgo bajo, pero llamadas rápidas válidas ejecutan transacciones independientes (esperado).
3. **Persistencia**: `ShopManager.guardar_estado/cargar_estado` duplica estructuras y maneja restock diferido/mercader; M38 persiste saldo aparte. No se observó duplicación cruzada.
4. **Efecto colateral no monetario en rollback**: `depositar_monedas` suma reputación (+1) en todo depósito. El rollback de compra llama `depositar_monedas` (`shop_manager.gd:174`), por lo que una compra fallida por inventario lleno puede **aumentar reputación** sin transacción neta de moneda. No duplica dinero/ítems, pero distorsiona la métrica de reputación.

---

## 4) Sugerencias de mejora (2)

### Mejora 1 — Reembolso económico explícito sin side effects + contrato transaccional con inventario
**Problema:** El rollback de compra usa `depositar_monedas`, que también ajusta reputación. Además, la atomicidad depende de un booleano de inventario sin detalle de aplicación parcial.

**Cambio propuesto:**
- En `EconomyManager`, agregar `reembolsar_monedas(total, motivo: String = "reembolso")` (o flag interno) que acredite saldo y registre transacción tipo reembolso **sin** `ajustar_reputacion(1)`.
- En `ShopManager.comprar`, reemplazar el rollback monetario por `economia.reembolsar_monedas(total, "rollback_compra")`.
- Formalizar contrato con inventario: retorno `Dictionary {ok: bool, agregados: int, rechazados: int}` o equivalente. Si no es todo-o-nada, cobrar/restock solo por lo aplicado.
- Tests: compra con inventario lleno => saldo neto 0, stock neto 0, reputación neta 0; venta con retiro parcial/fallido => sin depósito ni acumulación inconsistente.

**Impacto:** elimina efectos colaterales de rollback, mejora auditoría DOM-ECO-TRX y endurece atomicidad real.

### Mejora 2 — Alinear `ITienda`/API y endurecer guardas de entrada
**Problema:** `ITienda` no refleja el modelo real (servicio por señales + tienda runtime). Faltan guardas defensivas para montos/IDs en APIs públicas.

**Cambio propuesto:**
- Definir interfaz/contrato de servicio (ej. `IShopService`) coherente con `ShopManager` (métodos de comando + señales/documentación de eventos), o adaptar `Shop` solo a consultas (`esta_abierta`, `stock_de`, `id_tienda`, `precio_de` si delega).
- En `EconomyManager`, rechazar o no-op con log para `total <= 0` en `retirar_monedas/depositar_monedas` sin emitir `saldo_cambiado` ni transacción cuando no hay cambio.
- Validar `item_id.strip_edges() != ""` y `cantidad > 0` en puntos públicos de M38/M39; normalizar IDs donde aplique.
- Añadir test de regresión para el side effect de reputación en rollback y para `total == 0`.

**Impacto:** reduce deuda contractual (M139), facilita mocks/integración y evita ruido/efectos inesperados en economía.

---

## Conclusión final
La economía interna está **bien separada por responsabilidades**: M38 gestiona saldo, historial, persistencia y precios; M39 gestiona tiendas, horarios, stock, catálogos y orquesta transacciones contra M38/M14 con duck-typing. Hay **validaciones sólidas** en precios (anti-arbitraje, topes, descuentos, estacionalidad, límites/ventana) y en transacciones de tienda (apertura, stock, fondos, recompra, cantidad, rollback en compra). **No se identificó una duplicación directa de monedas o ítems** en el flujo principal revisado; los riesgos residuales se concentran en la dependencia del contrato todo-o-nada del inventario y en un side effect de reputación durante el rollback de compra. Las dos mejoras prioritarias son: (1) reembolso económico explícito sin side effects + contrato transaccional claro con inventario, y (2) alinear `ITienda`/API de servicio con la implementación real y endurecer guardas de montos/IDs.
