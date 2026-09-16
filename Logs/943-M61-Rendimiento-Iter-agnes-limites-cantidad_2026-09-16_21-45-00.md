# Log 943: M61 Rendimiento — iter. agnes acotada (gate de límites de CANTIDAD)

**Fecha:** 2026-09-16
**Hora:** 21:45
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Iteración del bucle V0/data-driven de **agnes-3-flash** sobre **M61 Rendimiento** (relevo §21.4.7 de la
reserva agnes-2.5 stale de 09-03). **Alcance deliberadamente acotado** a lo que mejor hago: data-driven +
gate CI + headless. El gate `validate_budget.gd` solo validaba presupuestos de **TIEMPO**; el límite de
**CANTIDAD** de partículas (spec §M "≤500 simultáneas/cámara", disparado por mi flag M52 "turbulencia 24
FPS") no estaba modelado. Lo agregué.

## Cambios Realizados

- **`data/performance/budgets.json`:** nuevo bloque `limites` → `particulas_simultaneas_max` (500, spec §M
  M61/RF13 + flag M52), `draw_calls_max` (400 = objetivo E.59), `objetos_mundo_max` (1000) + `nota` de
  trazabilidad.
- **`scripts/performance/validate_budget.gd`:** nuevos `_validar_limites()` + `_medicion_dentro_limites()`:
  valida el bloque (presente, bien formado, partículas == 500, lectura excedida detectada), **tolerante si el
  bloque falta** (no rompe el gate temporal para ramas anteriores). Print de evidencia `[M61] limites: 3
  limit(es) de cantidad validados`.
- **`05-Checklist.md` M61:** §M "Definir ≤500 partículas simultáneas por cámara" → `[x]` **con evidencia**
  (límite data-driven + gate). El contador runtime (que M52 no exceda 500 en ejecución) **sigue siendo del
  dueño M52**. Sección "Iteración agnes" agregada.
- **`04-Codigo.md` M61:** §"Iteración agnes" (cambios + verificación + reglas de asignación + nota §28 del
  typo preexistente `ools/mcp` en línea 240, no tocado).

## Verificación (godot 4.7.2 headless)

- `godot --headless --script res://scripts/performance/validate_budget.gd` → **0 fallos, exit 0, 0
  `SCRIPT ERROR`** (con y sin el print de evidencia).
- Trampa del linter estricto aplicada (misma lección M106/M107): `var clave_limite := clave + "_max"` con
  `clave` Variant → "Cannot infer type"; corregido con tipos explícitos (`String(clave)` + `: String`).

## Hallazgos
1. **M52→M61 bridge:** el flag "turbulencia 24 FPS" (Log 932, QA visual) ahora tiene un **límite data-driven
   concreto** (≤500 partículas/cámara) modelado en el gate CI de M61. El M52 solo debe agregar el contador
   runtime.
2. **Nota §28:** `04-Codigo.md` M61 línea 240 trae typo preexistente ajeno ("ools/mcp" por "tools/mcp") —
   verificado como UTF-8 válido (no mojibake), no lo toqué; quedó anotado para la pasada de saneamiento.

## Archivos Modificados/Creados

- `game/isla-ancestral/data/performance/budgets.json` (bloque `limites`)
- `game/isla-ancestral/scripts/performance/validate_budget.gd` (`_validar_limites` + `_medicion_dentro_limites`)
- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` (§Iteración agnes)
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` (§M + sección iter. agnes + reserva)
- `CHECKLIST-GLOBAL.md` fila 61 (mod)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada)
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/` (BACKLOG + 61, nuevo)

## Estado de M61
🟡 **Liberado (iter. agnes, acotada).** 34/139. Mi parte (gate de cantidades) entregada y verificada; la
metodología completa (bench visual V2, CI M116, técnicas LOD/pooling) sigue siendo del dueño M61. QA cruzado
§21.8 pendiente (verificador ≠ autor).
