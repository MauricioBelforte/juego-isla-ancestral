# Log 1765: QA §21.8 M120-DLC — sello válido (14 muestreados, 0 fallos, 116 checks runtime)

**Fecha:** 2026-10-12
**Hora:** 22:25
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

Ejecución de la QA cruzada §21.8 de M120-DLC-Y-Expansiones (encargo del director, msg 327
del canal atria-dawn-s2). Veredicto: **POSITIVO — el sello ✅ es válido**. Además se aplicó
la degradación autorizada de 16 ítems en M25 (parte 1 del mismo encargo, commit c20a284).

## Cambios Realizados

### M25 — degradación aplicada (commit c20a284)
- 16 ítems `[x]` "Implementar" sin evidencia → `[?]` con nota
  `QA s2 2026-10-12 (Log 1763): grep 0 hits → deuda implementación`.
- Línea Totales actualizada: 122 ítems · Completados: 106 · No resueltos: 16.
- Conteo verificado: 106 [x] / 16 [?] / 0 [ ] = 122. UTF-8 confirmado.

### M120 — QA §21.8 (READ-ONLY, sin ediciones del módulo)
- Conteo estricto: **222 [x] / 0 [?] / 0 [ ] = 222**, Totales coincide, sin drift.
- Muestreo §21.8.2.b: **14 ítems con verbos de creación, 0 fallos**.
- 3 suites re-ejecutadas en Godot 4.7.2 headless, **116 checks, 0 fallos, 3× EXIT 0**.

## Evidencia en disco (M120)

- `scripts/dlc/`: `dlc_manager.gd` (263 líneas), `dlc_compatibility_checker.gd`,
  `dlc_uninstaller.gd`, `dlc_bundle_manager.gd`, `sincronizar_dlc.gd`,
  `test_dlc_m120.gd`, `test_dlc_servicios_m120.gd`.
- `data/dlc/`: `dlc_manifest.json` (2 DLC: isla_hielo, pack_aurora),
  `bundles.json` (4 bundles: bundle_deluxe 0.15, season_pass_2024 0.30,
  bundle_completo 0.40, bundle_islas 0.30).
- `tests/unit/dlc/test_dlc_manager.gd` (39 checks, 12 bloques A-L).
- `project.godot:120` autoload `DlcManager="*res://scripts/dlc/dlc_manager.gd"`.
- Métodos citados en el checklist verificados en las líneas exactas:
  `load_island`:247, `load_biome`:250, `load_npc`:253, `load_historia`:256,
  `load_ruin`:259, `load_music`:262, `comparar_versiones`:90,
  `get_base_game_version`:44, `is_version_compatible`:51, `es_backward_compatible`:121,
  `load_bundles`:40, `get_bundle_price`:71, `calculate_bundle_discount`:83,
  `uninstall_dlc`:39, `mark_savegames_as_incomplete`:62.

## Runtime (Godot 4.7.2 headless)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| test_dlc_servicios_m120.gd | 61 | 0 | 0 |
| test_dlc_m120.gd | 16 | 0 | 0 |
| tests/unit/dlc/test_dlc_manager.gd | 39 | 0 | 0 |

Los SCRIPT ERROR del log son de otros módulos (fishing_manager.gd:144/145,
catalogo_tiendas.gd, animacion_jugador_m48.gd:40), no de M120.

## Observaciones (deuda no bloqueante, reportadas al director)

1. `07-Resultados-Testings.md` AUSENTE — la evidencia runtime existe pero no está
   registrada en el módulo.
2. Divergencia de nombres API diseño↔código: los ítems L213-232 citan
   load_dlc/unload_dlc/is_dlc_loaded/is_dlc_available/load_available_dlcs, signals
   dlc_loaded/dlc_unloaded, vars loaded_dlcs/available_dlcs — ninguno existe literalmente;
   se implementaron equivalentes (activar/desactivar/esta_activo/dlcs_ids/dlc, sin
   signals, _activos/config).
3. dlc_manifest.json define 2 DLC pero bundles.json referencia isla_volcan e isla_bosque
   (ausentes del manifest).

## Archivos Modificados/Creados

- `DOCUMENTACION/25-Ruinas/plan-actual/05-Checklist.md` (degradación 16 [x]→[?], Totales)
- `Mensajes entre modelos/atria-dawn-s2/328-2026-10-12_19-28-41-s2-a-s2-m120-qa-sello-valido-116-checks-0-fallos.md`
- `Logs/1765-atria-dawn-s2-M120-QA-sello-valido_2026-10-12_22-25-00.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (número 1765 consumido del pool)

El módulo M120 no se editó (QA READ-ONLY, §21.8 punto 3). El sello lo decide el director.
