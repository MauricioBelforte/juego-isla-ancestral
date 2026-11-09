# Reporte de análisis de autoloads (singletons) — Isla Ancestral

**Fecha:** 2026-11-09
**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Alcance:** `game/isla-ancestral/project.godot` sección `[autoload]` (líneas 19–136) + todos los scripts `.gd` referenciados + dependencias entre ellos + uso en el resto de `scripts/`.

**Método:** lectura directa de `project.godot` (PowerShell/UTF-8), conteo de líneas/funciones/señales por script, grafo de referencias directas por nombre de singleton (regex sobre el código fuente), detección de ciclos bidireccionales y de uso externo fuera del conjunto de autoloads.

---

## (1) ¿Cuántos autoloads hay y cuáles son?

### Conteo
- **116 autoloads** declarados en `project.godot:19-136`.
- **115 activos** (prefijo `*`) + **1 deshabilitado**: `TermsManager="res://scripts/legal/terms_manager.gd"` (`project.godot:21`, sin `*`). Sigue siendo referenciable por `class_name TermsManager` en `scripts/legal/terms_manager.gd:1`, pero **no se instancia** como singleton; su uso externo es de solo 3 archivos (ver §1.3).
- **0 archivos ausentes**: los 116 `res://` existen en disco.
- **4 conflictos de `class_name` con underscore** (evitan el pitfall Godot 4 §9.17/§9.41): `EventBus_` (`scripts/core/event_bus.gd:2`), `TooltipService_` (`scripts/ui/services/tooltip_service.gd`), `NotificationService_` (`scripts/ui/services/notification_service.gd`) y `TermsManager` (este último sí tiene `class_name` sin guion bajo y **colisiona** con el autoload de nombre `TermsManager`). La gran mayoría de los demás autoloads **evita** `class_name` con un comentario explícito ("Sin class_name: es autoload — pitfall documentado"), lo que es correcto; el riesgo aparece cuando otro script define una clase con el **mismo** nombre que un autoload.

### Lista completa (orden de carga, `project.godot:21-136`)

| # | Autoload | Script | Líneas | Funcs | Signals |
|---|----------|--------|--------|-------|---------|
| 1 | TermsManager (deshabilitado) | `scripts/legal/terms_manager.gd` | 73 | 8 | 3 |
| 2 | EventBus | `scripts/core/event_bus.gd` | 200 | 0 | 54 |
| 3 | WorldState | `scripts/dialogos/world_state_service.gd` | 133 | 14 | 0 |
| 4 | DialogueManager | `scripts/dialogos/dialogue_manager.gd` | 428 | 27 | 7 |
| 5 | GameSettings | `scripts/core/game_settings.gd` | 82 | 4 | 1 |
| 6 | ServiceRegistry | `scripts/core/service_registry.gd` | 76 | 9 | 0 |
| 7 | GameLogger | `scripts/logging/logger.gd` | 384 | 36 | 1 |
| 8 | AnalyticsDirector | `scripts/analytics/analytics_director.gd` | 232 | 19 | 1 |
| 9 | TelemetryDirector | `scripts/telemetry/telemetry_director.gd` | 533 | 41 | 3 |
| 10 | SaveManager | `scripts/saving/save_manager.gd` | 374 | 26 | 4 |
| 11 | TimeCalendar | `scripts/time/time_calendar.gd` | 274 | 41 | 6 |
| 12 | ItemDatabase | `scripts/data/item_database.gd` | 141 | 12 | 1 |
| 13 | EconomyManager | `scripts/economia/economy_manager.gd` | 228 | 21 | 3 |
| 14 | SoftlockGuard | `scripts/core/softlock_guard.gd` | 179 | 12 | 3 |
| 15 | ShopManager | `scripts/shops/shop_manager.gd` | 347 | 23 | 7 |
| 16 | Inventario | `scripts/inventario/inventario_service.gd` | 444 | 28 | 6 |
| 17 | Friendship | `scripts/friendship/friendship_service.gd` | 709 | 58 | 7 |
| 18 | GameTime | `scripts/time/game_clock.gd` | 264 | 29 | 5 |
| 19 | RelojHud | `scripts/clock/reloj_hud.gd` | 121 | 9 | 1 |
| 20 | Bootstrap | `scripts/core/bootstrap.gd` | 224 | 11 | 0 |
| 21 | UIManager | `scripts/ui/core/ui_manager.gd` | 646 | 43 | 3 |
| 22 | TooltipService | `scripts/ui/services/tooltip_service.gd` | 236 | 13 | 0 |
| 23 | NotificationService | `scripts/ui/services/notification_service.gd` | 204 | 13 | 0 |
| 24 | TerrainLocator | `scripts/core/terrain_locator.gd` | 74 | 7 | 0 |
| 25 | VillagerManager | `scripts/npc/villager_manager.gd` | 778 | 53 | 9 |
| 26 | ControlInput | `scripts/controls/control_input.gd` | 389 | 28 | 1 |
| 27 | ResourceManager | `scripts/resources/resource_manager.gd` | 367 | 31 | 3 |
| 28 | mineria | `scripts/mineria/mining_manager.gd` | 769 | 59 | 7 |
| 29 | interacciones | `scripts/interacciones/interaction_manager.gd` | 340 | 29 | 7 |
| 30 | fauna_registry | `scripts/fauna/fauna_registry.gd` | 209 | 17 | 3 |
| 31 | fauna | `scripts/fauna/fauna_manager.gd` | 134 | 13 | 0 |
| 32 | credits_manager | `scripts/legal/credits_manager.gd` | 331 | 30 | 6 |
| 33 | MerchManager | `scripts/legal/merch_manager.gd` | 297 | 30 | 0 |
| 34 | animal_ai | `scripts/animales_ia/m65_animal_ai.gd` | 352 | 22 | 0 |
| 35 | coleccionables | `scripts/coleccionables/coleccionables_manager.gd` | 232 | 20 | 3 |
| 36 | hotbar | `scripts/inventario/hotbar_state.gd` | 118 | 12 | 0 |
| 37 | inventario_helper | `scripts/inventario/inventario_iter4.gd` | 337 | 32 | 0 |
| 38 | inventario_iter5 | `scripts/inventario/inventario_iter5.gd` | 345 | 26 | 0 |
| 39 | Localization | `scripts/localization/localization_manager.gd` | 378 | 33 | 1 |
| 40 | Balance | `scripts/balance/balance_service.gd` | 180 | 29 | 0 |
| 41 | Tutorial | `scripts/tutorial/tutorial_manager.gd` | 814 | 67 | 12 |
| 42 | ThemeService | `scripts/ui/theme/theme_service.gd` | 67 | 7 | 0 |
| 43 | Crafting | `scripts/crafting/crafting_service.gd` | 460 | 33 | 9 |
| 44 | AssetProfile | `scripts/rendimiento/asset_profile.gd` | 159 | 14 | 0 |
| 45 | BrandConfig | `scripts/brand/brand_config.gd` | 47 | 3 | 0 |
| 46 | DebugMenu | `scripts/debug/debug_menu.gd` | 1309 | 107 | 3 |
| 47 | CatalogoTiendas | `scripts/shops/catalogo_tiendas.gd` | 169 | 9 | 0 |
| 48 | Farm | `scripts/farm/farm_service.gd` | 515 | 42 | 8 |
| 49 | Fishing | `scripts/fishing/fishing_manager.gd` | 496 | 38 | 6 |
| 50 | Weather | `scripts/clima/weather_service.gd` | 231 | 22 | 0 |
| 51 | Historia | `scripts/historia/story_manager.gd` | 256 | 20 | 0 |
| 52 | Historias | `scripts/historias/secondary_stories_service.gd` | 471 | 31 | 1 |
| 53 | Barter | `scripts/economia/barter_system.gd` | 215 | 16 | 2 |
| 54 | TravelService | `scripts/viajes/travel_service.gd` | 381 | 29 | 5 |
| 55 | CollectionRegistry | `scripts/museum/collection_registry.gd` | 365 | 25 | 2 |
| 56 | DonationService | `scripts/museum/donation_service.gd` | 96 | 4 | 3 |
| 57 | Diary | `scripts/diario/diary_service.gd` | 408 | 28 | 0 |
| 58 | PlayerProfile | `scripts/progresion/player_profile.gd` | 118 | 13 | 0 |
| 59 | ProgressionManager | `scripts/progresion/progression_manager.gd` | 960 | 55 | 5 |
| 60 | Achievements | `scripts/logros/achievement_service.gd` | 623 | 39 | 3 |
| 61 | Vehiculos | `scripts/vehiculos/vehicle_manager.gd` | 204 | 17 | 0 |
| 62 | Postgame | `scripts/postgame/postgame_manager.gd` | 284 | 21 | 2 |
| 63 | EscalasGlobales | `scripts/core/escalas_globales.gd` | 57 | 4 | 0 |
| 64 | AccesibilityManager | `scripts/accesibilidad/accesibilidad_manager.gd` | 462 | 37 | 8 |
| 65 | AnimationService | `scripts/animacion/animation_service.gd` | 135 | 8 | 4 |
| 66 | PhotoService | `scripts/foto/photo_service.gd` | 407 | 19 | 4 |
| 67 | Tiers | `scripts/herramientas158/tool_tier_system.gd` | 361 | 27 | 3 |
| 68 | AudioConfig | `scripts/audio/audio_config_service.gd` | 310 | 27 | 3 |
| 69 | DataStore | `scripts/datos/data_store.gd` | 650 | 38 | 7 |
| 70 | SubtitleManager | `scripts/ui/subtitle_manager.gd` | 360 | 30 | 4 |
| 71 | StreamManager | `scripts/stream/stream_manager.gd` | 528 | 41 | 5 |
| 72 | PantallaCarga | `scripts/stream/pantalla_carga.gd` | 187 | 16 | 1 |
| 73 | MonetizacionManager | `scripts/monetizacion/monetizacion_manager.gd` | 135 | 13 | 3 |
| 74 | TerrainProvider | `scripts/terrenos/terrain_provider.gd` | 107 | 10 | 0 |
| 75 | GameFlowManager | `scripts/core/game_flow_manager.gd` | 73 | 6 | 1 |
| 76 | SceneManager | `scripts/core/scene_manager.gd` | 160 | 10 | 3 |
| 77 | MotivacionManager | `scripts/motivacion/motivacion_manager.gd` | 180 | 17 | 2 |
| 78 | PlatformManager | `scripts/plataformas/platform_manager.gd` | 118 | 14 | 2 |
| 79 | WorldBible | `scripts/world/world_bible.gd` | 73 | 9 | 1 |
| 80 | MemoryMonitor | `scripts/rendimiento/memoria/memory_monitor.gd` | 642 | 68 | 5 |
| 81 | MusicDirector | `scripts/audio/music_director.gd` | 101 | 12 | 1 |
| 82 | AmbientDirector | `scripts/audio/ambient_director.gd` | 72 | 9 | 1 |
| 83 | SFXManager | `scripts/audio/sfx_manager.gd` | 400 | 38 | 0 |
| 84 | FeedbackDirector | `scripts/audio/feedback_director.gd` | 83 | 10 | 1 |
| 85 | NarrativeSound | `scripts/audio/narrative_sound.gd` | 244 | 26 | 4 |
| 86 | CrashReporter | `scripts/crash/crash_reporter.gd` | 94 | 7 | 1 |
| 87 | CiCdManager | `scripts/ci/cicd_manager.gd` | 299 | 22 | 0 |
| 88 | InstaladorConfig | `scripts/installer/instalador_config.gd` | 81 | 12 | 0 |
| 89 | MapManager | `scripts/mapa/mapa_manager.gd` | 304 | 30 | 3 |
| 90 | HardwareManager | `scripts/hardware/hardware_manager.gd` | 92 | 13 | 0 |
| 91 | BuildConfigManager | `scripts/build/build_config_manager.gd` | 74 | 7 | 0 |
| 92 | UpdateManager | `scripts/updates/update_manager.gd` | 93 | 10 | 0 |
| 93 | DevTools | `scripts/dev/dev_tools.gd` | 77 | 9 | 0 |
| 94 | MaterialesRecursos | `scripts/arte3d/materiales_recursos.gd` | 184 | 14 | 0 |
| 95 | BotPaseoM09 | `scripts/world/bot_paseo_m09.gd` | 244 | 11 | 0 |
| 96 | MundoRaiz | `scripts/world/mundo_raiz.gd` | 36 | 2 | 0 |
| 97 | SecurityManager | `scripts/security/security_manager.gd` | 243 | 17 | 0 |
| 98 | FontCatalog | `scripts/fonts/font_catalog.gd` | 100 | 11 | 0 |
| 99 | BackupManager | `scripts/backup/backup_manager.gd` | 408 | 35 | 0 |
| 100 | DlcManager | `scripts/dlc/dlc_manager.gd` | 343 | 39 | 0 |
| 101 | SupportManager | `scripts/support/support_manager.gd` | 135 | 17 | 2 |
| 102 | ModdingManager | `scripts/modding/modding_manager.gd` | 125 | 12 | 0 |
| 103 | UgcManager | `scripts/ugc/ugc_manager.gd` | 63 | 9 | 0 |
| 104 | CommunityManager | `scripts/community/community_manager.gd` | 54 | 7 | 0 |
| 105 | NPCManager | `scripts/ia_npc/npc_manager.gd` | 386 | 28 | 5 |
| 106 | eventos | `scripts/eventos/event_manager.gd` | 902 | 55 | 8 |
| 107 | EquipmentManager | `scripts/player/equipment_manager.gd` | 393 | 22 | 3 |
| 108 | NPCVisualDatabase | `scripts/data/npc_visual_database.gd` | 57 | 7 | 0 |
| 109 | WorldLocations | `scripts/data/world_locations.gd` | 344 | 16 | 2 |
| 110 | EnchantmentSystem | `scripts/enchantment/enchantment_system.gd` | 152 | 22 | 4 |
| 111 | TransportManager | `scripts/transporte/transport_manager.gd` | 703 | 59 | 6 |
| 112 | IslandRegistry | `scripts/islas/island_registry.gd` | 473 | 39 | 3 |
| 113 | gem_currency | `scripts/combat/gem_currency.gd` | 109 | 9 | 2 |
| 114 | combat_island | `scripts/combat/combat_island_system.gd` | 213 | 22 | 2 |
| 115 | Construccion | `scripts/construccion/build_manager.gd` | 804 | 66 | 6 |
| 116 | HouseManager | `scripts/houses/house_manager.gd` | 339 | 30 | 4 |

### Distribución por tamaño
- Cluster ">500 líneas — dioses potenciales": 14 autoloads (DebugMenu 1309, ProgressionManager 960, eventos 902, Tutorial 814, Construccion 804, VillagerManager 778, mineria 769, TransportManager 703, Friendship 709→778 en conteo de archivo, DataStore 650→566, MemoryMonitor 642→556, UIManager 646→542, Achievements 623→536, TelemetryDirector 533→470, StreamManager 528→428 — varían ±15% según método de conteo, el orden es estable).
- Cluster "datos/config pura" (<120 líneas, 2–7 funciones): MundoRaiz (36), BrandConfig (47), CommunityManager (54), EscalasGlobales (57), NPCVisualDatabase (57), UgcManager (63), ThemeService (67), AmbientDirector (72), GameFlowManager (73), TermsManager (73), WorldBible (73), DevTools (77), GameSettings (82), FeedbackDirector (83), InstaladorConfig (81), BuildConfigManager (74), UpdateManager (93), HardwareManager (92), CrashReporter (94), DonationService (96), FontCatalog (100), MusicDirector (101), TerrainProvider (107).

### Uso externo real (archivos `.gd` fuera del conjunto de autoloads que nombran al singleton)
Top: **Inventario (200 archivos)**, **eventos (134)**, **Historia (99)**, **SaveManager (97)**, **EventBus (91)**, **GameTime (73)**, **ServiceRegistry (59)**, **Localization (55)**, **Crafting (53)**, **Construccion (53)**, **fauna (52)**, **EconomyManager (48)**, **Friendship (44)**, **Diary (43)**, **Balance (43)**, **Weather (42)**, **TimeCalendar (42)**, **ItemDatabase (39)**, **UIManager (34)**, **TerrainLocator (34)**, **WorldState (30)**, **Bootstrap (29)**, **Tutorial (29)**, **Farm (28)**, **VillagerManager (28)**.
Cola: ~55 autoloads con **≤5 archivos** externos; **solo `BotPaseoM09` tiene 0 uso externo** (ver §4) y `SoftlockGuard` tiene 0 **referencias internas** entre autoloads pero 9 usos externos.

---

## (2) ¿Autoloads dios-objeto (demasiadas responsabilidades)?

**Sí, al menos 8 casos claros**, definidos como: archivo grande (>500 líneas), muchas funciones (>40), alta fan-out (menciona a muchos otros singletons) y/o responsabilidades cruzadas (mezcla datos, lógica de juego, UI y persistencia).

1. **DebugMenu** — `scripts/debug/debug_menu.gd:1-1309` (1309 líneas, 107 funciones, 17 referencias a otros autoloads). Header (líneas 1–10) declara que es menú de debug in-game con pestañas data-driven, comandos (teleport/spawn/time/clima/flags/exportar) y métricas de sistema. Es el autoload con **mayor fan-out** del proyecto. Debería ser **herramienta de editor/dev en construcción**, no un singleton presente en builds de producción (aunque se oculta con `OS.is_debug_build()`). Su tamaño ya forzó la extracción de `diagnostic_exporter.gd` y `debug_commands.gd` por `preload` (líneas 22–23).
2. **ProgressionManager** — `scripts/progresion/progression_manager.gd` (835–960 líneas, 55 funciones). Mezcla progresión de jugador, XP, niveles, desbloqueos y persistencia; 11 referencias internas + ciclo con `PlayerProfile` (§3).
3. **eventos (EventManager)** — `scripts/eventos/event_manager.gd` (774–902 líneas, 55 funciones). Es el **segundo hub de acoplamiento** del juego (0 referencias entrantes desde otros autoloads en el grafo interno, pero **134 archivos externos** lo nombran). Ciclo bidireccional con `EventBus`, `SaveManager`, `TimeCalendar`, `Friendship`, `GameTime` (§3) — el problema no es solo coordinar eventos, sino que es un emisario que obliga a medio juego a pasar por él.
4. **Tutorial** — `scripts/tutorial/tutorial_manager.gd` (725–814 líneas, 67 funciones — la mayor cantidad de funciones de cualquier autoload). Tres responsabilidades en uno: definición de pasos, orquestación de UI de tutorial y temporización; 7 referencias internas.
5. **Construccion (BuildManager)** — `scripts/construccion/build_manager.gd` (708–804 líneas, 66 funciones). Mezcla colocación en mundo, costes de recursos (debía delegar a `EconomyManager/ResourceManager`), validación de terreno y persistencia del construido.
6. **VillagerManager** — `scripts/npc/villager_manager.gd` (644–778 líneas, 53 funciones, 9 señales). Agrega spawns, IA de aldeanos, horarios, rutinas y persistencia; ciclo con `TimeCalendar` (§3). Referencia 4 archivos `.tscn` vía `preload` (olor a escena, §4).
7. **mineria (MiningManager)** — `scripts/mineria/mining_manager.gd` (682–769 líneas, 59 funciones). Debería ser solo extracción y drops; hoy también toca herramientas (`Tiers`), inventario y fauna.
8. **Friendship** — `scripts/friendship/friendship_service.gd` (632–709 líneas, 58 funciones). Combina afinidad, diálogos, recompensas y persistencia; ciclo con `EventBus` y `eventos` (§3).
9. **UIManager + TransportManager + DataStore + MemoryMonitor** (nivel medio-alto): `scripts/ui/core/ui_manager.gd` (542 líneas, 43 funciones), `scripts/transporte/transport_manager.gd` (568–703 líneas, 59 funciones, 15 referencias internas — segundo mayor fan-out), `scripts/datos/data_store.gd` (566–650 líneas), `scripts/rendimiento/memoria/memory_monitor.gd` (556–642 líneas, 68 funciones). No son dioses por sí mismos, pero **suman** a la red: cada uno añade 6–11 aristas al grafo de dependencias.

**Caso aparte — infraestructura que no debería existir como autoload:** `ServiceRegistry` (`scripts/core/service_registry.gd:1-76`) y `Bootstrap` (`scripts/core/bootstrap.gd:1-224`) conviven como **dos registros centrales**: Bootstrap registra "servicios core" por contrato en `ServiceRegistry` (`_register_core_services()`), y además los dominios se auto-registran por contrato (comentario en `bootstrap.gd:52-53`). El propio `bootstrap.gd:16-27` define `REQUIRED_SERVICES = ["event_bus"]` y `DOMINIOS_ESPERADOS = [...9 dominios...]` — un **segundo autoload cuya única función es conocer a los demás autoloads**. Es un meta-dios de arranque: si el orden de carga cambia, `_verify_game_flow.call_deferred()` y `_autoload_domains.call_deferred()` (líneas 50–53) corren tras el `_ready` de Bootstrap, pero cualquier autoload que consulte `get_service()` antes del diferido recibe `DOM-INF-ACCESO-TEMPRANO` (ver `service_registry.gd:34-41`).

**Contraste — autoloads sanos (pura configuración/dato):** `MundoRaiz` (`scripts/world/mundo_raiz.gd:1-36`, solo constantes `CENTRO`, `RADIO_ISLA`, `SPAWN_JUGADOR` + 2 getters), `EscalasGlobales` (57 líneas), `BrandConfig` (47), `WorldBible` (73), `GameSettings` (82). Estos no tienen lógica de juego, solo datos; son los candidatos correctos a ser singleton o incluso `Resource`/`const` en un `class_name` (ver §4).

---

## (3) ¿Dependencias circulares entre autoloads?

**Sí — 34 ciclos mutuos directos** (A menciona a B **y** B menciona a A en su propio script). Conteo por regex sobre los 116 textos; un par puede ser "falso positivo" si la mención es solo en un comentario, pero el patrón se repite en clusters coherentes (núcleo, economía, inventario, tiempo, fauna, progresión, UI).

### Lista de ciclos mutuos (A ↔ B)
- **Núcleo de arranque/flujo (el cluster más peligroso):**
  - `EventBus` ↔ `SaveManager`, `EventBus` ↔ `Friendship`, `EventBus` ↔ `Bootstrap`, `EventBus` ↔ `Fishing`, `EventBus` ↔ `Weather`, `EventBus` ↔ `Diary`, `EventBus` ↔ `GameFlowManager`, `EventBus` ↔ `SceneManager`, `EventBus` ↔ `eventos`
  - `ServiceRegistry` ↔ `Bootstrap` (el registro conoce al registrador y viceversa — `service_registry.gd:70-74` menciona a `bootstrap.gd:109`)
  - `Bootstrap` ↔ `SceneManager`, `GameFlowManager` ↔ `SceneManager`
- **Persistencia:**
  - `SaveManager` ↔ `Inventario`, `SaveManager` ↔ `Fishing`, `SaveManager` ↔ `DataStore`, `SaveManager` ↔ `EventBus`, `SaveManager` ↔ `eventos`
- **Tiempo/clima:**
  - `TimeCalendar` ↔ `VillagerManager`, `TimeCalendar` ↔ `fauna`, `TimeCalendar` ↔ `eventos`, `GameTime` ↔ `eventos`
- **Economía/inventario/crafteo:**
  - `EconomyManager` ↔ `ShopManager`, `ShopManager` ↔ `Inventario`, `ShopManager` ↔ `CatalogoTiendas`, `Inventario` ↔ `Crafting`, `Balance` ↔ `Crafting`, `Balance` ↔ `Farm`, `Balance` ↔ `Fishing`
- **Diálogo/historia:**
  - `WorldState` ↔ `DialogueManager`, `Historia` ↔ `Historias`, `Friendship` ↔ `eventos`
- **Fauna:**
  - `fauna_registry` ↔ `fauna`, `fauna` ↔ `animal_ai`
- **Progresión:**
  - `PlayerProfile` ↔ `ProgressionManager`
- **UI:**
  - `UIManager` ↔ `ThemeService`

### Por qué es grave (mecanismo concreto, no solo conteo)
1. **Orden de carga frágil:** Godot instancia los autoloads en el orden de `project.godot:21-136`. Quien esté antes tiene `_ready()` ejecutado antes. Con ciclos, al menos uno de los dos **siempre** consulta antes de que el otro termine de inicializarse (el propio equipo lo documenta: `service_registry.gd:34-41` emite `DOM-INF-ACCESO-TEMPRANO` "consulta antes de registrarse, devuelve null"). El `_ready()` diferido de Bootstrap (`bootstrap.gd:50-53`) es un parche para este problema, no una solución.
2. **Testabilidad rota:** dos autoloads que se citan no se pueden unit-testear por separado sin cargar el otro; en headless, `preload` cruzado puede disparar error de parseo (ver el workaround en `scripts/ia_npc/npc_manager.gd: header "Preload para resolver el class_name NPCAgent en este script (evita fallo de parseo headless por class_name cruzado, AGENTS.md §9.50)"`).
3. **Cascada de cambios:** tocar `SaveManager` obliga a revisar `Inventario`, `Fishing`, `DataStore`, `EventBus` y `eventos` (5 aristas). Tocar `EventBus` obliga a revisar 9 autoloads. Es el síntoma clásico de "núcleo enmarañado".
4. **Ciclos de 3+ saltos (no contados arriba, pero presentes en el grafo dirigido de 440 aristas):** p.ej. `eventos` → `SaveManager` → `Inventario` → `Crafting` → `Balance` → `Fishing` → `SaveManager` cierra un ciclo largo sin necesidad de que cada par sea mutuo. El Hub `EventBus` (11 referencias internas, 0 funciones, 54 señales) es el concentrador: 9 de los 34 ciclos pasan por él, lo que indica que **el bus de eventos está haciendo trabajo de acoplamiento que debería ser por señales dirigidas o inyección de dependencia**.

### Grafo de dependencias (resumen)
- **440 referencias dirigidas** entre pares de autoloads (promedio ~3,8 por autoload).
- **Top fan-out interno:** DebugMenu (17), TransportManager (15), Bootstrap (14), Achievements (13), ProgressionManager (11), UIManager (11), TravelService (11), EventBus (11).
- **40 autoloads sin referencias entrantes desde otros autoloads** (grafo interno). Aproximadamente la mitad de ellos **sí** se usan desde scripts de juego (p.ej. `SFXManager`, `NarrativeSound`, `MundoRaiz`, `NotificationService`, `SubtitleManager` — señales desde la capa de escena/UI). El resto es sospechoso de estar **sin cablear** (ver §4): `AmbientDirector`, `AnimationService`, `BackupManager`, `BotPaseoM09`, `BrandConfig`, `BuildConfigManager`, `CiCdManager`, `combat_island`, `CommunityManager`, `credits_manager`, `DevTools`, `DlcManager`, `EnchantmentSystem`, `EquipmentManager`, `EscalasGlobales`, `FeedbackDirector`, `FontCatalog`, `HardwareManager`, `HouseManager`, `InstaladorConfig`, `inventario_iter5`, `MaterialesRecursos`, `MerchManager`, `ModdingManager`, `MonetizacionManager`, `MotivacionManager`, `PantallaCarga`, `PlatformManager`, `RelojHud`, `SecurityManager`, `TermsManager`, etc.

---

## (4) ¿Autoloads que podrían ser nodos de escena en lugar de globales?

**Sí — al menos 10 clasificados por olor, + 3 grupos.**

### A. UI que vive como singleton en vez de en la escena (candidatos claros)
- **TooltipService** (`scripts/ui/services/tooltip_service.gd`, `extends CanvasLayer`, 11 `add_child`): es una capa visual. Debería ser un nodo `CanvasLayer` en `main_island.tscn` o en la escena de HUD, no un global. Igual para **NotificationService** (`scripts/ui/services/notification_service.gd`, `extends CanvasLayer`, 8 `add_child`).
- **UIManager** (`scripts/ui/core/ui_manager.gd`, 646 líneas, 43 funciones, 11 referencias internas, ciclo con `ThemeService`): si ya hay una escena de HUD/UI, el manager debería ser su script raíz. Hoy es un singleton que además coordina temas, pantallas y notificaciones — mezcla "dónde está la UI" con "qué pantalla mostrar".
- **PantallaCarga** (`scripts/stream/pantalla_carga.gd`, 187 líneas, `extends CanvasLayer`, 8 `add_child`, header líneas 1–12: "CanvasLayer con barra ColorRect... Se muestra/oculta con señal"): es literalmente una escena intrínseca; debería ser un `.tscn` instanciado por `SceneManager`/`StreamManager`.
- **RelojHud** (`scripts/clock/reloj_hud.gd`, 121 líneas, header: "HUD Reloj — capa de DISPLAY... Consumidor del GameClock M29"): un widget de HUD; su lugar es la escena de HUD, no el árbol root.
- **SubtitleManager** (`scripts/ui/subtitle_manager.gd`, 360 líneas, 2 referencias `.tscn`, 6 `add_child`): gestión de subtítulos que debería vivir junto al reproductor de audio/UI de subtítulos.
- **VillagerManager** (4 referencias `.tscn`, 3 `add_child`) y **NPCManager** (1 `.tscn`, 3 `add_child`), **Farm** (1 `.tscn`), **Bootstrap** (2 `.tscn` — carga `main_island.tscn`, `bootstrap.gd:31`): instancian escenas desde un global; la responsabilidad de "qué escena entra en qué contenedor" pertenece a la **escena dueña** (p.ej. un `MainIsland.tscn` con un nodo `WorldContainer`), no a un autoload.

### B. Herramientas de dev / QA que no deberían ser singletons de producción
- **BotPaseoM09** (`scripts/world/bot_paseo_m09.gd`, header línea 6: "TEMPORAL (M09): BOT DE PASEO REALISTA — simula W... waypoints... captura + resumen del tramo"): **0 archivos externos lo referencian** (único autoload con uso externo = 0). Es un bot de test temporal convertido en autoload permanente. Debería ser un `Node` en una escena de prueba dev (`scenes/dev/bot_paseo.tscn`) o un script de tool, nunca un singleton global que ocupa el árbol root.
- **DebugMenu** (1.309 líneas, §2): en builds de producción debería **no existir** como nodo; si se mantiene, ha de ser escena bajo demanda (`debug_builds/`), no autoload.
- **DevTools** (`scripts/dev/dev_tools.gd`, 77 líneas, solo 5 archivos externos), **CiCdManager** (`scripts/ci/cicd_manager.gd`, 299 líneas), **BuildConfigManager** (`scripts/build/build_config_manager.gd`, 74), **InstaladorConfig** (`scripts/installer/instalador_config.gd`, 81), **HardwareManager** (`scripts/hardware/hardware_manager.gd`, 92): son conceptos de **tooling/CI/distribución**, no de runtime. El mismo olor aplica a **UpdateManager** y **SupportManager** si nunca se usan en gameplay.

### C. Datos polvorienta que podrían ser `class_name` + `const`/`Resource` (falsos singletons)
- **MundoRaiz** (`scripts/world/mundo_raiz.gd:17-36`): solo `const CENTRO`, `RADIO_ISLA`, `SPAWN_JUGADOR` + 2 getters. Un `const` en una clase `MundoRaiz` (sin autoload) o en `WorldBible` bastaría.
- **EscalasGlobales** (`scripts/core/escalas_globales.gd`, 57 líneas, 4 funciones), **BrandConfig** (`scripts/brand/brand_config.gd`, 47), **NPCVisualDatabase** (`scripts/data/npc_visual_database.gd`, 57), **FontCatalog** (`scripts/fonts/font_catalog.gd`, 100), **ThemeService** (67), **WorldBible** (73), **CatalogoTiendas** (169): si solo publican catálogos/constantes, son `class_name` con `static func` o `Resource`, no nodos vivos con `_ready()`.

### D. Casos de duplicación entre autoloads (sospecha de "accidentalmente globales")
- **Inventario / inventario_helper / inventario_iter5 / hotbar**: 4 singletons para el mismo dominio (`scripts/inventario/inventario_service.gd` 444, `inventario_iter4.gd` 337, `inventario_iter5.gd` 345, `hotbar_state.gd` 118). El grafo interno no muestra ciclo entre ellos, pero el uso externo sí: **Inventario 200 archivos** vs `inventario_helper` 3 y `inventario_iter5` 3. Esto indica **capas de compatibilidad acumuladas** que deberían colapsar en un `InventoryService` + `HotbarState` como datos, no como autoloads.
- **Historia / Historias**: 2 singletons (`story_manager.gd` 256, `secondary_stories_service.gd` 471) con **uso externo 99 y 15** respectivamente + **ciclo mutuo** entre ellos (§3). Uno es el sistema de historias principales y el otro el de secundarias; deberían ser un único `StoryService` con dos `Resource` de datos o dos nodos hermanos bajo un `StoryRoot` en escena.
- **fauna / fauna_registry / animal_ai**: 3 singletons con **ciclos mutuos** `fauna_registry ↔ fauna` y `fauna ↔ animal_ai` (§3). Patrón natural: `FaunaSystem` (escena) con hijos `FaunaRegistry` (datos) y `FaunaAI` (lógica), no 3 globales.
- **GameTime / TimeCalendar / Weather**: 3 relojes/climas con aristas mutuas a `eventos`. Weather podría ser un componente del nodo `World` (con su ciclo día/noche y partículas), no un singleton.
- **UgcManager / ModdingManager / CommunityManager / DlcManager / MerchManager / MonetizacionManager / SupportManager / PlatformManager / SecurityManager / BackupManager / Ugc...**: bloque "meta/comunidad/monetización" con **uso externo ≤9 archivos** cada uno y, en muchos casos, 0 referencias entrantes desde autoloads. Parecen **scaffolding de módulos M-xxx no cableados** o stubs de publicación. Convertirlos en nodos opcionales (pack de "servicios externos") o eliminarlos del `project.godot` hasta que exista su escena/funcionalidad evitaría que el árbol de autoloads crezca sin control.

### Nota sobre "singleton sin uso"
- Solo **BotPaseoM09** tiene **literalmente 0** archivos externos que lo nombren. El resto de los 40 sin referencias **internas** sí se usan desde scripts de escena/UI (ver §1, cola de uso externo). La ausencia de referencias internas no implica ausencia de uso; implica **desacoplamiento real** (señalan desde un solo lado — la escena — y no desde otros singletons). Esa es la dirección correcta del acople.

---

## (5) Acciones para reducir el acoplamiento (2 propuestas, concretas)

### Acción 1 — Congelar el núcleo: eliminar los ciclos del arranque y de persistencia (romper 12 de los 34 ciclos sin reescribir API)
**Idea:** los ciclos más caros son los que envuelven `EventBus`, `Bootstrap/ServiceRegistry/GameFlowManager/SceneManager` y `SaveManager` con `Inventario/Fishing/DataStore`. Se rompen **sin cambiar nombres públicos** (la API por nombre de singleton se mantiene) cambiando **quién llama a quién** y **cuándo**:

1. **De arriba a abajo en el orden de carga:** mover `Bootstrap` (`project.godot:40`) al **final** de la lista (después de `HouseManager`, línea 136), de modo que todo dominio ya exista cuando `_register_core_services()` corre. Hoy Bootstrap está en la posición 20 (entre `RelojHud` y `UIManager`) y depende de diferidos (`bootstrap.gd:50-53`) para compensar. Al moverlo, se elimina la necesidad de `_verificar_game_flow.call_deferred()` y los avisos `DOM-INF-ACCESO-TEMPRANO`.
2. **Invertir las flechas del núcleo:** `ServiceRegistry` no debe mencionar `Bootstrap` (hoy `service_registry.gd:70-74` cita `bootstrap.gd:109`). La dirección correcta es **Bootstrap → ServiceRegistry** (uno solo). Eliminar la mención inversa rompe el ciclo `ServiceRegistry ↔ Bootstrap` sin tocar lógica.
3. **Guardar = orquestar, no conocer:** `SaveManager` (`scripts/saving/save_manager.gd`, 374 líneas) hoy conoce a `Inventario`, `Fishing`, `DataStore`, `EventBus` y `eventos` (5 aristas, 3 ciclos). Reescribirlo como **orquestador por señales** — cada dominio emite `guardado_solicitado`/`cargado` por `EventBus` y `SaveManager` solo escucha, sin importar los dominios — elimina 3 ciclos (`SaveManager ↔ Inventario`, `↔ Fishing`, `↔ DataStore`) y 2 más si `eventos` también pasa a señal. `EventBus` ya existe para esto (`scripts/core/event_bus.gd:1-12`, "Signal Up, Call Down"); hay que **usarlo en vez de las referencias directas**.
4. **EventBus deja de citar dominios:** su header dice "EventBus NO importa ningún dominio (solo define tipos)", pero hoy 9 ciclos lo pasan por él. Auditar sus 54 señales y borrar cualquiera que nombre un dominio concreto; las señales payload deben ser `Variant`/tipos de core, no de dominio. Sin ciclos por `EventBus`, el coordinador deja de ser un dios de acople.

**Efecto medible:** de 440 aristas dirigidas → ~420, y de 34 ciclos mutuos → ~20 (se eliminan los del núcleo, los más peligrosos para el arranque). **Esfuerzo:** M (2–3 días), porque no cambia firmas públicas, solo implementación interna y orden de carga. **Evidencia de éxito:** `grep -c "DOM-INF-ACCESO-TEMPRANO"` en logs en cero; el grafo de dependencias recalculado ya no muestra ciclos que pasen por `EventBus`/`Bootstrap`/`SaveManager`.

### Acción 2 — Reclasificar los autoloads que no son servicios globales: UI/escena, dev y datos (quitar ~20–25 autoloads del árbol root)
**Idea:** la mitad del problema es **cantidad**: 116 autoloads × ~3,8 aristas = superficie de acople enorme. No se necesita desacoplar cada uno; basta con **sacar del árbol root** a los que no son servicios reales:

1. **Escena (quitar 8–10):** `TooltipService`, `NotificationService`, `UIManager`, `PantallaCarga`, `RelojHud`, `SubtitleManager` pasan a ser nodos dentro de `scenes/main_island.tscn` (o de `scenes/ui/hud.tscn`/`scenes/ui/pantalla_carga.tscn`). `VillagerManager`, `NPCManager`, `Farm` dejan de instanciar `.tscn` (hoy 4+3+1 referencias) y reciben sus escenas como `@export` desde la escena que los contiene. `Bootstrap` sale del autoload y es el `script` de `res://scenes/main_island.tscn` (su única acción real es cargar esa escena — `bootstrap.gd:31, 52-53`).
2. **Dev/tooling (quitar 5–6):** `BotPaseoM09` → `scenes/dev/bot_paseo.tscn` (uso externo = 0 hoy, §4.B); `DebugMenu` → escena bajo demanda solo en `OS.is_debug_build()` (`debug_menu.gd:8` ya lo dice); `DevTools`, `CiCdManager`, `BuildConfigManager`, `InstaladorConfig`, `HardwareManager` → `scripts/tools/` o `addons/`, no autoloads de runtime.
3. **Datos (convertir 8–10):** `MundoRaiz`, `EscalasGlobales`, `BrandConfig`, `NPCVisualDatabase`, `FontCatalog`, `ThemeService`, `WorldBible`, `CatalogoTiendas` → `class_name X extends RefCounted` con `static`/`const`, o `Resource` cargado bajo demanda. `MundoRaiz` con solo constantes es el candidato piloto: 36 líneas, 2 getters, 10 archivos externos que podrían usar `MundoRaiz.CENTRO` sin nodo.
4. **Colapsar duplicados (quitar 4–5):** `inventario_helper` + `inventario_iter5` → métodos internos de `Inventario` (o `InventoryService` único); `Historia` + `Historias` → `StoryService` con `HistoriasSecundarias` como `Resource`; `fauna_registry` + `animal_ai` → componentes de `fauna` como escena (elimina además 2 de los 34 ciclos).

**Efecto medible:** de 116 autoloads → ~85–90, y de 440 aristas → ~250 (las flechas de UI/dev/datos desaparecen del grafo de singletons porque pasan a ser referencias de escena o consts). **Esfuerzo:** L (1–2 semanas por lote, por orden: datos → dev → UI → duplicados), pero **incrementable**: cada lote es independiente y deja el juego corriendo. **Regla de oro:** un autoload nuevo solo se acepta si cumple (a) no es UI/escena, (b) no es tooling, (c) tiene >5 archivos externos que lo necesitan **antes** de que exista su escena, y (d) no crea un ciclo mutuo nuevo.

---

## Conclusión final

**El proyecto tiene 116 autoloads (115 activos, 1 deshabilitado), muy por encima del umbral sano (5–15 para un juego de este tamaño).** El problema no es solo el número, sino **qué tipo de cosas son**: la mitad son servicios reales con alto uso externo (`Inventario`, `eventos`, `Historia`, `SaveManager`, `EventBus`, `GameTime` — los que sí deben ser singletons), y la otra mitad son **UI que debería ser escena, tooling de dev/CI que debería ser addon, catálogos de constantes que deberían ser `class_name`, y scaffolding de módulos no cableados**.

Hay **8 dioses-objeto claros** (`DebugMenu` 1309 líneas/107 funciones, `ProgressionManager`, `eventos`, `Tutorial`, `Construccion`, `VillagerManager`, `mineria`, `Friendship`) y un **meta-dios de arranque** (`Bootstrap` + `ServiceRegistry` duplicando el registro). El grafo de dependencias suma **440 aristas dirigidas y 34 ciclos mutuos**, concentrados en `EventBus` (9 ciclos), el núcleo de arranque/flujo (`Bootstrap`, `ServiceRegistry`, `GameFlowManager`, `SceneManager`, `SaveManager`) y tres clusters (economía/inventario/crafteo, tiempo/fauna, diálogo/historia). Los ciclos son **funcionales hoy** (el juego carga) pero frágiles: dependen del orden de `project.godot` y de `_ready()` diferidos, e impiden testear dominios por separado (síntoma documentado en el propio código con `DOM-INF-ACCESO-TEMPRANO` y workarounds de `preload` por `class_name` cruzado).

La dirección de arreglo jerarquiza **eficacia sobre perfección**: (1) romper los ciclos del núcleo cambiando dirección de flechas y usando `EventBus` como bus de señales en vez de referencias directas — sin cambiar API pública y con éxito verificable por ausencia de avisos de arranque; (2) sacar del árbol root a ~20–25 autoloads que no son servicios globales (UI→escena, dev→addon, datos→`class_name`, duplicados→colapso), reduciendo la superficie de acople de 440 a ~250 aristas. Ninguna de las dos exige reescribir gameplay; ambas son incrementables y dejan el juego corriendo en cada lote.

---

## Evidencia (archivos y líneas clave)

- `game/isla-ancestral/project.godot:19-136` — sección `[autoload]` completa (116 líneas, 115 con `*`, 1 sin: `TermsManager` línea 21).
- `game/isla-ancestral/project.godot:171-179` — límites del linter (`function_max_lines=50`, `class_max_lines=300`, `file_max_lines=500`): **17 autoloads exceden `file_max_lines` o `class_max_lines`** según el conteo de archivo, lo que indica que el propio linter ya los marcaría como dioses.
- `scripts/debug/debug_menu.gd:1-30` (header M110, 1309 líneas totales, 107 `func`) — dios #1 y mayor fan-out (17 aristas internas).
- `scripts/core/bootstrap.gd:16-53` (`REQUIRED_SERVICES`, `DOMINIOS_ESPERADOS`, `_ready()` con 5 diferidos) y `scripts/core/service_registry.gd:1-76` (en especial `:34-41` aviso de acceso temprano y `:70-74` referencia a `bootstrap.gd:109`) — meta-dios de arranque + ciclo.
- `scripts/core/event_bus.gd:1-12` (header "Signal Up, Call Down" + "EventBus NO importa ningún dominio") vs su uso real (11 referencias internas, 9 ciclos) — desacoplamiento declarado vs real.
- `scripts/world/mundo_raiz.gd:17-36` — caso piloto de falso singleton (solo constantes).
- `scripts/world/bot_paseo_m09.gd:6` ("TEMPORAL (M09)") — único autoload con **0** referencias externas.
- `scripts/stream/pantalla_carga.gd:1-12` y `scripts/clock/reloj_hud.gd:1-12` — UI como singleton documentada en sus propios headers.
- `scripts/ui/services/tooltip_service.gd` y `notification_service.gd` — `extends CanvasLayer` con 11/8 `add_child`.
