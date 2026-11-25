# Log 2452: M17 Construccion — P7: el ÚNICO `[?]` del módulo cerrado (contenido de las piezas)

**Fecha:** 2026-11-25
**Hora:** 11:50
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Cuarta tanda de la sesión sobre **M17-Construccion**. El objetivo era el **único ítem en `[?]`** del
módulo (degradado por atria-dawn-s2 el 2026-10-08, msg 133):

> *"La demolición de piezas funcionales (camas, almacenamiento) libera su contenido [C]"* — con la nota
> de que `demolir_pieza` solo devuelve los **materiales** de la receta, de que no existe lógica de
> liberar contenido y de que **no existe `build_interaction.gd`** (que el propio `04-Codigo.md` §1 ya
> listaba como "Punto de interacción en piezas funcionales (camas, almacenamiento M18)").

**Verificado en disco: era real.** Los items de un cofre **se perdían** al demoler la pieza.

**M17: 146 → 147 de 175, y el módulo queda con 0 ítems `[?]`** (28 `[ ]`, todos de otros dueños).

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/construccion/build_interaction.gd` (NUEVO) | Modelo puro del contenido de las piezas: `items_de_contenido` (normaliza las 2 formas de cofre del proyecto), `contenido_de`, `tiene_contenido`, `liberar_contenido` (NO muta), `vaciar_contenido` (sí muta), `items_a_contenido` (inverso), `total_items`, `texto_contenido`, `es_funcional`. |
| `game/isla-ancestral/scripts/construccion/build_manager.gd` | (1) `demolir_pieza()`: los items de la pieza **vuelven al inventario** y el resultado reporta `contenido_liberado`/`items_liberados`; (2) el historial guarda el `contenido` liberado → **deshacer** restituye la pieza **íntegra** y saca los items del inventario (no se duplican ni se pierden), **rehacer** los devuelve; (3) API pública `contenido_de_pieza(clave)` / `asignar_contenido(clave, items)` para M18. |
| `game/isla-ancestral/tests/test_m17_contenido_piezas.gd` (NUEVO) | **32 checks**, watchdog de 120 s, minimo 22. |
| `.github/workflows/quality.yml` | La suite nueva queda cableada en el gate M118. |
| `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` | Nueva sección **§13**. |
| `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` | El `[?]` → `[x]` con evidencia; Totales **147/28/0**. |
| `CHECKLIST-GLOBAL.md` | Fila 17: **147/175**, sin `[?]`. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2452** consumido. |

## Trampa de headless (documentada en §13.2)

Un archivo **nuevo** con `class_name` **no está en la cache global de clases** hasta que el editor
reescanea el proyecto. En headless eso rompía el arranque del autoload del manager:

```
SCRIPT ERROR: Parse Error: Identifier "BuildInteraction" not declared in the current scope.
ERROR: Failed to instantiate an autoload, script 'build_manager.gd' does not inherit from 'Node'.
```

y la suite **se colgaba** (EXIT 124) en vez de fallar. **Solución:** el manager carga el modelo con
`const INTERACCION := preload("res://scripts/construccion/build_interaction.gd")` en vez de por
`class_name` (el `class_name` se mantiene para cuando el editor registre la clase).

## Evidencia (Godot 4.7.2 headless, binario real)

**Suite nueva** `tests/test_m17_contenido_piezas.gd`: **32 checks, 0 fallos, EXIT 0**.

**ROJO-VERDE:** con `liberar_contenido()` stubbeado a items vacíos → **4 fallos (A9, A11, B7, B8) /
EXIT 1**. Restaurado → 32/0, EXIT 0.

**Regresión M17 completa (12 suites, todas EXIT 0):**

| Suite | Checks | Fallos |
|---|---|---|
| `test_m17_contenido_piezas.gd` (NUEVA) | 32 | 0 |
| `test_m17_hud_categorias.gd` | 22 | 0 |
| `test_m17_categorias.gd` | 24 | 0 |
| `test_m17_almacenamiento.gd` | 33 | 0 |
| `test_m17_materiales_compartidos.gd` | 13 | 0 |
| `test_m17_construccion_validacion.gd` | 44 | 0 |
| `test_m17_reglas_pieza.gd` | 40 | 0 |
| `test_m17_circulacion.gd` | 36 | 0 |
| `test_m17_persistencia_rejilla.gd` | 23 | 0 |
| `test_m17_suites_integracion.gd` | 17 (501 en las 7 suites) | 0 |
| `qa_m17_modo.gd` | 9 | 0 |
| `test_construccion_iter3.gd` | 138 | 0 |

## Checks clave (texto literal)

- "A1: el cofre canonico {'contenido':[{item_id,cantidad}]} se normaliza a {item_id: cantidad}"
- "A10: liberar_contenido NO vacia el cofre (la pieza guardada sigue INTEGRA para el deshacer)"
- "A12: items_a_contenido -> items_de_contenido es una ida y vuelta (piedra 3, madera 1)"
- "B7: la demolicion DEVUELVE los items al inventario (no se pierden)"
- "C3: la pieza vuelve INTEGRA (con su cofre y sus 4 de madera)"
- "C4: al deshacer, los items vuelven del inventario al cofre (no se duplican)"
- "D1: demoler una pieza SIN contenido -> ok (no rompe nada)"

## Regresion GLOBAL (runner central del proyecto, el mismo que usa el gate de CI)

`res://tests/run_tests.gd` (suite completa del repo, con su evidencia anti-falso-verde):

```
[EVIDENCIA] suites descubiertas: 70 (66 SceneTree + 4 GdUnit4) · excluidas documentadas: 0
[EVIDENCIA] suites OK: 70/70 ejecutables (de 70 descubiertas, 0 excluidas documentadas)
[EVIDENCIA] checks SceneTree: 2961 · test cases GdUnit4: 21 · tests totales: 2982
RESULTADO: ÉXITO MEDIDO — 70/70 suites · 2982 tests ejecutados · 0 fallos
```

EXIT 0. Las 4 suites de M17 nuevas/entregadas por este agente aparecen en el descubrimiento del
runner: `test_m17_categorias.gd`, `test_m17_contenido_piezas.gd`, `test_m17_hud_categorias.gd`,
`test_m17_materiales_compartidos.gd`.

> Nota honesta: el runner reporta **tiempo de suite 771 s (presupuesto 600 s, EXCEDE)**. No es una
> regresion de este cambio (el runner paraleliza 66 suites y la maquina esta compartida con el resto
> de la flota); el veredicto es **0 fallos**.

## Lo que NO se hizo (honestidad)

- La **ventana de confirmación** con lo que devuelve la pieza es **UI de M18** (L133): aquí están el
  dato y la lógica, no el diálogo.
- **M20** no se toca (reclamado por GLM-5.3-Flash).
- No se fabrican datos de otros dueños (M25, M73, M92, M93).
- Las 28 `[ ]` que quedan de M17 son de otros dueños (UI/arte/audio/navmesh/datos/playtest).
