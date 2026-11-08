# Reporte de Integración — Análisis de Acoplamiento en scripts/ (Godot)

**Modelo:** Reflection-Beam-1.0  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08  
**Scope:** `game/isla-ancestral/scripts/` (archivos `.gd`)  
**Archivos analizados:** 1260 `.gd` totales; 681 de producción (excluyendo tests, qa, validate, debug, preview, tools, editor)

---

## 1. Alcance y método

- Extracción de autoloads desde `project.godot`: **116 autoloads**.
- Detección de referencias cruzadas entre módulos mediante patrón `res://scripts/<modulo>/` y nombres de autoload como palabra completa.
- Análisis de señales: declaraciones `signal`, `emit`/`emit_signal`, `connect`.
- Análisis de tamaño/responsabilidades de autoloads (líneas, funciones, vars, señales, refs a otros autoloads).

---

## 2. (1) Dependencias cruzadas / circulares entre módulos

### Código de producción (filtrado)
No se detectaron pares de módulos con dependencia circular directa (A→B y B→A) entre módulos de producción.

### Código de tests/QA/herramientas (2 pares circulares detectados)
| Par | Archivo origen | Línea | Referencia |
|---|---|---|---|
| diario ↔ ui | `scripts/diario/validate_diary.gd` | 38 | `const RUTA_LAYER := "res://scripts/ui/layers/diary_layer.gd"` |
| diario ↔ ui | `scripts/ui/layers/diary_layer.gd` | 55 | `const ICONOS := preload("res://scripts/diario/iconos_diario.gd")` |
| diario ↔ ui | `scripts/ui/layers/diary_layer.gd` | 59 | `const LORE := preload("res://scripts/diario/secciones_lore.gd")` |
| saving ↔ ui | `scripts/saving/qa_m59_guardar_dirty.gd` | 23 | `var pause = load("res://scripts/ui/layers/pause_layer.gd").new()` |
| saving ↔ ui | `scripts/saving/qa_m59_bloqueo_manual.gd` | 23 | `var pause = load("res://scripts/ui/layers/pause_layer.gd").new()` |
| saving ↔ ui | `scripts/saving/qa_m59_guardar_confirmacion.gd` | 29 | `var pl = load("res://scripts/ui/layers/pause_layer.gd").new()` |
| saving ↔ ui | `scripts/saving/qa_m59_popup_opciones.gd` | 27 | `var popup = load("res://scripts/ui/layers/confirm_popup.gd").new()` |
| saving ↔ ui | `scripts/ui/qa_guardado_manual_item1.gd` | 17 | `var prov = load("res://scripts/saving/player_save_provider.gd").new()` |
| saving ↔ ui | `scripts/ui/qa_borrar_slot.gd` | 20 | `var prov = load("res://scripts/saving/player_save_provider.gd").new()` |
| saving ↔ ui | `scripts/ui/test_m89_menus.gd` | 243 | `var sw = load("res://scripts/saving/save_writer.gd")` |

**Conclusión (1):** En producción no hay ciclos directos; los ciclos aparecen en QA/tests por `preload`/`load` cruzados entre `diario`↔`ui` y `saving`↔`ui`. Riesgo bajo en runtime, pero indica acoplamiento de capas de presentación con dominio.

---

## 3. (2) Módulos que importan a muchos otros (acoplamiento fuerte)

### Módulos de producción con más referencias cruzadas (distinct module targets)
| Módulo | Targets distintos | Targets |
|---|---|---|
| (root) | 6 | crafting, enchantment, farm, fasttravel, ui, world |
| terreno | 3 | core, npc, world |
| ui | 3 | crafting, diario, shops |
| friendship | 2 | data, npc |

### Herramienta de colección (no gameplay)
- `scripts/editor/_colector_sintaxis.gd`: **1068 referencias** a `res://scripts/` (escaneo de sintaxis, no acoplamiento real).

### Archivos de producción con más autoloads usados
| Archivo | Autoloads usados |
|---|---|
| `scripts/transporte/transport_manager.gd` | 16 |
| `scripts/core/bootstrap.gd` | 15 |
| `scripts/logros/achievement_service.gd` | 12 |
| `scripts/core/verificar_arquitectura.gd` | 11 |
| `scripts/progresion/progression_manager.gd` | 11 |
| `scripts/ui/core/ui_manager.gd` | 10 |
| `scripts/viajes/travel_service.gd` | 10 |
| `scripts/fishing/fishing_manager.gd` | 9 |
| `scripts/friendship/friendship_service.gd` | 9 |
| `scripts/audio/sfx_manager.gd` | 8 |
| `scripts/core/event_bus.gd` | 8 |
| `scripts/economia/price_manager.gd` | 8 |
| `scripts/eventos/event_manager.gd` | 8 |
| `scripts/historias/secondary_stories_service.gd` | 8 |
| `scripts/player/player.gd` | 8 |

### Autoloads más usados (por cantidad de archivos)
| Autoload | Archivos que lo referencian |
|---|---|
| SaveManager | 59 |
| eventos | 55 |
| EventBus | 53 |
| Inventario | 51 |
| GameTime | 49 |
| ServiceRegistry | 46 |
| TimeCalendar | 30 |
| TerrainLocator | 27 |
| Localization | 25 |
| fauna | 18 |
| EconomyManager | 17 |
| WorldState | 16 |
| UIManager | 15 |
| Weather | 15 |
| ItemDatabase | 15 |

**Conclusión (2):** El acoplamiento fuerte se concentra en orquestadores (bootstrap, progression, transport/travel, ui_manager, achievement) que consumen muchos autoloads, y en hubs de datos (SaveManager, EventBus, Inventario, GameTime) usados por decenas de archivos. No hay módulos de dominio que importen muchos otros módulos por `res://` (solo 0–6 targets), pero el uso intensivo de autoloads globales genera acoplamiento implícito.

---

## 4. (3) Señales entre sistemas que no están conectadas

- Declaraciones de señales en módulos de producción: **443** (en 131 archivos).
- Emisiones detectadas (emit/emit_signal): **585** (en 140 archivos).
- Conexiones detectadas (connect): **356** (en 112 archivos).
- Señales con **≤2 ocurrencias totales** en todo el codebase (probablemente declaradas pero no emitidas/conectadas): **132**.

### Ejemplos de señales probablemente no conectadas
| Archivo | Señal |
|---|---|
| `scripts/core/event_bus.gd` | `chunk_modified`, `debt_paid`, `vessel_arrived`, `vehicle_docked`, `vehicle_aviso`, `layer_requested`, `confirm_requested`, `player_died`, `damage_taken`, `nivel_casa_cambio` |
| `scripts/accesibilidad/accesibilidad_manager.gd` | `profile_loaded`, `profile_reset` |
| `scripts/analytics/analytics_director.gd` | `evento_registrado` |
| `scripts/audio/narrative_sound.gd` | `leitmotif_ended`, `momento_played`, `silencio_started` |
| `scripts/camera/camera_rig.gd` | `zoom_changed` |
| `scripts/clock/reloj_hud.gd` | `formato_cambiado` |
| `scripts/coleccionables/coleccionables_manager.gd` | `categoria_progress_changed` |
| `scripts/combat/combat_island_system.gd` | `enemigo_derrotado` |
| `scripts/combat/gem_currency.gd` | `gema_gastada` |
| `scripts/crafting/crafting_service.gd` | `experimento_fallido`, `receta_bloqueada_estacion` |
| `scripts/data/world_locations.gd` | `location_loaded`, `location_unloaded` |
| `scripts/datos/data_store.gd` | `cargado_slot`, `config_lista`, `config_guardada` |
| `scripts/dialogos/typewriter_effect.gd` | `character_shown` |
| `scripts/enchantment/enchantment_system.gd` | `enchantment_applied`, `enchantment_removed`, `encantos_changed` |
| `scripts/farm/farm_service.gd` | `crop_planted`, `crop_ready`, `crop_harvested` |

**Conclusión (3):** Hay un desbalance (443 declaraciones vs 356 conexiones) y ~132 señales con uso marginal. Es probable que muchas señales del EventBus y de managers estén declaradas pero sin consumidores, o que el conteo incluya declaraciones de clases internas. Recomendado verificar con búsqueda dirigida antes de eliminar.

---

## 5. (4) Autoloads que actúan como 'dios' (demasiadas responsabilidades)

| Autoload | Líneas | Funcs | Vars | Señales | Refs a otros autoloads |
|---|---|---|---|---|---|
| DebugMenu | 1309 | 107 | 135 | 3 | 16 |
| ProgressionManager | 960 | 55 | 134 | 5 | 10 |
| eventos | 902 | 54 | 152 | 8 | 7 |
| Tutorial | 814 | 67 | 69 | 12 | 5 |
| Construccion | 804 | 66 | 108 | 6 | 1 |
| VillagerManager | 778 | 53 | 98 | 9 | 6 |
| mineria | 769 | 59 | 90 | 7 | 3 |
| Friendship | 709 | 58 | 92 | 7 | 8 |
| TransportManager | 703 | 59 | 84 | 6 | 15 |
| DataStore | 650 | 38 | 93 | 7 | 3 |
| UIManager | 646 | 43 | 49 | 3 | 9 |
| MemoryMonitor | 642 | 68 | 67 | 5 | 2 |
| Achievements | 623 | 39 | 89 | 3 | 11 |
| TelemetryDirector | 533 | 41 | 41 | 3 | 5 |
| StreamManager | 528 | 41 | 42 | 5 | 2 |
| Farm | 515 | 42 | 62 | 8 | 6 |
| Fishing | 496 | 38 | 66 | 6 | 8 |

Además:
- `core/event_bus.gd`: **54 señales** en 199 líneas (agregador de eventos de todos los dominios).
- `core/bootstrap.gd`: referencia **15 autoloads** (orquestador de arranque).

**Conclusión (4):** Varios autoloads superan 500–1300 líneas y concentran orquestación + estado + persistencia (DebugMenu, ProgressionManager, eventos, TransportManager). EventBus centraliza todas las señales de dominio. Esto es acoplamiento de responsabilidades y dificulta pruebas/mantenimiento.

---

## 6. (5) Sugerencias para reducir acoplamiento (2 acciones)

1. **Introducir contratos (interfaces) e inyección de dependencias para autoloads críticos.**  
   Reemplazar accesos directos a autoloads concretos (SaveManager, EventBus, Inventario, GameTime) por interfaces (`ISaveProvider`, `IEventBus`, `IInventory`) inyectadas o resueltas vía `ServiceRegistry`. Empezar por los archivos con más consumo (transport_manager.gd:16, bootstrap.gd:15, achievement_service.gd:12, progression_manager.gd:11, ui_manager.gd:10, travel_service.gd:10). Esto reduce acoplamiento implícito y facilita tests.

2. **Dividir el EventBus y eliminar señales sin uso; desacoplar capas UI↔Dominio.**  
   Separar `core/event_bus.gd` en buses por dominio (WorldEvents, EconomyEvents, etc.) o mantener clases anidadas pero exponer solo lo consumido; eliminar/verificar las ~132 señales con ≤2 ocurrencias. Romper los `preload`/`load` cruzados entre `ui`↔`diario` y `ui`↔`saving` moviendo adaptadores a una capa de infraestructura (no cargar capas de UI desde dominio ni viceversa).

---

## 7. Conclusión final

- **Circulares:** Ninguna en producción; 2 pares en tests/QA (diario↔ui, saving↔ui) por `preload`/`load`.
- **Acoplamiento fuerte:** Concentrado en orquestadores y hubs globales (SaveManager 59 archivos, EventBus 53, Inventario 51, GameTime 49, ServiceRegistry 46); no en imports `res://` entre módulos.
- **Señales:** 443 declaraciones vs 356 conexiones; ~132 señales con uso marginal (posible deuda).
- **Autoloads dios:** DebugMenu (1309 L), ProgressionManager (960 L), eventos (902 L), TransportManager (703 L, 15 refs), EventBus (54 señales).
- **Acciones:** (1) contratos + inyección para autoloads críticos; (2) fragmentar EventBus, limpiar señales muertas y romper imports cruzados UI↔Dominio.

**Firma:** Reflection-Beam-1.0 — Kilo Code — 2026-11-08