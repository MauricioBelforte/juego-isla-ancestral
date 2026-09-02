# 4-DOCUMENTO-EJECUCION-ACTUAL.md

**Modelo:** glm-5.3-flash (último modificador; esqueleto por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Vigente — inventario de ejecución real al 2026-09-01 (detalles por módulo en cada plan-actual).

## Propósito

Código de ejecución vigente: scripts clave, funciones, flujos y logs relacionados.

## Autoloads reales del proyecto (project.godot)

| Autoload | Script | Módulo | Responsabilidad |
|---|---|---|---|
| DataStore | `scripts/datos/data_store.gd` | M60 | Save/config persistente (GestorConfig + WriterAtomico) |
| SaveManager | `scripts/saving/save_manager.gd` | M59 | Cola de guardado, dirty tracking, auto-save (día/misión/cierre), bloqueo en diálogo |
| Weather | `scripts/clima/weather_service.gd` | M32 | Clima determinista (cadena seed+día, regla cozy, intensidad, persistencia) |
| Historia | `scripts/historia/story_manager.gd` | M22 | Grafo de historia data-driven, gating por sellos/flags/objetos |
| Barter | `scripts/economia/barter_system.gd` | M38 | Trueque objeto-por-objeto con amistad/temporada/límites + salvavidas |
| TravelService | `scripts/viajes/travel_service.gd` | M28 | Viajes en vapor (rutas data-driven, clima retraso-sin-bloqueo, persistencia mitad de ruta) |
| CollectionRegistry | `scripts/museum/collection_registry.gd` | M37 | Autoridad única de progreso de colecciones del museo |
| DonationService | `scripts/museum/donation_service.gd` | M37 | Validación/ejecución de donaciones (DonationResult, recompensas únicas) |
| Tutorial | `scripts/tutorial/tutorial_manager.gd` | M92 | Capítulos con triggers de señal/acción/mundo + watchdog |
| Localization | `scripts/localization/localization_manager.gd` | M87 | Idiomas es/en (.po), tr_key/tr_ctx, persistencia de locale |

(Demás autoloads del núcleo: EventBus M07, ServiceRegistry, Logger, Analytics/Telemetry, GameTime, TimeCalendar, Inventario, VillagerManager, Farm, Fishing, EconomyManager, ShopManager, Crafting, GameFlowManager — ver sus plan-actual.)

## Servicios nuevos del sprint glm-5.3-flash (2026-08-31 → 09-01, Logs 306-322)

| Módulo | Entrega principal | Archivos clave |
|---|---|---|
| M32 | WeatherService determinista + clima_config.tres + EventBus.weather | `scripts/clima/`, `data/clima/` |
| M59 | Dirty tracking + auto-save + PlayerSaveProvider + fix Node-providers | `scripts/saving/` |
| M22 | HistoriaService + historia_principal.json (12 nodos, 7 sellos, 4 finales) + validador | `scripts/historia/`, `data/historia/` |
| M33 | Puente M32→Farm (lluvia riega, apply_rain idempotente, hook _tile_expuesto) | `scripts/farm/farm_service.gd` |
| M34 | Bonos clima en pesca (_peso_efectivo, lluvia ×1.15 / tropical ×1.25, nunca filtra) | `scripts/fishing/fishing_manager.gd` |
| M38 | BarterSystem (BarterOffer + trueque atómico con rollback, salvavidas RF12) | `scripts/economia/`, `data/economia/barter/` |
| M19 | Mudanzas (propuesta→aprobación→llegada 08:00→partida+enfriamiento 30 d) + 5 perfiles + línea de visión F | `scripts/npc/villager_manager.gd`, `data/villagers/` |
| M93 | Tablas v2 (friendship/quests/puzzles/unlocks/meta-rareza+pity) | `data/balance/` |
| M28 | TravelService núcleo V0 (4 rutas, clima, refunds, persistencia mitad de ruta) | `scripts/viajes/`, `data/viajes/` |
| M92 | Triggers avanzados (acción EventBus, mundo por proximidad, watchdog 120 s, degradación) | `scripts/tutorial/tutorial_manager.gd` |
| M37 | CollectionRegistry + DonationService + exhibiciones.json + integración M34 | `scripts/museum/`, `data/museum/` |
| M87 | Persistencia de idioma vía M60 (sección "general"), sugerencia SO, tr_ctx | `scripts/localization/`, `scripts/datos/gestor_config.gd` |

## Secciones del esqueleto original

| Sección | Estado | Módulo dueño |
|---|---|---|
| Prototipo voxel (chunk, mesh, culling) | ✅ Implementado (M08/M09/M11) | 08, 09, 11 |
| Jugador y cámara | ✅ Implementado (M11/M12) | 11, 12 |
| Sistemas de gameplay | ✅ Implementado en su mayoría (M13/M14/M15/M16/M19/M20/M33/M34/M35/M38 + M22/M28/M32/M37/M92 núcleos) | 13-17, 19, 20, 22, 28, 32-38, 92 |
| Templos y puzzles | Framework (M24/M25 núcleo; M26 dueño pendiente) | 24, 25, 26 |
| UI | Capas DOM-UI montadas (M53 núcleo; visual V2) | 53 |
| Guardado | ✅ Núcleo + auto-save + providers (M59) | 59 |

## Reglas de actualización

- Incluir archivos, funciones clave y números de log al completar cada implementación.
- Los scripts del protocolo viven en `scripts/` (ver `Logs/` para instrucciones de uso).
- Convención de firma: este documento firma el ÚLTIMO agente que lo modificó.
