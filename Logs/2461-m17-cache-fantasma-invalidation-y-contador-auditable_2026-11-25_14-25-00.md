# Log 2461: M17 Construccion — P9c: la cache del fantasma (invalidacion + contador auditable)

**Fecha:** 2026-11-25
**Hora:** 14:25
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Tercera parte del barrido de la misma familia de defecto (L102 → escritura atómica → **cache del
fantasma**). Ítem tocado: **L225** (cache de celda) — **anotado, NO cerrado**: el throttle de 1
raycast por frame vive en la capa de input (M70).

**M17 sigue en 148/175, 0 `[?]`, 0 ítems inflados.** 0 flips en esta tanda.

## El defecto

`BuildPreview` cachea la evaluación por `(celda, rotacion, receta_id)` y se invalida con `limpiar()`.
La invalidación existía en **cuatro** rutas — `confirmar_colocacion`, `demolir_pieza`,
`mover_pieza` e `_invertir` — pero **faltaba en tres mutaciones del mundo**:

| Ruta sin invalidar | Consecuencia |
|---|---|
| `copiar_pieza()` | aparece una pieza nueva y la cache sigue valiendo |
| `limpiar_estructuras()` | se vacía el mundo y la cache sigue valiendo |
| `restaurar_estructuras()` (carga de save) | ídem (por cascada) |

Efecto para el jugador: el fantasma podía pintar **VERDE** una celda que ya estaba ocupada (o ROJA
una celda válida) porque reutilizaba un resultado viejo. Es la misma familia: **el sistema mostraba
un estado que ya no era verdad**.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/construccion/build_manager.gd` | `copiar_pieza()` y `limpiar_estructuras()` invalidan la cache del fantasma (`_preview.limpiar()`). `restaurar_estructuras()` queda cubierta por cascada. |
| `game/isla-ancestral/scripts/construccion/build_preview.gd` | Nuevo **contador auditable monótono** `recalculos_totales()` (NO se resetea al invalidar). El `recalculos()` de sesión queda **intacto** (lo usan `test_construccion_iter2.gd` e `iter3.gd`: su semántica no se toca). |
| `game/isla-ancestral/tests/test_m17_cache_preview.gd` (NUEVO) | **17 checks** + mínimo 12. |
| `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` | Nueva sección **§17**. |
| `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` | **L225 anotado** con la evidencia de la cache (sin flip: el throttle es de M70). |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2461** consumido. |

## Verificación (Godot 4.7.2 headless, binario real)

**Suite nueva** `tests/test_m17_cache_preview.gd`: **17 checks, 0 fallos, EXIT 0**.
Checks clave: "A2: la segunda vista previa MISMA celda es un acierto de cache" · "A3: el acierto de
cache NO recalcula" · "B3: COPIAR invalida la cache del fantasma (no se reutiliza el resultado
viejo)" · "B5: la vista previa de la celda recien copiada dice INVALIDA (la pieza esta ahi)" ·
"C1/C2: VACIAR el mundo invalida la cache y la celda ocupada vuelve a ser VALIDA" · "D1/D2: RESTAURAR
estructuras (carga de save) invalida la cache".

**ROJO-VERDE:** sin el `_preview.limpiar()` de `copiar_pieza()` → **1 fallo / EXIT 1** (el preview
reutiliza el resultado viejo). Restaurada → 17/0.

**Regresión: 16 suites en verde** (M17 ×15 + M59 28/0), incluidas `test_construccion_iter2.gd`
(99/0) e `iter3.gd` (138/0), que dependen de `recalculos()`.

## Lo que NO se hizo (honestidad)

- **L225 NO se cierra**: la mitad que sí es de M17 (la cache de celda) queda verificada con checks;
  el **throttle de 1 raycast por frame** vive en la capa de input (**M70**, su dueño).
- **M20** no se toca (reclamado por GLM-5.3-Flash).
- No se fabrican datos de otros dueños.
- El barrido sigue: quedan `build_ghost.gd` y `build_hud.gd` sin auditar con este criterio.
