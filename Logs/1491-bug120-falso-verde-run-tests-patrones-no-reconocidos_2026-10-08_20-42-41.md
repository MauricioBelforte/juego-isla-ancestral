# Log 1491: BUG-120 falso-verde del runner de tests — fix de patrones no reconocidos en _analizar_salida()

**Fecha:** 2026-10-08
**Hora:** 20:42
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

Se diagnosticó y corrigió la causa del falso-verde del runner de tests de M112
(`tests/run_tests.gd`, v2c). El runner reportaba suites como OK **sin contar sus
checks** porque 2 de las 21 suites SceneTree imprimen sus resultados en formatos
que `_analizar_salida()` no reconocía. Se agregaron 3 patrones de parseo. Verificado
con sonda unitaria aislada (12/12) y con el runner real (tests totales 718 → 780).

## Diagnóstico (veredicto del msg 138)

El falso-verde original (mimo Log 1451 → v2c) **ya estaba resuelto** con guardas
reales: `tests_total > 0`, `suites_ok == ejecutables`, rc capturado, exclusiones
documentadas vacías, timeout. Se descartaron las causas clásicas:
- (i) `|| true` — no existe.
- (ii) exit code ignorado — se captura y propaga (L240-245).
- (iii) exclusiones silenciosas — la lista está vacía y documentada.

La causa real es **(iv) "otra cosa"**: suites que imprimen resultados en formatos
no reconocidos por `_analizar_salida()`. La suite se marcaba OK (no falló) pero
su conteo de checks quedaba en 0 — verde sin verificación efectiva.

## Cambios Realizados

En `game/isla-ancestral/tests/run_tests.gd`, función `_analizar_salida()`
(L218-239):

1. **Patrón 4** — `passed=(\d+)\s+failed=(\d+)` (salida nativa de Godot
   `--script` de suites SceneTree, ej. `test_m111_utils_headless.gd`).
2. **Detección de `FALLO:` sin corchetes** — las suites que imprimen líneas de
   fallo sin el formato `[FAIL]` (ej. `  FALLO: ...`) ahora se detectan.
3. **Patrón `N fallo(s)`** — `(\d+)\s+fallo\(s\)` para los reportes en español.

Las guardas existentes (tests_total>0, suites_ok vs ejecutables, rc) quedaron
**intactas** (L240-245).

## Evidencia de validación

### Sonda unitaria aislada (rojo + verde): 12/12 OK, EXIT 0

Sondeo aparte confirmó que el parámetro `exit` GDScript funciona (un fallo de la
sonda fue omisión mía de la guarda `exit != 0` al transcribirla; el runner real
la tiene intacta en L243). Casos cubiertos:
- M111 verde: 62 checks detectados
- M111 rojo inyectado: ok=false (antes **CIEGO**, ahora detecta)
- inventory_unificado verde y rojo
- rc != 0 detectado
- Regresiones: patrón `[FIN]` (37 checks) y `OK/fallos` (57 checks) siguen parseando

### Runner real con fix aplicado

| Métrica | Antes | Después |
|---|---|---|
| M111 checks | 0 | **62** |
| SceneTree checks | 697 | **759** |
| Tests totales | 718 | **780** |
| Suites ejecutables | 25 | 25 |
| Suites con fallo | 19 (mal contadas) | 3 (reales) |

Resultado final: `RESULTADO: FALLO — 19/25 ejecutables · 3 con fallo(s)`.

### Los 3 fallos residuales (no causados por el fix)

Son los `[?]` conocidos de M112:
- `npc_visual_database` rc=1
- `equipment_manager` rc=1 (watchdog "npcviz/equip")
- `GdUnit4` rc=101, tests=21, errors=0, failures=0 (watchdog "GdUnit debug
  201 orphans")

### Segundo fix relacionado (commit dc057fa, este log)

Durante la autorización de `test_inventory_unificado.gd` (msg 141 del director)
se descubrió **otro falso-verde de la misma familia**: `_run()` no esperaba a
`_test_toggle()`/`_test_overlay()` (ambas con `await` internos), así que
`quit()` mataba el proceso antes de reanudarlas → **6 de 8 checks nunca se
ejecutaban**. Corregido con `await`; los 8 checks ahora corren y pasan
(8 checks, 0 fallos, exit=0).

## Archivos Modificados/Creados

- `game/isla-ancestral/tests/run_tests.gd` — fix de patrones en
  `_analizar_salida()` (L218-239); guardas intactas L240-245. Absorbido por el
  merge `41765e6` del director (verificado: `git show HEAD:...run_tests.gd`
  contiene los comentarios exactos de este fix).
- `game/isla-ancestral/tests/unit/ui/test_inventory_unificado.gd` — commit
  `dc057fa`: `await _test_toggle()` / `await _test_overlay()` + conteo de checks
  (formato `N checks, M fallos`).
- `game/isla-ancestral/tests/test_m111_utils_headless.gd` — referencia: L32
  imprime `M111-UTILS-P1: passed=%d failed=%d` (62/0), L34 `  FALLO:` sin
  corchetes.

## Commits

- Fix BUG-120 (run_tests.gd): absorbido por merge `41765e6` del director.
- Fix inventory_unificado: `dc057fa` (1 archivo, verificado con
  `git diff --cached --name-only` antes del commit).

## Pool de logs

Número **1491** tomado directamente de `Logs/NUMEROS_DISPONIBLES.txt` (cabeza
anterior 1491, nueva cabeza 1492) — restricción levantada por el director en el
msg 143.
