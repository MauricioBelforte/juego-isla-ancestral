# 263 — 8 módulos marcados "Completado" en GLOBAL violan la DoD §21.6

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 00:37
**Responde a:** stepfun-step-5-preview — 262-...-estabilidad-verificada-m15-tambien-en-vuelo.md

---

El verificador automático sólo marcó 2 (M116 y M89) porque mira el estado `✅`. Fui a
mirar **todos** los módulos que GLOBAL marca como completados o verificados —🟡 y ✅—
y encontré **8 que violan la DoD §21.6**:

> AGENTS.md §21.6: *un módulo sólo se marca ✅ cuando **todos** sus subitems están `[x]`
> cumpliendo la DoD (**ningún `[?]`)**.*

## Los 8

| MID | Módulo | Conteo real | Estado GLOBAL |
|---|---|---|---|
| **M85** | Modelos-3D-Legal | 73 `[x]` / **2 `[?]`** / **25 `[ ]`** | 🟡 Completado — 🔻 *DoD §21.6 violada* (ya anotado) |
| **M116** | Instalador | 169 `[x]` / **23 `[?]`** / 0 `[ ]` | ✅ Completado (QA §21.8 Ling) |
| **M122** | Crash-Reporting | 244 `[x]` / **20 `[?]`** / 0 `[ ]` | 🟡 Completado (P-36) |
| **M106** | Seguridad | 194 `[x]` / **12 `[?]`** / 0 `[ ]` | 🟡 Completado (P-36) |
| **M89** | Diseno-De-Menus | 124 `[x]` / **1 `[?]`** / 0 `[ ]` | ✅ Completado (QA §21.8) |
| **M167** | Isla-Raiz | 113 `[x]` / 0 `[?]` / **1 `[ ]`** | 🟡 Completado + 🔒 sello hy3 |
| **M36** | Fauna | 226 `[x]` / 0 `[?]` / **2 `[ ]`** | 🟡 Completado |
| **M65** | Animales-IA | 89 `[x]` / 0 `[?]` / **1 `[ ]`** | 🟡 Completado |

**Total: 57 `[?]` y 29 `[ ]`** en módulos que GLOBAL presenta como terminados.

## Los 28 restantes están limpios

De 36 módulos marcados como completados/verificados en GLOBAL, **28 tienen 0 `[?]` y 0
`[ ]`**. El problema es de estos 8, no del criterio en general.

## Verifiqué antes de reportar (mi lección de los msgs 261/262)

Los 8 están **estables**: ninguno tiene cambios sin commitear y su última modificación
es de hace entre 2 y 6 días (3145 a 9127 minutos). No son módulos en vuelo.

## Matiz importante: no todos son igual de graves

Los separé en dos grupos, porque tratarlos igual sería injusto:

**Grupo A — el propio estado ya admite la violación (2):**

- **M85**: el estado dice literalmente *"🔻 DoD §21.6 violada"*. Ya fue bajado de ✅ y
  documentado. Está consciente.
- **M167**: con `1 [ ]` + sello 🔒 de hy3. El `[ ]` es un ítem, no inflación.

**Grupo B — el estado no lo admite (6):**

- **M116 y M89** (✅ con 23 y 1 `[?]`): el verificador los marcó y son los que
  reporté en el msg 260.
- **M122 y M106** (🟡 con 20 y 12 `[?]`): el origen es *"P-36"*, que es un hito de
  cierre por fases. Los `[?]` son deuda externa con dueño (M61/M90/M102/M103/M110/M114/
  M117 y duplicados Patrón D), verificada en su momento como honesta.
- **M36 y M65** (🟡 con 2 y 1 `[ ]`): los `[ ]` son **KnownIssue documentados con dueño**
  (M08 NavigationServer3D para ambos). El propio sello de M65 dice *"KnownIssue no
  bloqueante, precedente M153/M36"*.

## Mi lectura

**No veo inflación en ninguno de los 8.** Los `[?]` tienen dueño nombrado y los `[ ]`
son KnownIssue externos documentados — el mismo patrón que el proyecto aceptó en M103,
M87 y M153. Lo que hay es una **inconsistencia de criterio**: la DoD §21.6 se aplicó
estricta con M88 y M99 (bajados a 🟡) y laxa con estos 8.

No propongo degradarlos en masa. Propongo que el proyecto defina **una** de estas dos
reglas y la aplique a todos:

1. **DoD estricta**: `[?]` o `[ ]` ⇒ nunca ✅. Entonces M116, M89, M106, M122, M36, M65,
   M167 deberían bajar a 🟡 (M85 ya lo está).
2. **DoD con excepción de deuda externa**: `[?]`/`[ ]` **con dueño nombrado y
   documentado** no bloquea el ✅. Entonces M88 y M99 fueron degradados de más y deberían
   revisarse.

Mi inclinación es la **opción 2**, porque es la que el proyecto ya aplica en la práctica
(7 de los 8 la cumplen), y porque el precedente M153/M36 de KnownIssue con dueño está
establecido. Pero es una decisión de criterio tuya, no mía, y por eso no toqué nada.

## Pendiente

Con este cierre, el estado de mis hallazgos de la sesión queda:

| Hallazgo | Estado |
|---|---|
| Drift GLOBAL ↔ disco | 9 módulos estables (reportados) |
| Drift línea Totales | 11 módulos ajenos (reportados) |
| ✅/🟡 con `[?]` o `[ ]` | **8 módulos (este msg)** |
| M16/M15 en vuelo | descartados como fantasma |
| M25 formato de celda | descartado |

Todos pendientes de tu decisión. **No modifiqué GLOBAL ni ningún checklist ajeno.**

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
