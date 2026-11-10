# Reporte: Autoloads y Singletons — Isla Ancestral

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09  
**Alcance:** `game/isla-ancestral/project.godot` (sección `[autoload]`) y scripts en `game/isla-ancestral/scripts/`

## 1) ¿Cuántos autoloads hay y cuáles son?

**Fuente:** `game/isla-ancestral/project.godot:19-136` (sección `[autoload]`).

- **Total de entradas autoload:** **116**.
- **Formato observado:** casi todas usan `*res://...` (nodo singleton cargado por el motor). **Excepción:** `TermsManager="res://scripts/legal/terms_manager.gd"` (`project.godot:21`) no tiene prefijo `*`; las demás entradas listadas (`:22-136`) sí lo tienen. Esto puede indicar una diferencia de registro/carga respecto al resto (conviene verificar en editor/runtime si `TermsManager` se comporta como autoload global esperado).

| Línea | Nombre (autoload) | Script |
|---:|---|---|
| 21 | `TermsManager` | `res://scripts/legal/terms_manager.gd` |
| 22 | `EventBus` | `res://scripts/core/event_bus.gd` |
| 23 | `WorldState` | `res://scripts/dialogos/world_state_service.gd` |
| 24 | `DialogueManager` | `res://scripts/dialogos/dialogue_manager.gd` |
| 25 | `GameSettings` | `res://scripts/core/game_settings.gd` |
| 26 | `ServiceRegistry` | `res://scripts/core/service_registry.gd` |
| 27 | `GameLogger` | `res://scripts/logging/logger.gd` |
| 28 | `AnalyticsDirector` | `res://scripts/analytics/analytics_director.gd` |
| 29 | `TelemetryDirector` | `res://scripts/telemetry/telemetry_director.gd` |
| 30 | `SaveManager` | `res://scripts/saving/save_manager.gd` |
| 31 | `TimeCalendar` | `res://scripts/time/time_calendar.gd` |
| 32 | `ItemDatabase` | `res://scripts/data/item_database.gd` |
| 33 | `EconomyManager` | `res://scripts/economia/economy_manager.gd` |
| 34 | `SoftlockGuard` | `res://scripts/core/softlock_guard.gd` |
| 35 | `ShopManager` | `res://scripts/shops/shop_manager.gd` |
| 36 | `Inventario` | `res://scripts/inventario/inventario_service.gd` |
| 37 | `Friendship` | `res://scripts/friendship/friendship_service.gd` |
| 38 | `GameTime` | `res://scripts/time/game_clock.gd` |
| 39 | `RelojHud` | `res://scripts/clock/reloj_hud.gd` |
| 40 | `Bootstrap` | `res://scripts/core/bootstrap.gd` |
| 41 | `UIManager` | `res://scripts/ui/core/ui_manager.gd` |
| 42 | `TooltipService` | `res://scripts/ui/services/tooltip_service.gd` |
| 43 | `NotificationService` | `res://scripts/ui/services/notification_service.gd` |
| 44 | `TerrainLocator` | `res://scripts/core/terrain_locator.gd` |
| 45 | `VillagerManager` | `res://scripts/npc/villager_manager.gd` |
| 46 | `ControlInput` | `res://scripts/controls/control_input.gd` |
| 47 | `ResourceManager` | `res://scripts/resources/resource_manager.gd` |
| 48 | `mineria` | `res://scripts/mineria/mining_manager.gd` |
| 49 | `interacciones` | `res://scripts/interacciones/interaction_manager.gd` |
| 50 | `fauna_registry` | `res://scripts/fauna/fauna_registry.gd` |
| 51 | `fauna` | `res://scripts/fauna/fauna_manager.gd` |
| 52 | `credits_manager` | `res://scripts/legal/credits_manager.gd` |
| 53 | `MerchManager` | `res://scripts/legal/merch_manager.gd` |
| 54 | `animal_ai` | `res://scripts/animales_ia/m65_animal_ai.gd` |
| 55 | `coleccionables` | `res://scripts/coleccionables/coleccionables_manager.gd` |
| 56 | `hotbar` | `res://scripts/inventario/hotbar_state.gd` |
| 57 | `inventario_helper` | `res://scripts/inventario/inventario_iter4.gd` |
| 58 | `inventario_iter5` | `res://scripts/inventario/inventario_iter5.gd` |
| 59 | `Localization` | `res://scripts/localization/localization_manager.gd` |
| 60 | `Balance` | `res://scripts/balance/balance_service.gd` |
| 61 | `Tutorial` | `res://scripts/tutorial/tutorial_manager.gd` |
| 62 | `ThemeService` | `res://scripts/ui/theme/theme_service.gd` |
| 63 | `Crafting` | `res://scripts/crafting/crafting_service.gd` |
| 64 | `AssetProfile` | `res://scripts/rendimiento/asset_profile.gd` |
| 65 | `BrandConfig` | `res://scripts/brand/brand_config.gd` |
| 66 | `DebugMenu` | `res://scripts/debug/debug_menu.gd` |
| 67 | `CatalogoTiendas` | `res://scripts/shops/catalogo_tiendas.gd` |
| 68 | `Farm` | `res://scripts/farm/farm_service.gd` |
| 69 | `Fishing` | `res://scripts/fishing/fishing_manager.gd` |
| 70 | `Weather` | `res://scripts/clima/weather_service.gd` |
| 71 | `Historia` | `res://scripts/historia/story_manager.gd` |
| 72 | `Historias` | `res://scripts/historias/secondary_stories_service.gd` |
| 73 | `Barter` | `res://scripts/economia/barter_system.gd` |
| 74 | `TravelService` | `res://scripts/viajes/travel_service.gd` |
| 75 | `CollectionRegistry` | `res://scripts/museum/collection_registry.gd` |
| 76 | `DonationService` | `res://scripts/museum/donation_service.gd` |
| 77 | `Diary` | `res://scripts/diario/diary_service.gd` |
| 78 | `PlayerProfile` | `res://scripts/progresion/player_profile.gd` |
| 79 | `ProgressionManager` | `res://scripts/progresion/progression_manager.gd` |
| 80 | `Achievements` | `res://scripts/logros/achievement_service.gd` |
| 81 | `Vehiculos` | `res://scripts/vehiculos/vehicle_manager.gd` |
| 82 | `Postgame` | `res://scripts/postgame/postgame_manager.gd` |
| 83 | `EscalasGlobales` | `res://scripts/core/escalas_globales.gd` |
| 84 | `AccesibilityManager` | `res://scripts/accesibilidad/accesibilidad_manager.gd` |
| 85 | `AnimationService` | `res://scripts/animacion/animation_service.gd` |
| 86 | `PhotoService` | `res://scripts/foto/photo_service.gd` |
| 87 | `Tiers` | `res://scripts/herramientas158/tool_tier_system.gd` |
| 88 | `AudioConfig` | `res://scripts/audio/audio_config_service.gd` |
| 89 | `DataStore` | `res://scripts/datos/data_store.gd` |
| 90 | `SubtitleManager` | `res://scripts/ui/subtitle_manager.gd` |
| 91 | `StreamManager` | `res://scripts/stream/stream_manager.gd` |
| 92 | `PantallaCarga` | `res://scripts/stream/pantalla_carga.gd` |
| 93 | `MonetizacionManager` | `res://scripts/monetizacion/monetizacion_manager.gd` |
| 94 | `TerrainProvider` | `res://scripts/terrenos/terrain_provider.gd` |
| 95 | `GameFlowManager` | `res://scripts/core/game_flow_manager.gd` |
| 96 | `SceneManager` | `res://scripts/core/scene_manager.gd` |
| 97 | `MotivacionManager` | `res://scripts/motivacion/motivacion_manager.gd` |
| 98 | `PlatformManager` | `res://scripts/plataformas/platform_manager.gd` |
| 99 | `WorldBible` | `res://scripts/world/world_bible.gd` |
| 100 | `MemoryMonitor` | `res://scripts/rendimiento/memoria/memory_monitor.gd` |
| 101 | `MusicDirector` | `res://scripts/audio/music_director.gd` |
| 102 | `AmbientDirector` | `res://scripts/audio/ambient_director.gd` |
| 103 | `SFXManager` | `res://scripts/audio/sfx_manager.gd` |
| 104 | `FeedbackDirector` | `res://scripts/audio/feedback_director.gd` |
| 105 | `NarrativeSound` | `res://scripts/audio/narrative_sound.gd` |
| 106 | `CrashReporter` | `res://scripts/crash/crash_reporter.gd` |
| 107 | `CiCdManager` | `res://scripts/ci/cicd_manager.gd` |
| 108 | `InstaladorConfig` | `res://scripts/installer/instalador_config.gd` |
| 109 | `MapManager` | `res://scripts/mapa/mapa_manager.gd` |
| 110 | `HardwareManager` | `res://scripts/hardware/hardware_manager.gd` |
| 111 | `BuildConfigManager` | `res://scripts/build/build_config_manager.gd` |
| 112 | `UpdateManager` | `res://scripts/updates/update_manager.gd` |
| 113 | `DevTools` | `res://scripts/dev/dev_tools.gd` |
| 114 | `MaterialesRecursos` | `res://scripts/arte3d/materiales_recursos.gd` |
| 115 | `BotPaseoM09` | `res://scripts/world/bot_paseo_m09.gd` |
| 116 | `MundoRaiz` | `res://scripts/world/mundo_raiz.gd` |
| 117 | `SecurityManager` | `res://scripts/security/security_manager.gd` |
| 118 | `FontCatalog` | `res://scripts/fonts/font_catalog.gd` |
| 119 | `BackupManager` | `res://scripts/backup/backup_manager.gd` |
| 120 | `DlcManager` | `res://scripts/dlc/dlc_manager.gd` |
| 121 | `SupportManager` | `res://scripts/support/support_manager.gd` |
| 122 | `ModdingManager` | `res://scripts/modding/modding_manager.gd` |
| 123 | `UgcManager` | `res://scripts/ugc/ugc_manager.gd` |
| 124 | `CommunityManager` | `res://scripts/community/community_manager.gd` |
| 125 | `NPCManager` | `res://scripts/ia_npc/npc_manager.gd` |
| 126 | `eventos` | `res://scripts/eventos/event_manager.gd` |
| 127 | `EquipmentManager` | `res://scripts/player/equipment_manager.gd` |
| 128 | `NPCVisualDatabase` | `res://scripts/data/npc_visual_database.gd` |
| 129 | `WorldLocations` | `res://scripts/data/world_locations.gd` |
| 130 | `EnchantmentSystem` | `res://scripts/enchantment/enchantment_system.gd` |
| 131 | `TransportManager` | `res://scripts/transporte/transport_manager.gd` |
| 132 | `IslandRegistry` | `res://scripts/islas/island_registry.gd` |
| 133 | `gem_currency` | `res://scripts/combat/gem_currency.gd` |
| 134 | `combat_island` | `res://scripts/combat/combat_island_system.gd` |
| 135 | `Construccion` | `res://scripts/construccion/build_manager.gd` |
| 136 | `HouseManager` | `res://scripts/houses/house_manager.gd` |

**Observación de naming/coherencia:** hay mezcla de `PascalCase`, `snake_case` y nombres por iteración (`inventario_helper` → `inventario_iter4.gd:57`, `inventario_iter5` → `inventario_iter5.gd:58`), lo que sugiere deuda de consolidación en el árbol global de autoloads.

## 2) ¿Hay acoplamiento fuerte entre autoloads?

**Sí, hay evidencia de acoplamiento fuerte y extendido.**

### 2.1 Búsquedas directas a `/root/*` (acoplamiento por nombre global)
- **181 referencias** en `game/isla-ancestral/scripts/**/*.gd` (excl. addons/tests en el conteo usado) a autoloads clave vía `/root/EventBus|SaveManager|UIManager|ServiceRegistry`.
- Ejemplos representativos:
  - `game/isla-ancestral/scripts/build/build_config_manager.gd:52` → `get_node_or_null("/root/ServiceRegistry")`
  - `game/isla-ancestral/scripts/backup/backup_manager.gd:42` → `ServiceRegistry`
  - `game/isla-ancestral/scripts/ci/cicd_manager.gd:35` → `ServiceRegistry`
  - `game/isla-ancestral/scripts/analytics/analytics_director.gd:53,206,212` → `ServiceRegistry`, `GameLogger`
  - `game/isla-ancestral/scripts/main_island.gd:47,90,94,103,106,215,251,299,302,401,404` → múltiples autoloads (`UIManager`, `MundoRaiz`, `TerrainLocator`, `ResourceManager`)
  - `game/isla-ancestral/scripts/dlc/dlc_manager.gd:118,127` → `ServiceRegistry`, `SaveManager`
  - `game/isla-ancestral/scripts/herramientas158/tool_tier_system.gd:71,119,198,234,244,257,261,295,303` → `EventBus`, `SaveManager`, `Inventario`, `EconomyManager`, `ProgressionManager`
  - `game/isla-ancestral/scripts/saving/save_manager.gd:88` y `game/isla-ancestral/scripts/ui/core/ui_manager.gd:47,56,60` → acceso directo a `EventBus`/servicios relacionados.

**Impacto:** cualquier renombre de autoload, cambio de ruta, orden de inicialización o disponibilidad parcial rompe múltiples sistemas en runtime (mitigado parcialmente por `get_node_or_null`, pero la dependencia semántica sigue siendo fuerte).

### 2.2 Uso de `EventBus` como hub global
- **67 usos** de `EventBus.` en scripts (conteo de referencias).
- `EventBus` define dominios tipados amplios (`world`, `economy`, `inventory`, `quest`, `npc`, `calendar`, `time`, `weather`, `travel`, `vehicle`, `ui`, `player`, `infra`, `diary`, `progresion`, `fishing`) en `game/isla-ancestral/scripts/core/event_bus.gd:14-44,48-199`.
- Esto es un patrón válido de desacoplamiento *si* se usa de forma consistente, pero en la práctica coexiste con accesos directos a `/root/*`, por lo que el acoplamiento se vuelve **mixto** (eventos + llamadas directas).

### 2.3 `ServiceRegistry` existe, pero su adopción es parcial
- `ServiceRegistry` implementa registro/lookup por contrato (`game/isla-ancestral/scripts/core/service_registry.gd:22-75`) y `Contratos` centraliza nombres (`game/isla-ancestral/scripts/core/contratos.gd:1-40`).
- `Bootstrap` registra core y luego **auto-registra dominios deferred** con mapeo explícito de nombres de autoload (`game/isla-ancestral/scripts/core/bootstrap.gd:43-83,143-160`). También valida servicios requeridos e integridad de dominios (`:164-183`).
- Sin embargo, el uso real de `ServiceRegistry.get_service(...)` en código de producción es bajo frente al volumen de `/root/*` (muestra: `telemetry_director.gd:56` menciona/usa lookup por registry; la mayoría de sistemas siguen resolviendo por `get_node_or_null("/root/...")`).

### 2.4 Dependencia de orden de inicialización
- `Bootstrap` difiere varias acciones con `call_deferred` (`bootstrap.gd:49-55`) porque `GameFlowManager` y dominios se montan después según orden de autoloads. Esto evidencia **fragilidad por orden de carga**: el sistema funciona, pero depende del orden global y de inicialización diferida.

## 3) ¿Hay dependencias circulares entre autoloads?

**No se detectó evidencia clara de ciclos de carga estática (preload/class_name circular) entre los autoloads revisados**, pero **sí hay dependencia mutua en runtime y riesgo estructural de ciclos lógicos**.

- Evidencia de acceso cruzado en runtime (no ciclo de carga probado, pero acoplamiento bidireccional potencial por nombres globales):
  - `SaveManager` consulta/conecta con `EventBus` y otros managers (`game/isla-ancestral/scripts/saving/save_manager.gd:88,108-119`).
  - `UIManager` consulta `EventBus`, `ControlInput`, `GameSettings` y reacciona a foco/capas (`game/isla-ancestral/scripts/ui/core/ui_manager.gd:47-77,84-112`).
  - `Bootstrap` resuelve `ServiceRegistry`, `GameFlowManager`, `SceneManager`, `EventBus` (`bootstrap.gd:78-133`).
  - `GameFlowManager` emite por `EventBus.infra` (`game/isla-ancestral/scripts/core/game_flow_manager.gd:66-73`).
  - `main_island.gd` (escena) orquesta varios autoloads de mundo/UI/terreno (`:47,90,94,103,215,251,299,401-404`), reforzando un grafo denso.

**Conclusión sobre ciclos:** con 116 autoloads y resolución por `/root`, el riesgo de **dependencias circulares lógicas** (A llama B, B depende de estado/señal de A durante init o flujo) es alto. No afirmo un ciclo concreto de import/preload entre autoloads sin un análisis de grafo completo de llamadas/señales, pero la arquitectura actual favorece ese tipo de regresión.

## 4) ¿Hay autoloads que actúan como dios-objeto?

**Sí, hay candidatos claros por tamaño y/o centralidad de responsabilidades.**

| Autoload / archivo | Tamaño (bytes) | Señales de “dios-objeto” / concentración |
|---|---:|---|
| `DebugMenu` — `game/isla-ancestral/scripts/debug/debug_menu.gd` | 51,704 | Autoload de debug con config, estado persistible, geometría, filtros, toggles visuales múltiples, señales, consola/logger, extracción parcial a módulos (`:1-80`). Alta concentración funcional en una sola fachada global. |
| `ProgressionManager` — `game/isla-ancestral/scripts/progresion/progression_manager.gd` | 35,973 | Orquesta catálogo, perfil, logger, guardado/proveedor, eventos, caché de evaluación de condiciones, hitos, desbloqueos, títulos (`:1-90`). Mucho estado y reglas de dominio en un singleton. |
| `UIManager` — `game/isla-ancestral/scripts/ui/core/ui_manager.gd` | 24,154 | Gestiona pila de capas, foco, pausa, integración con `EventBus`/`ControlInput`/`GameSettings`, tooltips, hover, restore de foco (`:1-120`). Centraliza política transversal de UI. |
| `SaveManager` — `game/isla-ancestral/scripts/saving/save_manager.gd` | 16,625 | Cola de guardado, bloqueo, snapshot/loader, dirty tracking, conexión a múltiples dominios vía `EventBus` y managers, auto-save por eventos, control de diálogo/minijuego (`:1-120`). Punto crítico con muchas responsabilidades de coordinación. |
| `EventBus` — `game/isla-ancestral/scripts/core/event_bus.gd` | 9,585 | No es “dios” por lógica de negocio, pero sí **hub global** de comunicación (muchos dominios/señales, `:14-199`). Su centralidad amplifica el impacto de cambios. |

**Matiz:** algunos (como `EventBus`) cumplen un rol legítimo de infraestructura; el riesgo de “dios-objeto” es mayor en `DebugMenu`, `ProgressionManager`, `SaveManager` y `UIManager` por acumulación de estado, reglas y coordinación.

## 5) Dos acciones para reducir acoplamiento

### Acción 1 — Migrar accesos directos `/root/*` a contratos vía `ServiceRegistry` + `Contratos` (con regla incremental)
- **Qué hacer:** reemplazar progresivamente `get_node_or_null("/root/X")` por `ServiceRegistry.get_service(Contratos.X)` (o helper tipado) en sistemas de dominio/UI, empezando por los puntos con mayor fan-out (ej. `main_island.gd:47-404`, `tool_tier_system.gd:71-303`, `save_manager.gd:88+`).
- **Cómo:** usar `Bootstrap` como punto único de registro ya existente (`bootstrap.gd:63-83,143-160`) y exigir que todo contrato nuevo pase por `Contratos` (`contratos.gd:1-40`).
- **Beneficio:** reduce acoplamiento por nombre de nodo, facilita stubs/tests, hace visibles dependencias y permite detectar faltantes temprano (`ServiceRegistry.get_service` ya advierte acceso temprano, `service_registry.gd:30-38`).
- **Riesgo a controlar:** mantener compatibilidad durante la migración (fallback temporal a `/root` solo donde sea imprescindible) y no ocultar dependencias reales.

### Acción 2 — Separar responsabilidades de los autoloads “pesados” y formalizar límites por eventos
- **Qué hacer:** extraer submódulos puros/servicios internos de `DebugMenu`, `SaveManager`, `ProgressionManager` y `UIManager` (estado, persistencia, evaluación, UI de capas, comandos) dejando al autoload como **fachada delgada**.
- **Cómo:**
  - En `SaveManager` (`save_manager.gd:1-120`), aislar `AutoSavePolicy` (qué eventos disparan/bloquean) y `SaveQueue` de la conexión directa a múltiples dominios; consumir señales de `EventBus` en adaptadores pequeños.
  - En `UIManager` (`ui_manager.gd:43-112`), separar router de input/pausa/foco en componentes con interfaces claras.
  - En `DebugMenu` (`debug_menu.gd:25-77`), continuar la extracción ya iniciada (`EXPORTADOR_DIAG`, `COMANDOS_DEBUG`) hacia módulos por pestaña/responsabilidad.
  - En `ProgressionManager` (`progression_manager.gd:18-90`), extraer evaluación de condiciones/caché y persistencia a servicios testables.
- **Beneficio:** disminuye el radio de cambio, reduce ciclos lógicos, mejora testeabilidad y permite evolucionar módulos sin tocar el singleton global.

## Conclusión final

El proyecto usa una arquitectura **altamente centralizada en autoloads**: **116 singletons registrados** en `project.godot:21-136`. Hay **acoplamiento fuerte** demostrado por el uso extensivo de resolución global (`/root/*`, 181 refs a singletons clave) y por la mezcla de acceso directo con `EventBus`/`ServiceRegistry` (este último subutilizado en producción). No se identificó un ciclo de carga estático obvio en la muestra, pero el grafo de dependencias en runtime es denso y propenso a **dependencias circulares lógicas** y fallos por orden de inicialización. Existen **dios-objetos/fachadas sobrecargadas** claros (`DebugMenu`, `ProgressionManager`, `UIManager`, `SaveManager`). Priorizar la migración a contratos (`ServiceRegistry`/`Contratos`) y la descomposición de autoloads pesados reduciría el acoplamiento sin cambiar el modelo global de golpe.
