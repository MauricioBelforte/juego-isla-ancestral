# Backlog 32 — P-01 Centinela anti-falso-verde (24 suites)

**Agente:** hy4-flash
**Origen:** director 068 (P-01 prioridad alta) + 078 ("Arranca cuando quieras")
**Fecha:** 2026-11-19
**Estado:** CERRADO — diagnóstico y guard medido; SIN fixes de código

## Objetivo

Sustituir la señal "EXIT=0 + `N checks, 0 fallos`" por evidencia observable:
capturar stdout+stderr de las 24 suites Godot 4.7.2, medir los checks
realmente ejecutados con instrumentación independiente, fijar `CHECKS_MINIMOS`
medido en verde y probar el guardián EN ROJO por inyección antes de fiarse.

## Método (reproducible)

1. **Corrida real (repo, sin tocar nada):** 24 suites con
   `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://...`,
   timeout 120 s, stdout+stderr separados. Raw en `Temp/p01_sentinel/repo_*.out`.
2. **Sandbox A (verde):** copia del proyecto en `Temp/p01_sandbox/proj`.
   ÚNICAMENTE ahí se neutralizan las dos regresiones conocidas:
   - 11× `_GL().Category.XXX` → `"XXX"` en `crucero_manager.gd`.
   - `AmbientDirector`: se agregan `set_ducking/esta_ducking/esta_pausado` y
     4 nodos `Layer_0..3` (`AudioStreamPlayer`).
3. **Sandbox B (roto):** copia limpia del repo, sin ningún fix; instrumentada igual.
4. **Instrumentación:** una sola línea `print("[HY4F-CHECK]")` como primera
   sentencia del cuerpo de `_check()` en las 24 suites. Un marcador = una
   llamada realmente ejecutada. Cero marcadores perdidos en la medición.
5. **Pisos:** `CHECKS_MINIMOS` = marcadores medidos en Sandbox A (verde real,
   0 SCRIPT ERROR en 23/24; la 24ª se re-corrió con `Layer_0..3` presentes).
   Ningún piso estimado ni copiado de memoria.
6. **Guard:** RED si `EXIT != 0`, o SCRIPT ERROR (global o local), o
   `reportado != ejecutado`, o `ejecutado < piso`, o resumen literal
   (`print("N checks...")`), o `[FAIL]`/`FALLO:` visible.

**Límite de la instrumentación:** agregar un `print` por check no altera las
aserciones; solo hace observable cada llamada. Las copias están en Temp; el
repo quedó intacto (`git status --short game/isla-ancestral/scripts` vacío).

## Resultado medido

`rep` = número impreso por la suite. `ejec` = marcadores reales en el estado
actual del repo. `piso` = marcadores medidos en verde. `SE(g/l)` = SCRIPT ERROR
(globales de `crucero_manager.gd` / locales de la suite).

| Suite | rep | ejec | piso | SE(g/l) | EXIT | Veredicto |
|---|---:|---:|---:|---:|---:|---|
| M13 / test_herramientas.gd | 334 | 334 | 334 | 11 (11/0) | 0 | RED |
| M13 / test_herramientas_iter4.gd | 28 | 28 | 28 | 11 (11/0) | 0 | RED |
| M15 / test_recursos.gd | 23 | 23 | 23 | 11 (11/0) | 0 | RED |
| M15 / test_recursos_persistencia.gd | 23 | 23 | 23 | 11 (11/0) | 0 | RED |
| M15 / test_recursos_spawner_runtime.gd | 27 | 27 | 27 | 11 (11/0) | 0 | RED |
| M15 / test_m15_iter6_atria.gd | 14 | 14 | 14 | 11 (11/0) | 0 | RED |
| M29 / test_calendario.gd | 13 | 13 | 13 | 11 (11/0) | 0 | RED |
| M29 / test_semilla_iter1.gd | 25 | 25 | 25 | 11 (11/0) | 0 | RED |
| M29 / test_time_calendar.gd | 74 | 74 | 74 | 11 (11/0) | 0 | RED |
| M29 / test_time_calendar_events.gd | 51 | 51 | 51 | 11 (11/0) | 0 | RED |
| M29 / test_time_cycles_year.gd | 39 | 39 | 39 | 11 (11/0) | 0 | RED |
| M30 / caso_reloj_tests.gd | 29 | 29 | 29 | 11 (11/0) | 1 | RED |
| M30 / test_reloj_hud.gd | 14 | 17 | 17 | 11 (11/0) | 0 | RED |
| M30 / test_reloj_localizacion.gd | 6 | 6 | 6 | 11 (11/0) | 0 | RED |
| M33 / test_farm.gd | 29 | 29 | 29 | 11 (11/0) | 0 | RED |
| M33 / test_farm_features_m33.gd | 39 | 39 | 39 | 11 (11/0) | 0 | RED |
| M33 / qa_farm_pausas_m33.gd | 35 | 35 | 35 | 11 (11/0) | 0 | RED |
| M33 / test_farm_m33_lote.gd | 42 | 42 | 42 | 11 (11/0) | 0 | RED |
| M33 / test_farm_voxel_m33.gd | 27 | 27 | 27 | 11 (11/0) | 0 | RED |
| M33 / test_farm_clima.gd | 20 | 20 | 20 | 11 (11/0) | 0 | RED |
| M42 / test_ambient_m42.gd | 9 | 9 | 14 | 13 (11/2) | 0 | RED |
| M54 / test_mapa_m54.gd | 42 | 42 | 42 | 11 (11/0) | 0 | RED |
| M54 / test_mapa_markers.gd | 9 | 9 | 9 | 11 (11/0) | 0 | RED |
| M54 / test_mapa_busqueda.gd | 9 | 9 | 9 | 11 (11/0) | 0 | RED |
| **TOTAL** | **961** | **964** | **969** | **266 (264/2)** | — | **24/24 RED** |

## Hallazgos nuevos (además del regres global ya reportado en 070)

1. **El baseline "961 checks, 0 fallos" no es evidencia.** 266 líneas
   `SCRIPT ERROR` en 24 suites (11 por suite + 2 locales en M42); 23 suites
   con EXIT 0 pese a eso. El contador de la suite no registra errores de
   runtime: solo cuenta las llamadas a `_check()` que alcanzaron a ejecutarse.
2. **M42: falso verde cuantificado.** En el repo imprime `9 checks, 0 fallos`,
   EXIT 0. En verde miden 14 checks. Faltan 5 ejecuciones silenciosas por
   dos capas de error: (a) `set_ducking` / `esta_pausado` inexistentes en
   `AmbientDirector`; (b) con esos métodos agregados, `Layer_0` no existe
   (`test_ambient_m42.gd:81-82` accede `.volume_db` de `null`) y se saltan
   2 checks más. La capa (b) no había sido reportada antes.
3. **M30 `test_reloj_hud.gd:48` imprime un número literal.** El código dice
   `print("14 checks, %d fallos ...")`; la instrumentación mide **17**
   ejecuciones en verde y en roto. El contador `_checks` existe pero no se
   usa en el resumen: el resumen miente por −3. No es falso verde de
   aserción (17/17 pasan) pero invalida cualquier agregación por resumen.
4. **Único fallo de aserción real del baseline:** `caso_reloj_tests.gd`,
   EXIT 1, deuda C56/M62 (`Time.get_datetime_string_from_system` en
   `scripts/rendimiento/memoria/`). 29/29 checks ejecutados.
5. **Orden de magnitud agregado:** reportados 961, ejecutados 964 (+3 de
   reloj_hud), esperados en verde 969 (−5 de M42). Ninguna de esas tres
   cifras es igual; usar 961 como "checks verificados" es incorrecto.

## Guard probado EN ROJO (antes de confiar en él)

- **Inyección real de error de runtime** en `test_mapa_busqueda.gd` dentro de
  Sandbox A: `var nulo: Node = null; nulo.get_name()` insertado antes del
  tercer check de `_test_busqueda`. Resultado medido:
  `SCRIPT ERROR: Cannot call method 'get_name' on a null value.`,
  resumen impreso **`8 checks, 0 fallos`**, **EXIT 0**, 8 marcadores vs piso 9
  → guard **RED** (`SCRIPT_ERROR_LOCAL=1`, `PISO 8<9`). El archivo inyectado
  fue restaurado inmediatamente. Raw: `Temp/p01_sentinel/injection_runtime.out`.
- **Inyecciones sintéticas sobre el guard puro:** baseline verde → GREEN;
  +1 SCRIPT ERROR → RED; checks 9→7 → RED; resumen ausente → RED;
  1 `[FAIL]` → RED; EXIT 1 → RED. 6/6 comportamientos esperados.
- Nota: la primera inyección (llamada a método inexistente) dio parse error
  y 0 checks; se descartó por poco representativa y se rehízo con error de
  runtime en mitad de la suite. No se oculta el intento fallido.

## Límites y decisiones que no tomé

- No arreglé `crucero_manager.gd`, M42, `reloj_hud` ni la deuda C56: P-01 es
  verificación. Los fixes en Sandbox A existen solo para MEDIR el piso verde.
- No apliqué marcas en `05-Checklist`, no sellé §21.8, no toqué
  `CHECKLIST-GLOBAL`, `quality.yml`, `AGENTS.md` ni `project.godot`.
- No hice commit ni push. Repo sin cambios en `game/isla-ancestral/scripts`.
- El guard está implementado en `Temp/p01_sentinel.py` + `Temp/p01_judge.py`.
  No lo instalé como herramienta versionada: hace falta GO del director.
- Los pisos quedan condicionados al estado post-fix: cuando ERNIE corrija
  ESC=3.2 y el dueño corrija `crucero_manager`, hay que re-medirlos en verde
  antes de reutilizarlos (un piso verde heredado es falso verde).

## Siguiente favorable

- P-03 (verificación post-saneo de Totales/GLOBAL) sigue en cola; P-04 también.
- P-05 queda RED hasta que desaparezcan las 11 llamadas `_GL()` y se
  re-corran boot + 24 suites con este centinela.

**Firma:** hy4-flash
