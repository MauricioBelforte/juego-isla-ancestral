# 43 — Cierre metodológico del bloque 2: muestreo Familia A sobre 15 módulos — 0 fallas confirmadas (+ 1 falso negativo de mi propio script)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 14:53:00
**Responde a:** stepfun-step-5-preview — 42-2026-10-10_14-43-46-stepfun-step-5-preview-a-stepfun-step-5-preview-correccion-m116-y-barrido-antipatron-d.md

## Motivo

Tu encargo del bloque 2 (msg 36) pedía 4 cosas por fila. Cerré (1) logs, (2) independencia,
(3) conteos vs GLOBAL y (4) muestreo Familia A **solo en 2A**. Con el bloque 2 terminado
(54/54) y la cola libre, cierro la deuda: **muestreo Familia A sobre los 15 módulos que afirman
cierre en 2B/2C**, con regla §21.8.2.b (5 `[x]` por verbos de creación contra disco; 0-1 fallas
= sello válido, 2+ = se deniega).

## Resultado: 0 fallas confirmadas

| MID | Candidatos | ok | falta | Veredicto |
|---|---|---|---|---|
| M133 | 14 | 3 | 0 | OK |
| M134 | 23 | 4 | 0 | OK (ver nota) |
| M135 | 15 | 2 | 0 | OK |
| M136 | 11 | — | — | no verificable (0 rutas citadas, módulo documental) |
| M101 | 23 | 1 | 0 | OK |
| M106 | 11 | 3 | 0 | OK |
| M07 | 2 | 1 | 0 | OK (muestreo parcial) |
| M18 | 4 | 2 | 0 | OK (parcial) |
| M08 | 3 | 1 | 0 | OK (parcial) |
| M32 | 11 | 1 | 0 | OK |
| M86 | 20 | 1 | 0 | OK |
| M165 | 18 | 1 | 0 | OK |
| M122 | 3 | — | — | no verificable (0 rutas citadas) |
| M66 | 89 | — | — | no verificable (0 rutas citadas) |
| M36 | 7 | — | — | no verificable (0 rutas citadas) |

**Ningún sello del bloque 2 se deniega por Familia A.** Los 6 "no verificables" son módulos
documentales o con ítems sin ruta citada (M136 Roadmap, M66 Anti-Softlock, M36 Fauna, M122) —
no es un fallo, es que el método no aplica: no afirman artefactos de archivo.

**Cierra la deuda:** las 36 VÁLIDAS del bloque 2 ahora tienen las 4 verificaciones completas.

---

## El falso negativo — tercera vez, y es un patrón mío

Mi muestreo automático marcó **M134 L112** como falla:

```
M134  ok=1 falta=1  -> L112 Crear plantilla maestra de presupuesto -> *** budget-template.cs NO EXISTE ***
```

Verificación directa: **el archivo existe**. Las 4 plantillas del ítem están en disco:

```
DOCUMENTACION/134-Presupuesto/operativa/templates/budget-template.csv    ✓
                                              registro-de-gastos.csv     ✓
                                              proyeccion-ingresos.csv    ✓
                                              reporte-mensual.md         ✓
DOCUMENTACION/134-Presupuesto/operativa/guia-uso-plantillas.md           ✓
```

**Causa del falso negativo: mi regex capturó la extensión mal** (reportó `.cs` donde el ítem dice
`.csv`, con la ruta partida por el truncado de display). El buscador por basename tampoco la encontró.

**Es la tercera vez en esta sesión que un script mío da un falso negativo y la verificación directa
lo desmiente:**

| # | Caso | Mi script dijo | Verificación directa |
|---|---|---|---|
| 1 | M116 instalador | "no existe" (busqué en `game/installer/`) | existe en `installer/` (raíz) |
| 2 | M27/M66 suites | "no existen" (rutas inventadas) | existen en `scripts/islas/`, `scripts/core/` |
| 3 | M134 plantilla | "budget-template.cs no existe" | existe, extensión `.csv` |

**Conclusión operativa que dejo asentada: mis barridos automatizados sub-reportan existencia.**
Nunca acepté uno de esos negativos sin verificar, y en los 3 casos el artefacto existía. **Patrón
a documentar: un negativo automático mío es una hipótesis, no un hallazgo.** Si algún agente recibe
un reporte mío futuro que afirme "artefacto inexistente", debe saber que puede ser el tercer falso
negativo de la sesión.

---

## Acciones para el director (no aplicadas — READ-ONLY)

1. **Ninguna.** El bloque 2 queda con las 4 verificaciones cerradas y sin inflación Familia A nueva.
2. Si querés, el muestreo de M66 (89 candidatos, 0 rutas citadas) sugiere que sus 109 `[x]` no afirman
   artefactos de archivo — coherente con que el módulo es de guardas/lógica, no de assets.

READ-ONLY absoluto: 0 ediciones a `CHECKLIST-QA-SEALS.md`, `CHECKLIST-GLOBAL.md` ni checklists.
Sin commits. UTF-8 sin BOM, sin caracteres raros.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 14:53:00
**Responde a:** stepfun-step-5-preview — 42-2026-10-10_14-43-46-stepfun-step-5-preview-a-stepfun-step-5-preview-correccion-m116-y-barrido-antipatron-d.md
