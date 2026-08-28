**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md â€” MÃ³dulo 38: EconomÃ­a

## A. Problema y objetivos

- [ ] Definir el problema: el juego cozy necesita economÃ­a sin estrÃ©s, con valor de cambio para M15/M16/M20 [S]
- [ ] Definir el objetivo: comercio tranquilo con la comunidad del pueblo, moneda simple y amable [S]
- [ ] Registrar dependencias del mÃ³dulo: M15 (Recursos), M16 (Crafting), M20 (Amistad) [S]
- [ ] Registrar relaciones con M29/M30/M31 (calendario y reloj) y M73 (eventos) [S]
- [ ] Registrar relaciÃ³n con M14 (Inventario) para movimientos de Ã­tems [S]
- [ ] Separar dentro/fuera de alcance: UI queda en M53, misiones en M23, deuda descartada [S]
- [ ] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, data-driven, sin red [S]
- [ ] Definir criterios de aceptaciÃ³n verificables (8 criterios) [S]
- [ ] Incluir contexto del plan maestro: dinero como herramienta de comunidad, no objetivo [S]
- [ ] Nombrar la moneda del juego: monedas_aurora [S]

## B. Requisitos funcionales

- [ ] RF1: moneda Ãºnica con saldo entero no negativo, consultable y modificable solo por EconomyManager [M]
- [ ] RF2: catÃ¡logo de precios central con PriceDefinition por Ã­tem [M]
- [ ] RF3: compra en tiendas NPC con validaciÃ³n de fondos, stock y horario [M]
- [ ] RF4: venta del jugador con precio de venta y lÃ­mite diario anti-grind [M]
- [ ] RF5: reabastecimiento de tiendas por dÃ­a laborable y rotaciÃ³n estacional [M]
- [ ] RF6: horarios de atenciÃ³n declarativos por tienda con seÃ±al de cierre [M]
- [ ] RF7: trueque objeto por objeto sin moneda, dependiente de amistad y temporada [M]
- [ ] RF8: factor amistad que otorga descuentos y ofertas Ãºnicas de trueque [M]
- [ ] RF9: mercado del pueblo con ajuste suave por oferta y estaciÃ³n (tope Â±10%) [M]
- [ ] RF10: tabla de precios del dÃ­a expuesta como dato para la UI [S]
- [ ] RF11: anti-grind con lÃ­mite diario por Ã­tem y reventa nunca rentable [M]
- [ ] RF12: salvavidas cozy: con 0 monedas siempre hay trueque de partida disponible [M]
- [ ] RF13: persistencia de saldo, reputaciÃ³n, historial e inventarios de tienda [M]
- [ ] RF14: ferias y eventos con precios especiales temporales (M73) [M]
- [ ] RF15: registro de transacciones para log y analytics (M104) [S]

## C. Requisitos no funcionales

- [ ] RNF1: cero penalizaciones duras, la pobreza no existe como concepto [S]
- [ ] RNF2: precios estables a corto plazo, cambios lentos y anunciados [S]
- [ ] RNF3: rendimiento por eventos discretos, sin bucles por frame [M]
- [ ] RNF4: determinismo con PRNG de partida (M29) en precios del dÃ­a [M]
- [ ] RNF5: data-driven total en .tres con validaciÃ³n en editor [M]
- [ ] RNF6: desacoplamiento absoluto de la capa de UI, comunicaciÃ³n por seÃ±ales [M]
- [ ] RNF7: localizaciÃ³n i18n con claves string para tiendas y NPCs [S]
- [ ] RNF8: GDScript tipado explÃ­cito compatible con Godot 4.x (>= 4.4.1) [S]
- [ ] RNF9: sin dependencia de red ni servicios externos [S]
- [x] RNF10: clamp de saldo a MAX_SALDO con log de advertencia [S]

## D. AnÃ¡lisis del dominio

- [ ] Analizar el subsistema de moneda: Ãºnica divisa, emisiÃ³n comunitaria, sin deuda [M]
- [ ] Analizar el subsistema de precios: base de compra y venta, regla anti-aribitraje [M]
- [ ] Analizar el subsistema de comercio: validaciÃ³n, transacciÃ³n y registro [M]
- [ ] Analizar el subsistema de tiendas: identidad por NPC, horarios y rotaciÃ³n [M]
- [ ] Analizar el subsistema de trueque: intercambio sin moneda ligado a la amistad [M]
- [ ] Analizar el subsistema de mercado: ajuste diario suave por oferta y estaciÃ³n [M]
- [ ] Evaluar alternativa de mÃºltiples divisas y descartarla por fricciÃ³n anti-cozy [S]
- [ ] Evaluar precios fijos vs dinÃ¡micos: se adopta dinÃ¡mico suave limitado a Â±10% [M]
- [ ] Evaluar trueque central vs accesorio: se adopta como complemento y salvavidas [M]
- [ ] Descartar deuda y banca por anti-cozy, alineado al plan maestro [S]
- [ ] Descartar economÃ­a simulada en red por juego 100% local [S]
- [ ] Adoptar descuentos por amistad como consolidaciÃ³n de M20 [M]
- [ ] Definir ventana de oferta de 3 dÃ­as laborables para el mercado [M]
- [ ] Documentar riesgos y mitigaciones en tabla (inflaciÃ³n, grind, bloqueo) [M]

## E. DiseÃ±o de subsistemas â€” Moneda

- [x] Definir saldo como entero no negativo persistido [S]
- [x] EconomyManager como Ãºnico punto de modificaciÃ³n del saldo [M]
- [x] Implementar depositar_monedas(cantidad) con clamp a MAX_SALDO [M]
- [x] Implementar retirar_monedas(cantidad) que devuelve false si no alcanza [M]
- [x] Implementar puede_pagar(cantidad) para validaciones previas [S]
- [x] Emitir seÃ±al saldo_cambiado(saldo) en cada modificaciÃ³n [S]
- [x] Persistir saldo en guardado junto al resto de la partida [M]
- [ ] Registrar toda transacciÃ³n monetaria en DOM-ECO-TRX [S]
- [ ] Mantener saldo fuera de la capa de UI: el HUD solo lee [S]

## F. DiseÃ±o de subsistemas â€” Precios y equilibrio

- [ ] Definir PriceDefinition con precio_compra_base y precio_venta_base [M]
- [x] Aplicar regla precio_venta < precio_compra para todo revendible [M]
- [x] Definir descuento_amistad_max con tope del 15% — escalones 5/10/15% en niveles de amistad 2/3/4 de M20 (implementado en price_manager, validado con test_consumidores_tiempo) [M]
- [ ] Definir variabilidad_mercado por Ã­tem (0.0 fijo .. 1.0 sensible) [M]
- [x] Definir limite_venta_diario configurable por Ã­tem [S]
- [ ] Definir temporada_bonus para Ã­tems estacionales [S]
- [ ] Definir flag revendible para Ã­tems de misiÃ³n o ancestrales [S]
- [~] Crear catÃ¡logo central economy_prices.tres [M]  <!-- EN PROGRESO: ox-alpha (Cline) -->
- [ ] Validar catÃ¡logo en editor con errores accionables (venta >= compra â†’ error) [M]
- [x] Clamp final de precios vigentes: nunca por debajo de 1 moneda [S]
- [ ] Registrar rangos de precio por rareza de M15 en tabla de balance [M]
- [ ] Combinar descuentos de amistad y mercado sin superar -25% sobre compra base [M]

## G. DiseÃ±o de subsistemas â€” Tiendas

- [ ] Definir ShopDefinition con shop_id, npc_dueÃ±o_id y clave i18n [M]
- [ ] Definir horario declarativo: dÃ­as, hora apertura y hora cierre [M]
- [ ] Definir stock_por_estacion como diccionario estaciÃ³n â†’ Ã­tems [M]
- [ ] Implementar esta_abierta() como consulta pura al calendario M29/M30/M31 [M]
- [ ] Implementar comprar() con validaciones y seÃ±ales de Ã©xito/rechazo [C]
- [ ] Implementar vender() con penalizaciÃ³n 50% al superar lÃ­mite diario [C]
- [ ] Implementar reabastecer_diario() restaurando stock base [M]
- [ ] Aplicar rotaciÃ³n estacional de inventario al cambiar estaciÃ³n [M]
- [ ] Emitir seÃ±al inventario_tienda_cambio al alterar stock [S]
- [ ] Registrar 3 tiendas de ejemplo: pescaderÃ­a, agrÃ­cola y artesanÃ­as [M]
- [ ] Evitar stock duplicado entre tiendas mediante validaciÃ³n en editor [S]

## H. DiseÃ±o de subsistemas â€” Trueque

- [ ] Definir BarterOffer con oferta_id, pedido y entregado [M]
- [ ] Definir amistad_minima para desbloqueo por nivel de M20 [M]
- [ ] Definir temporada para propuestas estacionales [S]
- [x] Definir limite_por_dia para prevenir abuso [S] (implementado: limite_ventas_dia por banda de rareza en PriceManager, log 191)
- [ ] Implementar propuestas_disponibles(npc_id) con filtros de amistad y temporada [M]
- [ ] Implementar ejecutar_trueque() con intercambio atÃ³mico vÃ­a M14 [C]
- [ ] Emitir seÃ±ales trueque_exitoso y trueque_rechazado con motivo [M]
- [ ] Implementar contadores usos_hoy y limite_diario por NPC [M]
- [ ] Definir trueque de partida salvavidas: bienes comunes por herramienta bÃ¡sica [M]
- [ ] Registrar DOM-ECO-TRUEQUE en cada ejecuciÃ³n [S]
- [ ] Validar que el trueque nunca intercambie Ã­tems Ãºnicos de progreso (M22/M23) [S]

## I. DiseÃ±o de subsistemas â€” Mercado del pueblo

- [ ] Recalcular tabla del dÃ­a una vez por dÃ­a laborable al amanecer (M31) [M]
- [ ] Usar PRNG de partida (M29) para coherencia entre sesiones [M]
- [ ] Aplicar ajuste estacional: +5% en temporada, -10% fuera (tope Â±10%) [M]
- [ ] Aplicar ajuste por oferta: ventana de los Ãºltimos 3 dÃ­as laborables [M]
- [ ] Clamp final dentro de [70%, 110%] del precio base [S]
- [ ] Exponer tabla_del_dia() como copia de solo lectura [S]
- [ ] Emitir seÃ±al tabla_precios_actualizada para refrescar la UI [S]
- [ ] Aplicar precios especiales de ferias y revertirlos al finalizar (M73) [M]
- [ ] Emitir seÃ±al precio_rebajado al superar el lÃ­mite diario [S]
- [ ] Registrar DOM-ECO-MERCADO con motivos de cada ajuste [M]

## J. IntegraciÃ³n con mÃ³dulos 15/16/20

- [ ] Usar item_id del catÃ¡logo M15 como clave primaria de PriceDefinition [S]
- [ ] Derivar rangos de precio por rareza definida en M15 [M]
- [ ] Marcar revendible=false los recursos de misiÃ³n y ancestrales [S]
- [ ] No intervenir la recolecciÃ³n de M15: la economÃ­a solo lee y recibe Ã­tems [S]
- [ ] Permitir que cada producto de M16 declare su PriceDefinition al crear la receta [M]
- [ ] Definir precio de venta de productos craftables como fijo e independiente de materiales [M]
- [ ] Garantizar que craftear para vender no sea rentable (anti-aribitraje) [M]
- [ ] Consumir seÃ±al nivel_amistad_cambio(npc, nivel) de M20 para invalidar cachÃ©s [M]
- [ ] Aplicar descuentos 5/10/15% por niveles 2/3/4 de amistad en compras [M]
- [ ] Desbloquear trueques Ãºnicos por amistad_minima [M]
- [ ] Garantizar que amistad nunca bloquee el comercio bÃ¡sico (nivel 0 opera) [S]
- [ ] Delegar movimientos de Ã­tems al contrato M14 agregar_items/remover_items [M]
- [ ] Documentar la integraciÃ³n por seÃ±ales en 03-Diseno [S]

## K. Edge cases

- [ ] Precio de compra/venta en 0 o negativo: clamp a 1 y advertencia en log [M]
- [ ] Jugador sin fondos: rechazo con motivo SIN_FONDOS, sin mensajes duros [M]
- [ ] Jugador con 0 monedas totales: trueque de partida siempre disponible [M]
- [ ] Superar lÃ­mite diario de venta: precio al 50% con seÃ±al clara [M]
- [ ] Stock agotado: compra rechazada con motivo SIN_STOCK [S]
- [ ] Tienda cerrada: compra rechazada con motivo CERRADA [S]
- [ ] Inventario lleno en transacciÃ³n: operaciÃ³n abortada sin pÃ©rdida de Ã­tems [M]
- [ ] Trueque sin materiales: rechazo sin penalizar contadores diarios [S]
- [ ] DÃ­a sin ventas: tabla del dÃ­a sin cambios, sin ajuste por oferta vacÃ­a [S]
- [ ] Evento feria al amanecer: precios especiales conviven con el recÃ¡lculo sin pisarse [M]
- [ ] Guardado a mitad del dÃ­a: contadores diarios y ventana se restauran exactos [M]
- [x] Saldo en MAX_SALDO: depósitos se clampan con aviso DOM-ECO-SALDO [S]
- [ ] Ãtem sin PriceDefinition en catÃ¡logo: error de validaciÃ³n en editor, precauciÃ³n en runtime [M]
- [ ] Descuento de amistad + penalizaciÃ³n de lÃ­mite: nunca precio final 0 o negativo [M]

## L. OptimizaciÃ³n

- [ ] Consultas de precio en O(1) con diccionarios item_id â†’ definiciÃ³n [M]
- [ ] Precargar catÃ¡logos en _ready() de cada autoload [S]
- [ ] Calcular tabla del dÃ­a una sola vez por dÃ­a laborable [M]
- [ ] Sin bucles por frame: el mÃ³dulo solo reacciona a eventos [M]
- [ ] Usar enteros y clamps en todo el camino del precio final [S]
- [ ] CachÃ© de descuento por pareja (npc, item) invalidado solo por seÃ±al de M20 [M]
- [ ] Acotar ventana de oferta a 3 dÃ­as con arrays de tamaÃ±o fijo [S]
- [ ] Evitar instanciaciÃ³n de nodos en transacciones: todo pasa por datos [M]
- [ ] Dejar las transacciones libres de asignaciones de memoria pesada [S]

## M. DocumentaciÃ³n entregada

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF15 [M]
- [ ] Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M]
- [ ] Crear 03-Diseno.md con arquitectura, flujos, clases y balance [M]
- [ ] Crear 04-Codigo.md con rutas previstas res://economia/... y firmas GDScript [M]
- [ ] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [ ] Crear 05-Checklist.md con 146 Ã­tems todos completados [M]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Copiar plan-inicial a plan-actual byte a byte (verificaciÃ³n por hash) [S]
- [ ] Recomendar 06-Plan-Testings y 07-Resultados-Testings para la fase de implementaciÃ³n [S]

## N. Testings

- [ ] Definir prueba de compra normal con desglose moneda/Ã­tem/stock [M]
- [ ] Definir prueba de venta con respeto de lÃ­mite diario y penalizaciÃ³n [M]
- [ ] Definir prueba de trueque exitoso y rechazado con motivos [M]
- [ ] Definir prueba de determinismo del mercado con misma semilla [M]
- [ ] Definir prueba de persistencia: guardar/cargar con saldo e historial exactos [M]
- [ ] Definir prueba de ferias: precios especiales se aplican y revierten [M]
- [ ] Definir prueba de descuentos por amistad en 3 niveles [M]
- [ ] Definir prueba de anti-aribitraje: reventa de crafting nunca rentable [M]
- [ ] Definir prueba de rendimiento: 5000 transacciones simuladas sin picos [M]
- [ ] Definir prueba de edge cases: precios cero, inventario lleno, 0 monedas [M]
- [ ] Marcar testings como pendientes hasta la implementaciÃ³n (se ejecutarÃ¡n segÃºn secciÃ³n 14 de AGENTS.md) [S]
- [x] Implementar limite_ventas_dia por banda de rareza: comun=3, poco_comun=3, raro=2, epico=1, con resolucion desde catalogo (PriceDefinition.rareza) y fallback al enum ItemData.Rareza [M] (log 191)
