**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 38: Economía

## 1. Análisis del Dominio

La economía del juego se descompone en seis subsistemas interconectados:

### 1.1 Moneda
- **Dominio:** única divisa `monedas_aurora`, emitida por el pueblo de la isla Aurora (contexto narrativo: moneda comunitaria heredada de los ancestros).
- **Características:** entero no negativo; sin deuda; sin intereses; sin impuestos. El saldo es solo de lectura para el resto de módulos; todo cambio pasa por el EconomyManager.
- **Concepto clave:** la moneda es un facilitador social, no un objetivo de progreso. El progreso real viene de M16 (recetas), M17 (construcción) y M20 (amistad).

### 1.2 Precios
- **Dominio:** cada ítem del juego tiene un precio de compra base y un precio de venta base, derivados de su rareza (M15), su nivel de receta (M16) y su utilidad.
- **Regla de oro:** precio_venta < precio_compra siempre (salvo ítems de regalo únicos que no se pueden revender). Esto elimina el arbitraje y el grind de compra-reventa.
- **Ventana de precios:** el mercado ajusta dentro de ±10% sobre el base; el descuento de amistad (M20) llega hasta -15% adicional. Combinados, nunca superan el -25% ni +10% sobre el base.

### 1.3 Comercio (compra/venta genérica)
- **Dominio:** operaciones de intercambio moneda ↔ ítem entre el jugador y el pueblo.
- **Capas:** validación (fondos, stock, horario) → transacción (movimiento de saldo e ítems) → registro (log + analytics M104).
- **Integración:** la entrega/recepción de ítems usa el contrato del inventario (M14, del cual M15 depende) y las definiciones de ítems de M15.

### 1.4 Tiendas
- **Dominio:** cada tienda pertenece a un vecino concreto (M20) y tiene identidad propia: inventario fijo (basado en el rol del NPC), horario diario, días de descanso y reabastecimiento por día laborable.
- **Horarios:** declarativos en la definición de la tienda: `{dias: [1..7], desde: "09:00", hasta: "17:00"}`; el reloj del juego (M30/M31) consulta el estado abierto/cerrado.
- **Rotación estacional:** algunas tiendas cambian su inventario por estación (M29): la tienda de pesca ofrece cebos de verano, la tienda agrícola vende semillas de estación.

### 1.5 Trueque
- **Dominio:** intercambio de ítems sin moneda, propio del tono cozy: "te doy mi cacao, me das tu lana".
- **Reglas:** cada NPC define propuestas de trueque (ofertas) que dependen de:
  - Nivel de amistad con el jugador (M20): a más amistad, propuestas más favorables y ofertas únicas.
  - Temporada: propuestas que solo ocurren en cierta estación (M29).
  - Eventos (M73): trueques especiales en ferias.
- **Anti-abuso:** las propuestas son limitadas por día laborable; el jugador no puede repetir el mismo trueque infinitas veces.
- **Concepto clave:** el trueque es el "salvavidas cozy": incluso con 0 monedas el jugador siempre puede intercambiar bienes comunes por lo que necesita (RF12).

### 1.6 Mercado del Pueblo
- **Dominio:** un lugar del pueblo (la plaza) donde los precios de venta/compra de ítems comunes varían suavemente según la oferta reciente y la estación.
- **Oferta reciente:** ventana móvil de ventas del jugador (últimos N días laborables); vender muchos ejemplares de un ítem baja su precio en la ventana siguiente (tecnicamente suave: máximo -10%).
- **Estacionalidad:** los ítems de temporada se pagan mejor en su temporada (fruta de verano en verano) y peor (pero nunca menos del 70% del base) fuera de ella.
- **Tabla de precios del día:** se calcula al amanecer (M31) con PRNG de partida (M29) y se expone como dato; la UI (M53) la muestra.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Moneda única vs múltiples divisas | **Moneda única** | Simplicidad cozy; múltiples divisas agregan fricción y confusión, contrario al tono |
| Precios fijos eternos vs dinámicos suaves | **Dinámicos suaves (±10%)** | Los fijos aburren el mercado; los salvajes (Stardew con fluctuaciones fuertes) generan estrés y optimización ansiosa. La opción elegida mantiene vivacidad sin ansiedad |
| Trueque como mecánica central vs accesorio | **Accesorio importante** | El trueque puro como moneda central complica el progreso de M17 (que usa monedas); como complemento, aporta identidad y el salvavidas cozy |
| Sistema de deuda/banca | **Descartado** | La deuda es lo más anti-cozy posible; el plan maestro no la contempla |
| Economía global simulada (server) | **Descartado** | Juego 100% local, single-player; simular mercado global es costo sin beneficio |
| Descuentos por amistad directos | **Adoptado** | Consolida M20 (dar regalos tiene recompensa económica tangible); incentiva la amistad sin exigirla |
| Mercado con subastas | **Descartado** | Complejidad y fricción innecesarias en un pueblo de pocos vecinos |

## 3. Decisiones Clave

1. **D1 — Moneda única `monedas_aurora`:** entero no negativo, sin deuda. Todo el intercambio monetario pasa por `EconomyManager` (único punto de modificación).
2. **D2 — Precios data-driven:** `PriceDefinition` (.tres) por ítem; el catálogo central `economy_prices.tres` valida que no existan ítems sin precio cuando son vendibles.
3. **D3 — anti-aribitraje:** `precio_venta < precio_compra` para todo ítem revendible; verificación en editor (`validar_catalogo()`).
4. **D4 — Límites diarios anti-grind:** Límite de venta diario de 3 actos por ítem (configurable); pasado el límite, el precio cae al 50% (señal claro al jugador), nunca 0.
5. **D5 — Salvavidas cozy:** con 0 monedas, el jugador siempre tiene un trueque de partida disponible (ej: "3 fibras → 1 herramienta básica") ofrecido por todos los comerciantes.
6. **D6 — Mercado por día, no por hora:** los precios se recalculan una vez por día laborable al amanecer (M31), con PRNG de partida (M29); predecible, tranquilo y determinista.
7. **D7 — Horarios declarativos:** cada tienda declara días y franjas; el estado abierto/cerrado es una consulta pura al calendario (M29/M30/M31), sin estado interno frágil.
8. **D8 — Amistad como factor económico:** descuentos del 5%/10%/15% por niveles 2/3/4 de amistad (M20) y trueques únicos desbloqueados por nivel; la amistad nunca bloquea comercio básico.
9. **D9 — Ventana de oferta:** histórico de ventas de los últimos 3 días laborables; influencia suave y reversible en el mercado (nunca efectos permanentes).
10. **D10 — Registro total:** toda transacción deja un evento en el log del módulo y alimenta analytics (M104) sin importar al systema principal.

## 4. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|---|---|
| Inflación por reventa de crafting | precio_venta fijo por ítem (no depende de materiales); límite diario; ajustes por tabla de balance |
| Grind de un recurso fácil | D4 (límite diario) + D9 (ventana de oferta) hacen que el farmeo tenga rendimientos decrecientes claros |
| Jugador sin monedas se siente bloqueado | D5 (trueque de partida) + ventas mínimas siempre disponibles |
| Desconexión con la amistad | D8: la amistad afecta precio y opciones comerciables; se documenta en 03-Diseno la integración por señales con M20 |
| Complejidad de horarios rompiendo simulación | D7: consulta pura al calendario; sin estados manuales |
| Overflow de saldo | clamp entero a `MAX_SALDO = 999_999`; log de advertencia al alcanzarlo |

## 5. Modelo Conceptual (entidades)

- `PriceDefinition` (Resource): ítem → precios base, descuento amistad, variabilidad mercado, límite diario.
- `CatalogoPrecios` (Resource): lista central de PriceDefinition + validación.
- `ShopDefinition` (Resource): tienda → NPC dueño, stock por estación, horario, días, trueques ofrecidos.
- `BarterOffer` (Resource): propuesta de trueque → ítem pedido, ítem entregado, niveles de amistad, temporada, límite diario.
- `EconomyManager` (autoload): saldo, transacciones, persistencia, señales.
- `PriceManager` (autoload): cálculo de precio vigente (base + mercado + amistad), tabla del día, ventana de oferta.
- `ShopManager` (autoload): estado de tiendas (stock, horario, reabastecimiento), compra/venta ejecutada.
- `BarterSystem` (autoload): propuestas de trueque, validación, ejecución.
- `MarketMarket` (a definir en 03-Diseno como parte del PriceManager): cálculo del ajuste diario del mercado.

## 6. Relaciones con Otros Módulos

| Módulo | Relación |
|---|---|
| M15 (Recursos) | Los ítems vendibles se referencian por `item_id` del catálogo M15; rareza influye precios base |
| M16 (Crafting) | Los productos craftables se venden en tiendas o al mercado; nivel de receta influye precio |
| M20 (Amistad) | Nivel de amistad del NPC → descuento en su tienda y calidad de trueques |
| M14 (Inventario) | Entrega/recepción de ítems por el contrato estándar `agregar_items/remover_items` |
| M29/M30/M31 (Calendario/Reloj) | Días laborables, horas, estaciones y PRNG del día |
| M73 (Eventos) | Ferias con precios especiales temporales |
| M53 (UI/UX) | Consumidor de señales y datos; nunca inyecta lógica |
| M104 (Analytics) | Registro de transacciones y tendencias del mercado |

## 7. Conclusión del Análisis

La economía de la isla Aurora será un sistema local, data-driven, orientado a eventos diarios, con moneda única y trueque como complemento, diseñado explícitamente para eliminar el estrés económico (sin deuda, sin inflación agresiva, con salvavidas universales). Los subsistemas se mantienen desacoplados mediante autoloads con señales; el diseño queda listo para implementación en Godot 4.x con GDScript tipado.