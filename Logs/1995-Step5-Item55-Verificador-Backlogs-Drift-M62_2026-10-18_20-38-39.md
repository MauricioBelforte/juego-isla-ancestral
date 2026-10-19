# Log 1995 - Step-5-WorkBuddy - Item 55: corrida de verificar_backlogs.py + barrido de canal (renumeracion)

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy (Step-5)
**Fecha:** 2026-10-18 20:38 (GMT-3)
**Log:** 1995 (reservado del pool; cabeza medida justo antes = 1995)
**Vuelta:** canal Step-5-WorkBuddy - RAMA 1 (sin mensajes nuevos) + RAMA 2 (item 55)
**Tarea:** BACKLOG-MASTER seccion A, Bloque C, item 55 = "Corrida scripts/verificar_backlogs.py + reporte"

---

## 1. Barrido de canal (RAMA 1) - sin mensajes nuevos del director

- Tracker encontrado: `.ultima-revision-step-5.txt` = **75** (mtime 2026-10-18 19:47).
- Snapshot RECURSIVO de la carpeta: **79 archivos** = 76 mensajes `.md` + `NUMEROS_DISPONIBLES.txt` +
  `.ultima-revision-step-5.txt` + `LEEME-ESTRUCTURA.txt`. Sin subcarpetas.
- Mensajes del director (`*glm-5.3-flash-director*a-step-5-workbuddy*`): ultimo = **074**
  (`074-2026-10-18_06-15-00-...veredicto-barrido-70.md`), ya procesado en la vuelta 19:22
  (era el "094" antes de la renumeracion). **No hay NN > tracker: RAMA 1 sin encargos nuevos.**

### Renumeracion del canal (evidencia medida hoy)

- Commits del director: `e1b3dc2` (19:48, "Fix final: el informe-078 asignado al numero 076")
  + `d145fcb` (19:58, nota de transparencia) + `461e8e6` (19:59) + `93a7b46`/`33f1951`/`f14efa9`
  (20:04-20:10, los 3 puntos obligatorios del fundador + PASO 7).
- Metodo: `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/COMO-CORREGIR-NUMERACION-MENSAJES.md`
  (152 lineas, leido hoy).
- Estado medido del canal tras la correccion: **76 mensajes consecutivos 001-076, sin huecos ni
  duplicados** (verificado con comm sobre `printf '%03d'`; el primer intento de medicion dio
  falso "01-76 huecos" por usar `seq -w` con ancho 2 en vez de 3 - corregido antes de publicar).
- Pool del canal: **100 numeros consecutivos 077-176**, LF puro, sin BOM (regenerado segun PASO 4).
- Titulos internos alineados con el prefijo (verificados 075 y 076).
- Mapa old->new de mis ultimos artefactos (por timestamp del nombre): 71->065, 72->067, 73->069,
  74->070, 75->071, 76->072, 77->073, 78->075, informe-078->076. Director: 094->074, 070->068,
  068->066.
- Puntero: el director dejo el tracker en **75** (max al momento de renumerar); el fix `e1b3dc2`
  asigno despues el 076. **Max real del canal = 076.** Ajustado a 076 segun PASO 5
  ("el puntero = max") y PASO 7 (el agente declara su riel procesado: mensajes del director
  procesados hasta el 074 = viejo 094; mis 075/076 leidos esta vuelta).
- El informe POST-correccion del director (PUNTO 1) aun no llego a mi carpeta: se receiptara
  cuando aparezca con NN > 076.

## 2. Corrida de `scripts/verificar_backlogs.py` (RAMA 2, item 55)

Script leido completo antes de correrlo (regla del repo: `--help` no es seguro). Es READ-ONLY
por diseno; corre `python` del sistema (3.13.14).

```
python scripts/verificar_backlogs.py        -> EXIT 1
python scripts/verificar_backlogs.py --json -> EXIT 1 (con traceback: ver seccion 5)
```

Salida completa capturada en `.workbuddy-ai/tmp/vb_run_2026-10-18.txt` (151 lineas) y
`.workbuddy-ai/tmp/vb_run_2026-10-18.json`.

- **Modelos con backlog: 27/29** (sin BACKLOG-MASTER: De-Director-V4.1 y GLM-5.3-Flash-Director).
- **Cierres afirmados con delta: 304** (clasificados en seccion 4: casi todos ruido del parser).
- **DRIFT INVERSO (trabajo ya hecho): 5** - todos de DeepSeek-V4.1-Flash, modulo M62.
- **Modulos inexistentes citados: 0.**
- EXIT 1 = "mire y encontre" (exit 3 seria DETECTOR CIEGO; no es el caso: leyo 27 backlogs).

### 3. Los 5 DRIFT INVERSO (material, verificados en disco)

Backlog `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`, items `[ ]`
cuyo texto YA esta `[x]` en `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`:

| Backlog DS | Item [ ] | Checklist M62 (medido hoy) |
|---|---|---|
| L811 | RN1: presupuesto de RAM objetivo <= 2.5 GB en PCs de gama media (preset Alta) | **L110 [x]** iter. 7 (2026-10-17, Tanda 6) |
| L812 | RN1: preset Baja <= 1.5 GB para gama baja con 4 GB de RAM | **L111 [x]** iter. 7 |
| L814 | RN2: cero hitching perceptible por refcount en liberaciones masivas | **L113 [x]** iter. 7 |
| L862 | Test Play Mode: teleport extremo x10 con memoria estable y sin picos | **L214 [x]** iter. 7 |
| L866 | Test Play Mode: textura gigante forzada degrada sin crash | **L218 [x]** iter. 7 |

- Conteo real M62 medido por prefijo de linea: **118 [x]** (cuadra con el 118/32/0 del script).
- Riesgo: el agente podria REPETIR trabajo ya cerrado (su propia Tanda 6 del 2026-10-17).
- Dueno: DeepSeek-V4.1-Flash. NO tocado (backlog ajeno). Reportado al director.
- Dato de contexto: hay un `test_m62_texturas_region.gd` sin seguimiento en el working tree
  (git status) - M62 sigue activo en la flota.

### 4. Los 304 "cierres afirmados con delta" - ruido del parser, no drift

El script asocia cada patron "N/M" de una linea `[x]` al modulo citado mas cerca (regla BUG-121,
ventana de 30 chars). La gran mayoria son **falsos positivos** verificados uno por uno en los
casos con delta grande:

- **Familia "colisiones AJENAS"**: lineas de reserva de log del tipo "Cabeza medida justo antes:
  1504 (colisiones AJENAS 1290/1468/1547...)". El lookbehind `(?<![Ll]og )` no cubre "colisiones
  AJENAS", asi que **1290 se lee como conteo de [x] del modulo de la linea**. Son los
  "+1159/+1161/+1215" de DeepSeek L1357 (M87), L1426 (M105), L1433 (M11) - el MISMO 1290
  imputado a 3 modulos distintos por proximidad.
- **step-5-kilocode L62**: "afirma 1821/1823 vs real 227/99" - su linea R13 cita "230 [?]
  auditados" y detalles por modulo; el 1821/1823 sale de laEvidencia en texto, no de un conteo
  de checklist. step-5-kilocode esta dado de baja (7 filas stale del GLOBAL).
- **Mis 5 "RETROCESO" de step-5-workbuddy - TODOS falsos, fuente leida en disco**:
  - L308 M109 "afirma 127": la linea dice "107 [x] / 28 [ ] / 3 [?] = 138" (iteracion 5,
    Log 1847); el 127 sale de la regla de proximidad, no de un 127 real. M109 real hoy =
    120/15/3 (mi modulo, medido en item 65).
  - L325 M6 "afirma 131": linea del acuse del msg 40 (mimo) sobre M06/M93; el numero es de
    otra celda de la linea. M06 esta CERRADO (100/100, flip del director).
  - L353/L361 M94 "afirma 120/124": conteos de modulos VECINOS en lineas multi-modulo
    (M109 120/138, M31 125/169, M76 126/130, M140 100/124...). M94 real = 83/0/55.
  - L406 M55 "afirma 126": "fila GLOBAL 76 APLICADA por el (126/130...)" - el 126/130 es de
    M76, imputado a M55 por la ventana de 30 chars. M55 real = 63/15/53.
- Mi backlog: **drift inverso 0, modulos inexistentes 0** (mis 12 `[ ]` son de la seccion B
  historica + los 2 stale M76 del Bloque W; los items de la cola A van como lista numerada sin
  checkbox, fuera del alcance del parser).
- Los "avance posterior" (delta negativo) son legitimos: el modulo avanzo despues de la foto
  del backlog. No son hallazgo.

## 5. BUG del script encontrado (ajeno, NO tocado) - `--json` rompe el exit code

`scripts/verificar_backlogs.py` L571-573:

```python
    if total_drift or total_inex:
        return 1
    return 0
```

`total_drift`/`total_inex`/`total_cierres` solo se definen en la rama ELSE (modo texto, L562-568).
En modo `--json` el flujo sale por el `if args.json:` (L550) y **nunca las define** ->
`UnboundLocalError: cannot access local variable 'total_drift'` -> traceback + exit 1 de Python.

Consecuencia medida hoy: `--json` **salta con traceback y exit 1 SIEMPRE** (tambien cuando no
hay alertas: el exit code no distingue limpio de sucio). El JSON en si se imprime COMPLETO
antes del crash (parseable con `raw_decode`). El modo texto funciona bien (exit 1 = encontro).
No esta en `quality.yml` ni en `.github/` (grep = 0): el bug afecta a agentes/personas, no al CI.

Patch propuesto (3 lineas, sin cambio de semantica; NO aplicado - el script es herramiental
compartida de la flota y el item 55 pide "corrida + reporte"):

```python
    total_drift = total_inex = total_cierres = 0
    if args.json:
        print(json.dumps(...))
    else:
        ...
        total_drift = sum(...)
```

## 6. Limites de la vuelta

0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a CHECKLIST-GLOBAL.md,
quality.yml, AGENTS.md, project.godot, backlogs ajenos / 0 flips / 0 auto-sellos 21.8.
El script es read-only: no modifico ningun backlog (su propia salida lo confirma).
Artefactos: este Log 1995 (ASCII puro por bytes, CRLF, sin BOM), mensaje de canal **077**
(UTF-8 sin BOM, LF) - numero consumido del pool (cabeza 077 -> ahora 078), BACKLOG-MASTER
item 55 -> `[x]` con evidencia + registro de vuelta, tracker -> 076, diario y memoria.

**Firma:** Step-5-WorkBuddy / WorkBuddy - 2026-10-18 20:38.
