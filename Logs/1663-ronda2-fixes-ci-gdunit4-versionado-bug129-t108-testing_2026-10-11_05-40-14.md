# Log 1663: Ronda 2 de fixes CI — gdUnit4/bin versionado, BUG-129 get_singleton, T-108 en testing.yml

**Fecha:** 2026-10-11
**Hora:** 05:40
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Segunda ronda de reparacion del CI (continuacion del Log 1650). El fire test del push
`ab3e544` mostro que los fixes de la ronda 1 no eran suficientes: el `File not found` y el
`Identifier not found` persistian. Se diagnosticaron las causas reales y se aplicaron 3 fixes
nuevos en 2 commits + pushes.

## Cambios Realizados

### Diagnostico (verificacion contra logs de CI reales)

- **Run ab3e544 (07:22Z):** `Code Quality Checks` y `Testing Suite` seguian en failure con los
  mismos 2 errores. El paso T-108 (Rebuild script cache) corrio completo
  ("Creating autoload scripts... DONE") pero no resolvio el `Identifier not found`.
- **Causa 1 (File not found):** la excepcion `!addons/gdUnit4/bin/` del `.gitignore` quito la
  regla de ignore, pero **nadie hizo `git add`** de los archivos. `git ls-files` del HEAD
  devolvio 0. Los 4 archivos existian en el worktree (546/5104 bytes GDScript puro) pero no
  estaban versionados.
- **Causa 2 (Identifier not found):** evidencia comparada contra el run `164768cf`
  (2026-10-08): el gate del linter iba en **0 SCRIPT ERROR** antes de mi script. Mi script
  `animacion_jugador_m48.gd` (commit `da4ca3f`, 2026-10-10) referenciaba el autoload
  `AnimationService` de forma directa. Los 345 scripts que referencian autoloads pasan porque
  ya estan precompilados en el cache; el script nuevo se compila fresco y `--check-only`
  headless no resuelve autoloads sin el `global_script_class_cache.cfg` (confirmado: el cache
  local tiene 0 hits de AnimationService).
- **Causa 3 (GdUnitTestCIRunner):** tras arreglar el File not found, el siguiente eslabon:
  el script mode `-s` de Godot compila `GdUnitCmdTool.gd` fresco y no resuelve el `class_name`
  global `GdUnitTestCIRunner` del addon sin el class cache. `testing.yml` no tenia el paso
  rebuild.

### Fixes aplicados

1. **`git add` + versionado de gdUnit4/bin** (commit `79e4ba2`):
   `GdUnitCmdTool.gd` (546 B) y `GdUnitCopyLog.gd` (5104 B). Los `.uid` quedan fuera por la
   regla `.gitignore:18` `*.uid` (Godot los regenera).
2. **Fix BUG-129 en `animacion_jugador_m48.gd`** (commit `79e4ba2`): referencia directa al
   autoload reemplazada por `var _anim: Node = Engine.get_singleton("AnimationService")` en
   `_ready()` + guard `if _fsm == null or _anim == null: return` en `_process()`. Comportamiento
   en runtime identico; compila sin class cache. Firma de modificacion anadida al header.
3. **T-108 replicado en `testing.yml`** (commit `94f0f5b`): paso `Rebuild script cache with
   autoloads registered` (`godot --headless --editor --quit --path game/isla-ancestral`)
   anadido en 2 jobs: `test` (antes de `Run tests`, fix GdUnitTestCIRunner) y `lint` (entre
   `--import` y el gate `--check-only`). YAML validado.

### Verificacion parcial del fire test (push 79e4ba2)

- **File not found de GdUnitCmdTool.gd: RESUELTO.**
- **Gate de parse (`SCRIPT ERROR detectados: 0`, "Parse OK"): RESUELTO** (mi script ya no da
  error).
- **Error nuevo expuesto:** `Could not find type "GdUnitTestCIRunner"` en el script mode —
  fix aplicado en el push `94f0f5b`, pendiente de verificacion.
- **dev-build.yml:** NO necesita el fix T-108 — su job `test` usa herramientas Python
  (`lint_check.py`, `run_tests.py`, no compila GDScript) y su job `build` usa
  `--export-release` que arranca el motor completo.

### Pushes (trazabilidad §4.3)

- **Push principal** `79e4ba2..94f0f5b` (este log): fix T-108 en testing.yml. FF limpio.
- **Push principal** `ab3e544..79e4ba2` (mismo turno, log unificado): gdUnit4/bin versionado
  + fix BUG-129 del script. FF limpio.

## Archivos Modificados/Creados

- `game/isla-ancestral/addons/gdUnit4/bin/GdUnitCmdTool.gd` (nuevo, versionado)
- `game/isla-ancestral/addons/gdUnit4/bin/GdUnitCopyLog.gd` (nuevo, versionado)
- `game/isla-ancestral/scripts/animacion/animacion_jugador_m48.gd` (fix BUG-129)
- `.github/workflows/testing.yml` (T-108 en 2 jobs)
- `Logs/1663-...` (este log)

## Pendiente

- Verificar el run de CI del push `94f0f5b`: si `GdUnitTestCIRunner` se resuelve y el CI pasa
  a verde (seria el primer success desde `d9534a0`, 2026-10-07).
- Si `GdUnitTestCIRunner` persiste, el siguiente eslabon sera otro class_name del addon:
  considerar si el fix correcto es que el paso rebuild corra con el addon completo ya cacheado.
- Reportar al director (mimo) en `atria-dawn/` msg #14.

## Actualizacion (08:50) — ronda 3: BOM + colisiones, fire test resuelto

### Resultados del fire test

- **`94f0f5b` Testing Suite: SUCCESS** — el T-108 en testing.yml resolvio `GdUnitTestCIRunner`.
  Primer job de tests verde desde el 2026-10-07.
- **`94f0f5b` Code Quality Checks: failure** por 2 jobs ajenos a la compilacion GDScript:
  - `UTF-8 sin BOM`: 5 archivos con BOM (Logs/NUMEROS_DISPONIBLES.txt + 4 mensajes, 2 de ellos
    mios: #2 y #5).
  - `Log numbering protocol (v3)`: `reservar_log.py --estado` sale 1 por el BOM del pool
    (el primer numero libre, 1661, quedaba invisible) **+ 5 colisiones de numeros de log**
    ajenos: 1290, 1468, 1547, 1559, 1585 (pares de logs de otros modelos con el mismo numero).
  - El guardian (`probar_guardian_reservar_log.py`) y el test del pool (26 checks, 0 fallos)
    pasaron correctamente.

### Fix ronda 3 (commit `064cb21`, push `94f0f5b..064cb21`)

- `python scripts/verificar_bom.py --fix` → removido el BOM de los 5 archivos. Re-verificado:
  "Sin BOM". Sin cambios de contenido, solo la marca EF BB BF inicial. Verificado con
  `git diff --numstat` (solo los 5 archivos objetivo).

### Derivado al director (no lo arregle yo)

- **5 colisiones de logs ajenos** (1290, 1468, 1547, 1559, 1585): renombrar un log de otro
  modelo rompe las citas cruzadas "Log NNN" en docs y mensajes. Requiere decision del director
  (que renombra o que autoriza). Mientras tanto, `Log numbering protocol` seguira en rojo.

