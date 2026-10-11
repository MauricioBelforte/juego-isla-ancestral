# Log 1657: M50-Vegetación — `vegetation_budget.json` inexistente, sin reemplazo en código

**Fecha:** 2026-10-11
**Hora:** 10:10
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Asignación del director (msg 113): verificar M50-Vegetación, donde DeepSeek detectó
`vegetation_budget.json` inexistente (H4) y el director degradó L110 `[x]`→`[?]`.
**Confirmado: el archivo no existe y no hay nada que lo reemplace.**

## Verificación

### 1. `vegetation_budget.json` — NO EXISTE

| Búsqueda | Resultado |
|---|---|
| `game/**/vegetation_budget*` | **0 resultados** |
| Referencias en `.gd` (`vegetation_budget`) | **0 resultados** |
| Alguna constante `budget`/`presupuesto`/`coste`/`max_insta`/`limite` en `scripts/vegetacion/` | **0 resultados** |
| Algún `*.json` con función de presupuesto | ninguno (ver abajo) |

### 2. Qué existe en su lugar

`game/isla-ancestral/data/vegetacion/vegetacion_config.json` existe, pero **no es un presupuesto**:
contiene `biomas` → `tipos` + `densidad` (número de instancias por bioma), sin coste, límite de
instancias ni tope de rendimiento.

```
{"playa": {"tipos": [...], "densidad": 12}, "bosque": {"densidad": 22}, ...}
```

`densidad` es cantidad de spawns por bioma, no un presupuesto de coste. No sustituye la función del
ítem L110.

### 3. Conteo del módulo — coherente (con una contradicción resuelta)

| Fuente | Valor |
|---|---|
| Disco (`^\s*-\s+\[[ x?]\]`) | **28 `[x]` / 4 `[?]` / 110 `[ ]` = 142** |
| Línea Totales (L276) | 142 · 28 · 110 · 4 ✅ |
| `CHECKLIST-GLOBAL.md` | **28/110/4** ✅ |
| Nota de drift (L279, 2026-09-20) | 29 `[x]` / 110 `[ ]` / 3 `[?]` ⚠️ |
| Auditoría T (L282, agnes) | 29 `[x]` verificados ⚠️ |

**La contradicción 28 vs 29 se resuelve:** ambas notas midieron 29 `[x]` **antes** de que el director
degradara L110 a `[?]` (2026-10-11). Con la degradación, 29 − 1 = 28 y 3 + 1 = 4. Las notas quedaron
como histórico; el conteo vigente es 28/4/110 y cuadra en las tres fuentes.

### 4. Muestreo §21.8.2.b

De los 28 `[x]`, solo **3** contienen verbos de creación (L100, L186, L191) y **ninguno cita ruta de
archivo**. El muestreo por verbos no es concluyente: el módulo, como M74, tiene perfil de
diseño/planificación más que de implementación.

### 5. Coherencia código ↔ checklist

Código real en disco (`scripts/vegetacion/`): `vegetation_manager.gd`, `vegetation_plan.gd`,
`vegetation_spawner.gd` + 4 suites.

| Suite | Resultado |
|---|---|
| `test_vegetation_headless.gd` | ✅ **7 checks, 0 fallos** |
| `test_vegetation_plan_headless.gd` | ✅ **5 checks, 0 fallos** |
| `test_vegetation_spawner_headless.gd` | ✅ **4 checks, 0 fallos** |
| `test_distribucion.gd` | ✅ exit 0 (utilidad de debug, sin contador) |
| **Total** | **16 checks, 0 fallos** |

`test_distribucion.gd` **no está citada en el checklist** — trabajo real no documentado (cuarta suite).

### 6. Los 4 `[?]`

| Línea | Ítem |
|---|---|
| L110 | Definir registro `vegetation_budget.json` — **confirmado inexistente** |
| L117 | Verificar LOD presente — no implementado |
| L197 | VegetationManager (spawn/pooling/densidad) — iter 2 |
| L203 | Instanciación en el mundo (M08 poblar) — iter 3 |

L197/L203 explican el 110 `[ ]`: el grueso del módulo es integración pendiente con M08/M10.

## Veredicto

**El ítem L110 queda correctamente degradado a `[?]`.** La deuda es real y no tiene reemplazo: o se
crea el `vegetation_budget.json`, o se elimina el ítem y se documenta que `densidad` por bioma cumple
ese rol. **Decisión del director.**

El módulo tiene código funcional (3 ficheros + 4 suites, 16 checks verdes) y conteo veraz en tres
fuentes. Con 110 `[ ]` y 4 `[?]`, **no cumple §21.8 para sello**.

## Archivos Modificados/Creados

**Creados:**
- `Logs/1657-M50-vegetation-budget-inexistente-sin-reemplazo_2026-10-11.md`

**Leídos (read-only):**
- `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md`
- `CHECKLIST-GLOBAL.md`
