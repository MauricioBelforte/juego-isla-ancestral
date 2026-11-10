# Reporte: Autoloads / Singletons en `game/isla-ancestral/scripts`

**Fecha:** 2026-11-09  
**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Alcance:** `game/isla-ancestral/project.godot` (sección `[autoload]`) y scripts `.gd` referenciados como autoloads bajo `res://scripts/`.

## Metodología

- Fuente de verdad de autoloads: `game/isla-ancestral/project.godot:15-131` (bloque `[autoload]`).
- Conteo de autoloads de script: entradas con ruta `res://scripts/...` en `project.godot` (**116 autoloads**).
- Acoplamiento/dependencias: análisis estático por búsqueda de referencias `NombreAutoload.` dentro del código de cada autoload registrado. **No** incluye dependencias por `get_node("/root/...")`, señales conectadas dinámicamente desde escenas externas, ni llamadas indirectas vía `ServiceRegistry`.
- Líneas: conteo de líneas del archivo `.gd` referenciado.

## 1) ¿Cuántos autoloads hay y cuáles son?

**Total:** 116 autoloads apuntando a scripts en `game/isla-ancestral/scripts/` (declarados en `game/isla-ancestral/project.godot:16-131`).

| Autoload | Script | Líneas |
|---|---|---:|
| `TermsManager` | `scripts/legal/terms_manager.gd` | 72 |
| `EventBus` | `scripts/core/event_bus.gd` | 199 |
| `WorldState` | `scripts/dialogos/world_state_service.gd` | 132 |
| `DialogueManager` | `scripts/dialogos/dialogue_manager.gd` | 427 |
| `GameSettings` | `scripts/core/game_settings.gd` | 81 |
| `ServiceRegistry` | `scripts/core/service_registry.gd` | 75 |
| `GameLogger` | `scripts/logging/logger.gd` | 384 |
| `AnalyticsDirector` | `scripts/analytics/analytics_director.gd` | 232 |
| `TelemetryDirector` | `scripts/telemetry/telemetry_director.gd` | 533 |
| `SaveManager` | `scripts/saving/save_manager.gd` | 373 |
| `TimeCalendar` | `scripts/time/time_calendar.gd` | 274 |
| `ItemDatabase` | `scripts/data/item_database.gd` | 140 |
| `EconomyManager` | `scripts/economia/economy_manager.gd` | 227 |
| `SoftlockGuard` | `scripts/core/softlock_guard.gd` | 178 |
| `ShopManager` | `scripts/shops/shop_manager.gd` | 346 |
| `Inventario` | `scripts/inventario/inventario_service.gd` | 444 |
| `Friendship` | `scripts/friendship/friendship_service.gd` | 708 |
| `GameTime` | `scripts/time/game_clock.gd` | 263 |
| `RelojHud` | `scripts/clock/reloj_hud.gd` | 120 |
| `Bootstrap` | `scripts/core/bootstrap.gd` | 223 |
| `UIManager` | `scripts/ui/core/ui_manager.gd` | 645 |
| `TooltipService` | `scripts/ui/services/tooltip_service.gd` | 235 |
| `NotificationService` | `scripts/ui/services/notification_service.gd` | 203 |
| `TerrainLocator` | `scripts/core/terrain_locator.gd` | 73 |
| `VillagerManager` | `scripts/npc/villager_manager.gd` | 777 |
| `ControlInput` | `scripts/controls/control_input.gd` | 388 |
| `ResourceManager` | `scripts/resources/resource_manager.gd` | 367 |
| `mineria` | `scripts/mineria/mining_manager.gd` | 768 |
| `interacciones` | `scripts/interacciones/interaction_manager.gd` | 340 |
| `fauna_registry` | `scripts/fauna/fauna_registry.gd` | 208 |
| `fauna` | `scripts/fauna/fauna_manager.gd` | 133 |
| `credits_manager` | `scripts/legal/credits_manager.gd` | 330 |
| `MerchManager` | `scripts/legal/merch_manager.gd` | 296 |
| `animal_ai` | `scripts/animales_ia/m65_animal_ai.gd` | 351 |
| `coleccionables` | `scripts/coleccionables/coleccionables_manager.gd` | 231 |
| `hotbar` | `scripts/inventario/hotbar_state.gd` | 117 |
| `inventario_helper` | `scripts/inventario/inventario_iter4.gd` | 336 |
| `inventario_iter5` | `scripts/inventario/inventario_iter5.gd` | 344 |
| `Localization` | `scripts/localization/localization_manager.gd` | 377 |
| `Balance` | `scripts/balance/balance_service.gd` | 180 |
| `Tutorial` | `scripts/tutorial/tutorial_manager.gd` | 814 |
| `ThemeService` | `scripts/ui/theme/theme_service.gd` | 66 |
| `Crafting` | `scripts/crafting/crafting_service.gd` | 459 |
| `AssetProfile` | `scripts/rendimiento/asset_profile.gd` | 158 |
| `BrandConfig` | `scripts/brand/brand_config.gd` | 46 |
| `DebugMenu` | `scripts/debug/debug_menu.gd` | 1308 |
| `CatalogoTiendas` | `scripts/shops/catalogo_tiendas.gd` | 168 |
| `Farm` | `scripts/farm/farm_service.gd` | 515 |
| `Fishing` | `scripts/fishing/fishing_manager.gd` | 496 |
| `Weather` | `scripts/clima/weather_service.gd` | 230 |
| `Historia` | `scripts/historia/story_manager.gd` | 255 |
| `Historias` | `scripts/historias/secondary_stories_service.gd` | 470 |
| `Barter` | `scripts/economia/barter_system.gd` | 214 |
| `TravelService` | `scripts/viajes/travel_service.gd` | 380 |
| `CollectionRegistry` | `scripts/museum/collection_registry.gd` | 364 |
| `DonationService` | `scripts/museum/donation_service.gd` | 95 |
| `Diary` | `scripts/diario/diary_service.gd` | 407 |
| `PlayerProfile` | `scripts/progresion/player_profile.gd` | 117 |
| `ProgressionManager` | `scripts/progresion/progression_manager.gd` | 959 |
| `Achievements` | `scripts/logros/achievement_service.gd` | 622 |
| `Vehiculos` | `scripts/vehiculos/vehicle_manager.gd` | 203 |
| `Postgame` | `scripts/postgame/postgame_manager.gd` | 283 |
| `EscalasGlobales` | `scripts/core/escalas_globales.gd` | 56 |
| `AccesibilityManager` | `scripts/accesibilidad/accesibilidad_manager.gd` | 461 |
| `AnimationService` | `scripts/animacion/animation_service.gd` | 134 |
| `PhotoService` | `scripts/foto/photo_service.gd` | 406 |
| `Tiers` | `scripts/herramientas158/tool_tier_system.gd` | 360 |
| `AudioConfig` | `scripts/audio/audio_config_service.gd` | 309 |
| `DataStore` | `scripts/datos/data_store.gd` | 650 |
| `SubtitleManager` | `scripts/ui/subtitle_manager.gd` | 359 |
| `StreamManager` | `scripts/stream/stream_manager.gd` | 527 |
| `PantallaCarga` | `scripts/stream/pantalla_carga.gd` | 186 |
| `MonetizacionManager` | `scripts/monetizacion/monetizacion_manager.gd` | 134 |
| `TerrainProvider` | `scripts/terrenos/terrain_provider.gd` | 106 |
| `GameFlowManager` | `scripts/core/game_flow_manager.gd` | 73 |
| `SceneManager` | `scripts/core/scene_manager.gd` | 160 |
| `MotivacionManager` | `scripts/motivacion/motivacion_manager.gd` | 180 |
| `PlatformManager` | `scripts/plataformas/platform_manager.gd` | 118 |
| `WorldBible` | `scripts/world/world_bible.gd` | 73 |
| `MemoryMonitor` | `scripts/rendimiento/memoria/memory_monitor.gd` | 641 |
| `MusicDirector` | `scripts/audio/music_director.gd` | 101 |
| `AmbientDirector` | `scripts/audio/ambient_director.gd` | 72 |
| `SFXManager` | `scripts/audio/sfx_manager.gd` | 400 |
| `FeedbackDirector` | `scripts/audio/feedback_director.gd` | 83 |
| `NarrativeSound` | `scripts/audio/narrative_sound.gd` | 243 |
| `CrashReporter` | `scripts/crash/crash_reporter.gd` | 94 |
| `CiCdManager` | `scripts/ci/cicd_manager.gd` | 298 |
| `InstaladorConfig` | `scripts/installer/instalador_config.gd` | 81 |
| `MapManager` | `scripts/mapa/mapa_manager.gd` | 304 |
| `HardwareManager` | `scripts/hardware/hardware_manager.gd` | 92 |
| `BuildConfigManager` | `scripts/build/build_config_manager.gd` | 74 |
| `UpdateManager` | `scripts/updates/update_manager.gd` | 92 |
| `DevTools` | `scripts/dev/dev_tools.gd` | 77 |
| `MaterialesRecursos` | `scripts/arte3d/materiales_recursos.gd` | 183 |
| `BotPaseoM09` | `scripts/world/bot_paseo_m09.gd` | 243 |
| `MundoRaiz` | `scripts/world/mundo_raiz.gd` | 35 |
| `SecurityManager` | `scripts/security/security_manager.gd` | 243 |
| `FontCatalog` | `scripts/fonts/font_catalog.gd` | 100 |
| `BackupManager` | `scripts/backup/backup_manager.gd` | 407 |
| `DlcManager` | `scripts/dlc/dlc_manager.gd` | 343 |
| `SupportManager` | `scripts/support/support_manager.gd` | 134 |
| `ModdingManager` | `scripts/modding/modding_manager.gd` | 125 |
| `UgcManager` | `scripts/ugc/ugc_manager.gd` | 63 |
| `CommunityManager` | `scripts/community/community_manager.gd` | 54 |
| `NPCManager` | `scripts/ia_npc/npc_manager.gd` | 385 |
| `eventos` | `scripts/eventos/event_manager.gd` | 901 |
| `EquipmentManager` | `scripts/player/equipment_manager.gd` | 392 |
| `NPCVisualDatabase` | `scripts/data/npc_visual_database.gd` | 56 |
| `WorldLocations` | `scripts/data/world_locations.gd` | 343 |
| `EnchantmentSystem` | `scripts/enchantment/enchantment_system.gd` | 151 |
| `TransportManager` | `scripts/transporte/transport_manager.gd` | 702 |
| `IslandRegistry` | `scripts/islas/island_registry.gd` | 472 |
| `gem_currency` | `scripts/combat/gem_currency.gd` | 108 |
| `combat_island` | `scripts/combat/combat_island_system.gd` | 212 |
| `Construccion` | `scripts/construccion/build_manager.gd` | 803 |
| `HouseManager` | `scripts/houses/house_manager.gd` | 338 |

**Observación:** hay 116 singletons globales. El orden de carga en `project.godot` importa; varios sistemas dependen de otros ya inicializados (p. ej. `Bootstrap` usa `get_node_or_null("/root/ServiceRegistry")` en `scripts/core/bootstrap.gd:139-141, 150-151, 174-175, 184-185`).

## 2) ¿Hay acoplamiento fuerte entre autoloads?

Sí. El acoplamiento fuerte aparece en dos formas: **dependencias directas por nombre global** y **autocomposición de responsabilidades**.

| Autoload | Script | Referencias directas a otros autoloads (detectadas) | Nº |
|---|---|---|---:|
| `TelemetryDirector` | `scripts/telemetry/telemetry_director.gd` | `ServiceRegistry`, `GameLogger`, `AnalyticsDirector`, `eventos` | 4 |
| `eventos` | `scripts/eventos/event_manager.gd` | `EventBus`, `TimeCalendar`, `GameTime`, `Weather` | 4 |
| `Achievements` | `scripts/logros/achievement_service.gd` | `EventBus`, `SaveManager`, `Fishing`, `ProgressionManager` | 4 |
| `Balance` | `scripts/balance/balance_service.gd` | `Friendship`, `Crafting`, `Fishing` | 3 |
| `ProgressionManager` | `scripts/progresion/progression_manager.gd` | `EventBus`, `Barter` | 2 |
| `Crafting` | `scripts/crafting/crafting_service.gd` | `Inventario`, `GameTime` | 2 |
| `Inventario` | `scripts/inventario/inventario_service.gd` | `Crafting` | 1 (parte de ciclo) |
| `DebugMenu` | `scripts/debug/debug_menu.gd` | `GameLogger`, `Weather` | 2 |
| `VillagerManager` | `scripts/npc/villager_manager.gd` | `EventBus` | 1 |
| `Friendship` | `scripts/friendship/friendship_service.gd` | `EventBus`, `VillagerManager` | 2 |

**Casos concretos (líneas):**
- `scripts/core/event_bus.gd:11-12, 194` documenta/usa dominio de pesca (`fishing`/`Fishing`) dentro del bus global; además el grafo estático detecta referencia `EventBus -> Fishing` y señales de pesca se emiten desde `scripts/fishing/fishing_manager.gd:211, 298`.
- `scripts/fishing/fishing_manager.gd:469` menciona integración directa con `DonationService.donate(...)`.
- `scripts/museum/donation_service.gd:16` depende conceptualmente de diario/eventos y el grafo detecta `DonationService -> EventBus, Diary`.
- `scripts/eventos/event_manager.gd:100, 108` se suscribe a `GameTime.dia_cambio` y `EventBus.weather.clima_cambio`.
- `scripts/time/game_clock.gd:142, 153-154` expone/utiliza estado temporal global consumido por otros dominios.
- `scripts/crafting/crafting_service.gd:79, 84, 196` lee/manipula tiempo e inventario; `scripts/inventario/inventario_service.gd:22, 295` menciona consumo de pergamino por `Crafting` y operaciones de equipamiento.
- `scripts/dialogos/world_state_service.gd:17` consulta amistad desde `Friendship.get_nivel`; `scripts/friendship/friendship_service.gd:9-12` emite eventos NPC en `EventBus`.

**Conclusión parcial:** el acoplamiento es moderado-alto en dominios de gameplay (inventario, crafting, amistad, eventos, pesca, progresión) y alto en infraestructura transversal (`TelemetryDirector`, `eventos`, `DebugMenu`).

## 3) ¿Hay dependencias circulares?

Sí, se detectan **3 ciclos** por referencias directas entre autoloads:

1. **Ciclo directo (2 nodos):** `Crafting -> Inventario -> Crafting`  
   - `scripts/crafting/crafting_service.gd` referencia `Inventario` y `GameTime`.  
   - `scripts/inventario/inventario_service.gd` referencia `Crafting` (p. ej. consumo de pergamino, `scripts/inventario/inventario_service.gd:22`).  
   - Riesgo: orden de inicialización, dificultad para pruebas aisladas y cambios en cadena.

2. **Ciclo de 3 nodos:** `DonationService -> EventBus -> Fishing -> DonationService`  
   - `scripts/museum/donation_service.gd` usa `EventBus`/`Diary` (grafo: `EventBus`, `Diary`).  
   - `scripts/core/event_bus.gd` expone dominio `fishing` y contiene acoplamiento conceptual/documental con pesca (`scripts/core/event_bus.gd:194`); el grafo estático marca `EventBus -> Fishing`.  
   - `scripts/fishing/fishing_manager.gd` emite en `EventBus.fishing.*` (`:211`, `:298`) y menciona `DonationService.donate(...)` (`:469`).  
   - Riesgo: EventBus deja de ser un bus neutro si depende o conoce dominios concretos; el ciclo mezcla infraestructura y gameplay.

3. **Ciclo directo (2 nodos):** `GameTime -> eventos -> GameTime`  
   - `scripts/time/game_clock.gd:142` gestiona eventos temporales; `scripts/eventos/event_manager.gd:100` se suscribe a `GameTime.dia_cambio`.  
   - El grafo también detecta `eventos -> EventBus, TimeCalendar, GameTime, Weather`.  
   - Riesgo: cambios en reloj/calendario pueden romper agenda de eventos y viceversa.

**Nota:** `ServiceRegistry -> Bootstrap` aparece en el grafo por referencia de código, pero `Bootstrap` no figura como autoload registrado (es script de arranque/infra); no debe tratarse como ciclo autoload-autoload sin verificar su montaje real. `Bootstrap` accede a `ServiceRegistry` vía `/root/ServiceRegistry` (`scripts/core/bootstrap.gd:139-141`).

## 4) ¿Hay autoloads con demasiadas responsabilidades?

Sí. Indicadores: tamaño elevado, múltiples dominios, o rol transversal con muchas dependencias.

| Autoload | Script | Líneas | Señales de responsabilidad excesiva |
|---|---|---:|---|
| `DebugMenu` | `scripts/debug/debug_menu.gd` | 1308 | Superficie de depuración muy grande; riesgo de convertirse en “god object” de diagnóstico/editor/runtime. |
| `ProgressionManager` | `scripts/progresion/progression_manager.gd` | 959 | Progresión global; depende de `EventBus` y `Barter`; probable orquestación de múltiples sistemas. |
| `eventos` | `scripts/eventos/event_manager.gd` | 901 | Agenda, clima, tiempo y bus; 4 dependencias directas (`EventBus`, `TimeCalendar`, `GameTime`, `Weather`). Alto riesgo de acoplamiento temporal. |
| `Tutorial` | `scripts/tutorial/tutorial_manager.gd` | 814 | Flujo de onboarding potencialmente extenso; depende de `eventos`. |
| `Construccion` | `scripts/construccion/build_manager.gd` | 803 | Construcción completa en un único singleton. |
| `VillagerManager` | `scripts/npc/villager_manager.gd` | 777 | Gestión NPC/aldeanos centralizada. |
| `mineria` | `scripts/mineria/mining_manager.gd` | 768 | Dominio de minería con integración a inventario. |
| `TransportManager` | `scripts/transporte/transport_manager.gd` | 702 | Transporte global; depende de `Friendship`. |
| `Friendship` | `scripts/friendship/friendship_service.gd` | 708 | Amistad, regalos, cumpleaños/cartas y eventos NPC (`scripts/friendship/friendship_service.gd:9-12`). |
| `DataStore` | `scripts/datos/data_store.gd` | 650 | Almacenamiento/datos globales; nombre sugiere responsabilidad amplia. |
| `UIManager` | `scripts/ui/core/ui_manager.gd` | 645 | Coordinación UI central; depende de `GameTime`. |
| `MemoryMonitor` | `scripts/rendimiento/memoria/memory_monitor.gd` | 641 | Monitoreo de memoria/rendimiento; tamaño alto para un monitor. |
| `Achievements` | `scripts/logros/achievement_service.gd` | 622 | Escucha/procesa eventos de varios dominios (`EventBus`, `SaveManager`, `Fishing`, `ProgressionManager`). |
| `TelemetryDirector` | `scripts/telemetry/telemetry_director.gd` | 533 | Telemetría con dependencias a servicios, logger, analytics y eventos. |

**Umbral práctico usado:** >500 líneas o >3 dependencias directas a otros autoloads como señal de revisión. No implica defecto automático, pero sí costo alto de mantenimiento.

## 5) Sugerencias de mejora (2)

### Mejora 1: Romper ciclos con contratos/eventos neutros y dependencias inyectadas

**Objetivo:** eliminar los ciclos `Crafting<->Inventario`, `DonationService->EventBus->Fishing->DonationService` y `GameTime<->eventos`.

**Acciones concretas:**
- `Inventario` (`scripts/inventario/inventario_service.gd`) no debe llamar/depender de `Crafting` para consumir pergaminos; publicar un evento de uso de ítem (`item_used`/`scroll_used`) en `EventBus` y que `Crafting` se suscriba. Revisar `scripts/inventario/inventario_service.gd:22`.
- `Crafting` (`scripts/crafting/crafting_service.gd`) puede recibir una interfaz/adapter de inventario o usar señales para operaciones que hoy requieran conocimiento bidireccional.
- `EventBus` (`scripts/core/event_bus.gd`) debe permanecer neutral: evitar referencias/documentación ejecutable acoplada a dominios concretos como `Fishing`. Revisar `scripts/core/event_bus.gd:194` y las emisiones/consumos cruzados con `scripts/fishing/fishing_manager.gd:211,298,469`.
- `DonationService` (`scripts/museum/donation_service.gd:16`) debe depender solo de contratos de donación/diario; la integración con pesca debe ocurrir en un controlador de gameplay o por eventos, no mediante referencias mutuas.
- Separar “reloj/calendario” de “agenda de eventos”: `eventos` puede consumir ticks/señales, pero `GameTime` no debería depender de la capa de agenda (`scripts/eventos/event_manager.gd:100`, `scripts/time/game_clock.gd:142`).

**Criterio de éxito:** grafo de autoloads sin ciclos; `EventBus` sin dependencias de dominio; tests unitarios posibles con dobles para inventario/crafting/pesca.

### Mejora 2: Reducir el número efectivo de singletons y dividir “god objects”

**Objetivo:** bajar complejidad global (116 autoloads) y responsabilidades por archivo.

**Acciones concretas:**
- Priorizar refactor de los más grandes: `DebugMenu` (1308), `ProgressionManager` (959), `eventos` (901), `Tutorial` (814), `Construccion` (803), `VillagerManager` (777), `mineria` (768).
- Extraer submódulos puros (sin `Node` autoload cuando sea posible): validadores, cálculos, carga de datos, reglas, formateo, queries. Mantener el autoload solo como fachada/orquestador.
- Agrupar autoloads de infraestructura relacionados cuando tengan ciclo de vida común (audio: `AudioConfig`/directores; UI: `UIManager`/`TooltipService`/`NotificationService`/`ThemeService`/`SubtitleManager`) detrás de servicios registrados en `ServiceRegistry` (`scripts/core/service_registry.gd`).
- Revisar autoloads experimentales o específicos de módulo (`BotPaseoM09`, iteraciones de inventario `inventario_helper`/`inventario_iter5`) y convertirlos en nodos de escena/sistemas bajo demanda si no necesitan estado global permanente.
- Establecer presupuesto: límite de líneas por autoload (p. ej. 300-400) y límite de dependencias directas a otros autoloads (p. ej. <=2), con excepción documentada.

**Criterio de éxito:** menos autoloads globales, archivos más pequeños, dependencias explícitas, menor riesgo al modificar un dominio.

## Conclusión final

El proyecto declara **116 autoloads** en `game/isla-ancestral/project.godot:15-131`, una cantidad alta para mantener orden de inicialización, testabilidad y acoplamiento bajo control. El análisis estático detecta **acoplamiento fuerte** en dominios centrales (inventario/crafting, amistad/NPC, tiempo/eventos, pesca/museo, progresión/logros) y **3 dependencias circulares**: `Crafting<->Inventario`, `DonationService->EventBus->Fishing->DonationService` y `GameTime<->eventos`. También hay varios autoloads con **responsabilidad potencialmente excesiva** por tamaño o número de dependencias (`DebugMenu` 1308, `ProgressionManager` 959, `eventos` 901, entre otros).

La prioridad técnica recomendada es: (1) **romper ciclos** usando eventos neutros y contratos inyectados, especialmente sacando conocimiento de dominio fuera de `EventBus` y eliminando la bidireccionalidad entre inventario y crafting; (2) **reducir y dividir singletons** grandes en módulos con responsabilidades claras, manteniendo solo como autoload lo que realmente requiera estado global y acceso temprano.
