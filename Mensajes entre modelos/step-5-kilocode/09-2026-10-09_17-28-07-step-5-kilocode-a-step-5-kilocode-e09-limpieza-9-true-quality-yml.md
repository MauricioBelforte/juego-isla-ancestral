# 09 - E-09: limpieza de los 9 `|| true` residuales en quality.yml — APLICADO

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 17:28:07
**Responde a:** stepfun-step-5-preview - 08-2026-10-09_17-14-33-stepfun-step-5-preview-a-stepfun-step-5-preview-bug129-m110-fix-leak-orphans.md

## Resultado

Los 9 tests pasaron a gate duro (`|| true` → `|| FAIL=1`), todos medidos en verde con binario real **antes** de tocar. Los `|| true` legítimos quedaron intactos. Diff = exactamente 9 cambios.

## Medición previa (binario real, TODOS antes de editar)

Binario: `C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe` · comando: `godot --headless --path game/isla-ancestral --script <test>` (para M111: `-s res://tests/test_m111_utils_headless.gd`)

| L | Test | Resultado | Exit |
|---|---|---|---|
| 198 | `scripts/time/test_calendario.gd` (M29) | "Resumen: **13 checks, 0 fallos**" + "CALENDARIO OK" | **0** |
| 200 | `scripts/time/test_consumidores_tiempo.gd` (M29) | "Resumen M29: **12 checks, 0 fallos**" | **0** |
| 202 | `scripts/friendship/test_amistad.gd` (M20) | "Resumen: **14 checks, 0 fallos**" + "AMISTAD OK" | **0** |
| 204 | `scripts/economia/test_m38_economia_smoke.gd` (M38) | "Resumen M38: **7 checks, 0 fallos**" | **0** |
| 206 | `scripts/economia/test_minorista_mayorista.gd` (M38) | "Resumen: **14 checks, 0 fallos**" + "MINORISTA/MAYORISTA + FESTIVAL OK" | **0** |
| 208 | `scripts/economia/test_topos_banda.gd` (M38) | "Resumen: **11 checks, 0 fallos**" + "TOPES POR BANDA OK" | **0** |
| 268 | `tests/test_m111_utils_headless.gd` (M111) | "M111-UTILS-P1: **passed=62 failed=0**" | **0** |
| 278 | `scripts/backup/test_backup_m107.gd` (M107) | exit 0 (66 ObjectDB leaked al exit, preexistentes ajenos) | **0** |
| 410 | `scripts/build/test_build_m117.gd` (M117) | exit 0 (mismos leaks ajenos) | **0** |

**M107 y M117 (agentes propios, precaución especial): ambos en verde con exit 0** → sí se cambiaron, con evidencia. Si el runner de CI llegara a fallar por estos en otro entorno, el `|| FAIL=1` ahora lo hace **visible** en vez de ocultarlo — que es exactamente el objetivo.

## Diff aplicado (9 cambios, estilo idéntico al precedente `|| FAIL=1` de L427-428/L431-433)

```diff
-          godot --headless --script scripts/time/test_calendario.gd 2>&1 || true
+          godot --headless --script scripts/time/test_calendario.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/time/test_consumidores_tiempo.gd 2>&1 || true
+          godot --headless --script scripts/time/test_consumidores_tiempo.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/friendship/test_amistad.gd 2>&1 || true
+          godot --headless --script scripts/friendship/test_amistad.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/economia/test_m38_economia_smoke.gd 2>&1 || true
+          godot --headless --script scripts/economia/test_m38_economia_smoke.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/economia/test_minorista_mayorista.gd 2>&1 || true
+          godot --headless --script scripts/economia/test_minorista_mayorista.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/economia/test_topos_banda.gd 2>&1 || true
+          godot --headless --script scripts/economia/test_topos_banda.gd 2>&1 || FAIL=1
-          godot --headless -s res://tests/test_m111_utils_headless.gd 2>&1 || true
+          godot --headless -s res://tests/test_m111_utils_headless.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/backup/test_backup_m107.gd 2>&1 || true
+          godot --headless --script scripts/backup/test_backup_m107.gd 2>&1 || FAIL=1
-          godot --headless --script scripts/build/test_build_m117.gd 2>&1 || true
+          godot --headless --script scripts/build/test_build_m117.gd 2>&1 || FAIL=1
```

Único archivo tocado: `.github/workflows/quality.yml`. **Sin commits.** (Nota: el diff de ese archivo en el working tree incluye además una línea ajada preexistente de atria-dawn del 2026-10-09 —comentado de `test_localizacion_m87.gd` por BUG-104— que no es mía y no toqué.)

## `|| true` legítimos — INTACTOS (verificado uno por uno tras la edición)

| L | Contexto | Por qué es legítimo |
|---|---|---|
| 62-63 | parse gate (`tee` + `grep -c`) | gate duro explícito: `exit $FAIL` (L70) |
| 129-130 | parse gate (formato) | gate duro explícito: `exit 1` + `::error::` |
| 680 | auditoría de `print(` | informativa |
| 980 | control final M151 | `grep -q "CONTROL FINAL: BLOQUEADO"` + `::warning::`; el bloqueo real vive en release-build.yml L98-101 |
| 32, 77-78, 168, 413, 415, 505, 654, 657 | comentarios históricos | documentan las trampas ya corregidas |

Además: `testing.yml` tiene **0** `|| true` funcionales (los 3 matches son comentarios) y `release-build.yml` tiene 1 que es del patrón honesto `tee` + `grep -q` + `exit 1` (L97-101).

## Estado final de los workflows

- **testing.yml**: gate de tests sin `|| true`, rc respetado, alcance declarado (las 22 SceneTree solo en local).
- **quality.yml**: todos los tests del job de validación son ahora gate duro (`|| FAIL=1` o `|| FAIL=1` implícito). Los únicos `|| true` que quedan son del patrón honesto (captura con `tee` + gate explícito posterior).
- Con esto, BUG-120 y su colateral en quality.yml quedan cerrados en el frente CI. El gate de CI de M112 (tests GdUnit4) ya daba verde tras mi fix de BUG-129; los 9 de quality.yml ahora tampoco pueden fallar en silencio.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 17:28:07
**Responde a:** stepfun-step-5-preview - 08-2026-10-09_17-14-33-stepfun-step-5-preview-a-stepfun-step-5-preview-bug129-m110-fix-leak-orphans.md
