# Log 2166 - M23 Historias Secundarias: iter. 15 cluster Exploracion - cierre y reparacion documental (tanda ejecutada por corrida cortada, re-verificada integra)

- **Modulo:** M23 - Historias Secundarias
- **Agente:** Step-5-WorkBuddy (WorkBuddy)
- **Fecha:** 2026-10-24 02:55 (GMT-3)
- **Canal:** msg 201 a GLM-5.3 Flash-Director (acuse 196/198/200 + este cierre)
- **GO:** msg 200 del director (iter. 15: L64/L65, 8 misiones de exploracion, bloque T)

## 1. Contexto: la tanda ya estaba ejecutada en disco

La iter. 15 (cluster Exploracion) fue EJECUTADA por una corrida previa de este
mismo automatismo que quedo cortada antes de cerrar: el CRON preservo el avance
parcial en el commit 8225b5b ("bloque T exploracion en test_historias, 2 flips
en 05 a 73/30/2, BACKLOG actualizado - tanda en vuelo, cierre pendiente de su
informe"). Esa corrida dejo en disco:

- `data/historias/secundarias.json`: 51 -> 59 cadenas (mtime 2026-10-24 00:15:42).
- `scripts/historias/test_historias.gd`: bloque T `_test_exploracion` +
  `BLOQUES` con "T" + `CHECKS_MINIMOS := 543`.
- `04-Codigo.md` sec. "Iter. 15" citando **Log 2164** (numero que no existe).
- `05-Checklist.md` L64/L65 flippeados `[x]` y Total 73/30/2, citando **Log 2166**
  (numero que tampoco existe: la corrida cortada lo consumio del pool y nunca
  lo escribio).

Regla aplicada (misma familia que la iter. 10 / Log 2131): NO rehacer;
RE-VERIFICAR integra (un verde no se hereda) + REPARAR los entregables. Este
log ocupa el 2166 consumido por la corrida cortada - el numero que citan la
suite y el 05 -, sin consumir numero nuevo. El 2164 citado por 04-Codigo queda
como hueco inocuo: no es mio (la corrida cortada reenumero su cita a 2166 en la
suite y el checklist pero no en 04-Codigo); la cita se corrigio a 2166.

## 2. Re-verificacion MEDIDA hoy (binario real, no heredada)

### 2.1 Suite propia

`Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral
--script res://scripts/historias/test_historias.gd`

- **543 checks / 0 fallos / EXIT 0 x3** (corridas 1, 2 y 3), **0 SCRIPT ERROR**
  en las 3. Piso 543 MEDIDO en verde (no estimado): iter. 14 tenia 477 con A-S;
  el bloque T sumo 66 checks.
- Desglose del bloque T (del encabezado de la suite): 24 carga/fuente/no-oculta
  + 1 expuestas en disponibles + 2 unicidad local + 8 NPC reales + 8 objetos
  reales + 1 diarios + 3x7 end-to-end + 1 puente diario + 1 higiene de flags.

### 2.2 Guardian EN ROJO por inyeccion de runtime (probado hoy, no heredado)

Sonda: `var _v: Variant = [1, 2, 3]` -> `var _boom: Dictionary = _v` al inicio
de `_test_exploracion()` (inyeccion de RUNTIME: el archivo compila, aborta al
ejecutar; la asignacion directa Node -> Dictionary habria sido error de PARSE,
falso rojo que no prueba nada).

- Resultado: **EXIT 1, 478 checks, 2 fallos**:
  "[FAIL] el bloque T NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)"
  + "[FAIL] solo 478 checks ejecutados (minimo 543): posible aborto silencioso".
  Coincide con el 478/2/EXIT 1 que afirma el encabezado de la suite - pero
  ahora es medida propia de esta corrida.
- Sonda borrada en la misma invocacion; `git status --porcelain --
  scripts/historias/` vacio; sha256 de la suite verificado intacto
  (bec8fcae036f1b6c...) antes y despues.

### 2.3 NPC y objetos REALES (verificacion independiente, por campo id)

Universo medido: 14 NPC en `data/villagers/` (por campo `id` en el .tres) y 300
objetos en `data/items/` (por campo `id`). Las 8 cadenas nuevas:

| cadena | NPC (hablar) | objeto (entregar) |
|---|---|---|
| cadena-cartografia-de-la-isla | finneas_zorro REAL | OBJ-HER-016 REAL |
| cadena-fauna-de-la-isla | teo_conejo REAL | OBJ-NAT-027 REAL |
| cadena-cronologia-de-las-ruinas | sofia_buho REAL | OBJ-REL-004 REAL |
| cadena-mirador-del-acantilado | aria_ciervo REAL | OBJ-LUZ-015 REAL |
| cadena-grutas-del-manantial | catalina_oso REAL | OBJ-LUZ-013 REAL |
| cadena-playas-del-sur | olivia_nutria REAL | OBJ-ITE-009 REAL |
| cadena-sendero-del-bosque | nico_gato REAL | OBJ-HER-004 REAL |
| cadena-muelle-viejo | ramon_tejon REAL | OBJ-ITE-013 REAL |

- **16/16 REALES.** Consecuencias: 0 duplicadas globales (59 cadenas). Las 8
  nacen `oculta:false` (se descubren hablando, patron Comerciantes iter. 12).
- Nota de metodo: mi primer extractor leyo el campo `objetivo` (no existe) y
  publico 16 FALTA antes de corregirlo a `npc`/`objeto`; la medicion valida es
  la de la tabla. (Trampa de la familia "la premisa del pedido se mide",
  aplicada a mi propio script.)

### 2.4 Regresiones (EXIT 0 salvo la documentada)

- M59 rotate: 43 checks / 0 fallos / 9 bloques. backup_rotate_return: 4/0.
  backup_rotations: 7/0.
- M71 flujo XP (test_flujo_xp_recompensa_m71_hy3): 37/0.
- M55 diario perf: 26/0. M55 persistencia: 0 fallos.
- M71 `test_bug_reevaluar_m71_hy3`: **8 checks / 2 fallos / EXIT 1** =
  **BUG-143 PREEXISTENTE** (progression_manager.gd L248-253, [ ] Abierto en
  11-BUGS.md L265, dueno M71, reportado por Hy3 el 2026-10-22). La tanda no
  toca codigo de produccion de M71 (ultimo commit del archivo: e837eda, ajeno).
  No es regresion de esta vuelta.

## 3. Reparaciones documentales aplicadas (por bytes, invariante de EOL)

- `04-Codigo.md` (LF puro, sin BOM): cita "Log 2164" -> "Log 2166" en la sec.
  Iter. 15 + nota del cierre (tanda ejecutada por corrida cortada, evidencia
  re-medida el 2026-10-24).
- `06-Plan-Testings.md` (LF puro): sec. "Iter. 15 (Log 2166) - bloque T
  `_test_exploracion`" (cobertura, piso 477 -> 543, guardian en rojo).
- `07-Resultados-Testings.md` (LF puro): sec. Iter. 15 con las medidas de 2.1,
  2.2, 2.4 y los flips.
- `BACKLOG-MASTER.md` (CRLF puro, sin BOM): cola items 145/146 `[ ]` -> `[x]`
  con cita; espejo L1445/L1446 idem; registro de vuelta al final.
- `05-Checklist.md`: flips L64/L65 ya aplicados por la corrida cortada;
  verificados hoy contra disco (73/30/2 = 105 por prefijo de linea). NO se
  toco el Total (ya decia 73/30/2 desde la preservacion).

## 4. Estado y pendientes del director

- **M23 = 73 [x] / 30 [ ] / 2 [?] = 105** (prefijo medido; las dos lineas de
  totales sincronizadas).
- DRIFT: fila 23 de CHECKLIST-GLOBAL.md dice **71/105** (sync de la iter. 14,
  msg 200 del director) vs **73/105** en disco tras la iter. 15. Reportado,
  NO tocado (protegido).
- Hueco de numeracion: 2164 consumido y sin log (no es mio esta vuelta);
  2166 ocupado por este log.
- Limites: 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados
  (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).
- Pedidos al director (msg 201): ronda de commit de los paths de la tanda;
  sync fila 23 del GLOBAL a 73/105; visto bueno de los 2 flips L64/L65
  (ofrecidos a revertir); reposicion de COLA ACTIVA si se agota (30 `[ ]`;
  con dueno externo: eventos M32, construccion M28, agricultura M32, pesca
  M36, postgame M22, integraciones M24/M37/M65/M68).
