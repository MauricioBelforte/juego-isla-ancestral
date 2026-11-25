# Log 2448: Los 12 críticos Nemotron — verificados uno por uno contra disco

**Fecha:** 2026-11-25
**Hora:** 10:31
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Contexto

El backlog heredado (`02-Backlog-Criticos-12.md`, fuente agnes-3-flash, Cron D del 9nov) tenía
12 críticos abiertos con la nota "code changes ya en worktree". Nadie los había verificado ni
marcado. Esta tanda los mide uno por uno contra el código actual y una suite con conteo real.

## Resultado: 12/12 cerrados

| # | Crítico | Evidencia (código) | Suite (checks/fallos) |
|---|---|---|---|
| 1 | VfxDirector RAM leak | `vfx_director.gd:108` `_process`→`actualizar`; `:111` `_exit_tree` | `test_vfx_m52_iter6.gd` 76/0 |
| 2 | HealthComponent NaN/negativo | `health_component.gd:126/138/151/157` | `test_health_component.gd` 46/0 |
| 3 | Logging RAM leak | `logger.gd:16` (buffer muerto eliminado) | `test_logger.gd` 14/0 |
| 4 | Save: pre-validación | `save_manager.gd:159` y `:253` | `test_prevalidacion_payload_m59.gd` 25/0 |
| 5 | DLC: manager | `dlc_manager.gd:184-187` gate de propiedad | `test_dlc_m120` 19/0, servicios 61/0, unit 50/0 |
| 6 | Economía: retiro cero + tope | `economy_manager.gd` MAX_SALDO + `retirar_monedas` | 11/0, 6/0, 7/0 |
| 7 | M17 lote 1: circulación + apoyo | `construccion` | `test_m17_circulacion.gd` 36/0 |
| 8 | M129: stock + numeración | `merch_manager.gd` 1..N por SKU | `test_merch_m129.gd` 58/0 |
| 9 | M129: boot B-17/B-12-06 | `merch_boot` | `test_merch_boot_m129.gd` 11/0 |
| 10 | M17: tests | — | 44/0 + 17/0 (7 suites de `scripts/construccion/`) |
| 11 | Regresión M21/M162 | — | 24 suites de `scripts/dialogos/`, **0 fallidas** |
| 12 | Verificación global 300 s | — | 18000 frames headless, exit 0, **0 SCRIPT ERROR** |

## Único cambio de código de la tanda

`game/isla-ancestral/scripts/dlc/test_dlc_m120.gd` estaba desactualizado respecto de su propio
producto: activaba `isla_hielo` sin registrar propiedad, y desde que el manager cerró el gate por
defecto (`dlc_manager.gd:184-187`) el test fallaba con `[FAIL] isla_hielo activo` (2 fallos de 16,
con `push_warning` y stack de Godot que parecía un crash y era el rechazo esperado).
Ahora el test fija el contrato completo: **sin** propiedad NO activa y no queda activo; **con**
propiedad SÍ activa. Resultado: **19 checks, 0 fallos**.

## Notas de medición

- La verificación global se corrió como `--headless --fixed-fps 60 --quit-after 18000`
  (18000 frames = 300 s simulados), 52,6 s de reloj real, 442 líneas de consola. Las 8 líneas
  `ERROR:` (`wrong RID`, `Parameter "m" is null`, `unimplemented base type ... scene cull`) son
  ruido del renderer en `--headless`, no errores de script: `SCRIPT ERROR = 0` y exit 0.
- `M129: 54 items` del backlog era el conteo **anterior** al cierre v3 del 2026-11-06; el
  `05-Checklist.md` de M129 hoy tiene **0 pendientes** (1 `[?]` de render 3D de mockups, dueño Hy4).
- `M17: 33 [ ] restantes` del backlog son **31** hoy: dos se cerraron desde el 9nov. Siguen siendo
  el frente post-crítico real (UI de modo, HUD, fantasmas, audio, navmesh, cross-module).

## Archivos modificados

- `game/isla-ancestral/scripts/dlc/test_dlc_m120.gd` (test actualizado al gate vigente)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash-DeepAI/BACKLOGS/02-Backlog-Criticos-12.md`
  (12 `[x]` con evidencia + estado real de post-críticos)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash-DeepAI/BACKLOGS/BACKLOG-MASTER.md`
  (bloque 2 cerrado, cola siguiente)

## Pendiente que hereda el próximo

Post-críticos: M17 (31 ítems, casi todos de UI/arte/audio y varios cross-module) y el `[?]` de
M129 (render 3D de mockups, dueño Hy4). Además, la deuda estructural de M62 (arista
`DataStore`↔`SaveManager` declarada, no resuelta) y el cierre real del copyright de assets vía
pipeline de exportación (M166/M09).