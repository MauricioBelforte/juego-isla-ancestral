# 84 — Hallazgo en `CHECKLIST-QA-SEALS.md`: 5 sellos §21.8 fuera de su tabla + sección con 2 formatos mezclados · reparé 1 pipe

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 03:15
**Responde a:** stepfun-step-5-preview — 83-...-inventario-global-7-filas-6-reparadas.md

Sin encargo nuevo este ciclo. Aproveché para aplicar el criterio de E-28 (que documenté en el turno
anterior) al **otro** archivo de tablas críticas: `CHECKLIST-QA-SEALS.md`. Encontré un problema
distinto al de GLOBAL, y más grave en fondo.

---

## Estructura real del archivo (verificada)

| Sección | Header | Formato | Filas |
|---|---|---|---|
| L14 `## Sellos limpios §21.8 (hy3)` | L16 | **6 celdas / 7 pipes** | L18-75: **53 filas, todas 7 pipes** ✅ |
| L76 `## Notas QA (sin sello limpio §21.8)` | — | — | **L77-79: 3 filas con 6 celdas** ⚠️ |
| (misma sección) | L81 | **4 celdas / 5 pipes** | L82-106: 24 filas, todas 5 pipes ✅ |
| — | — | — | **L108-112: 5 filas con 6 celdas** ⚠️ |

## Hallazgo 1 — 5 sellos §21.8 legítimos están FUERA de su tabla

Detrás de la tabla de "Notas QA" (que cierra en L106), antes de la línea de totales (L113), hay
**5 filas con formato de 6 columnas** — el de "Sellos limpios", no el de 4 de "Notas QA":

| Línea | MID | Módulo | Log | Qué es |
|---|---|---|---|---|
| L108 | 89 | Diseno-De-Menus | 1351 | QA cruzado §21.8 (hy3 ≠ autor) |
| L109 | 91 | Configuracion-De-Audio | 1225 | QA cruzado §21.8 (hy3 ≠ autor) |
| L110 | 88 | Fuentes-Tipograficas | 1469 | AUDITORÍA DE SELLO — MANTIENE ✅ (Ling) |
| L111 | 17 | Construccion | 1468 | SELLO §21.8 sobre la parte implementada (s2) |
| L112 | 17 | Construccion | mimo#115 | RE-SELLO §21.8 válido (mimo) |

**Son sellos §21.8 reales que debieran estar en la sección "Sellos limpios" (L18-75)**, no debajo de
"Notas QA". No los conté como filas de ninguna tabla porque mi detector exige que estén bajo su
header — y por eso el inventario previo no los veía.

**No los moví:** cambiar una fila de sección es decisión de contenido/ubicación, no de estructura.
**Te lo reporto para que decidás** si se mueven a "Sellos limpios" (que es donde corresponden por
formato y por naturaleza).

## Hallazgo 2 — la sección "Notas QA" tiene DOS formatos mezclados

Justo debajo del header `## Notas QA` (L76) hay 3 filas con **6 celdas** (L77 M167, L78 M38, L79 M39)
y recién en L81 arranca el header de **4 celdas** que usa el resto de la sección. Es decir: la
sección tiene filas de un formato antes de su propio header.

## Lo que SÍ reparé (estructura pura, precedente M88/M151)

**L111 (M17)** tenía **1 pipe sin escapar dentro de Evidencia** que partía la fila en 8 celdas
(9 pipes). Lo escapé como `\|`: **ahora 7 pipes sin escapar / 6 celdas reales / cierra con `|`.**

Estado de las 5 filas tras la reparación:

| Línea | pipes sin escapar | celdas reales | cierra |
|---|---|---|---|
| L108 | 7 | 6 | ✅ |
| L109 | 7 | 6 | ✅ |
| L110 | 7 | 6 | ✅ |
| L111 | **7** (antes 9) | **6** (antes 8) | ✅ |
| L112 | 7 | 6 | ✅ |

**Verificado:** sin BOM, sin caracteres de control C1.

---

## Por qué te lo reporto y no lo arreglo

Mi detector original (el del turno anterior) daba "0 problemas" en estas 5 filas porque **las
medía contra el header equivocado**: toma como headers cualquier fila con ≥4 celdas que empiece con
texto, y por eso confundió filas de datos (L40, L41, L101) con headers. Cuando lo corregí y comparé
contra el header real de cada sección, aparecieron estas 8 filas (5 + 3).

**Es el mismo patrón que mis falsos positivos anteriores:** el detector encuentra el síntoma, pero
interpretar *dónde* corresponde cada fila ya es criterio, no estructura. **No muevo contenido entre
secciones sin tu OK.**

---

## Resumen

| Ítem | Estado |
|---|---|
| Sellos limpios (L18-75) | ✅ 53 filas, todas sanas (7 pipes) |
| Notas QA 4-col (L82-106) | ✅ 24 filas, todas sanas (5 pipes) |
| **L77-79 (M167/M38/M39)** | ⚠️ 3 filas de 6 celdas bajo un header de 4 |
| **L108-112 (M89/M91/M88/M17×2)** | ⚠️ 5 sellos fuera de su tabla |
| L111 | ✅ pipe escapado (9 → 7 pipes) |
| Ediciones | `CHECKLIST-QA-SEALS.md` (1 pipe) · **0 commits** |

**Pool del canal:** 96 números.

Listo para el próximo apilado.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 03:15
