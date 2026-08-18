**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 39: Tiendas

## 1. Arquitectura

El módulo de tiendas se organiza en un **autoload orquestador** (`ShopManager`), una **clase runtime por tienda** (`Shop`), un **generador de stock por canalización** (`StockGenerator`) y un **script de UI desacoplado** (`ShopUI`, capa M53). Los precios y monedas se delegan a M38; los horarios se consultan a M29/M30; los ítems se mueven por M14. Toda comunicación hacia afuera es por señales.

```
[Autoload del módulo]
ShopManager       → registro de tiendas, orquestación compra/venta, consultas, señales

[Clases runtime]
Shop (RefCounted)              → definición + stock_actual + estado (abierta, mercader activo)
StockGenerator (RefCounted)    → canalización: base → estación → eventos → aforo → PRNG

[Script de UI (capa M53, desacoplado)]
ShopUI (Node/Canvas)           → escucha señales de ShopManager; muestra catálogo, stock y saldo

[Recursos .tres (data)]
tiendas/*.tres                 → una ShopDefinition por tienda (incluye ShopCatalog y StockEntry)
```

Flujo de dependencia: `ShopManager` instancia `Shop` por cada `ShopDefinition`; `StockGenerator` produce el stock inicial, el restock diario y el catálogo rodante de mercaderes; `ShopManager` consulta precios a M38 (`PriceManager`), mueve monedas con M38 (`EconomyManager`) e ítems con M14. La UI (M53) nunca es referenciada desde el autoload.

## 2. Diagramas de Flujo (texto)

### 2.1 Compra en tienda (jugador → NPC)

```
jugador pulsa "comprar" en ShopUI (M53)
  → UI llama ShopManager.comprar(shop_id, item_id, cantidad)
  → tienda = registro[shop_id] ; existe ?
       ├─ NO → señal compra_rechazada(motivo=TIENDA_INEXISTENTE) → fin
       └─ SI
  → ShopManager.esta_abierta(shop_id) ?                      [D4, consulta M29/M30]
       ├─ NO → señal compra_rechazada(motivo=CERRADA) → fin
       └─ SI
  → stock = tienda.stock_actual[item_id] ; stock >= cantidad ?
       ├─ NO → señal compra_rechazada(motivo=SIN_STOCK) → fin
       └─ SI
  → precio = PriceManager.precio_compra_vigente(item_id, npc_duenio)   [M38]
  → total = precio * cantidad
  → EconomyManager.puede_pagar(total) ?
       ├─ NO → señal compra_rechazada(motivo=SIN_FONDOS) → fin
       └─ SI
  → transacción atómica [D8]:
       → remover_items(item_id, cantidad) de stock de la tienda
       → Inventario.agregar_items({item_id: cantidad})  [M14]
         ├─ fallo (inventario lleno) → revertir stock → señal compra_rechazada(motivo=INVENTARIO_LLENO) → fin
       → EconomyManager.retirar_monedas(total)           [M38]
       → señal compra_exitosa(shop_id, item_id, cantidad, total, precio)
       → señal inventario_tienda_cambio(shop_id, item_id, stock_restante)
       → log DOM-TIEN-COMPRA
```

### 2.2 Venta en tienda (jugador → NPC)

```
UI llama ShopManager.vender(shop_id, item_id, cantidad)
  → validar tienda existe → validar esta_abierta(shop_id)     [mismos rechazos que compra]
  → catálogo de recompra del NPC contiene item_id ?             [D3]
       ├─ NO → señal venta_rechazada(motivo=NO_RECOMPRA) → fin
       └─ SI
  → Inventario.remover_items({item_id: cantidad})  [M14]
       ├─ faltan ítems → señal venta_rechazada(motivo=SIN_ITEMS_JUGADOR) → fin
       └─ OK
  → precio = PriceManager.precio_venta_vigente(item_id)        [M38, con topes anti-grind]
  → total = precio * cantidad
  → transacción atómica [D8]:
       → EconomyManager.depositar_monedas(total)  [M38]
       → tienda.stock_actual[item_id] += cantidad              [la tienda acumula lo recomprado]
       → señal venta_exitosa(shop_id, item_id, cantidad, total, precio)
       → señal inventario_tienda_cambio + log DOM-TIEN-VENTA
```

### 2.3 Reabastecimiento diario (día laborable)

```
evento nuevo_dia_laborable (M29) → ShopManager.reabastecer_diario(fecha)
  → por cada tienda fija:
       → si fecha_ultimo_restock == fecha → skip (idempotencia) [Riesgo restock duplicado]
       → contexto = {estacion: M29, eventos_activos: M73, prng: M29}
       → StockGenerator.generar(tienda.definicion, contexto, MODO_RESTOCK)
       → aplicar: stock_actual[item] = clamp(base_restock, min, max)  [D6]
       → tienda.fecha_ultimo_restock = fecha
       → señal inventario_tienda_cambio por ítem modificado
       → log DOM-TIEN-RESTOCK (resumen por tienda)
  → mercaderes viajeros: evaluar aparición del día [D9]
       → señal mercader_aparecio/mercader_parto(npc_id)
```

### 2.4 Aparición de mercader viajero

```
evento nuevo_dia_laborable / estacion_cambio / evento_iniciado (feria)
  → ShopManager.actualizar_mercaderes(fecha, contexto)
  → para cada ShopDefinition.tipo == VIAJERO:
       → decide = feria activa ? SI : (dias_fijos contiene hoy ? SI : (prng.randf() < prob_diaria ? SI : NO))
       → SI(sin estar activo):
            → StockGenerator.generar(..., MODO_APARICION) → catálogo rodante
            → estado = activo; señal mercader_aparecio(npc_id, catálogo)
       → NO(estando activo):
            → estado = inactivo; señal mercader_parto(npc_id)
```

## 3. Clases / Autoloads Previstos

### 3.1 `ShopManager` (autoload)
- Responsable: registro de tiendas, orquestación compra/venta, restock, mercaderes viajeros, señales.
- Expone: `comprar(shop_id, item_id, cantidad) -> Dictionary`, `vender(shop_id, item_id, cantidad) -> Dictionary`, `esta_abierta(shop_id) -> bool`, `stock_de(shop_id, item_id) -> int`, `listar_stock(shop_id) -> Array`, `lista_tiendas() -> Array[Shop]`, `reabastecer_diario(fecha)`, `actualizar_mercaderes(fecha, contexto)`.
- Señales: `compra_exitosa/rechazada`, `venta_exitosa/rechazada`, `inventario_tienda_cambio`, `tienda_abierta/tienda_cerrada`, `mercader_aparecio/mercader_parto`.
- Dependencias: `PriceManager` y `EconomyManager` (M38), inventario M14, calendario M29, reloj M30.

### 3.2 `Shop` (RefCounted)
- Responsable: estado runtime de una tienda (definición + stock + fechas + activación de mercader).
- Expone: `definicion: ShopDefinition`, `stock_actual: Dictionary`, `fecha_ultimo_restock: int`, `mer_activo: bool`, `obtener_stock(item_id) -> int`, `listar_stock() -> Array`, `descontar_stock(item_id, cantidad) -> bool`, `acumular_stock(item_id, cantidad)`.
- Nota: clase pura de datos y validaciones; no emite señales (las emite el ShopManager).

### 3.3 `StockGenerator` (RefCounted)
- Responsable: canalización de stock en 5 etapas; devuelve stock materializado.
- Expone: `generar(definicion: ShopDefinition, contexto: Dictionary, modo: StringName) -> Dictionary`, `generar_catalogo_rodante(definicion, contexto) -> Dictionary`.
- Etapas: `_etapa_base()`, `_etapa_estacion()`, `_etapa_eventos()`, `_etapa_aforo()`, `_etapa_prng()`.
- Contexto: `{estacion, eventos_activos: Array, prng: RandomNumberGenerator, fecha}`.
- Debe ser determinista: misma definición + contexto → mismo stock.

### 3.4 `ShopUI` (script de escena, capa M53)
- Responsable: mostrar catálogo, stock, precios (vía señales de M38) y saldo; enviar intenciones de compra/venta.
- Expone (capa UI): `abrir_tienda(shop_id)`, `mostrar_catalogo(catalogo, precios)`, `on_boton_comprar(item_id, cantidad)`, `on_boton_vender(item_id, cantidad)`, `mostrar_cartel_cerrado(horario)`.
- **Restricción:** ningún autoload referencia `ShopUI`; solo se suscribe a señales. (No contiene lógica de negocio.)

### 3.5 Recursos de datos (`.tres`)
- `ShopDefinition`: `shop_id`, `npc_duenio_id`, `tipo_tienda: StringName` (SEMILLAS/PESCADERIA/FERRETERIA/GENERAL/VIAJERO), `nombre_clave_i18n`, `dias_abierto: Array[int]`, `dias_descanso: Array[int]`, `hora_apertura: int`, `hora_cierre: int`, `catalogo: ShopCatalog`, `prob_diaria_aparicion: float` (solo VIAJERO), `dias_fijos_aparicion: Array[int]` (solo VIAJERO), `recargo_compra: int`/`recargo_venta: int` (porcentaje, solo VIAJERO, aplica dentro de topes M38).
- `ShopCatalog`: `items_venta: Array[StockEntry]`, `items_recompra: Array[StringName]`, `pool_rodante: Array[StockEntry]` (solo VIAJERO).
- `StockEntry`: `item_id`, `stock_min: int`, `stock_max: int`, `restock_diario: int`, `peso_rareza: float`, `temporadas: Array[StringName]` (vacío = todas), `solo_evento: StringName` ("" = normal).

## 4. Integración con Módulos 14, 19, 29, 30, 38 y 53

### 4.1 M14 (Inventario)
- Compra: `Inventario.agregar_items({item_id: cantidad})` al final de la validación; si falla (inventario lleno) se revierte el stock descontado (D8).
- Venta: `Inventario.remover_items({item_id: cantidad})` como primera validación dura; sin ítems disponibles → rechazo SIN_ITEMS_JUGADOR.
- El stock de tienda es independiente del inventario del jugador: nunca se mezclan.

### 4.2 M19 (Población)
- `npc_duenio_id` debe existir en el directorio de población; validación en editor.
- La tienda se vincula al NPC dueño en escena: el jugador abre la tienda interactuando con el vecino (contrato IInteractable del proyecto).

### 4.3 M29/M30 (Calendario y Reloj)
- `esta_abierta(shop_id)`: consulta día de la semana (M29), hora actual (M30) y `dias_abierto/dias_descanso/hora_apertura/hora_cierre`; función pura sin estado.
- Señales consumidas: `nuevo_dia_laborable(fecha)` → restock + mercaderes; `estacion_cambio(estacion)` → rotación estacional; `evento_iniciado/evento_finalizado` (M73) → etapa de eventos.
- PRNG: `RandomNumberGenerator` con semilla de partida provista por M29.

### 4.4 M38 (Economía)
- `precio_compra_vigente(item_id, npc_id)` y `precio_venta_vigente(item_id)` consultados en cada operación (no se cachea: el precio del día puede cambiar entre sesiones del UI).
- `EconomyManager.retirar_monedas/depositar_monedas` para el movimiento de saldo.
- En mercaderes viajeros: se pasa el recargo como parámetro opcional a M38 (`precio_compra_vigente(item, npc, recargo)`), que M38 aplica dentro de sus clamps; este módulo jamás suma precios por su cuenta.
- Anti-grind y ventana de oferta: respondidos por M38 dentro de `precio_venta_vigente`.

### 4.5 M53 (UI/UX)
- `ShopUI.abrir_tienda(shop_id)` pide datos: `listar_stock` + precios (M38) + saldo (M38).
- Reglas de UX obligatorias (sección 8 de AGENTS.md): feedback inmediato a `compra_rechazada/venta_rechazada` con motivo legible; deshabilitar acciones durante transacciones; mostrar cartel de cierre con horario de reapertura.

## 5. Contrato de Señales (resumen)

| Señal | Emisor | Consumidores |
|---|---|---|
| `compra_exitosa(shop_id, item_id, cantidad, total, precio)` | ShopManager | ShopUI (M53), sonido (M43), log |
| `compra_rechazada(shop_id, item_id, motivo)` | ShopManager | ShopUI (M53), sonido (M43) |
| `venta_exitosa(shop_id, item_id, cantidad, total, precio)` | ShopManager | ShopUI (M53), sonido (M43) |
| `venta_rechazada(shop_id, item_id, motivo)` | ShopManager | ShopUI (M53) |
| `inventario_tienda_cambio(shop_id, item_id, stock)` | ShopManager | ShopUI (M53), persistencia |
| `tienda_abierta(shop_id)` / `tienda_cerrada(shop_id, proxima_apertura)` | ShopManager | ShopUI (M53), IA de NPC (M26) |
| `mercader_aparecio(npc_id, catalogo)` / `mercader_parto(npc_id)` | ShopManager | ShopUI (M53), eventos (M73) |
| `saldo_cambiado(saldo)` | EconomyManager (M38) | ShopUI (M53) |
| `nuevo_dia_laborable(fecha)` / `estacion_cambio(estacion)` | M29 | ShopManager |
| `evento_iniciado/finalizado(evento_id)` | M73 | ShopManager |

## 6. Persistencia

Se guarda en la partida (junto a M14/M38):
- `stock_actual` por tienda: `Dictionary{shop_id: {item_id: cantidad}}`.
- `fecha_ultimo_restock` por tienda (int día laborable).
- Mercaderes viajeros: `mer_activo` + catálogo rodante materializado + día de aparición.
- Consistencia: al cargar, si `fecha_guardada < fecha_actual` se ejecuta `reabastecer_diario` hasta alcanzar el día (recuperación de días perdidos).
- Formato: `Dictionary` simple serializable desde `ShopManager.guardar_estado()`; el orquestador global de persistencia (M114 o equivalente) lo invoca.

## 7. Optimización

- `stock_actual` como `Dictionary{item_id: int}` → consultas O(1).
- `esta_abierta` es cálculo aritmético puro (día/hora vs rangos), sin alocación.
- La canalización corre solo en eventos de cambio de día/estación/evento; jamás por frame.
- Transacciones sin instanciación de nodos: todo contra diccionarios y llamadas a M38/M14.
- Catálogos precargados en `_ready()` del ShopManager; sin lecturas de disco en runtime.
- Pool de `Shop` por `shop_id` con acceso O(1) desde el registro.

## 8. Diseño de Balance (tabla de referencia)

| Parámetro | Puesto de semillas | Pescadería | Ferretería | Tienda general | Mercader viajero |
|---|---|---|---|---|---|
| Ítems en catálogo | 12-18 | 10-15 | 12-16 | 15-25 | 8-14 rodantes |
| stock_min por ítem básico | 5 | 4 | 3 | 5 | - |
| stock_max por ítem básico | 30 | 20 | 15 | 25 | 6-10 |
| restock_diario | 5-10 | 4-8 | 3-6 | 5-8 | regenera por aparición |
| Rotación estacional | Fuerte (semillas) | Media (cebos/pesca) | Baja | Media | Alta (pool rota) |
| Días de descanso típicos | 1 | 1-2 | 1 | 1 | - (aparece en días) |
| Recargo m. viajero | - | - | - | - | ±10-15% (dentro de topes M38) |

Reglas: los ítems básicos de cada tienda (semillas comunes, pescado genérico, herramientas básicas) tienen `stock_min >= 1` garantizado; los ítems raros tienen `stock_max` bajo y `peso_rareza` alto (menos ejemplares); el restock nunca excede `stock_max`.