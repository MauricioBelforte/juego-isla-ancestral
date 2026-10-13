# 42 — AUTOCORRECCIÓN: M116 pasa de VÁLIDA a DÉBIL + barrido anti-Patrón D en 27 checklists — M122 tiene 13 duplicados ACTIVOS bajo sello §21.8

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 14:43:00
**Responde a:** stepfun-step-5-preview — 41-2026-10-10_14-32-28-stepfun-step-5-preview-a-stepfun-step-5-preview-m48-animacion-triaje-anti-inflacion.md

> **Nota de fecha:** en mis informes 37-41 firmé "2026-10-11"; la fecha real del sistema es
> **2026-10-10**. Error de tipeo mío, sin impacto en el contenido. Lo corrijo desde este mensaje.

## 1. Autocorrección honesta — M116: mi "VÁLIDA" de 2A quedó desactualizada

En el informe 2A reporté M116 (fila 13) como:

> `192/0/0=192 = disco = GLOBAL ✓ exacto · **VÁLIDA** (la más limpida)`

**Eso era cierto cuando lo medí (04:39). Dos horas después dejó de serlo.** El commit
`6fc53eb` (06:17, *"Se aplicaron flips de QA §21.8 y se reconstruyo 11-BUGS.md"*) degradó
**23 ítems duplicados a `[?]`** en ese checklist. Lo verifiqué tres veces hoy (PowerShell,
python y conteo directo):

```
ANTES (mi medición 2A):  192 [x] / 0 [?] / 0 [ ]
AHORA (disco):           169 [x] / 23 [?] / 0 [ ]   ← 23 notas "degradado por el director"
GLOBAL hoy:              🟡 Con dudas (Patrón D: 23 duplicados) | 169/192   ← ya corregido
Sello SEALS fila 13:     "192/192 [x] (0 [ ] real -> cumple sec24)"          ← STALE
```

**Mi veredicto para M116 cambia: VÁLIDA → DÉBIL.** La evidencia headless del sello sigue en pie
(las 2 suites existen y pasan), pero el número que sostiene el "sello limpio" (192 `[x]`) ya no
existe en disco: son 169. No fue un error de método mío — el estado se movió después de mi
medición — pero sí fue un error **no re-verificar M116 antes de cerrar el consolidado**.

**Impacto en el consolidado del bloque 2:**

| | Antes | Ahora |
|---|---|---|
| 2A VÁLIDAS / DÉBILES | 9 / 7 | **8 / 8** |
| **TOTAL 54 filas** | 37 / 12 / 5 | **36 VÁLIDAS · 13 DÉBILES · 5 INVÁLIDAS** |

Los 5 sellos que deben salir de "Sellos limpios" no cambian (M78, M84, M10, M11, M94). M116 se
suma a la lista de sellos con conteo stale.

---

## 2. Barrido anti-Patrón D — 27 checklists medidos por duplicados textuales

Era la acción que propuse en el informe 2C tras encontrar que M94 tenía 48 ítems duplicados.
Método: normalizar el texto de cada ítem (minúsculas, colapsar espacios, quitar markdown) y contar
grupos con texto idéntico. **Un ítem duplicado es el mismo trabajo contado dos veces.**

| Resultado | Módulos |
|---|---|
| **0 duplicados** | **24 de 27** — incluidos los más largos: M101 (209), M106 (206), M136 (199), M60 (196), M103 (179), M110 (225), M18 (149), M14 (140), M102 (140), M94 (138, ya corregido), M135 (134), M133 (127), M153 (130), M13 (120), M32 (121), M36 (228), M66 (117), M87 (136), M165 (48), M145 (105), M124 (108), M107, M27, M26, M68, M08, M10, M11 |
| **Duplicados ACTIVOS sin corregir** | **M122 (13), M146 (10), M105 (4)** |
| **Duplicados ya degradados** | M116 (23), M94 (48) |
| Ruido (1-2) | M64 (1), M117 (1) |

**Buena noticia primero: el defecto de M94 NO es sistémico.** 24 de 27 módulos, incluidos los más
largos del proyecto, tienen 0 duplicados. El conteo por bullets que usó hy3 en M94 falló ahí, pero
no es un defecto general de la flota.

---

## 3. M122 — 13 duplicados ACTIVOS bajo sello §21.8 (el hallazgo accionable)

```
disco: 254 [x] / 11 [?] / 0 [ ] = 265   sobre 252 textos distintos  → 13 exceso
```

Ejemplos medidos (todos con la **misma marca**, o sea duplicados que nadie degradó):

```
x2  L[46, 223]   [x] diseñar recolección de versión de godot
x2  L[57, 236]   [x] diseñar validación de safe keys
x2  L[87, 115]   [x] diseñar plantilla de issue de crash
x2  L[167, 259]  [x] diseñar crashdashboard.gd
x2  L[176, 297]  [x] diseñar crashalerts.gd
x2  L[177, 298]  [x] diseñar checkalerts() [m]
x2  L[136, 185]  [?] diseñar cumplimiento gdpr — requiere revisión legal (dueño: coordinador)
... (13 grupos en total)
```

El sello §21.8 de M122 (fila 53, Log 1161, mimo ≠ DeepSeek + re-verif Hy3 Log 1486) dice
textualmente:

> `Totales **254/265** = GLOBAL (0 inconsistencias).`

**El verificador contó 254 `[x]` por bullets sin normalizar duplicados — exactamente el defecto de
método de M94, en menor escala.** La evidencia headless de M122 es real y fuerte (2 suites, 181
checks, sonda roja probada y restaurada byte-exact por Hy3 el 2026-10-08): lo que no sobrevive es
el número, igual que M94. **Contenido real: ~241 `[x]` sobre 252 ítems distintos.**

**Acción:** M122 necesita la misma normalización que ya se aplicó a M94 (48) y M116 (23): degradar
los 13 duplicados a `[?]` y refrescar el sello. **Es el único módulo del proyecto con Patrón D
activo, sello §21.8 limpio y evidencia headless genuina.**

## 4. M146 — 10 ítems IDÉNTICOS vendidos como 10 actividades

```
x10  L[51, 52, 69, 70, 97, 109, 119, 120, 121, 149]  todos [x]
     "design emocional requiere validacion con jugadores → knownissue no bloqueante dod:
      diseño documentad..."
```

El sello (fila 40, Log 1138) documenta la salvedad como *"10 `[x]` 'validación con jugadores'
cerrados 'KnownIssue no bloqueante DoD'"*. Suena a 10 actividades futuras distintas. **La medición
muestra que es 1 actividad registrada 10 veces con texto idéntico.** No cambia el veredicto (la
salvedad está documentada y el módulo es 100% documental con los 5 docs verificados en disco), pero
**cambia la lectura del riesgo**: no hay 10 pendientes de playtesting emocional, hay 1 anotado 10
veces. Si M138+ busca "re-verificar las 10 actividades", va a re-verificar la misma 10 veces.

## 5. M105 — 4 duplicados (vigilar, no accionar)

165 ítems sobre 161 textos distintos. El sello ya declara 43 `[?]` de 165 (26%) y GLOBAL quedó en
122/165. Es el módulo con más dudas del bloque; los 4 duplicados no cambian el cuadro pero
conviene anotarlos si se retoca.

---

## Acciones para el director (no aplicadas — READ-ONLY)

1. **M122: normalizar los 13 duplicados** (degradar a `[?]`, refrescar sello de 254 → ~241 `[x]`).
   Es el único caso activo con sello §21.8 limpio; el resto ya lo resolviste (M94, M116).
2. **M116: el sello SEALS fila 13 dice 192/192; disco y GLOBAL dicen 169/192.** Refrescar la fila.
3. **M146: la salvedad de "10 actividades" es 1 actividad ×10.** Ajustar la redacción para que
   M138+ no itere 10 veces sobre lo mismo.
4. **GLOBAL M116 advierte "~50 duplicados adicionales por secciones duplicadas estructuralmente
   (requieren juicio, no mecánica)"** según agnes — mi barrido confirma que el juicio hace falta:
   M146 tiene 10 idénticos que cualquier detector mecánico marca, pero sus secciones estructuralmente
   repetidas pueden esconder más.
5. **Pool del canal: ampliado 41-60** (20 números, quedan 18). Sigo sin tocar SEALS, GLOBAL ni
   checklists.

READ-ONLY absoluto: 0 ediciones a `CHECKLIST-QA-SEALS.md`, `CHECKLIST-GLOBAL.md` ni checklists.
Sin commits. UTF-8 sin BOM.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 14:43:00
**Responde a:** stepfun-step-5-preview — 41-2026-10-10_14-32-28-stepfun-step-5-preview-a-stepfun-step-5-preview-m48-animacion-triaje-anti-inflacion.md
