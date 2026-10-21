# Log 2080 - M102-Bug-Tracking - Metricas unificadas desde 11-BUGS.md

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 15:45
**Modulo:** M102-Bug-Tracking
**Item:** 31 de la COLA ACTIVA - "M102-Bug-Tracking: unificar metricas con 11-BUGS.md (reporte automatico)"
**Via:** RAMA 1 (msg 350 del director = acuse de mi 349 + decisiones, sin trabajo propio asignado)
**Tipo de entrega:** herramienta + suite + informe generado (codigo, no diseno)

---

## 1. Premisa MEDIDA antes de escribir codigo

Tres mediciones de 2 minutos que cambiaron el alcance:

1. **El dashboard no mide el registro.** `docs/bug_metrics.md` y
   `.github/workflows/bug_metrics.yml` cuentan SOLO issues de GitHub. El dashboard
   declara literalmente `Bugs abiertos | 0`, `Bugs cerrados (total) | 0` y
   "Sin alertas activas (sin bugs registrados aun)".
2. **El registro real tiene 25 no resueltos.** `DOCUMENTACION/11-BUGS.md`, seccion 5:
   92 filas, 88 IDs unicos, 14 `[ ]` abierto + 7 `[?]` delegado + 4 `[->]` en progreso
   = **25 no resueltos**; 67 resueltos.
3. **Ninguna herramienta de metricas lee 11-BUGS.md.** `grep -rl "11-BUGS"` sobre
   `scripts/*.py` da 16 archivos y ninguno calcula metricas; `scripts/verificar_bugs_gate.py`
   lo abre solo para bloquear P0/P1 (no cuenta nada).

Conclusion medida: el "0 bugs" del dashboard es un **falso verde de universo** - no
mide el registro del proyecto, mide otra fuente. Los dos universos nunca se cruzaban.

---

## 2. Entregado

### 2.1 `scripts/metricas_bugs.py` (NUEVO, 34.141 B)

Metricas unificadas sobre `DOCUMENTACION/11-BUGS.md` + drift entre sus dos
representaciones (tabla resumen de la seccion 5 vs entradas de las secciones 6/7/8).

- Cuenta: filas, IDs unicos, entradas, por estado, por severidad, por modulo, por
  reportero, ID maximo, huecos de numeracion (con clasificacion), no resueltos.
- Detecta 9 familias de defecto: `fila_malformada`, `estado_desconocido`,
  `estado_sin_marca`, `severidad_desconocida`, `id_duplicado_tabla`,
  `entrada_duplicada`, `fila_sin_entrada`, `entrada_sin_fila`,
  `etiqueta_severidad_inconsistente`, `seccion_pegada`, `dashboard_divergente`.
- Modos: informe humano, `--json` (SOLO JSON), `--check`, `--report RUTA`,
  `--archivo RUTA`, `--dashboard RUTA`, `--selftest`.
- Codigos de salida segun convencion del repo: 0 sin defectos / 1 defectos /
  2 uso / **3 DETECTOR CIEGO** (no colapsar "no pude mirar" con "mire y encontre").

### 2.2 `scripts/test_metricas_bugs.py` (NUEVO, 16.342 B)

20 checks. NO congela los conteos de hoy (11-BUGS.md lo editan varios agentes por dia:
fijar "92 filas" seria consagrar un dato vivo); congela INVARIANTES y el poder
discriminante del detector.

### 2.3 `DOCUMENTACION/102-Bug-Tracking/plan-actual/08-Metricas-Bugs.md` (NUEVO, 10.139 B)

Informe generado por `--report`. Es regenerable: no se edita a mano.

---

## 3. Defectos medidos en el registro: 79

| Tipo | Cantidad |
|---|---|
| `entrada_sin_fila` (entrada sin fila en la tabla) | 49 |
| `entrada_duplicada` (mismo ID con 2 encabezados) | 8 |
| `fila_sin_entrada` (fila sin entrada) | 8 |
| `id_duplicado_tabla` (mismo ID 2 veces en la tabla) | 4 |
| `etiqueta_severidad_inconsistente` (mismo emoji, otra palabra) | 4 |
| `fila_malformada` (celdas != 7) | 3 |
| `estado_sin_marca` (estado en texto, sin `[x]`) | 1 |
| `seccion_pegada` (encabezado con otro embebido) | 1 |
| `dashboard_divergente` (dashboard 0 vs registro 25) | 1 |

Casos concretos medidos (linea del archivo):
- L153 `BUG-127` 14 celdas | L177 `BUG-088` 15 celdas | L205 `BUG-118` 6 celdas.
- L3061 `## 7. Bugs Resueltos (historial)## BUG-119: ...` - el encabezado de seccion y
  el de la entrada estan PEGADOS: la entrada de BUG-119 es invisible al parser.
- L149/L172 `BUG-071`, L154/L206 `BUG-129`, L155/L207 `BUG-130`, L159/L209 `BUG-139`
  aparecen dos veces en la tabla.
- L141 `BUG-058` declara `Resuelto` sin marca (se cuenta igual, se declara el formato).

### Huecos de numeracion: 3, clasificados

- `[23, 119]` **mencionados sin entrada canonica**: BUG-023 usa
  `## [2026-09-03 05:45] - Bug 023: ...` (formato alternativo) y BUG-119 vive dentro del
  encabezado pegado. El parser NO inventa entradas por ellos: los reporta como huecos
  "mencionados", que es la verdad medible.
- `[45]` **ausente del registro entero**: no aparece con ningun formato.

---

## 4. Evidencia de la suite (medida, x3)

| Corrida | Resultado | EXIT |
|---|---|---|
| 1 | 20 PASS, 0 FAIL | 0 |
| 2 | 20 PASS, 0 FAIL | 0 |
| 3 | 20 PASS, 0 FAIL | 0 |

`--selftest` del medidor: **29 OK / 0 FALLO / EXIT 0 x3**.

### Prueba EN ROJO (no se hereda un verde)

4 inyecciones de regresion en el medidor, cada una restaurada byte-exacto
(sha256 `afc8dbbc927e0e09...` identico antes y despues):

| Inyeccion | Efecto esperado | Medido |
|---|---|---|
| A: el detector de filas malformadas deja de mirar las celdas | suite roja | EXIT 1, 4 fallos nombrados |
| B: `normalizar_estado` devuelve siempre None | suite roja | EXIT 1, 7 fallos nombrados |
| C: el registro sin tabla ya no se declara ciego | suite roja | EXIT 1, 1 fallo nombrado |
| D: el pipeline de defectos se vacia | suite roja | EXIT 1, 3 fallos nombrados |

### Prueba EN ROJO del piso `CHECKS_MINIMOS`

Suite recortada a 17 checks (se quitaron 3 llamadas del runner):
`[FALLO] piso de checks ejecutados -> solo 17 checks ejecutados (minimo 20)` / EXIT 1.
Restaurada byte-exacto -> 20 PASS / EXIT 0.

---

## 5. Higiene de bytes (medida por bytes, no mirando)

| Archivo | Bytes | BOM | CR | LF sueltos | U+FFFD |
|---|---|---|---|---|---|
| `scripts/metricas_bugs.py` | 34.141 | False | 0 | 815 | 0 |
| `scripts/test_metricas_bugs.py` | 16.342 | False | 0 | 366 | 0 |
| `.../08-Metricas-Bugs.md` | 10.139 | False | 0 | 137 | 0 |

Este mismo Log se verifica por bytes al cierre (no se autodeclara un tamano que
cambiaria al escribirlo): ASCII puro, CRLF puro, sin BOM.

---

## 6. Regresiones y gates

- `scripts/verificar_bom.py`: **mis 3 archivos NO aparecen** en la lista. El gate sigue
  ROJO por deuda AJENA (mensajes de `agnes-3-flash/`, `tools/legal/generate_item_attribution.py`
  y su test). No la toco: es de otro dueno.
- `scripts/diagnosticar_mojibake.py`: mis 3 archivos no aparecen (0 hallazgos propios).
- **0 archivos existentes modificados**: los 3 paths son nuevos (`??` en `git status`).
- `scripts/test_scripts.py` no descubre suites (enumera a mano): mi suite es standalone,
  igual que `test_verificar_cjk.py`.

---

## 7. Limites declarados (no son excusas, son el alcance)

1. El parser reconoce entradas con `^#{2,3} BUG-NNN`. Un encabezado con OTRO formato
   (`## [fecha] - Bug 023`, encabezado pegado) **no** cuenta como entrada: se reporta
   como hueco "mencionado". Inventar la entrada seria peor que declarar el hueco.
2. El script **solo lee** `11-BUGS.md`. Los 79 defectos son deuda del registro, no del
   script: no edito el registro (es el documento vivo de todo el proyecto).
3. `--check` sale **1 hoy** (79 defectos). Por eso **no** lo cableo a CI: un gate que
   nace rojo se neutraliza o se ignora. `quality.yml` ademas es del director.
4. La comparacion con el dashboard usa `docs/bug_metrics.md`; si ese archivo no existe,
   el medidor sigue midiendo el registro local (el dashboard es universo paralelo, no
   fuente de verdad).

---

## 8. Pedidos al director

1. **Commit** de los 3 paths nuevos (`scripts/metricas_bugs.py`,
   `scripts/test_metricas_bugs.py`, `.../08-Metricas-Bugs.md`). No commiteo sin
   autorizacion (regla dura).
2. **Decision de CI**: cablear `test_metricas_bugs.py` a `quality.yml` es del director.
3. **Decision de baseline**: hoy hay 79 defectos de sincronizacion en `11-BUGS.md`.
   Opciones medidas: (a) arreglarlos (dueno del registro vivo), (b) declararlos como
   `DEUDA_CONOCIDA` en el script (patron de `validar_workflows.py`) y recien entonces
   cablear `--check` como gate, (c) dejarlo como informe manual.
4. **M102 checklist**: el modulo esta 140/140 y **no tiene un solo item sobre
   `11-BUGS.md`** (0 apariciones de esa ruta en su `05-Checklist.md`). El cierre 140/140
   no cubria esta integracion; si el director quiere trazabilidad, hace falta un item
   nuevo (no lo agrego yo).
5. Marca del item 31: **propongo `[x]`** (herramienta + suite + informe medidos en
   disco), pero el flip lo aplica el director.

---

## 9. Numeracion de esta vuelta

- **Log 2080**: pool `Logs/NUMEROS_DISPONIBLES.txt` cabeza medida justo antes de
  reservar = 2080 (consumido; cabeza post = 2081).
- **Mensaje 351**: pool de canal cabeza medida = 351 (= ultimo 350 + 1).
- **Tracker**: 349 -> 350 (el 350 es el mensaje del director que esta vuelta proceso).
- **`reservar_log.py --estado` al cierre**: 11 problemas de numeracion, **TODOS AJENOS y
  anteriores** (1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726, 1876, 1878, 1888). **Ninguno
  toca el 2080.** No los toco: renumerar un log ajeno es destructivo (se reporta y se sigue).
- **0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.**

---

## 10. Addendum post-cierre (medido, no accionado)

Al verificar el estado final, `git log --oneline -3 -- <mis 3 artefactos>` devuelve **`a005456`**
("Se agrego el reporte automatico de metricas de bugs y el alta de la seccion 19.1 de la guia"):
**el CRON DEL DIRECTOR ya commiteo mis 3 artefactos** mientras esta vuelta estaba en curso
(misma clase de evento que los commits `c99559b` y `7866aed` de vueltas anteriores).

Medido, no supuesto:
- `git diff --stat HEAD -- scripts/metricas_bugs.py scripts/test_metricas_bugs.py
  DOCUMENTACION/102-Bug-Tracking/plan-actual/08-Metricas-Bugs.md` = **vacio**: lo commiteado es
  la version FINAL (byte a byte), no un estado a medio escribir.
- El Log **si** quedo commiteado en una version previa: el blob de `HEAD` tiene 8.788 B y el
  worktree 9.259 B; `git diff --stat HEAD -- <log>` = **3 inserciones** (justo la nota de
  `--estado` que agregue despues). **El blob de HEAD es LF y el worktree CRLF**, que es lo
  correcto en este repo (`core.autocrlf=true`: el blob va LF, el arbol CRLF); ASCII puro en los dos.
- **No commiteo el residuo**: sin autorizacion (regla dura). Va en el proximo barrido del cron.

Consecuencia para el pedido 1 de la seccion 8: **ya no hace falta** pedir el commit de los 3
paths; queda solo el residuo de 3 lineas del Log.

Firma: DeepSeek-V4.1-Flash (WorkBuddy) - 2026-10-21.
