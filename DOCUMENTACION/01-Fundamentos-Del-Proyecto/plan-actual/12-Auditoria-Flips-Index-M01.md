# 12 — Auditoría de flips del índice maestro M01 (2026-10-28)

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy) · **Log:** 2228 · **Módulo:** M01-Fundamentos-Del-Proyecto
**Tarea:** BACKLOG-MASTER (A) COLA ACTIVA ítem 3 — «M01 b2: continuar (docs del 05-Checklist con cita de archivo)»
**Naturaleza:** medición + herramienta + suite. **0 flips aplicados** (los aplica el director).

---

## 1. Qué se midió y con qué criterio

El índice maestro (`plan-actual/05-Checklist.md`, 152 ítems = un módulo del plan inicial cada uno) se
evalúa con el criterio **ratificado por el director en la iter. 8** y ya implementado en
`scripts/auditar_indice_m01.py`:

> `[x]` sostenido ⇔ **checklist propia del módulo 100 % cerrada** (`[ ]` = 0 y `[?]` = 0)
> **Y fila de `CHECKLIST-GLOBAL.md` en estado `✅`**.

Medición por **prefijo de línea** (`^\s*-\s+\[([ x?])\]`), nunca por substring.

## 2. Resultado de hoy (medido, no heredado)

| Métrica | Valor |
|---|---|
| Ítems del índice | **152** |
| `[x]` | **122** |
| `[ ]` | **30** |
| `[?]` | **0** |
| `[x]` **sostenidos** hoy | **36** |
| `[x]` **NO sostenidos** hoy | **86** |

`**Totales:**` del propio archivo (línea 251) declara «Completados: 29 · Pendientes: 123» → **stale**
frente a los 122/30 reales. Es la trampa ya conocida: la línea de totales no se recalcula sola.

## 3. De dónde salen los 86

El salto de marcas es **un solo commit**: `dd6fb70` (2026-10-25 00:19:28, «preservación de la
jornada de coordinación»), `105` líneas agregadas / `96` quitadas sobre el índice.

**Línea base correcta: `19615fd`** (el commit donde se aplicó la iter. 8/9, con sus citas y sus
reverts). Medido contra esa base:

| Concepto | Valor |
|---|---|
| `[x]` en la base | **32** (todos sostenibles hoy) |
| Flips `[ ] → [x]` que mete `dd6fb70` | **90** |
| Reversiones `[x] → [ ]` | **0** |
| De los 90, sostenidos hoy | **4** (M64, M71, M74, M76) |
| De los 90, NO sostenidos hoy | **86** |
| `[x]` al cierre | **122** |

`4 + 86 = 90`. **Los 86 flips no sostenidos son exactamente los que entraron en ese commit**, y solo
4 de los 90 se sostienen.

> **Nota de método (error propio corregido en la misma vuelta):** la primera medición se hizo contra
> `2e12dc1`, que es *anterior* a la iter. 8, y por eso el diff mostraba 96 flips y 3 «preexistentes»
> que en realidad eran **re-flips**. Comparar contra el commit equivocado no solo cambia las cifras:
> invierte la conclusión sobre los reverts (§6).

## 4. Clases de los 86 (por qué no se sostienen)

| Clase | N | Significado |
|---|---|---|
| `modulo_abierto` | **24** | la checklist del módulo **todavía tiene `[ ]`** → el flip se adelantó |
| `solo_interrogantes` | **24** | 0 `[ ]` pero con `[?]` abiertos |
| `cerrada_sin_fila_ok` | **38** | checklist cerrada, **la fila del GLOBAL no está en `✅`** (palanca del director) |
| `sin_checklist` | **0** | — |

Los 24 `modulo_abierto` son los más graves: el índice afirma cerrado un módulo que tiene trabajo
pendiente en su propia checklist. Extremos medidos (**`[x]` / `[ ]` / `[?]`**, medido por carpeta):

| Índice | Carpeta | `[x]` | `[ ]` | `[?]` |
|---|---|---|---|---|
| M40 | 41-Musica | 60 | **50** | 0 |
| M19 | 20-Sistema-De-Amistad | 102 | **48** | 0 |
| M16 | 17-Construccion | 135 | **39** | 1 |
| M44 | 45-Arte-3D | 157 | **12** | 2 |
| M58 | 59-Guardado | 116 | **12** | 2 |

## 5. Auditoría de cita: los 90 flips no citan nada

| Momento | Líneas con anotación `FLIP` |
|---|---|
| `2e12dc1` (antes de la iter. 8) | **0** |
| `19615fd` (iter. 8 + 9) | **9** |
| HEAD (hoy) | **9** |

Los 9 ítems citados son **M05, M18, M21, M89, M99, M113** (los 6 flips de la iter. 8) y
**M69, M98, M117** (los 3 de la iter. 9); los 9 se sostienen hoy y **ninguno de ellos está entre los
90 de `dd6fb70`**. O sea: **los 90 flips del commit de preservación tienen 0 citas** — ni uno solo
dice contra qué evidencia se flipeó, y 86 de ellos no se sostienen.

## 6. Hallazgo grave: el flip masivo deshizo una corrección ratificada

La iter. 8 revirtió 3 marcas (M31 → 32-Clima, M77 → 78-Legal-PI, M112 → 113-Pruebas-De-Stress)
porque no sostenían el criterio. **Esas 3 reversiones sí se aplicaron**: en `19615fd` las tres están
en `[ ]`. Medido commit a commit:

| Commit | M31 | M77 | M112 | `[x]` totales |
|---|---|---|---|---|
| `2e12dc1` (pre-iter. 8) | `[x]` | `[x]` | `[x]` | 26 |
| `19615fd` (iter. 8 + 9) | **`[ ]`** | **`[ ]`** | **`[ ]`** | 32 = 26 − 3 + 9 |
| `dd6fb70` (flip masivo) | `[x]` | `[x]` | `[x]` | 122 |
| HEAD | `[x]` | `[x]` | `[x]` | 122 |

`dd6fb70` **volvió a flipear las tres**. O sea: un commit de preservación deshizo, sin citarlo, una
corrección que el director había ratificado dos commits antes. Las tres siguen sin sostener el
criterio hoy.

## 7. Qué entregué (código, no solo diagnóstico)

**`scripts/auditar_indice_m01.py` — modo nuevo `--stale`** (extendido, no duplicado; comparte la
lectura del índice, el mapeo `M## → carpeta {##+1}` y la lectura del GLOBAL):

- `leer_indice()` ahora captura la línea cruda y su **continuación**, porque en este archivo la cita
  del flip vive en la línea siguiente (formato real: `\n — FLIP iter.8 (...)`).
- `clase_stale()` / `clasificar_stale()`: clase por ítem + `cita` booleana **medida en todos los
  ítems** (no solo en los stale); agrega `por_clase`, `con_cita`, `sin_cita`.
- `informe_stale()`: tabla con `ID / LINEA / CARPETA / CHK x/?/[] / CITA / CLASE`.
- `--check --stale` → **exit 1** si queda algún flip sin cita (gate medible, hoy en rojo: 86).
- El bloque `stale` también viaja en `--json`.

**`scripts/test_auditar_indice_m01.py` — bloque P (17 checks nuevos), piso 62 → 79 MEDIDO.**

| Evidencia | Resultado |
|---|---|
| Suite completa | **79 checks / 0 fallos / EXIT 0 ×3** |
| Piso `CHECKS_MINIMOS` | **79**, medido en verde (no estimado) |
| Sonda S1 (clase_stale miente) | EXIT 1, **4 fallos** nombrando `P2`, `P3`, `P6`, `P7` |
| Sonda S2 (`RE_CITA` acepta todo) | EXIT 1, **3 fallos** nombrando `P9`, `P12`, `P13` |
| Sonda S3 (piso a 99) | EXIT 1: «solo 79 checks ejecutados (minimo 99)» |
| Repo tras las sondas | **intacto** (sha256 de los 2 archivos sin cambio) |

Las 3 sondas trabajan sobre una **copia en directorio temporal**: no mutan el repo (evita la trampa
de restauración por lock de Windows). Los checks cubren las dos direcciones: un `[x]` cerrado con
fila `✅` **no** cae en stale (control negativo P5), y cada clase se contamina a sí misma si el
clasificador miente (P6/P7).

**Regresión de los modos previos del auditor:** `(sin flags)` EXIT 0 · `--check` EXIT 0 ·
`--pendientes` EXIT 0 · `--dependencias` EXIT 0 · `--stale` EXIT 0 · `--json` EXIT 0.

## 8. Lo que NO hice

- **0 flips aplicados** y **0 degradaciones**: los 86 `[x]` quedan como están. Revertir 86 marcas es
  una decisión del director, no del auditor.
- **No toqué `05-Checklist.md`** (ni el del índice ni el de ningún módulo).
- **No toqué** `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`.
- **0 commits / 0 push.**

## 9. Pedidos al director

1. **Decisión de semántica** (bloquea todo lo demás): ¿el `[x]` del índice significa «módulo cerrado
   + fila OK» (criterio de la iter. 8, el que ratificaste) o «módulo identificado en el plan»
   (nota del 2026-10-12, línea 2)? Hoy conviven las dos y por eso 86 marcas no se pueden juzgar.
2. **Si gana el criterio de la iter. 8:** GO para revertir los **24 `modulo_abierto`** (los que
   tienen `[ ]` real) y para tratar los 38 `cerrada_sin_fila_ok` como deuda de FILA (tu palanca).
3. **GO de commit** de esta tanda (pathspec exacto):
   - `scripts/auditar_indice_m01.py`
   - `scripts/test_auditar_indice_m01.py`
   - `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/12-Auditoria-Flips-Index-M01.md`
4. **Corregir la línea `**Totales:**`** del índice (dice 29/123; real 122/30). No la toqué por ser
   línea de totales de un archivo de módulo. **La afirmación «3 reverts» de esa línea es correcta**:
   las 3 reversiones se aplicaron en `19615fd`; lo que las deshizo fue `dd6fb70` (§6).
5. **Reposición de la COLA ACTIVA con conteo medido.** Siete ítems de la cola tienen la premisa
   vencida. Medido hoy por prefijo, **por carpeta** (el `M##` del backlog mezcla las dos
   numeraciones del proyecto — la del índice maestro y la de carpeta, desplazadas +1):

   | Ítem de la cola | Dice | Medido hoy |
   |---|---|---|
   | 10 · M62-Memoria | «37 `[ ]`» | `62-Memoria` **147 `[x]` / 0 `[ ]` / 3 `[?]`** |
   | 18 · M112-Testing | «14 pendientes» | `112-Testing-Automatico` **232 / 0 / 0** |
   | 19 · M117-Build | «18 pendientes» | `117-Build-System` **109 / 0 / 1** |
   | 20 · M118-CI/CD | «1 pendiente» | `118-CI-CD` **113 / 0 / 0** |
   | 21 · M123-Modding | «2 pendientes» | `123-Modding` **108 / 0 / 0** |
   | 31 · M102-Bug-Tracking | — | `102-Bug-Tracking` **142 / 0 / 0** |
   | 33 · M107-Backups | «9 pendientes» | `107-Backups` **182 / 0 / 0** |

## 10. Trampas registradas en esta vuelta

1. **Un `[x]` masivo en un commit de preservación no es un flip auditado.** 90 marcas entraron en
   `dd6fb70` sin cita; **86 de las 90 no se sostienen**. Un commit de «preservación de jornada» mezcla
   trabajo de varios agentes y **ninguno** responde por las marcas que movió. Peor: puede deshacer una
   corrección ya ratificada (re-flipeó las 3 que la iter. 8 había revertido).
2. **Elegir mal el commit base invierte la conclusión.** Contra `2e12dc1` (pre-iter. 8) el diff daba
   96 flips y 3 «preexistentes», y de ahí concluí que las 3 reversiones de la iter. 8 «no ocurrieron».
   Contra `19615fd` (post-iter. 8) son 90 flips y 0 preexistentes, y las reversiones **sí** existen.
   La base correcta es el último commit donde el cambio anterior está aplicado; el diff se mide
   contra **ese**, no contra el primero que tenga el archivo.
3. **La cita del flip puede vivir en la línea siguiente**, no en la del ítem. Un auditor que solo
   mire la línea del ítem reporta 0 citas cuando hay 9.
4. **Sondas de inyección sobre copia temporal**: evita la restauración por `sha256` con reintentos
   que exige el lock de Windows, y deja la prueba de «repo intacto» como check explícito.
5. **El informe legible del auditor imprime `CHK` como `x/?/[]` sin rotular la columna.** Un lector
   (o un script auxiliar con otro orden) transpone `[ ]` y `[?]` y concluye la clase equivocada: me
   pasó en esta vuelta con M40 y M62 y lo delató medir la carpeta por separado. El informe nuevo
   `--stale` rotula la columna `CHK x/?/[]` a propósito; **toda cifra de este documento está
   re-medida por carpeta**, no copiada de una tabla.
6. **El `M##` del BACKLOG no es el `M##` del índice maestro**: el índice está desplazado +1 respecto
   de la carpeta (`M40` → `41-Musica`). Citar «M40» sin decir qué numeración se usa hace que dos
   agentes midan carpetas distintas y ambos crean tener razón.

## 11. Re-baseline aplicado (2026-10-29 — Log 2249, orden de la directora msg 457)

**Qué cambió:** el índice maestro pasó de **122/30/0** a **73/79/0** (`[x]`/`[ ]`/`[?]`, medido por
prefijo de línea). Se degradaron **49** marcas, no 86: la clasificación de §4 se re-midió fresca hoy y
las clases se movieron (24 `modulo_abierto` · 25 `solo_interrogantes` · 36 `cerrada_sin_fila_ok` =
**85**, no 86 — el módulo M59 cambió entre el 28 y el 29).

| Clase | N | Se degradó | Por qué |
|---|---|---|---|
| `modulo_abierto` | 24 | **sí** | la checklist propia todavía tiene `[ ]`: el `[x]` afirmaba cerrado un módulo con trabajo pendiente |
| `solo_interrogantes` | 25 | **sí** | sin `[ ]` pero con `[?]` abiertos; el criterio ratificado exige `[?]` = 0 |
| `cerrada_sin_fila_ok` | 36 | **no** | la checklist propia está 100 % cerrada; lo único que falta es que la fila del GLOBAL pase a `✅`, palanca de la directora |

**Las 49 líneas degradadas** (marca `[x]` → `[ ]`, con nota inline `re-baseline 29oct` que cita clase y
conteo de la checklist propia):

- `modulo_abierto` (24): L41 M12, L45 M16, L52 M19, L73 M32, L75 M34, L77 M36, L80 M39, L84 M40,
  L88 M44, L93 M49, L94 M50, L100 M53, L102 M55, L103 M56, L104 M57, L108 M58, L109 M59, L110 M60,
  L112 M62, L116 M66, L117 M67, L144 M84, L218 M139, L232 M150.
- `solo_interrogantes` (25): L26 M01, L27 M02, L37 M08, L40 M11, L43 M14, L44 M15, L59 M25, L63 M26,
  L74 M33, L92 M48, L95 M51, L126 M73, L150 M87, L157 M93, L159 M95, L170 M102, L175 M107, L176 M108,
  L194 M121, L196 M123, L199 M126, L201 M128, L203 M130, L215 M136, L226 M144.

**Las 36 que NO se tocaron** (decisión pendiente de la directora): M09, M13, M17, M20, M23, M31, M35,
M65, M70, M75, M77, M79, M80, M81, M82, M88, M90, M91, M92, M94, M103, M104, M105, M111, M112, M114,
M118, M122, M125, M127, M140, M142, M143, M145, M148, M152. **Si se aplica la lectura estricta** del
criterio (fila `✅` obligatoria), el conteo honesto sería **37/115/0** — queda medido y visible, no aplicado.

**Línea de totales corregida.** El archivo tenía **dos** líneas de totales (26/126 y 29/123), ambas stale;
quedaron marcadas `SUPERADA` y se agregó el total vigente al pie: `152 ítems · Completados: 73 ·
Pendientes: 79 · No resueltos: 0`. El muestreador ahora lee `delta_total=+0 delta_x=+0` sobre el índice
(antes `delta_x=-93`).

**Verificación:** `scripts/auditar_indice_m01.py --stale` → 36 stale, todas `cerrada_sin_fila_ok`, 0 en
las otras dos clases. `--check` EXIT 0. Sin BOM, CRLF preservado (309/309), `git diff --stat` ==
`--ignore-cr-at-eol` (75/51, sin churn).

### 11.1 Defecto del muestreador que este módulo destapó

`muestreo_p100.py` devolvía **`VEREDICTO: OK` con la muestra vacía**. El índice M01 no tiene un solo ítem
con verbo de creación ni con artefacto citado (son enunciados de plan: «definir nombre, pilares, pitch»),
así que `filas` quedaba en 0, `fallas=0` y el resumen decía OK **sin haber mirado nada** — un falso verde
por muestra vacía, justo el que el propio docstring decía cubrir con el código de salida 3.

- **Corte nuevo:** `if not filas: veredicto = "CIEGO"` + `main()` devuelve **3** si algún módulo sale CIEGO.
- **Suite:** bloque `test_ceguera_muestra_vacia` (fixture `77-Ciego`: 2 `[x]` de diseño puro) + control
  negativo (un módulo con muestra no puede salir CIEGO). Piso `CHECKS_MINIMOS` 60 → **71** (medido).
- **Sonda EN ROJO:** se eliminó la rama `if not filas` en una copia → **2 fallos** nombrando los checks y
  `RESULTADO: FAIL`. Restaurado; verde ×2 después.

### 11.2 Trampa nueva: contar `[?]` con grep da 0 SIEMPRE

`grep -cE "^\s*- \[$m\]"` con `m='?'` devuelve **0** en cualquier archivo: en ERE el `?` cuantifica el `\[`
que tiene delante, así que el patrón busca «cero o una `[` seguida de `]`» y nunca matchea `- [?]`. Medido
hoy: dio `[?]=0` para M11, M67 y M74 cuando los reales son **7, 15 y 58** (coinciden con la tabla de la
directora). Se detectó porque el muestreador en Python (`[ x?]` dentro de una clase de caracteres) daba
otra cifra. **Regla:** contar marcas con `[?]` entre corchetes (`\[[?]\]`) o, mejor, con el muestreador.
