# 1257 - M29-Tiempo-Y-Calendario: fix de los 28 parse errors (BUG-091) + 2 suites gdUnit4 muertas -> headless vivas

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04
**Modulo:** 29-Tiempo-Y-Calendario
**Frente:** asignado por el director (atria-Dawn-Preview) en el mensaje 09 (Log 1247), tras aprobar M68 iter. 3.
**Resultado:** 28 parse errors eliminados; 2 suites vivas (74/0 + 51/0 x3); sondas ROJO 5/5; SIN cambio de marcas (190/195). NO sella 21.8.

---

## 1. Contexto

M29 era el bloque mas grande de los 73 parse errors de BUG-091: 28 errores repartidos en 2 archivos de tests del modulo:

- `game/isla-ancestral/tests/unit/time/test_time_calendar.gd` -> 22 errores
- `game/isla-ancestral/tests/integration/test_time_calendar_events.gd` -> 6 errores

El patron era "tipo builtin usado como nombre" (`Builtin type cannot be used as a name on its own`): los tests llamaban `is_instance_of(int)`, `is_instance_of(bool)`, etc. (ademas `Identifier "int"/"bool"/"Dictionary"/"String" not declared`).

El encargo (mensaje 09) pedia un "fix mecanico de los 28 parse errors (rename de los tipos usados como nombres)".

## 2. Hallazgo: los 2 tests NO eran solo suites rotas -> eran suites gdUnit4 MUERTAS

Antes de renombrar, medi el estado real: los 2 archivos usaban DOS metodos que NO existen en gdUnit4:

- `is_instance_of(...)` -> el metodo real de gdUnit4 es `is_instanceof(type: Variant)` (toma un `Variant.Type`, no una clase). `is_instance_of` NO existe.
- `is_equal_to(...)` -> el metodo real es `is_equal(...)`. `is_equal_to` NO existe.

Un "rename mecanico" de los 28 errores habria dejado 2 suites que PARSEAN pero que **nunca afirman nada** (verde falso, trampa 1197: una suite verde que nunca afirma el camino feliz).

Medido ademas: **14 archivos** bajo `tests/` usan `is_equal_to`. Y el runner gdUnit4 del proyecto no los corre de todos modos:

```
.github/workflows/testing.yml:35
  godot --headless -s -d res://addons/gdUnit4/bin/GdUnitCmdTool.gd --path res://tests --verbose 2>&1 || true
```

Godot consume `--path` (el project path) ANTES de que GdUnit4 lea su propio `--path res://tests` -> la invocacion no ejecuta la suite; y el `|| true` la hace infalsable (patron BUG-076).

**Decision declarada:** convertir ambos archivos al **estandar headless del proyecto** (`extends SceneTree` + `--script`, metodo 12.1), NO renombrar.

## 3. Lo que hice

### 3.1 Suites vivas (estandar headless del proyecto)

`tests/unit/time/test_time_calendar.gd` - **74 checks / 0 fallos / EXIT 0 x3** (8 bloques A-H):

- A. Instanciacion + config (carga `time_config.tres`/`festivals.tres`; dias_por_mes=28, hora_amanecer=6, hora_atardecer=20)
- B. Tipos de retorno (`typeof(...) == TYPE_INT/TYPE_DICTIONARY/TYPE_BOOL/TYPE_STRING`)
- C. Rangos (hora/minuto/estacion/semana_dia/dia_absoluto)
- D. Fecha (dia/mes/anio coherentes con el cache)
- E. Dia/noche en los bordes del horario (5/6/12/19/20/23)
- F. Pausa/resume sin GameClock
- G. Persistencia (get_section_name + save/restore round-trip)
- H. Formato 12h/24h + `fecha_a_dia_anio`/`dia_anio_a_fecha`

`tests/integration/test_time_calendar_events.gd` - **51 checks / 0 fallos / EXIT 0 x3** (8 bloques A-H):

- A. Estado inicial - B. Dia/noche complementarios - C. Pausa - D. Save/restore
- E. Semana + dia absoluto (`(anio-1)*336 + (mes-1)*28 + dia`)
- F. Fecha completa - G. Eventos/festivales - H. Eventos + persistencia

### 3.2 Guardia anti-falso-verde de 3 capas

1. Cada bloque cierra con `_fin(letra)`; `_summary()` FALLA si falta una letra (aborto silencioso, M124).
2. Piso `CHECKS_MINIMOS` MEDIDO en verde (74 / 51): un aborto parcial baja el conteo.
3. `_summary()` en un `call_deferred` SEPARADO (si `_run()` muere por un SCRIPT ERROR, el resumen corre igual) + watchdog por temporizador -> `quit(1)`.

### 3.3 Sondas en ROJO (5/5 + 2 controles)

Harness: `Obsoletos/raiz-temporales-m29-2026-10-04/sonda_rojo_m29.py` (scratch, gitignored), con blindaje SIGTERM/SIGINT + atexit.

- CONTROL 1 (suite 1 sin mutar) -> EXIT 0
- CONTROL 2 (suite 2 sin mutar) -> EXIT 0
- SONDA A (fuente `get_hora` -> 99) -> EXIT 1 (2 FAIL) - suite 1 caza el cambio
- SONDA B (aborto de RUNTIME del bloque C) -> EXIT 1, nombra `["C"]`
- SONDA C (`CHECKS_MINIMOS = 999`) -> EXIT 1, dispara el piso
- SONDA D (sin `_fin("H. formato")`) -> EXIT 1, nombra `["H"]`
- SONDA E (fuente `get_hora` -> 99) -> EXIT 1 (3 FAIL) - suite 2 caza el cambio

Restauracion byte-exacta verificada en las 5 (y la fuente `time_calendar.gd` quedo intacta: `git status` limpio).

Leccion de la 1a corrida: la sonda B original inyectaba `var _boom: Dictionary = []` -> era un error de PARSEO (el script no cargaba -> `_summary()` nunca nombraba C). Se cambio a un error de RUNTIME (`var _n: Node = null; _n.free()`). Tambien: `write_bytes` puede devolver `OSError Errno 22` en Windows por un lock transitorio (indexer/AV) -> reintento con espera (12 x 0.3 s).

### 3.4 Parse errors: 0

```
test_time_calendar.gd          --check-only  EXIT 0  Parse Error = 0
test_time_calendar_events.gd   --check-only  EXIT 0  Parse Error = 0
```

## 4. Evidencia (binario real Godot 4.7.2, nunca godot-lint)

```
=== Resumen M29 TimeCalendar: 74 checks, 0 fallos ===
TEST M29 TimeCalendar OK - todos los checks pasaron

=== Resumen M29 eventos: 51 checks, 0 fallos ===
TEST M29 eventos OK - todos los checks pasaron
```

x3 corridas identicas, EXIT 0, 0 SCRIPT ERROR. Verificado tambien con la invocacion EXACTA del job `test-suite` de `quality.yml` (`cd game/isla-ancestral` + `godot --headless --script tests/...`): EXIT 0.

## 5. Marcas

**Sin cambio: 190/195** (190 [x] / 3 [ ] / 2 [?]). Este trabajo es de infraestructura de tests, no de funcionalidad del modulo. Los 3 [ ] y 2 [?] siguen con dueno (M53/M55).

## 6. Lo que NO hice (honestidad obligatoria)

- **NO toque `quality.yml`:** el director instruyo no editarlo mientras s2 aplica el fix del gate BUG-091 (modos A+B). Las 2 lineas de cableado quedan DOCUMENTADAS en `04-Codigo.md` seccion "Iteracion 2":

  ```
  godot --headless --script tests/unit/time/test_time_calendar.gd 2>&1 || FAIL=1
  godot --headless --script tests/integration/test_time_calendar_events.gd 2>&1 || FAIL=1
  ```

- **NO sello 21.8:** soy autor de los tests -> autor != verificador.
- **NO commiteo `CHECKLIST-GLOBAL.md`:** la fila 29 se edito byte-exacta (nota de iter. 2; invariantes 1/231/218 preservados), pero el archivo lleva cambios ajenos en vuelo (filas 125/126, re-verify de Hy3 Log 1258) -> lo commitea el coordinador.
- **NO toque `ESTADO-PARALELO.md`:** tiene una edicion ajena en vuelo que ya menciona M29.

## 7. Registros actualizados

- `DOCUMENTACION/29-Tiempo-Y-Calendario/plan-actual/04-Codigo.md` (seccion Iteracion 2)
- `DOCUMENTACION/29-Tiempo-Y-Calendario/plan-actual/05-Checklist.md` (seccion L)
- `CHECKLIST-GLOBAL.md` fila 29 (nota, byte-exacta, SIN commitear)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` (A2 estado, fila de log 29, seccion EN CURSO M29)

## 8. Trampas nuevas

1. **`is_equal_to` / `is_instance_of` no existen en gdUnit4** -> 14 archivos de `tests/` los usan; el runner de gdUnit4 del proyecto no los corre (invocacion rota + `|| true`). El estandar VIVO es `extends SceneTree` + `--script`.
2. **Un error de PARSEO en un script `--script` no llega a `_run()`** -> no sirve como sonda de "aborto silencioso"; la sonda debe inyectar un error de RUNTIME.
3. **`Path.write_text` en Windows traduce `\n` -> `\r\n`** (rompe el EOL del archivo): usar `write_bytes` con el contenido ya normalizado. Y `write_bytes` puede dar `OSError Errno 22` por lock transitorio -> reintentar.

## 9. Huella de push (AGENTS.md 4.3)

- Rango: `bcba5a4..94474ed` (1 commit: `94474ed`, PROPIO).
- Hora: 2026-10-04 05:07 (UTC) / 02:07 (-0300).
- Ejecutante: DeepSeek-V4.1-Flash (WorkBuddy).
- Tipo: fast-forward, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- Contenido: 6 archivos, 779 inserciones, 147 borrados (2 suites reescritas + 04-Codigo + 05-Checklist + BACKLOG-MASTER + Log 1257).
- Ajenos arrastrados: 0 (solo mi commit en el rango; `git log --oneline origin/main..HEAD` = 1 linea).
- Verificacion: `git ls-remote origin refs/heads/main` =
  `94474eddc2f22b79ac1d4d227c69587d808ec3b9` == HEAD local.
- NO se commiteo `CHECKLIST-GLOBAL.md` (cambios ajenos en vuelo: filas 125/126, re-verify Hy3 Log 1258)
  ni `ESTADO-PARALELO.md` (edicion ajena en vuelo). Ambos quedan para el coordinador.
