# Log 2003 - Step-5-WorkBuddy - Item 57: barrido de Totales inconsistentes (drift > 5)

- **Agente:** Step-5-WorkBuddy
- **Modulo:** GLOBAL (barrido multi-modulo)
- **Fecha:** 2026-10-18 23:03 (GMT-3)
- **Log nro:** 2003 (reservado del pool con `scripts/reservar_log.py --reservar`; cabeza medida justo antes = 2003, pool 2004 en adelante)
- **Mensaje al director:** 080

## Encargo

Item 57 de la COLA ACTIVA (Bloque C, mi nicho): "Barrido de Totales
inconsistentes (drift > 5) en CHECKLIST-GLOBAL". Sin mensajes nuevos del
director (ultimo = 077, ya procesado; 078/079 propios), RAMA 2.

## Universo y criterio

- **Universo:** los 167 `05-Checklist.md` de `DOCUMENTACION/*/plan-actual/`.
  Los 168 de `plan-inicial/` se midieron APARTE y se EXCLUYEN del veredicto:
  son la foto inicial del modulo (todos `[ ]` por diseno), no deuda viva.
- **Conteo real:** por PREFIJO DE LINEA `^- \[[x? ]]` (mismo criterio
  estricto que `scripts/verificar_checklist.py`). Control alternativo en los
  3 hallazgos (con sangria y bruto): identico.
- **Declarado:** parseado de la linea que EMPIEZA con "Totales", por
  etiquetas (Completados/Pendientes/No resueltos), o por desglose
  `` N `[x]` | N `[ ]` | N `[?]` `` (primera aparicion por marca), o por
  fraccionario X/N solo en los primeros 80 caracteres.
- **Drift:** maximo absoluto por componente (completados vs `[x]`,
  pendientes vs `[ ]`, no-resueltos vs `[?]`); umbral > 5.

## Resultado (plan-actual, 167 archivos)

- ILEGIBLES: 0 (167/167 UTF-8 estricto valido).
- NO-PARSE: 2
  - M116-Instalador: linea narrativa sin cifras parseables ("Totales vs
    GLOBAL; muestreo 21.8.2.b..."). Real: 192 [x] / 0 [?] / 0 [ ].
  - M151-Control-Final: SIN linea Totales. Real: 94 [x] / 6 [?] / 67 [ ].
- DRIFT marca-vs-real (> 5): **3**
  - **M71-Progresion - drift 96.** Declarado: 72 [x] / 141 [?]
    (reconciliacion 2026-09-18, hy3/WorkBuddy). Real: **168 [x] / 45 [?] /
    0 [ ]**. La cabecera quedo congelada en la foto vieja mientras el
    modulo avanzo; el total declarado (213) sigue cuadrando con el real
    (213), el drift es todo de composicion.
  - **M32-Clima - drift 23.** Declarado: 96 [x] / 25 [?] (auditoria iter.
    2, GLM-5.3/Kilo Code, 2026-09-12). Real: **119 [x] / 2 [?] / 0 [ ]**.
  - **M30-Reloj-En-Tiempo-Real - drift 12.** Declarado: 107 [x] / 13 [?]
    (reconciliacion 2026-09-18, hy3/WorkBuddy). Real: **119 [x] / 1 [?] /
    0 [ ]**.
- DRIFT total-declarado vs suma real: **0** (todas las cabeceras cuadran
  el total de items).
- **Ninguno de los 3 es mio.** Mis modulos verificados: M31 cuadra exacto
  (125/169, cabecera escrita por mi el 2026-10-15/16); los otros 5 modulos
  propios no entraron en el barrido con drift.

## Contraste con la deuda del director

El director anota "16 `Totales` incoherentes sin dueno". Con el criterio de
este barrido (marca-vs-real, drift > 5, solo plan-actual) el numero de hoy
es **3**. O la lista del director usa otro criterio (p.ej. incluir
plan-inicial, donde el mismo barrido da 36 drift + 132 no-parse, todo ruido
de foto inicial), o parte de esos 16 ya se corrigio durante el dia. Queda
pedida la aclaracion / la lista origen en el mensaje 080.

## Trampa propia (documentada para el skill)

Mi parser v1/v2 tuvo dos falsos positivos, ambos MEDIDOS y corregidos:
1. La linea de Totales puede citar un test ("test_cielo_estrellas_m31.gd
   39/0/EXIT 0 x3") y un regex de fraccionario X/N suelto tomaba ese 39
   como "completados" -> drift fantasma de 86 en M31 (real: 0).
2. Exigir exactamente 3 pares `` N `[x]` `` hacia que una linea con un par
   extra cayera al fraccionario y perdiera el desglose bueno.
Regla que sale: el fraccionario solo se acepta si la linea no tiene
backticks-marks y solo en la cabecera (primeros 80 caracteres); el desglose
se toma por PRIMERA aparicion de cada marca, sin exigir 3 exactos.

## Limites

0 commits / 0 push / 0 archivos de modulo modificados / 0 ediciones a
CHECKLIST-GLOBAL.md (NO TOCAR: solo se leyo), quality.yml, AGENTS.md ni
project.godot. M71/M32/M30 quedan como estan: reportados al director, la
correccion es de sus duenos.
