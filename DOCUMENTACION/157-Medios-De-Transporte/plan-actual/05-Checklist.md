**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30 (scaffold plan-actual; base plan-inicial MiMo V2.5 / OpenCode, 2026-08-22)

# 05-Checklist.md — Modulo 157: Medios de Transporte (plan-actual)

> **Estado del scaffold (2026-10-30, encargo de agnes-3-flash msg 317, vuelta 14 de Ling):** `plan-actual/` creada por Ling-3.1-Flash. Los archivos 01-04 son copia intacta del `plan-inicial/` + nota de scaffold (AGENTS.md §11.7). Este 05 **reescribe el del plan-inicial con honestidad de disco**: el plan-inicial declaraba "Totales: 106 items · Completados: 106" con **0 marcas `[x]` reales** (patrón de inflación M01/M119), y el módulo tiene **0 implementación verificada en disco** (glob/grep 2026-10-30: sin `TransportManager.gd`, `JourneyInstance.gd`, `*Transport.gd`, `JourneyHUD.gd`, `EventPanel.gd`, `MysteryPanel.gd`, ni carpetas `transport_definitions/` / `journey_events/` / `mysteries/` en `game/isla-ancestral/scripts/`; los únicos hits relacionados pertenecen a otros módulos: M67 `vehiculo_invariant.gd`, M104 `telemetria_m104.gd`, señal de barco en `event_bus.gd` L103).
>
> **Arranque honesto: 4 `[x]` documentales sustanciables (J-01..J-04) + 128 `[ ]`.** La sección K amplía el cubrimiento contra `Plan-inicial-minimo.md` (600+ puntos), `Plan-de-produccion.md` y los estándares del proyecto (AGENTS.md).
>
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
- [ ] E-02: EventChoice.gd para opciones de respuesta a evento [M]
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

- [x] J-01: 01-Requerimientos.md con 10 requisitos funcionales [S] — evidencia disco: `plan-actual/01-Requerimientos.md` RF-01..RF-10 presentes (copia verificada del plan-inicial + nota de scaffold)
- [x] J-02: 02-Analisis.md con análisis por tipo de transporte [M] — evidencia disco: `plan-actual/02-Analisis.md` L9 Barco / L35 Tren / L61 Avión / L87 Carreta / L113 A Pie
- [x] J-03: 03-Diseno.md con arquitectura y diagramas [C] — evidencia disco: `plan-actual/03-Diseno.md` L7 Arquitectura General, diagrama TransportManager L11-14, Diagrama de Flujo del Viaje L292
- [x] J-04: 04-Codigo.md con archivos y contratos de integración [M] — evidencia disco: `plan-actual/04-Codigo.md` lista 20 scripts "A Crear" + contratos. **ADVERTENCIA anti-drift (patrón M119): los scripts listados NO existen en disco — el [x] cubre el documento, no la implementación**
- [ ] J-05: 05-Checklist.md con 106 items completados [C] — este archivo (132 ítems: 4 [x] / 128 [ ]); se cumple con 106+ ítems [x] reales según DoD §21.6

## K. Cubrimiento ampliado — Plan-inicial-minimo + Plan-de-produccion + estándares del proyecto (26 items)

> Agregados por Ling-3.1-Flash (2026-10-30) para cumplir AGENTS.md §3 (mínimo 100 ítems con cubrimiento de fuentes primarias) y elevar la verificabilidad del módulo. Referencias: `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` (§3 Game Engine, §27 Viajes, §56 Interfaz de Control, §57 Accesibilidad, §58 Guardado, §60 Rendimiento, §65 Anti-Softlock, §67 Transporte y Navegación, §86 Localización, §100 QA, §111 Testing) y `Plan-de-produccion.md` (§3.6 Viaje entre islas, §3.7 Océano, §4 Pipeline arte 3D, §8 UI/UX, §10 QA/testing/optimización).

- [ ] K-01: TransportManager registrado como autoload en `project.godot` (Project Settings > Autoload), no como singleton manual [S] — Plan-inicial-minimo §3
- [ ] K-02: Estructura de carpetas Godot del proyecto para assets del módulo: `scripts/transporte/` + `scenes/transporte/` + `data/transporte/` [S] — AGENTS.md §24
- [ ] K-03: Nomenclatura GDScript del proyecto (snake_case archivos, PascalCase clases, `_` prefijo privados) y consulta de GUIA-GODOT errores comunes antes de codificar [S] — AGENTS.md §26/§28
- [ ] K-04: **i18n (nicho Ling):** TODO texto jugador-visible del módulo vía `_t()` con claves `M157.*` en los 3 catálogos (es/en/pt), paridad total de msgids, 0 literales ES en producción [C] — riel M87; Plan-inicial-minimo §86
- [ ] K-05: Marcadores `#. no-traducir` en los 3 .po para nombres propios de misterios/lore del módulo (patrón M87, 15 marcadores base + cognatos) [M] — riel M87
- [ ] K-06: Plurales PT (nplurals=2, msgstr[0]+[1]) en textos de viaje con conteos (horas/minutos/segundos restantes, pasajeros, eventos) [M] — canon PT del GO #4
- [ ] K-07: UI desacoplada (AGENTS §9): JourneyHUD/EventPanel/MysteryPanel solo renderizan; toda la lógica de viaje vive en TransportManager/JourneyInstance [M]
- [ ] K-08: Controles de viaje con New Input System (teclado, mouse, gamepad) — RNF-03 [M] — Plan-inicial-minimo §56
- [ ] K-09: Accesibilidad: eventos comunicados por audio Y texto; alternativas para jugadores con distintas habilidades — RNF-03 [M] — Plan-inicial-minimo §57
- [ ] K-10: Rendimiento: pooling de eventos, generación bajo demanda (no pre-cargados), viaje completo sin drops >5ms — RNF-01 [M] — Plan-inicial-minimo §60
- [ ] K-11: Optimización de assets 3D de transportes: LOD 3 niveles, culling, batching — estándar §21.4 (no se acepta polígono mal optimizado) [M]
- [ ] K-12: Tests unitarios TransportManager ≥80% cobertura, ejecutables headless (suites en quality.yml) [C] — RNF-05; Plan-inicial-minimo §111
- [ ] K-13: Tests de integración: flujo completo de viaje + 1 viaje por cada tipo de transporte (CA-08: 0 errores de runtime) [C]
- [ ] K-14: Tests de edge cases: viaje cancelado, inventario lleno, fondos insuficientes, softlock a medio viaje [M]
- [ ] K-15: Plan de testings profesional (`plan-actual/06-Plan-Testings.md`) creado ANTES de la primera prueba manual (módulo complejo, gameplay core) [M] — AGENTS §14
- [ ] K-16: Persistencia del viaje: save/load de viaje activo, eventos completados, misterios resueltos, transportes desbloqueados — RF-09 [C] — Plan-inicial-minimo §58
- [ ] K-17: Señales de event bus documentadas para el módulo (journey_started / journey_event / journey_completed / journey_cancelled) en `event_bus.gd` [M]
- [ ] K-18: Anti-softlock: reglas ante viaje cancelado, interrumpido por carga, o jugador atrapado a medio viaje (integrar `softlock_rules.gd` / `softlock_guard.gd`) [C] — Plan-inicial-minimo §65
- [ ] K-19: Telemetría M104: eventos de transporte medibles (embarque, desembarque, evento de viaje, resolución de misterio) con propiedades [M] — Plan-inicial-minimo §104
- [ ] K-20: Capturas de progreso del módulo en `tools/mcp/godot-mcp/capturas/157-Medios-De-Transporte/` (nomenclatura cap_157_*, sin sobrescribir) [S] — AGENTS §24
- [ ] K-21: Respaldo en `Obsoletos/` con nomenclatura timestamp antes de refactors grandes del módulo [S] — AGENTS §5
- [ ] K-22: Logs en `Logs/` con numeración de pool (§6.1) y firma modelo/plataforma en toda documentación generada [S] — AGENTS §6
- [ ] K-23: QA cruzado §21.8 (verificador ≠ implementador) + muestreo anti-inflación §21.8.2.b (≥5 ítems [x] contra disco) ANTES de cualquier sello [M]
- [ ] K-24: Cubrimiento Plan-de-produccion §3.6 "Viaje entre islas": diseño de rutas/destinos, costes, transición cozy sin perder al jugador [M]
- [ ] K-25: Mapeo de puntos relevantes del maestro: Plan-inicial-minimo §27 Viajes + §67 Transporte y Navegación → RF/CA de este módulo (tabla de trazabilidad) [M]
- [ ] K-26: Auditoría anti-inflación permanente: verificar artefacto en disco por ítem antes de marcar [x] (lección M01/M119; el plan-inicial declaró 106/106 con 0 marcas reales) [S]

---

**Totales:** 132 items · Completados: 4 (J-01..J-04 documentales, evidencia en disco) · Pendientes: 128 · [?]: 0

**Drift documental corregido:** plan-inicial/05 declaraba "106/106 completados" sin marcas `[x]` reales ni implementación en disco. Este plan-actual arranca verificable: 4/132 con evidencia citada por ítem.

## Notas del Agente

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-30
**Estado:** Scaffold de plan-actual completado (encargo agnes-3-flash msg 317, vuelta 14)

### Lo que hice
- Creé `DOCUMENTACION/157-Medios-De-Transporte/plan-actual/` (no existía; el GLOBAL reportaba "Progreso no verificable → 0/106 hasta crear el plan-actual").
- 01-04: copia intacta del plan-inicial + nota de scaffold con verificación de disco (AGENTS §11.7).
- 05-Checklist.md: reescrito honesto — 106 ítems base A-J del plan-inicial + 26 ítems K de cubrimiento ampliado (Plan-inicial-minimo §3/§27/§56-58/§60/§65/§67/§86/§100/§111 + Plan-de-produccion §3.6/§3.7/§4/§8/§10 + estándares AGENTS).
- J-01..J-04 `[x]` solo con evidencia textual en disco (archivo + línea); J-05 `[ ]` (requiere 106+ ítems completados con DoD).

### Verificación en disco (2026-10-30)
- 0 implementación del módulo: glob/grep en `game/isla-ancestral/scripts/` sin TransportManager/JourneyInstance/*Transport/JourneyHUD/EventPanel/MysteryPanel; 0 carpetas transport_definitions/journey_events/mysteries.
- Hits relacionados son de OTROS módulos (M67 vehiculo_invariant, M104 telemetría puertos, event_bus L103 barco/vessel) — no cuentan para M157.
- 02-Analisis: análisis de los 5 tipos confirmado (L9/35/61/87/113). 03-Diseno: arquitectura + diagramas confirmados (L7/11-14/292). 04-Codigo: 20 scripts "A Crear" + contratos.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementación del módulo (0/128 ítems de código): fuera de mi nicho doc/i18n y del encargo (agnes: "scaffoldeá su 05"). Requiere GO del fundador + visión M154 para assets 3D (C-15) + owner de gameplay.
- 06-Plan-Testings.md / 07-Resultados: no creados porque no hay código que testear (módulo 0 implementación); se agregan cuando exista implementación (módulo complejo, §14).

### Recomendaciones para el próximo agente
- Dueño de implementación: definir arquitectura contra 03-Diseno del plan-inicial (TransportManager autoload + JourneyInstance Node3D + Resources TransportDef/JourneyEvent/MysteryDef).
- i18n del módulo (K-04..K-06) es mi riel: cuando existan literales jugador-visibles, pasarlos por el proceso M87 (clave M157.* + 3 catálogos + validador_po).
- Integraciones críticas a respetar: M69 inventario, M22 NPCs, M24 misiones, M19 combate, M29 economía (sección H) + M28-Viajes ( TravelService 4 rutas, Log 370) y M68-Transporte-Y-Navegacion (grafo de paradas/rutas 130/130, Log 437-equivalente DeepSeek) — M157 debe consumir el grafo de M68 como fuente de rutas, NO duplicarlo.
- Anti-drift: todo ítem [x] futuro debe citar archivo:línea verificable (§21.8.2.b).
