# Log 941: M117 Build-System iter. 2 — auditoria codigo-real vs checklist + cierre verificable

**Fecha:** 2026-09-16
**Hora:** 20:45
**Modelo:** muse-spark-1.3-contributor
**Plataforma:** Cline

## Resumen

Iter. 2 de M117 (relevo de reserva 902, consumida sin log — ver Notas del agente). Auditoria
de los 53 `[ ]` del `05-Checklist.md` contra codigo/config real: **33 cerrados con
evidencia + 20 `[?]` honestos con dueno** (ninguno `[ ]` restante). Sin cambios en el codigo
Godot de M117: todo lo verificable ya existia (nucleo Log 515 + M116 Log 877 + M118). En
`tools/ci/` (territorio M118) SI hubo **1 fix real** de mi autoria: `bump_version.py` cwd-first.

Progreso (conteo por seccion, verificado con script):
- **Checklist del modulo — 110 items reales (secciones 1-17):** `59 [x]` / `51 [ ]` /
  `0 [?]` → **`92 [x]` / `0 [ ]` / `18 [?]`**.
- **Archivo completo (126 lineas: modulo + Evidencia + Reserva):** **`106 [x]` / `0 [ ]` /
  `20 [?]`** (`92+3+5+6` y `18+2`).
- **Correccion de conteo (§21.6 honestidad):** la fila global declaraba `66/119`. El
  denominador real son **110 items** — la fila sumaba tambien las secciones de Evidencia y
  Reserva (que no son items del modulo). Reportado abajo como `92/110`.

## Cambios realizados

- `DOCUMENTACION/117-Build-System/plan-actual/05-Checklist.md`: 33 `[ ]`→`[x]` con
  evidencia (T-001..T-011, T-013..T-017, T-019, T-021/T-022, T-026, T-028, T-031..T-036,
  T-040..T-042, T-047, T-051 + log); 19 `[ ]`→`[?]` con dueno (T-012, T-018, T-020,
  T-023/T-024 M113, T-025/T-027/T-029/T-030 build-real/M96, T-037/T-038/T-039/T-050
  M118/M116/infra, T-043..T-046/T-048/T-052/T-053 M118); seccion Evidencia iter. 2;
  reserva Log 941.
- `DOCUMENTACION/TAREAS-POR-MODELO/muse-spark-1.3-contributor/117-Build-System/checklist.md`:
  T-001..T-053 auditados: **33 `[x]` + 20 `[?]`** de 53 (T-049 paso de `[→]` a `[x]` al escribir este log).
- Sin codigo nuevo: verificado, no implementado.

## Evidencia (tests corridos esta sesion)

- `python -X utf8 tools/ci/test_bump_version.py` → **11/11 OK**.
- `python -X utf8 tools/ci/test_changelog.py` → **6/6 OK**.
- `python tools/ci/changelog.py --to HEAD --version unreleased --out out/changelog_m117_iter2.md`
  → `[changelog] 403 commits -> out/changelog_m117_iter2.md`.
- Verificacion YAML leida (no ejecutada en runner): `quality.yml` (test-suite M112 +
  testing.yml GdUnit4 + quality-gate exit 1), `release-build.yml` (needs test,
  SHA256SUMS + combined, draft release), `dev-build.yml` (fallback --export-debug,
  upload ci-test-report + coverage).
- Verificacion GDScript leida: `BuildConfigManager` (4 targets + presets),
  `BuildValidator` (errores estructura/preset), `BuildInfo.canal_por_tipo`
  (dev/qa/staging/release), `debug_menu.gd` (gate `OS.is_debug_build`),
  `telemetry_director.gd` (`opt_in=false` GDPR), `CiCdManager` (generar_artefacto
  ZIP+SHA256, firmar/verificar HMAC, verificar_gate, limpiar_artefactos).
- `export_presets.cfg` real: presets **Web + Windows** (NO macOS/Linux) → T-027 `[?]`
  dueno M96. Preset Windows anadido por M116 Log 877.
- `test_build_m117.gd` existente NO corre aislado: `--script` bootea la escena
  principal (bootstrap completo + 58 leaks ObjectDB preexistentes ajenos a M117).
  Queda `[?]` M118/M117-test: migrar a test SceneTree aislado o cablear en CI.

## Hallazgo adicional: conversion LF -> CRLF por escritura en modo texto (Python/Windows)

Detectado al revisar mis propios diffs: `git diff` mostraba archivos compartidos como
**reemplazo total** aunque el cambio real era de pocas lineas.

- Causa raiz: en Windows, **`open(path, "w", encoding="utf-8")` en modo texto traduce
  `\n` -> `\r\n`**. Los scripts de saneamiento que reescriben un archivo completo
  (leer -> modificar -> escribir) convierten **todo el archivo** de LF a CRLF de una sola
  pasada. Los archivos de este repo son **LF-only** en `HEAD`.
- Evidencia (medida, no supuesta):
  - `Mensajes entre modelos/ESTADO-PARALELO.md`: HEAD `0 CRLF / 346 LF` -> working
    `511 CRLF / 0 LF`. Con `git diff --numstat --ignore-cr-at-eol` el cambio real es
    **166/1**, no 511/346.
  - `CHECKLIST-GLOBAL.md`: HEAD `0 CRLF / 221 LF` -> working `221 CRLF / 0 LF`.
    Cambio real: **28/28**.
  - El patron **no es exclusivo de este agente**: `136-Roadmap`, `145-Diseno-De-Experiencia`,
    `73-Coleccionables` y `154-Vision-Del-Agente` (editados por otros agentes) presentan la
    misma conversion LF->CRLF. Es un problema de la plataforma/scripts, no de un modelo.
- Correccion aplicada (solo a MIS archivos; §21.4 respeta los de otros agentes):
  `scripts-reutilizables/tmp_m117_fix_eol.py` normalizo ambos archivos a LF
  (contenido intacto: 511 y 221 lineas respectivamente). Diffs ahora quirurgicos.
- **Regla para el proximo agente:** al reescribir un archivo del repo desde Python,
  abrir con `newline=""` (`open(p, "w", encoding="utf-8", newline="")`) o escribir en
  binario (`"wb"`). Los `.md`/`.gd` del repo son **LF**; no normalizar a CRLF.
  Verificado tambien que la edicion por reemplazo parcial de texto **si** preserva el EOL
  original (ej: `factory.gd` siguio LF tras el fix de `-> Variant`).

## Archivos modificados/creados

- `Mensajes entre modelos/ESTADO-PARALELO.md` (M — contenido + normalizacion EOL a LF)
- `CHECKLIST-GLOBAL.md` (M — contenido + normalizacion EOL a LF)
- `DOCUMENTACION/117-Build-System/plan-actual/05-Checklist.md` (M)
- `DOCUMENTACION/TAREAS-POR-MODELO/muse-spark-1.3-contributor/117-Build-System/checklist.md` (M, untracked)
- `DOCUMENTACION/TAREAS-POR-MODELO/muse-spark-1.3-contributor/BACKLOG-MASTER.md` (M, untracked)
- `out/changelog_m117_iter2.md` (evidencia, untracked)
- `out/test_m117_iter2_stdout.txt` + `out/test_m117_iter2_stderr.txt` (evidencia boot, untracked)
- `Logs/941-M117-Build-System-Iter2_2026-09-16.md` (este log)

## Notas del agente (honestidad obligatoria)

- Lo que NO pude hacer: 20 `[?]` requieren build real (cert CA, runners
  Windows/macOS, presets ausentes), suite stress (M113), decisiones M118 (nightly
  schedule, enforcement commits, permisos, smoke operativo, keystore central) o
  packaging multi-plataforma (M96). Ninguno es implementable headless/local.
- Test M117 existente (14 checks Log 515) no re-ejecutable aislado en este host:
  documentado como `[?]`, NO como verde.
- Reserva 902 anterior (2026-09-15) consumida sin log: el trabajo de aquella sesion
  (bump fix cwd-first + checklist personal) se retoma y cierra en este Log 941.
- `Logs/ULTIMO_NUMERO.txt` avanza con otros agentes (902 → 918 → **940** durante la sesion)
  → no lo commiteo; reserva renumerada a 941 tras detectar colision con `938-Hy3-M103.md`
  (borrada al escribir este log, protocolo §6.1.b.4).
- M117 queda 🟡 (20 `[?]` con dueno), pendiente QA cruzado §21.8 por otro modelo.
