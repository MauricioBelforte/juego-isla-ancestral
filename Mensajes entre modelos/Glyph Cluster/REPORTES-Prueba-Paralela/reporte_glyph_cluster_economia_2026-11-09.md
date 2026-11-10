# Reporte de análisis: Economía, comercio y tiendas

**Modelo:** Glyph Cluster (stealth)  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/scripts/economia/`, `game/isla-ancestral/scripts/shops/`, `game/isla-ancestral/scripts/security/security_economy_validation.gd`, integraciones con `scripts/inventario/` y `scripts/data/item_data*.gd`

---

## Archivos analizados (núcleo)

| Archivo | Rol |
|---|---|
| `scripts/economia/economy_manager.gd` (227 líneas) | Autoload M38: saldo, retiros/depósitos, reputación, historial, persistencia, delegación de precios. |
| `scripts/economia/price_manager.gd` (549 líneas) | Cálculo de precios vigentes (compra/venta), descuentos (amistad/volumen), estacionalidad, ferias, ventana de oferta, límite diario de venta, cachés. |
| `scripts/economia/economy_price_catalog.gd` (69 líneas) | Catálogo central (`econ_prices.tres`) con overrides de precios; índice O(1) por `item_id`. |
| `scripts/economia/price_definition.gd` (36 líneas) | Resource de definición de precio por ítem (compra/venta/rareza/variabilidad/temporada). |
| `scripts/economia/barter_system.gd` (214 líneas) | Autoload `Barter` M38: trueque sin moneda, validación por amistad/temporada/límite diario, intercambio atómico con rollback, persistencia. |
| `scripts/economia/barter_offer.gd` (28 líneas) | Resource de oferta de trueque. |
| `scripts/shops/shop_manager.gd` (346 líneas) | Autoload M39: registro de tiendas, horario/festivales/mercader viajero, compra/venta con transacción atómica, restock, persistencia. |
| `scripts/shops/shop.gd` (76 líneas) | Estado runtime de una tienda (stock mutable, horario puro, serialización). |
| `scripts/shops/shop_data.gd` (84 líneas) | Resource data-driven por tienda (catálogos, horarios, flags). |
| `scripts/shops/stock_generator.gd` (98 líneas) | Generación/reabastecimiento determinista de stock (canales: básicos, estación, eventos, rareza, PRNG). |
| `scripts/shops/catalogo_tiendas.gd` (168 líneas) | Catálogos definitivos del prototipo (tienda general, herrería, mercader viajero) + validación dura en boot. |
| `scripts/shops/shop_ui.gd` (367 líneas) | UI M53: catálogo/saldo/compra/venta; consume managers, no muta contenedores. |
| `scripts/shops/reputacion_tienda.gd` (80 líneas) | Reputación de tienda del jugador (niveles 0–5, sin decaimiento). |
| `scripts/security/security_economy_validation.gd` (91 líneas) | Helper M106: validación de rangos (`max_oro`, `max_objetos`) y checksum SHA-256 del bloque económico. |
| `scripts/inventario/inventario_service.gd` (444 líneas) | Autoload `Inventario` M14: autoridad de ítems, `agregar_items`/`remover_items` todo-o-nada, persistencia con saneamiento (BUG-108). |
| `scripts/inventario/inventario_contenedor.gd` (163 líneas) | Contenedor genérico: add en 2 pasadas, `remove_item` todo-o-nada, validación de cantidades/stack_max. |
| `scripts/inventario/inventory_slot.gd` (57 líneas) | Slot (id/cantidad/flags/instancia). |
| `scripts/data/item_data.gd` (95 líneas) | Resource `ItemData` M159: precios base, apilable/stack_max, rareza, validación (`es_valido`). |
| `scripts/data/item_database.gd` (parcial, ~120 líneas leídas) | Autoload catálogo de ítems (`res://data/items/*.tres`). |

Tests relacionados observados: `economia/test_m38_economia_smoke.gd`, `test_bug047_sell_only.gd`, `test_edge_cases_precio.gd`, `test_topos_banda.gd`, `test_tabla_dia_transacciones.gd`, `test_barter.gd`, `shops/test_tiendas*.gd`, `test_loop_economico.gd`, `test_m39_rendimiento_tienda.gd`, `test_catalogo_m39_m15.gd`, `security` implícito en validación.

---

## 1) ¿Cómo se gestiona la economía interna?

### 1.1 Núcleo monetario (M38)
- **Fuente de verdad del saldo:** `EconomyManager` (`economy_manager.gd`, autoload). Mantiene `saldo` (inicial `SALDO_INICIAL=100`, L21/L35), tope `MAX_SALDO=999999` (L24), reputación del pueblo `0..100` (L32–L34, L171–L180) e historial acotado en anillo `HISTORIAL_MAX=200` (L27, L38, L143–L155).
- **API transaccional:** `puede_pagar` (L92–L93), `retirar_monedas` (L103–L111), `depositar_monedas` (L113–L137). Emite `saldo_cambiado` y registra transacciones (`_registrar_tx`, L143–L155) con tipo/monto/saldo/día/timestamp y log `[DOM-ECO-TRX]` (L154).
- **Separación de responsabilidades:** el manager no conoce tiendas/trueques; delega precios a `PriceManager` (`PRICE_MANAGER_SCRIPT`, L13/L36/L44–L47/L82–L88) y expone `precio_compra_vigente`/`precio_venta_vigente` que M39 consume (contrato documentado L8–L9).
- **Reputación por comercio honesto:** cada depósito real ajusta reputación +1 (cozy, sin castigo; L135–L136). La amistad con NPC (M20) se integra para invalidar caché de descuentos (L51–L67, señal `nivel_amistad_cambio`).
- **Persistencia (ISaveProvider/M59):** sección `"economy"` guarda saldo, estado de precios, historial y reputación (L193–L203) y restaura con clamp/saneamiento defensivo (L205–L227).

### 1.2 Motor de precios (M38 `PriceManager`)
- **Precio base:** override desde `EconomyPriceCatalog`/`econ_prices.tres` primero, luego `ItemData.precio_compra` (L468–L484). Venta base = `compra * TOPE_VENTA_SOBRE_COMPRA (0.6)` + ajustes (L166–L181, L26–L27).
- **Ajustes dinámicos:** estacionalidad (L346–L362, ±5%/+10% según temporada), ferias/eventos M73 (L398–L464), ventana de oferta 3 días con saturación hasta -10% (L486–L500), variabilidad por ítem 0..1 (L126–L144), multiplicadores de feria.
- **Descuentos de compra (solo jugador paga menos, nunca se bonifica venta en volumen):** amistad M20 + volumen por tramos (1/5/10/20 → 0/5/10/15%), con tope total 20% (L38–L49, L108–L124, L502–L534). Cachés por NPC con invalidación (L74–L76, L516–L540).
- **Anti-grind:** límite diario de ventas por banda de rareza; excedido rebaja venta al 50% (`FACTOR_EXCEDIDO_DIARIO`, L28–L29, L150–L155, L244–L263). Registro de ventas en ventana/oferta y por día (L243–L263).
- **Rendimiento:** caché de `tabla_del_dia` invalidada por ventas/recálculo/feria/estación (L69–L72, L255, L273–L281, L342–L344, L403, L410, L418–L420).
- **Items solo vendibles (BUG-047):** se soporta `precio_compra=0` usando `precio_venta` del catálogo (L169–L176, L184–L195) y el clamp anti-reventa solo aplica si hay tope de compra > 0 (L156–L160).

### 1.3 Tiendas (M39 `ShopManager` + `Shop` + `ShopUI`)
- **Orquestación:** `ShopManager` registra tiendas, sincroniza tiempo (M29 `TimeCalendar` con fallback M30), maneja apertura/cierre por horario/festivales/mercader viajero, restock diario y rotación estacional (L48–L116, L147–L205, L298–L309).
- **Compra (`comprar`, L214–L251):** valida tienda/cierre/cantidad/stock/sistemas (M38+M14). Obtiene precio **siempre de M38** (L233–L236) con clamp `>=1`. Ejecuta **transacción atómica cozy**: retira monedas → descuenta stock → `inventario.agregar_items`; si el inventario falla, revierte stock y **devuelve monedas** (L241–L248). Emite señales y actualiza stock.
- **Venta (`vender`, L254–L296):** valida cierre/cantidad/recompra/sistemas/ítems del jugador. Remueve ítems del inventario, obtiene precio de M38 (clamp `>=1`), deposita, acumula stock en tienda. Registra venta para anti-grind de mercado usando `dia_absoluto` (L286–L290) y reputación de tienda (L292–L296).
- **Stock/horario:** `Shop` mantiene `stock_actual` (O(1) por `item_id`), consulta pura de horario (L48–L60) y serialización (incluye presencia de mercader, L62–L76). `StockGenerator` es determinista por PRNG y corre solo en eventos de día/estación/evento (no por frame).
- **Catálogos definitivos:** `catalogo_tiendas.gd` registra tienda general, herrería y mercader viajero con validación dura (errores bloquean registro), mapeo a IDs válidos de M15 (BUG-106 documentado) y avisos si `ItemDatabase` no resuelve ítems en boot.
- **UI:** `ShopUI` solo consume `ShopManager/EconomyManager/Inventario`, calcula máximos por saldo/stock (L272–L282) y delega transacciones; no muta contenedores directamente.

### 1.4 Trueque sin moneda (M38 `Barter`)
- Ofertas `.tres` en `res://data/economia/barter/`. Filtra por NPC, amistad mínima, temporada y límite diario; el salvavidas (RF12) ignora restricciones (L70–L86). `ejecutar_trueque` verifica pedido, remueve todo-o-nada, agrega entregado y hace rollback del pedido si no entra lo recibido (L91–L140). No toca `EconomyManager`. Persiste usos por día (sección `"barter"`).

---

## 2) ¿Hay validación de precios y transacciones?

**Sí, hay múltiples capas (con matices):**

### Precios
- **Catálogo/definiciones:** `EconomyPriceCatalog._validate()` exige `venta < compra` cuando `compra>0` y `venta>0` para solo-vendibles (`economy_price_catalog.gd` L47–L56). `PriceDefinition` tipa rareza/variabilidad/temporada.
- **Topes y clamps en cálculo:** venta limitada al 60% de compra (L26–L27, L177), resultados `maxi(1, ...)` (L124, L155, L161, L175, L181), ajuste de oferta acotado (L496–L500), descuentos acotados (amistad/volumen/tope total), recargo mercader aplicado sobre precio final (L120–L123).
- **Anti-arbitraje/anti-grind:** venta nunca supera compra vigente (L156–L160) salvo caso sell-only sin tope; límite diario por banda y rebaja al exceder (L150–L155, L197–L263); registro de venta para mercado (ShopManager L286–L290).
- **Fuente única:** tiendas/UI obtienen precios de M38 (`shop_manager.gd` L233–L236, L269–L277; `shop_ui.gd` usa `precio_compra_vigente`/`precio_venta_vigente`). `CatalogoTiendas` valida tiendas oficiales antes de registrar (L44–L86).

### Transacciones monetarias
- `EconomyManager`: rechaza montos `<= 0` en retiro/depósito (L103–L105, L117–L119), verifica fondos (L106–L107), aplica tope de saldo sin evaporar monedas (rechaza si tope lleno; L121–L130), registra monto **realmente acreditado** (L134), emite señales/log.
- `ShopManager` compra: validaciones de estado/cantidad/stock/fondos/sistemas (L215–L231). Atomicidad con rollback total ante fallo de inventario (L241–L248) — corrige pérdida de monedas previa (comentario L247). Venta: valida recompra/ítems del jugador (L261–L272), remueve antes de depositar, clamp defensivo de precio (L274–L277).
- `Barter`: validación completa + rollback si el recibido no entra (L122–L135).

### Transacciones de inventario (base de atomicidad)
- `Inventario.agregar_items` es todo-o-nada con reversión parcial si falla en cadena bolsillo→casa (`inventario_service.gd` L225–L237). `remover_items` valida primero en bolsillo+mochila+casa y luego remueve (L239–L254). `ContenedorInventario.add_item` devuelve sobrante (2 pasadas, stack_max) y `remove_item` verifica disponibilidad (L47–L97).

### Seguridad/persistencia
- `security_economy_validation.gd` valida rangos y checksum SHA-256 canónico (M106, L29–L58); usa vocabulario flexible (`oro/gold/plata`, `inventario/inventory`). No reemplaza al autoload `SecurityManager` (documentado L11–L13).
- `EconomyManager.restore_save_data` clampa saldo/reputación e historial (L205–L227). `Inventario` sanea claves/cantidades/stack_max al restaurar (BUG-108; L400–L429, `inventario_contenedor.gd` L122–L145).

### Brechas / matices observados
- **`security_economy_validation.gd` no está cableado** a `EconomyManager`/guardado/carga en los archivos revisados: existe como helper reutilizable, pero su uso efectivo depende de integración externa (M106/M59). Esto deja una capa de integridad declarada pero no necesariamente aplicada en runtime.
- **Validación UI del máximo comprable:** `shop_ui.gd` calcula `max_por_precio` (L281) pero llama `sm.comprar(..., clampi(mini(stock, max_por_precio), 0, stock))` (L282), lo que puede enviar una cantidad mayor a la que el saldo permite. No es crítico porque `ShopManager`/`EconomyManager` rechazan por fondos (L238, manager L106), pero es una validación redundante incompleta en UI.
- **`InventorySlot.deserializar`** crea el slot sin clamp de cantidad (L48–L57); el clamp fuerte ocurre en `ContenedorInventario.deserializar` (BUG-108, L141–L145). Correcto por capas, pero conviene mantener la defensa en profundidad consistente.

---

## 3) ¿Hay problemas de duplicación de monedas o items?

### Hallazgos principales: no se observaron exploits evidentes de duplicación en el flujo principal

**Monedas (compra/venta):**
- En **compra**, el orden es: precio de M38 → `retirar_monedas(total)` debe devolver `true` → se descuenta stock → se intenta `agregar_items`; si falla, se revierte stock y se hace `depositar_monedas(total)` (`shop_manager.gd` L233–L248). Esto evita pérdida de monedas; la reversión devuelve exactamente `total` retirado.
- En **venta**, se remueve inventario primero (`inventario.remover_items`) y solo si tiene éxito se deposita y acumula stock (`shop_manager.gd` L271–L284). No hay ruta obvia para acreditar monedas sin quitar ítems.
- `EconomyManager` rechaza montos `<=0` (corrige farmeo de reputación/tx nulas; L103–L105, L117–L119) y protege el tope sin acreditar de más (L121–L130). Historial registra el monto acreditado real (L134).
- **Riesgo teórico bajo:** si `depositar_monedas` fallara en el rollback de compra por tope lleno extremo (`saldo >= MAX_SALDO`), el jugador ya pagó y no recibe ítem/monedas; eso sería **pérdida**, no duplicación (y es un caso límite muy improbable con el flujo actual).

**Ítems (compra/venta/trueque):**
- `Inventario.agregar_items` revierte lo agregado si no cabe todo (L225–L237). `remover_items` es todo-o-nada con verificación previa (L239–L254). `ContenedorInventario` devuelve sobrante y no “crea” ítems sin capacidad (L47–L79).
- En **compra**, el stock de tienda se descuenta antes de agregar al inventario (L244–L245) y se revierte si falla (L246). Si la reversión del stock y el depósito ocurrieran en estado inconsistente por un fallo interno muy específico, podría haber desajuste; pero el código intenta revertir ambos y no hay copia del ítem al jugador en la rama de fallo.
- En **trueque**, se verifica el pedido, se remueve, y si no entra lo recibido se hace rollback del pedido (L122–L135). Patrón correcto anti-dup/anti-pérdida.
- `add_item` ignora favoritos al apilar (L59) y usa dos pasadas; no duplica, aunque puede dejar comportamiento de UX específico. `swap_items` copia datos (L111–141) — operación de intercambio, no creación.

**Persistencia / carga:**
- BUG-108 mitigado: claves no numéricas ya no clobberan bolsillo (L400–L421 en `inventario_service.gd`), cantidades se acotan a `stack_max` al deserializar contenedor (L138–145). `EconomyManager` clampa saldo al restaurar (L206). Esto reduce vectores de duplicación/inflación por saves manipulados, aunque no sustituye validación/integridad completa de archivo.

**Conclusión sobre duplicación:** no encontré un bug de duplicación obvio y reproducible en la lógica revisada. Las transacciones principales tienen intención atómica y rollbacks. Los riesgos restantes son más bien **de integridad no reforzada** (checksum/anti-tamper no integrado en el flujo vivo) y **casos límite extremos** que merecen tests dirigidos.

---

## 4) Dos mejoras sugeridas

### Mejora 1 — Integrar `SecurityEconomyValidation` al pipeline real de economía/guardado (integridad efectiva)
**Problema:** `scripts/security/security_economy_validation.gd` implementa validación de rangos y checksum SHA-256 (M106), pero no se observa integración en `EconomyManager.get_save_data/restore_save_data`, en el flujo de `SaveManager`/M59, ni en transacciones runtime. La protección queda “disponible” pero no aplicada.
**Propuesta concreta:**
- Definir un esquema canónico de bloque económico (p. ej. `oro/saldo` + inventario relevante o referencia a sección `inventory`) y generar/verificar `checksum` al guardar/cargar.
- En `restore_save_data` de economía (y/o validador global M106), rechazar o sanear datos con checksum inválido, valores fuera de rango, o inventario con cantidades negativas/excesivas, registrando `[DOM-ECO-SEC]`/warning sin crashear (modo cozy defensivo).
- Añadir tests headless: save válido pasa; oro negativo, ítems > `max_objetos`, checksum alterado → detectado.
- **Archivos a tocar (referencia):** `scripts/economia/economy_manager.gd` (L191–227), `scripts/security/security_economy_validation.gd` (L29–58), integración con M59 `SaveManager`/proveedores.

### Mejora 2 — Endurecer la UI de compra máxima y cubrir el rollback monetario en caso límite
**Problema:** `shop_ui.gd` calcula el máximo por precio pero no lo aplica al pasar la cantidad a `comprar` (`L281–L282`), confiando en el rechazo del backend. Además, el rollback de compra hace `depositar_monedas(total)` (shop_manager L247) sin verificar el resultado; si el tope estuviera lleno en un caso extremo, habría pérdida (no duplicación).
**Propuesta concreta:**
- En UI: `var cant := clampi(mini(stock, max_por_precio), 1, stock); if cant > 0 and (cant * precio) <= saldo: sm.comprar(...)` (ajustar con el mismo `precio` usado para la acción o recalcular). Mantener la validación backend como defensa final.
- En `ShopManager.comprar`: tras revertir stock, verificar `economia.depositar_monedas(total)`; si devuelve `false`, registrar error crítico `[DOM-ECO-TRX] rollback monetario falló`, emitir señal/telemetría y considerar una cola de compensación o al menos no silenciar el evento. Idealmente cubrir con un test que fuerce `MAX_SALDO` durante el rollback.
- **Archivos a tocar (referencia):** `scripts/shops/shop_ui.gd` (L272–L282), `scripts/shops/shop_manager.gd` (L241–248).

---

## Conclusión final

La economía interna de `Isla Ancestral` está **bien separada por responsabilidades**: `EconomyManager` (M38) gobierna saldo/persistencia/historial, `PriceManager` calcula precios con reglas anti-arbitraje/anti-grind y cachés, `ShopManager`/`Shop` (M39) orquestan comercio con tiempo/stock, `Barter` resuelve trueques sin moneda, y `Inventario` (M14) actúa como autoridad atómica de ítems. Se observan **validaciones relevantes** (montos > 0, topes de saldo, clamp de precios/venta≤compra, límites diarios, checks de stock/fondos/recompra, saneamiento en carga) y **transacciones con rollback** en compra, venta y trueque; no identifiqué un camino claro de **duplicación de monedas o ítems** en los flujos revisados. Los puntos de mejora más útiles son: (1) **integrar efectivamente** `SecurityEconomyValidation` en guardado/carga/runtime para pasar de validación declarada a integridad aplicada, y (2) **endurecer el máximo de compra en UI** y el manejo explícito de fallos del rollback monetario en casos límite extremos. En conjunto, el sistema es funcional y defensivo para un prototipo cozy, con margen para reforzar integridad y pruebas de borde.