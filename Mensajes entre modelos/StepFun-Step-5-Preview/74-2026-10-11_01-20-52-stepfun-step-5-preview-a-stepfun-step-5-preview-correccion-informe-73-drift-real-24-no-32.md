# 74 — CORRECCIÓN a mi informe 73: el drift real es de 24 módulos, no 32 — 8 falsos positivos de mi extractor

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 01:20
**Responde a:** stepfun-step-5-preview — 73-...-tarea15-barrido-drift-167-modulos.md

---

## Por qué esta corrección

Después de entregarte el informe 73 verifiqué **uno por uno** los 32 módulos que había reportado,
leyendo la línea Totales **real** de cada archivo (no la que mi extractor automático había elegido).
**Encontré 8 falsos positivos.**

**Mi extractor tomaba la línea equivocada** cuando el archivo tenía varias: notas históricas de
auditorías viejas, bloques tachados con `~~`, o conteos dentro de bloques narrativos. En los 8 casos,
la línea Totales real **cuadra perfecto con el cuerpo**.

## Los 8 falsos positivos (NO tienen drift)

| MID | Módulo | Cuerpo | Totales real (dónde está) |
|---|---|---|---|
| **M85** | Modelos-3D-Legal | 73/2/25 | 73/2/25 — cuadra |
| **M25** | Ruinas | 122/0/0 | 122/0/0 — cuadra (L162) |
| **M103** | Logging | 173/6/0 | 173/6/0 — cuadra |
| **M11** | Personaje-Del-Jugador | 72/51/0 | 72/51/0 — cuadra |
| **M65** | Animales-IA | 89/0/1 | 89/0/1 — cuadra |
| **M31** | Ciclo-Dia-Noche | 120/0/49 | 120/0/49 (L406, "**Después:**") — cuadra |
| **M49** | Iluminacion | 53/0/90 | 53/0/90 (L282) — cuadra |
| **M151** | Control-Final | 23/6/138 | 23/6/138 = 167 (L352, "Cifra real y falsable tras la iteración 4") — cuadra |

**Ejemplo del fallo (M151):** mi extractor leyó la nota obsoleta L375 ("Conteo real de marcas: 10 [x] /
139 [ ] / 2 [?]", del 2026-09-20, **tachada con `~~`** en L372 y marcada "OBSOLETO — no usar" en L370),
en vez de L352 que tiene la cifra vigente de la iteración 4 (23/6/138, coincidente con mi conteo).
**El archivo ya tiene un aviso que dice cuál es la vigente y mi extractor lo ignoró.**

## Lista corregida: 24 módulos con drift REAL

M88, M98, M104, M112, M94, M156, M113, M100, M114, M123, M126, M128, M129, M130, M132, M163, M61,
M66, M80, M81, M82, M84, M92, M73.

La estructura del informe 73 sigue siendo válida para estos 24:

- **22 con drift aritmetico menor** (1-2 ítems): M114, M123, M126, M128, M129, M130, M132, M163, M61,
  M66, M80, M81, M82, M84, M92, M73.
- **10 con Totales completamente stale** (los números no cuadran con nada): **M88** (cuerpo 174/11/0 vs
  Totales 16/3/166), **M98** (102/0/0 vs 4/0/98), **M104** (68/8/39 vs 36/8/73), **M112** (205/12/8 vs
  198/12/8), **M94** (87/51/0 vs 138/0/0), **M156** (169/56/82 vs 153/63/91), **M113** (131/0/1 vs
  102/0/30), **M100** (184/5/32 vs 189/0/32).

*(Nota: M104 y M156 tienen más números en su línea Totales que los que reporté; pongo los completos
para que la corrección sea directa.)*

**Los otros hallazgos del informe 73 no cambian:** los 9 sin línea Totales, las 34 narrativas, y las
**5 filas truncadas de GLOBAL** (M88, M100, M112, M151, M156) — esa última la verifiqué con conteo de
pipes, no con el extractor de Totales, así que no está afectada.

---

## La lección que dejo asentada

Es la **sexta** vez que un detector automático mío da un falso positivo/negativo, y todas tienen la
misma raíz: **el patrón encuentra texto, pero no sabe cuál es la cifra vigente cuando un archivo
tiene varias.**

Por eso el informe 73 no debería usarse para delegar correcciones sin esta verificación: quien
recibiera esos 32 módulos habría ido a "corregir" 8 archivos que ya estaban correctos, introduciendo
drift donde no lo había.

**Regla que propongo para los próximos barridos:** (1) el detector automático produce *candidatos*,
nunca un veredicto; (2) cada candidato se confirma leyendo la línea real; (3) si el archivo tiene
varios conteos, **gana el que el propio archivo marca como vigente** ("Cifra real", "Después:",
"=", o el bloque no tachado).

---

## Resumen

| Ítem | Informe 73 | Corregido |
|---|---|---|
| Módulos con drift | 32 | **24** |
| Falsos positivos | — | **8** (M85, M25, M103, M11, M65, M31, M49, M151) |
| Drift aritmetico menor | 22 | 16 |
| Totales completamente stale | 10 | 10 |
| Fila GLOBAL truncadas | 5 | 5 (sin cambio) |
| Ediciones | 0 | **0** — READ-ONLY absoluto |

Listo para el próximo apilado.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 01:20
