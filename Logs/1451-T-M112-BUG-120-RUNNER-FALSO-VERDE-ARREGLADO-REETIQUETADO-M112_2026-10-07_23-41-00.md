# Log 1451: T-M112 / BUG-120 — runner falso-verde arreglado (evidencia 718 tests) + reetiquetado honesto de M112

**Fecha:** 2026-10-07
**Hora:** 23:41
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del director (msg 57): (1) arreglar `tests/run_tests.gd` — que corriera las
suites de verdad y exigiera evidencia de ejecución (conteo > 0), o declararlo
honestamente no-verde; (2) reetiquetar el framework de testing en las docs de
M112; (3) no romper `quality.yml` / gate M103 y correr el gate antes y después.
Todo cerrado con evidencia medida.

## Diagnóstico (BUG-120)

- **Reproducción:** `godot --headless -s res://tests/run_tests.gd` → `EXIT 0` +
  `RESULTADO: EXITO — Todos los tests pasaron` con **0 tests**.
- **Causa raíz:** la v1 invocaba `GdUnitCmdTool.gd -- --path res://tests --verbose`.
  `CmdArgumentParser.parse()` descarta hasta el nombre de la tool usando
  `OS.get_cmdline_args()`, array al que Godot **no agrega los argumentos tras
  `--`** (van a `get_cmdline_user_args()`). El parser ve solo `["-s", "…"]` →
  `GdUnitResult.empty()` → `show_help()` → `quit(RETURN_SUCCESS)` = exit 0 sin
  ejecutar nada. Verificado con 2 probes (ya borrados).
- **Lecciones laterales:** `OS.execute` no captura el stdout de un hijo Godot en
  este build (patrón de `scripts/templos/test_regresion_templos.gd`); sin
  `--ignoreHeadlessMode` GdUnit sale 103; `--path` no es flag de GdUnit.

## Cambios realizados

- **`tests/run_tests.gd` reescrito (v2c):** descubre `tests/**/test_*.gd`
  (excluye `helpers/`), clasifica SceneTree vs GdUnit4, ejecuta **una suite por
  subproceso** con salida redirigida a archivo (`cmd /V:ON /C … & echo
  !errorlevel!`), **timeout 180 s (GdUnit 300 s) + `taskkill /T /F`**, parsea el
  `Overall Summary` real de GdUnit, y aplica guardas anti-falso-verde:
  `EXIT 0` solo si suites ejecutadas == descubiertas-ejecutables **Y** tests > 0
  **Y** 0 fallos; **`EXIT 2` = sin evidencia (0 tests)**. El éxito mintiroso es
  estructuralmente imposible.
- **Invocación GdUnit4 corregida:** `godot --headless -s
  res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a <dirs> --ignoreHeadlessMode`
  (sin `--`, sin `--path`).
- **Fix de las 4 suites GdUnit4** (21/21 tests): guards `if not X.is_node_ready():
  await X.ready` (foto ×3, ui ×3, debug ×2), captura de lambda por wrapper
  (foto), `layer.toggle()` en el test de slots (ui), assert del diagnóstico al
  formato vigente `DIAGNOSTICO Isla Ancestral` + `Fecha:` (debug).
- **Exclusión documentada** en el runner de `tests/test_debug_menu.gd` (raíz):
  API muerta (`is_visible/show_menu/…`) y un SCRIPT ERROR la deja en loop
  eterno → `[?]` con dueño M110.
- **Docs M112:** `04-Codigo.md` con nueva sección 0 (etiquetado honesto: framework
  híbrido 22 SceneTree + 4 GdUnit4, artefactos inexistentes, `testing.yml` con
  `|| true`); `05-Checklist.md` con sección T-M112 (12 [x] / 5 [?], firmada, byte-level
  para no tocar su cp1252) y línea de reapertura en la reserva.
- **`11-BUGS.md`:** insertados **BUG-119** (informe de cierre del director,
  falso positivo — se había perdido en el incidente 21:09) y **BUG-120** (este)
  en §7 con causa, fix, evidencia y hallazgos delegados.

## Evidencia

**Corrida final del runner (2026-10-07):**
```
[EVIDENCIA] suites descubiertas: 26 (22 SceneTree + 4 GdUnit4) · excluidas documentadas: 1
[EVIDENCIA] suites OK: 19/25 ejecutables · checks SceneTree: 697 · GdUnit4: 21 · tests totales: 718
RESULTADO: FALLO — 19 suites OK de 25 · 718 tests corridos · 3 con fallo(s)   (EXIT 1)
```
**Gate antes/después** (`scripts/templos/test_regresion_templos.gd`, intacto):
76 checks / 0 fallos / `EXIT 0` en ambas corridas (piso 649 verificado).
`quality.yml` no tocado.

**Nota de frescura:** la evidencia 718 es **previa** al fix de BUG-121
(null-guard de fauna, agnes-3-flash, Log 1440, 2026-10-08 00:42): ese fix solo
mejora los números (M78/M107/M110 con 0 SCRIPT ERROR).

## Hallazgos delegados ([?] en M112 05-Checklist, fuera de alcance)

- `tests/unit/data/test_npc_visual_database.gd` → rc=1, corta antes de su
  resumen (watchdog en el primer bloque). Dueño: suite visual/NPC.
- `tests/unit/player/test_equipment_manager.gd` → rc=1, corta en bloque A.
  Dueño: M59.
- GdUnit4 `tests/unit/debug/test_debug_menu.gd` → **201 orphans → rc=101** pese
  a 21/21 PASSED. Dueño: M110.
- `tests/test_debug_menu.gd` (raíz) → API muerta, excluida del runner. Dueño: M110.
- `.github/workflows/testing.yml` → flag `--path` inválido + `|| true` (el CI
  nunca falla). **NO tocado** (requiere instrucción del director). Dueño: M118.

## Archivos modificados/creados

- `game/isla-ancestral/tests/run_tests.gd` (v2c; respaldo v1 en `tests/Obsoletos/2026-10-07_22-00-01_run_tests.gd`)
- `game/isla-ancestral/tests/unit/foto/test_photo_service.gd`
- `game/isla-ancestral/tests/unit/ui/test_equipment_layer.gd`
- `game/isla-ancestral/tests/unit/debug/test_debug_menu.gd`
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/04-Codigo.md`
- `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md`
- `DOCUMENTACION/11-BUGS.md` (BUG-119 restaurado + BUG-120)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md`
- `Mensajes entre modelos/mimo-v2.6-flash-free/58-…` (informe de cierre)
- `Logs/NUMEROS_DISPONIBLES.txt` (reserva 1451)

## Reglas

Sin commit ni push (encargo directo). `quality.yml`, `interaction_manager`,
`service_registry`, `bootstrap`, `main_island`, pool 1290 y CHECKLIST-GLOBAL no
tocados. `11-BUGS.md` y `ESTADO-PARALELO.md` contienen cambios de otros agentes
(incidente 21:09 + BUG-121) → no se pusieron en el índice.
