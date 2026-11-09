# Reporte: scripts .gd huérfanos — game/isla-ancestral/scripts/

**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-09

## Alcance y método

- Raíz analizada: `game/isla-ancestral/scripts/` → **1.261 archivos `.gd`**
- Contraste contra: otros `.gd` de `scripts/`, las **69 escenas `.tscn`** del proyecto (`game/isla-ancestral/`, 85 scripts referenciados desde `.tscn`), y los **116 autoload** declarados en la sección `[autoload]` de `project.godot`.
- Clasificación por referencias (basename o `class_name` mencionado fuera del propio archivo):

| Categoría | Cantidad |
|---|---|
| Referenciados desde otro `.gd` + `.tscn` | 70 |
| Solo desde otro `.gd` | 873 |
| Solo desde `.tscn` | 2 |
| Autoload (`project.godot`) | 116 |
| **Sin ninguna referencia (huérfanos)** | **142** |

## (1) Archivos .gd sin importadores

**142 archivos no son mencionados por ningún otro `.gd`, ninguna `.tscn` ni son autoload.** El 90 % (≈128) son herramientas de QA/tests standalone pensadas para ejecutarse con `godot --script` o GdUnit (prefijos `test_*`, `qa_*`, `probe_*`, `sesion_*`, `medir_*`, `diag_*`, `sonda_*`, `validate_*`). Muestra por directorio (líneas entre paréntesis):

- `rendimiento/memoria/` — 18 archivos `test_m62_*` / `sesion_m62_*` (151–483 líneas), p. ej. `test_m62_duro95.gd` (331), `sesion_m62_clima_30min.gd` (483)
- `saving/` — `test_menu_guardado_idiomas_m59.gd` (507), `test_fecha_diario_cola_m59.gd` (413), `test_slots_perfiles_m59.gd` (423), más 8 `qa_m59_*`
- `dialogos/` — `test_m21_lote1_hy3.gd` (187), `test_playback_dialogo_hy3.gd` (113), `test_polish_m21.gd` (144), 7 `qa_m21_*`
- `debug/` — 7 `test_*_m110.gd` (294–475), p. ej. `test_debug_visualizer_real_m110.gd` (475)
- `datos/test_serializacion_roundtrip_m60_hy3.gd` (369), `islas/test_island_travel_guard_hy3.gd` (472), `editor/_colector_sintaxis.gd` (1.141)
- `legal/Obsoletos/2026-11-06_22-18-40_merch_manager.gd` (99): histórico respaldo, confirma duplicado con `legal/merch_manager.gd` (este último sí es autoload vía `MerchManager`)

**Huérfanos de runtime reales** (no son tests/QA; nada los usa):
- `arte2d/pack_atlas.gd` (173) — herramienta de empaquetado de atlas sin caller
- `foto/photo_gallery.gd` (136) y `foto/validate_photo.gd` (115)
- `mineria/ocupacion_voxel.gd` (98, `class_name OcupacionVoxel`)
- `terrenos/terrain_block.gd` (43)
- `prototipo/` entero: `game_state_proto.gd` (14), `player_proto.gd` (24), `world_seed.gd` (6)

## (2) Autoload y señales

- `project.godot` declara **116 autoload** (EventBus, WorldState, DialogueManager, SaveManager, TerrainLocator, UIManager, etc.).
- De 1.261 scripts, **156 declaran/emiten señales** y **244** contienen `.connect(`; los restantes actúan por llamadas directas, instanciación o solo como datos. **Conclusión:** no hay un grupo grande de scripts "desconectados" problemático; la falta de señales es el patrón normal (autoloads + preloads). Solo 2 archivos dependen exclusivamente de una `.tscn` sin mención en otro `.gd` — candidatos a verificar si la escena que los referencia sigue vigente.

## (3) Duplicados

**14 colisiones de nombre base** entre directorios (0 archivos idénticos por hash MD5, 0 idénticos normalizando comentarios/espacios):

| Pareja | Tamaños (líneas) | Estado |
|---|---|---|
| `ui/hud/{clock_widget,season_widget,resource_counter,status_bar,hotbar_widget,interact_prompt,minimap_widget,action_prompt_overlay}.gd` vs `ui/widgets/*.gd` | stubs de 11–21 líneas (300–614 B) vs versiones completas (70–240 líneas, 2,8–14 KB) | los `hud/` parecen **stubs muertos**; `clock_widget.gd` de `hud/` es un label mínimo y `widgets/` es el widget cozy con `class_name ClockWidget` |
| `terrain/{terrain_modifiers,terrain_data,terrain_detector}.gd` vs `terrenos/*.gd` | existen en ambas carpetas | funcionalidad elevando la sospecha de carpeta legacy `terrain/` vs vigente `terrenos/` |
| `utils/data/item_data.gd` vs `data/item_data.gd`; `localizacion/localization_manager.gd` vs `localization/localization_manager.gd`; `utils/state_machine.gd` vs `ia_npc/state_machine.gd` | — | solapamiento funcional, revisar cuál referencia cada consumidor |

**Conclusión:** no hay copias byte-a-byte, pero sí **dobles carpetas funcionales** (`ui/hud` stubs vs `ui/widgets` reales; `terrain` vs `terrenos`) que son la verdadera fuente de confusión.

## (4) Archivos vacíos o casi vacíos (< 10 líneas reales)

**35 archivos** con < 10 líneas de código (sin comentarios ni líneas en blanco). Los menores:

| Líneas reales | Archivo | Tipo |
|---|---|---|
| 3 (6 totales) | `main_test2.gd` | stub residual en raíz de scripts |
| 3 (7) | `player/equipment_catalog.gd` | catálogo vacío |
| 3 (16) | `tutorial/tutorial_guiones.gd` | guiones vacíos |
| 4 (6) | `prototipo/world_seed.gd` | prototipo (huérfano además) |
| 5 (8) | `utils/game_enums.gd` | enums (verificar uso) |
| 5 (9) | `utils/strategy.gd` | estrategia (verificar uso) |
| 6 (15) | `data/accesorio_data.gd`, `fishing/cebo_definition.gd`, `legal/credits_catalog.gd` | data classes (legítimos, referenciados) |
| 7 (10–22) | `clock/w_reloj_config.gd`, `data/location_requirements.gd`, `legal/terms_config.gd`, `ui/core/ui_layer_type.gd`, `ui/hud/{clock,season}_widget.gd`, `utils/data/{item,mission,npc}_data.gd` | configs/enums/stubs de HUD |
| 8–9 | `data/{island_type,ropa_data}.gd`, `economia/price_definition.gd`, `fishing/fishing_rod.gd`, `telemetry/stub_analytics_director.gd`, `foto/i_diary_photo_provider.gd`, `interacciones/categoria_interaccion.gd` | data/interface/stub |

La mayoría de los data/config son legítimos (referenciados); los problemáticos son `main_test2.gd`, `world_seed.gd`, `stub_analytics_director.gd` y los 8 stubs de `ui/hud/`.

## (5) Acciones de limpieza sugeridas

1. **Mover las herramientas QA/test a una carpeta fuera del export** (p. ej. `scripts/tests/` excluida en `export_presets.cfg` o `tools/`): son ≈128 de los 142 huérfanos (`test_*`, `qa_*`, `probe_*`, `sesion_m62_*`, `medir_*`, `diag_*`) y hoy inflan el árbol de runtime y el tiempo de importación. Requiere actualizar los comandos `--script` documentados que las ejecutan, y borrar `prototipo/` y `legal/Obsoletos/` de `scripts/` (o moverlos a `Obsoletos/` de raíz).
2. **Consolidar los gemelos `ui/hud/` → `ui/widgets/` y `terrain/` vs `terrenos/`**: verificar cuál de cada pareja referencia cada `.tscn`/`.gd` (las 69 escenas) y eliminar los stubs de `ui/hud/` (11–21 líneas, 300–614 B cada uno) y la carpeta `terrain/` o `terrenos/` perdedora; dejar un solo `ClockWidget`, `SeasonWidget`, etc., y un solo `terrain_data/terrain_detector/terrain_modifiers`.

## Conclusión final

**No hay scripts de juego huérfanos en masa:** 1.119 de 1.261 (88,7 %) están vivos (referenciados por otro `.gd`, una `.tscn` o son autoload). Los **142 huérfanos son casi todos infraestructura de QA/tests standalone** (correctamente desconectados: se ejecutan manualmente), más 3 prototipos olvidados y 2 herramientas sueltas (`pack_atlas.gd`, `ocupacion_voxel.gd`, `photo_gallery.gd`) a verificar. La deuda real no es "archivos sin usar" sino **duplicación de carpetas** (`ui/hud` stub vs `ui/widgets`, `terrain` vs `terrenos`) y **35 archivos < 10 líneas** de los que una decena son stubs residuales (`main_test2.gd`, `world_seed.gd`, stubs HUD). Priorizar: (a) sacar QA/tests del árbol runtime, (b) eliminar los stubs de `ui/hud/` tras comprobar qué escena los referencia.
