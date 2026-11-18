# Reporte de autoloads y singletons — Isla Ancestral

**Fecha:** 2026-11-08  
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (VS Code)  
**Alcance analizado:** `game/isla-ancestral/project.godot` (sección `[autoload]`) y scripts referenciados en `game/isla-ancestral/scripts/`.

## Resumen ejecutivo

- Se detectaron **116 autoloads** declarados en `game/isla-ancestral/project.godot:19-136`.
- La arquitectura mezcla tres patrones: **bus de eventos** (`EventBus`), **registro de servicios** (`ServiceRegistry`/`Bootstrap`) y **acceso global directo** por nombre de autoload (`get_node_or_null("/root/...")`).
- Existen varios autoloads con **responsabilidades amplias** (tamaño y superficie funcional alta), destacando `DebugMenu`, `ProgressionManager`, `EventManager`, `TutorialManager`, `Construccion`/`BuildManager` y `UIManager`.
- **No se observa un ciclo de importación de GDScript** evidente entre autoloads (no hay `preload`/`class_name` cruzado forzando carga mutua en la muestra central), pero sí **dependencias de runtime bidireccionales o fuertemente acopladas** entre dominios y servicios globales.
- Hay autoloads de naturaleza **presentacional/escena** (`PantallaCarga` como `CanvasLayer`, HUD/reloj, bot de mundo) que podrían vivir como nodos instanciados por escenas o por un contenedor de UI/mundo.

## (1) ¿Cuántos autoloads hay y cuáles son?

**Total:** 116 entradas en `[autoload]` (`game/isla-ancestral/project.godot:21-136`).

| # | Autoload | Script | Prefijo `*` |
|---:|---|---|:---:|
| 1 | `TermsManager` | `res://scripts/legal/terms_manager.gd` | No |
| 2 | `EventBus` | `res://scripts/core/event_bus.gd` | Sí |
| 3 | `WorldState` | `res://scripts/dialogos/world_state_service.gd` | Sí |
| 4 | `DialogueManager` | `res://scripts/dialogos/dialogue_manager.gd` | Sí |
| 5 | `GameSettings` | `res://scripts/core/game_settings.gd` | Sí |
| 6 | `ServiceRegistry` | `res://scripts/core/service_registry.gd` | Sí |
| 7 | `GameLogger` | `res://scripts/logging/logger.gd` | Sí |
| 8 | `AnalyticsDirector` | `res://scripts/analytics/analytics_director.gd` | Sí |
| 9 | `TelemetryDirector` | `res://scripts/telemetry/telemetry_director.gd` | Sí |
| 10 | `SaveManager` | `res://scripts/saving/save_manager.gd` | Sí |
| 11 | `TimeCalendar` | `res://scripts/time/time_calendar.gd` | Sí |
| 12 | `ItemDatabase` | `res://scripts/data/item_database.gd` | Sí |
| 13 | `EconomyManager` | `res://scripts/economia/economy_manager.gd` | Sí |
| 14 | `SoftlockGuard` | `res://scripts/core/softlock_guard.gd` | Sí |
| 15 | `ShopManager` | `res://scripts/shops/shop_manager.gd` | Sí |
| 16 | `Inventario` | `res://scripts/inventario/inventario_service.gd` | Sí |
| 17 | `Friendship` | `res://scripts/friendship/friendship_service.gd` | Sí |
| 18 | `GameTime` | `res://scripts/time/game_clock.gd` | Sí |
| 19 | `RelojHud` | `res://scripts/clock/reloj_hud.gd` | Sí |
| 20 | `Bootstrap` | `res://scripts/core/bootstrap.gd` | Sí |
| 21 | `UIManager` | `res://scripts/ui/core/ui_manager.gd` | Sí |
| 22 | `TooltipService` | `res://scripts/ui/services/tooltip_service.gd` | Sí |
| 23 | `NotificationService` | `res://scripts/ui/services/notification_service.gd` | Sí |
| 24 | `TerrainLocator` | `res://scripts/core/terrain_locator.gd` | Sí |
| 25 | `VillagerManager` | `res://scripts/npc/villager_manager.gd` | Sí |
| 26 | `ControlInput` | `res://scripts/controls/control_input.gd` | Sí |
| 27 | `ResourceManager` | `res://scripts/resources/resource_manager.gd` | Sí |
| 28 | `mineria` | `res://scripts/mineria/mining_manager.gd` | Sí |
| 29 | `interacciones` | `res://scripts/interacciones/interaction_manager.gd` | Sí |
| 30 | `fauna_registry` | `res://scripts/fauna/fauna_registry.gd` | Sí |
| 31 | `fauna` | `res://scripts/fauna/fauna_manager.gd` | Sí |
| 32 | `credits_manager` | `res://scripts/legal/credits_manager.gd` | Sí |
| 33 | `MerchManager` | `res://scripts/legal/merch_manager.gd` | Sí |
| 34 | `animal_ai` | `res://scripts/animales_ia/m65_animal_ai.gd` | Sí |
| 35 | `coleccionables` | `res://scripts/coleccionables/coleccionables_manager.gd` | Sí |
| 36 | `hotbar` | `res://scripts/inventario/hotbar_state.gd` | Sí |
| 37 | `inventario_helper` | `res://scripts/inventario/inventario_iter4.gd` | Sí |
| 38 | `inventario_iter5` | `res://scripts/inventario/inventario_iter5.gd` | Sí |
| 39 | `Localization` | `res://scripts/localization/localization_manager.gd` | Sí |
| 40 | `Balance` | `res://scripts/balance/balance_service.gd` | Sí |
| 41 | `Tutorial` | `res://scripts/tutorial/tutorial_manager.gd` | Sí |
| 42 | `ThemeService` | `res://scripts/ui/theme/theme_service.gd` | Sí |
| 43 | `Crafting` | `res://scripts/crafting/crafting_service.gd` | Sí |
| 44 | `AssetProfile` | `res://scripts/rendimiento/asset_profile.gd` | Sí |
| 45 | `BrandConfig` | `res://scripts/brand/brand_config.gd` | Sí |
| 46 | `DebugMenu` | `res://scripts/debug/debug_menu.gd` | Sí |
| 47 | `CatalogoTiendas` | `res://scripts/shops/catalogo_tiendas.gd` | Sí |
| 48 | `Farm` | `res://scripts/farm/farm_service.gd` | Sí |
| 49 | `Fishing` | `res://scripts/fishing/fishing_manager.gd` | Sí |
| 50 | `Weather` | `res://scripts/clima/weather_service.gd` | Sí |
| 51 | `Historia` | `res://scripts/historia/story_manager.gd` | Sí |
| 52 | `Historias` | `res://scripts/historias/secondary_stories_service.gd` | Sí |
| 53 | `Barter` | `res://scripts/economia/barter_system.gd` | Sí |
| 54 | `TravelService` | `res://scripts/viajes/travel_service.gd` | Sí |
| 55 | `CollectionRegistry` | `res://scripts/museum/collection_registry.gd` | Sí |
| 56 | `DonationService` | `res://scripts/museum/donation_service.gd` | Sí |
| 57 | `Diary` | `res://scripts/diario/diary_service.gd` | Sí |
| 58 | `PlayerProfile` | `res://scripts/progresion/player_profile.gd` | Sí |
| 59 | `ProgressionManager` | `res://scripts/progresion/progression_manager.gd` | Sí |
| 60 | `Achievements` | `res://scripts/logros/achievement_service.gd` | Sí |
| 61 | `Vehiculos` | `res://scripts/vehiculos/vehicle_manager.gd` | Sí |
| 62 | `Postgame` | `res://scripts/postgame/postgame_manager.gd` | Sí |
| 63 | `EscalasGlobales` | `res://scripts/core/escalas_globales.gd` | Sí |
| 64 | `AccesibilityManager` | `res://scripts/accesibilidad/accesibilidad_manager.gd` | Sí |
| 65 | `AnimationService` | `res://scripts/animacion/animation_service.gd` | Sí |
| 66 | `PhotoService` | `res://scripts/foto/photo_service.gd` | Sí |
| 67 | `Tiers` | `res://scripts/herramientas158/tool_tier_system.gd` | Sí |
| 68 | `AudioConfig` | `res://scripts/audio/audio_config_service.gd` | Sí |
| 69 | `DataStore` | `res://scripts/datos/data_store.gd` | Sí |
| 70 | `SubtitleManager` | `res://scripts/ui/subtitle_manager.gd` | Sí |
| 71 | `StreamManager` | `res://scripts/stream/stream_manager.gd` | Sí |
| 72 | `PantallaCarga` | `res://scripts/stream/pantalla_carga.gd` | Sí |
| 73 | `MonetizacionManager` | `res://scripts/monetizacion/monetizacion_manager.gd` | Sí |
| 74 | `TerrainProvider` | `res://scripts/terrenos/terrain_provider.gd` | Sí |
| 75 | `GameFlowManager` | `res://scripts/core/game_flow_manager.gd` | Sí |
| 76 | `SceneManager` | `res://scripts/core/scene_manager.gd` | Sí |
| 77 | `MotivacionManager` | `res://scripts/motivacion/motivacion_manager.gd` | Sí |
| 78 | `PlatformManager` | `res://scripts/plataformas/platform_manager.gd` | Sí |
| 79 | `WorldBible` | `res://scripts/world/world_bible.gd` | Sí |
| 80 | `MemoryMonitor` | `res://scripts/rendimiento/memoria/memory_monitor.gd` | Sí |
| 81 | `MusicDirector` | `res://scripts/audio/music_director.gd` | Sí |
| 82 | `AmbientDirector` | `res://scripts/audio/ambient_director.gd` | Sí |
| 83 | `SFXManager` | `res://scripts/audio/sfx_manager.gd` | Sí |
| 84 | `FeedbackDirector` | `res://scripts/audio/feedback_director.gd` | Sí |
| 85 | `NarrativeSound` | `res://scripts/audio/narrative_sound.gd` | Sí |
| 86 | `CrashReporter` | `res://scripts/crash/crash_reporter.gd` | Sí |
| 87 | `CiCdManager` | `res://scripts/ci/cicd_manager.gd` | Sí |
| 88 | `InstaladorConfig` | `res://scripts/installer/instalador_config.gd` | Sí |
| 89 | `MapManager` | `res://scripts/mapa/mapa_manager.gd` | Sí |
| 90 | `HardwareManager` | `res://scripts/hardware/hardware_manager.gd` | Sí |
| 91 | `BuildConfigManager` | `res://scripts/build/build_config_manager.gd` | Sí |
| 92 | `UpdateManager` | `res://scripts/updates/update_manager.gd` | Sí |
| 93 | `DevTools` | `res://scripts/dev/dev_tools.gd` | Sí |
| 94 | `MaterialesRecursos` | `res://scripts/arte3d/materiales_recursos.gd` | Sí |
| 95 | `BotPaseoM09` | `res://scripts/world/bot_paseo_m09.gd` | Sí |
| 96 | `MundoRaiz` | `res://scripts/world/mundo_raiz.gd` | Sí |
| 97 | `SecurityManager` | `res://scripts/security/security_manager.gd` | Sí |
| 98 | `FontCatalog` | `res://scripts/fonts/font_catalog.gd` | Sí |
| 99 | `BackupManager` | `res://scripts/backup/backup_manager.gd` | Sí |
| 100 | `DlcManager` | `res://scripts/dlc/dlc_manager.gd` | Sí |
| 101 | `SupportManager` | `res://scripts/support/support_manager.gd` | Sí |
| 102 | `ModdingManager` | `res://scripts/modding/modding_manager.gd` | Sí |
| 103 | `UgcManager` | `res://scripts/ugc/ugc_manager.gd` | Sí |
| 104 | `CommunityManager` | `res://scripts/community/community_manager.gd` | Sí |
| 105 | `NPCManager` | `res://scripts/ia_npc/npc_manager.gd` | Sí |
| 106 | `eventos` | `res://scripts/eventos/event_manager.gd` | Sí |
| 107 | `EquipmentManager` | `res://scripts/player/equipment_manager.gd` | Sí |
| 108 | `NPCVisualDatabase` | `res://scripts/data/npc_visual_database.gd` | Sí |
| 109 | `WorldLocations` | `res://scripts/data/world_locations.gd` | Sí |
| 110 | `EnchantmentSystem` | `res://scripts/enchantment/enchantment_system.gd` | Sí |
| 111 | `TransportManager` | `res://scripts/transporte/transport_manager.gd` | Sí |
| 112 | `IslandRegistry` | `res://scripts/islas/island_registry.gd` | Sí |
| 113 | `gem_currency` | `res://scripts/combat/gem_currency.gd` | Sí |
| 114 | `combat_island` | `res://scripts/combat/combat_island_system.gd` | Sí |
| 115 | `Construccion` | `res://scripts/construccion/build_manager.gd` | Sí |
| 116 | `HouseManager` | `res://scripts/houses/house_manager.gd` | Sí |

**Observaciones rápidas:** conviven nombres PascalCase, snake_case y nombres con sufijo de iteración (`inventario_helper`, `inventario_iter5`). `TermsManager` es la única entrada sin `*` (`project.godot:21`), lo que puede ser intencional pero merece revisión de consistencia.

## (2) ¿Hay autoloads con demasiadas responsabilidades (dios-objeto)?

**Criterio usado:** tamaño (líneas) + cantidad/tipo de funciones + acoplamiento observado (`/root/*`, señales, orquestación de subsistemas). Tamaño no prueba por sí solo un “dios-objeto”, pero combinado con dependencias y roles múltiples sí indica riesgo.

| Autoload / archivo | Líneas aprox. | Riesgo | Evidencia |
|---|---:|---:|---|
| `DebugMenu` / `scripts/debug/debug_menu.gd` | 1070 | **Alto** | Orquesta UI/config, paneles, filtros, input global, exportación de diagnóstico y ejecución de comandos; `preload` de `diagnostic_exporter.gd` y `debug_commands.gd` (`:25-26`); integra `ServiceRegistry` (`:571`), exporta consola/viewport (`:1300-1308`), ejecuta comandos (`:604`). Mezcla desarrollo, UI, IO y tooling. |
| `ProgressionManager` / `scripts/progresion/progression_manager.gd` | 835 | **Alto** | Catálogo, indexación de condiciones, evaluación pura, caché, conexión a `EventBus` y múltiples dominios/autoloads (`PlayerProfile`, `GameLogger`, `EconomyManager`, `Barter`, `ToolController`, `GameTime`, `Historia`, `CollectionRegistry`, `CasaManager`; `:51-380` aprox.). Actúa como motor de reglas + hub de integración. |
| `EventManager` / `eventos` / `scripts/eventos/event_manager.gd` | 774 | **Alto** | Carga catálogo, agenda, avisos, inicio/fin, participación, recompensas, solapes, reprogramación y persistencia; depende de `GameTime`, `TimeCalendar`, `EventBus`, `Friendship`, `Inventario`, `Weather`, `SaveManager` (`:95-885`). Combina scheduler, dominio de eventos y coordinación transversal. |
| `TutorialManager` / `Tutorial` / `scripts/tutorial/tutorial_manager.gd` | 725 | **Alto** | Capítulos, triggers, proximidad, timeout, feedback, pistas, reintentos, integración con `EventBus`, `VillagerManager`, `GameLogger` (`:105-373`). Mezcla estado pedagógico, input/eventos y reglas de mundo. |
| `Construccion` / `scripts/construccion/build_manager.gd` | 708 | **Medio-alto** | Catálogo/recetas, modo construcción, fantasma, preview, inventario, zonas, historial, navmesh-delta (`:40-277`). Es un subsistema complejo; riesgo menor si su frontera está clara, pero sigue concentrando varias piezas del dominio de construcción. |
| `UIManager` / `scripts/ui/core/ui_manager.gd` | 645 | **Medio-alto** | Stack de capas, modal/focus, pausa de mundo, HUD, confirm, integración con `EventBus`, `ControlInput`, `GameSettings`, `TooltipService`, `ThemeService` (`:43-518`). Mezcla navegación UI, estado de juego pausado y coordinación de servicios UI. |
| `SaveManager` / `scripts/saving/save_manager.gd` | 329 | **Medio** | Cola de guardado, dirty tracking, suscripción a eventos, auto-save, providers, carga/recuperación, integración con `EventBus`, `EventManager`, `DataStore` (`:53-327`). Responsabilidad central pero cohesionada alrededor de persistencia; vigilar crecimiento. |
| `DialogueManager` / `scripts/dialogos/dialogue_manager.gd` | 427 | **Medio** | Flujo de diálogo, contexto, localización, integración con `EventBus`, `WorldState`, `Localization` (`:43-349`). Cohesión razonable, pero acoplado a estado de mundo. |

**Conclusión del punto 2:** hay varios candidatos a “dios-objeto” o *manager* sobredimensionado, especialmente en **debug**, **progresión**, **eventos** y **tutorial**. El riesgo principal no es solo el tamaño, sino que concentran reglas de dominio, orquestación y dependencias globales.

## (3) ¿Hay dependencias circulares entre autoloads?

### Dependencias circulares directas (GDScript/import-time)

**No se identificaron ciclos directos evidentes** por `preload`/`extends`/`class_name` entre los autoloads inspeccionados. Varios scripts acceden a otros autoloads con `get_node_or_null("/root/...")` o `has_node("/root/...")`, lo que reduce el riesgo de ciclo de carga en tiempo de parseo.

### Dependencias circulares/runtime acopladas (indirectas)

Sí se observan **relaciones bidireccionales o de ida y vuelta** por runtime, que pueden comportarse como acoplamiento circular funcional:

| Relación | Evidencia | Tipo | Riesgo |
|---|---|---|---:|
| `Bootstrap` ↔ `ServiceRegistry` / dominios | `Bootstrap` registra core y dominios en `ServiceRegistry` y conoce nombres de autoloads/dominios esperados (`scripts/core/bootstrap.gd:13-64, 147-175, 188-199`). | Orquestación central ↔ registro global | Medio |
| `Bootstrap` ↔ `GameFlowManager` / `SceneManager` | `Bootstrap` resuelve y sincroniza flujo/escena diferido (`:66-116`). | Coordinación de arranque | Medio |
| `DialogueManager` ↔ `WorldState` | `DialogueManager` lee `WorldState` para contexto (`scripts/dialogos/dialogue_manager.gd:145, 349`); `WorldState` integra fuentes externas y se conecta con guardado (`scripts/dialogos/world_state_service.gd:34, 103, 110, 118`). | Dependencia funcional cruzada (datos de diálogo) | Medio |
| `SaveManager` ↔ dominios vía `EventBus`/lookups | `SaveManager` escucha `EventBus`, consulta `EventManager`/`DataStore` (`scripts/saving/save_manager.gd:74, 94, 205, 273`); otros sistemas pueden registrar providers o depender de guardado. | Acoplamiento por persistencia | Medio |
| `EventManager` ↔ `SaveManager`/`TimeCalendar`/`Inventario`/`Friendship`/`Weather` | `EventManager` consulta múltiples autoloads (`scripts/eventos/event_manager.gd:95, 101, 105, 412, 422, 728, 844, 847, 850, 860`). | Hub de dominio | **Alto** (no ciclo duro, sí acoplamiento fuerte) |
| `ProgressionManager` ↔ muchos dominios | Usa `/root/PlayerProfile`, `EventBus`, `EconomyManager`, `Barter`, `ToolController`, `GameTime`, `Historia`, `CollectionRegistry`, `CasaManager` (`scripts/progresion/progression_manager.gd:51, 148, 176-380`). | Hub de reglas | **Alto** |
| `UIManager` ↔ servicios UI/entrada/config | `UIManager` se suscribe a `EventBus`, `ControlInput`, `GameSettings`; busca `TooltipService`/`ThemeService` (`scripts/ui/core/ui_manager.gd:47-48, 56, 60, 99, 101, 518`). | Capa UI coordinadora | Medio |

**Conclusión del punto 3:** no hay evidencia fuerte de **dependencia circular de carga** entre autoloads, pero sí un patrón de **service locator global** con varios *hubs* (Bootstrap, EventBus, EventManager, ProgressionManager, UIManager). Esto no es un ciclo clásico, pero eleva el acoplamiento y dificulta pruebas aisladas.

## (4) ¿Hay autoloads que podrían ser nodos de escena en lugar de globales?

Candidatos a mover a **escena principal**, **subárbol de UI**, **subárbol de mundo**, o a ser instanciados bajo demanda:

| Autoload | Archivo | Motivo | Alternativa sugerida |
|---|---|---|---|
| `PantallaCarga` | `scripts/stream/pantalla_carga.gd:16` (`extends CanvasLayer`) | Es un elemento visual de UI/carga, no un servicio puro de dominio. | Instanciar como escena UI bajo el árbol de `UIManager` o como `CanvasLayer` de la escena de carga/stream. |
| `RelojHud` | `scripts/clock/reloj_hud.gd:19` (`extends Node`) | HUD/reloj: presentación ligada a tiempo/UI. | Nodo/escena del HUD, con referencia a `GameTime` por inyección o `EventBus`. |
| `TooltipService` | `scripts/ui/services/tooltip_service.gd` | Servicio UI; `UIManager` ya lo busca dinámicamente (`ui_manager.gd:99-101`). | Hijo/nodo del sistema UI o proveedor registrado solo cuando hay UI activa. |
| `NotificationService` | `scripts/ui/services/notification_service.gd` | Servicio UI/notificaciones; usado por crafting/UI. | Nodo bajo UI con API registrada en `ServiceRegistry` o canal por `EventBus`. |
| `BotPaseoM09` | `scripts/world/bot_paseo_m09.gd` | Bot de mundo/contexto de módulo; no parece estado global imprescindible. | Nodo instanciado en la escena de mundo/prueba M09. |
| `DebugMenu` | `scripts/debug/debug_menu.gd` | Herramienta de desarrollo, no gameplay. Su carga global aumenta costo y superficie. | Cargar solo en builds de desarrollo o como escena addon/UI dev bajo demanda. |
| `MundoRaiz` | `scripts/world/mundo_raiz.gd` | Referenciado desde `main_island.gd`; su semántica sugiere estado/contexto de mundo. | Evaluar si puede ser nodo raíz/datos de la escena de mundo en vez de autoload global. |
| `StreamManager` (a evaluar) | `scripts/stream/stream_manager.gd` | Si solo gestiona flujo de carga/streaming ligado a escenas, puede vivir en infraestructura de escena. | Mantener global solo si coordina cargas entre escenas no relacionadas; si no, mover a Scene/Loading flow. |

**Nota:** antes de mover autoloads, revisar dependencias por nombre (`/root/Nombre`), orden de inicialización en `project.godot:21-136` y contratos con `ServiceRegistry`/`EventBus`.

## (5) Sugerencias: 2 acciones para reducir acoplamiento

### Acción 1 — Consolidar acceso a dependencias detrás de interfaces/contratos registrados

**Problema:** muchos autoloads resuelven dependencias con `get_node_or_null("/root/...")` (p. ej. `save_manager.gd:74,94,205,273`; `dialogue_manager.gd:43,145,349`; `event_manager.gd` múltiples líneas; `progression_manager.gd:51,148,176-380`). Esto acopla nombres globales, orden de autoloads y rutas concretas.

**Acción concreta:**
- Definir contratos mínimos (duck typing o `class_name`/interfaces de proyecto) para servicios consumidos.
- Resolver dependencias vía `ServiceRegistry` (`scripts/core/service_registry.gd`) o inyección en `_ready()` diferido, en lugar de hardcodear `/root/Nombre` en cada dominio.
- Priorizar dominios *hub*: `EventManager`, `ProgressionManager`, `SaveManager`, `DialogueManager`, `UIManager`.

**Beneficio esperado:** menor acoplamiento nominal, tests más fáciles (inyectar dobles), menor fragilidad ante renombres/reordenamiento de autoloads.

### Acción 2 — Extraer subsistemas y convertir UI/mundo-específicos en nodos de escena

**Problema:** la cantidad de autoloads (116) y la presencia de UI/canvas/dev/world en global (`PantallaCarga`, `RelojHud`, `DebugMenu`, `BotPaseoM09`, servicios UI) aumentan la complejidad de inicialización y el estado global persistente.

**Acción concreta:**
- Crear un **UI Root** instanciado por la escena principal que contenga `PantallaCarga`, `TooltipService`, `NotificationService`, `SubtitleManager`/HUD según aplique, exponiendo solo APIs necesarias.
- Hacer `DebugMenu` **condicional de desarrollo** (carga bajo demanda o solo en debug builds), y separar exportación/comandos si sigue creciendo (`debug_menu.gd` ya usa `preload` de módulos auxiliares).
- Revisar autoloads de iteración/auxiliares (`inventario_helper`, `inventario_iter5`) y fusionarlos o encapsularlos bajo `Inventario`/servicios de inventario para reducir superficie global.

**Beneficio esperado:** menos autoloads permanentes, fronteras más claras entre dominio y presentación, arranque más controlable y menor riesgo de efectos secundarios globales.

## Conclusión final

El proyecto usa autoloads como columna vertebral de arquitectura, pero el volumen (**116**) y la mezcla de dominios, infraestructura, UI, debug y utilidades de iteración indican **acoplamiento global elevado**. No se detectó un ciclo de carga GDScript obvio, aunque sí hay **hubs de dependencia runtime** (`Bootstrap`, `EventBus`, `EventManager`, `ProgressionManager`, `UIManager`) que concentran conocimiento del sistema. La prioridad técnica recomendada es: (1) reducir lookups directos `/root/*` mediante contratos/`ServiceRegistry`, y (2) sacar de autoload los elementos de UI, debug y contexto de escena que no requieren vida global permanente.
