# Log 1197 - M59 iter. 1: 3 bugs reales (carga imposible, metadatos vacios, aviso de version futura)

- **Modelo:** DeepSeek-V4.1-Flash
- **Plataforma:** WorkBuddy
- **Fecha:** 2026-10-02 20:04
- **Modulo:** M59 (Guardado)
- **Iteracion:** 1 (relevo sec21.4.7; el reclamo previo de la fila 59 era de agnes-2.5-flash, descatalogado)
- **Log:** 1197 (reservado del pool via protocolo v3, AGENTS.md 6.1.a)
- **Checklist del modulo:** 58 [x] / 71 [ ] / 1 [?] (era 55/75/0)
- **Binario:** Godot_v4.7.2-stable_win64_console.exe

## 1. Objetivo

Tomar M59-Guardado con autonomia total. El encargo pedia: (a) providers ISaveProvider reales,
(b) conectar los hitos de M07 a `request_save()`, (c) **medir** si hace falta background thread
(glm lo dejo `[?]` porque "los saves < 10 KB no lo justificaban"), y (d) correr siempre la suite
heredada antes de tocar nada.

Se priorizo dentro del modulo: **primero la correccion del modulo** (habia bugs reales que hacian
que el sistema no cumpliera su funcion), y la medicion pedida en (c).

## 2. Prerequisito: suite heredada

`validate_save.gd` ANTES de tocar codigo: **13 checks, 0 fallos, EXIT 0**. Requisito cumplido.

## 3. HALLAZGO PRINCIPAL - BUG CRITICO: ningun save valido se podia cargar

`SaveLoader.load()` devolvia `CORRUPTED` (sin backup) o `RECOVERED` (con backup) para **cualquier**
save leido del disco. Con backup presente el juego cargaba **el save ANTERIOR en silencio**
(perdida de progreso); sin backup no cargaba nada.

Causa raiz MEDIDA (no inferida) con sonda headless:

```
JSON round-trip de {"a":1}      -> typeof=3 (TYPE_FLOAT) valor=1.0
save valido leido del disco     -> schema_version=1.0 (FLOAT), time.day=5.0 (FLOAT)
SaveSchema.validate()           -> ["schema_version no es int", "time.day no es int"]
SaveLoader.load() (sin backup)  -> result=2 (CORRUPTED)
SaveLoader.load() (con backup)  -> result=3 (RECOVERED); cargo dia 5.0 mientras el disco tenia 99
```

`JSON.parse_string()` de Godot 4.7 devuelve **float** para todo numero (`1` -> `1.0`;
`TYPE_INT=2`, `TYPE_FLOAT=3`). `SaveSchema.validate()` exigia `typeof(x) == TYPE_INT` para
`schema_version` y `time.day`, asi que **todo** payload que volvia del disco fallaba y `load()`
caia a `_try_recover()`.

Fix (2 piezas, minimas):
- `save_schema.gd`: nuevo `_es_entero(v)` que acepta `int` o `float` con valor entero
  (`is_finite(f) and f == floorf(f) and absf(f) <= 2^53`). `validate()` lo usa para
  `schema_version` y `time.day`. El schema exige un entero SEMANTICO; JSON no preserva el tipo,
  asi que validar el tipo crudo era un error de diseno.
- `save_loader.gd`: tras el parseo, `payload["schema_version"] = int(...)`, restaurando el
  contrato del campo que el propio loader compara.

## 4. Por que la suite heredada estaba verde (ceguera por OMISION de asercion)

`validate_save.gd` estaba en 13/13 verde. **Ningun test afirmaba `LoadResult.OK`:**
- `_test_checksum_detection` aceptaba `RECOVERED or CORRUPTED` (disyuncion laxa) y luego fijaba
  `CORRUPTED` - pero solo ejercitaba el camino de ERROR.
- `_test_migration_path` llamaba `SaveSchema.validate()` sobre el `default_payload()` **en
  memoria** (que conserva los int), nunca sobre un payload leido del disco.

No era una asercion que consagrara el bug: era la **ausencia** de la asercion del camino feliz.
Se cerro anadiendo `_test_carga_valida()` (3 checks): el payload del disco debe pasar `validate()`,
`load()` debe dar `OK` y el dia debe conservarse. 13 -> 16 checks.

## 5. Bugs 2 y 3

- **`slot_metadata()` devolvia `{}` siempre.** Hacia `JSON.parse_string(archivo_completo)`, pero el
  archivo NO es JSON: su primera linea es el checksum SHA-256 en hex (`checksum\npayload`), asi
  que el parseo fallaba siempre. Fix: `SaveWriter.parse_document()` (valida checksum y extrae el
  payload). Afectaba al item D "Mostrar metadatos por slot" y a la futura UI de slots (M53).
- **`FUTURE_VERSION` sin aviso.** `SaveLoader` devolvia `FUTURE_VERSION` en silencio. El rechazo
  ya era correcto (no migra hacia atras, no toca el archivo, `load_slot` no fija `current_slot`),
  pero faltaba el "aviso claro" del item V. Fix: `push_warning` explicito con slot y ambas
  versiones; la senal `slot_loaded(slot, FUTURE_VERSION)` ya llevaba el codigo a la UI (M53).

## 6. Medicion: hace falta background thread? (seccion R, "Guardado en background thread (< 80 ms)")

Rondas intercaladas (7-15 por tamano), payload REAL de 4,2 KB + sinteticos de 2/30/120 KB:

```
write_atomic real 4,2 KB   med=22,66 ms  min=19,52  max=46,12   (presupuesto frame = 16,67 ms)
write_atomic 120 KB        med=45,88 ms
request_save() end-to-end  =48,20 ms     (write_atomic + rotacion de backups)
SaveBackup.rotate()        med=27,41 ms
```

Descomposicion por fases (mediana de 9 rondas):

```
 2KB  ser=0,27  open=1,24  write=0,02  close=0,23  readback=1,16  sha=0,35  rename=20,33  TOTAL=23,25
30KB  ser=1,76  open=0,99  write=0,13  close=0,10  readback=7,65  sha=2,35  rename=17,16  TOTAL=30,10
120KB ser=6,94  open=0,99  write=0,22  close=0,09  readback=9,38  sha=7,14  rename=16,81  TOTAL=42,55
```

Conclusion: el coste lo domina el **I/O del SO** (rename/crear/borrar en `user://` =
`AppData/Roaming`, ~17-40 ms con varianza alta), **NO el tamano del payload** (`serialize` 0,27 ms
para 4 KB). Cumple el criterio `< 80 ms` del item, pero **excede el presupuesto de frame
(16,67 ms a 60 FPS)** -> hitch de 1-3 frames por guardado. El hilo esta **justificado**; el item
queda `[?]` con dueno **M61** (no tocado, por regla). La premisa heredada ("los saves < 10 KB no
justifican hilo") queda **refutada**.

## 7. Prueba en rojo (el guardian esta VIVO)

- **Sonda externa (codigo real, pre-fix):** con el fix revertido, `validate_save.gd` da
  **16 checks / 3 fallos / EXIT 1** nombrando `["schema_version no es int", "time.day no es int"]`
  y `resultado=2 (CORRUPTED)`. Con el fix: **16 checks / 0 fallos / EXIT 0**.
- **Suite nueva `test_slots_m59.gd` pre-fix:** **19 checks / 7 fallos / EXIT 1**.
- **Piso `CHECKS_MINIMOS` probado en rojo:** copia temporal con el piso mutado a 99 ->
  `PISO NO CUMPLIDO: 22 checks < CHECKS_MINIMOS=99` + EXIT 1; control (piso 22) EXIT 0.
- El guardian de la propia suite detecto un bug propio durante el desarrollo (`_abrir()` usaba
  nombres largos y `_fin()` claves cortas, asi que `erase()` nunca casaba y los bloques quedaban
  abiertos -> EXIT 1 "suite incompleta"). Corregido antes de dar por verde.

## 8. Verificacion final

```
validate_save.gd   16 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR   (x3)
test_slots_m59.gd  22 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR   (x3, 5 bloques cerrados)
```

`test_slots_m59.gd` es nueva y usa la guardia anti-falso-verde de 3 capas de M62: `_fin(clave)`
por bloque + piso `CHECKS_MINIMOS = 22` MEDIDO en verde + `_summary()` en `call_deferred`
separado (sobrevive a un SCRIPT ERROR que aborte `_run()`). Verificado tambien que el aviso de
version futura se emite:

```
WARNING: [SAVE] El save del slot 3 es de una version FUTURA (v2 > v1 soportada). No se carga
para no degradarlo; actualiza el juego.
```

Gates en `.github/workflows/quality.yml`: `validate_save.gd` pasa de `|| true` (no-op, trampa 81)
a `|| FAIL=1`; `test_slots_m59.gd` se anade con `|| FAIL=1`. YAML validado (12 jobs).

## 9. Documentacion actualizada

- `DOCUMENTACION/59-Guardado/plan-actual/05-Checklist.md`: items D-metadatos, H-versiones y
  V-version futura a `[x]`; item R-background-thread a `[?]` con la medicion y dueno M61; bloque
  de reserva actual + notas de iteracion; totales 58/71/1. EOL CRLF preservado
  (invariante crlf==lf==cr: 273/273/273).
- `DOCUMENTACION/59-Guardado/plan-actual/04-Codigo.md`: notas del agente (iter. 1).
- `Mensajes entre modelos/ESTADO-PARALELO.md`: entrada de la sesion.
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`: registro del Log 1197.
- **`CHECKLIST-GLOBAL.md` NO se toco:** una sesion del coordinador tiene una tarea de pipes en
  vuelo sobre ese archivo (su diff sin commitear ya reescribe las filas 62/70/91). La fila 59
  necesita, cuando el coordinador libere el archivo: estado -> En curso, agente ->
  DeepSeek-V4.1-Flash, progreso -> 58/130.

## 10. Push (huella - AGENTS.md 4.3)

- **Rango:** (pendiente de completar tras el push)
- **Tipo:** fast-forward a `main`, sin `--force`, `GIT_TERMINAL_PROMPT=0`.
- **Commits propios:** (pendiente)
- **Nota de repo compartido:** el worktree `main` lo comparten ~4 agentes; entre el inicio y el
  cierre de esta iteracion aparecio el commit AJENO `9dcee9f` (M54, pin creation right-click).
  El push se hace sobre ese HEAD.

## NO sella sec21.8

Autor != verificador. El delta de la iter. 1 de M59 queda para verificacion de hy3/agnes/mimo.
