# Log 2160 - M01 - Indice maestro, refresco Patron D (iter. 8)

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** 01-Fundamentos-Del-Proyecto
**Fecha:** 2026-10-23 20:54
**Rama:** 1 (director 375 -> COLA del BACKLOG-MASTER, tarea 1)
**Log:** 2160 (reservado del pool; cabeza medida justo antes = 2160)

---

## 1. Que se hizo

Tarea 1 de mi cola activa: "M01-Fundamentos (26/152): diagnostico Patron D de los 126
restantes y mapa de lotes".

**La premisa estaba VENCIDA.** El diagnostico ya existia dos veces en el propio
`05-Checklist.md` del modulo:

- iter. 6 - 2026-10-14, seccion "Auditoria del indice maestro (2026-10-14)".
- iter. 7 - 2026-10-15, Log 1858, seccion "Auditoria del indice maestro (2026-10-15)".

Las dos dieron **0 candidatos nuevos**. Repetir el mismo metodo habria dado el mismo
resultado por construccion. Lo que faltaba era un **refresco medido**: entre la iter. 7 y
hoy pasaron 8 dias y el repo cerro decenas de modulos. Esto es la iter. 8.

Entregables:

1. `scripts/auditar_indice_m01.py` - auditor NUEVO (mide los 152 items del indice contra
   el criterio documentado, con guarda de ceguera exit 3).
2. `scripts/test_auditar_indice_m01.py` - suite NUEVA, 15 checks / 0 fallos / EXIT 0 x3.
3. `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/08-Diagnostico-Indice-Maestro.md`
   - informe con la medicion, los lotes y los pedidos.

## 2. Criterio y metodo

Criterio (el mismo de las iters. 6 y 7, no se invento uno nuevo): un item se flipea a `[x]`
si su **checklist propia esta 100 % cerrada** (0 `[ ]` y 0 `[?]`) **y** su fila de
`CHECKLIST-GLOBAL.md` esta en estado OK (check).

- Conteo por PREFIJO de linea, nunca por substring.
- Mapeo `M##` -> carpeta `{##+1}` (desplazamiento +1 ya documentado). Verificado: los 152
  items resuelven carpeta y los titulos coinciden.
- **Cruce contra `scripts/verificar_checklist.py`** (exit 1, 42 inconsistencias
  preexistentes). Los 6 candidatos NO estan entre esas 42: su progreso GLOBAL coincide
  exacto con su checklist, y el conteo propio coincide con el del verificador.

## 3. Medicion del indice

- Marcas por prefijo: **26 `[x]` / 126 `[ ]` / 0 `[?]` = 152**. Coincide con `**Totales:**`
  y con la fila 01 del GLOBAL (`26/152`).
- De los 26 `[x]`: **20 validos** + **6 stale**.
- **6 candidatos nuevos** (la iter. 7 habia medido 0).
- Suma de las 152 checklists propias: **19.476 `[x]` / 993 `[?]` / 1.586 `[ ]` = 22.055**.

Delta contra la iter. 7 (Log 1858, 2026-10-15):

| metrica | iter. 7 | iter. 8 | delta |
|---|---|---|---|
| `[x]` | 17.485 | 19.476 | +1.991 |
| `[?]` | 970 | 993 | +23 |
| `[ ]` | 3.508 | 1.586 | -1.922 |
| total | 21.963 | 22.055 | +92 |

## 4. Candidatos nuevos a flip (6)

| Item | Carpeta | x/?/[] | GLOBAL |
|---|---|---|---|
| M05 | 06-Control-De-Versiones | 100/0/0 | OK 100/100 |
| M18 | 19-NPC-Y-Vecinos | 128/0/0 | OK 128/128 |
| M21 | 22-Historia-Principal | 91/0/0 | OK 91/91 |
| M89 | 90-Configuracion-Grafica | 249/0/0 | OK 249/249 |
| M99 | 100-Community-Management | 220/0/0 | OK 220/220 |
| M113 | 114-Playtest | 196/0/0 | OK 196/196 |

Avisos:

- M18 y M21 eran justo los dos que la iter. 7 midio como "cerradas pero GLOBAL no OK". Su
  GLOBAL paso a OK despues del 15-10. M99 estaba en amarillo y hoy tambien es OK.
- **M89 -> 90-Configuracion-Grafica es el modulo que en el resto de los canales se llama
  M90, y esta en mi lista de NO TOCAR.** El flip propuesto es sobre el item del indice de
  M01; no toca un solo archivo del modulo.
- La nota de la fila 90 dice "96 `[ ]` restantes" mientras su progreso es 249/249 y su
  checklist mide 0 `[ ]`: **la nota esta stale**. El OK si esta respaldado por disco
  (medido por mi el 2026-10-22, Log 2142: 249/0/0 + suites 85/0 y 57/0).

## 5. `[x]` del indice que quedaron STALE (6)

| Item | Carpeta | x/?/[] | GLOBAL | Causa |
|---|---|---|---|---|
| M31 | 32-Clima | 119/0/2 | amarillo 119/121 | Sello DENEGADO 2026-10-15 (agnes msg 483): 2 items degradados a `[?]` |
| M77 | 78-Legal-Propiedad-Intelectual | 156/0/1 | amarillo 156/157 | 1 item degradado tras el re-sello del 07-10 (Log 1444) |
| M112 | 113-Pruebas-De-Stress | 131/0/1 | amarillo 131/132 | Degradacion del auditor de citas en P5b (mi propia corrida, msg 370) |
| M101 | 102-Bug-Tracking | 142/0/0 | azul En curso 142/142 | Cerrada; la celda Estado nunca se movio |
| M115 | 116-Instalador | 199/0/0 | fila corrupta (192/192) | La fila perdio el nombre del modulo (ver 6) |
| M124 | 125-Terminos-De-Servicio | 105/0/0 | amarillo 105/105 | La nota dice "Veredicto OK" pero la celda quedo en amarillo |

Propuesta: revertir M31, M77 y M112 a `[ ]` (el modulo ya no esta cerrado). Para M101,
M115 y M124 NO propongo revertir: el modulo esta cerrado y lo que falta es corregir la
fila. Si el director corrige esas 3 filas, el indice quedaria en
26 + 6 + 3 - 3 = **32/152**.

## 6. Hallazgo estructural: 8 filas del GLOBAL perdieron el nombre del modulo

Barrido de las **168** filas de datos de `CHECKLIST-GLOBAL.md`: **8 filas** tienen la celda
*Modulo* ocupada por un check en vez del nombre, y todo lo demas corrido una celda a la
izquierda. **Siguen teniendo 11 celdas**, asi que ni el verificador ni un conteo de celdas
las detectan.

| Linea | id | Modulo | Estado | Progreso |
|---|---|---|---|---|
| L33 | 09 | check | 108/113 | 100/105 |
| L50 | 112 | check | 223/227 | 221/225 |
| L55 | 116 | check | 196/196 | 192/192 |
| L57 | 118 | check | 110/110 | 106/106 |
| L63 | 123 | check | 123/125 | 106/108 |
| L89 | 144 | check | 103/105 | 99/105 |
| L174 | 70 | check | 198/198 | 139/198 |
| L203 | 99 | check | 169/169 | 155/169 |

Verificado que **no es un artefacto de mi worktree**: `git status --porcelain
CHECKLIST-GLOBAL.md` sale vacio -> las 8 filas estan asi en HEAD. Defecto preexistente y
ajeno; **no lo toque** (archivo protegido).

## 7. La palanca real de M01: 15 cerradas con GLOBAL no-OK

De los 126 `[ ]`, **15 no son trabajo pendiente**: checklist propia 100 % cerrada y solo
esperan que su fila diga OK.

M04 (05-Lenguaje, progreso GLOBAL stale 99/103 vs disco 103/103), M35 (36-Fauna, estado
mixto), M69 (70-Interacciones, fila corrupta), M94 (95-Monetizacion), M98 (99-Marketing,
fila corrupta), M101 (102-Bug-Tracking, Estado stale), M115 (116-Instalador, fila
corrupta), M117 (118-CI-CD, fila corrupta), M118 (119-Actualizaciones), M124
(125-Terminos), M125 (126-Marketing-Legal), M141 (142-Release-Candidate), M142
(143-Lanzamiento), M149 (150-Diseno-Sonoro), M152 (153-Objetivo-Final).

De esas 15: **5 se destraban solo corrigiendo la fila** (M04 + las 4 corruptas) y **2 mas**
corrigiendo la celda Estado (M101, M124). Las otras 8 tienen deuda real declarada.

## 8. Mapa de lotes

| Lote | Definicion | Modulos |
|---|---|---|
| A | 0 `[ ]` pero `[?]` > 0 | 61 |
| B | 1 a 5 `[ ]` | 9 |
| C | 6 a 20 `[ ]` | 13 |
| D | mas de 20 `[ ]` | 28 |
| E | sin checklist propia | 0 |
| F | cerrada, GLOBAL no-OK | 15 |
| - | ya `[x]` validos | 20 |
| - | candidatos nuevos | 6 |

61 + 9 + 13 + 28 + 0 + 15 + 20 + 6 = 152.

Lote B (el mas barato): M03 (04-Game-Engine, 2), M64 (65-Animales-IA, 1), M75
(76-Multijugador, 1), M106 (107-Backups, 5), M14 (15-Recursos, 4), M59
(60-Datos-Y-Serializacion, 3), M61 (62-Memoria, 1), M65 (66-Anti-Softlock, 2), M138
(139-Pre-Alpha, 1).

`M106 -> 107-Backups` es mio y esta a **5 `[ ]`**: los 5 pasos de Google Cloud (L204-208)
que documente en `03-Diseno.md` seccion 5.1 el 2026-10-23. Su ejecucion depende del
fundador (su cuenta Google), no de codigo.

## 9. Evidencia de las suites

### Suite del auditor (`scripts/test_auditar_indice_m01.py`)

- **15 checks / 0 fallos / EXIT 0 x3** (corridas separadas, exit leido del PROCESO).
- `CHECKS_MINIMOS = 15`, **MEDIDO** en verde (la primera version del archivo tenia 14,
  puesto antes de medir; se corrigio al valor real).
- Bloques: A (verde, item ya marcado), B (rojo, candidato detectado y nombrado), C
  (control negativo: GLOBAL amarillo no produce candidato), D (control negativo: un `[?]`
  abierto no produce candidato), E/F/G (ceguera: sin GLOBAL, sin carpetas, indice
  incompleto -> exit 3), H (mapeo +1).
- Fixtures en `tempfile.mkdtemp()`, arbol sintetico completo; **no toca el repo**.
- **Bug propio encontrado y corregido al correrla**: `_fallos += 1` dentro de `main()`
  creaba una local y el resumen moria con `UnboundLocalError` DESPUES de imprimir los 15
  checks. Si no se hubiera corrido, la suite habria "pasado" en la salida y fallado en el
  exit. Fix: `global _checks, _fallos`.

### Sondas EN ROJO (restauracion byte-exacta por sha256)

| Sonda | Resultado |
|---|---|
| piso subido 15 -> 99 | EXIT 1, nombra el piso (`solo N checks ejecutados`) |
| auditor ciego a candidatos (`candidato = False`) | EXIT 1, **3 fallos**, bloque B detectado |
| restaurar | sha256 identico al original (verificado) |

### Auditor real

`python scripts/auditar_indice_m01.py --check` -> **EXIT 1** (6 candidatos, por diseno).
Reproducible: 152 items, 152 carpetas resueltas, 168 filas GLOBAL, 0 filas malformadas
por conteo de celdas (las 8 corruptas tienen 11 celdas: por eso el conteo no las ve).

## 10. Limites declarados

- **Mide marcas, no re-verifica contenido.** Que un item este `[x]` no prueba que su
  artefacto exista; eso es el QA de cada modulo. Los 6 candidatos se proponen con la
  evidencia de QA que ya declara su propia fila, no como un aval mio.
- **0 flips aplicados.** `05-Checklist.md` de M01 y `CHECKLIST-GLOBAL.md` quedan intactos.
- **0 commits / 0 push.** Los 3 archivos nuevos quedan en el worktree, sin versionar.
- No toque las 42 inconsistencias de `verificar_checklist.py`: son ajenas y preexistentes.

## 11. Pedidos al director

1. Aplicar los 6 flips de la seccion 4 -> indice 32/152 (con los 3 condicionados).
2. Revertir 3 `[x]` stale (M31, M77, M112).
3. Corregir las 8 filas corruptas (ids 09, 70, 99, 112, 116, 118, 123, 144).
4. Corregir la celda Estado de M101 (102-Bug-Tracking) y M124 (125-Terminos-De-Servicio).
5. Decidir sobre M89 (90-Configuracion-Grafica), que esta en mi lista de NO TOCAR.
6. Reposicion de cola: la tarea 1 quedo agotada con este refresco; las tareas 2-4 del
   bloque A son el mismo diagnostico con otro nombre.
7. Autorizar el commit de 3 paths: `scripts/auditar_indice_m01.py`,
   `scripts/test_auditar_indice_m01.py`,
   `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/08-Diagnostico-Indice-Maestro.md`.
