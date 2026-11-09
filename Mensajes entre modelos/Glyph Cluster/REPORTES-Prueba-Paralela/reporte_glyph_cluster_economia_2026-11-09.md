# Reporte: Economía, comercio, tiendas y monedas (M38/M39/M164)

**Fecha:** 2026-11-09  
**Modelo:** Glyph Cluster  
**Alcance analizado:** `game/isla-ancestral/scripts/economia/`, `game/isla-ancestral/scripts/shops/`, `game/isla-ancestral/scripts/combat/gem_currency.gd`, `game/isla-ancestral/scripts/interfaces/i_tienda.gd`, `game/isla-ancestral/scripts/herramientas158/shop_visitor.gd`, y contratos de inventario consultados en `game/isla-ancestral/scripts/inventario/inventario_service.gd` / `inventario_contenedor.gd`.

> Nota: no existe carpeta `scripts/tienda/` ni `scripts/comercio/`; el dominio de tiendas está en `scripts/shops/` y el de economía en `scripts/economia/`.

---

## 1) ¿Cómo se gestiona la economía interna?

### 1.1 Moneda principal (AO/saldo del jugador) — M38
- **`game/isla-ancestral/scripts/economia/economy_manager.gd`** (autoload `EconomyManager`, sin `class_name`, L10–11) centraliza el **saldo** (`saldo`, inicial `SALDO_INICIAL=100`, L21–35) y las transacciones monetarias (`puede_pagar`, `retirar_monedas`, `depositar_monedas`, L91–137).
- Delega **precios vigentes** a `PriceManager` (`precios = PRICE_MANAGER_SCRIPT.new()`, L13–14,44,71–88). Contrato explícito consumido por tiendas: `precio_compra_vigente`, `precio_venta_vigente`, `puede_pagar`, `retirar_monedas`, `depositar_monedas` (L8–9).
- Emite señales de contrato (`saldo_cambiado`, `transaccion_registrada`, `reputacion_cambiada`, L16–18) y registra transacciones en un **historial acotado** (`HISTORIAL_MAX=200`, anillo, L26–29,143–169).
- Persiste estado vía interfaz duck-typed de guardado M59 (`get_section_name/get_save_data/restore_save_data`, L193–227), incluyendo saldo, precios, historial y reputación (clamp 0..100, L32–37,171–180,224–226).
- Aplica tope de saldo `MAX_SALDO=999999` (L24) y rechaza depósitos/retiradas inválidas (L99–137).

### 1.2 Formación de precios — M38
- **`game/isla-ancestral/scripts/economia/price_manager.gd`** (`class_name PriceManager`, L14–15) calcula precios con reglas “cozy/anti-arbitraje” (L6–12,25–61): tope de venta sobre compra (`TOPE_VENTA_SOBRE_COMPRA=0.6`, L26), rebaja por exceder límite diario (`FACTOR_EXCEDIDO_DIARIO=0.5`, L29), ventana de oferta 3 días con ajuste hasta -10% (L32–33,486–500), descuentos por amistad M20 (L36,516–540), descuento por volumen con topes (`DESCUENTO_VOLUMEN_MAX=0.15`, `DESCUENTO_TOTAL_MAX=0.20`, L38–49,504–510), límites diarios por banda (L52–61,197–237), estacionalidad/ferias y variabilidad por ítem (L81–88,339–465).
- `precio_compra_vigente` aplica mercado, variabilidad, amistad+volumen (tope total), recargo de mercader opcional y clamp `>=1` (L108–124). `precio_venta_vigente` aplica rebaja por límite diario, anti-grind “venta nunca supera compra vigente” cuando hay precio de compra (`tope > 0`, L146–161) y maneja ítems solo vendibles por catálogo (L166–195).
- Cachea tabla del día y descuenta amistad con invalidación (L70–76,273–280,539–540); expone señales `tabla_precios_actualizada`/`precio_rebajado` (L18–19).

### 1.3 Tiendas — M39
- **`game/isla-ancestral/scripts/shops/shop_manager.gd`** (autoload `ShopManager`, L10–11) orquesta registro de tiendas, horario, compra/venta atómica, restock, mercader viajero y persistencia. Integra por duck-typing con `TimeCalendar/GameTime` (M29/M30), `EconomyManager` (M38) e `Inventario` (M14), todos opcionales (L8–9,52–86,227–231,265–270).
- **`shop.gd`** (`RefCounted`, L8) mantiene estado mutable por tienda: `stock_actual` dict O(1), último restock, presencia de mercader (L12–18); consultas puras de horario (`esta_abierta`, L48–60) y operaciones de stock (`tiene_stock`, `remover_stock`, `acumular_stock` con cap, L30–44).
- **`shop_data.gd`** (`Resource`, L8) define definición data-driven por tienda (tipo, dueño NPC, horarios, festivales, catálogos, restock, rotación estacional, recargo mercader, aparición PRNG; L11–84).
- **`stock_generator.gd`** (L8) genera/reabastece stock con contexto (estación/eventos/día) y PRNG determinista; filtra temporada/eventos respetando básicos garantizados (L13–85).
- **`catalogo_tiendas.gd`** (L25) registra tiendas oficiales al arrancar (`tienda_general`, `herreria`, `mercader_viajero`, L34–168) con validación dura/tolerante según contexto (L49–87).
- **`shop_ui.gd`** (`class_name ShopUI`, capa UI M53, L12–14) solo consulta/ordena acciones a `ShopManager`/`EconomyManager`/`Inventario`; no muta contenedores directamente (L8–9,269–330). Incluye compra 1/máx y venta 1/máx (L269–300) y maneja rechazo/éxito por señales (L304–330).
- **`reputacion_tienda.gd`** gestiona reputación de tienda del jugador (datos puros, sin decaimiento; L6–80), invocada por ventas (shop_manager L292–296).
- **`shop_visitor.gd`** (M158, nodo interno) simula NPC visitante que compra 1x/día al jugador usando `Inventario` y precios de `PriceManager`/fallback, depositando AO vía `EconomyManager.depositar_monedas` (L70–95).

### 1.4 Otras economías/comercio
- **`game/isla-ancestral/scripts/combat/gem_currency.gd`** (`class_name GemCurrency`, autoload, L17–19): moneda separada “gemas” para Isla de Combate; `add_gems`/`spend_gems`/`has_gems`, historial, tablas de valor por tier/categoría, persistencia M59 (L24–108). Reglas cozy: no descartar ni perder al morir, sin compra con dinero real en esta entrega (L10–15).
- **`game/isla-ancestral/scripts/economia/barter_system.gd`** (autoload `Barter`, L17): trueque objeto-por-objeto **sin moneda**, con validaciones de amistad/temporada/límite diario/salvavidas e intercambio atómico con rollback vía `Inventario` (L70–140).
- **`game/isla-ancestral/scripts/interfaces/i_tienda.gd`** (`ITienda`, Resource, L3): contrato de interfaz para compra/venta/precio/stock/horario/id (L19–43), superficie nueva sin romper consumidores.

---

## 2) ¿Hay validación de precios y transacciones?

Sí, hay validaciones relevantes, con algunas asimetrías:

- **Precios centralizados y no calculados por la tienda:** `shop_manager.comprar` obtiene precio de `EconomyManager.precio_compra_vigente(...)` y rechaza si M38/M14 no están o no exponen el método (L227–236); `vender` usa `precio_venta_vigente` (L265–277). `Shop.gd` explícitamente no calcula precios (L7).
- **Validación de cantidad y estado en tienda:** compra rechaza tienda inexistente, cerrada, `cantidad <= 0`, sin stock (L215–225); venta rechaza tienda/cerrada/`cantidad <= 0`, item no recomprable, sistemas no disponibles, items insuficientes (L255–272). `CANTIDAD_INVALIDA` existe como motivo (L26,222–223,260–262).
- **Validación monetaria/inventario:** compra verifica fondos con `retirar_monedas(total)` (L238–239) y revierte stock+monedas si `inventario.agregar_items` falla (L241–248). Venta retira items del jugador antes de pagar (L271–272).
- **Clamps defensivos de precio:** tienda usa `maxi(1, int(...))` al obtener precios (L236,276); `PriceManager` devuelve `maxi(1, final)`/`maxi(1, base)` y `>=0` en bases (L124,155,161,175,181). Anti-grind limita venta a no superar compra vigente cuando aplica (L156–160).
- **EconomyManager valida montos:** `retirar_monedas`/`depositar_monedas` rechazan `total <= 0` (L103–119) — corrección documentada para evitar transacciones/reputación espuria; depósitos al tope máximo se rechazan (L121–125) y parciales se claman con aviso/contador (L126–134).
- **Barter valida completamente:** oferta/NPC, amistad, temporada, límite diario, inventario disponible, remoción/agregado atómico y rollback si no entra lo recibido (barter_system L91–140).
- **GemCurrency valida montos:** `add_gems` ignora `<=0` (L42–46); `spend_gems` permite `<=0` como no-op exitoso y rechaza saldo insuficiente (L49–58).
- **UI:** `ShopUI` deshabilita botones según stock/tengo (L249–257) y calcula “máximo” por saldo/stock (L272–282), pero la autoridad final es `ShopManager` (revalida).

**Limitación observada:** el flujo de venta en `ShopManager.vender` no comprueba el resultado de `depositar_monedas` (ver sección 3/4).

---

## 3) ¿Hay problemas de duplicación de monedas o items?

### Hallazgos
1. **Compra (jugador → tienda): sin duplicación evidente; hay rollback.**  
   - En `shop_manager.gd:233–251`, el precio viene de M38, se retiran monedas (`retirar_monedas`), se descuenta stock, se agregan items al inventario y **si falla el inventario se revierten stock y monedas** (`acumular_stock` + `depositar_monedas(total)`, L244–248). Esto evita pérdida de dinero/stock en el caso de inventario lleno.

2. **Venta (jugador → tienda): riesgo de pérdida de valor al tope de saldo, no duplicación.**  
   - En `shop_manager.gd:271–284`, primero se remueven items del jugador (`inventario.remover_items`, L271–272). Luego se calcula total y se llama `economia.depositar_monedas(total)` (L280) **sin inspeccionar el booleano de retorno**; después se acumula stock en tienda (L281), se emiten señales (L283–284), se registra anti-grind (L288–290) y reputación (L293–296).
   - En `economy_manager.gd:121–137`, `depositar_monedas` **devuelve `false`** si el saldo ya está en `MAX_SALDO` (“rechazado: saldo en el tope”, L121–125) o clampa depósitos parciales acreditando solo lo real (L126–134). 
   - **Consecuencia:** si el jugador está en tope, puede **perder items** (ya removidos) y la tienda **ganar stock** sin que el jugador reciba AO. Si el depósito se clampa parcialmente, el jugador recibe menos de `total` pero la venta se considera exitosa con `total` completo en señal/historial de mercado/reputación (L276–296 usan `total` calculado, no lo acreditado). No es duplicación de monedas/items; es inconsistencia/loss en borde de tope.

3. **UI “comprar máximo”: cálculo no atómico, pero backend revalida.**  
   - `shop_ui.gd:272–282` calcula máximo con saldo/precio/stock y llama `sm.comprar(...)`. Puede quedar desfasado entre lectura y ejecución, pero `ShopManager.comprar` vuelve a validar cierre, stock, sistemas, precio, fondos y resultado de inventario (L214–248). Riesgo práctico bajo en single-thread; sin evidencia de duplicación.

4. **Trueque: intercambio con rollback.**  
   - `barter_system.gd:122–140` verifica items, remueve pedido todo-o-nada, intenta agregar entregado y hace rollback (`agregar_items(pedido)`) si falla. No usa moneda.

5. **GemCurrency:** operaciones simples en memoria (`+=`/`-=`) con validación de saldo en gasto (gem_currency L42–58). Persistencia restaura y emite cambio (L94–108). No se observa rollback/atomicidad multi-sistema porque no coordina inventario+moneda en la misma transacción; el canje de herramientas encantadas mencionado en comentarios depende de NPC/M164 externo (no revisado aquí).

6. **Visitante de tienda (M158):** remueve item, calcula precio y deposita AO (shop_visitor L88–95). Si `depositar_monedas` falla por tope, igualmente ya removió el item y emite venta — patrón similar al punto 2 (menos crítico por ser NPC/flujo auxiliar).

7. **Concurrencia/autoridad:** no se observan locks ni transacciones distribuidas; en Godot single-thread esto suele ser suficiente para juego local. Si en el futuro hay multiplayer o llamadas asíncronas, faltaría autoridad servidor/transacción formal.

---

## 4) Sugerencias de mejora (2)

### Mejora 1 — Hacer la venta atómica respecto al acreditamiento real
**Objetivo:** evitar pérdida de items/valor cuando `depositar_monedas` rechaza o clampa por `MAX_SALDO`.

- En `shop_manager.vender` (`game/isla-ancestral/scripts/shops/shop_manager.gd:273–296`): capturar el resultado/valor acreditado. Opciones:
  - Cambiar `EconomyManager.depositar_monedas` para devolver información útil (`bool` + `acreditado`) o exponer `acreditar_hasta_tope(total) -> int`; o consultar `saldo` antes/después de forma controlada.
  - Si el depósito es rechazado completamente (`false` por tope), **revertir**: devolver items al jugador (`inventario.agregar_items({item_id:cantidad})`) y **no** acumular stock en tienda ni emitir éxito; emitir `venta_rechazada` con motivo adecuado (p. ej. nuevo `SALDO_MAXIMO` o reutilizar con cuidado).
  - Si se clampa parcialmente, registrar/emitir el **monto acreditado real** (no `total` teórico) y decidir política explícita: pagar parcial y vender parcial, o todo-o-nada. Para cozy y claridad, **todo-o-nada** suele ser más seguro.
- Aplicar patrón equivalente en `shop_visitor.gd:88–95` para el NPC visitante.
- Añadir pruebas en `scripts/economia/` o `scripts/shops/` para el caso “vender con saldo en `MAX_SALDO`”.

**Impacto:** corrige inconsistencia económica real en borde; mejora confianza (RNF10 ya mencionado en EconomyManager).

### Mejora 2 — Endurecer contratos de transacción y observabilidad
**Objetivo:** reducir errores de integración y facilitar auditoría de economía.

- Definir una **API de transacción de tienda** más explícita (p. ej., resultado `Dictionary {ok, motivo, total_pedido, total_acreditado, precio_unitario}`) en `ShopManager` y hacer que `ShopUI` consuma ese contrato; actualmente compra/venta emiten señales void de control de flujo y la UI infiere estados.
- Registrar en historial/eventos de economía los casos de rechazo/clamp relevantes (tope, precio 0 defensivo, sistema no disponible) con IDs de transacción correlacionables entre `ShopManager` e `EconomyManager` (útil para M103/M104 analytics y debugging).
- Añadir validación cruzada de catálogo/precios en arranque o herramienta de CI: verificar que `item_id` de `catalogo_tiendas.gd` existan en M15 (ya hay warnings parciales, L72–76) y que tengan precio resoluble en `PriceManager` cuando aplique; esto evita compras/ventas con precio 0 o ítems huérfanos.

**Impacto:** menor riesgo de regresiones al tocar M38/M39/M14, mejor telemetría y diagnósticos.

---

## Conclusión

La economía interna está razonablemente separada: **M38 (`EconomyManager` + `PriceManager`)** gestiona saldo, precios, límites y reglas anti-arbitraje; **M39 (`ShopManager`/`Shop`/`StockGenerator`/UI)** gestiona tiendas, horario, stock y orquesta compra/venta consultando M38 y mutando inventario M14; **`Barter`** maneja trueque sin moneda con rollback; **`GemCurrency`** es una moneda paralela persistente. Hay **validaciones sólidas** en cantidad, apertura, stock, fondos, disponibilidad de sistemas, clamps de precio y rechazos de montos inválidos. No se observan rutas claras de **duplicación** de monedas/items en los flujos revisados; el riesgo principal es **inconsistencia/pérdida en venta cuando el saldo está en `MAX_SALDO`**, porque `ShopManager.vender` ignora el fallo/clamp de `depositar_monedas` tras haber removido items del jugador. Las dos mejoras prioritarias son: (1) atomicidad/rollback real en ventas según acreditamiento efectivo, y (2) contratos de transacción más explícitos con mejor observabilidad.