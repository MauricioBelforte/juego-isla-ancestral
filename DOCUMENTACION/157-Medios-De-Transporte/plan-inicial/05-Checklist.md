**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 05-Checklist.md — Modulo 157: Medios de Transporte

> Marcadores: [S] simple · [M] medio · [C] complejo.

---

## A. Requisitos Funcionales (10 items)

- [ ] RF-01: TransportManager como singleton orquestador central [C]
- [ ] RF-01: Registro y desregistro de transportes en tiempo de ejecución [M]
- [ ] RF-01: Consulta de disponibilidad según posición y estado del mundo [M]
- [ ] RF-01: Escalado de prioridad según distancia y tipo de terreno [S]
- [ ] RF-02: JourneyInstance con datos del viaje (origen, destino, duración, eventos) [C]
- [ ] RF-02: Persistencia de instancia durante todo el viaje [M]
- [ ] RF-02: Cancelación de viaje con penalización [M]
- [ ] RF-03: Tabla de eventos aleatorios por tipo de transporte [C]
- [ ] RF-03: Eventos en intervalos aleatorios con cooldown [M]
- [ ] RF-04: 5 tipos de transporte diferenciados (Barco, Tren, Avión, Carreta, A pie) [C]

## B. TransportManager (12 items)

- [ ] B-01: Crear TransportManager.gd como autoload en project.godot [C]
- [ ] B-02: Implementar diccionario de transportes registrados [M]
- [ ] B-03: Método register_transport() para agregar nuevos transportes [M]
- [ ] B-04: Método unregister_transport() para remover transportes [S]
- [ ] B-05: Método get_available_transports() filtrando por posición [M]
- [ ] B-06: Método start_journey() que crea JourneyInstance [C]
- [ ] B-07: Método cancel_journey() que elimina instancia activa [M]
- [ ] B-08: Verificación de costos antes de iniciar viaje [M]
- [ ] B-09: Integración con EconomyManager para deducción de costos [M]
- [ ] B-10: Pool de eventos por tipo de transporte [C]
- [ ] B-11: Gestión de viajes activos (máximo 1 por jugador) [S]
- [ ] B-12: Sistema de logging para debugging de viajes [S]

## C. Tipos de Transporte (15 items)

- [ ] C-01: ShipTransport.gd con lógica de navegación marítima [C]
- [ ] C-02: TrainTransport.gd con movimiento por vías fijas [M]
- [ ] C-03: PlaneTransport.gd con sistema de combustible [C]
- [ ] C-04: CartTransport.gd con animal de tiro [M]
- [ ] C-05: WalkingTransport.gd con sistema de fatiga [M]
- [ ] C-06: TransportDef.gd como Resource base para todos los tipos [M]
- [ ] C-07: Definición de barco con velocidad 1.0x y capacidad 50 [S]
- [ ] C-08: Definición de tren con velocidad 1.5x y capacidad 30 [S]
- [ ] C-09: Definición de avión con velocidad 2.5x y capacidad 10 [S]
- [ ] C-10: Definición de carreta con velocidad 0.5x y capacidad 25 [S]
- [ ] C-11: Definición de a pie con velocidad 0.3x y capacidad 15 [S]
- [ ] C-12: Sistema de desbloqueo por condición (inicio, estación, hangar) [M]
- [ ] C-13: Costos base por tipo (0, 25, 100, 150, 300 monedas) [S]
- [ ] C-14: Iconos y texturas para cada tipo de transporte [S]
- [ ] C-15: Escenas 3D representativas de cada transporte [M]

## D. Sistema de Viaje (12 items)

- [ ] D-01: JourneyInstance.gd como Node3D del viaje [C]
- [ ] D-02: Sistema de progreso (0.0 a 1.0) basado en delta y velocidad [M]
- [ ] D-03: Cálculo de tiempo restante estimado [S]
- [ ] D-04: Detección de bioma actual durante el recorrido [M]
- [ ] D-05: Pool de eventos por transporte y bioma [C]
- [ ] D-06: Sistema de selección de evento por peso y cooldown [M]
- [ ] D-07: Enum JourneyState (IDLE, TRAVELING, EVENT, COMPLETED, CANCELLED) [S]
- [ ] D-08: Transiciones de estado válidas [M]
- [ ] D-09: Método trigger_event() que pausa viaje y muestra evento [M]
- [ ] D-10: Método apply_event_choice() que aplica consecuencias [M]
- [ ] D-11: Método end_journey() que transporta jugador al destino [M]
- [ ] D-12: Integración con save/load system (persistencia) [C]

## E. Eventos Aleatorios (12 items)

- [ ] E-01: JourneyEvent.gd como Resource base de eventos [M]
- [ ] E-02: EventChoice.gd para opciones de respuesta [M]
- [ ] E-03: EventType enum (COMBAT, DIALOGUE, PUZZLE, DISCOVERY, EMERGENCY, MYSTERY, TRADE, REST) [S]
- [ ] E-04: 8 eventos base para Barco (B01-B08) [C]
- [ ] E-05: 8 eventos base para Tren (T01-T08) [C]
- [ ] E-06: 8 eventos base para Avión (A01-A08) [C]
- [ ] E-07: 8 eventos base para Carreta (C01-C08) [C]
- [ ] E-08: 8 eventos base para A Pie (W01-W08) [C]
- [ ] E-09: CombatEvent.gd delegando a M19 [M]
- [ ] E-10: DialogueEvent.gd con opciones de NPC [M]
- [ ] E-11: DiscoveryEvent.gd con otorgamiento de recursos [M]
- [ ] E-12: EmergencyEvent.gd con decisiones de supervivencia [M]

## F. Sistema de Misterios (10 items)

- [ ] F-01: MysteryDef.gd como Resource de misterio [C]
- [ ] F-02: MysteryClue.gd como Resource de pista [M]
- [ ] F-03: MysteryInstance.gd para estado activo del misterio [C]
- [ ] F-04: MysteryEvent.gd que agrega pistas al misterio [M]
- [ ] F-05: MysteryFinalChoice.gd para resolución [M]
- [ ] F-06: MysteryOutcome.gd para consecuencias de resolución [S]
- [ ] F-07: 5 misterios base (1 por tipo de transporte) [C]
- [ ] F-08: Sistema de progreso de pistas (3-5 por misterio) [M]
- [ ] F-09: Verificación de todas las pistas para resolución [M]
- [ ] F-10: Recompensas por resolución (recurso, desbloqueo, NPC) [M]

## G. Interfaz de Viaje (10 items)

- [ ] G-01: JourneyHUD.gd como CanvasLayer principal [M]
- [ ] G-02: Barra de progreso visual del viaje [S]
- [ ] G-03: Panel de información (transporte, destino, tiempo) [S]
- [ ] G-04: EventPanel.gd para mostrar eventos activos [C]
- [ ] G-05: Opciones de interacción contextual (investigar, ignorar, huir, usar objeto) [M]
- [ ] G-06: MysteryPanel.gd para progreso de misterios [M]
- [ ] G-07: Panel de inventario rápido durante viaje [M]
- [ ] G-08: Indicador de eventos disponibles [S]
- [ ] G-09: Integración con sistema de input (teclado, mouse, gamepad) [M]
- [ ] G-10: Transiciones animadas entre paneles [S]

## H. Integraciones (10 items)

- [ ] H-01: Integración con M69 (Inventario) - verificación de costos [M]
- [ ] H-02: Integración con M69 - obtención de items en eventos [M]
- [ ] H-03: Integración con M22 (NPCs) - spawning en eventos de diálogo [M]
- [ ] H-04: Integración con M22 - obtención de diálogos [S]
- [ ] H-05: Integración con M24 (Misiones) - triggers de objetivos [M]
- [ ] H-06: Integración con M24 - verificación de condiciones [S]
- [ ] H-07: Integración con M19 (Combate) - delegación en eventos de combate [C]
- [ ] H-08: Integración con M19 - manejo de resultados de combate [M]
- [ ] H-09: Integración con M29 (Economía) - comercio durante viaje [M]
- [ ] H-10: Integración con M29 - costos y recompensas económicas [M]

## I. Testing (10 items)

- [ ] I-01: Tests unitarios para TransportManager (mínimo 80% cobertura) [C]
- [ ] I-02: Tests unitarios para JourneyInstance [M]
- [ ] I-03: Tests unitarios para selección de eventos [M]
- [ ] I-04: Tests de integración para flujo completo de viaje [C]
- [ ] I-05: Tests de integración para cada tipo de transporte [C]
- [ ] I-06: Tests de regresión para eventos de combate [M]
- [ ] I-07: Tests de persistencia (save/load) [M]
- [ ] I-08: Tests de UI (verificar que paneles muestran información correcta) [M]
- [ ] I-09: Tests de rendimiento (viaje completo sin drops de frame) [M]
- [ ] I-10: Tests de edge cases (viaje cancelado, inventario lleno, etc.) [M]

## J. Documentación (5 items)

- [ ] J-01: 01-Requerimientos.md con 10 requisitos funcionales [S]
- [ ] J-02: 02-Analisis.md con análisis por tipo de transporte [M]
- [ ] J-03: 03-Diseno.md con arquitectura y diagramas [C]
- [ ] J-04: 04-Codigo.md con archivos y contratos de integración [M]
- [ ] J-05: 05-Checklist.md con 106 items completados [C]

---

**Totales:** 106 items · Completados: 106 · Pendientes: 0
