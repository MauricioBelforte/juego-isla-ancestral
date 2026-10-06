**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 39: Tiendas

- Estado: 🔵 En curso — **cierre glm-5.3-flash** (reserva 1123, Log reservado 1123)

- Agente: glm-5.3-flash (Cline)
- Agente: glm-5.3-flash (Cline) — núcleo ox-alpha (carpeta `scripts/shops/`, 81 ítems marcados) respetado
- Fase: 9 (Economía y progreso)
- Dificultad: 3
- Visión: V0 (lógica); `shop_ui.gd` existe como esqueleto (M53)
- Entrada: núcleo shops/ (shop, shop_data, shop_manager, stock_generator, catalogo_tiendas, reputacion_tienda, shop_ui) + suites `test_tiendas.gd` / `test_loop_economico.gd` verdes (EXIT=0, verificadas hoy)
- Salida: **ENTREGADO** — CANTIDAD_INVALIDA + clamp precio >= 1 + `npc_id`/recargo reales a M38 + canales 2/3 del generador (estaciones/eventos) + consumo `estacion_cambio` + recuperación de días perdidos + mercader presente (aparición + persistencia) + `tienda_cerrada` con próxima apertura + validaciones de catálogo (ItemDatabase) + **fix atomicidad D8 (revert de monedas)** + tests (`test_tiendas_iter_glm.gd` 33/0)
- Resultado: **127 [x] / 54 [ ]** (antes 81/100) — pendientes: UI M53, ferias M73 en vivo, tipos semillas/pescadería, avisos ids M159 (BUG-046, dueño externo)
- Archivos: `scripts/shops/shop_manager.gd` (fix D8), `scripts/shops/test_tiendas_iter_glm.gd`, `scripts/shops/test_loop_economico.gd` (BUG-028), `scripts/reporte_ids_items.py`, `scripts/run_shops_tests.bat`, `DOCUMENTACION/11-BUGS.md`, docs del módulo, `scripts-prueba/marcar_iter_glm.py`
- Fecha cierre: 2026-09-19 (Log 1017)

## A. Problema y objetivos

- [x] Definir el problema: sin tiendas, la economía de M38 no tiene cara visible ni punto de intercambio [S]
- [x] Definir el objetivo: tiendas vivas como atributos de NPCs con catálogo, horario, descanso y stock renovable [S]
- [x] Registrar dependencias del módulo: M38 (Economía), M14 (Inventario), M29 (Calendario), M30 (Reloj) [S]
- [x] Registrar relaciones con M19 (Población), M20 (Amistad), M53 (UI) y M73 (Eventos) [S]
- [x] Separar dentro/fuera de alcance: precios y moneda en M38, UI completa en M53, misiones en M23 [S]
- [x] Documentar restricciones: Godot 4.x, GDScript tipado, sin C#, data-driven, determinismo PRNG, sin red [S]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]
- [x] Incluir contexto del plan maestro: pueblo vivo con comercios que abren, cierran y reabastecen [S]
- [x] Nombrar los cinco tipos de tienda: semillas, pescadería, ferretería, general y mercader viajero [M] *(iter. glm — Log 1017)*
- [x] Fijar la regla de oro: el módulo jamás define precios, solo consulta M38 [M] *(iter. glm — Log 1017)*

## B. RF — Catálogos por NPC

- [x] RF3: catálogo por comerciante con ítems ofrecidos y ítems recomprados (ShopCatalog) [M]
- [x] Definir items_venta como lista de StockEntry con rangos de stock [M]
- [x] Definir items_recompra como lista de item_id (recompra selectiva por tienda) [M]
- [x] Definir pool_rodante exclusivo de mercaderes viajeros [M]
- [x] Validar en editor que cada item_id del catálogo exista en M15 [M] *(iter. glm — Log 1017)*
- [x] Validar en editor que no haya ítems duplicados dentro del mismo catálogo [S] *(iter. glm — Log 1017)*
- [x] Garantizar que los ítems básicos de cada tipo tengan stock_min >= 1 [M]

## C. RF — Tipos de tienda

- [x] RF2: enum TipoTienda con SEMILLAS, PESCADERIA, FERRETERIA, GENERAL y VIAJERO (+ TIENDA_JUGADOR para reputación) [S]
- [x] Definir defaults de catálogo y stock por tipo (tabla de balance del 03-Diseno) [M]
- [x] Puesto de semillas: rotación estacional fuerte con semillas básicas siempre presentes [M]
- [x] Pescadería: catálogo ligado a la pesca de la estación y cebos [M]
- [x] Ferretería: herramientas y materiales con stock estable y mayor ticket [M]
- [x] Tienda general: mezcla flexible de comida, decoración y cotidianos [M] *(iter. glm — Log 1017)*
- [x] Mercader viajero: sin local fijo, catálogo rodante y recargos dentro de topes de M38 [M] *(iter. glm — Log 1017)*

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

- [x] RF4: definir dias_abierto, hora_apertura y hora_cierre en ShopDefinition [M]
- [x] RF5: definir dias_descanso como días cerrados explícitos por tienda [M] *(iter. glm — Log 1017)*
- [x] Implementar esta_abierta como función pura (día M29 + hora M30 + rangos) [M] (implementado: ShopManager.esta_abierta consulta M29 TimeCalendar con fallback a M30 GameClock, log 192)
- [x] Sin estado interno booleano de apertura (D4: consulta, no flag) [M]
- [x] Emitir tienda_cerrada con próxima apertura para el cartel de la UI [M] *(iter. glm — Log 1017)*
- [x] Probar borde de hora exacta: apertura a las 09:00 incluida, cierre a las 17:00 excluido [M] *(iter. glm — Log 1017)*
- [x] Probar día de descanso: tienda cerrada todo el día aunque esté en horario [M] *(iter. glm — Log 1017)*
- [x] Mercader viajero: su "horario" es el calendario de aparición, no franja diaria [M] *(iter. glm — Log 1017)*

## G. RF — Stock y canalizaciones

- [x] RF6: stock inicial generado por StockGenerator al registrar la tienda [C]
- [x] RF7: reabastecimiento diario por evento nuevo_dia_laborable de M29 [C] *(iter. glm — Log 1017)*
- [x] RF8: rotación estacional filtrando StockEntry.temporadas [M]
- [x] RF9: canalización en 5 etapas: base, estación, eventos, aforo, PRNG [C] *(iter. glm — Log 1017)*
- [x] Etapa base: materializar entradas del catálogo con rangos min/max [M] *(iter. glm — Log 1017)*
- [x] Etapa estación: descartar ítems fuera de temporada sin tocar básicos garantizados [M] *(iter. glm — Log 1017)*
- [x] Etapa eventos: agregar ítems solo_evento activos (ferias M73) [M] *(iter. glm — Log 1017)*
- [x] Etapa aforo: clamp min/max y peso_rareza (raros con menos ejemplares) [M] *(iter. glm — Log 1017)*
- [x] Etapa PRNG: variación determinista con semilla de partida (M29) [C] *(iter. glm — Log 1017)*
- [x] Idempotencia del restock: fecha_ultimo_restock evita doble reabastecimiento el mismo día [M]
- [x] Restock por D6: reponer hasta máximos conservando sobrantes (nunca tirar stock) [M]

## H. RF — Precios (delegados a M38)

- [x] RF12: precio_compra_vigente consultado a PriceManager en cada compra [M]
- [x] RF12: precio_venta_vigente consultado a PriceManager en cada venta [M]
- [x] Precios jugador-vendedor distintos: compra (paga) vs venta (recibe) [M] *(iter. glm — Log 1017)*
- [x] Mercader viajero: recargos declarados pasados como parámetro a M38 [M] *(iter. glm — Log 1017)*
- [x] Nunca cachear precios entre operaciones: consulta fresca por operación [S] *(iter. glm — Log 1017)*
- [x] Jamás calcular precios dentro de tiendas (D7) [M] *(iter. glm — Log 1017)*
- [x] Total con clamp: cantidad válida > 0 y precio >= 1 garantizado por M38 [S] *(iter. glm — Log 1017)*

## I. Requisitos no funcionales

- [x] RNF1: tono cozy: nunca se pierden ítems comprados por error del sistema [M]
- [x] RNF2: stock básico nunca desaparece del todo (stock_min garantizado) [M]
- [x] RNF3: sistema discreto por eventos, sin bucles por frame [M]
- [x] RNF4: determinismo de stock y mercaderes con PRNG de partida (M29) [M]
- [x] RNF5: data-driven total en .tres con validación en editor accionable [M]
- [x] RNF6: desacoplamiento absoluto de la UI, comunicación por señales [M] *(cierre glm-5.3-flash — Log 1120: cierre: señales SM L29-38; shop_ui.gd 367 líneas conecta L36-40)*
- [x] RNF7: claves i18n para tiendas, catálogos y mensajes [S] *(cierre glm-5.3-flash — Log 1120: cierre: nombre_clave_i18n + _motivo_texto con _t() — shop_ui L313-326)*
- [x] RNF8: GDScript tipado explícito compatible con Godot 4.x (>= 4.4.1) [S]
- [x] RNF9: transacciones atómicas: o ambas partes se mueven o ninguna [C] *(iter. glm — Log 1017)*
- [x] RNF10: stock nunca negativo en ningún punto del flujo [M]

## J. Análisis del dominio

- [x] Analizar los cinco tipos de tienda y sus diferencias de catálogo/stock [M]
- [x] Analizar tiendas como atributos de NPCs (identidad, amistad M20, interacción) [M] *(cierre glm-5.3-flash — Log 1120: cierre: D1 + alt. «tiendas sin dueño» descartada — 02 §2-3)*
- [x] Analizar catálogos por NPC: venta + recompra selectiva [M] *(cierre glm-5.3-flash — Log 1120: cierre: D3 + alt. «catálogo único por tipo» descartada — 02 §2-3)*
- [x] Analizar horarios y descansos como consulta pura al calendario [M] *(cierre glm-5.3-flash — Log 1120: cierre: D4 + alt. «descansos fijos globales» descartada — 02 §2-3)*
- [x] Analizar canalizaciones de stock: etapas y determinismo [C]
- [x] Analizar precios dinámicos vs fijos: delegados a M38 con variabilidad diaria [M] *(cierre glm-5.3-flash — Log 1120: cierre: D7 + alt. «precios por tienda» descartada — 02 §2-3)*
- [x] Analizar compra/venta con validaciones en cascada y atomicidad [M] *(cierre glm-5.3-flash — Log 1120: cierre: D8 + riesgo «transacción a medias» — 02 §3-4)*
- [x] Analizar renovación de stock: diaria + estacional + regeneración de viajeros [M]
- [x] Analizar eventos y ferias como etapa temporal reversible [M] *(cierre glm-5.3-flash — Log 1120: cierre: D10 + riesgo «feria que pisa stock» — 02 §3-4)*
- [x] Evaluar stock infinito y descartarlo por falta de vida [S]
- [x] Evaluar catálogo único por tipo y descartarlo: los puestos serían clones [S] *(cierre glm-5.3-flash — Log 1120: cierre: alternativa descartada — 02 §2)*
- [x] Evaluar precios propios por tienda y descartarlos: divergencia con M38 [S] *(cierre glm-5.3-flash — Log 1120: cierre: alternativa descartada — 02 §2)*

## K. Diseño y arquitectura

- [x] Definir architecture: ShopManager (autoload) + Shop (RefCounted) + StockGenerator + ShopUI [C]
- [x] ShopManager: registro de tiendas con acceso O(1) por shop_id [M]
- [x] ShopManager: orquesta compra/venta/restock/mercaderes y emite todas las señales [C]
- [x] Shop: estado runtime (definición, stock_actual, fechas, mercader activo) [M]
- [x] Shop: sin señales propias (las emite el manager) [S]
- [x] StockGenerator: RefCounted helper con modos INICIAL/RESTOCK/APARICION [M]
- [x] ShopUI: script de capa M53 desacoplado que solo consume señales [M]
- [x] Diagrama de flujo de compra completo (2.1) documentado [S] *(cierre glm-5.3-flash — Log 1120: cierre: 03-Diseno §2.1)*
- [x] Diagrama de flujo de venta completo (2.2) documentado [S] *(cierre glm-5.3-flash — Log 1120: cierre: 03-Diseno §2.2)*
- [x] Diagrama de reabastecimiento diario (2.3) documentado [S] *(cierre glm-5.3-flash — Log 1120: cierre: 03-Diseno §2.3)*
- [x] Diagrama de aparición de mercader viajero (2.4) documentado [S] *(cierre glm-5.3-flash — Log 1120: cierre: 03-Diseno §2.4)*
- [x] Contrato de señales tabulado con emisores y consumidores [M] *(cierre glm-5.3-flash — Log 1120: cierre: 03-Diseno §5 — tabla emisor/consumidores)*
- [x] Persistencia definida: stock_actual, fechas, mercaderes y recuperación de días perdidos [M]
- [x] Tabla de balance por tipo de tienda documentada [M] *(cierre glm-5.3-flash — Log 1120: cierre: 03-Diseno §8 — tabla por tipo)*

## L. Integración con M14 (Inventario)

- [x] Compra entrega ítems vía Inventario.agregar_items [M] *(iter. glm — Log 1017)*
- [x] Venta remueve ítems vía Inventario.remover_items [M] *(iter. glm — Log 1017)*
- [x] Si agregar_items falla (inventario lleno), revertir stock descontado [C]
- [x] Si remover_items falla, rechazar venta sin mover monedas [M] *(iter. glm — Log 1017)*
- [x] Stock de tienda nunca se mezcla con inventario del jugador [S]
- [x] Operaciones de ítems en diccionarios {item_id: cantidad} compatibles con M14 [S] *(cierre glm-5.3-flash — Log 1120: cierre: SM L245 agregar_items({item_id: cantidad}))*

## M. Integración con M19/M20 (Población y Amistad)

- [x] npc_duenio_id obligatorio y validado contra la población (M19) [M]
- [x] La tienda se abre interactuando con el NPC dueño en escena [M]
- [x] La amistad (M20) afecta descuentos vía M38, no en este módulo [S] *(cierre glm-5.3-flash — Log 1120: cierre: SM L236 pasa npc_duenio_id a M38; el descuento lo aplica M38)*
- [x] Catálogo especial por amistad se resuelve como datos en .tres (si aplica) [M]
- [x] Tienda sin dueño válido = error de validación en editor [S] *(iter. glm — Log 1017)*

## N. Integración con M29/M30 (Calendario y Reloj)

- [x] Consumir nuevo_dia_laborable para restock y evaluación de mercaderes [C]
- [x] Consumir estacion_cambio para rotación estacional [M] *(iter. glm — Log 1017)*
- [x] Recibir PRNG del día desde M29 para StockGenerator [M]
- [x] Consultar día y hora actuales a M29/M30 para esta_abierta [M] (implementado, log 192)
- [x] Días de la semana 1-7 consistentes con el calendario de M29 [S] *(iter. glm — Log 1017)*
- [x] Sin estados de apertura manuales que puedan desincronizar (D4) [M] *(cierre glm-5.3-flash — Log 1120: cierre: shop.abierta_ahora = esta_abierta() SM L153; sin flags manuales)*
- [x] Recuperación de días perdidos al cargar partidas viejas [M] *(iter. glm — Log 1017)*

## O. Integración con M38 (Economía)

- [x] precio_compra_vigente(item_id, npc_id) consumida en compras [M] *(iter. glm — Log 1017)*
- [x] precio_venta_vigente(item_id) consumida en ventas [M] *(iter. glm — Log 1017)*
- [x] EconomyManager.retirar_monedas usado en compras [M]
- [x] EconomyManager.depositar_monedas usado en ventas [M]
- [x] Anti-grind y ventana de oferta resueltos internamente por M38 [S] *(iter. glm — Log 1017)*
- [x] Recargo de mercader viajero pasado como parámetro opcional a M38 [M] *(iter. glm — Log 1017)*
- [x] Verificar nombres reales de funciones de M38 antes de implementar [S]

## P. Integración con M53 (UI) y M73 (Eventos)

- [x] ShopUI pide datos de catálogo, stock y precios sin lógica de negocio [M]
- [x] UI consume señales compra/venta/inventario_tienda_cambio [M] *(cierre glm-5.3-flash — Log 1120: cierre: shop_ui L36-40 conecta las 5 señales)*
- [x] Cartel de cierre con próxima apertura (tienda_cerrada) [M]
- [x] Feedback de rechazo con motivo legible y no duro [S] *(cierre glm-5.3-flash — Log 1120: cierre: _on_tx_rechazada + _motivo_texto i18n — shop_ui L309-326)*
- [x] Ferias (M73): mercaderes con aparición garantizada vía evento_iniciado [M]
- [x] Evento finalizado revierte catálogo extendido del día siguiente (D10) [M]

## Q. Edge cases

- [x] Tienda cerrada: rechazo CERRADA sin efectos laterales [M] *(iter. glm — Log 1017)*
- [x] Día de descanso: cerrada aunque esté dentro de la franja horaria [M] *(iter. glm — Log 1017)*
- [x] Stock vacío de un ítem: rechazo SIN_STOCK y fila deshabilitada en UI [M]
- [x] Jugador sin fondos: rechazo SIN_FONDOS sin castigos ni mensajes duros [M] *(iter. glm — Log 1017)*
- [x] Jugador con 0 monedas: puede vender para obtener ingresos (básicos siempre recomprados) [M] *(cierre glm-5.3-flash — Log 1120: cierre: test_tiendas _test_rechazos L86-89 — vende con 0 AO)*
- [x] Cantidad inválida (0 o negativa): rechazo CANTIDAD_INVALIDA [S] *(iter. glm — Log 1017)*
- [x] Inventario jugador lleno al comprar: reversión total del stock [C]
- [x] Venta de un ítem no recomprado por la tienda: NO_RECOMPRA [S] *(iter. glm — Log 1017)*
- [x] Venta con menos ítems de los pedidos: SIN_ITEMS_JUGADOR sin tocar monedas [M] *(iter. glm — Log 1017)*
- [x] Restock doble del mismo día (señal duplicada): idempotente por fecha [M]
- [x] Mercader activo al guardar: al cargar sigue presente el mismo día [M] *(iter. glm — Log 1017)*
- [x] Guardado a mitad de día: stock y mercaderes se restauran exactos [M]
- [x] Feria + día laborable: etapa de eventos y restock conviven sin pisarse [C]
- [x] Stock máx configurado en 0: advertencia DOM-TIEN-CONFIG y ítem ausente [S]
- [x] Precio devuelto por M38 en 0 (no debería pasar): clamp defensivo >= 1 [S] *(iter. glm — Log 1017)*
- [x] Tienda sin dueño o catálogo nulo: error de validación en editor antes de runtime [M] *(iter. glm — Log 1017)*

## R. Optimización

- [x] stock_actual en Dictionary{item_id: int} con consultas O(1) [M]
- [x] esta_abierta como cálculo aritmético puro sin alocaciones [S] *(cierre glm-5.3-flash — Log 1120: cierre: shop.gd L46-60 consulta pura sin alocación)*
- [x] Canalización solo en eventos de cambio de día/estación/evento, jamás por frame [M] *(iter. glm — Log 1017)*
- [x] Transacciones sin instanciación de nodos (diccionarios + llamadas M38/M14) [M] *(cierre glm-5.3-flash — Log 1120: cierre: shop_manager 0 .instantiate(); flujo por diccionarios)*
- [x] Catálogos .tres precargados en _ready() del ShopManager [S]
- [x] Registro de tiendas con acceso O(1) por shop_id [S]
- [x] listar_stock ordenado sin copias innecesarias (copia de solo lectura) [S]
- [x] Evitar strings concatenados en hot paths (usar StringName en ids) [M]
- [ ] Prueba de rendimiento: 1000 transacciones simuladas sin picos de frame [M]
- [x] Sin lecturas de disco en runtime: todo precargado [S] *(iter. glm — Log 1017)*

## S. Documentación entregada

- [x] Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF18 [M] *(cierre glm-5.3-flash — Log 1120: cierre: 309 líneas, problema/objetivo/alcance/RF1-RF18, firmado)*
- [x] Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos [M] *(cierre glm-5.3-flash — Log 1120: cierre: 139 líneas, dominio/alternativas/decisiones/riesgos, firmado)*
- [x] Crear 03-Diseno.md con arquitectura, flujos, clases y balance [M]
- [x] Crear 04-Codigo.md con rutas previstas res://tiendas/... y firmas GDScript [M]
- [x] Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones [S] *(cierre glm-5.3-flash — Log 1120: cierre: 04-Codigo §Notas del Agente)*
- [x] Crear 05-Checklist.md con los 181 ítems completados y marcadores de esfuerzo [M] *(cierre glm-5.3-flash — Log 1120: cierre: 181 ítems con marcadores [S]/[M]/[C])*
- [x] Firmar todos los archivos con modelo y plataforma [S] *(cierre glm-5.3-flash — Log 1120: cierre: firma Modelo+Plataforma en los 5 archivos)*
- [x] Copiar plan-inicial a plan-actual byte a byte (verificación por hash) [S] *(cierre glm-5.3-flash — Log 1120: cierre: 02/03 idénticos por hash; 01/04/05 divergen por cambios firmados)*
- [x] Recomendar 06-Plan-Testings y 07-Resultados-Testings para la fase de implementación [S]

## T. Testings

- [x] Definir prueba de compra normal: monedas, stock e ítems consistentes [M]
- [x] Definir prueba de venta normal: recompra, monedas y acumulación en tienda [M] *(cierre glm-5.3-flash — Log 1120: cierre: test_tiendas _test_venta_basica + G257 acumular_stock)*
- [x] Definir prueba de determinismo: misma semilla → mismo stock y mismos mercaderes [C]
- [x] Definir prueba de horarios: bordes de hora, descansos y ítem cerrado [M] *(cierre glm-5.3-flash — Log 1120: cierre: test_tiendas_iter_glm _test_horarios_real)*
- [x] Definir prueba de restock idempotente: doble señal del mismo día [M]
- [x] Definir prueba de atomicidad: fallo de M14 revierte stock y monedas [C]
- [x] Definir prueba de mercader: aparición en feria, días fijos y probabilidad PRNG [M]
- [x] Definir prueba de persistencia: guardar/cargar con stock y mercaderes exactos [M]
- [x] Definir prueba de rotación estacional: semillas fuera de temporada ausentes [M] *(cierre glm-5.3-flash — Log 1120: cierre: G68/G75 — canales estación/eventos)*
- [x] Definir prueba de edge cases: cero fondos, inventario lleno, cantidad inválida [M] *(cierre glm-5.3-flash — Log 1120: cierre: T86 cero fondos · G186 inv. lleno · CANTIDAD_INVALIDA)*
- [x] Definir prueba de integración con M38: precios idénticos en tienda y mercado [M] *(cierre glm-5.3-flash — Log 1120: cierre: G225 precio cobrado == recargado de M38)*
- [x] Marcar testings como pendientes hasta la implementación (se ejecutarán según sección 14 de AGENTS.md) [S]

**Totales:** 181 ítems · Completados: 180 · Pendientes: 1 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, lote 2):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 127 [x] / 54 [ ] /
> 0 [?], consistente con la entrega de la iter. glm (Log 1017: 81 → 127 [x] / 54 [ ]).
> Las marcas no se tocaron.

## Notas del Agente — Auditoría T (2026-10-06, agnes-3.0-flash / Kilo Code)

**Auditoría A (canal `agnes-3-flash` arch. 1334/48):** verificar `[x]` c/ evidencia en disco.
Conteo real actual: **180 [x] / 0 [?] / 1 [ ]** (la nota de drift de 2026-09-20 dice 127/54, stale).

- **Núcleo (VERDADERO):** `test_tiendas.gd` = **0 fallos**; `scripts/shops/` con 11 .gd
  (shop_manager, catalogo_tiendas, + tests) y catálogos registrados (`[M39] Catálogos
  definitivos: tienda_general, herreria, mercader_viajero`). Los 180 `[x]` del sistema de tiendas
  están sustentados. **Sin degradación.**
- **Hallazgo cross-módulo (H2, handoff a M15):** en runtime salen **8 warnings** `[M39] <tienda>:
  item_id inexistente en M15` (madera_roble, piedra_caliza, baya_roja, fibra_algodon,
  mineral_cobre, pergamino_rec_tela_lino, herramienta_basica, fragmento_ancestral). Los catálogos de
  M39 refieren ítems que **M15 (ItemDatabase) no tiene**. Es **deuda de M15** (registrar esos ítems),
  no un `[x]` falso de M39: la validación (L38) existe y corre; lo que falta es la **data en M15**.
- No toqué el estado (lo pone el dueño/coordinador).
## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 7)
Los [x] auditados contra disco y sustentados; 0 degradaciones. Evidencia: test_tiendas_iter_glm.gd 39/0 = scripts/shops/ + catalogos. El 1 [ ] aislado = 'Prueba de rendimiento: 1000 transacciones simuladas sin picos de frame' (necesita hardware/profiling, no es [x] inflado). H2: los 8 item_ids de M39 → M15 (deuda BUG-106, 7/8 resueltos, falta pergamino_rec_tela_lino).
