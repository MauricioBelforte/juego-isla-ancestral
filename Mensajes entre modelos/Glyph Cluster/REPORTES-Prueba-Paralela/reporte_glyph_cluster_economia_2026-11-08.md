# Reporte — Economía, Comercio, Tiendas y Monedas (Glyph Cluster)

**Fecha:** 2026-11-08  
**Ámbito analizado:** `game/isla-ancestral/scripts/economia/`, `game/isla-ancestral/scripts/shops/`, `game/isla-ancestral/scripts/security/`, pruebas de integración relacionadas.  
**Modelo/Plataforma:** Glyph Cluster / Kilo Code

## 1) ¿Cómo se gestiona la economía interna?

### Núcleo monetario (`EconomyManager`)
- **Archivo:** `game/isla-ancestral/scripts/economia/economy_manager.gd`
- **Responsabilidad:** saldo global del jugador, transacciones monetarias, reputación, historial, persistencia y puente con precios.
- **Saldo inicial/tope:** `SALDO_INICIAL = 100` (L21), `MAX_SALDO = 999999` (L24).
- **Consultas de precio:** delega en `PriceManager` (`precio_compra_vigente` L79-L81, `precio_venta_vigente` L83-L85).
- **Transacciones:**
  - `puede_pagar(total)` verifica monto no negativo y saldo suficiente (L89-L90).
  - `retirar_monedas(total)` rechaza si no alcanza, resta saldo, emite `saldo_cambiado` y registra transacción (L93-L99).
  - `depositar_monedas(total)` rechaza montos negativos, suma con `mini(..., MAX_SALDO)`, emite señales, registra transacción y aumenta reputación (L101-L109).
- **Historial (RF15):** anillo acotado a `HISTORIAL_MAX = 200` con `pop_front()` (L27-L28, L115-L127, L137-L141). Registra tipo, monto, saldo, día y timestamp; emite `transaccion_registrada`.
- **Persistencia (M59):** guarda/restaura saldo, precios, historial y reputación (`get_save_data` L168-L175, `restore_save_data` L177-L199). El saldo se clampa en carga (L178).
- **Reputación (RF13 parcial):** valor 0-100, solo crece por ingresos honestos (`ajustar_reputacion` L147-L152, llamada en depósito L108).

### Motor de precios (`PriceManager`)
- **Archivo:** `game/isla-ancestral/scripts/economia/price_manager.gd`
- **Responsabilidad:** calcular precio vigente de compra/venta con reglas anti-abuso y contexto de mercado.
- **Fuentes de precio:** catálogo económico (`_catalog_get` L97-L101, `_precio_base_compra` L468-L484) con fallback a `ItemDatabase`.
- **Compra vigente:** parte de base/catálogo, aplica ajuste estacional, multiplicador de feria, variabilidad por ítem, descuentos por amistad+volumen con tope total 20%, y recargo opcional de mercader (`precio_compra_vigente` L108-L124).
- **Venta vigente:** tope base `TOPE_VENTA_SOBRE_COMPRA = 0.6` (L26), ajustes estacionales/feria/oferta, rebaja 50% si excede límite diario, y clamp para que la venta no supere la compra vigente (`precio_venta_vigente` L146-L161, `_precio_venta_base` L166-L181).
- **Anti-grind:** límites diarios por banda de rareza (`LIMITE_VENTA_POR_BANDA` L56-L61, `limite_ventas_dia` L200-L202) y rebaja al exceder (`FACTOR_EXCEDIDO_DIARIO = 0.5`, L29, L153-L154, L256-L259).
- **Oferta/saturación:** ventana de 3 días ajusta precio a la baja hasta -10% (`VENTANA_OFERTA_DIAS` L32, `_ajuste_por_oferta` L489-L500, `_podar_ventana` L542-L549).
- **Estación/ferias:** integración duck-typed con calendario/eventos; recalcula e invalida caché (`forzar_estacion` L342-L344, `_ajuste_estacional` L349-L362, `aplicar_precios_feria` L399-L411, `vincular_eventos` L426-L464).
- **Cachés:** tabla del día, descuento por amistad e índice de catálogo para evitar trabajo repetido (L71-L76, L273-L280, `economy_price_catalog.gd` L23-L45).

### Definiciones de precio
- **Archivos:** `game/isla-ancestral/scripts/economia/price_definition.gd`, `game/isla-ancestral/scripts/economia/economy_price_catalog.gd`
- **Modelo de datos:** `PriceDefinition` define `item_id`, `precio_compra`, `precio_venta`, rareza, revendibilidad, variabilidad y temporada (L14-L36).
- **Catálogo:** carga `res://data/economy/econ_prices.tres`, cachea instancia e indexa por `item_id` (L13-L45, L61-L69).
- **Validación estática:** `_validate()` detecta overrides con venta >= compra y items solo-vendibles sin precio de venta válido (L46-L56). Nota: `_validate()` existe pero no se invoca explícitamente en `get_catalog()`.

### Tiendas (`ShopManager`/`Shop`)
- **Archivos:** `game/isla-ancestral/scripts/shops/shop_manager.gd`, `game/isla-ancestral/scripts/shops/shop.gd`, `game/isla-ancestral/scripts/shops/stock_generator.gd`
- **Responsabilidad:** registro de tiendas, horarios, presencia de mercader viajero, compra/venta con transacciones atómicas, restock y persistencia.
- **Dependencias opcionales:** `EconomyManager` (M38), `Inventario` (M14), tiempo/calendario (M29/M30), eventos/reputación; usa duck-typing y rechaza con `SISTEMA_NO_DISPONIBLE` si faltan sistemas clave (L227-L231, L266-L270).
- **Compra (jugador compra):** valida tienda/cierre/cantidad/stock, obtiene precio de M38, retira monedas, remueve stock, agrega al inventario; si inventario falla revierte stock y monedas (L214-L251). Esto evita pérdida de monedas en fallo de inventario.
- **Venta (jugador vende):** valida tienda/cierre/cantidad/recompra/inventario, obtiene precio de M38, remueve ítems, deposita monedas, acumula stock, registra venta para mercado anti-grind y reputación (L254-L296).
- **Stock/horarios:** `Shop` maneja stock mutable y consultas puras de horario (`tiene_stock` L31-L32, `remover_stock` L35-L37, `acumular_stock` L40-L44, `esta_abierta` L48-L60).
- **Restock:** `StockGenerator` genera/reabastece con PRNG determinista, canales por estación/evento/rareza, y mínimos garantizados para básicos (L19-L98).

### Trueque (`BarterSystem`)
- **Archivo:** `game/isla-ancestral/scripts/economia/barter_system.gd`
- **Responsabilidad:** intercambio objeto-por-objeto sin moneda, con filtros por amistad/temporada/límite diario y salvavidas.
- **Ejecución:** valida oferta/NPC/amistad/temporada/límite, verifica ítems pedidos, remueve pedido atómicamente vía inventario; si no puede entregar lo recibido hace rollback del pedido (`ejecutar_trueque` L91-L140). No toca monedas.
- **Persistencia:** sección `barter` con día y usos (L200-L214).

### Validación de seguridad económica
- **Archivo:** `game/isla-ancestral/scripts/security/security_economy_validation.gd`
- **Responsabilidad:** helper puro para validar rangos de oro/inventario y checksum SHA-256 del bloque económico (`validar_economia` L31-L40, `validar_economia_checksum` L44-L45, `calcular_checksum_economia` L49-L58).
- **Alcance:** acepta vocabulario alternativo (`gold/inventory/quantity` y variantes). No reemplaza al autoload `SecurityManager`; complementa con límites parametrizables y checksum.

## 2) ¿Hay validación de precios y transacciones?

**Sí, hay validación en varios niveles, pero con huecos.**

### Validaciones presentes
- **Monedas:** rechaza retiro si `total < 0` o saldo insuficiente; rechaza depósito negativo; clampa saldo al máximo (`economy_manager.gd` L89-L109, L178).
- **Precios de compra:** si base <= 0 devuelve 0; clamp final a `>= 1`; descuentos limitados (amistad+volumen <= 20%); recargo opcional aplicado sobre precio calculado (`price_manager.gd` L108-L124).
- **Precios de venta:** tope 60% de compra, rebaja por límite diario, ajuste por oferta/estación/feria, venta nunca mayor que compra vigente cuando hay precio de compra (`price_manager.gd` L146-L181).
- **Catálogo:** detecta inconsistencias de override (venta >= compra; sell-only sin precio) en `_validate()` (`economy_price_catalog.gd` L46-L56).
- **Tiendas:** valida existencia, apertura, cantidad > 0, stock, recompra permitida, disponibilidad de sistemas, fondos del jugador, ítems del jugador (`shop_manager.gd` L214-L276). Precio final de compra/venta se clampa defensivamente a `>= 1` (L236, L276).
- **Trueque:** valida oferta, NPC dueño, amistad, temporada, límite diario, inventario disponible y rollback si falla entrega (`barter_system.gd` L91-L140).
- **Seguridad anti-trampa (helper):** valida rangos de oro/cantidades y checksum de bloque económico (`security_economy_validation.gd` L31-L58).
- **Pruebas de integración:** cubren compra/venta, saldo insuficiente, señales, persistencia e interacción inventario-economía (`tests/integration/test_economy_npc_shop.gd`, `tests/integration/test_inventory_economy.gd`).

### Huecos / riesgos de validación
- **`EconomyManager.retirar_monedas/depositar_monedas` no tratan explícitamente cantidades `== 0` como inválidas operativas.** Retirar 0 puede “pasar” sin cambiar saldo pero emite señales/registro (L93-L99); depositar 0 suma reputación y registra transacción (L101-L109). No es corrupción directa, pero puede contaminar historial/métricas y otorgar reputación gratuita si alguien llama la API con 0.
- **`PriceManager._ajuste_estacional` multiplica el precio de venta base con `TEMPORADA_BONUS_COMPRA` (+5%)** (L349-L359). El nombre sugiere compra; aplicado también a venta (porque `_precio_venta_base` llama `_ajuste_estacional`, L178). Esto puede inflar venta en temporada y acercarla al clamp de compra vigente. No rompe invariantes por el clamp final, pero es confuso y puede distorsionar balance.
- **Validación de catálogo no se ejecuta al cargar.** `EconomyPriceCatalog._validate()` existe pero `get_catalog()` no la llama (L30-L37, L46-L56). Overrides inválidos podrían pasar inadvertidos hasta causar efectos de balance.
- **ShopManager confía en que `precio_compra_vigente`/`precio_venta_vigente` representen reglas completas de M38.** Hace clamp `maxi(1, ...)` defensivo, pero no valida coherencia económica adicional (p. ej. precio de venta 0 legítimo/ilegítimo según diseño, límites diarios externos, moneda fraccionaria). La delegación es correcta por arquitectura, pero la superficie depende de M38.

## 3) ¿Hay problemas de duplicación de monedas o items?

### Hallazgos principales
- **Riesgo mitigado en compra de tienda:** en `ShopManager.comprar`, el orden es retirar dinero → remover stock → agregar al inventario; si `agregar_items` falla, revierte stock y **devuelve monedas** (L238-L248). Esto corrige el caso clásico de “dinero perdido”, y no duplica ítems porque el ítem solo entra si `agregar_items` devuelve éxito.
- **Riesgo mitigado en venta de tienda:** en `ShopManager.vender`, primero remueve ítems del jugador; solo si la remoción tiene éxito deposita monedas y acumula stock (L271-L284). No deposita sin haber retirado ítems.
- **Riesgo mitigado en trueque:** remueve pedido, intenta entregar recibido, y si falla hace rollback del pedido (`barter_system.gd` L127-L135). Es patrón atómico con reversión.
- **No se observó duplicación directa obvia** en los flujos revisados (compra, venta, trueque, depósito/retiro). Las operaciones críticas usan checks previos y rollback.

### Riesgos residuales / condiciones a vigilar
- **Atomicidad depende de `Inventario` (M14) y sus contratos.** `ShopManager` y `BarterSystem` asumen que `agregar_items`/`remover_items` son fiables y coherentes. Si M14 tuviera bugs (éxito parcial reportado como éxito total, o rollback interno inconsistente), podrían aparecer duplicaciones/pérdidas. La evidencia revisada no muestra ese bug, pero la seguridad económica depende de esa capa.
- **Persistencia separada (economía, tiendas, barter, inventario).** Cada sistema serializa por separado (`EconomyManager.get/save`, `ShopManager.guardar_estado/cargar_estado`, `Barter.get_save_data/restore_save_data`). Si el guardado/carga no es transaccional a nivel global, una falla entre secciones podría dejar estados inconsistentes (ej. monedas guardadas y stock no, o inventario sí). Esto es más un riesgo de consistencia/rollback de save que de duplicación en runtime.
- **Señales/registro en operaciones neutras (0).** No duplican recursos, pero pueden inflar métricas o reputación si se abusa de llamadas con 0 (`economy_manager.gd` L93-L109). En un contexto de explotación de API interna/modding, conviene endurecer.
- **No hay límites visibles de cantidad máxima por transacción en tienda.** `cantidad <= 0` se rechaza, pero cantidades extremadamente grandes dependen de stock/dinero/inventario. El `total` es `precio * cantidad` (int). En Godot/GDScript el riesgo práctico depende del tipo y validaciones de M14/M38; conviene validar un tope razonable para evitar abusos o estados extremos.

## 4) Sugerencias de mejora (2)

1. **Endurecer transacciones monetarias contra montos neutros/extremos y ejecutar validación del catálogo al cargar.**
   - En `economy_manager.gd`, tratar `total == 0` como operación inválida (`return false`) o como no-op sin emitir señales/registrar historial/ajustar reputación (L93-L109). Añadir tope defensivo de monto por transacción (ej. `total <= MAX_SALDO` o límite de negocio) para evitar estados absurdos.
   - En `economy_price_catalog.gd`, invocar `_validate()` dentro de `get_catalog()` tras cargar o en `_init` controlado (L30-L37, L46-L56), registrando errores con contexto del recurso. Así los overrides inválidos se detectan temprano.
   - Beneficio: menos contaminación de historial/reputación, mejor integridad de datos de precios y detección temprana de configuración errónea.

2. **Hacer la compra/venta de tienda más robusta ante fallos parciales y cantidades extremas.**
   - En `shop_manager.gd`, validar `cantidad` con un tope superior configurable (ej. `MAX_UNIDADES_TRANSACCION`) además de `<= 0` (L222-L223, L260-L262). Rechazar si `precio <= 0` o `total <= 0` antes de retirar/remover.
   - Considerar un patrón de “pre-validación + confirmación”: verificar capacidad de inventario antes de retirar monedas en compra, si M14 expone una API de `puede_agregar`/espacio estimado. Mantener el rollback actual como red de seguridad.
   - En venta, si `depositar_monedas` fallara en el futuro (por cambios de contrato), evitar que quede el ítem removido sin compensación; hoy `depositar_monedas` solo falla con negativo, pero conviene contrato explícito.
   - Beneficio: reduce riesgo de exploits por cantidades extremas y mejora la consistencia ante cambios futuros en inventario/economía.

## Conclusión final

La economía interna está razonablemente estructurada: `EconomyManager` centraliza saldo, historial y persistencia; `PriceManager` concentra reglas de precios con controles anti-arbitraje/anti-grind (tope venta/compra, límites diarios, oferta, estación, feria, descuentos acotados); `ShopManager` orquesta compra/venta con validaciones y rollbacks; `BarterSystem` realiza trueques sin moneda con rollback; y existe un helper de seguridad para rangos/checksum.

No se identificó una duplicación directa evidente de monedas o ítems en los flujos revisados. Las mitigaciones más claras son el reembolso de monedas si falla agregar al inventario en compra (`shop_manager.gd` L238-L248) y los rollbacks en venta/trueque. Sin embargo, la integridad depende fuertemente de contratos correctos en `Inventario` (M14) y de la consistencia entre guardados parciales de sistemas.

Los principales puntos a mejorar son: (1) endurecer montos neutros/extremos y activar la validación del catálogo al cargar; (2) reforzar límites/validaciones defensivas en transacciones de tienda y pre-validación de capacidad cuando sea posible. Con esos ajustes, el sistema ganaría robustez ante configuraciones inválidas, métricas contaminadas y casos borde de explotación.