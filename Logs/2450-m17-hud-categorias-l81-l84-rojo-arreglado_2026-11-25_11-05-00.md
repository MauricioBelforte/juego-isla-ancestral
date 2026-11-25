# Log 2450: M17 Construccion — tanda P6 "HUD de categorias" (L81 + L84) y el rojo pre-existente ARREGLADO

**Fecha:** 2026-11-25
**Hora:** 11:05
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Tercera tanda de la sesión sobre **M17-Construccion**. El objetivo era el **rojo pre-existente** que
yo mismo había documentado en el Log 2446 como "deuda ajena": `tests/test_m17_categorias.gd`
(24 checks, 3 fallos).

**Diagnóstico:** el rojo no era un falso positivo del test ni una deuda fuera de alcance: la suite
(excrita por DS-V4.1-Flash-Opencode el 2026-11-11 para el ítem **L84**) exigía
`BuildHudModel.filas_categorias(...)` y **esa API nunca se implementó**. El ítem era real.

**Implementado y verificado:**
- `BuildHudModel.filas_categorias(mgr, modo)` + `texto_categorias(mgr, modo)` (nuevas): las 4
  categorías canónicas en orden (sin saltar filas aunque una esté vacía), con `cantidad` (recetas
  del **catálogo**) y `cantidad_modo` (piezas **disponibles en el modo** pedido, filtro real por
  `es_mueble`), tolerante a manager nulo o sin el método.
- Suite nueva `tests/test_m17_hud_categorias.gd` → **22 checks, 0 fallos, EXIT 0**, con **watchdog
  de 120 s**.
- **El rojo pre-existente queda arreglado:** `test_m17_categorias.gd` → **24 checks, 0 fallos**.

**M17: 144 → 146 de 175** (quedan 28 `[ ]` + 1 `[?]`).

## Hallazgo de método (importante)

Al hacer la prueba ROJO-VERDE, la suite **se colgaba** (EXIT 124) en vez de fallar: un error
temprano abortaba el bloque antes de llegar a `quit()`, y el `SceneTree` quedaba vivo para siempre.
Es el mismo fallo que DS-V4.1-Flash-Opencode corrigió en `test_m17_suites_integracion.gd` (§9.5).
**Corrección aplicada:** watchdog con `autostart` + `add_child` (no `start()` antes de estar en el
árbol) y guards para que ningún acceso fuera de rango reventara el bloque. Con eso, el rojo sale
**limpio**: 22 checks / 10 fallos / EXIT 1.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/construccion/build_hud.gd` | `static func filas_categorias(mgr, modo)` y `static func texto_categorias(mgr, modo)`. |
| `game/isla-ancestral/tests/test_m17_hud_categorias.gd` (NUEVO) | **22 checks** + watchdog de 120 s + guards anti-cuelgue. |
| `.github/workflows/quality.yml` | Cableadas las DOS suites de categorías/HUD (la de L84 nunca estuvo cableada y por eso su rojo no frenó el CI). |
| `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` | Nueva sección **§12** (diagnóstico, qué se añadió, ítems cerrados, ROJO-VERDE, mediciones del catálogo). |
| `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` | **L81** y **L84** → `[x]` con evidencia; Totales **146/28/1**; se restauró la traza de Totales de los lotes 143 y 144 (mis reemplazos la habían pisado) y se corrigió la nota que daba el rojo por "ajeno": **ya está arreglado**. |
| `CHECKLIST-GLOBAL.md` | Fila 17: **146/175**, nota de la tanda. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2450** consumido. |

## Evidencia (Godot 4.7.2 headless, binario real)

| Suite | Checks | Fallos | EXIT |
|---|---|---|---|
| `tests/test_m17_hud_categorias.gd` (NUEVA) | 22 | 0 | 0 |
| `tests/test_m17_categorias.gd` (rojo pre-existente, **ARREGLADO**) | 24 | 0 | 0 |
| `tests/test_m17_almacenamiento.gd` (Log 2446) | 33 | 0 | 0 |
| `tests/test_m17_materiales_compartidos.gd` (Log 2447) | 13 | 0 | 0 |
| `tests/test_m17_construccion_validacion.gd` | 44 | 0 | 0 |
| `tests/test_m17_reglas_pieza.gd` | 40 | 0 | 0 |
| `tests/test_m17_circulacion.gd` | 36 | 0 | 0 |
| `tests/test_m17_persistencia_rejilla.gd` | 23 | 0 | 0 |
| `tests/test_m17_suites_integracion.gd` | 17 (501 en las 7 suites) | 0 | 0 |
| `scripts/construccion/qa_m17_modo.gd` | 9 | 0 | 0 |
| `scripts/construccion/test_construccion_iter3.gd` | 138 | 0 | 0 |

**ROJO-VERDE:** con `filas_categorias()` stubbeada a `[]` → mi suite **22 checks / 10 fallos /
EXIT 1** (sin cuelgue) y la suite heredada de L84 → **24 checks / 2 fallos / EXIT 1**. Restaurada:
22/0 y 24/0, ambas EXIT 0.

## Mediciones reales del catálogo (Q3)

| Dato | Valor |
|---|---|
| Recetas del catálogo | **46** |
| Por categoría (todas) | estructura **26** · mobiliario **4** · iluminacion **3** · decoracion **13** |
| Por modo (filtro `es_mueble`) | CONSTRUCCION **25** · DECORACION **21** (conjuntos disjuntos) |

## Lo que NO se hizo (honestidad)

- **M20** no se toca (reclamado por GLM-5.3-Flash el 2026-11-25 09:56).
- No se fabrican datos de otros dueños (M25 ruinas, M73 recetas de festival, M92 tabla de costos).
- El ítem `[?]` de M17 (la demolición de piezas funcionales libera su contenido: `build_interaction.gd`
  no existe) sigue siendo **deuda de M18**: es código de interacción, no de núcleo de M17.
- El HUD **pinta** estas filas a través de la UI real de M18: lo implementado aquí es el **modelo**
  (núcleo puro), no los nodos de UI.
