# 15 - QA §21.8 de M116-Instalador — SELLO VÁLIDO (1 flip cosmético sugerido)

**Modelo:** Ling 3.1 Flash (inclusionai/ling-3.1-flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 19:20:23
**Responde a:** atria-dawn-s3 - 14-2026-10-10_18-50-27-atria-dawn-s3-a-ling-3-1-flash-m66-re-sello-aceptado-l22-flip-aplicado-110-117.md

## Veredicto: SELLO VÁLIDO — M116 puede sellarse tras 1 flip cosmético de totales

## 1. Conteo estricto (regex `^- \[x\]` / `^- \[\?\]` / `^- \[ \]`)
- Cuerpo del 05-Checklist: **169 `[x]` / 23 `[?]` / 0 `[ ]` = 192**
- Coincide con CHECKLIST-GLOBAL fila 116 (169/192) y con la re-medición de Step 5 (msg 57, 19:05).
- **HALLAZGO NUEVO — drift de totales (flip sugerido, READ-ONLY):** L276-277 ("Resueltos: 192 `[x]` · Con dueño externo: 0 `[?]` · Pendientes: 0 `[ ]`"), L293 ("Totales: 192 ítems · Completados: 192 · Pendientes: 0 · No resueltos: 0") y la nota de drift L295-299 ("Conteo real de marcas: 192 [x] / 0 [ ] / 0 [?]") están STALE: no se actualizaron cuando el director degradó los 23 duplicados el 2026-10-10 (QA agnes-3-flash msg 200). Flip sugerido: L276-277 y L293 → 169 `[x]` / 23 `[?]` / 0 `[ ]`. Precedente: flip 1 de Step 5 en M107 (Totales 146/12/18 → 151/0/25).

## 2. Patrón D — confirmo el análisis de Step 5 (msg 57)
Los 23 `[?]` son TODOS degradaciones explícitas del director (2026-10-10), cada una con nota "Patrón D — duplicado de la línea N" y canónica `[x]` superviviente:
- "Diseñar conservación de datos del usuario" ×5 → L174, L185, L213, L221, L229
- "Diseñar detección de versión instalada (registro de Windows)" ×2 → L172, L211
- "Diseñar actualización incremental (solo archivos modificados)" ×2 → L173, L212
- "Diseñar validación de espacio en disco" ×2 → L81, L205
- "Diseñar code signing" ×2 → L233 (ejecutable Godot export), L234 (instalador Inno Setup)
- Únicos: L82 (validación de requisitos de sistema), L147 (desinstalador elimina todos los archivos), L204 (validación de RAM 8GB), L214 (actualización de shortcuts y asociación), L219 (validación de integridad de archivos), L220 (reinstalación de archivos corruptos), L226 (backup de versión anterior), L227 (rollback automático), L228 (restauración de versión anterior), L260 (icon.ico, 2ª referencia)
- Veredicto: doble indexación estructural, NO duplicado real ni deferral disfrazado (M114). Cada `[?]` tiene razón explícita + referencia canónica. La re-medición de Step 5 fue falso positivo, como él mismo reportó.

## 3. Muestreo §21.8.2.b — 10+ ítems `[x]` (verbos de creación), 10/10 VÁLIDO
| Ítem | Artefacto en disco |
|---|---|
| L25 Crear build release | scripts/build_installer.bat ✓ |
| L26 Crear instalador — iter. 2 | installer/setup_windows.ps1 + installer/IslaAncestral.iss ✓ |
| L28 Crear desinstalador | installer/uninstall_windows.ps1 ✓ |
| L41 Definir export Godot 4.x Windows Desktop | game/isla-ancestral/export_presets.cfg ✓ |
| L109/L224 Firma digital / code_signing.bat | installer/code_signing.bat ✓ |
| L119 IsUpdate() | installer/update.iss L25 ✓ |
| L171 RollbackToPreviousVersion() | installer/rollback.iss L43 ✓ |
| L189 IsWindows10Or11() | installer/system_requirements.iss L9 ✓ |
| L200 GetInstalledVersion() | installer/update.iss L15 ✓ |
| L209 ValidateFileIntegrity() | installer/repair.iss L14 ✓ |
| L245 installer/IslaAncestral.iss | ✓ (incluye system_requirements/update/repair/rollback.iss en su única sección [Code]) |

Soporte verificado: game/isla-ancestral/scripts/build/ (build_config_manager.gd, build_validator.gd, validador_instalador.gd, test_instalador_m116.gd, test_build_m117.gd); game/isla-ancestral/data/installer/instalador_config.json; installer/license.txt.

## 4. Runner del gate M116 (quality.yml L418)
`test_instalador_m116.gd` headless → "=== Resumen M116: 15 checks, 0 fallo(s) ===" + "TEST M116 OK" + "[OK] el validador ejecuto al menos 40 checks (ejecuto 61)". EXIT 0.

## 5. Runner run_tests.gd (encargo punto 5 — pertenece a M112/BUG-120)
`C:\Temp\godot\godot472.exe --headless --ignoreHeadlessMode --path game/isla-ancestral --script res://tests/run_tests.gd`
→ **RESULTADO: ÉXITO MEDIDO — 29/29 suites ejecutables (29 descubiertas, 0 excluidas documentadas) · checks SceneTree: 1249 · test cases GdUnit4: 21 · tests totales: 1270 · 0 fallos · EXIT 0.**
Se usó `--ignoreHeadlessMode` (lección E-27: sin el flag el guardián aborta con EXIT 103).

## 6. Aclaración de nomenclatura (para el director)
El encargo msg 14 dice "M116-Testing-Automatico", pero el módulo 116 de CHECKLIST-GLOBAL es **116-Instalador** (DOCUMENTACION/116-Instalador/). El testing automático y run_tests.gd pertenecen a **M112 (112-Testing-Automatico)**. Verifiqué ambos: el gate de M116 (test_instalador_m116.gd, punto 4) y el runner global (run_tests.gd, punto 5). Sin pisada con Step 5: avisado en su canal (msg 59) antes de leer el 05-Checklist de M116; él ya había cerrado su re-medición (msg 57) y está libre.

## 7. Independencia §21.8.4
QA por Ling 3.1 Flash (Kilo Code); implementación M116 por agnes-2.5-flash/agnes-3-flash; degradaciones por el director. Sin conflicto de identidad.

## Recomendación
Sello VÁLIDO. Flip sugerido (cosmético, lo aplica el director o Step 5): L276-277 y L293 → 169/23/0. Tras el flip, M116 queda apto para ✅.
