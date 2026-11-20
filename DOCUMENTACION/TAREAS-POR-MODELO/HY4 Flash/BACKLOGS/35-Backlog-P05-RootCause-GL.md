# Backlog 35 — P-05 root-cause: call sites `_GL()` sin migrar (16 en 3 archivos)

**Agente:** hy4-flash
**Origen:** corrida cron 2026-11-20 02:54 GMT-3, RAMA 2 (cola agotada); deriva de director 068/078 + reporte propio 070
**Fecha:** 2026-11-20
**Estado:** DIAGNOSTICADO — sin fix, sin GO para arreglar (no soy autor de `crucero/`)

## Tarea (única, verificada en disco)

- [x] T35-01 — Medir los call sites vivos de `_GL()` tras el commit `fd0667b` y confirmar el falso verde en runtime headless real.

## Evidencia

### Estático (HEAD, `git status` limpio en `scripts/crucero/`)

`fd0667b` ("Fix CRITICO: `_func _GL()` sintaxis invalida ... Regression global eliminada") quitó la definición `func _GL()` y la sustituyó por `var _gl` + helpers `_log_debug/_log_info/_log_warning/_log_error`, pero **dejó 16 llamadas sin migrar**:

| Archivo | Líneas | Cant. |
|---|---|---:|
| `game/isla-ancestral/scripts/crucero/crucero_manager.gd` | 71, 77, 82, 143, 158, 163, 173, 181, 201, 208, 252 | 11 |
| `game/isla-ancestral/scripts/crucero/crucero_eventos.gd` | 52, 56, 64, 144 | 4 |
| `game/isla-ancestral/scripts/crucero/crucero_interior.gd` | 59 | 1 |
| **Total** | **3 archivos** | **16** |

No existe `func _GL()` ni autoload que exponga `_GL()` en ningún `.gd` del proyecto (`grep -rnF "_GL"`). El único `_gl` con definición real está en `scripts/datos/test_datos_m60_iter4.gd:47,215` y apunta a `GameLogger`.

**Corrección propia:** el reporte 070 contabilizó 11 (solo `crucero_manager.gd`). La cifra correcta es 16: faltaban `crucero_eventos.gd` y `crucero_interior.gd`. No se hereda la medición anterior.

### Runtime (real, esta corrida)

Comando: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/mapa/test_mapa_busqueda.gd` (timeout 90 s).

- EXIT = **0**
- `SCRIPT ERROR: Parse Error: Function "_GL()" not found in base self.` × **11**
- Resumen impreso: `=== Resumen M54-Busqueda: 9 checks, 0 fallos ===` / `TEST OK — todos los checks pasaron`

Falso verde confirmado de nuevo: 11 errores de runtime no alteran el EXIT ni el contador de la suite.

### API correcta (para el dueño del fix)

- Autoload: `game/isla-ancestral/project.godot:27` → `GameLogger="*res://scripts/logging/logger.gd"`.
- `game/isla-ancestral/scripts/logging/logger.gd:39` → `enum Category { BOOT, SYSTEM, GAMEPLAY, WORLD, NETWORKING, ANALYTICS, CRASH }`.
- `logger.gd:148-160` → `debug/info/warning/error/critical(message: String, category: int = Category.SYSTEM, context: Dictionary = {})`.
- Trampa: los helpers de `crucero_manager.gd:5-13` declaran `cat: String`, pero los callers pasan un `int` de enum. Un reemplazo literal `_GL()` → `GameLogger` cambia un error por otro (int→String). La firma de los helpers debe pasar a `int` (o los callers deben pasar tags `String`).

## Decisiones que NO tomé

- Sin fix en repo; P-05 es diagnóstico y `crucero/` no es módulo propio.
- Sin marcas en `05-Checklist`, sin sello §21.8, sin `CHECKLIST-GLOBAL.md` / `quality.yml` / `AGENTS.md` / `project.godot`.
- Sin commit ni push.
- No re-medí el resto de las 23 suites: el centinela de P-01 ya las cubre y sus pisos están condicionados al post-fix.

## Pendiente del director

1. Reponer cola (0 tareas `[ ]` en los 34 backlogs del nicho).
2. Asignar dueño del fix de los 16 call sites.
3. GO opcional para versionar el centinela de P-01 (`Temp/p01_sentinel.py` + `Temp/p01_judge.py`).

**Firma:** hy4-flash
