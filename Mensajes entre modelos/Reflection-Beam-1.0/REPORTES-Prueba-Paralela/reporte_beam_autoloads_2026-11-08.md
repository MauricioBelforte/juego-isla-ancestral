# Reporte: Análisis de Autoloads — isla-ancestral

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Proyecto:** game/isla-ancestral (Godot 4.7)
**Fuente:** project.godot → sección [autoload]

## 1. Cantidad y listado de autoloads

Total de autoloads registrados en `project.godot`: **116**.

| # | Nombre (global) | Ruta | Líneas | Funcs | Señales |
|---|-----------------|------|--------|-------|---------|
| 1 | `TermsManager` | `res://scripts/legal/terms_manager.gd` | 72 | 8 | 3 |
| 2 | `EventBus` | `res://scripts/core/event_bus.gd` | 199 | 0 | 54 |
| 3 | `WorldState` | `res://scripts/dialogos/world_state_service.gd` | 132 | 14 | 0 |
| 4 | `DialogueManager` | `res://scripts/dialogos/dialogue_manager.gd` | 427 | 27 | 7 |
| 5 | `GameSettings` | `res://scripts/core/game_settings.gd` | 81 | 4 | 1 |
| 6 | `ServiceRegistry` | `res://scripts/core/service_registry.gd` | 75 | 9 | 0 |
| 7 | `GameLogger` | `res://scripts/logging/logger.gd` | 384 | 36 | 1 |
| 8 | `AnalyticsDirector` | `res://scripts/analytics/analytics_director.gd` | 232 | 19 | 1 |
| 9 | `TelemetryDirector` | `res://scripts/telemetry/telemetry_director.gd` | 533 | 41 | 3 |
| 10 | `SaveManager` | `res://scripts/saving/save_manager.gd` | 329 | 24 | 4 |
| 11 | `TimeCalendar` | `res://scripts/time/time_calendar.gd` | 274 | 41 | 6 |
| 12 | `ItemDatabase` | `res://scripts/data/item_database.gd` | 140 | 12 | 1 |
| 13 | `EconomyManager` | `res://scripts/economia/economy_manager.gd` | 199 | 20 | 3 |
| 14 | `SoftlockGuard` | `res://scripts/core/softlock_guard.gd` | 178 | 12 | 3 |
| 15 | `ShopManager` | `res://scripts/shops/shop_manager.gd` | 346 | 23 | 7 |
| 16 | `Inventario` | `res://scripts/inventario/inventario_service.gd` | 444 | 28 | 6 |
| 17 | `Friendship` | `res://scripts/friendship/friendship_service.gd` | 708 | 58 | 7 |
| 18 | `GameTime` | `res://scripts/time/game_clock.gd` | 263 | 29 | 5 |
| 19 | `RelojHud` | `res://scripts/clock/reloj_hud.gd` | 120 | 9 | 1 |
| 20 | `Bootstrap` | `res://scripts/core/bootstrap.gd` | 223 | 11 | 0 |
| 21 | `UIManager` | `res://scripts/ui/core/ui_manager.gd` | 645 | 43 | 3 |
| 22 | `TooltipService` | `res://scripts/ui/services/tooltip_service.gd` | 235 | 13 | 0 |
| 23 | `NotificationService` | `res://scripts/ui/services/notification_service.gd` | 203 | 13 | 0 |
| 24 | `TerrainLocator` | `res://scripts/core/terrain_locator.gd` | 73 | 7 | 0 |
| 25 | `VillagerManager` | `res://scripts/npc/villager_manager.gd` | 777 | 53 | 9 |
| 26 | `ControlInput` | `res://scripts/controls/control_input.gd` | 388 | 28 | 1 |
| 27 | `ResourceManager` | `res://scripts/resources/resource_manager.gd` | 367 | 31 | 3 |
| 28 | `mineria` | `res://scripts/mineria/mining_manager.gd` | 768 | 59 | 7 |
| 29 | `interacciones` | `res://scripts/interacciones/interaction_manager.gd` | 340 | 29 | 7 |
| 30 | `fauna_registry` | `res://scripts/fauna/fauna_registry.gd` | 208 | 17 | 3 |
| 31 | `fauna` | `res://scripts/fauna/fauna_manager.gd` | 133 | 13 | 0 |
| 32 | `credits_manager` | `res://scripts/legal/credits_manager.gd` | 330 | 30 | 6 |
| 33 | `MerchManager` | `res://scripts/legal/merch_manager.gd` | 296 | 30 | 0 |
| 34 | `animal_ai` | `res://scripts/animales_ia/m65_animal_ai.gd` | 351 | 22 | 0 |
| 35 | `coleccionables` | `res://scripts/coleccionables/coleccionables_manager.gd` | 231 | 20 | 3 |
| 36 | `hotbar` | `res://scripts/inventario/hotbar_state.gd` | 117 | 12 | 0 |
| 37 | `inventario_helper` | `res://scripts/inventario/inventario_iter4.gd` | 336 | 32 | 0 |
| 38 | `inventario_iter5` | `res://scripts/inventario/inventario_iter5.gd` | 344 | 26 | 0 |
| 39 | `Localization` | `res://scripts/localization/localization_manager.gd` | 377 | 32 | 1 |
| 40 | `Balance` | `res://scripts/balance/balance_service.gd` | 180 | 29 | 0 |
| 41 | `Tutorial` | `res://scripts/tutorial/tutorial_manager.gd` | 814 | 67 | 12 |
| 42 | `ThemeService` | `res://scripts/ui/theme/theme_service.gd` | 66 | 7 | 0 |
| 43 | `Crafting` | `res://scripts/crafting/crafting_service.gd` | 459 | 33 | 9 |
| 44 | `AssetProfile` | `res://scripts/rendimiento/asset_profile.gd` | 158 | 14 | 0 |
| 45 | `BrandConfig` | `res://scripts/brand/brand_config.gd` | 46 | 3 | 0 |
| 46 | `DebugMenu` | `res://scripts/debug/debug_menu.gd` | 1308 | 107 | 3 |
| 47 | `CatalogoTiendas` | `res://scripts/shops/catalogo_tiendas.gd` | 168 | 9 | 0 |
| 48 | `Farm` | `res://scripts/farm/farm_service.gd` | 515 | 42 | 8 |
| 49 | `Fishing` | `res://scripts/fishing/fishing_manager.gd` | 496 | 38 | 6 |
| 50 | `Weather` | `res://scripts/clima/weather_service.gd` | 230 | 22 | 0 |
| 51 | `Historia` | `res://scripts/historia/story_manager.gd` | 255 | 20 | 0 |
| 52 | `Historias` | `res://scripts/historias/secondary_stories_service.gd` | 470 | 31 | 1 |
| 53 | `Barter` | `res://scripts/economia/barter_system.gd` | 214 | 16 | 2 |
| 54 | `TravelService` | `res://scripts/viajes/travel_service.gd` | 380 | 29 | 5 |
| 55 | `CollectionRegistry` | `res://scripts/museum/collection_registry.gd` | 364 | 25 | 2 |
| 56 | `DonationService` | `res://scripts/museum/donation_service.gd` | 95 | 4 | 3 |
| 57 | `Diary` | `res://scripts/diario/diary_service.gd` | 407 | 28 | 0 |
| 58 | `PlayerProfile` | `res://scripts/progresion/player_profile.gd` | 117 | 13 | 0 |
| 59 | `ProgressionManager` | `res://scripts/progresion/progression_manager.gd` | 959 | 55 | 5 |
| 60 | `Achievements` | `res://scripts/logros/achievement_service.gd` | 622 | 39 | 3 |
| 61 | `Vehiculos` | `res://scripts/vehiculos/vehicle_manager.gd` | 203 | 17 | 0 |
| 62 | `Postgame` | `res://scripts/postgame/postgame_manager.gd` | 283 | 21 | 2 |
| 63 | `EscalasGlobales` | `res://scripts/core/escalas_globales.gd` | 56 | 4 | 0 |
| 64 | `AccesibilityManager` | `res://scripts/accesibilidad/accesibilidad_manager.gd` | 461 | 37 | 8 |
| 65 | `AnimationService` | `res://scripts/animacion/animation_service.gd` | 134 | 8 | 4 |
| 66 | `PhotoService` | `res://scripts/foto/photo_service.gd` | 406 | 19 | 4 |
| 67 | `Tiers` | `res://scripts/herramientas158/tool_tier_system.gd` | 360 | 27 | 3 |
| 68 | `AudioConfig` | `res://scripts/audio/audio_config_service.gd` | 309 | 27 | 3 |
| 69 | `DataStore` | `res://scripts/datos/data_store.gd` | 650 | 38 | 7 |
| 70 | `SubtitleManager` | `res://scripts/ui/subtitle_manager.gd` | 359 | 30 | 4 |
| 71 | `StreamManager` | `res://scripts/stream/stream_manager.gd` | 527 | 41 | 5 |
| 72 | `PantallaCarga` | `res://scripts/stream/pantalla_carga.gd` | 186 | 16 | 1 |
| 73 | `MonetizacionManager` | `res://scripts/monetizacion/monetizacion_manager.gd` | 134 | 13 | 3 |
| 74 | `TerrainProvider` | `res://scripts/terrenos/terrain_provider.gd` | 106 | 10 | 0 |
| 75 | `GameFlowManager` | `res://scripts/core/game_flow_manager.gd` | 73 | 6 | 1 |
| 76 | `SceneManager` | `res://scripts/core/scene_manager.gd` | 160 | 10 | 3 |
| 77 | `MotivacionManager` | `res://scripts/motivacion/motivacion_manager.gd` | 180 | 17 | 2 |
| 78 | `PlatformManager` | `res://scripts/plataformas/platform_manager.gd` | 118 | 14 | 2 |
| 79 | `WorldBible` | `res://scripts/world/world_bible.gd` | 73 | 9 | 1 |
| 80 | `MemoryMonitor` | `res://scripts/rendimiento/memoria/memory_monitor.gd` | 641 | 68 | 5 |
| 81 | `MusicDirector` | `res://scripts/audio/music_director.gd` | 101 | 12 | 1 |
| 82 | `AmbientDirector` | `res://scripts/audio/ambient_director.gd` | 72 | 9 | 1 |
| 83 | `SFXManager` | `res://scripts/audio/sfx_manager.gd` | 400 | 38 | 0 |
| 84 | `FeedbackDirector` | `res://scripts/audio/feedback_director.gd` | 83 | 10 | 1 |
| 85 | `NarrativeSound` | `res://scripts/audio/narrative_sound.gd` | 243 | 26 | 4 |
| 86 | `CrashReporter` | `res://scripts/crash/crash_reporter.gd` | 94 | 7 | 1 |
| 87 | `CiCdManager` | `res://scripts/ci/cicd_manager.gd` | 298 | 22 | 0 |
| 88 | `InstaladorConfig` | `res://scripts/installer/instalador_config.gd` | 81 | 12 | 0 |
| 89 | `MapManager` | `res://scripts/mapa/mapa_manager.gd` | 304 | 30 | 3 |
| 90 | `HardwareManager` | `res://scripts/hardware/hardware_manager.gd` | 92 | 13 | 0 |
| 91 | `BuildConfigManager` | `res://scripts/build/build_config_manager.gd` | 74 | 7 | 0 |
| 92 | `UpdateManager` | `res://scripts/updates/update_manager.gd` | 92 | 10 | 0 |
| 93 | `DevTools` | `res://scripts/dev/dev_tools.gd` | 77 | 9 | 0 |
| 94 | `MaterialesRecursos` | `res://scripts/arte3d/materiales_recursos.gd` | 183 | 14 | 0 |
| 95 | `BotPaseoM09` | `res://scripts/world/bot_paseo_m09.gd` | 243 | 11 | 0 |
| 96 | `MundoRaiz` | `res://scripts/world/mundo_raiz.gd` | 35 | 2 | 0 |
| 97 | `SecurityManager` | `res://scripts/security/security_manager.gd` | 243 | 17 | 0 |
| 98 | `FontCatalog` | `res://scripts/fonts/font_catalog.gd` | 100 | 11 | 0 |
| 99 | `BackupManager` | `res://scripts/backup/backup_manager.gd` | 407 | 35 | 0 |
| 100 | `DlcManager` | `res://scripts/dlc/dlc_manager.gd` | 263 | 33 | 0 |
| 101 | `SupportManager` | `res://scripts/support/support_manager.gd` | 134 | 17 | 2 |
| 102 | `ModdingManager` | `res://scripts/modding/modding_manager.gd` | 125 | 12 | 0 |
| 103 | `UgcManager` | `res://scripts/ugc/ugc_manager.gd` | 63 | 9 | 0 |
| 104 | `CommunityManager` | `res://scripts/community/community_manager.gd` | 54 | 7 | 0 |
| 105 | `NPCManager` | `res://scripts/ia_npc/npc_manager.gd` | 385 | 28 | 4 |
| 106 | `eventos` | `res://scripts/eventos/event_manager.gd` | 901 | 55 | 8 |
| 107 | `EquipmentManager` | `res://scripts/player/equipment_manager.gd` | 392 | 22 | 3 |
| 108 | `NPCVisualDatabase` | `res://scripts/data/npc_visual_database.gd` | 56 | 7 | 0 |
| 109 | `WorldLocations` | `res://scripts/data/world_locations.gd` | 343 | 16 | 2 |
| 110 | `EnchantmentSystem` | `res://scripts/enchantment/enchantment_system.gd` | 151 | 22 | 4 |
| 111 | `TransportManager` | `res://scripts/transporte/transport_manager.gd` | 702 | 59 | 6 |
| 112 | `IslandRegistry` | `res://scripts/islas/island_registry.gd` | 472 | 39 | 3 |
| 113 | `gem_currency` | `res://scripts/combat/gem_currency.gd` | 108 | 9 | 2 |
| 114 | `combat_island` | `res://scripts/combat/combat_island_system.gd` | 212 | 22 | 2 |
| 115 | `Construccion` | `res://scripts/construccion/build_manager.gd` | 803 | 66 | 6 |
| 116 | `HouseManager` | `res://scripts/houses/house_manager.gd` | 338 | 30 | 4 |

## 2. Autoloads con demasiadas responsabilidades (god-objects)

Criterio: archivos con >= 500 líneas o >= 40 funciones. Se detectaron **17** autoloads que concentran demasiada lógica en un único global.

| Autoload | Archivo | Líneas | Funcs | Señales |
|----------|---------|--------|-------|---------|
| `DebugMenu` | `res://scripts/debug/debug_menu.gd` | 1308 | 107 | 3 |
| `ProgressionManager` | `res://scripts/progresion/progression_manager.gd` | 959 | 55 | 5 |
| `eventos` | `res://scripts/eventos/event_manager.gd` | 901 | 55 | 8 |
| `Tutorial` | `res://scripts/tutorial/tutorial_manager.gd` | 814 | 67 | 12 |
| `Construccion` | `res://scripts/construccion/build_manager.gd` | 803 | 66 | 6 |
| `VillagerManager` | `res://scripts/npc/villager_manager.gd` | 777 | 53 | 9 |
| `mineria` | `res://scripts/mineria/mining_manager.gd` | 768 | 59 | 7 |
| `Friendship` | `res://scripts/friendship/friendship_service.gd` | 708 | 58 | 7 |
| `TransportManager` | `res://scripts/transporte/transport_manager.gd` | 702 | 59 | 6 |
| `DataStore` | `res://scripts/datos/data_store.gd` | 650 | 38 | 7 |
| `UIManager` | `res://scripts/ui/core/ui_manager.gd` | 645 | 43 | 3 |
| `MemoryMonitor` | `res://scripts/rendimiento/memoria/memory_monitor.gd` | 641 | 68 | 5 |
| `Achievements` | `res://scripts/logros/achievement_service.gd` | 622 | 39 | 3 |
| `TelemetryDirector` | `res://scripts/telemetry/telemetry_director.gd` | 533 | 41 | 3 |
| `StreamManager` | `res://scripts/stream/stream_manager.gd` | 527 | 41 | 5 |
| `Farm` | `res://scripts/farm/farm_service.gd` | 515 | 42 | 8 |
| `TimeCalendar` | `res://scripts/time/time_calendar.gd` | 274 | 41 | 6 |

Observaciones:
- `DebugMenu` (`res://scripts/debug/debug_menu.gd`): 1308 líneas / 107 funcs → candidato a dividir en subservicios.
- `ProgressionManager` (`res://scripts/progresion/progression_manager.gd`): 959 líneas / 55 funcs → candidato a dividir en subservicios.
- `eventos` (`res://scripts/eventos/event_manager.gd`): 901 líneas / 55 funcs → candidato a dividir en subservicios.
- `Tutorial` (`res://scripts/tutorial/tutorial_manager.gd`): 814 líneas / 67 funcs → candidato a dividir en subservicios.
- `Construccion` (`res://scripts/construccion/build_manager.gd`): 803 líneas / 66 funcs → candidato a dividir en subservicios.
- `VillagerManager` (`res://scripts/npc/villager_manager.gd`): 777 líneas / 53 funcs → candidato a dividir en subservicios.
- `mineria` (`res://scripts/mineria/mining_manager.gd`): 768 líneas / 59 funcs → candidato a dividir en subservicios.
- `Friendship` (`res://scripts/friendship/friendship_service.gd`): 708 líneas / 58 funcs → candidato a dividir en subservicios.

## 3. Dependencias circulares entre autoloads

Análisis de uso real (acceso `Nombre.` / `Nombre(` / `/root/Nombre`), excluyendo comentarios. Se detectaron **2 ciclos**:

### Ciclo A — DataStore ↔ SaveManager
- `DataStore` → `SaveManager`: `game/isla-ancestral/scripts/datos/data_store.gd:86` (`var sm := get_node_or_null("/root/SaveManager")`)
- `SaveManager` → `DataStore`: `game/isla-ancestral/scripts/saving/save_manager.gd:205` y `:273` (`var ds := get_node_or_null("/root/DataStore")`)

### Ciclo B — eventos ↔ Friendship ↔ GameTime ↔ TimeCalendar ↔ VillagerManager ↔ Weather
Aristas relevantes (extracto):
- `eventos` → `Friendship`
- `eventos` → `GameTime`
- `eventos` → `TimeCalendar`
- `eventos` → `Weather`
- `Friendship` → `GameTime`
- `Friendship` → `TimeCalendar`
- `Friendship` → `VillagerManager`
- `GameTime` → `eventos`
- `TimeCalendar` → `GameTime`
- `VillagerManager` → `GameTime`
- `VillagerManager` → `TimeCalendar`
- `Weather` → `GameTime`

Evidencia de líneas clave:
- `eventos` → `Friendship`: `scripts/eventos/event_manager.gd:844`
- `eventos` → `GameTime`: `scripts/eventos/event_manager.gd:95,100,163,...`
- `eventos` → `TimeCalendar`: `scripts/eventos/event_manager.gd:101,104,422,810,841`
- `eventos` → `Weather`: `scripts/eventos/event_manager.gd:106-108,850-852`
- `Friendship` → `GameTime`: `scripts/friendship/friendship_service.gd:161`
- `Friendship` → `TimeCalendar`: `scripts/friendship/friendship_service.gd:155,158`
- `Friendship` → `VillagerManager`: `scripts/friendship/friendship_service.gd:178,221,226`
- `GameTime` → `eventos`: `scripts/time/game_clock.gd:43,138-147,245,261-263` (campo `_eventos_visitados`)
- `TimeCalendar` → `GameTime`: `scripts/time/time_calendar.gd:55`
- `TimeCalendar` → `eventos`: `scripts/time/time_calendar.gd:29,86,95,104,106,108,109,111,113,114,188-218`
- `VillagerManager` → `GameTime`: `scripts/npc/villager_manager.gd:138,169,545`
- `VillagerManager` → `TimeCalendar`: `scripts/npc/villager_manager.gd:548`
- `Weather` → `GameTime`: `scripts/clima/weather_service.gd:53,58,174,219`

## 4. Autoloads que podrían ser nodos de escena en lugar de globales

Candidatos: UI/visual (CanvasLayer), sistemas que referencian `current_scene`, crean nodos con `add_child` o usan `@export`.

| Autoload | Archivo | Razones |
|----------|---------|---------|
| `TelemetryDirector` | `res://scripts/telemetry/telemetry_director.gd` | add_child x2 (crea nodos en árbol) |
| `SaveManager` | `res://scripts/saving/save_manager.gd` | @export (config de nodo) |
| `SoftlockGuard` | `res://scripts/core/softlock_guard.gd` | add_child x2 (crea nodos en árbol) |
| `RelojHud` | `res://scripts/clock/reloj_hud.gd` | UI/visual |
| `Bootstrap` | `res://scripts/core/bootstrap.gd` | referencia current_scene |
| `UIManager` | `res://scripts/ui/core/ui_manager.gd` | UI/visual |
| `TooltipService` | `res://scripts/ui/services/tooltip_service.gd` | extends CanvasLayer (capa UI); add_child x5 (crea nodos en árbol); @export (config de nodo) |
| `NotificationService` | `res://scripts/ui/services/notification_service.gd` | extends CanvasLayer (capa UI); add_child x4 (crea nodos en árbol); @export (config de nodo) |
| `TerrainLocator` | `res://scripts/core/terrain_locator.gd` | referencia current_scene |
| `VillagerManager` | `res://scripts/npc/villager_manager.gd` | referencia current_scene; add_child x3 (crea nodos en árbol) |
| `ThemeService` | `res://scripts/ui/theme/theme_service.gd` | UI/visual |
| `Crafting` | `res://scripts/crafting/crafting_service.gd` | add_child x2 (crea nodos en árbol) |
| `DebugMenu` | `res://scripts/debug/debug_menu.gd` | UI/visual; referencia current_scene |
| `Farm` | `res://scripts/farm/farm_service.gd` | referencia current_scene |
| `PhotoService` | `res://scripts/foto/photo_service.gd` | add_child x2 (crea nodos en árbol) |
| `SubtitleManager` | `res://scripts/ui/subtitle_manager.gd` | UI/visual; add_child x3 (crea nodos en árbol) |
| `PantallaCarga` | `res://scripts/stream/pantalla_carga.gd` | extends CanvasLayer (capa UI); add_child x4 (crea nodos en árbol) |
| `SceneManager` | `res://scripts/core/scene_manager.gd` | referencia current_scene |
| `MaterialesRecursos` | `res://scripts/arte3d/materiales_recursos.gd` | add_child x3 (crea nodos en árbol) |
| `NPCManager` | `res://scripts/ia_npc/npc_manager.gd` | add_child x3 (crea nodos en árbol) |

## 5. Sugerencias para reducir acoplamiento (2 acciones)

1. **Romper los ciclos con inyección diferida / eventos:** en `DataStore`/`SaveManager` y en el grupo `eventos`-`Friendship`-`GameTime`-`TimeCalendar`-`VillagerManager`-`Weather`, reemplazar `get_node_or_null("/root/X")` por señales del `EventBus` y resolución perezosa en `_ready` (conexión unidireccional). Convertir a dependencias unidireccionales: `GameTime` emite `dia_cambiado`, `eventos`/`Weather` se suscriben; `SaveManager` orquesta persistencia llamando a `DataStore` sin que `DataStore` conozca a `SaveManager`.
2. **Des-globalizar UI y sistemas de escena:** convertir `TooltipService`, `NotificationService`, `PantallaCarga` (CanvasLayer) y `RelojHud`/`DebugMenu`/`UIManager` en nodos de la escena principal (instancia en `main_island.tscn`) en lugar de autoloads; y mover `VillagerManager`, `Farm`, `TerrainLocator` (que usan `current_scene`) a nodos hijos de la escena de mundo. Mantener como autoloads solo `EventBus`, `GameSettings`, `ServiceRegistry`, `GameLogger` y `TerrainLocator` si se requiere acceso global temprano.

## Conclusión final

El proyecto registra **116 autoloads** en `project.godot`, de los cuales **17** superan el umbral de god-object (>=500 líneas o >=40 funcs). Se detectaron **2 ciclos de dependencia** (DataStore↔SaveManager y un ciclo de 6 nodos tiempo/eventos/clima). Al menos **20** autoloads son candidatos a convertirse en nodos de escena (UI overlays y sistemas ligados a `current_scene`). Recomendación: priorizar romper los ciclos y des-globalizar la UI antes de añadir nuevos autoloads.
