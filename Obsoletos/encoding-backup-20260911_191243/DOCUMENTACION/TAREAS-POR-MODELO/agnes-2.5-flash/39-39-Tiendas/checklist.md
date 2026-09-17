# Tareas módulo 39 39-Tiendas

**Estado:** ðŸŸ¡ Con dudas

**Items pendientes:** 100

[ ] T-39-001: Definir el problema: sin tiendas, la economía de M38 no tiene cara visible ni punto de intercambio
[ ] T-39-002: Registrar dependencias del módulo: M38 (Economía), M14 (Inventario), M29 (Calendario), M30 (Reloj)
[ ] T-39-003: Registrar relaciones con M19 (Población), M20 (Amistad), M53 (UI) y M73 (Eventos)
[ ] T-39-004: Separar dentro/fuera de alcance: precios y moneda en M38, UI completa en M53, misiones en M23
[ ] T-39-005: Definir criterios de aceptación verificables (8 criterios)
[ ] T-39-006: Incluir contexto del plan maestro: pueblo vivo con comercios que abren, cierran y reabastecen
[ ] T-39-007: Nombrar los cinco tipos de tienda: semillas, pescadería, ferretería, general y mercader viajero
[ ] T-39-008: Fijar la regla de oro: el módulo jamás define precios, solo consulta M38
[ ] T-39-009: Definir pool_rodante exclusivo de mercaderes viajeros
[ ] T-39-010: Validar en editor que cada item_id del catálogo exista en M15
[ ] T-39-011: Validar en editor que no haya ítems duplicados dentro del mismo catálogo
[ ] T-39-012: Puesto de semillas: rotación estacional fuerte con semillas básicas siempre presentes
[ ] T-39-013: Pescadería: catálogo ligado a la pesca de la estación y cebos
[ ] T-39-014: Tienda general: mezcla flexible de comida, decoración y cotidianos
[ ] T-39-015: Mercader viajero: sin local fijo, catálogo rodante y recargos dentro de topes de M38
[ ] T-39-016: RF5: definir dias_descanso como días cerrados explícitos por tienda
[ ] T-39-017: Sin estado interno booleano de apertura (D4: consulta, no flag)
[ ] T-39-018: Emitir tienda_cerrada con próxima apertura para el cartel de la UI
[ ] T-39-019: Probar borde de hora exacta: apertura a las 09:00 incluida, cierre a las 17:00 excluido
[ ] T-39-020: Probar día de descanso: tienda cerrada todo el día aunque esté en horario
[ ] T-39-021: Mercader viajero: su "horario" es el calendario de aparición, no franja diaria
[ ] T-39-022: RF7: reabastecimiento diario por evento nuevo_dia_laborable de M29
[ ] T-39-023: RF9: canalización en 5 etapas: base, estación, eventos, aforo, PRNG
[ ] T-39-024: Etapa base: materializar entradas del catálogo con rangos min/max
[ ] T-39-025: Etapa estación: descartar ítems fuera de temporada sin tocar básicos garantizados
[ ] T-39-026: Etapa eventos: agregar ítems solo_evento activos (ferias M73)
[ ] T-39-027: Etapa aforo: clamp min/max y peso_rareza (raros con menos ejemplares)
[ ] T-39-028: Etapa PRNG: variación determinista con semilla de partida (M29)
[ ] T-39-029: Precios jugador-vendedor distintos: compra (paga) vs venta (recibe)
[ ] T-39-030: Mercader viajero: recargos declarados pasados como parámetro a M38
[ ] T-39-031: Nunca cachear precios entre operaciones: consulta fresca por operación
[ ] T-39-032: Jamás calcular precios dentro de tiendas (D7)
[ ] T-39-033: Total con clamp: cantidad válida > 0 y precio >= 1 garantizado por M38
[ ] T-39-034: RNF6: desacoplamiento absoluto de la UI, comunicación por señales
[ ] T-39-035: RNF7: claves i18n para tiendas, catálogos y mensajes
[ ] T-39-036: RNF9: transacciones atómicas: o ambas partes se mueven o ninguna
[ ] T-39-037: Analizar tiendas como atributos de NPCs (identidad, amistad M20, interacción)
[ ] T-39-038: Analizar catálogos por NPC: venta + recompra selectiva
[ ] T-39-039: Analizar horarios y descansos como consulta pura al calendario
[ ] T-39-040: Analizar precios dinámicos vs fijos: delegados a M38 con variabilidad diaria
[ ] T-39-041: Analizar compra/venta con validaciones en cascada y atomicidad
[ ] T-39-042: Analizar eventos y ferias como etapa temporal reversible
[ ] T-39-043: Evaluar catálogo único por tipo y descartarlo: los puestos serían clones
[ ] T-39-044: Evaluar precios propios por tienda y descartarlos: divergencia con M38
[ ] T-39-045: Diagrama de flujo de compra completo (2.1) documentado
[ ] T-39-046: Diagrama de flujo de venta completo (2.2) documentado
[ ] T-39-047: Diagrama de reabastecimiento diario (2.3) documentado
[ ] T-39-048: Diagrama de aparición de mercader viajero (2.4) documentado
[ ] T-39-049: Contrato de señales tabulado con emisores y consumidores
[ ] T-39-050: Tabla de balance por tipo de tienda documentada
[ ] T-39-051: Compra entrega ítems vía Inventario.agregar_items
[ ] T-39-052: Venta remueve ítems vía Inventario.remover_items
[ ] T-39-053: Si remover_items falla, rechazar venta sin mover monedas
[ ] T-39-054: Operaciones de ítems en diccionarios {item_id: cantidad} compatibles con M14
[ ] T-39-055: npc_duenio_id obligatorio y validado contra la población (M19)
[ ] T-39-056: La tienda se abre interactuando con el NPC dueño en escena
[ ] T-39-057: La amistad (M20) afecta descuentos vía M38, no en este módulo
[ ] T-39-058: Catálogo especial por amistad se resuelve como datos en .tres (si aplica)
[ ] T-39-059: Tienda sin dueño válido = error de validación en editor
[ ] T-39-060: Consumir estacion_cambio para rotación estacional
[ ] T-39-061: Días de la semana 1-7 consistentes con el calendario de M29
[ ] T-39-062: Sin estados de apertura manuales que puedan desincronizar (D4)
[ ] T-39-063: Recuperación de días perdidos al cargar partidas viejas
[ ] T-39-064: precio_compra_vigente(item_id, npc_id) consumida en compras
[ ] T-39-065: precio_venta_vigente(item_id) consumida en ventas
[ ] T-39-066: Anti-grind y ventana de oferta resueltos internamente por M38
[ ] T-39-067: Recargo de mercader viajero pasado como parámetro opcional a M38
[ ] T-39-068: UI consume señales compra/venta/inventario_tienda_cambio
[ ] T-39-069: Cartel de cierre con próxima apertura (tienda_cerrada)
[ ] T-39-070: Feedback de rechazo con motivo legible y no duro
[ ] T-39-071: Ferias (M73): mercaderes con aparición garantizada vía evento_iniciado
[ ] T-39-072: Evento finalizado revierte catálogo extendido del día siguiente (D10)
[ ] T-39-073: Tienda cerrada: rechazo CERRADA sin efectos laterales
[ ] T-39-074: Día de descanso: cerrada aunque esté dentro de la franja horaria
[ ] T-39-075: Jugador sin fondos: rechazo SIN_FONDOS sin castigos ni mensajes duros
[ ] T-39-076: Jugador con 0 monedas: puede vender para obtener ingresos (básicos siempre recomprados)
[ ] T-39-077: Cantidad inválida (0 o negativa): rechazo CANTIDAD_INVALIDA
[ ] T-39-078: Venta de un ítem no recomprado por la tienda: NO_RECOMPRA
[ ] T-39-079: Venta con menos ítems de los pedidos: SIN_ITEMS_JUGADOR sin tocar monedas
[ ] T-39-080: Mercader activo al guardar: al cargar sigue presente el mismo día
[ ] T-39-081: Precio devuelto por M38 en 0 (no debería pasar): clamp defensivo >= 1
[ ] T-39-082: Tienda sin dueño o catálogo nulo: error de validación en editor antes de runtime
[ ] T-39-083: esta_abierta como cálculo aritmético puro sin alocaciones
[ ] T-39-084: Canalización solo en eventos de cambio de día/estación/evento, jamás por frame
[ ] T-39-085: Transacciones sin instanciación de nodos (diccionarios + llamadas M38/M14)
[ ] T-39-086: Evitar strings concatenados en hot paths (usar StringName en ids)
[ ] T-39-087: Prueba de rendimiento: 1000 transacciones simuladas sin picos de frame
[ ] T-39-088: Sin lecturas de disco en runtime: todo precargado
[ ] T-39-089: Crear 01-Requerimientos.md con problema, objetivo, alcance y RF1-RF18
[ ] T-39-090: Crear 02-Analisis.md con dominio, alternativas, decisiones y riesgos
[ ] T-39-091: Incluir Notas del Agente en 04-Codigo.md con honestidad y recomendaciones
[ ] T-39-092: Crear 05-Checklist.md con los 181 ítems completados y marcadores de esfuerzo
[ ] T-39-093: Firmar todos los archivos con modelo y plataforma
[ ] T-39-094: Copiar plan-inicial a plan-actual byte a byte (verificación por hash)
[ ] T-39-095: Definir prueba de venta normal: recompra, monedas y acumulación en tienda
[ ] T-39-096: Definir prueba de horarios: bordes de hora, descansos y ítem cerrado
[ ] T-39-097: Definir prueba de mercader: aparición en feria, días fijos y probabilidad PRNG
[ ] T-39-098: Definir prueba de rotación estacional: semillas fuera de temporada ausentes
[ ] T-39-099: Definir prueba de edge cases: cero fondos, inventario lleno, cantidad inválida
[ ] T-39-100: Definir prueba de integración con M38: precios idénticos en tienda y mercado
