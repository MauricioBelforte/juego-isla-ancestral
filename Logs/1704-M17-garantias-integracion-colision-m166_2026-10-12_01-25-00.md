# Log 1704: M17 - garantias de integracion verificadas (4 items) + colision con M166

**Fecha:** 2026-10-12
**Hora:** 01:25
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 154): M17 integraciones con hooks listos. De los items de
K y M, 4 se pudieron verificar con suite propia. **M17: 72 -> 76 `[x]` / 175.**

## Cambios Realizados

Suite nueva `test_construccion_iter6.gd` (23 checks, 0 fallos, 3 bloques):

| Item | Que se verifico |
|---|---|
| K181 (M71) | `pieza_colocada(receta_id, celda)` y `pieza_demolida(receta_id, celda)` con argumentos utiles; `navmesh_delta` con las celdas tocadas al colocar y al demoler |
| K180 (M32) | Cero hooks de clima en `scripts/construccion/` y ninguna API de clima en el manager: la lluvia agrega VFX desde M32 y no puede tocar piezas |
| M201 (dirty flags) | `escribir_voxel`/`borrar_voxel` puntuales: 2 piezas en celdas distintas = exactamente 2 celdas escritas |
| M202 (sin regeneracion global) | Ninguna llamada a `regenerate(`/`rebuild(`/`remesh(`/`regenerar(`; el terrain espia no recibio regeneraciones |

**Falso positivo propio corregido:** el primer chequeo de "regenerar" matcheaba el
parametro `regenerar_id` de `resultado_ok()`. Endurecido exigiendo la llamada con
parentesis.

## COLISION CON OTRO AGENTE (reportada al director)

`test_construccion_iter2.gd` y `test_construccion_iter3.gd` **no compilan**:
`Compile Error: Identifier not found: AssetProfile`. La referencia
`AssetProfile.ruta(...)` esta en `build_ghost.gd:96` y la clase `AssetProfile` **no
existe** en el repo. El diff muestra que ese bloque llego con el trabajo de M166
("capa B" de assets), no con mis cambios (los mios en ese archivo son el fix de
`ocultar()`).

Estado de suites: `test_construccion.gd` (131 checks) e `iter6` (23 checks) pasan;
`iter2` e `iter3` no compilan. No toque esos archivos: son del agente de M166.

## Verificacion

```
test_construccion_iter6.gd   23 checks, 0 fallos, 3 bloques   (nueva)
test_construccion.gd        131 checks, 0 fallos, 12 bloques
test_construccion_iter2.gd  NO COMPILA (AssetProfile, ajeno)
test_construccion_iter3.gd  NO COMPILA (AssetProfile, ajeno)
```

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/construccion/test_construccion_iter6.gd` (nueva)
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (4 flips + nota)
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` (Notas del Agente)

## Lo que queda en M17 (98 `[ ]`)

Integraciones que dependen de otros modulos (M18 ampliaciones, M25 ruinas, M73
festivales, M31 luces, M93 metas) y optimizaciones que necesitan escena real
(raycast por frame, batching, presupuesto de preview con profiler). El unico
nucleo-implementable que quedaba era M08 (capa voxel separada) y **no corresponde**:
`escribir_voxel` escribe en el canal de bloques del terreno, no en una capa aparte.
