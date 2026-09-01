**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 07: Arquitectura General

**Estado:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Principios de arquitectura (14)

- [x] Definir arquitectura modular por dominio [S]
- [x] Definir la separación de sistemas independientes [S]
- [x] Definir la regla de capas unidireccionales (UI→Servicios→Sistemas→Datos) [S] (validada por verificar_arquitectura.gd: scripts/core no referencia capas superiores)
- [x] Minimizar dependencias circulares (4 reglas verificables) [S]
- [x] Definir los managers necesarios (lista de 18 servicios) [S]
- [x] Prohibir el GameManager monolítico (Bootstrap orquesta) [S] (bootstrap.gd: solo registro y carga de escena)
- [x] Diseñar el sistema de eventos global tipado (EventBus) [S]
- [x] Diseñar el sistema de configuración (Settings autoload) [S] (game_settings.gd activo como autoload)
- [x] Diseñar el sistema de datos (Resources vs comportamiento) [S]
- [x] Diseñar el sistema de persistencia (GameState, alto nivel) [S]
- [x] Diseñar el sistema de streaming (escenas+chunks) [S]
- [x] Diseñar el sistema de escenas (SceneManager) [S]
- [x] Diseñar el sistema de chunks (VoxelWorld/ChunkManager) [S]
- [x] Documentar el flujo de arranque/cierre del juego [S]

## B. Mapeo de los 27 sistemas del plan maestro (14)

- [x] Mapear objetos interactivos → InteractableService [S]
- [x] Mapear NPC → NPCScheduler + NPCEmotionService [S]
- [x] Mapear misiones → QuestManager [S]
- [x] Mapear inventario → InventoryService [S]
- [x] Mapear crafting → CraftingManager [S]
- [x] Mapear economía → EconomyService (doble wallet) [S]
- [x] Mapear construcción → BuildManager [S]
- [x] Mapear agricultura → FarmingSystem [S]
- [x] Mapear pesca → FishingSystem [S]
- [x] Mapear minería → MiningSystem [S]
- [x] Mapear clima → WeatherSystem [S]
- [x] Mapear estaciones → SeasonSystem [S]
- [x] Mapear tiempo → GameClock [S]
- [x] Mapear viaje y descubrimiento → TravelManager/DiscoveryService [S]

## C. Service Locator y ciclo de vida (12)

- [x] Diseñar ServiceRegistry (registro por interfaz) [M]
- [x] Definir que los servicios se consultan por interface, no por nombre [S]
- [x] Diseñar Bootstrap (autoload 0: registro + arranque) [M] (bootstrap.gd operativo; posición de autoload al final recomendada, diferido por reservas M53/M112)
- [x] Definir el orden de registro de servicios [S] (event_bus -> service_registry; precedencias de autoloads validadas por script)
- [x] Diseñar el flujo de carga de isla (SceneManager→World→chunks→carga diégetica) [M]
- [x] Diseñar el flujo de cierre (autosave→flush→logs) [S]
- [x] Definir la cola de trabajo pesado (ThreadPool + call_deferred) [M]
- [x] Definir la comunicación síncrona liviana entre servicios vecinos [S]
- [x] Definir la comunicación por eventos para cruzada [S]
- [x] Definir el autosave por eventos acotados [S]
- [x] Documentar que el progreso visual de carga es obligatorio (AGENTS §8) [S]
- [x] Documentar el patrón MVP por dominio (View/Controller/Model) [S]

## D. GameState (alto nivel) (10)

- [x] Diseñar la partición por dominio (meta, world, player, economy…) [S]
- [x] Definir que los servicios mutan estado solo vía API pública [S]
- [x] Definir que nada fuera de servicios de datos toca GameState [S]
- [x] Definir versionado y migraciones por partición (detalle M59) [S]
- [x] Definir settings del usuario fuera del GameState [S]
- [x] Definir el guardado de diffs de chunks por isla [S]
- [x] Definir flags de mundo consultables (reactividad NPC) [S]
- [x] Definir fecha/estación/eventos en calendar state [S]
- [x] Definir discovery state (islas/regiones) [S]
- [x] Documentar la relación con M59 (diseño detallado) [S]

## E. EventBus por dominios (10)

- [x] Diseñar el dominio `world` (chunk_modified, block_placed…) [S]
- [x] Diseñar el dominio `economy` (currency_changed, purchase_done…) [S]
- [x] Diseñar el dominio `inventory` (item_added, hotbar_selected…) [S]
- [x] Diseñar el dominio `quest` (quest_started, prereq_met…) [S]
- [x] Diseñar el dominio `npc` (moveln, friendship_level_up…) [S]
- [x] Diseñar el dominio `calendar` (day_started, vessel_arrived…) [S]
- [x] Diseñar el dominio `travel` (travel_started, island_loaded…) [S]
- [x] Diseñar el dominio `ui` (hud, dialog — solo suscripción desde UI) [S]
- [x] Definir que EventBus no importa dominios (solo tipos) [S]
- [x] Definir payloads tipados (objetos de dominio) [S]

## F. Evaluación de alternativas (8)

- [x] Evaluar ECS y descartarlo para v1.0 (motivo documentado) [S]
- [x] Evaluar MVC/MVP por dominio (adoptado parcial) [S]
- [x] Evaluar singleton puro (descartado → Service Registry) [S]
- [x] Documentar el equivalente Godot de ScriptableObjects (Resources) [S]
- [x] Documentar por qué no se hereda de un "BaseManager" gigante [S]
- [x] Evaluar la composición sobre herencia (M05/AGENTS §9) [S]
- [x] Documentar el trade-off de los 18 servicios vs menos/grandes [S]
- [x] Documentar el trade-off ECS en caso de necesitarse post-v1.0 [S]

## G. Riesgos y anti-patterns (10)

- [x] Documentar riesgo: bus de eventos lento → medición M61 [S]
- [x] Documentar riesgo: dependencias circulares en la práctica → script de verificación [S]
- [x] Documentar riesgo: GameState gigante → partición + versionado por dominio [S]
- [x] Documentar riesgo: Bootstrap con lógica → solo registro [S]
- [x] Prohibir acceso directo UI→Sistemas [S]
- [x] Prohibir acceso directo a GameState desde gameplay [S]
- [x] Prohibir servicios sin interface registrada [S]
- [x] Prohibir eventos con payload abierto (dict) [S]
- [x] Prohibir lógica de dominio dentro de escenas (.tscn) [S]
- [x] Prohibir importar UI desde dominios (espiral inversa) [S]

## H. Calidad y verificación documental (12)

- [x] Definir el script de verificación de capas (imports estáticos) [M]
- [x] Definir el contrato de integración en 6 pasos [S]
- [x] Verificar trazabilidad de los 27 puntos del plan maestro [S]
- [x] Verificar coherencia con M04 (Godot) y M05 (patrones GDScript) [S]
- [x] Verificar coherencia con Plan-de-produccion §3 (framework emisor→receptor en Templos) [S]
- [x] Actualizar 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md con arquitectura [S]
- [x] Actualizar CHECKLIST-GLOBAL con el estado de M07 [S]
- [x] Actualizar DOCUMENTACION/README.md con el componente 07 [S]
- [x] Generar log de finalización y actualizar ULTIMO_NUMERO [S]
- [x] Copiar plan-inicial → plan-actual (espejo vigente) [S]
- [x] Documentar los pendientes con dueño (M1, M59, M61) [S]
- [x] Registrar el criterio de salida del módulo (bootstrap mínimo en M1) [S] (puerta F1 verificada: escena prueba_arquitectura.tscn SMOKE OK)

## I. Edge cases e integración con el mundo (12)

- [x] Documentar la comunicación VoxelWorld → ChunkManager (threading + deferred) [S]
- [x] Documentar la integración del framework emisor→receptor con EventBus [S]
- [x] Documentar el flujo de modificación de bloque → evento world → suscriptores (reacción de NPC) [S]
- [x] Documentar el flujo de crafting → economía → tienda (transición de servicios) [S]
- [x] Documentar el flujo de pesca/minería → inventario → quest [S]
- [x] Documentar el flujo de viaje (travel_started → isla_loaded → autosave) [S]
- [x] Documentar el edge case: evento emitido durante carga de escena (diferir) [S]
- [x] Documentar el edge case: servicios que arrancan en distinto orden (bootstrap idempotente) [S] (precedencias verificadas; bootstrap deferred e idempotente)
- [x] Documentar el edge case: reinicio del juego con servicios con estado en memoria [S]
- [x] Documentar el edge case: dos sistemas escribiendo el mismo dominio de GameState (API única) [S]
- [x] Documentar el edge case: tiempo real vs tiempo de juego (GameClock como única fuente) [S]
- [x] Documentar el edge case: pérdida de red/archivos → ErrorHandler + estado de recuperación [S]

---

**Totales:** 102 ítems · Completados: 102 · Pendientes: 0 · No resueltos: 0.
**Nota:** los detalles de implementación (bootstrap real, verificación de capas, perf de eventos) se ejecutan en el hito M1 y quedan registrados en 04-Codigo.md §4 como pendientes con dueño.

## Implementacion Fase 1 (2026-08-29 — Hy3/Kilo)

- [x] Definir orden de inicializacion de autoloads [S] (precedencias canonicas en verificar_arquitectura.gd; EventBus primero; Bootstrap al final recomendado y diferido por reservas M53/M112)
- [x] Verificar dependencias unidireccionales [S] (scripts/core sin referencias a capas superiores; verificado por script)
- [x] Ejecutar una escena vacia usando la arquitectura base [S] (scenes/prueba_arquitectura.tscn: SMOKE OK en runtime real — autoloads, registro y EventBus por dominios)


## Notas del Agente (Cierre Fase 1 - 2026-08-29)

**Modelo:** Hy3 | **Plataforma:** Kilo | **Estado:** items de la guia 08 completados y verificados; auditoria del resto del checklist pendiente (honestidad 21.4.3)

### Lo que hice
- Verificacion con Godot 4.7.2 headless + runtime: proyecto arranca sin errores de script.
- Ver tilo de guia 08 del modulo completado con evidencia (ver seccion "Implementacion Fase 1").
- Libere el modulo en CHECKLIST-GLOBAL y ESTADO-PARALELO como nucleo verificado (🟡); la auditoria completa del checklist queda para la siguiente pasada.

### Pendiente (honestidad)
- Auditoria item por item del resto de este checklist contra el codigo real.
