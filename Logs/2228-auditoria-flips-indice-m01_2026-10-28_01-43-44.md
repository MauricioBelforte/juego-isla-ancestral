# Log 2228 - Auditoria de flips del indice maestro M01 (modo --stale)

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-28 01:43 (GMT-3)
**Modulo:** M01-Fundamentos-Del-Proyecto
**Tarea:** BACKLOG-MASTER (A) COLA ACTIVA item 3 - "M01 b2: continuar (docs del 05-Checklist con cita de archivo)"
**Entrada:** 436 de agnes-3-flash (acuse del 435, sin tarea ejecutable) - RAMA 1 drenada, RAMA 2 ejecutada.

---

## 1. Medicion (antes de escribir cualquier cifra)

Criterio ratificado en la iter. 8: `[x]` sostenido si y solo si la checklist propia del modulo esta
100 por ciento cerrada (`[ ]` = 0 y `[?]` = 0) Y la fila de CHECKLIST-GLOBAL esta en estado OK.
Conteo por PREFIJO de linea, nunca por substring.

Indice maestro hoy: 152 items = 122 `[x]` / 30 `[ ]` / 0 `[?]`.
- 36 `[x]` sostenidos.
- 86 `[x]` NO sostenidos.

La linea `**Totales:**` del propio archivo (linea 251) declara 29 completados / 123 pendientes:
STALE frente a los 122/30 reales.

## 2. Origen de los 86 (diff contra la base correcta 19615fd)

| Concepto | Valor |
|---|---|
| `[x]` en la base (iter. 8 + 9 aplicadas) | 32, todos sostenibles hoy |
| Flips `[ ] -> [x]` que mete dd6fb70 | 90 |
| Reversiones `[x] -> [ ]` | 0 |
| De los 90, sostenidos hoy | 4 (M64, M71, M74, M76) |
| De los 90, NO sostenidos | 86 |
| `[x]` al cierre | 122 |

4 + 86 = 90. Los 86 no sostenidos son exactamente los que entraron en ese commit. El salto esta en
dd6fb70 (2026-10-25 00:19:28, "preservacion de la jornada de coordinacion"), 105 lineas agregadas /
96 quitadas sobre el indice.

## 3. Clases

- modulo_abierto: 24 (la checklist del modulo todavia tiene `[ ]`).
- solo_interrogantes: 24 (0 `[ ]` pero con `[?]`).
- cerrada_sin_fila_ok: 38 (checklist cerrada, la fila del GLOBAL no esta OK).
- sin_checklist: 0.

Extremos de modulo_abierto, medidos por carpeta (x / `[ ]` / `[?]`):
41-Musica 60/50/0 - 20-Sistema-De-Amistad 102/48/0 - 17-Construccion 135/39/1 -
45-Arte-3D 157/12/2 - 59-Guardado 116/12/2.

## 4. Auditoria de cita

Lineas con anotacion FLIP: 0 en 2e12dc1, 9 en 19615fd, 9 en HEAD (M05, M18, M21, M89, M99, M113 de
la iter. 8 y M69, M98, M117 de la iter. 9). Los 9 se sostienen hoy y NINGUNO esta entre los 90 de
dd6fb70: los 90 flips del commit de preservacion tienen 0 citas.

## 5. Hallazgo grave: el flip masivo deshizo una correccion ratificada

La iter. 8 revirtio 3 marcas (M31 -> 32-Clima, M77 -> 78-Legal-PI, M112 -> 113-Pruebas-De-Stress).
Esas 3 reversiones SI se aplicaron: en 19615fd las tres estan en `[ ]`. Medido commit a commit:

| Commit | M31 | M77 | M112 | `[x]` |
|---|---|---|---|---|
| 2e12dc1 (pre-iter. 8) | [x] | [x] | [x] | 26 |
| 19615fd (iter. 8 + 9) | [ ] | [ ] | [ ] | 32 = 26 - 3 + 9 |
| dd6fb70 (flip masivo) | [x] | [x] | [x] | 122 |
| HEAD | [x] | [x] | [x] | 122 |

dd6fb70 volvio a flipear las tres: un commit de preservacion deshizo, sin citarlo, una correccion
que el director habia ratificado dos commits antes.

**Error propio corregido en la misma vuelta:** la primera medicion se hizo contra 2e12dc1 (anterior a
la iter. 8) y de ahi conclui que las 3 reversiones "no habian ocurrido". La base correcta es el
ultimo commit donde el cambio anterior esta aplicado. El diff contra la base equivocada no solo
cambia cifras: invierte la conclusion.

## 6. Entregado

- scripts/auditar_indice_m01.py: modo nuevo `--stale` (extendido, no duplicado). leer_indice()
  captura la linea cruda y su continuacion (la cita del flip vive en la linea siguiente en este
  archivo). clase_stale() / clasificar_stale() / informe_stale(). `--check --stale` sale 1 si queda
  algun flip sin cita. El bloque `stale` viaja tambien en `--json`.
- scripts/test_auditar_indice_m01.py: bloque P, 17 checks nuevos, piso 62 -> 79 MEDIDO.
- DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/12-Auditoria-Flips-Index-M01.md (UTF-8 sin
  BOM, LF, 0 U+FFFD).

## 7. Evidencia

| Prueba | Resultado |
|---|---|
| Suite completa x3 | 79 checks / 0 fallos / EXIT 0 |
| Piso CHECKS_MINIMOS | 79, medido en verde |
| Sonda S1 (clase_stale miente) | EXIT 1, 4 fallos nombrando P2, P3, P6, P7 |
| Sonda S2 (RE_CITA acepta todo) | EXIT 1, 3 fallos nombrando P9, P12, P13 |
| Sonda S3 (piso a 99) | EXIT 1: "solo 79 checks ejecutados (minimo 99)" |
| Repo tras las sondas | intacto (sha256 de los 2 archivos sin cambio) |
| Regresion modos del auditor | (sin flags) 0 - --check 0 - --pendientes 0 - --dependencias 0 - --stale 0 - --json 0 |

Las 3 sondas trabajan sobre una copia en directorio temporal: no mutan el repo.

## 8. Limites respetados

0 flips aplicados, 0 degradaciones, 0 commits, 0 push. No toque el 05-Checklist del indice ni el de
ningun modulo, ni CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md ni project.godot.

## 9. Pedidos al director

1. Decision de semantica: el `[x]` del indice significa "modulo cerrado + fila OK" (iter. 8) o
   "modulo identificado en el plan" (nota del 2026-10-12, linea 2)? Hoy conviven las dos.
2. Si gana el criterio de la iter. 8: GO para revertir los 24 modulo_abierto. Los 38
   cerrada_sin_fila_ok son deuda de FILA (palanca del director), no trabajo de codigo.
3. GO de commit de los 3 paths de esta tanda.
4. Corregir la linea de totales del indice (29/123 -> 122/30). La afirmacion "3 reverts" de esa linea
   es CORRECTA: las 3 reversiones se aplicaron en 19615fd; lo que las deshizo fue dd6fb70.
5. Reposicion de la COLA ACTIVA con conteo medido: 7 items con premisa vencida (62-Memoria
   147/0/3, 112-Testing-Automatico 232/0/0, 117-Build-System 109/0/1, 118-CI-CD 113/0/0,
   123-Modding 108/0/0, 102-Bug-Tracking 142/0/0, 107-Backups 182/0/0).
6. Sobre la mejora al probe que anotaste en el 436 (patron emit_signal dinamico): NO la aplique
   porque cambia el oraculo 54/20 que ya ratificaron Hy3 y vos. Queda propuesta y lista.

## 10. Trampas registradas

1. Un `[x]` masivo dentro de un commit de preservacion no es un flip auditado: 90 marcas entraron
   sin cita y 86 no se sostienen. Peor: puede deshacer una correccion ya ratificada.
2. Elegir mal el commit base invierte la conclusion. La base correcta es el ultimo commit donde el
   cambio anterior esta aplicado; el diff se mide contra ESE.
3. La cita del flip puede vivir en la linea SIGUIENTE al item: un auditor que solo mire la linea del
   item reporta 0 citas cuando hay 9.
4. El informe legible del auditor imprime CHK como x/?/[] SIN rotular la columna: un lector o un
   script auxiliar transpone `[ ]` y `[?]` y concluye la clase equivocada. Me paso con M40 y M62 y lo
   delato medir la carpeta por separado. El modo --stale rotula CHK x/?/[] a proposito.
5. El `M##` del BACKLOG no es el `M##` del indice maestro: el indice esta desplazado +1 respecto de
   la carpeta (M40 -> 41-Musica). Citar "M40" sin decir que numeracion se usa hace que dos agentes
   midan carpetas distintas y ambos crean tener razon.
6. Sondas de inyeccion sobre copia temporal: evita la restauracion por sha256 con reintentos que
   exige el lock de Windows y deja "repo intacto" como check explicito.
