**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 38: Economía

## A. Problema y objetivos

- [ ] Definir el problema: el juego cozy necesita economía sin estrés, con valor de cambio para M15/M16/M20 [S]
- [ ] Definir el objetivo: comercio tranquilo con la comunidad del pueblo, moneda simple y amable [S]
- [ ] Registrar dependencias del módulo: M15 (Recursos), M16 (Crafting), M20 (Amistad) [S]
- [ ] Registrar relaciones con M29/M30/M31 (calendario y reloj) y M73 (eventos) [S]
- [ ] Registrar relación con M14 (Inventario) para movimientos de ítems [S]
- [ ] Separar dentro/fuera de alcance: UI queda en M53, misiones en M23, deuda descartada [S]
- [ ] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, data-driven, sin red [S]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]
- [ ] Incluir contexto del plan maestro: dinero como herramienta de comunidad, no objetivo [S]
- [ ] Nombrar la moneda del juego: monedas_aurora [S]

## B. Requisitos funcionales

- [ ] RF1: moneda única con saldo entero no negativo, consultable y modificable solo por EconomyManager [M]
- [ ] RF2: catálogo de precios central con PriceDefinition por ítem [M]
- [ ] RF3: compra en tiendas NPC con validación de fondos, stock y horario [M]
- [ ] RF4: venta del jugador con precio de venta y límite diario anti-grind [M]
- [ ] RF5: reabastecimiento de tiendas por día laborable y rotación estacional [M]
- [ ] RF6: horarios de atención declarativos por tienda con señal de cierre [M]
- [ ] RF7: trueque objeto por objeto sin moneda, dependiente de amistad y temporada [M]
- [ ] RF8: factor amistad que otorga descuentos y ofertas únicas de trueque [M]
- [ ] RF9: mercado del pueblo con ajuste suave por oferta y estación (tope ±10%) [M]
- [ ] RF10: tabla de precios del día expuesta como dato para la UI [S]
- [ ] RF11: anti-grind con límite diario por ítem y reventa nunca rentable [M]
- [ ] RF12: salvavidas cozy: con 0 monedas siempre hay trueque de partida disponible [M]
- [ ] RF13: persistencia de saldo, reputación, historial e inventarios de tienda [M]
- [ ] RF14: ferias y eventos con precios especiales temporales (M73) [M]
- [ ] RF15: registro de transacciones para log y analytics (M104) [S]

## C. Requisitos no funcionales

- [ ] RNF1: cero penalizaciones duras, la pobreza no existe como concepto [S]
- [ ] RNF2: precios estables a corto plazo, cambios lentos y anunciados [S]
- [ ] RNF3: rendimiento por eventos discretos, sin bucles por frame [M]
- [ ] RNF4: determinismo con PRNG de partida (M29) en precios del día [M]
- [ ] RNF5: data-driven total en .tres con validación en editor [M]
- [ ] RNF6: desacoplamiento absoluto de la capa de UI, comunicación por señales [M]
- [ ] RNF7: localización i18n con claves string para tiendas y NPCs [S]
- [ ] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [ ] RNF9: sin dependencia de red ni servicios externos [S]
- [ ] RNF10: clamp de saldo a MAX_SALDO con log de advertencia [S]

## D. Análisis del dominio

- [ ] Analizar el subsistema de moneda: única divisa, emisión comunitaria, sin deuda [M]
- [ ] Analizar el subsistema de precios: base de compra y venta, regla anti-aribitraje [M]
- [ ] Analizar el subsistema de comercio: validación, transacción y registro [M]
- [ ] Analizar el subsistema de tiendas: identidad por NPC, horarios y rotación [M]
- [ ] Analizar el subsistema de trueque: intercambio sin moneda ligado a la amistad [M]
- [ ] Analizar el subsistema de mercado: ajuste diario suave por oferta y estación [M]
- [ ] Evaluar alternativa de múltiples divisas y descartarla por fricción anti-cozy [S]
- [ ] Evaluar precios fijos vs dinámicos: se adopta dinámico suave limitado a ±10% [M]
- [ ] Evaluar trueque central vs accesorio: se adopta como complemento y salvavidas [M]
- [ ] Descartar deuda y banca por anti-cozy, alineado al plan maestro [S]
- [ ] Descartar economía simulada en red por juego 100% local [S]
- [ ] Adoptar descuentos por amistad como consolidación de M20 [M]
- [ ] Definir ventana de oferta de 3 días laborables para el mercado [M]
- [ ] Documentar riesgos y mitigaciones en tabla (inflación, grind, bloqueo) [M]

## E. Diseño de subsistemas — Moneda

- [x] Definir saldo como entero no negativo persistido [S]
- [x] EconomyManager como único punto de modificación del saldo [M]
- [ ] Implementar depositar_monedas(cantidad) con clamp a MAX_SALDO [M]
- [x] Implementar retirar_monedas(cantidad) que devuelve false si no alcanza [M]
- [x] Implementar puede_pagar(cantidad) para validaciones previas [S]
- [x] Emitir señal saldo_cambiado(saldo) en cada modificación [S]
- [x] Persistir saldo en guardado junto al resto de la partida [M]
- [ ] Registrar toda transacción monetaria en DOM-ECO-TRX [S]
- [ ] Mantener saldo fuera de la capa de UI: el HUD solo lee [S]

## F. Diseño de subsistemas — Precios y equilibrio

- [ ] Definir PriceDefinition con precio_compra_base y precio_venta_base [M]
- [x] Aplicar regla precio_venta < precio_compra para todo revendible [M]
- [ ] Definir descuento_amistad_max con tope del 15% y niveles 5/10/15 [M]
- [ ] Definir variabilidad_mercado por ítem (0.0 fijo .. 1.0 sensible) [M]
- [x] Definir limite_venta_diario configurable por ítem [S]
- [ ] Definir temporada_bonus para ítems estacionales [S]
- [ ] Definir flag revendible para ítems de misión o ancestrales [S]
- [ ] Crear catálogo central economy_prices.tres [M]
- [ ] Validar catálogo en editor con errores accionables (venta >= compra → error) [M]
- [x] Clamp final de precios vigentes: nunca por debajo de 1 moneda [S]
- [ ] Registrar rangos de precio por rareza de M15 en tabla de balance [M]
- [ ] Combinar descuentos de amistad y mercado sin superar -25% sobre compra base [M]

## G. Diseño de subsistemas — Tiendas

- [ ] Definir ShopDefinition con shop_id, npc_dueño_id y clave i18n [M]
- [ ] Definir horario declarativo: días, hora apertura y hora cierre [M]
- [ ] Definir stock_por_estacion como diccionario estación → ítems [M]
- [ ] Implementar esta_abierta() como consulta pura al calendario M29/M30/M31 [M]
- [ ] Implementar comprar() con validaciones y señales de éxito/rechazo [C]
- [ ] Implementar vender() con penalización 50% al superar límite diario [C]
- [ ] Implementar reabastecer_diario() restaurando stock base [M]
- [ ] Aplicar rotación estacional de inventario al cambiar estación [M]
- [ ] Emitir señal inventario_tienda_cambio al alterar stock [S]
- [ ] Registrar 3 tiendas de ejemplo: pescadería, agrícola y artesanías [M]
- [ ] Evitar stock duplicado entre tiendas mediante validación en editor [S]

## H. Diseño de subsistemas — Trueque

- [ ] Definir BarterOffer con oferta_id, pedido y entregado [M]
- [ ] Definir amistad_minima para desbloqueo por nivel de M20 [M]
- [ ] Definir temporada para propuestas estacionales [S]
- [ ] Definir limite_por_dia para prevenir abuso [S]
- [ ] Implementar propuestas_disponibles(npc_id) con filtros de amistad y temporada [M]
- [ ] Implementar ejecutar_trueque() con intercambio atómico vía M14 [C]
- [ ] Emitir señales trueque_exitoso y trueque_rechazado con motivo [M]
- [ ] Implementar contadores usos_hoy y limite_diario por NPC [M]
- [ ] Definir trueque de partida salvavidas: bienes comunes por herramienta básica [M]
- [ ] Registrar DOM-ECO-TRUEQUE en cada ejecución [S]
- [ ] Validar que el trueque nunca intercambie ítems únicos de progreso (M22/M23) [S]

## I. Diseño de subsistemas — Mercado del pueblo

- [ ] Recalcular tabla del día una vez por día laborable al amanecer (M31) [M]
- [ ] Usar PRNG de partida (M29) para coherencia entre sesiones [M]
- [ ] Aplicar ajuste estacional: +5% en temporada, -10% fuera (tope ±10%) [M]
- [ ] Aplicar ajuste por oferta: ventana de los últimos 3 días laborables [M]
- [ ] Clamp final dentro de [70%, 110%] del precio base [S]
- [ ] Exponer tabla_del_dia() como copia de solo lectura [S]
- [ ] Emitir señal tabla_precios_actualizada para refrescar la UI [S]
- [ ] Aplicar precios especiales de ferias y revertirlos al finalizar (M73) [M]
- [ ] Emitir señal precio_rebajado al superar el límite diario [S]
- [ ] Registrar DOM-ECO-MERCADO con motivos de cada ajuste [M]

## J. Integración con módulos 15/16/20

- [ ] Usar item_id del catálogo M15 como clave primaria de PriceDefinition [S]
- [ ] Derivar rangos de precio por rareza definida en M15 [M]
- [ ] Marcar revendible=false los recursos de misión y ancestrales [S]
- [ ] No intervenir la recolección de M15: la economía solo lee y recibe ítems [S]
- [ ] Permitir que cada producto de M16 declare su PriceDefinition al crear la receta [M]
- [ ] Definir precio de venta de productos craftables como fijo e independiente de materiales [M]
- [ ] Garantizar que craftear para vender no sea rentable (anti-aribitraje) [M]
- [ ] Consumir señal nivel_amistad_cambio(npc, nivel) de M20 para invalidar cachés [M]
- [ ] Aplicar descuentos 5/10/15% por niveles 2/3/4 de amistad en compras [M]
- [ ] Desbloquear trueques únicos por amistad_minima [M]
- [ ] Garantizar que amistad nunca bloquee el comercio básico (nivel 0 opera) [S]
- [ ] Delegar movimientos de ítems al contrato M14 agregar_items/remover_items [M]
- [ ] Documentar la integración por señales en 03-Diseno [S]

## K. Edge cases

- [ ] Precio de compra/venta en 0 o negativo: clamp a 1 y advertencia en log [M]
- [ ] Jugador sin fondos: rechazo con motivo SIN_FONDOS, sin mensajes duros [M]
- [ ] Jugador con 0 monedas totales: trueque de partida siempre disponible [M]
- [ ] Superar límite diario de venta: precio al 50% con señal clara [M]
- [ ] Stock agotado: compra rechazada con motivo SIN_STOCK [S]
- [ ] Tienda cerrada: compra rechazada con motivo CERRADA [S]
- [ ] Inventario lleno en transacción: operación abortada sin pérdida de ítems [M]
- [ ] Trueque sin materiales: rechazo sin penalizar contadores diarios [S]
- [ ] Día sin ventas: tabla del día sin cambios, sin ajuste por oferta vacía [S]
- [ ] Evento feria al amanecer: precios especiales conviven con el recálculo sin pisarse [M]
- [ ] Guardado a mitad del día: contadores diarios y ventana se restauran exactos [M]
- [ ] Saldo en MAX_SALDO: depósitos se clampan con aviso DOM-ECO-SALDO [S]
- [ ] Ítem sin PriceDefinition en catálogo: error de validación en editor, precaución en runtime [M]
- [ ] Descuento de amistad + penalización de límite: nunca precio final 0 o negativo [M]

## L. Optimización

- [ ] Consultas de precio en O(1) con diccionarios item_id → definición [M]
- [ ] Precargar catálogos en _ready() de cada autoload [S]
- [ ] Calcular tabla del día una sola vez por día laborable [M]
- [ ] Sin bucles por frame: el módulo solo reacciona a eventos [M]
- [ ] Usar enteros y clamps en todo el camino del precio final [S]
- [ ] Caché de descuento por pareja (npc, item) invalidado solo por señal de M20 [M]
- [ ] Acotar ventana de oferta a 3 días con arrays de tamaño fijo [S]
- [ ] Evitar instanciación de nodos en transacciones: todo pasa por datos [M]
- [ ] Dejar las transacciones libres de asignaciones de memoria pesada [S]

## M. Documentación entregada

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF15 [M]
- [ ] Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M]
- [ ] Crear 03-Diseno.md con arquitectura, flujos, clases y balance [M]
- [ ] Crear 04-Codigo.md con rutas previstas res://economia/... y firmas GDScript [M]
- [ ] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [ ] Crear 05-Checklist.md con 146 ítems todos completados [M]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]
- [ ] Recomendar 06-Plan-Testings y 07-Resultados-Testings para la fase de implementación [S]

## N. Testings

- [ ] Definir prueba de compra normal con desglose moneda/ítem/stock [M]
- [ ] Definir prueba de venta con respeto de límite diario y penalización [M]
- [ ] Definir prueba de trueque exitoso y rechazado con motivos [M]
- [ ] Definir prueba de determinismo del mercado con misma semilla [M]
- [ ] Definir prueba de persistencia: guardar/cargar con saldo e historial exactos [M]
- [ ] Definir prueba de ferias: precios especiales se aplican y revierten [M]
- [ ] Definir prueba de descuentos por amistad en 3 niveles [M]
- [ ] Definir prueba de anti-aribitraje: reventa de crafting nunca rentable [M]
- [ ] Definir prueba de rendimiento: 5000 transacciones simuladas sin picos [M]
- [ ] Definir prueba de edge cases: precios cero, inventario lleno, 0 monedas [M]
- [ ] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]