# Log 1604 - M107 Backups - verificacion del flip WakeToRun (L110) + re-corrida de la suite

**Modelo:** DeepSeek-V4.1-Flash
**Fecha:** 2026-10-10 17:20 (GMT-3)
**Encargo:** mensaje 145 del director (atria-dawn / Kilo Code, 2026-10-10 16:31). OJO: el archivo
viene MAL NOMBRADO como `deepseek-a-deepseek` (no matchea el patron `atria-a-deepseek`); su
cabecera lo firma atria-dawn / Kilo Code y "Responde a" mi 144 -> ES del director (misma trampa
del msg 143, corrida 40).
**Independencia 21.8:** M107 lo trabajo Hy3 (esta en QA); yo soy el verificador. OK.
**Restricciones:** READ-ONLY sobre M107 (no edite checklist, diseno, codigo ni suite). Sin commit/push.

## Encargo (msg 145)

1. Verificar que el item L110 del checklist de M107 describe la desviacion del director sobre
   WakeToRun correctamente (que no diga "pendiente" ni "mal").
2. Si hay otro item que afirme que WakeToRun esta activado, reportarlo (NO editar).
3. Re-correr la suite de M107 (`test_backup_m107.gd`) para confirmar que el fix de BUG-131 sigue limpio.

## Tarea 1 - L110 describe la desviacion CORRECTAMENTE (CONFORME)

Texto medido del item (`DOCUMENTACION/107-Backups/plan-actual/05-Checklist.md` L110):

    - [x] Configurar condicion: despertar equipo [S] - register_task.ps1 "WakeToRun desactivado"
      - **DEVIACION DOCUMENTADA por el director (2026-10-10):** el diseno 7 L246 pide WakeToRun
      activado, pero se mantiene **desactivado adrede** - el target es un notebook y despertarlo a
      las 03:00 sin atencion es comportamiento sorpresivo. No es bug, es decision operativa
      (reportada por atria-dawn-s2, msg 199).

- Estado: [x]. Dice "desactivado adrede" y "No es bug, es decision operativa".
- NO dice "pendiente" ni "mal". Cumple el criterio del director.
- Coincide con el CODIGO real: `scripts/backup/register_task.ps1` NO pasa `-WakeToRun` a
  `New-ScheduledTaskSettingsSet` (L69-70) -> en PS 5.1 la omision deja WakeToRun=false. El header
  del script (L18) dice literalmente "WakeToRun desactivado (no despertar el equipo)".
- Nota de precision: el msg 145 menciona `-AllowStartIfOnBatteries`, que es OTRA condicion (L109
  "alimentacion de CA", BUG-131). El script (L11-14) documenta que NO la pasa -> StartIfOnBatteries
  queda en false, como exige el diseno 7. L109 y L110 son correctos por separado.

## Tarea 2 - Ningun otro item afirma WakeToRun activado (NADA QUE REPORTAR)

- `grep -niE "waketorun|allowstart"` sobre TODO `DOCUMENTACION/107-Backups/`: 1 sola ocurrencia (L110).
- No hay otro item del checklist que afirme WakeToRun activado -> no hay nada que marcar.
- OBSERVACION (no es item de checklist; solo reporte): `03-Diseno.md` seccion 7, linea 246 del
  archivo, dice "Despertar el equipo para ejecutar esta tarea" -> el DISENO pide activarlo. Es el
  origen de la desviacion que L110 documenta; no es un item a corregir. Si el director quiere
  consistencia total, la anotacion iria en el diseno, no en el checklist.

## Tarea 3 - Suite de M107: 28/0 EXIT 0 x3, 0 SCRIPT ERROR

Suite: `game/isla-ancestral/scripts/backup/test_backup_m107.gd` (mimo-v2.5, 2026-09-19).
Godot 4.7.2 headless, worktree actual.

| Pasada | Checks | Fallos | SCRIPT ERROR | EXIT |
|---|---|---|---|---|
| 1 | 28 | 0 | 0 | 0 |
| 2 | 28 | 0 | 0 | 0 |
| 3 | 28 | 0 | 0 | 0 |

Salida literal: `=== Resumen M107: 28 checks, 0 fallos ===` / `TEST M107 OK`.

### HALLAZGO IMPORTANTE: la suite NO cubre BUG-131

`grep -nE "register_task|\.ps1|AllowStart|Wake"` sobre la suite = **0 coincidencias**. La suite
valida el BackupManager GDScript (crear/verificar/restaurar/retencion/categorias/compresion/
manifest), NO el registro de la tarea programada. El fix de BUG-131 vive en `register_task.ps1`
(PowerShell), que NINGUNA suite headless ejercita. Por lo tanto: "re-correr la suite" NO confirma
nada sobre BUG-131; el verde 28/0 es correcto pero NO es evidencia del fix.

Verificacion ESTATICA del fix (por lectura, es lo unico posible): `register_task.ps1` L11-14
documenta que NO pasa `-AllowStartIfOnBatteries` (la omision deja StartIfOnBatteries=false, como
exige 03-Diseno 7) y L69-70 no pasa `-WakeToRun`. Ambas condiciones coinciden con el diseno y con
la desviacion documentada.

### HALLAZGO SECUNDARIO: la suite no tiene piso CHECKS_MINIMOS

`grep` de `CHECKS_MINIMOS|_fin(|BLOQUES` en la suite = **0**. Es una suite de mimo-v2.5 con
`_check()` que cuenta pero SIN piso ni marcadores de bloque: un aborto silencioso por SCRIPT ERROR
en un helper daria "0 fallos" con menos checks (familia trampa 122). Hoy el conteo es estable
(28 x3) y no hay SCRIPT ERROR, pero la suite es vulnerable al falso verde. REPORTADO, NO tocado
(M107 es de Hy3).

## Conteo medido del checklist M107 (snapshot)

- 151 [x] / 0 [ ] / 25 [?] = 176 (conteo por PREFIJO de linea; CRLF puro 351, sin BOM, 0 NUL, 0 FFFD).
- La linea `**Totales:**` (L243) dice "176 items - Completados: 146 - Pendientes: 12 - No resueltos: 18"
  -> DRIFT: ese detalle (146/12/18) NO coincide con el conteo real (151/0/25). La fila 84 del
  CHECKLIST-GLOBAL ya dice 151/176 (alineada con el conteo real, no con la linea Totales). REPORTADO,
  NO tocado.
- M107 esta ACTIVO ahora mismo (Ling/Hy3 en sub-bloque C, Haiku por su canal; msg 211 de agnes):
  el conteo es un snapshot, no un estado congelado.

## Restricciones respetadas

- READ-ONLY: 0 ediciones en `05-Checklist.md`, `03-Diseno.md`, `register_task.ps1` o la suite.
- No toque `CHECKLIST-GLOBAL.md` ni `quality.yml`.
- Sin commit / sin push (la automatizacion no commitea sin autorizacion explicita).
- Colisiones de pool AJENAS (1290/1468/1547/1559/1585) reportadas, NO tocadas. No tome el 1290.
- Worktree ajeno intacto (trampa 87).

## Pendiente (director)

- Decidir si la suite de M107 debe (a) cablearse a `quality.yml` y (b) ganar piso CHECKS_MINIMOS.
- Decidir si se anota la desviacion WakeToRun en `03-Diseno.md` seccion 7 L246 (hoy solo en el checklist).
- Reconciliar el drift del `**Totales:**` de L243 (146/12/18 -> 151/0/25).
- M155 (investigacion de los 3 fallos de `test_equipment_m155.gd`) queda pendiente de asignacion.
