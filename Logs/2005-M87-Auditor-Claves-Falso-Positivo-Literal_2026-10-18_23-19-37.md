# Log 2005 - M87 Localizacion - El auditor de claves inventaba una clave desde un literal de cadena (CI rojo)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-18 23:19 (GMT-3)
**Modulo:** M87-Localizacion
**Tarea:** RAMA 2 / COLA ACTIVA item 45 (M87-Localizacion) + diagnostico del CI rojo
**Rama:** RAMA 2 (0 mensajes nuevos del director; NN entrante maximo = 312, ya procesado)

## 1. Punto de partida medido

- Tracker `.ultima-revision-deepseek.txt` = 313. Barrido recursivo del canal (raiz + 0-99/ +
  100-199/): el NN mas alto del director es **312** (archivo `glm-53-flash-director-a-DeepSeek...`,
  patron sin el punto), ya respondido en la vuelta anterior (mensaje 313). **0 mensajes nuevos.**
- Pool del canal: cabeza 314, ultimo mensaje 313 -> `ultimo+1` = 314. Consistente.
- Pool de Logs: cabeza medida justo antes = **2005** (consumido por `reservar_log.py --reservar`).

## 2. El CI estaba ROJO por tres jobs (medido, no supuesto)

`gh run list`: el run de `2b421ce` ("Ciclo 03:55") dejo **Code Quality Checks = failure**. Resumen
del propio workflow:

```
godot-lint: success | formatting-check: success | test-suite: FAILURE
legal-tools: FAILURE | security-scan: success | encoding-guard: FAILURE
log-protocol: success | binary-guard: success | architecture-guard: success
checklist-orchestrator: success | release-gate: success
```

- **legal-tools**: 300 hallazgos nuevos (300 PNG de `assets/2d/items_m159/` sin metadata). Deuda
  ya declarada del lote M159; no es mia y no la toco.
- **encoding-guard**: 3 archivos con BOM **en HEAD** (`M161/plan-actual/04-Codigo.md`,
  `M161/plan-actual/README-FORMATO-IDS.md`, `M83/plan-actual/05-Checklist.md`). Medido con `od`:
  `HEAD` empieza `efbbbf` y el **worktree ya esta reparado** (`2a2a4d`, `232052`, `3e202a`).
  O sea: **el fix existe sin commitear**; el gate no puede pasar hasta que se commitee.
- **test-suite**: el job corre ~50 suites con `|| FAIL=1` y **no imprime QUE script fallo**
  (defecto de observabilidad del workflow, que es NO TOCAR). Aislado por busqueda en el log:
  `=== Resumen M87: 84 checks, 2 fallos ===` con dos lineas `FALLO: auditor real: ...`.

## 3. Causa raiz del rojo de test-suite (reproducida en local)

```
godot --headless --path game/isla-ancestral --script res://scripts/localization/test_validador_po_m87.gd
EXIT=1  ->  === Resumen M87: 84 checks, 2 fallos ===
FALLO: auditor real: 0 claves de PRODUCCION ausentes -> ["), "]
FALLO: auditor real: veredicto OK
```

El informe del auditor lo delataba:

```
USADAS EN CODIGO PERO AUSENTES DEL CATALOGO (1):
  . ),   [diag_ui_en.gd, test_diario_ui.gd]
```

**Mecanismo exacto.** El patron principal del auditor es la forma de la llamada seguida de una
comilla. En `scripts/ui/diag_ui_en.gd:299` y `scripts/ui/test_diario_ui.gd:294` hay una asercion que
comprueba que el fuente CONTIENE esa llamada, y la escribe como un literal de cadena:

```
_check(src.contains("_t("), "textos por claves i18n + metadato text_key (M87)")
```

Sobre ese texto el patron hace: encuentra la llamada, toma la comilla de cierre del literal como
comilla de apertura de la clave, y **captura `), `** hasta la comilla siguiente. Esa captura entra
como clave usada en PRODUCCION, el catalogo (243 claves) no la tiene, y el veredicto deja de ser OK.

- Los dos archivos son de otro dueno (M55/Diario UI) y su asercion es **legitima**: no se tocan.
- El defecto es del auditor: sus patrones no distinguen una llamada de la **forma** de una llamada
  dentro de un literal.

## 4. Fix aplicado (2 archivos, M87)

### 4.1 `scripts/localization/auditor_claves.gd`

1. Nueva constante `RE_CLAVE_VALIDA = "^[A-Za-z0-9_.|]+$"` con el caso medido documentado.
   Justificacion medida: las **243** claves de `locales/es.po` cumplen ese charset (0 caracteres
   fuera de `[A-Za-z0-9_.|]`), asi que descartar las capturas que no lo cumplen **no puede ocultar
   una clave ausente real**.
2. `_registrar()` pasa a ser el **unico punto de entrada** de toda clave capturada (los 6 patrones
   se unificaron ahi) y descarta lo que no tiene forma de clave. Antes recibia `usadas` y `origenes`;
   ahora recibe `inf`.
3. Lo descartado NO se tira: se acumula en `inf["descartadas"]` (deduplicado, ordenado en
   `_finalizar`) y el informe lo imprime como `CAPTURAS DESCARTADAS (no tienen forma de clave): N`.
   Una exclusion invisible es un agujero negro; esta es auditable.
4. `formatear_informe()` lee `descartadas` con `get(..., [])`: es un formateador **publico** y el
   propio suite le pasa un Dictionary armado a mano (sin esa clave). Sin el default, el suite caia
   con `SCRIPT ERROR: Invalid access to property or key 'descartadas'` -- lo vi en la 1a corrida y
   por eso el default esta.

### 4.2 `scripts/localization/test_validador_po_m87.gd`

3 checks de regresion en el bloque `auditor` (el fixture reproduce la forma exacta del fallo):

- `una llamada dentro de un literal NO inventa una clave` (no aparece `), ` en `usadas_sin_clave`)
- `la captura descartada queda registrada (auditable)` (aparece en `descartadas`)
- `el descarte NO oculta una clave ausente real (control)` (un `ZZ.FALTA.CLAVE` del mismo fixture
  SIGUE reportado como ausente)

`CHECKS_MINIMOS` **re-MEDIDO** 84 -> 87 (no estimado: la corrida verde da 87 exactos).

## 5. Evidencia medida

| Medicion | Antes | Despues |
|---|---|---|
| suite `test_validador_po_m87.gd` | 84 checks / **2 fallos** / EXIT 1 | **87 / 0 / EXIT 0** x3 corridas |
| `usadas_sin_clave` (informe real) | `["), "]` | `[]` |
| `RESULTADO:` del auditor | CLAVES SIN TRADUCCION | **OK** |
| `SCRIPT ERROR` en la salida | 0 | **0** (en las 3 corridas) |

- **Prueba EN ROJO del gate (no heredada)**: cree `scripts/localization/_probe_inyeccion_tmp.gd`
  con una clave realmente ausente y volvi a correr la suite:
  `FALLO: auditor real: 0 claves de PRODUCCION ausentes -> ["ZZ.INYECTADA.CLAVE"]`,
  `Resumen M87: 87 checks, 2 fallos`, **EXIT 1**, y el informe la atribuye al archivo de la sonda.
  Sonda borrada y verde re-medido (3 corridas). **El descarte no ciego al auditor.**
- **Primera sonda descartada (honestidad)**: la 1a inyeccion uso `tr("...")`, que **no** es uno de
  los patrones del auditor -> dio verde y no probaba nada. Se rehizo con la forma real. Una sonda
  que no puede fallar no es una sonda.
- **Regresion de las 5 suites hermanas de localizacion** (el auditor no tiene otro consumidor:
  `grep AuditorClaves` fuera de su archivo solo da el suite): `test_localization` 23/0,
  `iter2` 21/0, `iter3` 12/0, `iter4` 25/0, `iter6` 82/0 -- todas EXIT 0 y 0 SCRIPT ERROR.
- **Higiene de bytes** de los 2 archivos: `auditor_claves.gd` 12.811 B, `test_validador_po_m87.gd`
  21.197 B; BOM=False, CRLF=0, CR solo=0, NUL=0, U+FFFD=0, LF puro. Diff: +55/-8 y +15/-1.
- `--check-only` sobre el auditor: EXIT 0.

## 6. Hallazgo GRAVE no buscado: los dos registros compartidos fueron RE-CODIFICADOS hace minutos

Al correr los gates del repo aparecio esto, y **no es mio**:

```
CHECKLIST-GLOBAL.md                     : BOM=True  U+00C3=3200  CRLF=225   (HEAD: BOM=False, 1270, 0)
Mensajes entre modelos/ESTADO-PARALELO.md: BOM=True  U+00C3=4768  CRLF=?     (HEAD: BOM=False, 4768?)
```

Medido por bytes:

- **HEAD** ya trae **mojibake simple** en el titulo: despues de `# CHECKLIST-GLOBAL.md ` los bytes son
  `c3 a2 e2 82 ac e2 80 9d` (tres caracteres: a-con-circunflejo, simbolo del euro, comilla tipografica)
  donde deberia ir un guion largo (su UTF-8 correcto seria `e2 80 94`). 1.270 apariciones de U+00C3 en HEAD.
- **Worktree** trae **mojibake DOBLE**: `c3 83 c2 a2 c3 a2 e2 80 9a c2 ac ...` (los mismos tres
  caracteres, pero cada uno ya re-codificado otra vez) + **BOM** + **225 CRLF**. 3.200 apariciones.
- **mtime del worktree: 23:14:43** (GLOBAL) y **23:15:02** (ESTADO-PARALELO), o sea **3-4 minutos
  despues** del commit HEAD `136e75d` (23:11:39) y dentro de esta misma ventana de trabajo.
- **Conteo de filas IDENTICO a HEAD**: 182 filas en ambos (GLOBAL), 202 en ambos (ESTADO-PARALELO).
  No se agrego ni se perdio ninguna fila: es una **re-codificacion del mismo contenido**.
- **NO es reversible byte-exacto**: probe deshacer una ronda con `cp1252` y con `latin-1`; ambas
  fallan (el dano mezcla ambas tablas: hay bytes C1 sueltos, `0x9D`/`0x8D`). Por eso **no lo toco**:
  un `git checkout HEAD --` perderia cualquier edicion de celda en vuelo y el inverso limpio no existe.
- **Exoneracion medida**: `verificar_bom.py` solo escribe con `--fix` (linea 199, rama del fix) y
  `diagnosticar_mojibake.py` no tiene ninguna escritura. Los corri **sin** `--fix` y **despues** de
  las 23:15. El dano es de otra herramienta/agente (patron `Set-Content`/`Out-File` de PS 5.1:
  lee UTF-8 como ANSI y reescribe UTF-8; el mensaje 312 del director describe exactamente ese modo
  de falla).

**Pedido al director (no lo puedo hacer yo):** decidir entre (a) `git checkout HEAD --` de los dos
archivos (perdida declarada: ninguna fila, pero se pierde cualquier celda editada en vuelo) o
(b) pedir al dueno del proceso que los reescriba desde su copia. Mientras tanto el gate
`encoding-guard` y el de mojibake siguen rojos por estos dos archivos, no por el codigo.

## 7. Correccion de una afirmacion heredada: la COLA ACTIVA NO esta agotada

Las 3 vueltas anteriores reportaron "cola agotada, 0 items [ ]" y pidieron reposicion. Medido hoy:
de los **105** items numerados de la seccion (A), solo **3** llevan marca `[x]` (103, 104, 105).
Los otros **102 no llevan checkbox**, y "sin checkbox" no es "hecho": el formato de la cola es lista
numerada, no casillas. La conclusion "0 items [ ]" salio de un `grep` de `- [ ]`, que en esa seccion
no puede matchear nada. **El backlog no esta corto: nunca lo estuvo.** Esta vuelta trabajo el item
45 (M87) por esa via.

## 8. Limites respetados

0 commits / 0 push / 0 flips de marca / 0 auto-sellos 21.8. No se toco `CHECKLIST-GLOBAL.md`,
`quality.yml`, `AGENTS.md`, `project.godot` ni el `05-Checklist.md` de ningun modulo. No se tocaron
los archivos de M55/Diario UI (dueno ajeno) ni los dos registros compartidos del punto 6.

## 9. Pendiente / proxima

1. Director: autorizar el commit de los 2 archivos de M87 (`auditor_claves.gd`,
   `test_validador_po_m87.gd`) y de los 3 BOM ya reparados en el worktree (M161 x2, M83).
2. Director: decision sobre los dos registros compartidos re-codificados (punto 6).
3. Director: decidir si el flip del item 45 procede; yo no aplico marcas.
4. Proxima vuelta: si no hay NN > 313, siguiente item sin marcar de la cola por nicho (CI/QA).
