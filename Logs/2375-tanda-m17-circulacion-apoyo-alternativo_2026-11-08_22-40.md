# Log 2375: M17 — circulación de salidas y apoyo alternativo de escalera

**Fecha:** 2026-11-08
**Hora:** 22:40
**Modelo:** DeepSeek-V4.1-Flash (OpenCode)
**Plataforma:** OpenCode

## Resumen

Tanda de M17 Construcción con **2 ítems cerrados con evidencia** (L148 «las piezas no pueden
bloquear la única salida de la zona» y L143 «escalera exige apoyo en piso **o** pared»), una
**suite nueva de 36 checks** y la línea base del módulo en verde (5 suites, 0 fallos). M17 queda
**en pausa** por orden de la directora (mensaje 257: los 12 críticos de la evaluación Nemotron van
primero).

## Cambios Realizados

1. **`scripts/construccion/circulacion.gd` (NUEVO).** Modelo puro `class_name Circulacion`:
   BFS 4-direccional en x/z con `MAX_VISITAS = 200000`; `analizar()` devuelve
   `bloquea/salidas_aisladas/salidas_tapadas/libres_antes/libres_despues/componentes_antes/
   componentes_despues`. Detecta salida tapada, dos salidas desconectadas y salida única aislada;
   no culpa a la pieza nueva de una salida ya aislada antes.
2. **`construccion_validator.gd`.** Paso **9 `circulacion`**: `ORDEN` pasa a 9 reglas; el paso solo
   corre si `ctx["circulacion"]` es un `Dictionary` (fail-open `sin_datos` si no). Nuevo helper
   `tiene_apoyo_alternativo(receta, celda, rotacion, ctx)` usado en el paso 3 (soporte).
3. **`construccion_tipos.gd`.** Motivo nuevo `BLOQUEA_SALIDA` (permanente) con texto
   «taparia la unica salida de la zona».
4. **`placement_rule.gd`.** `apoyo_alternativo: Array[StringName]` export + round-trip en
   `a_dict()`/`desde_dict()`.
5. **Data.** `escalera_recta.tres` y `escalera_doble.tres` declaran `[&"pared"]` como apoyo
   alternativo.
6. **`tests/test_m17_circulacion.gd` (NUEVA).** A1-A16 (modelo puro) + B1-B7 (integración con el
   validador, incluida huella 2x1) + C1-C12 (apoyo alternativo y regresión de receta sin
   alternativo). **36 checks, 0 fallos, EXIT 0.**
7. **`tests/test_m17_construccion_validacion.gd`.** La aserción de `ORDEN` se actualizó de 8 a 9
   reglas (contrato, no comportamiento). 44/0.
8. **`tests/test_m17_suites_integracion.gd`.** Watchdog: `w.start()` en `_initialize()` corría antes
   de que el `Window` raíz entrara al árbol y Godot emitía
   `ERROR: Unable to start the timer because it's not inside the scene tree`. Se cambió a
   `w.autostart = true`; el error desapareció y la suite sigue 17/0 (501 checks en las 7 suites).
9. **`DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`.** L143 y L148 → `[x]` con
   evidencia; encabezado «Última tanda» y línea de Totales nuevas. Conteo real por prefijo:
   **141 `[x]` / 33 `[ ]` / 1 `[?]` = 175**.
10. **`DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md`.** Sección 9 nueva (qué se añadió,
    ítems cerrados, línea base, corrección de §8.4 y deuda honesta).

## Evidencia (5 suites, Godot 4.7.2 headless)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `tests/test_m17_circulacion.gd` (NUEVA) | 36 | 0 | 0 |
| `tests/test_m17_construccion_validacion.gd` | 44 | 0 | 0 |
| `tests/test_m17_reglas_pieza.gd` | 40 | 0 | 0 |
| `tests/test_m17_suites_integracion.gd` | 17 (501 en las 7 suites) | 0 | 0 |
| `tests/test_m17_persistencia_rejilla.gd` | 23 | 0 | 0 |

## Deuda honesta

- El paso 9 **no está cableado al `BuildManager`**: nadie arma todavía `ctx["circulacion"]` (dueño
  de la zona: M18 escena / M64 navmesh). Sin datos, el paso devuelve `sin_datos` y no bloquea.
- El modelo es **por planta**: una escalera no conecta plantas para el BFS. Documentado para que el
  cableado no asuma lo contrario.
- `G139`/`G144` citados en §8.4 de `04-Codigo.md` **no existen** como líneas del checklist (IDs
  legacy); las líneas reales son L143 y L148, ambas cerradas.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/construccion/circulacion.gd` (NUEVO)
- `game/isla-ancestral/scripts/construccion/construccion_validator.gd`
- `game/isla-ancestral/scripts/construccion/construccion_tipos.gd`
- `game/isla-ancestral/scripts/construccion/placement_rule.gd`
- `game/isla-ancestral/data/construccion/piezas/escalera_recta.tres`
- `game/isla-ancestral/data/construccion/piezas/escalera_doble.tres`
- `game/isla-ancestral/tests/test_m17_circulacion.gd` (NUEVO)
- `game/isla-ancestral/tests/test_m17_construccion_validacion.gd`
- `game/isla-ancestral/tests/test_m17_suites_integracion.gd`
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md`

## Nota de estado del repositorio

Parte de esta tanda (`circulacion.gd`, validador, `placement_rule.gd`, data y la suite nueva) ya
fue barrida por el commit de preservación `e634eef` de un tercero; quedan como modificados en el
working tree solo `tests/test_m17_construccion_validacion.gd` y
`tests/test_m17_suites_integracion.gd`. No se hizo commit propio.
