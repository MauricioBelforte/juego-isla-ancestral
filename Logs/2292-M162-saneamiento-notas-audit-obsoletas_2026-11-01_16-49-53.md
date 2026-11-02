# Log 2292 - M162 - Saneamiento de las 40 notas AUDIT 2026-10-14 (solo nota, sin re-medir)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-11-01 16:49:53
**Modulo:** M162 - Dialogos Contextuales de NPCs
**Orden:** agnes-3-flash, canal 492, pedido 1: 'M162 40 notas AUDIT obsoletas: GO.
  Corregir en 1 vuelta (solo nota, no re-medir). Es checklist tuyo (D-01 lo auditaste).'
**Rama:** 1 (mensaje del director NN 492 > tracker 490)

## 1. Que se hizo

Se anotaron las 40 notas `AUDIT 2026-10-14 (step-5-kilocode)` del
`DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/05-Checklist.md`.
NO se re-midio ningun item y NO se toco ninguna marca.

| Marca aplicada | Cantidad | Criterio |
|---|---|---|
| `[OBSOLETO 2026-11-01: superado por la nota posterior]` | 38 | el item ya tiene una nota
  posterior propia (REVERIFICADO/VERIFICADO 2026-10-15, FLIP 2026-10-26, DEGRADADO 2026-11-01) |
| `[PREMISA OBSOLETA 2026-11-01: data/m160/catalogo_ubicaciones.json EXISTE; item sin re-medir]` | 1 | item 101: su unica premisa ('M160 sin datos de ubicaciones en disco') es medible y hoy es falsa |
| sin marcar | 1 | item 47 (L84): su nota NO habla de datos en disco sino de la ausencia de un test
  cruzado con M23; no fue re-medida, asi que marcarla seria afirmar algo no medido |

## 2. Por que las notas eran obsoletas (medido hoy)

La premisa central del bloque AUDIT 2026-10-14 es 'M158/M160 no tienen datos en disco'.
Medido el 2026-11-01:

```
game/isla-ancestral/data/m158/catalogo_herramientas.json   -> EXISTE
game/isla-ancestral/data/m160/catalogo_ubicaciones.json    -> EXISTE
data/dialogues/contextual/*.json                           -> 368 archivos
```

Las notas que dicen 'no existe data/m158' / 'no existe data/m160' / 'M160 no tiene datos
de X en disco' son por tanto falsas a la fecha. Esto ya se habia detectado en la vuelta
del canal 489: degradar un `[x]` apoyandose en esas notas habria producido 4 degradaciones
FALSAS en M162. Por eso el arreglo correcto es anotar la nota, no la marca.

## 3. Invariantes verificados (por bytes, no a ojo)

```
marcas ANTES   : x=114  ?=2  vacio=4  total=120
marcas DESPUES : x=114  ?=2  vacio=4  total=120   (identicas, lista comparada en el script)
bytes          : 34059 -> 37146
CRLF           : 284 -> 296   (LF sueltos = 0 antes y despues)
BOM            : False        FFFD = 0        CRCRLF = 0
diff numstat   : 51 insertadas / 39 eliminadas  (39 = 38 items anotados + 1 linea del bloque)
diff -U0       : 0 lineas eliminadas sin reemplazo -> cambio puramente aditivo en contenido
```

El script abortaba si: el ancla no aparecia exactamente 40 veces, si las marcas cambiaban,
si el EOL dejaba de ser CRLF uniforme, si aparecia BOM/FFFD, o si los conteos de
OBSOLETO/PREMISA/sin-marcar no daban 38/1/1. Ninguna guarda se disparo.

## 4. Efecto sobre el verificador del repo

`scripts/verificar_checklist.py` NO reporta inconsistencia para M162 (GLOBAL 114/120 =
checklist 114/120). Las 4 inconsistencias que imprime son de modulos AJENOS
(04-Game-Engine 126/128 vs 128/128, 10-Generacion-Del-Mundo 90/106 vs 88/106,
103-Logging 173/179 vs 177/179, 104-Analytics 111/119 vs 119/119). No se tocan.

## 5. Deuda que queda anotada, sin tocar

- La linea `## Total de items: 120 - [x] = 80 / [?] = 40 (iter 3 ...)` de la cabecera
  esta STALE: el conteo real es 114/4/2 desde hace varias vueltas. No la cambie porque
  no es una nota AUDIT y el pedido era acotado. Requiere orden aparte.
- Las 40 notas siguen ahi (con su texto original intacto): no se borro evidencia, se la
  etiqueto. Un lector que quiera el detalle historico lo tiene; uno que quiera el estado
  actual ve el marcador y la nota posterior.
- Numeracion de logs: `reservar_log.py --estado` reporta 12 problemas, TODOS de logs
  ajenos (colisiones 1698, 1726, 1876, 1878, 1888, 2120, etc.). No se renumeran.

## 6. Estado de M162 al cierre

```
M162 = 114 [x] / 4 [ ] / 2 [?] = 120   (sin cambios respecto de la vuelta anterior)
```

0 commits / 0 push / 0 auto-sellos. 1 path tocado (el 05-Checklist de M162).

