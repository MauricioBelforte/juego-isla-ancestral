# 07 — Resultados de Testings — M120: DLC y Expansiones

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12

> Resultados de la re-ejecución de las suites durante la QA §21.8 (Log 1765, msg 328 del
> canal atria-dawn-s2). Binario: Godot 4.7.2.stable, modo `--headless`.

## Resumen

| Fecha | Binario | Script | EXIT | SCRIPT ERROR (M120) | Checks | Fallos | Veredicto |
|---|---|---|---|---|---|---|---|
| 2026-10-12 | Godot 4.7.2.stable (headless) | `scripts/dlc/test_dlc_servicios_m120.gd` | 0 | 0 | 61 | 0 | PASS |
| 2026-10-12 | Godot 4.7.2.stable (headless) | `scripts/dlc/test_dlc_m120.gd` | 0 | 0 | 16 | 0 | PASS |
| 2026-10-12 | Godot 4.7.2.stable (headless) | `tests/unit/dlc/test_dlc_manager.gd` | 0 | 0 | 39 | 0 | PASS |

**Totales: 3 scripts · 116 checks · 0 fallos · 3× EXIT 0.**

## Detalle por suite

### `scripts/dlc/test_dlc_servicios_m120.gd` — 61 checks, 6 bloques A-F

Cubre `DLCCompatibilityChecker`, `DLCBundleManager`, `DLCUninstaller` y los loaders de
contenido de `DlcManager`. Guardián de 3 capas (marcadores `_fin` por bloque, piso
`CHECKS_MINIMOS=61` MEDIDO, resumen diferido en `_init`).

| Bloque | Tema | Checks |
|---|---|---|
| A | `get_base_game_version` no vacío + compatibilidad | 61 totales |
| B | `DLCBundleManager`: total 4 bundles | (distribuidos) |
| C | `DLCUninstaller`: marca 1 save | |
| D | `DlcManager` presente: loaders `load_island/biome/npc/historia/ruin/music`, idempotencia, casos vacíos | |
| E | accessors `compatibility_checker`/`uninstaller`/`bundle_manager` + cruce checker vs `DlcManager.comparar_versiones` (5/5) | |
| F | bundles: `season_pass_2024` (0.30), `bundle_completo` (0.40), `bundle_islas` (0.30) | |

### `scripts/dlc/test_dlc_m120.gd` — 16 checks

Regresión del `DlcManager` (autoload, manifest, bundles, activar/desactivar,
compatibilidad de versión). Verificación de arranque: imprime
`[M120] DlcManager listo (2 DLC, 4 bundles)`.

### `tests/unit/dlc/test_dlc_manager.gd` — 39 checks, 12 bloques A-L

| Bloque | Tema | Checks |
|---|---|---|
| A | test_autoload_disponible | 1 |
| B | test_manifest_cargado | 3 |
| C | test_comparar_versiones_semantica | 4 |
| D | test_comparar_versiones_tolerancias | 4 |
| E | test_es_compatible | 3 |
| F | test_activar_desactivar | 4 |
| G | test_bundles | 3 |
| H | test_seccion_guardado_integracion | 3 |
| I | test_get_save_data | 4 |
| J | test_roundtrip_persistencia | 3 |
| K | test_reconciliacion_dlc_ausente | 3 |
| L | test_version_guardada | 3 |
| **Total** | | **39** |

## Notas

- Comando: `godot472.exe --headless --path game/isla-ancestral --script res://<script>`.
- Los `SCRIPT ERROR` que aparecen en stderr durante la corrida son de **otros módulos**
  (`fishing_manager.gd:144/145`, `catalogo_tiendas.gd`, `animacion_jugador_m48.gd:40`),
  **no de M120**; el juego completo arranca para ejecutar el script.
- Cobertura del muestreo §21.8.2.b: 14 ítems con verbos de creación verificados contra
  disco, 0 fallos (ver Log 1765).
