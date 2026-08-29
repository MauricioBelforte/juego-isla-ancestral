**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 39: Tiendas

## A. Problema y objetivos

- [ ] Definir el problema: sin tiendas, la economía de M38 no tiene cara visible ni punto de intercambio [S]
- [ ] Definir el objetivo: tiendas vivas como atributos de NPCs con catálogo, horario, descanso y stock renovable [S]
- [ ] Registrar dependencias del módulo: M38 (Economía), M14 (Inventario), M29 (Calendario), M30 (Reloj) [S]
- [ ] Registrar relaciones con M19 (Población), M20 (Amistad), M53 (UI) y M73 (Eventos) [S]
- [ ] Separar dentro/fuera de alcance: precios y moneda en M38, UI completa en M53, misiones en M23 [S]
- [ ] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, data-driven, determinismo PRNG, sin red [S]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]
- [ ] Incluir contexto del plan maestro: pueblo vivo con comercios que abren, cierran y reabastecen [S]
- [ ] Nombrar los cinco tipos de tienda: semillas, pescadería, ferretería, general y mercader viajero [M]
- [ ] Fijar la regla de oro: el módulo jamás define precios, solo consulta M38 [M]

## B. RF — Catálogos por NPC

- [x] RF3: catálogo por comerciante con ítems ofrecidos y ítems recomprados (ShopCatalog) [M]
- [x] Definir items_venta como lista de StockEntry con rangos de stock [M]
- [x] Definir items_recompra como lista de item_id (recompra selectiva por tienda) [M]
- [ ] Definir pool_rodante exclusivo de mercaderes viajeros [M]
- [ ] Validar en editor que cada item_id del catálogo exista en M15 [M]
- [ ] Validar en editor que no haya ítems duplicados dentro del mismo catálogo [S]
- [x] Garantizar que los ítems básicos de cada tipo tengan stock_min >= 1 [M]

## C. RF — Tipos de tienda

- [x] RF2: enum TipoTienda con SEMILLAS, PESCADERIA, FERRETERIA, GENERAL y VIAJERO (+ TIENDA_JUGADOR para reputación) [S]
- [ ] Definir defaults de catálogo y stock por tipo (tabla de balance del 03-Diseno) [M]
- [ ] Puesto de semillas: rotación estacional fuerte con semillas básicas siempre presentes [M]
- [ ] Pescadería: catálogo ligado a la pesca de la estación y cebos [M]
- [ ] Ferretería: herramientas y materiales con stock estable y mayor ticket [M]
- [ ] Tienda general: mezcla flexible de comida, decoración y cotidianos [M]
- [ ] Mercader viajero: sin local fijo, catálogo rodante y recargos dentro de topes de M38 [M]

## D. RF — Compra

- [x] RF10: flujo de compra jugador → tienda con validación en cascada completa (2.1 del 03-Diseno) [C]
- [x] Validar existencia de la tienda antes de cualquier operación [S]
- [x] Validar tienda abierta (consulta pura a M29/M30) antes de comprar [M]
- [x] Validar stock suficiente antes de descontar [M]
- [x] Validar fondos con EconomyManager.puede_pagar antes de retirar [M]
- [x] Validar cupo del inventario jugador (M14) antes de entregar ítems [M]
- [x] Calcular total = precio_compra_vigente * cantidad con enteros [M]
- [x] Ejecutar transacción atómica con reversión de stock si M14 falla [C]
- [x] Emitir señales compra_exitosa/compra_rechazada con motivo legible [S]

## E. RF — Venta

- [x] RF11: flujo de venta jugador → tienda con recompra selectiva (2.2 del 03-Diseno) [C]
- [x] Validar tienda existente y abierta antes de vender [S]
- [x] Validar que el ítem esté en items_recompra de la tienda (NO_RECOMPRA) [M]
- [x] Remover ítems del inventario jugador (M14) antes de depositar monedas [M]
- [x] Rechazar con SIN_ITEMS_JUGADOR si no hay cantidad suficiente [S]
- [x] Usar precio_venta_vigente de M38 (respeta anti-grind y ventana de oferta) [M]
- [x] Acumular en la tienda lo recomprado (stock_actual += cantidad vendida) [M]
- [x] Emitir venta_exitosa/venta_rechazada y registrar en log DOM-TIEN-VENTA [S]

---

## Notas del Agente

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-25
**Estado:** Parcial (capa de datos implementada; integraciones y UI pendientes)

### Lo que hice
- Implementé la capa de datos completa: `shop_data.gd` (Resource), `shop.gd` (runtime), `stock_generator.gd` (canalización determinista), `reputacion_tienda.gd` (niveles 0-5 cozy), `shop_manager.gd` (autoload con compra/venta atómica y señales).
- Autoload ShopManager registrado en project.godot.
- Los 5 scripts pasan `--check-only --headless` de Godot 4.7.2 sin errores.
- Log 167 generado.

### Lo que NO pude hacer (honestidad obligatoria)
- Los ítems de flujo D/E marcados [x] tienen el CÓDIGO implementado, pero NO fueron probados end-to-end porque M38 (EconomyManager) y M14 (Inventario) aún no existen como autoloads. Hoy toda compra/venta rechaza con SISTEMA_NO_DISPONIBLE por diseño defensivo.
- Rotación estacional real y filtros por eventos: placeholders hasta que existan M29/M73.
- Pool rodante de mercader viajero, catálogos .tres reales, validación contra M15: pendientes.
- UI de compra (M53): fuera de alcance de este turno según directiva del usuario.

### Recomendaciones para el próximo agente
- Cuando se implemente M38/M14, verificar que sus autoloads se llamen exactamente `EconomyManager` e `Inventario`, o ajustar las rutas en shop_manager.gd (`get_node_or_null("/root/...")`).
- Probar transacción atómica con inventario lleno (revert de stock).
- Conectar `tick_hora()` al reloj de M30 y `reabastecer_diario()` al calendario de M29.


## F. RF — Horarios y días de descanso

- [ ] RF4: definir dias_abierto, hora_apertura y hora_cierre en ShopDefinition [M]
- [ ] RF5: definir dias_descanso como días cerrados explícitos por tienda [M]
- [x] Implementar esta_abierta como función pura (día M29 + hora M30 + rangos) [M] (implementado: ShopManager.esta_abierta consulta M29 TimeCalendar con fallback a M30 GameClock, log 192)
- [ ] Sin estado interno booleano de apertura (D4: consulta, no flag) [M]
- [ ] Emitir tienda_cerrada con próxima apertura para el cartel de la UI [M]
- [ ] Probar borde de hora exacta: apertura a las 09:00 incluida, cierre a las 17:00 excluido [M]
- [ ] Probar día de descanso: tienda cerrada todo el día aunque esté en horario [M]
- [ ] Mercader viajero: su "horario" es el calendario de aparición, no franja diaria [M]

## G. RF — Stock y canalizaciones

- [ ] RF6: stock inicial generado por StockGenerator al registrar la tienda [C]
- [ ] RF7: reabastecimiento diario por evento nuevo_dia_laborable de M29 [C]
- [ ] RF8: rotación estacional filtrando StockEntry.temporadas [M]
- [ ] RF9: canalización en 5 etapas: base, estación, eventos, aforo, PRNG [C]
- [ ] Etapa base: materializar entradas del catálogo con rangos min/max [M]
- [ ] Etapa estación: descartar ítems fuera de temporada sin tocar básicos garantizados [M]
- [ ] Etapa eventos: agregar ítems solo_evento activos (ferias M73) [M]
- [ ] Etapa aforo: clamp min/max y peso_rareza (raros con menos ejemplares) [M]
- [ ] Etapa PRNG: variación determinista con semilla de partida (M29) [C]
- [ ] Idempotencia del restock: fecha_ultimo_restock evita doble reabastecimiento el mismo día [M]
- [ ] Restock por D6: reponer hasta máximos conservando sobrantes (nunca tirar stock) [M]

## H. RF — Precios (delegados a M38)

- [ ] RF12: precio_compra_vigente consultado a PriceManager en cada compra [M]
- [ ] RF12: precio_venta_vigente consultado a PriceManager en cada venta [M]
- [ ] Precios jugador-vendedor distintos: compra (paga) vs venta (recibe) [M]
- [ ] Mercader viajero: recargos declarados pasados como parámetro a M38 [M]
- [ ] Nunca cachear precios entre operaciones: consulta fresca por operación [S]
- [ ] Jamás calcular precios dentro de tiendas (D7) [M]
- [ ] Total con clamp: cantidad válida > 0 y precio >= 1 garantizado por M38 [S]

## I. Requisitos no funcionales

- [ ] RNF1: tono cozy: nunca se pierden ítems comprados por error del sistema [M]
- [ ] RNF2: stock básico nunca desaparece del todo (stock_min garantizado) [M]
- [ ] RNF3: sistema discreto por eventos, sin bucles por frame [M]
- [ ] RNF4: determinismo de stock y mercaderes con PRNG de partida (M29) [M]
- [ ] RNF5: data-driven total en .tres con validación en editor accionable [M]
- [ ] RNF6: desacoplamiento absoluto de la UI, comunicación por señales [M]
- [ ] RNF7: claves i18n para tiendas, catálogos y mensajes [S]
- [ ] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [ ] RNF9: transacciones atómicas: o ambas partes se mueven o ninguna [C]
- [ ] RNF10: stock nunca negativo en ningún punto del flujo [M]

## J. Análisis del dominio

- [ ] Analizar los cinco tipos de tienda y sus diferencias de catálogo/stock [M]
- [ ] Analizar tiendas como atributos de NPCs (identidad, amistad M20, interacción) [M]
- [ ] Analizar catálogos por NPC: venta + recompra selectiva [M]
- [ ] Analizar horarios y descansos como consulta pura al calendario [M]
- [ ] Analizar canalizaciones de stock: etapas y determinismo [C]
- [ ] Analizar precios dinámicos vs fijos: delegados a M38 con variabilidad diaria [M]
- [ ] Analizar compra/venta con validaciones en cascada y atomicidad [M]
- [ ] Analizar renovación de stock: diaria + estacional + regeneración de viajeros [M]
- [ ] Analizar eventos y ferias como etapa temporal reversible [M]
- [ ] Evaluar stock infinito y descartarlo por falta de vida [S]
- [ ] Evaluar catálogo único por tipo y descartarlo: los puestos serían clones [S]
- [ ] Evaluar precios propios por tienda y descartarlos: divergencia con M38 [S]

## K. Diseño y arquitectura

- [ ] Definir architecture: ShopManager (autoload) + Shop (RefCounted) + StockGenerator + ShopUI [C]
- [ ] ShopManager: registro de tiendas con acceso O(1) por shop_id [M]
- [ ] ShopManager: orquesta compra/venta/restock/mercaderes y emite todas las señales [C]
- [ ] Shop: estado runtime (definición, stock_actual, fechas, mercader activo) [M]
- [ ] Shop: sin señales propias (las emite el manager) [S]
- [ ] StockGenerator: RefCounted helper con modos INICIAL/RESTOCK/APARICION [M]
- [ ] ShopUI: script de capa M53 desacoplado que solo consume señales [M]
- [ ] Diagrama de flujo de compra completo (2.1) documentado [S]
- [ ] Diagrama de flujo de venta completo (2.2) documentado [S]
- [ ] Diagrama de reabastecimiento diario (2.3) documentado [S]
- [ ] Diagrama de aparición de mercader viajero (2.4) documentado [S]
- [ ] Contrato de señales tabulado con emisores y consumidores [M]
- [ ] Persistencia definida: stock_actual, fechas, mercaderes y recuperación de días perdidos [M]
- [ ] Tabla de balance por tipo de tienda documentada [M]

## L. Integración con M14 (Inventario)

- [ ] Compra entrega ítems vía Inventario.agregar_items [M]
- [ ] Venta remueve ítems vía Inventario.remover_items [M]
- [ ] Si agregar_items falla (inventario lleno), revertir stock descontado [C]
- [ ] Si remover_items falla, rechazar venta sin mover monedas [M]
- [ ] Stock de tienda nunca se mezcla con inventario del jugador [S]
- [ ] Operaciones de ítems en diccionarios {item_id: cantidad} compatibles con M14 [S]

## M. Integración con M19/M20 (Población y Amistad)

- [ ] npc_duenio_id obligatorio y validado contra la población (M19) [M]
- [ ] La tienda se abre interactuando con el NPC dueño en escena [M]
- [ ] La amistad (M20) afecta descuentos vía M38, no en este módulo [S]
- [ ] Catálogo especial por amistad se resuelve como datos en .tres (si aplica) [M]
- [ ] Tienda sin dueño válido = error de validación en editor [S]

## N. Integración con M29/M30 (Calendario y Reloj)

- [ ] Consumir nuevo_dia_laborable para restock y evaluación de mercaderes [C]
- [ ] Consumir estacion_cambio para rotación estacional [M]
- [ ] Recibir PRNG del día desde M29 para StockGenerator [M]
- [x] Consultar día y hora actuales a M29/M30 para esta_abierta [M] (implementado, log 192)
- [ ] Días de la semana 1-7 consistentes con el calendario de M29 [S]
- [ ] Sin estados de apertura manuales que puedan desincronizar (D4) [M]
- [ ] Recuperación de días perdidos al cargar partidas viejas [M]

## O. Integración con M38 (Economía)

- [ ] precio_compra_vigente(item_id, npc_id) consumida en compras [M]
- [ ] precio_venta_vigente(item_id) consumida en ventas [M]
- [ ] EconomyManager.retirar_monedas usado en compras [M]
- [ ] EconomyManager.depositar_monedas usado en ventas [M]
- [ ] Anti-grind y ventana de oferta resueltos internamente por M38 [S]
- [ ] Recargo de mercader viajero pasado como parámetro opcional a M38 [M]
- [ ] Verificar nombres reales de funciones de M38 antes de implementar [S]

## P. Integración con M53 (UI) y M73 (Eventos)

- [ ] ShopUI pide datos de catálogo, stock y precios sin lógica de negocio [M]
- [ ] UI consume señales compra/venta/inventario_tienda_cambio [M]
- [ ] Cartel de cierre con próxima apertura (tienda_cerrada) [M]
- [ ] Feedback de rechazo con motivo legible y no duro [S]
- [ ] Ferias (M73): mercaderes con aparición garantizada vía evento_iniciado [M]
- [ ] Evento finalizado revierte catálogo extendido del día siguiente (D10) [M]

## Q. Edge cases

- [ ] Tienda cerrada: rechazo CERRADA sin efectos laterales [M]
- [ ] Día de descanso: cerrada aunque esté dentro de la franja horaria [M]
- [ ] Stock vacío de un ítem: rechazo SIN_STOCK y fila deshabilitada en UI [M]
- [ ] Jugador sin fondos: rechazo SIN_FONDOS sin castigos ni mensajes duros [M]
- [ ] Jugador con 0 monedas: puede vender para obtener ingresos (básicos siempre recomprados) [M]
- [ ] Cantidad inválida (0 o negativa): rechazo CANTIDAD_INVALIDA [S]
- [ ] Inventario jugador lleno al comprar: reversión total del stock [C]
- [ ] Venta de un ítem no recomprado por la tienda: NO_RECOMPRA [S]
- [ ] Venta con menos ítems de los pedidos: SIN_ITEMS_JUGADOR sin tocar monedas [M]
- [ ] Restock doble del mismo día (señal duplicada): idempotente por fecha [M]
- [ ] Mercader activo al guardar: al cargar sigue presente el mismo día [M]
- [ ] Guardado a mitad de día: stock y mercaderes se restauran exactos [M]
- [ ] Feria + día laborable: etapa de eventos y restock conviven sin pisarse [C]
- [ ] Stock máx configurado en 0: advertencia DOM-TIEN-CONFIG y ítem ausente [S]
- [ ] Precio devuelto por M38 en 0 (no debería pasar): clamp defensivo >= 1 [S]
- [ ] Tienda sin dueño o catálogo nulo: error de validación en editor antes de runtime [M]

## R. Optimización

- [ ] stock_actual en Dictionary{item_id: int} con consultas O(1) [M]
- [ ] esta_abierta como cálculo aritmético puro sin alocaciones [S]
- [ ] Canalización solo en eventos de cambio de día/estación/evento, jamás por frame [M]
- [ ] Transacciones sin instanciación de nodos (diccionarios + llamadas M38/M14) [M]
- [ ] Catálogos .tres precargados en _ready() del ShopManager [S]
- [ ] Registro de tiendas con acceso O(1) por shop_id [S]
- [ ] listar_stock ordenado sin copias innecesarias (copia de solo lectura) [S]
- [ ] Evitar strings concatenados en hot paths (usar StringName en ids) [M]
- [ ] Prueba de rendimiento: 1000 transacciones simuladas sin picos de frame [M]
- [ ] Sin lecturas de disco en runtime: todo precargado [S]

## S. Documentación entregada

- [ ] Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF18 [M]
- [ ] Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M]
- [ ] Crear 03-Diseno.md con arquitectura, flujos, clases y balance [M]
- [ ] Crear 04-Codigo.md con rutas previstas res://tiendas/... y firmas GDScript [M]
- [ ] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S]
- [ ] Crear 05-Checklist.md con los 181 ítems completados y marcadores de esfuerzo [M]
- [ ] Firmar todos los archivos con modelo y plataforma [S]
- [ ] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S]
- [ ] Recomendar 06-Plan-Testings y 07-Resultados-Testings para la fase de implementación [S]

## T. Testings

- [ ] Definir prueba de compra normal: monedas, stock e ítems consistentes [M]
- [ ] Definir prueba de venta normal: recompra, monedas y acumulación en tienda [M]
- [ ] Definir prueba de determinismo: misma semilla → mismo stock y mismos mercaderes [C]
- [ ] Definir prueba de horarios: bordes de hora, descansos y ítem cerrado [M]
- [ ] Definir prueba de restock idempotente: doble señal del mismo día [M]
- [ ] Definir prueba de atomicidad: fallo de M14 revierte stock y monedas [C]
- [ ] Definir prueba de mercader: aparición en feria, días fijos y probabilidad PRNG [M]
- [ ] Definir prueba de persistencia: guardar/cargar con stock y mercaderes exactos [M]
- [ ] Definir prueba de rotación estacional: semillas fuera de temporada ausentes [M]
- [ ] Definir prueba de edge cases: cero fondos, inventario lleno, cantidad inválida [M]
- [ ] Definir prueba de integración con M38: precios idénticos en tienda y mercado [M]
- [ ] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]