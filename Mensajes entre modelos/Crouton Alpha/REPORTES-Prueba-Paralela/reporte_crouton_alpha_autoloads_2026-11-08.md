# Reporte de autoloads y singletons — Crouton Alpha

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Alcance:** `game/isla-ancestral/project.godot` sección `[autoload]` (líneas 19-137) + scripts `.gd` referenciados + dependencias entre ellos por mención textual del nombre.
**Método:** lectura directa de `project.godot`, conteo de líneas/funciones/signals/vars por archivo con script, grafo de referencias `autoload -> autoload` y búsqueda de ciclos por DFS, conteo de uso externo en los ~1.260 `.gd` del proyecto.

> No se ejecutó Godot. Las referencias son textuales (nombre del autoload mencionado en el código), por lo que un ciclo textual no implica necesariamente un ciclo de carga en `_ready()`; es una señal de acoplamiento bidireccional.

---

## 1. ¿Cuántos autoloads hay y cuáles son?

**Hay 116 autoloads** en `game/isla-ancestral/project.godot:19-137`.

Todos existen en disco (0 rutas rotas). Todos extienden `Node` salvo tres excepciones puntuales: `interacciones` (`Node,Resource`) y `IslandRegistry` (`Node,Node`) presentan doble `extends` detectado por regex por múltiples declaraciones `extends`/`class_name` en el archivo; no se encontró un autoload roto.

### Lista completa (orden de `project.godot`, líneas 21-137)

| # | Nombre | Archivo |
|---|--------|---------|
| 1 | TermsManager | `res://scripts/legal/terms_manager.gd` |
| 2 | EventBus | `res://scripts/core/event_bus.gd` |
| 3 | WorldState | `res://scripts/dialogos/world_state_service.gd` |
| 4 | DialogueManager | `res://scripts/dialogos/dialogue_manager.gd` |
| 5 | GameSettings | `res://scripts/core/game_settings.gd` |
| 6 | ServiceRegistry | `res://scripts/core/service_registry.gd` |
| 7 | GameLogger | `res://scripts/logging/logger.gd` |
| 8 | AnalyticsDirector | `res://scripts/analytics/analytics_director.gd` |
| 9 | TelemetryDirector | `res://scripts/telemetry/telemetry_director.gd` |
| 10 | SaveManager | `res://scripts/saving/save_manager.gd` |
| 11 | TimeCalendar | `res://scripts/time/time_calendar.gd` |
| 12 | ItemDatabase | `res://scripts/data/item_database.gd` |
| 13 | EconomyManager | `res://scripts/economia/economy_manager.gd` |
| 14 | SoftlockGuard | `res://scripts/core/softlock_guard.gd` |
| 15 | ShopManager | `res://scripts/shops/shop_manager.gd` |
| 16 | Inventario | `res://scripts/inventario/inventario_service.gd` |
| 17 | Friendship | `res://scripts/friendship/friendship_service.gd` |
| 18 | GameTime | `res://scripts/time/game_clock.gd` |
| 19 | RelojHud | `res://scripts/clock/reloj_hud.gd` |
| 20 | Bootstrap | `res://scripts/core/bootstrap.gd` |
| 21 | UIManager | `res://scripts/ui/core/ui_manager.gd` |
| 22 | TooltipService | `res://scripts/ui/services/tooltip_service.gd` |
| 23 | NotificationService | `res://scripts/ui/services/notification_service.gd` |
| 24 | TerrainLocator | `res://scripts/core/terrain_locator.gd` |
| 25 | VillagerManager | `res://scripts/npc/villager_manager.gd` |
| 26 | ControlInput | `res://scripts/controls/control_input.gd` |
| 27 | ResourceManager | `res://scripts/resources/resource_manager.gd` |
| 28 | mineria | `res://scripts/mineria/mining_manager.gd` |
| 29 | interacciones | `res://scripts/interacciones/interaction_manager.gd` |
| 30 | fauna_registry | `res://scripts/fauna/fauna_registry.gd` |
| 31 | fauna | `res://scripts/fauna/fauna_manager.gd` |
| 32 | credits_manager | `res://scripts/legal/credits_manager.gd` |
| 33 | MerchManager | `res://scripts/legal/merch_manager.gd` |
| 34 | animal_ai | `res://scripts/animales_ia/m65_animal_ai.gd` |
| 35 | coleccionables | `res://scripts/coleccionables/coleccionables_manager.gd` |
| 36 | hotbar | `res://scripts/inventario/hotbar_state.gd` |
| 37 | inventario_helper | `res://scripts/inventario/inventario_iter4.gd` |
| 38 | inventario_iter5 | `res://scripts/inventario/inventario_iter5.gd` |
| 39 | Localization | `res://scripts/localization/localization_manager.gd` |
| 40 | Balance | `res://scripts/balance/balance_service.gd` |
| 41 | Tutorial | `res://scripts/tutorial/tutorial_manager.gd` |
| 42 | ThemeService | `res://scripts/ui/theme/theme_service.gd` |
| 43 | Crafting | `res://scripts/crafting/crafting_service.gd` |
| 44 | AssetProfile | `res://scripts/rendimiento/asset_profile.gd` |
| 45 | BrandConfig | `res://scripts/brand/brand_config.gd` |
| 46 | DebugMenu | `res://scripts/debug/debug_menu.gd` |
| 47 | CatalogoTiendas | `res://scripts/shops/catalogo_tiendas.gd` |
| 48 | Farm | `res://scripts/farm/farm_service.gd` |
| 49 | Fishing | `res://scripts/fishing/fishing_manager.gd` |
| 50 | Weather | `res://scripts/clima/weather_service.gd` |
| 51 | Historia | `res://scripts/historia/story_manager.gd` |
| 52 | Historias | `res://scripts/historias/secondary_stories_service.gd` |
| 53 | Barter | `res://scripts/economia/barter_system.gd` |
| 54 | TravelService | `res://scripts/viajes/travel_service.gd` |
| 55 | CollectionRegistry | `res://scripts/museum/collection_registry.gd` |
| 56 | DonationService | `res://scripts/museum/donation_service.gd` |
| 57 | Diary | `res://scripts/diario/diary_service.gd` |
| 58 | PlayerProfile | `res://scripts/progresion/player_profile.gd` |
| 59 | ProgressionManager | `res://scripts/progresion/progression_manager.gd` |
| 60 | Achievements | `res://scripts/logros/achievement_service.gd` |
| 61 | Vehiculos | `res://scripts/vehiculos/vehicle_manager.gd` |
| 62 | Postgame | `res://scripts/postgame/postgame_manager.gd` |
| 63 | EscalasGlobales | `res://scripts/core/escalas_globales.gd` |
| 64 | AccesibilityManager | `res://scripts/accesibilidad/accesibilidad_manager.gd` |
| 65 | AnimationService | `res://scripts/animacion/animation_service.gd` |
| 66 | PhotoService | `res://scripts/foto/photo_service.gd` |
| 67 | Tiers | `res://scripts/herramientas158/tool_tier_system.gd` |
| 68 | AudioConfig | `res://scripts/audio/audio_config_service.gd` |
| 69 | DataStore | `res://scripts/datos/data_store.gd` |
| 70 | SubtitleManager | `res://scripts/ui/subtitle_manager.gd` |
| 71 | StreamManager | `res://scripts/stream/stream_manager.gd` |
| 72 | PantallaCarga | `res://scripts/stream/pantalla_carga.gd` |
| 73 | MonetizacionManager | `res://scripts/monetizacion/monetizacion_manager.gd` |
| 74 | TerrainProvider | `res://scripts/terrenos/terrain_provider.gd` |
| 75 | GameFlowManager | `res://scripts/core/game_flow_manager.gd` |
| 76 | SceneManager | `res://scripts/core/scene_manager.gd` |
| 77 | MotivacionManager | `res://scripts/motivacion/motivacion_manager.gd` |
| 78 | PlatformManager | `res://scripts/plataformas/platform_manager.gd` |
| 79 | WorldBible | `res://scripts/world/world_bible.gd` |
| 80 | MemoryMonitor | `res://scripts/rendimiento/memoria/memory_monitor.gd` |
| 81 | MusicDirector | `res://scripts/audio/music_director.gd` |
| 82 | AmbientDirector | `res://scripts/audio/ambient_director.gd` |
| 83 | SFXManager | `res://scripts/audio/sfx_manager.gd` |
| 84 | FeedbackDirector | `res://scripts/audio/feedback_director.gd` |
| 85 | NarrativeSound | `res://scripts/audio/narrative_sound.gd` |
| 86 | CrashReporter | `res://scripts/crash/crash_reporter.gd` |
| 87 | CiCdManager | `res://scripts/ci/cicd_manager.gd` |
| 88 | InstaladorConfig | `res://scripts/installer/instalador_config.gd` |
| 89 | MapManager | `res://scripts/mapa/mapa_manager.gd` |
| 90 | HardwareManager | `res://scripts/hardware/hardware_manager.gd` |
| 91 | BuildConfigManager | `res://scripts/build/build_config_manager.gd` |
| 92 | UpdateManager | `res://scripts/updates/update_manager.gd` |
| 93 | DevTools | `res://scripts/dev/dev_tools.gd` |
| 94 | MaterialesRecursos | `res://scripts/arte3d/materiales_recursos.gd` |
| 95 | BotPaseoM09 | `res://scripts/world/bot_paseo_m09.gd` |
| 96 | MundoRaiz | `res://scripts/world/mundo_raiz.gd` |
| 97 | SecurityManager | `res://scripts/security/security_manager.gd` |
| 98 | FontCatalog | `res://scripts/fonts/font_catalog.gd` |
| 99 | BackupManager | `res://scripts/backup/backup_manager.gd` |
| 100 | DlcManager | `res://scripts/dlc/dlc_manager.gd` |
| 101 | SupportManager | `res://scripts/support/support_manager.gd` |
| 102 | ModdingManager | `res://scripts/modding/modding_manager.gd` |
| 103 | UgcManager | `res://scripts/ugc/ugc_manager.gd` |
| 104 | CommunityManager | `res://scripts/community/community_manager.gd` |
| 105 | NPCManager | `res://scripts/ia_npc/npc_manager.gd` |
| 106 | eventos | `res://scripts/eventos/event_manager.gd` |
| 107 | EquipmentManager | `res://scripts/player/equipment_manager.gd` |
| 108 | NPCVisualDatabase | `res://scripts/data/npc_visual_database.gd` |
| 109 | WorldLocations | `res://scripts/data/world_locations.gd` |
| 110 | EnchantmentSystem | `res://scripts/enchantment/enchantment_system.gd` |
| 111 | TransportManager | `res://scripts/transporte/transport_manager.gd` |
| 112 | IslandRegistry | `res://scripts/islas/island_registry.gd` |
| 113 | gem_currency | `res://scripts/combat/gem_currency.gd` |
| 114 | combat_island | `res://scripts/combat/combat_island_system.gd` |
| 115 | Construccion | `res://scripts/construccion/build_manager.gd` |
| 116 | HouseManager | `res://scripts/houses/house_manager.gd` |

Tamaño total: **34.344 líneas GDScript** en autoloads; media **296 líneas**; mediana implícita muy inferior (16 superan 500 líneas, 48 superan 300). Total de funciones en autoloads: **2.726** (media 23,5 por autoload).

### Datos duros por autoload (top)

| Autoload | Líneas | Funciones | Signals | Vars | Autoloads referenciados (grados de salida) | Uso externo (archivos `.gd` que lo citan) |
|----------|--------|-----------|---------|------|--------------------------------------------|---------------------------------------------|
| DebugMenu (`debug_menu.gd`) | 1.308 | 107 | 3 | 135 | 16 | 2 |
| ProgressionManager (`progression_manager.gd`) | 959 | 55 | 5 | 134 | 10 | 1 |
| eventos (`event_manager.gd`) | 901 | 54 | 8 | 152 | 7 | 19 |
| Tutorial (`tutorial_manager.gd`) | 814 | 67 | 12 | 69 | 5 | 0 |
| Construccion (`build_manager.gd`) | 803 | 66 | 6 | 108 | 1 | 1 |
| VillagerManager (`villager_manager.gd`) | 777 | 53 | 9 | 98 | 6 | 4 |
| mineria (`mining_manager.gd`) | 768 | 59 | 7 | 90 | 3 | 1 |
| Friendship (`friendship_service.gd`) | 708 | 58 | 7 | 92 | 8 | 5 |
| TransportManager (`transport_manager.gd`) | 702 | 59 | 6 | 84 | 15 | 2 |
| DataStore (`data_store.gd`) | 650 | 38 | 7 | 93 | 3 | 3 |
| UIManager (`ui_manager.gd`) | 645 | 43 | 3 | 49 | 9 | 9 |
| MemoryMonitor (`memory_monitor.gd`) | 641 | 68 | 5 | 67 | 2 | 2 |
| Achievements (`achievement_service.gd`) | 622 | 39 | 3 | 89 | 11 | 0 |
| TelemetryDirector (`telemetry_director.gd`) | 533 | 41 | 3 | 41 | 5 | 1 |
| StreamManager (`stream_manager.gd`) | 527 | 41 | 5 | 42 | 2 | 1 |
| EventBus (`event_bus.gd`) | 199 | 0 | 54 | 16 | 7 | 39 |
| ServiceRegistry (`service_registry.gd`) | 75 | 7 | 0 | 3 | 0 | 7 |

El resto (99 autoloads) está por debajo de 500 líneas. El detalle por autoload con líneas/funciones/signals/vars y vecinos está en el análisis reproducido en la sección 4 del Anexo.

---

## 2. ¿Hay autoloads con demasiadas responsabilidades (dios-objeto)?

**Sí, al menos 6 candidatos claros** por combinación de líneas + funciones + vars + grado de salida:

1. **DebugMenu — `game/isla-ancestral/scripts/debug/debug_menu.gd:1-1308`.** 1.308 líneas, 107 funciones (máximo del proyecto, muy por encima de la media 23,5), 135 vars, 16 autoloads referenciados. Mezcla subsistemas heterogéneos: persistencia de estado (`_cargar_estado`, `save_config`, líneas 132-229), control de visibilidad e input (`show/hide/toggle`, `_input`, líneas 355-471), overlay FPS (líneas 502-515), comandos (`ejecutar_comando`, línea 596), teleport (`teleport_player`, línea 870), tiempo (`set_game_time`, línea 894), clima (`set_weather`, línea 917), inventario (`dar_objetos`, línea 937), dinero (`dar_dinero`, línea 950), misiones (`completar_mision`, línea 963), herramientas (línea 976), viajes (línea 993), sellos (línea 1006), toggles visuales (líneas 1019-1087), estación (línea 1096), avance de días (línea 1111), NPC (línea 1132), puzzle (línea 1156), chunks (línea 1190), vida del jugador (línea 1232), caché (línea 1248), consola del logger (líneas 1261-1283), entorno/diagnóstico (líneas 633-812), metadatos (líneas 815-839). Es un dios-objeto de debug: cualquier cambio en economía, clima o inventario que necesite un comando de debug toca este archivo. La propia cabecera reconoce extracciones previas a `diagnostic_exporter.gd` y `debug_commands.gd` (líneas 21-26), pero el núcleo sigue centraludiendo todo.

2. **ProgressionManager — `scripts/progresion/progression_manager.gd`, 959 líneas, 55 funciones, 134 vars, 10 vecinos.** Concentra progresión, logros parciales y persistencia, y referencia a `Barter`, `CollectionRegistry`, `EconomyManager`, `EventBus`, `GameLogger`, `GameTime`, `Historia`, `PlayerProfile`, `SaveManager` y `eventos`. Su uso externo es 1 solo archivo: casi todo su acoplamiento es de salida. Con tanto estado propio, es difícil testearlo sin montar 10 autoloads.

3. **eventos — `scripts/eventos/event_manager.gd`, 901 líneas, 54 funciones, 152 vars (máximo de vars), 7 vecinos.** Es el autoload más usado del proyecto junto a `EventBus` (19 archivos la citan) y a la vez uno de los más grandes. Mezcla calendario de eventos, persistencia, amistad, inventario, tiempo, clima. Es el segundo dios-objeto funcional (no de debug).

4. **Tutorial — `scripts/tutorial/tutorial_manager.gd`, 814 líneas, 67 funciones, 12 signals (máximo de signals fuera de EventBus).** 0 usos externos detectados: todo su acoplamiento es de salida (`EventBus`, `GameLogger`, `SaveManager`, `VillagerManager`, `eventos`). Un hotspot de señalización que nadie fuera de sí mismo consume directamente por el nombre viejo, probablemente por `eventos`/`EventBus`.

5. **Construccion — `scripts/construccion/build_manager.gd`, 803 líneas, 66 funciones, 108 vars, solo 1 vecino (`Inventario`).** Tamaño enorme pero acoplamiento de salida bajo: es un monolito de dominio (construcción: rejilla, persistencia, validación, circulación). No es dios-objeto transversal, sí es “archivo dios” dentro de su dominio y candidato a partir en subservicios (rejilla / persistencia / validación), igual que `Tutorial`.

6. **TransportManager — `scripts/transporte/transport_manager.gd`, 702 líneas, 59 funciones, 15 vecinos (máximo grado de salida junto a DebugMenu).** Referencia a `DialogueManager`, `EconomyManager`, `EventBus`, `Friendship`, `GameLogger`, `GameTime`, `Historia`, `Inventario`, `SaveManager`, `ServiceRegistry`, `TimeCalendar`, `TravelService`, `Weather`, `WorldState` y `eventos`. Es el hub de acoplamiento: 15 sistemas distintos en un solo autoload de transporte. Uso externo: 2 archivos.

Casos semilla adicionales: `VillagerManager` (777 líneas, 53 funciones, 6 vecinos), `mineria` (768 líneas, 59 funciones, 3 vecinos), `Friendship` (708 líneas, 58 funciones, 8 vecinos), `DataStore` (650 líneas, 38 funciones, 93 vars) y `UIManager` (645 líneas, 43 funciones, 9 vecinos). No los califico como dios-objeto transversal, pero sí como archivos monolíticos que superan con holgura el límite del propio linter del proyecto (`linter/class_max_lines=300`, `project.godot:174`; 48 autoloads lo superan).

**Patrón secundario:** `ServiceRegistry` (`service_registry.gd:1-75`, 75 líneas, 7 funciones, 0 señales, 0 vecinos) es el anti-dios-objeto: diccionario con `register/get_service/has/unregister/contracts/list_registered/validate_required` (líneas 22-72). Es la pieza que permite desacoplar sin seguir añadiendo autoloads globales, pero su uso externo es solo 7 archivos y ~30 autoloads lo mencionan solo como `/root/ServiceRegistry` en `get_node_or_null`, no como servicio resuelto. Está infrautilizado frente a su diseño.

**Autoloads “display/config” con 0 uso externo y tamaño no trivial** (señal de posible lastre o de acceso por otra vía): `Tutorial` (814 líneas, 0 usos), `Achievements` (622 líneas, 0 usos), `Farm` (515 líneas, 0 usos), `Historias` (470 líneas, 0 usos), `Balance`, `BrandConfig`, `CatalogoTiendas`, `Vehiculos`, `Postgame`, `Tiers`, `EscalasGlobales`, `SubtitleManager`, `PantallaCarga`, `GameFlowManager`, `SceneManager`, `MotivacionManager`, `WorldBible`, `MusicDirector`, `SFXManager`, `NarrativeSound`, `CrashReporter`, `CiCdManager`, `InstaladorConfig`, `MapManager`, `HardwareManager`, `BuildConfigManager`, `UpdateManager`, `MaterialesRecursos`, `BotPaseoM09`, `FontCatalog`, `BackupManager`, `ModdingManager`, `CommunityManager`, `NPCVisualDatabase`, `WorldLocations`, `EnchantmentSystem`, `combat_island`, `TermsManager`, `TooltipService`, `MerchManager`, `inventario_helper`, `Transaction…`. Ver §4 para la tabla de uso externo completa.

---

## 3. ¿Hay dependencias circulares entre autoloads?

**Sí. Se detectaron ciclos textuales** (grafo dirigido `A -> B` si el código de A menciona el nombre de B). Los ciclos no garantizan un ciclo de arranque bloqueante — Godot carga los autoloads en el orden de `project.godot` y la mayoría de las referencias son perezosas (`get_node_or_null("/root/X")` o en métodos, no en `_ready` destructivo) — pero sí prueban acoplamiento bidireccional, que es lo que rompe la separación en capas.

Ciclos elementales encontrados (recorrido DFS sobre el grafo de 116 nodos):

### Ciclos cortos (2-3 nodos) — los más preocupantes

- `Inventario -> ShopManager -> Inventario` (`scripts/inventario/inventario_service.gd` menciona `ShopManager`; `scripts/shops/shop_manager.gd` menciona `Inventario` y `CatalogoTiendas`/`EconomyManager`).
- `ShopManager -> EconomyManager -> ShopManager` (viceversa).
- `ShopManager -> CatalogoTiendas -> ShopManager`.
- `Inventario -> ShopManager -> CatalogoTiendas -> Crafting -> Inventario` (circuito de 4).
- `SaveManager -> Inventario -> ShopManager -> EconomyManager -> SaveManager` (circuito de 4 contra el servicio de guardado).
- `SaveManager -> Inventario -> SaveManager` (2 nodos).
- `SaveManager -> DataStore -> SaveManager` (2 nodos).
- `GameTime -> eventos -> GameTime` (2 nodos).
- `eventos -> SaveManager -> eventos` (2 nodos).
- `TimeCalendar -> VillagerManager -> TimeCalendar` (2 nodos).
- `PlayerProfile -> ProgressionManager -> PlayerProfile` (2 nodos).
- `fauna -> fauna_registry -> fauna` y `animal_ai -> fauna -> fauna_registry -> animal_ai` (circuito de 3 en fauna).
- `ThemeService -> UIManager -> ThemeService` (2 nodos).
- `Godot-like`: `Localization <-> DataStore` vía `AudioConfig`/`Localization`/`GameSettings` (`SaveManager -> SceneManager -> Bootstrap -> DialogueManager -> Localization -> GameSettings -> AudioConfig -> SaveManager`, ciclo de 8 que vuelve al guardado).

### Hubs de ciclos (nodos que participan en muchos ciclos)

- **SaveManager** (17 usos externos): `SaveManager <-> eventos`, `SaveManager <-> DataStore`, `SaveManager <-> Inventario`, `SaveManager -> SceneManager -> Bootstrap -> ... -> SaveManager`, `SaveManager -> SceneManager -> GameFlowManager -> EventBus -> ... -> SaveManager`. Es el centro del ciclo mayor: casi cualquier camino largo termina en SaveManager.
- **eventos** (901 líneas, 19 usos): `GameTime <-> eventos`, `TimeCalendar -> VillagerManager -> GameTime -> eventos -> TimeCalendar`, `eventos -> SaveManager -> SceneManager -> Bootstrap -> ... -> eventos`. Es el otro hub.
- **Inventario / ShopManager / EconomyManager**: triángulo cerrado con `Crafting` y `CatalogoTiendas` (circuito económico completo).
- **EventBus** (54 signals, 39 usos): `EventBus -> Fishing -> TimeCalendar -> VillagerManager -> GameTime -> eventos -> SaveManager -> EventBus`. EventBus referencia a 7 autoloads (incluidos `Bootstrap`, `Fishing`, `GameFlowManager`, `SaveManager`, `SceneManager`, `eventos`, `hotbar`), lo que lo convierte también en hub de acoplamiento de salida pese a ser solo un bus de señales.
- **Bootstrap** (referencia a 14 autoloads: `Balance`, `Crafting`, `DialogueManager`, `EconomyManager`, `EventBus`, `Farm`, `Fishing`, `GameFlowManager`, `Inventario`, `SceneManager`, `ServiceRegistry`, `ShopManager`, `TimeCalendar`, `eventos`): cierra ciclos largos porque casi todo el mundo lo menciona de vuelta vía `SceneManager`/`GameFlowManager`.

### Interpretación

El estándar del proyecto es **SaveManager <-> Sistema del dominio**: casi todo autoload de juego menciona `SaveManager` y `SaveManager` o `DataStore` menciona de vuelta al dominio (persistencia bidireccional). Eso produce decenas de ciclos textuales 2-nodos. En la práctica Godot no los bloquea porque las llamadas son diferidas en métodos, pero impide razonar “qué se carga antes que qué” y obliga a `get_node_or_null` defensivo en todas partes (ej. `debug_menu.gd:538-541` accede a `/root/GameLogger` con guarda; `reloj_hud.gd:48-52` documenta el problema de acceso a autoloads aún no cargados).

---

## 4. ¿Hay autoloads que podrían ser nodos de escena en lugar de globales?

**Sí, al menos 14 candidatos claros** agrupados por motivo. El criterio: el autoload tiene ciclo de vida atado a una escena (HUD, pantalla, menú, bot de paseo, mundo concreto), o su uso externo es 0-1 (nunca se consume globalmente, solo por su escena), o duplica a un nodo de escena ya existente.

### 4.1 UI de escena (HUD/pantallas) — deberían ser nodos en la escena de UI

- **RelojHud — `scripts/clock/reloj_hud.gd:1-120`.** La propia cabecera (líneas 5-7) dice “HUD Reloj — capa de DISPLAY” y que consume a `GameTime` (`/root/GameTime`). Extiende `Node` (línea 19), no `Control`/`CanvasItem`; es un formateador con constantes visuales (`COLOR_ESTACION`, líneas 35-41; `HORAS_POR_SESION`, líneas 28-33). Como autoload vive siempre aunque no haya HUD; como nodo hijo de un `HUD`/`CanvasLayer` en la escena principal compartiría ciclo de vida con la pantalla que lo dibuja. Uso externo: 3 archivos (casi nulo frente a su responsabilidad visual).
- **UIManager — `scripts/ui/core/ui_manager.gd`, 645 líneas, 43 funciones, 9 vecinos, 9 usos externos.** Gestiona pantallas y HUD global; su ciclo de vida es el de la partida, pero su implementación presume árbol de UI (`AccesibilityManager`, `ControlInput`, `ThemeService`, `TooltipService`). Permitiría instanciarse por escena (`main_island.tscn`) y liberarse al cambiar de escena.
- **PantallaCarga — `scripts/stream/pantalla_carga.gd`, uso externo 0.** Por nombre y por su vecino `StreamManager` (líneas 527, 41 funciones) es una pantalla de carga: típico nodo de escena de UI, no un singleton permanente. Referencia a `Bootstrap`, `GameTime`, `SceneManager`, `StreamManager`.
- **SubtitleManager — `scripts/ui/subtitle_manager.gd`, uso externo 0.** Subtítulos son UI de escena (CanvasLayer con Labels); como autoload consume `AudioConfig` y `DataStore` pero nadie lo cita por nombre fuera de sí mismo.
- **TooltipService — `scripts/ui/services/tooltip_service.gd`, uso externo 0.** Solo referencia a `Localization`. Tooltips son controles UI.
- **NotificationService — `scripts/ui/services/notification_service.gd`, uso externo 2.** Notificaciones también son UI efímera de escena.
- **ThemeService — `scripts/ui/theme/theme_service.gd`, uso externo 2.** Tema visual; perfectamente modelable como recurso/nodo de UI por escena. Además forma ciclo con `UIManager` (`ThemeService -> UIManager -> ThemeService`).
- **DebugMenu — `scripts/debug/debug_menu.gd:1-1308`.** Ya se autodesactiva en builds de release (`OS.is_debug_build()`, línea 72-74). Como autoload existe siempre en memoria (1.308 líneas compiladas). Como nodo en una escena de debug (cargada solo en desarrollo) dejaría de existir en release y respetaría el ciclo de vida de la escena de debug. Su uso externo es 2 archivos.

### 4.2 Mundo/escena concreta

- **MundoRaiz — `scripts/world/mundo_raiz.gd`, 5 usos externos.** La raíz de la isla IS una escena (`run/main_scene="res://scenes/main_island.tscn"`, `project.godot:15`). Un autoload `MundoRaiz` que referencia a `fauna` compite con el nodo raíz de la escena principal: el mundo debería ser el nodo de la escena, no un global además de ella.
- **BotPaseoM09 — `scripts/world/bot_paseo_m09.gd`, uso externo 0.** Bot de paseo de prueba (M09): herramienta de escena/test, no servicio global. Verificado en disco que el archivo existe.
- **TerrainProvider — `scripts/terrenos/terrain_provider.gd`, uso externo 2** y **TerrainLocator — `scripts/core/terrain_locator.gd`, uso externo 6.** Ambos proveen altura/terreno de la escena activa; deberían obtenerse desde la escena de mundo (`main_island`) o inyectarse, no desde un global que esconde qué terreno está activo. Hoy `DebugMenu` los busca con `get_node_or_null` (líneas 874-878) porque no hay otra vía.
- **MapManager — `scripts/mapa/mapa_manager.gd`, uso externo 0** (solo referenciado por sí mismo vía `ServiceRegistry`/`TerrainLocator`). El mapa es UI de escena.
- **Navigation/AI de escena**: `NPCManager` (`scripts/ia_npc/npc_manager.gd`, 1 uso externo) y `animal_ai` (`scripts/animales_ia/m65_animal_ai.gd`, 1 uso externo) compiten con `VillagerManager` (`scripts/npc/villager_manager.gd`, 777 líneas) — tres managers de NPC/animales como globales en vez de un nodo `NPCs` en la escena de mundo que instancie los agentes.

### 4.3 Config / datos estáticos (podrían ser Resources, no autoloads)

- **BrandConfig — `scripts/brand/brand_config.gd`, uso externo 0.** Config de marca: Resource estático cargable, no singleton vivo.
- **FontCatalog — `scripts/fonts/font_catalog.gd`, uso externo 0.** Catálogo de fuentes: Resource.
- **EscalasGlobales — `scripts/core/escalas_globales.gd`, uso externo 0.** Escalas: constantes/config, no nodo.
- **MaterialesRecursos — `scripts/arte3d/materiales_recursos.gd`, uso externo 0.** Materiales: Resources.
- **InstaladorConfig — `scripts/installer/instalador_config.gd`, uso externo 0.** Config de instalador.
- **BuildConfigManager — `scripts/build/build_config_manager.gd`, uso externo 0** y **CiCdManager — `scripts/ci/cicd_manager.gd`, uso externo 0.** Herramientas de build/CI como autoloads en runtime: no deberían ni compilarse en el juego exportado.
- **DevTools — `scripts/dev/dev_tools.gd`, uso externo 1.** Herramienta de desarrollo.
- **TermsManager (`scripts/legal/terms_manager.gd`, línea 21, sin `*`), MerchManager, credits_manager.** Legal/comercial: lógica que pertenece a una escena de ajustes/tienda, no a 3 globales permanentes. `TermsManager` además es el único autoload sin asterisco (carga deshabilitable), señal de que su globalidad nunca fue segura.

### 4.4 Singletons iterativos (deuda de diseño)

- **inventario_iter4.gd / inventario_iter5.gd / inventario_helper / hotbar / Inventario** (5 autoloads para el mismo dominio). `inventario_helper` (uso externo 0) e `inventario_iter5` (uso externo 2) deberían ser nodos/servicios internos de `Inventario`, no globales competidores. `hotbar` (4 usos) es estado de UI del inventario.
- **fauna / fauna_registry / animal_ai / coleccionables** (4 autoloads para fauna). `fauna -> fauna_registry -> fauna` es ciclo directo; `coleccionables` referencia a `fauna`, `fauna_registry` y `mineria`. Un nodo `Fauna` en la escena de mundo con 3 subservicios internos resolvería el ciclo.
- **DialogueManager / WorldState / Historia / Historias / Tutorial / eventos** (6 autoloads para narrativa/eventos). `DialogueManager -> WorldState`, `Historia -> WorldState`, `Historias -> Historia/WorldState`, `Tutorial -> eventos`, `eventos` (901 líneas) como hub. Al menos `Tutorial` e `Historias` (0 usos externos cada uno) podrían ser nodos de la escena de diálogo/quest activa.

---

## 5. Acciones sugeridas para reducir acoplamiento

### Acción 1 — Congelar el alta de autoloads y migrar UI/debug a nodos de escena (quitar ~20 globales sin perder función)

**Qué:** imponer moratoria de nuevos autoloads (todo autoload nuevo requiere justificante en PR). Migrar en oleadas:

- **Oleada A (UI, dentro de `main_island.tscn`/`UI`):** `RelojHud` (`reloj_hud.gd:1-120`), `PantallaCarga`, `SubtitleManager`, `TooltipService`, `NotificationService`, `ThemeService`, `MapManager` pasan a nodos hijos de un `CanvasLayer`/`HUD` de la escena principal. `ThemeService` deja de ciclar con `UIManager` porque ambos cuelgan del mismo padre.
- **Oleada B (debug/dev):** `DebugMenu` (`debug_menu.gd:1-1308`), `DevTools`, `CiCdManager`, `BuildConfigManager` y `BotPaseoM09` pasan a escena de debug cargada solo si `OS.is_debug_build()`. En release desaparecen del árbol, no solo de `_process`.
- **Oleada C (config estática):** `BrandConfig`, `FontCatalog`, `EscalasGlobales`, `MaterialesRecursos`, `InstaladorConfig` pasan a `Resource` (`.tres`/`.res`) cargados por quien los necesite, no por `ProjectSettings`.

**Por qué reduce acoplamiento:** elimina ~15-20 nodos del grafo y con ellos sus aristas (p. ej. las 16 relativas de `DebugMenu`). El ciclo `ThemeService <-> UIManager` desaparece. El HUD y la pantalla de carga dejan de existir cuando la escena no está activa, lo que acota su `_process` y sus señales. Es la acción de mayor retorno: no cambia lógica, cambia ciclo de vida.

**Criterio de cierre verificable:** `project.godot` pasa de 116 a ≤ 95 autoloads; los migrados ya no aparecen en `[autoload]`; `grep` sobre `scripts/` muestra 0 menciones a los nombres migrados como `/root/X` (sustituidas por referencia al nodo de escena).

### Acción 2 — Romper los hubs del ciclo y fijar capas (EventBus + ServiceRegistry + SaveManager unidireccional)

**Qué:** hoy el grafo es bidireccional porque **EventBus (39 usos)**, **SaveManager (17 usos)** y **eventos (19 usos)** son hubs y casi todo el mundo los referencia directamente. Tres reglas concretas:

1. **EventBus solo señales, sin lógica ni referencias de salida.** Hoy `scripts/core/event_bus.gd` (199 líneas, 54 signals, 0 funciones) referencia a 7 autoloads (`Bootstrap`, `Fishing`, `GameFlowManager`, `SaveManager`, `SceneManager`, `eventos`, `hotbar`). Eliminar esas 7 referencias (el bus no necesita conocer a sus emisores/consumidores) lo deja como bus puro y corta el ciclo `EventBus -> Fishing -> ... -> SaveManager -> EventBus`.
2. **SaveManager/DataStore dejan de conocer a los dominios.** Hoy `SaveManager -> Inventario -> ShopManager -> EconomyManager -> SaveManager` y `SaveManager -> DataStore -> SaveManager`. Invertir: el dominio llama a `SaveManager.guardar(id, datos)` / `SaveManager.cargar(id)` por **contrato string** (ya existe `ServiceRegistry.register/get_service`, `service_registry.gd:22-38`), y `SaveManager` nunca llama de vuelta al dominio. Las suscripciones de guardado se hacen por señales de `EventBus`, no por referencia directa.
3. **Respetar la capa de transmisiones del propio proyecto:** capa `core` (`EventBus`, `ServiceRegistry`, `GameLogger`, `SaveManager` solo como infraestructura de persistencia) ← capa `servicios` (`GameTime`, `ItemDatabase`, `TerrainLocator`) ← capa `dominio` (`Inventario`, `Friendship`, `Farm`, `Fishing`…). Ningún servicio de capa superior referencia a uno de capa inferior salvo por `ServiceRegistry`/`EventBus`. La capa ya existe en carpetas (`scripts/core/`, `scripts/data/`, `scripts/time/`, `scripts/economia/`); falta hacerla cumplir en el código.

**Por qué reduce acoplamiento:** elimina los ciclos 2-nodos `SaveManager <-> DataStore`, `Inventario <-> ShopManager`, `GameTime <-> eventos`, `TimeCalendar <-> VillagerManager` y el ciclo largo de 8 nodos que vuelve a `SaveManager`. `ServiceRegistry` (75 líneas, hoy infrautilizado con 7 usos externos) pasa a ser la única vía de resolución entre capas. `eventos` (901 líneas, 19 usos) deja de ser hub: sus emisores pasan por `EventBus` en vez de citarlo directo.

**Criterio de cierre verificable:** re-ejecutar el grafo de este reporte; 0 ciclos de longitud 2; `event_bus.gd` con 0 referencias a otros autoloads; `save_manager.gd` con 0 referencias directas a autoloads de dominio (solo `DataStore` como almacén o contratos string).

---

## Conclusión final

**El proyecto tiene 116 autoloads (34.344 líneas, 2.726 funciones), cifra muy por encima de lo sostenible para un juego indie.** La distribución es bimodal: una cola de ~48 autoloads de 300+ líneas (16 superan 500; el linter del propio proyecto fija 300 como máximo de clase en `project.godot:174`) y una cola de servicios pequeños. Hay **dios-objetos confirmados** (`DebugMenu` 1.308 líneas/107 funciones/16 vecinos, `ProgressionManager`, `eventos`, `Tutorial`, `TransportManager`), **ciclos textuales extensos** centrados en `SaveManager`, `eventos`, `Inventario/ShopManager/EconomyManager`, `EventBus` y `Bootstrap`, y **~20 autoloads que deberían ser nodos de escena** (HUD, pantalla de carga, subtítulos, mapa, mundo, debug, builds) o **Resources estáticos** (brand, fonts, materiales). Las dos acciones propuestas (congelar + migrar UI/debug; romper hubs y fijar capas con `EventBus`/`ServiceRegistry`) son mecánicas, verificables con el mismo grafo de este reporte, y no requieren reescribir lógica de juego: requieren cambiar ciclo de vida y dirección de las referencias.

---

## Anexo A — Archivos y líneas clave

| # | Archivo | Líneas | Rol en el análisis |
|---|---------|--------|--------------------|
| A1 | `game/isla-ancestral/project.godot` | 19-137 | Sección `[autoload]`, 116 entradas; 15 `run/main_scene`, 173-175 límites del linter |
| A2 | `game/isla-ancestral/scripts/debug/debug_menu.gd` | 1-1308 (leído 1-1298) | Dios-objeto #1; 107 funciones; 16 vecinos; comandos teleport/tiempo/clima/inventario/economía/misiones en 862-1283 |
| A3 | `game/isla-ancestral/scripts/core/service_registry.gd` | 1-75 | Infrautilizado (7 usos); contrato `register/get_service` en 22-38 |
| A4 | `game/isla-ancestral/scripts/clock/reloj_hud.gd` | 1-120 | HUD como autoload (candidato a nodo); acceso a `GameTime` en 46-52 |
| A5 | `game/isla-ancestral/scripts/progresion/progression_manager.gd` | — (959 líneas) | Dios-objeto #2; 10 vecinos |
| A6 | `game/isla-ancestral/scripts/eventos/event_manager.gd` | — (901 líneas) | Hub de ciclos; 19 usos externos; 152 vars |
| A7 | `game/isla-ancestral/scripts/core/event_bus.gd` | — (199 líneas, 54 signals) | Bus con 7 referencias de salida; 39 usos externos |
| A8 | `game/isla-ancestral/scripts/saving/save_manager.gd` | — | Hub de ciclos; 17 usos externos |
| A9 | `game/isla-ancestral/scripts/time/game_clock.gd` | — | `GameTime`; 17 usos externos; ciclo con `eventos` |
| A10 | `game/isla-ancestral/scripts/inventario/inventario_service.gd` | — (444 líneas) | Ciclo con `ShopManager` |

## Anexo B — Requisitos del encargo

- (1) ¿Cuántos autoloads y cuáles? → 116, lista completa en §1.
- (2) ¿Dios-objetos? → Sí, §2 (6 confirmados + 5 semilla + infrautilización de `ServiceRegistry`).
- (3) ¿Dependencias circulares? → Sí, §3 (ciclos de 2-4 nodos y ciclo largo de 8; hubs identificados).
- (4) ¿Candidatos a nodo de escena? → Sí, §4 (≈20 autoloads agrupados en UI/mundo/config/singletons iterativos).
- (5) 2 acciones para reducir acoplamiento → §5 (A: moratoria + migración a escena; B: romper hubs y fijar capas).
- Archivo y conclusión final → Conclusión final.
- Idioma español → este reporte.

## Anexo C — Método y límites

- Conteo de líneas/funciones/signals/vars por regex sobre texto (`^\s*func`, `^\s*signal`, `^\s*var`). Las funciones con `static func`, lambdas o `class_name` internas pueden infracontarse.
- Grafo: arista `A -> B` si el texto de A contiene la palabra `B` como token (`\bB\b`). No distingue entre referencia real (`/root/B`, `B.metodo`) y mención en comentario/string. Los ciclos listados son **señales de acoplamiento**, no prueba de ciclo de arranque bloqueante. La verificación de ciclo de carga requeriría ejecutar Godot headless y observar el orden de `_ready` (fuera de alcance de este análisis estático).
- Uso externo: nº de archivos `.gd` (sobre ~1.260 en `game/isla-ancestral/scripts`) que mencionan el nombre seguido de `.`. `TermsManager` no lleva `*` en `project.godot` (autoload deshabilitado por defecto); su uso externo contado es 0.
- No se modificó código. Este análisis se escribió con un script temporal (`analizar_autoloads.py`) fuera del árbol del juego; la salida completa de conteos se reproduce en los tablas.
