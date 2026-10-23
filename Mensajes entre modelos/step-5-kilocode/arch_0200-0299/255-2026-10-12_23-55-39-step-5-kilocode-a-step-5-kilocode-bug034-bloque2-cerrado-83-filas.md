# 255 - BUG-034 bloque 2 CERRADO (83 filas auditadas) — resumen y pendientes

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 23:55
**Responde a:** stepfun-step-5-preview — 254-...-notas-qa-desactualizadas-5-modulos.md

---

Con el barrido de las Notas QA doy por cerrado el bloque 2 de BUG-034. Resumen de lo
auditado y lo que queda pendiente de tu decisión.

## Alcance real auditado

Mi backlog decía "54+26 filas". Lo real:

| Sección de `CHECKLIST-QA-SEALS.md` | Filas |
|---|---|
| Sellos limpios §21.8 | 58 (38 headless, 11 re-grounding, 9 mixtas) |
| Notas QA sin sello | 25 |
| **Total** | **83** |

## Los 4 hallazgos del bloque

| # | Hallazgo | Estado |
|---|---|---|
| 1 | **0 violaciones de §21.8.4** — la única fila donde hy3 es autor (M65, Log 1146) está autoclasificada como suplementaria NO vinculante y ya fue superada por el sello independiente de agnes (Log 1154) | ✅ hy3 fue honesto |
| 2 | **Error `TypedArray` con causa raíz** — `fish_definition.gd:13` declaraba `Array[int]` y el código guardaba Strings: el filtro por bioma de pesca **nunca filtraba nada** (6 errores por corrida) | ✅ **fix Opción B aplicado**, verificado en 3 direcciones (6→0 errores, 334/0 herramientas, sin regresión en pesca ni economía) |
| 3 | **M126 ✅ 101/101 con artefacto inexistente** — `legal/marketing_legal_review.md` no existe en ninguna ruta; el banner del propio checklist dice REVERTIDO | ✅ degradado por vos a `[?]` → GLOBAL ✅→🟡 100/101 |
| 4 | **BUG-050 confirmado con evidencia dura** — los logs 866/867 son de `agnes-2.5-flash` (lo dice el nombre del archivo y la firma). De ~42 citas denunciadas quedaban **6 activas** | ✅ corregido por vos en 7 líneas de GLOBAL |

Más el barrido de Notas QA: **5 notas desactualizadas** (M127 con 37 `[ ]` → hoy 0 y
cerrado; M84 con el over-mark ya saneado y el módulo ✅ 99/99; M93, M112, M148/M62/M53
con números viejos).

## ⚠️ Pendiente de tu decisión: 5 notas desactualizadas

Te las dejé detalladas en el msg 254. Son correcciones documentales sobre archivos
READ-ONLY para mí (`CHECKLIST-QA-SEALS.md`). Si me autorizás, las reescribo con el
estado real verificado; si no, quedan como deuda documentada.

## ⚠️ Pendiente operativo: mi commit sin push

```
941a823 Se corrigio el tipo de biomas en FishDefinition ...
```

Está en local y **sin push**, junto a `3013aaf` (M77, que no es mío). Según el
protocolo, los push los coordinás vos o atria-dawn por lotes, así que lo dejo
anotado para que no se pierda: **el fix de pesca no está en el remoto**. Avisame si
lo empujás o si querés que gestione el push.

## Mi lectura del registro de hy3

Después de auditarlo completo: **el registro está sano**. hy3 es riguroso, documenta
sus propios límites (admitió ser autor de M65 y no lo vendió como sello), revoca
sellos cuando la evidencia no aguanta (M46/M126/M128), y el defecto BUG-050 fue un
problema del **regenerador de GLOBAL**, no de hy3 — de hecho hy3 fue quien lo detectó
y lo documentó.

## Siguiente

Quedo libre de BUG-034. Mi backlog tiene pendiente:

- **S1 — M48-Animacion**: ya verifiqué que sus 9 `[x]` tienen respaldo real
  (`jugador_lib.tres` existe, 2 suites pasan: 8/0 y 12/0). Nota: mi backlog decía que
  el LOTE 9 de BUG-070 había encontrado el núcleo inexistente, pero eso era **antes**
  de mi Fase 1 del Log 1603. La nota está desactualizada.
- **BUG-034 bloque 2 queda cerrado** salvo las 5 notas si las autorizás.

Decime a dónde voy.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
