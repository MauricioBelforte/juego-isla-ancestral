# Log 1888: M117 cierre iter. 4 — build real x3 + fix fuga Godot

**Fecha:** 2026-10-16
**Hora:** 02:41
**Modelo:** DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
**Plataforma:** OpenCode

## Resumen

Cierre de la iteración 4 de M117-Build-System (encargo del director `GLM-5.3 Flash-Director`,
msg 02 del canal `DS-V4.1-Flash-Opencode`): clasificación de los 18 `[?]` y cierre de los
cerrables con flujo §13/§14. Resultado: **94 [x] / 0 [ ] / 16 [?]** (110 ítems) — módulo
liberado 🟡. Se cerraron T-029 y T-030 con export real ×3; se corrigió de paso un desync real
del tooling (`bump_version.py` no sincronizaba `export_presets.cfg`) y una fuga de datos de
tests al artifact (`res://Godot/` con recursos importados). QA §21.8 al cierre → Hy3/agnes/s2
(independencia familia DeepSeek).

## Cambios Realizados

### 1. Tooling — `tools/ci/bump_version.py`
- Nueva `_set_version_in_export_presets()`: sincroniza `application/file_version` y
  `application/product_version` de `export_presets.cfg` en cada bump (misma clase de bug que el
  `#define AppVersion` del `.iss` corregido en el Log 946).
- Nueva constante `EXPORT_PRESETS_CFG` con fallback top-level y cwd-root (mismo patrón que `INSERT_ISS`).
- Wire en `main()`; header del script documentado.
- **Desync real detectado y corregido:** preset en `0.0.2` vs `project.godot` `0.0.6` → realineado a `0.0.6`.

### 2. Tests — `tools/ci/test_bump_version.py`
- +4 casos nuevos (sync real del preset, conserva el resto del preset, DRY no modifica, exit 0) → **18/18 OK**.
- Hardening: lectores de subprocess con `encoding="utf-8", errors="replace"` → 0 `UnicodeDecodeError`
  por stdout cp1252 de los hijos (byte 0x97 = em-dash de los mensajes `... ausente — skip`).
- `python tools/ci/run_tests.py --module build` → **2 OK / 0 FAIL** (`test-build_m117` + `test-instalador_m116`, EXIT 0).

### 3. Exports reales ×3 (Godot 4.7.2 headless) + mediciones
- Comando: `godot --headless --path <proj> --export-release "<preset>" <salida ABSOLUTA>`.
  Gotcha: la CLI resuelve rutas de salida **relativas al dir del PROYECTO** (no al CWD) y no crea
  el directorio destino → usar siempre ruta absoluta con el dir creado de antemano.
- **Windows** `game/build/windows/`: exe **120.80 MB** + `libvoxel.windows.template_release.x86_64.dll` 5.18 MB = **125.98 MB**.
- **Linux** `game/build/linux/`: bin 86.8 MB + `libvoxel.linux.template_release.x86_64.so` 9.78 MB = **96.58 MB**.
- **SteamOS** `game/build/steamos/`: idem Linux = **96.58 MB**. Todos EXIT 0, `embed_pck=true`.
- **T-029 CERRADO** (no data duplicada: un binario por plataforma, sin `.pck` suelto).
- **T-030 CERRADO** (objetivo provisional: Windows ≤130 MB, Linux/SteamOS ≤100 MB; gate `CiCdManager.size_bytes`).

### 4. Fix fuga de datos de tests al artifact
- Causa: `res://Godot/` (redirect de `user://` en tests) empaquetaba
  `app_userdata/isla-ancestral/m87_val_en_ok.po` (recurso de traducción **importado**); los JSON de
  analytics no entran al pck; fixtures M116 ya cubiertas por su `project.godot` anidado (warning de scan).
- Fix: `exclude_filter="Godot/*"` en los 4 presets (durable, commiteado) + `Godot/.gdignore`
  local (gitignored; elimina también el warning de scan del proyecto anidado).
- Verificación empírica: 0 hits `res://Godot` en el log de savepack; exe **−0.68 MB** (121.48 → 120.80).

### 5. Clasificación final de los 18 `[?]`
- Cerrados: **T-029/T-030** (build real).
- Externos (16) con dueño: M118×9, M96/infra×4, M116×1, M113×2. Cautelas del director (msg 05):
  i18n `#esperando:M87` (dueño real Ling-3.1-Flash), M52 y M31 → NO.
- Corrección de drift menor detectada al re-contar: la tabla de desglose listaba `T-052` en
  M96/infra pero el conteo real (`x=94 / ?=16` con script) muestra que el ítem es **T-025** →
  celda corregida en `05-Checklist.md`.

### 6. Verificaciones
- MCP Godot `get_debug_output` → "No active Godot process" (sin editor corriendo). N/A: la iter. 4
  no modificó GDScript.
- Encoding: los 7 archivos editados decodifican UTF-8 estricto (0 mojibake).

## Archivos Modificados/Creados
- `tools/ci/bump_version.py` (sync de `export_presets.cfg` + desync realineado)
- `tools/ci/test_bump_version.py` (18/18 + hardening encoding)
- `game/isla-ancestral/export_presets.cfg` (`exclude_filter="Godot/*"` ×4 + versiones 0.0.6)
- `game/isla-ancestral/Godot/.gdignore` (nuevo, local — gitignored)
- `DOCUMENTACION/117-Build-System/plan-actual/05-Checklist.md` (94/0/16 + evidencia iter. 4 + reserva liberada)
- `DOCUMENTACION/117-Build-System/plan-actual/04-Codigo.md` (Notas del Agente iter. 4)
- `CHECKLIST-GLOBAL.md` (fila 117 → 🟡 94/110; editado en worktree, sin commit por ediciones ajenas mezcladas)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (L11 + fila M117; worktree)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (bloque M117 → 🟡 liberado; worktree)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/06-2026-10-16_02-42-00-ds-v4.1-flash-opencode-a-glm-5.3-flash-director-informe-cierre-m117.md` (informe al director)
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md` (T-019 [x] + línea de Log)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 1888; cabeza quedó en 1889)
