# Log 883 — HY4 — QA cruzado Lote G (headless, Godot 4.7.2-stable)

**Modelo:** hy3 (Tencent Hunyuan) / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 20:10 (GMT-3)
**Rol:** QA cruzado (AGENTS.md §21.8) — verificador ≠ autor.
**Identidad:** Este chat es hy3/WorkBuddy. El Lote F fue firmado erróneamente
"Hy3/WorkBuddy" y corregido en Log 880; por eso Lote G se firma hy3/WorkBuddy.
NO edito `TAREAS-POR-MODELO/Hy3/`.

## Ejecución headless
Comando: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://<test>`

| M | Test | Checks | Fallos | EXIT | Nota |
|---|------|--------|--------|------|------|
| 78  | scripts/legal/test_legal_m78.gd             | 9  | 0 | 0 | restore drop Lote F |
| 84  | scripts/legal/test_audio_licenses_m84.gd    | 8  | 0 | 0 | restore drop Lote F |
| 128 | scripts/legal/test_brand_m128.gd           | 8  | 0 | 0 | restore drop Lote F |
| 126 | scripts/legal/test_marketing_legal_m126.gd  | 9  | 0 | 0 | restore drop Lote F + fila CHECKLIST ausente (reconstruida) |
| 87  | scripts/localizacion/test_localizacion_m87.gd | 18 | 3 | 1 | FAIL: aserciones conteo obsoletas (11 vs 25) |
| 87  | scripts/localization/test_validador_po_m87.gd | — | 0 | 0 | pasa (validador .po) |
| 116 | scripts/build/test_instalador_m116.gd      | 15 | 0 | 0 | |
| 116 | scripts/installer/test_installer_m116.gd   | 18 | 0 | 0 | |
| 123 | scripts/modding/test_modding_m123.gd       | 69 | 0 | 0 | |
| 127 | scripts/legal/test_copyright_m127.gd       | 9  | 2 | 1 | FAIL: aserciones conteo obsoletas (5/2 vs 7/5); CopyrightValidator data válida 0 errores |
| 150 | scripts/audio/test_narrative_m150.gd       | 12 | 0 | 0 | fila CHECKLIST ausente (reconstruida) |
| 105 (suplementario) | scripts/telemetry/test_telemetry.gd | 16 | 0 | 0 | re-ground verificado |

## Hallazgos
- **10 EXIT 0, 2 EXIT 1** (M87, M127).
- M87/M127 fallan SOLO por aserciones de conteo obsoletas en el test (el módulo fue
  expandido por su autor; el test no se actualizó). La funcionalidad es correcta:
  `LocalizationManager` (3 idiomas, get_texto, interpolación) y `CopyrightValidator`
  (data válida, 0 errores) validan OK. **NO es regresión del módulo.**
- Delegado al autor de los tests (**DeepSeek-V4.1-Flash**) vía BUG-032 / BUG-033 en
  `DOCUMENTACION/11-BUGS.md`. NO se aplica sello limpio §21.8 a M87/M127; se deja
  nota de QA cruzado en CHECKLIST-GLOBAL.
- Se corrigió un bug en `run_lote_g.py`: las rutas de test apuntaban a
  `ROOT/scripts/...` en lugar de `ROOT/game/isla-ancestral/scripts/...`.

## SELLADOS §21.8 (Log 883/884, hy3/WorkBuddy)
M78, M84, M116, M123, M126, M128, M150, M105 (headless EXIT 0) + M46, M149, M160
(re-grounding, Log 884). Total: 11.

**Firma:** hy3 (Tencent Hunyuan) / WorkBuddy
