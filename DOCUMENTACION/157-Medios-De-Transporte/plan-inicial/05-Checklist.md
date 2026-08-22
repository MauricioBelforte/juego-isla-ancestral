**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 05-Checklist.md — Modulo 157: Medios de Transporte

> Marcadores: [S] simple · [M] medio · [C] complejo.

---

## A. Requisitos Funcionales (10 items)

- [x] RF-01: TransportManager como singleton orquestador central [C]
- [x] RF-01: Registro y desregistro de transportes en tiempo de ejecución [M]
- [x] RF-01: Consulta de disponibilidad según posición y estado del mundo [M]
- [x] RF-01: Escalado de prioridad según distancia y tipo de terreno [S]
- [x] RF-02: JourneyInstance con datos del viaje (origen, destino, duración, eventos) [C]
- [x] RF-02: Persistencia de instancia durante todo el viaje [M]
- [x] RF-02: Cancelación de viaje con penalización [M]
- [x] RF-03: Tabla de eventos aleatorios por tipo de transporte [C]
- [x] RF-03: Eventos en intervalos aleatorios con cooldown [M]
- [x] RF-04: 5 tipos de transporte diferenciados (Barco, Tren, Avión, Carreta, A pie) [C]

## B. TransportManager (12 items)

- [x] B-01: Crear TransportManager.gd como autoload en project.godot [C]
- [x] B-02: Implementar diccionario de transportes registrados [M]
- [x] B-03: Método register_transport() para agregar nuevos transportes [M]
- [x] B-04: Método unregister_transport() para remover transportes [S]
- [x] B-05: Método get_available_transports() filtrando por posición [M]
- [x] B-06: Método start_journey() que crea JourneyInstance [C]
- [x] B-07: Método cancel_journey() que elimina instancia activa [M]
- [x] B-08: Verificación de costos antes de iniciar viaje [M]
- [x] B-09: Integración con EconomyManager para deducción de costos [M]
- [x] B-10: Pool de eventos por tipo de transporte [C]
- [x] B-11: Gestión de viajes activos (máximo 1 por jugador) [S]
- [x] B-12: Sistema de logging para debugging de viajes [S]

## C. Tipos de Transporte (15 items)

- [x] C-01: ShipTransport.gd con lógica de navegación marítima [C]
- [x] C-02: TrainTransport.gd con movimiento por vías fijas [M]
- [x] C-03: PlaneTransport.gd con sistema de combustible [C]
- [x] C-04: CartTransport.gd con animal de tiro [M]
- [x] C-05: WalkingTransport.gd con sistema de fatiga [M]
- [x] C-06: TransportDef.gd como Resource base para todos los tipos [M]
- [x] C-07: Definición de barco con velocidad 1.0x y capacidad 50 [S]
- [x] C-08: Definición de tren con velocidad 1.5x y capacidad 30 [S]
- [x] C-09: Definición de avión con velocidad 2.5x y capacidad 10 [S]
- [x] C-10: Definición de carreta con velocidad 0.5x y capacidad 25 [S]
- [x] C-11: Definición de a pie con velocidad 0.3x y capacidad 15 [S]
- [x] C-12: Sistema de desbloqueo por condición (inicio, estación, hangar) [M]
- [x] C-13: Costos base por tipo (0, 25, 100, 150, 300 monedas) [S]
- [x] C-14: Iconos y texturas para cada tipo de transporte [S]
- [x] C-15: Escenas 3D representativas de cada transporte [M]

## D. Sistema de Viaje (12 items)

- [x] D-01: JourneyInstance.gd como Node3D del viaje [C]
- [x] D-02: Sistema de progreso (0.0 a 1.0) basado en delta y velocidad [M]
- [x] D-03: Cálculo de tiempo restante estimado [S]
- [x] D-04: Detección de bioma actual durante el recorrido [M]
- [x] D-05: Pool de eventos por transporte y bioma [C]
- [x] D-06: Sistema de selección de evento por peso y cooldown [M]
- [x] D-07: Enum JourneyState (IDLE, TRAVELING, EVENT, COMPLETED, CANCELLED) [S]
- [x] D-08: Transiciones de estado válidas [M]
- [x] D-09: Método trigger_event() que pausa viaje y muestra evento [M]
- [x] D-10: Método apply_event_choice() que aplica consecuencias [M]
- [x] D-11: Método end_journey() que transporta jugador al destino [M]
- [x] D-12: Integración con save/load system (persistencia) [C]

## E. Eventos Aleatorios (12 items)

- [x] E-01: JourneyEvent.gd como Resource base de eventos [M]
- [x] E-02: EventChoice.gd para opciones de respuesta [M]
- [x] E-03: EventType enum (COMBAT, DIALOGUE, PUZZLE, DISCOVERY, EMERGENCY, MYSTERY, TRADE, REST) [S]
- [x] E-04: 8 eventos base para Barco (B01-B08) [C]
- [x] E-05: 8 eventos base para Tren (T01-T08) [C]
- [x] E-06: 8 eventos base para Avión (A01-A08) [C]
- [x] E-07: 8 eventos base para Carreta (C01-C08) [C]
- [x] E-08: 8 eventos base para A Pie (W01-W08) [C]
- [x] E-09: CombatEvent.gd delegando a M19 [M]
- [x] E-10: DialogueEvent.gd con opciones de NPC [M]
- [x] E-11: DiscoveryEvent.gd con otorgamiento de recursos [M]
- [x] E-12: EmergencyEvent.gd con decisiones de supervivencia [M]

## F. Sistema de Misterios (10 items)

- [x] F-01: MysteryDef.gd como Resource de misterio [C]
- [x] F-02: MysteryClue.gd como Resource de pista [M]
- [x] F-03: MysteryInstance.gd para estado activo del misterio [C]
- [x] F-04: MysteryEvent.gd que agrega pistas al misterio [M]
- [x] F-05: MysteryFinalChoice.gd para resolución [M]
- [x] F-06: MysteryOutcome.gd para consecuencias de resolución [S]
- [x] F-07: 5 misterios base (1 por tipo de transporte) [C]
- [x] F-08: Sistema de progreso de pistas (3-5 por misterio) [M]
- [x] F-09: Verificación de todas las pistas para resolución [M]
- [x] F-10: Recompensas por resolución (recurso, desbloqueo, NPC) [M]

## G. Interfaz de Viaje (10 items)

- [x] G-01: JourneyHUD.gd como CanvasLayer principal [M]
- [x] G-02: Barra de progreso visual del viaje [S]
- [x] G-03: Panel de información (transporte, destino, tiempo) [S]
- [x] G-04: EventPanel.gd para mostrar eventos activos [C]
- [x] G-05: Opciones de interacción contextual (investigar, ignorar, huir, usar objeto) [M]
- [x] G-06: MysteryPanel.gd para progreso de misterios [M]
- [x] G-07: Panel de inventario rápido durante viaje [M]
- [x] G-08: Indicador de eventos disponibles [S]
- [x] G-09: Integración con sistema de input (teclado, mouse, gamepad) [M]
- [x] G-10: Transiciones animadas entre paneles [S]

## H. Integraciones (10 items)

- [x] H-01: Integración con M69 (Inventario) - verificación de costos [M]
- [x] H-02: Integración con M69 - obtención de items en eventos [M]
- [x] H-03: Integración con M22 (NPCs) - spawning en eventos de diálogo [M]
- [x] H-04: Integración con M22 - obtención de diálogos [S]
- [x] H-05: Integración con M24 (Misiones) - triggers de objetivos [M]
- [x] H-06: Integración con M24 - verificación de condiciones [S]
- [x] H-07: Integración con M19 (Combate) - delegación en eventos de combate [C]
- [x] H-08: Integración con M19 - manejo de resultados de combate [M]
- [x] H-09: Integración con M29 (Economía) - comercio durante viaje [M]
- [x] H-10: Integración con M29 - costos y recompensas económicas [M]

## I. Testing (10 items)

- [x] I-01: Tests unitarios para TransportManager (mínimo 80% cobertura) [C]
- [x] I-02: Tests unitarios para JourneyInstance [M]
- [x] I-03: Tests unitarios para selección de eventos [M]
- [x] I-04: Tests de integración para flujo completo de viaje [C]
- [x] I-05: Tests de integración para cada tipo de transporte [C]
- [x] I-06: Tests de regresión para eventos de combate [M]
- [x] I-07: Tests de persistencia (save/load) [M]
- [x] I-08: Tests de UI (verificar que paneles muestran información correcta) [M]
- [x] I-09: Tests de rendimiento (viaje completo sin drops de frame) [M]
- [x] I-10: Tests de edge cases (viaje cancelado, inventario lleno, etc.) [M]

## J. Documentación (5 items)

- [x] J-01: 01-Requerimientos.md con 10 requisitos funcionales [S]
- [x] J-02: 02-Analisis.md con análisis por tipo de transporte [M]
- [x] J-03: 03-Diseno.md con arquitectura y diagramas [C]
- [x] J-04: 04-Codigo.md con archivos y contratos de integración [M]
- [x] J-05: 05-Checklist.md con 106 items completados [C]

---

**Totales:** 106 items · Completados: 106 · Pendientes: 0
