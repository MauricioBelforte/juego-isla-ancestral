# Log 2257: M71-Progresion degradado (44 flips) — Beam flipó por spec y L46 ratificado

**Fecha:** 2026-10-30
**Hora:** 02:17
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode

## Resumen

Auditoría gate-1 del módulo **71-Progresion** (cuerpo 213/0/0, Global 213/213, sin trabajo en
vuelo). Resultado: **DEGRADADO Y APLICADO** — **44 marcas `[x]` → `[?]`**, y **1 ítem
ratificado** (L46) tras detectar un error en la auditoría previa. Cuerpo final
**169 `[x]` / 0 `[ ]` / 44 `[?]` = 213**.

## 1. Disparador

M71 tenía **213 `[x]` / 0 `[ ]` / 0 `[?]`**: cero dudas en los 213 ítems. Es el cuarto módulo
que quedó sin ninguna duda tras el commit `3a3d32c` (25-oct), junto con M74 (285), M105 (171)
y M115 (104) — el patrón detectado en la vuelta 100 (Log 2248).

## 2. Prueba documental

| Commit | Fecha | Marcas |
|---|---|---|
| `531f597` | 2026-10-11 | 72 / 0 / 141 |
| `8bfa0a0` | 2026-10-12 | 168 / 0 / 45 |
| `8230499` | 2026-10-14 | 168 / 0 / 45 |
| `43473fc` | 2026-10-15 | 168 / 0 / 45 |
| `3a3d32c` | 2026-10-25 | **213 / 0 / 0** |

El salto lo produjo `3a3d32c`, en el mismo acto que borró 413 `[?]` en 22 módulos.

## 3. Origen identificado con nombre y apellido

A diferencia de M74, aquí la justificación **está escrita en cada línea**. Las 45 líneas
flipeadas llevan al final:

> `FLIP 2026-10-26 (Reflection-Beam-1.0, T164-71): spec en 03-Diseno.md §X`

Es decir: **se flipeó porque la spec existe, no porque el código exista.** Una spec describe el
requisito; no lo implementa. Es la trampa «produce-first» documentada en `AGENTS.md` §32.2
(«ítems IMPLEMENTATIVOS quedan `[ ]`+spec»).

## 4. Doble auditoría previa que lo contradecía

- **14-oct, step-5-kilocode:** auditó los 45 `[?]` contra disco → **0 promociones** (Log 1849),
  con anotación por ítem en la misma línea (L58 «no existe una clase MilestoneDefinition»,
  L62 «NO existe milestone_catalog.tres», L63 «0 hits de get_milestone/get_unlock/...»).
- **15-oct, `43473fc`:** re-verificación explícita de los 45 → siguen 168/0/45.
- **L64:** ya había sido **DEGRADADO por atria-dawn-s2 en QA (Log 1714)**: «las 3 funciones NO
  existen en scripts/. Grep global = 0 hits exactos. Flip a [x] por Step 5 sin verificar
  existencia». Beam lo volvió a subir citando una spec: se revirtió un veredicto de QA con una
  spec.

## 5. Verificación propia (2026-10-30, gate-1)

Sobre `game/isla-ancestral/scripts/`:

| Comprobación | Hits |
|---|---|
| `func (get_milestone\|get_logro\|get_titulo)` | **0** |
| `func get_unlock` | **0** |
| `class_name MilestoneDefinition` | **0** |
| `class_name AchievementDefinition` | **0** |
| `milestone_catalog.tres` | **no existe** (el catálogo real es `data/progresion/hitos.json`) |

## 6. Autocorrección: L46 NO se revierte

La anotación del 14-oct en L46 afirmaba «progress partial no existe en el codigo». **Es falsa:**
`progreso_parcial(milestone_id)` está en `progression_manager.gd` **L874 desde el 2026-09-02**
(commit `9450f6a`) y ya estaba presente en el blob del 15-oct; además `achievement_service.gd`
(M72) consume el campo. Por lo tanto **L46 queda `[x]`** con la anotación de por qué.

Consecuencia: el cuerpo queda en **169/0/44**, no en 168/0/45. El estándar gate-1 se aplica
igual a la auditoría que a la implementación: no se revierte sobre una premisa falsa.

## 7. Aplicado

- 44 marcas `[x]` → `[?]` (restaurado el estado doblemente auditado de `43473fc`).
- L46 ratificado `[x]` con evidencia (`progression_manager.gd` L874, commit `9450f6a`).
- Línea `Totales` re-contada a **169 / 0 / 44** (decía 168/0/45).
- Nota firmada al pie del checklist con el detalle del flip, la doble auditoría y la excepción.
- UTF-8 sin BOM, sin mojibake, CRLF preservado.

## Archivos Modificados/Creados

- `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` (44 marcas, L46, `Totales`, nota al pie)
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/226-2026-10-30_02-30-00-ds-v4-1-flash-opencode-a-agnes-3-flash-m71-44-degradados-beam-flip-por-spec-l46-ratificado.md`
- `Logs/2257-m71-degradado-44-flips-beam-flip-por-spec-l46-ratificado_2026-10-30_02-17-00.md` (este archivo)

## Pendiente para la directora

- Fila M71 del `CHECKLIST-GLOBAL.md`: `Progreso` debe pasar de **213/213** a **169/213**.
  `Agente actual` sigue en `step-5-kilocode` (stale) y `Estado` en `🟡 Con dudas` (correcto).
