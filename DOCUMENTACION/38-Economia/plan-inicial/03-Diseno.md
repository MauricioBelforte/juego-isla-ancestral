**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 38: Economía

## 1. Arquitectura

La economía se organiza en **autoloads de lógica pura** (sin UI) que comunican por señales. La UI (M53) consume datos y señales; ningún autoload referencia nodos de Canvas.

```
[Autoloads del módulo]
EconomyManager  → saldo, transacciones monetarias, persistencia general
PriceManager    → precio vigente por ítem, tabla del día, ventana de oferta
ShopManager     → tiendas: stock, horarios, reabastecimiento, compra/venta
BarterSystem    → trueques: propuestas, validación, ejecución

[Recursos .tres (data)]
economy_prices.tres      → catálogo central de PriceDefinition
shops/*.tres             → una ShopDefinition por tienda
barter/*.tres            → una BarterOffer por propuesta de trueque
```

Flujo de dependencia: `ShopManager` y `BarterSystem` consumen `PriceManager` y `EconomyManager`; el `EconomyManager` no conoce tiendas ni trueques (solo moneda y logs). Las señales salientes las escuchan la UI (M53), el log (M103) y analytics (M104).

## 2. Diagramas de Flujo (texto)

### 2.1 Compra en tienda (jugador → NPC)

```
jugador pulsa "comprar" en UI (M53)
  → UI llama ShopManager.comprar(shop_id, item_id, cantidad)
  → ShopManager.esta_abierta(shop_id, calendario) ?          [D7]
       ├─ NO → señal compra_rechazada(motivo=CERRADA) → fin
       └─ SI
  → validar stock suficiente ?
       ├─ NO → señal compra_rechazada(motivo=SIN_STOCK) → fin
       └─ SI
  → pref = PriceManager.precio_compra_vigente(item_id, npc_id)
  → total = pref * cantidad  (clamp y validación de fondos)
  → EconomyManager.retirar_monedas(total) y Inventario.agregar_items(M14)
       ├─ fallo → señal compra_rechazada(motivo=SIN_FONDOS) → fin
       └─ éxito → ShopManager.descontar_stock, registrar venta
         → señal compra_exitosa(shop_id, item_id, cantidad, total, pref)
         → log DOM-ECO-TRX
```

### 2.2 Venta en mercado (jugador → pueblo)

```
UI llama ShopManager.vender(vendedor_id, item_id, cantidad)
  → limite_diario = PriceManager.limite_ventas_dia(item_id)  [D4]
  → ventas_hoy(item_id) >= limite ?
       ├─ SI → precio ajustado al 50% (señal precio_rebajado) → continúa
       └─ NO → precio normal vigente
  → precio = PriceManager.precio_venta_vigente(item_id)
  → se remueven ítems (M14) y EconomyManager.depositar_monedas(total)
  → PriceManager.registrar_venta(item_id, cantidad, fecha)    [D9]
  → señal venta_exitosa(...) + log DOM-ECO-TRX
```

### 2.3 Trueque (sin moneda)

```
UI llama BarterSystem.ejecutar_trueque(npc_id, oferta_id)
  → validar amistad minima (M20) y temporada (M29)
  → validar limite diario del NPC
  → validar items requeridos presentes en inventario (M14)
  → intercambio atomico: remover pedido / agregar entregado (M14)
  → señal trueque_exitoso(npc_id, oferta_id, entregado, recibido)
  → log DOM-ECO-TRUEQUE
```

### 2.4 Cálculo diario del mercado (amanecer)

```
evento amanecer (M31) + nuevo_dia_laborable (M29/M30)
  → PriceManager.recalcular_tabla_dia()
  → por cada ítem con variabilidad_mercado > 0:
  → base = precio_base(ítem)
  → estacional: si es temporada del ítem → +5% (tope +10%); fuera → -10% (piso -10%)
  → oferta: ventas_ventana(item, 3 dias) * factor_decreciente → ajuste entre -10% y 0%
  → clamp final dentro de [base*0.70, base*1.10]
  → señal tabla_precios_actualizada(tabla)
  → UI (M53) refresca la pizarra del mercado
```

## 3. Clases / Autoloads Previstos

### 3.1 `EconomyManager` (autoload)
- Responsable: saldo, transacciones monetarias, persistencia, señales globales económicas.
- Expone: `saldo: int`, `depositar_monedas(n)`, `retirar_monedas(n) -> bool`, `puede_pagar(n)`, `guardar_estado()/cargar_estado()`, `reset_transacciones_dia()`.
- Señales: `saldo_cambiado(saldo_actual)`, `transaccion_registrada(tx: Dictionary)`.

### 3.2 `PriceManager` (autoload)
- Responsable: catálogo de precios, ajustes de mercado, amistad, límites diarios, tabla del día.
- Expone: `precio_compra_vigente(item_id, npc_id) -> int`, `precio_venta_vigente(item_id) -> int`, `limite_ventas_dia(item_id) -> int`, `ventas_hoy(item_id) -> int`, `tabla_del_dia() -> Dictionary`, `registrar_venta(item_id, cantidad, fecha)`, `recalcular_tabla_dia()`.
- Señales: `tabla_precios_actualizada(tabla)`, `precio_rebajado(item_id, precio_antes, precio_despues)`.

### 3.3 `ShopManager` (autoload)
- Responsable: tiendas, stock, horarios, reabastecimiento, compra y venta.
- Expone: `esta_abierta(shop_id) -> bool`, `stock_de(shop_id, item_id) -> int`, `comprar(shop_id, item_id, cantidad) -> Dictionary`, `vender(vendedor_id, item_id, cantidad) -> Dictionary`, `reabastecer_diario(fecha_laborable)`, `lista_tiendas() -> Array`.
- Señales: `compra_exitosa(...)`, `compra_rechazada(motivo)`, `venta_exitosa(...)`, `inventario_tienda_cambio(shop_id, item_id, stock)`.

### 3.4 `BarterSystem` (autoload)
- Responsable: propuestas de trueque, validación, límites diarios, ejecución.
- Expone: `propuestas_disponibles(npc_id) -> Array[BarterOffer]`, `ejecutar_trueque(npc_id, oferta_id) -> Dictionary`, `limite_diario(npc_id) -> int`, `usos_hoy(npc_id) -> int`.
- Señales: `trueque_exitoso(...)`, `trueque_rechazado(motivo)`.

### 3.5 Recursos de datos (`.tres`)
- `PriceDefinition`: `item_id`, `precio_compra_base`, `precio_venta_base`, `descuento_amistad_max`, `variabilidad_mercado` (0..1), `limite_venta_diario`, `temporada_bonus` (StringName o ""), `revendible: bool`.
- `ShopDefinition`: `shop_id`, `npc_dueño_id` (M20), `nombre_clave_i18n`, `horario {dias, desde, hasta}`, `stock_por_estacion: Dictionary` (estacion → Array de {item_id, cantidad}), `trueques: Array[BarterOffer]`.
- `BarterOffer`: `oferta_id`, `amistad_minima` (0..4), `temporada` ("" = todas), `pedido: Array[IdCantidad]`, `entregado: Array[IdCantidad]`, `limite_por_dia` (0 = infinito).

## 4. Integración con Módulos 15, 16 y 20

### 4.1 M15 (Recursos)
- Los `item_id` de los catálogos de M15 son la clave primaria de `PriceDefinition`.
- La rareza de M15 define un precio base por rango de referencia (común 5-25, fino 30-80, raro 90-250, legendario/ancestral 300+), calibrado en tabla de balance.
- Los recursos se venden por defecto en el mercado (todos los recursos comunes son vendibles); los recursos de misión/ancestrales pueden marcarse `revendible = false`.
- Al recolectar (M15), el módulo no interviene: la economía solo lee el catálogo y recibe ítems vía M14.

### 4.2 M16 (Crafting)
- Cada producto craftable puede declarar su `PriceDefinition` al crearse la receta (validación en editor: producto vendible sin precio → advertencia).
- Regla económica: el precio de venta de un producto craftable es fijo e independiente de la suma de materiales (evita inflación por encadenar recetas); se documenta en la tabla de balance.
- Comprar materiales en tienda para craftear y vender el producto no debe ser rentable (anti-aribitraje: venta < costo de materiales).

### 4.3 M20 (Amistad)
- El nivel de amistad del jugador con el NPC dueño (M20) modifica la compra: descuento 5%/10%/15% en niveles 2/3/4 respectivamente, aplicado en `PriceManager.precio_compra_vigente`.
- Los trueques únicos se desbloquean por nivel de amistad declarado en `BarterOffer.amistad_minima`.
- La amistad nunca bloquea el comercio básico: nivel 0 siempre permite comprar y vender.
- Señal de M20 consumida: `nivel_amistad_cambio(npc_id, nivel)` → invalida cachés de precios del NPC.

## 5. Contrato de Señales (resumen)

| Señal | Emisor | Consumidores |
|---|---|---|
| `saldo_cambiado(saldo)` | EconomyManager | UI HUD (M53), persistencia |
| `transaccion_registrada(tx)` | EconomyManager | Log (M103), Analytics (M104) |
| `tabla_precios_actualizada(tabla)` | PriceManager | UI mercado (M53) |
| `precio_rebajado(item, antes, despues)` | PriceManager | UI feedback (M53) |
| `compra_exitosa/rechazada(...)` | ShopManager | UI tienda (M53), sonido (M43) |
| `venta_exitosa(...)` | ShopManager | UI mercado (M53) |
| `inventario_tienda_cambio(...)` | ShopManager | UI tienda (M53) |
| `trueque_exitoso/rechazado(...)` | BarterSystem | UI trueque (M53), sonido (M43) |
| `nivel_amistad_cambio(npc, nivel)` | M20 | PriceManager (invalida descuentos) |

## 6. Persistencia

Se guarda en la partida (junto a M15/M16/M20):
- `saldo` (int).
- `ventas_por_item_dia`: contadores del día actual (se resetean al cambiar de día laborable).
- `ventana_oferta`: lista de ventas de los últimos 3 días laborables (item_id, cantidad, dia).
- `stock_tiendas`: desviaciones de stock respecto al inventario base por estación.
- `usos_trueque_por_npc_dia`: contadores diarios de trueques.
- `fecha_ultima_recalc`: día laborable en que se recalculó la tabla del mercado.

Formato: todo serializable a `Dictionary` simple desde `EconomyManager.guardar_estado()`; el guardado global lo orquesta el módulo de persistencia (M114 o equivalente).

## 7. Optimización

- Las consultas de precio son O(1) con diccionarios `item_id → PriceDefinition` precargados al `_ready()`.
- La tabla del día se calcula una vez por día laborable; el resto del día es solo lectura.
- Sin bucles por frame: el módulo reacciona solo a eventos (transacción, cambio de día, señal de amistad).
- Los ajustes de mercado usan enteros y clamps; sin floats en el camino del precio final.
- Caché de descuento por pareja (npc_id, item_id) invalidada solo por señal de M20.
- Presupuesto de memoria: filtros finitos de historial (ventana fija de 3 días, arrays acotados).

## 8. Diseño de Balance (tabla de referencia)

| Rango | Ítems ej. | Compra base | Venta base | Variabilidad mercado | Límite diario |
|---|---|---|---|---|---|
| Común | madera, piedra, fibras | 8-20 | 4-10 | 0.4 | 3 |
| Comida | frutas, hongos, pescado común | 15-50 | 8-25 | 0.6 | 3 |
| Procesado (M16) | telas, conservas, herramientas | 60-200 | 30-100 | 0.5 | 2 |
| Fino | minerales, pesca rara | 80-250 | 40-120 | 0.5 | 2 |
| Raro/ancestral | reliquias, polvo ancestral | 300-800 | 150-400 | 0.3 | 1 |

Reglas: venta nunca supera el 50-60% de la compra; en temporada el bono máximo de mercado es +10%; el descuento de amistad tope -15%; combinación tope: -25% sobre compra base y nunca precios negativos.