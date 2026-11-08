**Modelo:** Reflection Beam 1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08

# Reporte: Archivos .gd huérfanos / sin uso — game/isla-ancestral/scripts/

## Resumen ejecutivo

- Total de archivos .gd analizados en `scripts/`: **1260**
- (1) Sin referencia entrante (huérfanos potenciales): **139** (19 de producción + 120 de test/QA/probe)
- (2) Sin autoload ni conexión a señales (aislados): **102** (intersección de huérfanos sin señales)
- (3) Duplicados por nombre (mismo stem en carpetas distintas): **14** grupos (0 duplicados byte-idénticos)
- (4) Vacíos o casi vacíos (<10 líneas de código real): **35**

Metodología: se recorrió `game/isla-ancestral/scripts/` (1260 .gd). Para cada archivo se contaron líneas de código real (no vacías, no comentarios `#`). Se buscó referencia entrante en todo el proyecto (`.gd`, `.tscn`, `.tres`, `.godot`, `.cfg`) por ruta relativa, `res://`, nombre de archivo y `class_name`. Se cruzó con la sección `[autoload]` de `project.godot` y con keywords de señales (`signal`, `connect(`, `emit_signal`).

---

## (1) Archivos .gd sin referencia entrante (huérfanos potenciales)

### 1a. Producción (19) — sin refs, no autoload

| # | Archivo | Líneas reales | class_name |
|---|---------|---------------|------------|
| 1 | `scripts/editor/_colector_sintaxis.gd` | 1133 | — |
| 2 | `scripts/foto/photo_gallery.gd` | 97 | — |
| 3 | `scripts/foto/validate_photo.gd` | 82 | — |
| 4 | `scripts/interacciones/sonda_m70.gd` | 53 | — |
| 5 | `scripts/legal/Obsoletos/2026-11-06_22-18-40_merch_manager.gd` | 64 | — |
| 6 | `scripts/prototipo/game_state_proto.gd` | 10 | — |
| 7 | `scripts/prototipo/player_proto.gd` | 18 | — |
| 8 | `scripts/prototipo/world_seed.gd` | 4 | — |
| 9 | `scripts/rendimiento/memoria/sesion_m62_30min.gd` | 151 | — |
| 10 | `scripts/rendimiento/memoria/sesion_m62_baselines.gd` | 363 | — |
| 11 | `scripts/rendimiento/memoria/sesion_m62_clima_30min.gd` | 372 | — |
| 12 | `scripts/rendimiento/memoria/sesion_m62_limite.gd` | 201 | — |
| 13 | `scripts/rendimiento/memoria/sesion_m62_voxel_500.gd` | 212 | — |
| 14 | `scripts/terrenos/terrain_block.gd` | 33 | — |
| 15 | `scripts/ui/diag_arbol_m53.gd` | 46 | — |
| 16 | `scripts/ui/diag_perf_m55.gd` | 55 | — |
| 17 | `scripts/ui/diag_scroll.gd` | 136 | — |
| 18 | `scripts/vegetacion/medir_plan_m50.gd` | 137 | — |
| 19 | `scripts/vehiculos/validate_vehicles.gd` | 211 | — |

### 1b. Test / QA / probe (120) — intencionales, sin refs

Archivos de prueba, QA, smoke y probes que no son importados por otros .gd (se ejecutan manualmente o por el runner de tests). Muestra de 15:

- `scripts/accesibilidad/qa_m58_indicador_perfil.gd` (40 L)
- `scripts/accesibilidad/qa_m58_nav_menu.gd` (41 L)
- `scripts/accesibilidad/qa_m58_nfr_overhead.gd` (64 L)
- `scripts/coleccionables/test_coleccionables_lote2_m73.gd` (35 L)
- `scripts/coleccionables/test_coleccionables_lote3_m73.gd` (44 L)
- `scripts/coleccionables/test_coleccionables_lote4_m73.gd` (43 L)
- `scripts/coleccionables/test_validate_collectibles_m73.gd` (65 L)
- `scripts/construccion/qa_m17_modo.gd` (42 L)
- `scripts/controls/qa_m57_prompts.gd` (79 L)
- `scripts/core/probe_runtime_bus_m14.gd` (83 L)
- `scripts/core/qa_m40_spy.gd` (58 L)
- `scripts/core/test_smoke_core_hy3.gd` (67 L)
- `scripts/core/test_smoke_persistencia_hy3.gd` (61 L)
- `scripts/crafting/qa_filtros_estacion_m16.gd` (50 L)
- `scripts/crafting/qa_m16_clamp30.gd` (50 L)
- ... y 105 más (ver JSON de análisis).

---

## (2) Archivos .gd que no son autoload ni se conectan a ninguna señal

Intersección de huérfanos sin autoload y sin keywords de señal: **102** archivos. Son los más aislados del flujo (ni registrados como autoload, ni declaran/conectan señales, ni son referenciados). Muestra de 20:

- `scripts/accesibilidad/qa_m58_nav_menu.gd` (41 L)
- `scripts/accesibilidad/qa_m58_nfr_overhead.gd` (64 L)
- `scripts/coleccionables/test_coleccionables_lote2_m73.gd` (35 L)
- `scripts/coleccionables/test_coleccionables_lote3_m73.gd` (44 L)
- `scripts/coleccionables/test_coleccionables_lote4_m73.gd` (43 L)
- `scripts/coleccionables/test_validate_collectibles_m73.gd` (65 L)
- `scripts/construccion/qa_m17_modo.gd` (42 L)
- `scripts/controls/qa_m57_prompts.gd` (79 L)
- `scripts/core/qa_m40_spy.gd` (58 L)
- `scripts/core/test_smoke_core_hy3.gd` (67 L)
- `scripts/core/test_smoke_persistencia_hy3.gd` (61 L)
- `scripts/crafting/qa_m16_clamp30.gd` (50 L)
- `scripts/crafting/qa_m16_pool_iconos.gd` (34 L)
- `scripts/crafting/qa_m16_station_fisica.gd` (31 L)
- `scripts/crafting/qa_m16_ui_cerrada.gd` (35 L)
- `scripts/crafting/qa_pool_iconos.gd` (31 L)
- `scripts/datos/qa_perfil_id.gd` (47 L)
- `scripts/datos/qa_perfil_schema.gd` (44 L)
- `scripts/datos/test_serializacion_roundtrip_m60_hy3.gd` (260 L)
- `scripts/debug/test_debug_menu_config_m110.gd` (261 L)
- ... y 82 más.

Nota: la mayoría son tests/QA/probes (ver 1b). Los de producción aislados coinciden con la lista 1a (salvo los que declaran señales, p. ej. `status_bar` no aplica).

---

## (3) Archivos .gd duplicados con funcionalidad similar

No se encontraron duplicados byte-idénticos (hash SHA-256 normalizado). Sí se encontraron **14 grupos de mismo nombre de archivo (stem) en carpetas distintas**, con contenidos distintos (tamaños muy diferentes), lo que sugiere migración de carpetas con stubs/legacy conviviendo con la implementación real:

| Stem | Archivo A (líneas) | Archivo B (líneas) | Relación |
|------|--------------------|--------------------|----------|
| `item_data` | `scripts/data/item_data.gd` (70) | `scripts/utils/data/item_data.gd` (7) | A más largo |
| `state_machine` | `scripts/ia_npc/state_machine.gd` (192) | `scripts/utils/state_machine.gd` (24) | A más largo |
| `localization_manager` | `scripts/localizacion/localization_manager.gd` (58) | `scripts/localization/localization_manager.gd` (262) | stub/legacy (A más corto) |
| `terrain_data` | `scripts/terrain/terrain_data.gd` (16) | `scripts/terrenos/terrain_data.gd` (17) | stub/legacy (A más corto) |
| `terrain_detector` | `scripts/terrain/terrain_detector.gd` (42) | `scripts/terrenos/terrain_detector.gd` (139) | stub/legacy (A más corto) |
| `terrain_modifiers` | `scripts/terrain/terrain_modifiers.gd` (9) | `scripts/terrenos/terrain_modifiers.gd` (36) | stub/legacy (A más corto) |
| `action_prompt_overlay` | `scripts/ui/hud/action_prompt_overlay.gd` (20) | `scripts/ui/widgets/action_prompt_overlay.gd` (163) | stub/legacy (A más corto) |
| `clock_widget` | `scripts/ui/hud/clock_widget.gd` (7) | `scripts/ui/widgets/clock_widget.gd` (55) | stub/legacy (A más corto) |
| `hotbar_widget` | `scripts/ui/hud/hotbar_widget.gd` (15) | `scripts/ui/widgets/hotbar_widget.gd` (122) | stub/legacy (A más corto) |
| `interact_prompt` | `scripts/ui/hud/interact_prompt.gd` (15) | `scripts/ui/widgets/interact_prompt.gd` (57) | stub/legacy (A más corto) |
| `minimap_widget` | `scripts/ui/hud/minimap_widget.gd` (19) | `scripts/ui/widgets/minimap_widget.gd` (295) | stub/legacy (A más corto) |
| `resource_counter` | `scripts/ui/hud/resource_counter.gd` (10) | `scripts/ui/widgets/resource_counter.gd` (43) | stub/legacy (A más corto) |
| `season_widget` | `scripts/ui/hud/season_widget.gd` (7) | `scripts/ui/widgets/season_widget.gd` (46) | stub/legacy (A más corto) |
| `status_bar` | `scripts/ui/hud/status_bar.gd` (14) | `scripts/ui/widgets/status_bar.gd` (67) | stub/legacy (A más corto) |

Patrón dominante: `ui/hud/*` (11-26 L) son stubs mínimos frente a `ui/widgets/*` (77-389 L) que son la implementación completa; y `terrain/*` (15-56 L) frente a `terrenos/*` (32-239 L). Riesgo de divergencia y confusión de imports.

---

## (4) Archivos .gd vacíos o casi vacíos (<10 líneas de código real)

Total: **35** archivos. Incluyen enums/constantes legítimos (p. ej. `ui_layer_type.gd`, `item_data.gd`) y stubs/prototipos. Lista completa:

| # | Archivo | Líneas reales |
|---|---------|---------------|
| 1 | `scripts/main_test2.gd` | 3 |
| 2 | `scripts/player/equipment_catalog.gd` | 3 |
| 3 | `scripts/tutorial/tutorial_guiones.gd` | 3 |
| 4 | `scripts/prototipo/world_seed.gd` | 4 |
| 5 | `scripts/utils/game_enums.gd` | 5 |
| 6 | `scripts/utils/strategy.gd` | 5 |
| 7 | `scripts/data/accesorio_data.gd` | 6 |
| 8 | `scripts/fishing/cebo_definition.gd` | 6 |
| 9 | `scripts/legal/credits_catalog.gd` | 6 |
| 10 | `scripts/clock/w_reloj_config.gd` | 7 |
| 11 | `scripts/data/location_requirements.gd` | 7 |
| 12 | `scripts/legal/terms_config.gd` | 7 |
| 13 | `scripts/ui/core/ui_layer_type.gd` | 7 |
| 14 | `scripts/ui/hud/clock_widget.gd` | 7 |
| 15 | `scripts/ui/hud/season_widget.gd` | 7 |
| 16 | `scripts/utils/data/item_data.gd` | 7 |
| 17 | `scripts/utils/data/mission_data.gd` | 7 |
| 18 | `scripts/utils/data/npc_data.gd` | 7 |
| 19 | `scripts/core/invariants/jugador_invariant.gd` | 8 |
| 20 | `scripts/core/invariants/vehiculo_invariant.gd` | 8 |
| 21 | `scripts/core/test_m66_handler.gd` | 8 |
| 22 | `scripts/data/island_type.gd` | 8 |
| 23 | `scripts/data/ropa_data.gd` | 8 |
| 24 | `scripts/foto/i_diary_photo_provider.gd` | 8 |
| 25 | `scripts/interacciones/categoria_interaccion.gd` | 8 |
| 26 | `scripts/telemetry/stub_analytics_director.gd` | 8 |
| 27 | `scripts/utils/data/player_data.gd` | 8 |
| 28 | `scripts/utils/game_constants.gd` | 8 |
| 29 | `scripts/core/invariants/puzzle_invariant.gd` | 9 |
| 30 | `scripts/core/test_m66_inv_ruta.gd` | 9 |
| 31 | `scripts/economia/price_definition.gd` | 9 |
| 32 | `scripts/fishing/fishing_rod.gd` | 9 |
| 33 | `scripts/friendship/amistad_config.gd` | 9 |
| 34 | `scripts/licensing/license_validation_result.gd` | 9 |
| 35 | `scripts/terrain/terrain_modifiers.gd` | 9 |

---

## (5) Dos acciones de limpieza sugeridas

1. **Eliminar/mover a `Obsoletos/` los 19 scripts de producción huérfanos de diagnóstico/validación/prototipo** (`scripts/editor/_colector_sintaxis.gd`, `scripts/ui/diag_*.gd`, `scripts/*/*validate*.gd`, `scripts/prototipo/*`, `scripts/rendimiento/memoria/sesion_m62_*.gd`, `scripts/interacciones/sonda_m70.gd`, `scripts/foto/validate_photo.gd`, `scripts/foto/photo_gallery.gd`, `scripts/vehiculos/validate_vehicles.gd`, `scripts/vegetacion/medir_plan_m50.gd`, `scripts/terrenos/terrain_block.gd`, `scripts/legal/Obsoletos/...merch_manager.gd`) y los 35 archivos con <10 líneas reales que sean stubs (mantener los enums/constantes legítimos). Antes, confirmar con `grep` que ninguno se instancia por ruta dinámica o desde `.tscn`/`.gd` (el análisis ya filtró referencias estáticas, pero conviene una segunda pasada).

2. **Consolidar los 14 pares de mismo stem (hud vs widgets, terrain vs terrenos, data vs utils/data, localizacion vs localization)**: elegir una ubicación canónica (p. ej. `ui/widgets/` y `terrenos/`), convertir la otra en re-export/shim o borrarla, y actualizar los imports en escenas y scripts. Priorizar los pares donde el stub (`hud/*`, `terrain/*`) es claramente la versión vieja. Esto reduce la ambigüedad de imports y evita divergencia.

---

## Conclusión final

De los 1260 archivos .gd en `scripts/`, se identificaron **139 huérfanos potenciales** (19 de producción + 120 de test/QA/probe), **102 aislados** (sin autoload ni señales), **14 grupos de duplicación por nombre** (sin duplicados byte-idénticos) y **35 archivos casi vacíos**. La limpieza de los scripts de diagnóstico/prototipo y la consolidación de los pares de mismo stem son las dos acciones de mayor impacto y menor riesgo. Recomendación: ejecutar la acción 1 primero (mover a `Obsoletos/` en vez de borrar, para trazabilidad) y validar con el juego en ejecución antes de la acción 2.
