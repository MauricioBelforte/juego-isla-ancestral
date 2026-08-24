**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 07: Arquitectura General

**Estado:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Principios de arquitectura (14)

- [ ] Definir arquitectura modular por dominio [S]
- [ ] Definir la separación de sistemas independientes [S]
- [ ] Definir la regla de capas unidireccionales (UI→Servicios→Sistemas→Datos) [S]
- [ ] Minimizar dependencias circulares (4 reglas verificables) [S]
- [ ] Definir los managers necesarios (lista de 18 servicios) [S]
- [ ] Prohibir el GameManager monolítico (Bootstrap orquesta) [S]
- [ ] Diseñar el sistema de eventos global tipado (EventBus) [S]
- [ ] Diseñar el sistema de configuración (Settings autoload) [S]
- [ ] Diseñar el sistema de datos (Resources vs comportamiento) [S]
- [ ] Diseñar el sistema de persistencia (GameState, alto nivel) [S]
- [ ] Diseñar el sistema de streaming (escenas+chunks) [S]
- [ ] Diseñar el sistema de escenas (SceneManager) [S]
- [ ] Diseñar el sistema de chunks (VoxelWorld/ChunkManager) [S]
- [ ] Documentar el flujo de arranque/cierre del juego [S]

## B. Mapeo de los 27 sistemas del plan maestro (14)

- [ ] Mapear objetos interactivos → InteractableService [S]
- [ ] Mapear NPC → NPCScheduler + NPCEmotionService [S]
- [ ] Mapear misiones → QuestManager [S]
- [ ] Mapear inventario → InventoryService [S]
- [ ] Mapear crafting → CraftingManager [S]
- [ ] Mapear economía → EconomyService (doble wallet) [S]
- [ ] Mapear construcción → BuildManager [S]
- [ ] Mapear agricultura → FarmingSystem [S]
- [ ] Mapear pesca → FishingSystem [S]
- [ ] Mapear minería → MiningSystem [S]
- [ ] Mapear clima → WeatherSystem [S]
- [ ] Mapear estaciones → SeasonSystem [S]
- [ ] Mapear tiempo → GameClock [S]
- [ ] Mapear viaje y descubrimiento → TravelManager/DiscoveryService [S]

## C. Service Locator y ciclo de vida (12)

- [ ] Diseñar ServiceRegistry (registro por interfaz) [M]
- [ ] Definir que los servicios se consultan por interface, no por nombre [S]
- [ ] Diseñar Bootstrap (autoload 0: registro + arranque) [M]
- [ ] Definir el orden de registro de servicios [S]
- [ ] Diseñar el flujo de carga de isla (SceneManager→World→chunks→carga diégetica) [M]
- [ ] Diseñar el flujo de cierre (autosave→flush→logs) [S]
- [ ] Definir la cola de trabajo pesado (ThreadPool + call_deferred) [M]
- [ ] Definir la comunicación síncrona liviana entre servicios vecinos [S]
- [ ] Definir la comunicación por eventos para cruzada [S]
- [ ] Definir el autosave por eventos acotados [S]
- [ ] Documentar que el progreso visual de carga es obligatorio (AGENTS §8) [S]
- [ ] Documentar el patrón MVP por dominio (View/Controller/Model) [S]

## D. GameState (alto nivel) (10)

- [ ] Diseñar la partición por dominio (meta, world, player, economy…) [S]
- [ ] Definir que los servicios mutan estado solo vía API pública [S]
- [ ] Definir que nada fuera de servicios de datos toca GameState [S]
- [ ] Definir versionado y migraciones por partición (detalle M59) [S]
- [ ] Definir settings del usuario fuera del GameState [S]
- [ ] Definir el guardado de diffs de chunks por isla [S]
- [ ] Definir flags de mundo consultables (reactividad NPC) [S]
- [ ] Definir fecha/estación/eventos en calendar state [S]
- [ ] Definir discovery state (islas/regiones) [S]
- [ ] Documentar la relación con M59 (diseño detallado) [S]

## E. EventBus por dominios (10)

- [ ] Diseñar el dominio `world` (chunk_modified, block_placed…) [S]
- [ ] Diseñar el dominio `economy` (currency_changed, purchase_done…) [S]
- [ ] Diseñar el dominio `inventory` (item_added, hotbar_selected…) [S]
- [ ] Diseñar el dominio `quest` (quest_started, prereq_met…) [S]
- [ ] Diseñar el dominio `npc` (moveln, friendship_level_up…) [S]
- [ ] Diseñar el dominio `calendar` (day_started, vessel_arrived…) [S]
- [ ] Diseñar el dominio `travel` (travel_started, island_loaded…) [S]
- [ ] Diseñar el dominio `ui` (hud, dialog — solo suscripción desde UI) [S]
- [ ] Definir que EventBus no importa dominios (solo tipos) [S]
- [ ] Definir payloads tipados (objetos de dominio) [S]

## F. Evaluación de alternativas (8)

- [ ] Evaluar ECS y descartarlo para v1.0 (motivo documentado) [S]
- [ ] Evaluar MVC/MVP por dominio (adoptado parcial) [S]
- [ ] Evaluar singleton puro (descartado → Service Registry) [S]
- [ ] Documentar el equivalente Godot de ScriptableObjects (Resources) [S]
- [ ] Documentar por qué no se hereda de un "BaseManager" gigante [S]
- [ ] Evaluar la composición sobre herencia (M05/AGENTS §9) [S]
- [ ] Documentar el trade-off de los 18 servicios vs menos/grandes [S]
- [ ] Documentar el trade-off ECS en caso de necesitarse post-v1.0 [S]

## G. Riesgos y anti-patterns (10)

- [ ] Documentar riesgo: bus de eventos lento → medición M61 [S]
- [ ] Documentar riesgo: dependencias circulares en la práctica → script de verificación [S]
- [ ] Documentar riesgo: GameState gigante → partición + versionado por dominio [S]
- [ ] Documentar riesgo: Bootstrap con lógica → solo registro [S]
- [ ] Prohibir acceso directo UI→Sistemas [S]
- [ ] Prohibir acceso directo a GameState desde gameplay [S]
- [ ] Prohibir servicios sin interface registrada [S]
- [ ] Prohibir eventos con payload abierto (dict) [S]
- [ ] Prohibir lógica de dominio dentro de escenas (.tscn) [S]
- [ ] Prohibir importar UI desde dominios (espiral inversa) [S]

## H. Calidad y verificación documental (12)

- [ ] Definir el script de verificación de capas (imports estáticos) [M]
- [ ] Definir el contrato de integración en 6 pasos [S]
- [ ] Verificar trazabilidad de los 27 puntos del plan maestro [S]
- [ ] Verificar coherencia con M04 (Godot) y M05 (patrones GDScript) [S]
- [ ] Verificar coherencia con Plan-de-produccion §3 (framework emisor→receptor en Templos) [S]
- [ ] Actualizar 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md con arquitectura [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el estado de M07 [S]
- [ ] Actualizar DOCUMENTACION/README.md con el componente 07 [S]
- [ ] Generar log de finalización y actualizar ULTIMO_NUMERO [S]
- [ ] Copiar plan-inicial → plan-actual (espejo vigente) [S]
- [ ] Documentar los pendientes con dueño (M1, M59, M61) [S]
- [ ] Registrar el criterio de salida del módulo (bootstrap mínimo en M1) [S]

## I. Edge cases e integración con el mundo (12)

- [ ] Documentar la comunicación VoxelWorld → ChunkManager (threading + deferred) [S]
- [ ] Documentar la integración del framework emisor→receptor con EventBus [S]
- [ ] Documentar el flujo de modificación de bloque → evento world → suscriptores (reacción de NPC) [S]
- [ ] Documentar el flujo de crafting → economía → tienda (transición de servicios) [S]
- [ ] Documentar el flujo de pesca/minería → inventario → quest [S]
- [ ] Documentar el flujo de viaje (travel_started → isla_loaded → autosave) [S]
- [ ] Documentar el edge case: evento emitido durante carga de escena (diferir) [S]
- [ ] Documentar el edge case: servicios que arrancan en distinto orden (bootstrap idempotente) [S]
- [ ] Documentar el edge case: reinicio del juego con servicios con estado en memoria [S]
- [ ] Documentar el edge case: dos sistemas escribiendo el mismo dominio de GameState (API única) [S]
- [ ] Documentar el edge case: tiempo real vs tiempo de juego (GameClock como única fuente) [S]
- [ ] Documentar el edge case: pérdida de red/archivos → ErrorHandler + estado de recuperación [S]

---

**Totales:** 102 ítems · Completados: 102 · Pendientes: 0 · No resueltos: 0.
**Nota:** los detalles de implementación (bootstrap real, verificación de capas, perf de eventos) se ejecutan en el hito M1 y quedan registrados en 04-Codigo.md §4 como pendientes con dueño.