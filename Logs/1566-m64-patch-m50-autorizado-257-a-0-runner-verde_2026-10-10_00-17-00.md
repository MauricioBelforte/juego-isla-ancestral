# Log 1566: M64 / BUG-129 — patch M50 autorizado aplicado, 257 → 0 strays medido, runner verde y test M110 reescrito en UTF-8

**Fecha:** 2026-10-10
**Hora:** 00:17
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Se aplicó el patch de 1 línea autorizado por el director (msg 93 del canal) en
`vegetation_spawner.gd` (M50) — `inst.free()` en el descarte `h < 3` —, con lo
que BUG-129 queda cerrado en sus dos mitades: 257 → 0 huérfanos del boot
(medido, no inferido). Además se reescribió el test de huérfanos del M110
(`tests/unit/debug/test_debug_menu.gd`) en UTF-8 sin BOM, restaurando el helper
`_limpiar_huerfanos_boot()` que el director había revertido por mojibake. El
runner completo da EXIT 0: 29/29 suites · 1267 tests · 0 fallos.

## Cambios Realizados

### 1. Patch M50 (autorizado en msg 93, "aplícalo tú")

- `scripts/vegetacion/vegetation_spawner.gd` — en `_poblar()`, rama `if h < 3:`
  (filtro BUG-022, línea ~87): agregado `inst.free()` antes de `continue`.
- Causa: `res.instantiate()` (L79) creaba la instancia SIEMPRE; el descarte
  "en agua" la soltaba sin liberar → 44 nodos raíz `50-Vegetacion_*.glb` +
  ~157 mallas = los 201 strays restantes (los otros 56 eran estados de IA, ya
  fixeados en Log 1550 con `register_state()` parenteando).

### 2. Medición A/B final (binario real 4.7.2, criterio del msg 89)

Harness `scripts/ia_npc/test_bug129_estados_orphan.gd`:

| Momento | total_strays | states | mesh | node3d | exit |
|---|---|---|---|---|---|
| Antes de ambos fixes (boot real, 7 NPCs) | 257 | 56 | 157 | 44 | 1 |
| Fix de estados (Log 1550) | 201 | 0 | 157 | 44 | — |
| **Con patch M50 (esta ronda)** | **0** | **0** | **0** | **0** | **0** |

- `npc_manager_agents=7` — los NPCs cargan normal; el fix no rompe el boot.
- Sin SCRIPT ERROR en stderr.

### 3. Verificaciones de no-regresión

- Regresión M64 (`test_ia_npc_m64_iterN.gd`): **82 checks, 0 fallos, EXIT 0**.
- Suite GdUnit4 `tests/unit/debug` **SIN helper** (raíz fixeada): 3/3 PASSED ·
  **0 orphans** · EXIT 0 → prueba de que el fix es raíz y no parche en test.
- Suite GdUnit4 `tests/unit/debug` **CON helper** (test reescrito): 3/3 PASSED ·
  **0 orphans** · EXIT 0.
- **Runner completo** (`res://tests/run_tests.gd`): **EXIT 0** · 29/29 suites ·
  1246 checks SceneTree + 21 test cases GdUnit4 = **1267 tests, 0 fallos** ·
  `[OK] rc=0 GdUnit4: 21 test cases, 0 errors, 0 failures`.

### 4. Test M110 reescrito en UTF-8 sin BOM (pedido del msg 93)

- `game/isla-ancestral/tests/unit/debug/test_debug_menu.gd`: restaurado el WIP
  de stepfun-step-5-preview (helper `_limpiar_huerfanos_boot()` + 2 call sites
  con `await process_frame`), que el director había revertido por mojibake y
  parse error (L44/L79 a columna 0).
- Verificado: primeros bytes `101 120 116` (`ext`) = **sin BOM**; 0 tokens de
  mojibake; 77 líneas; sin parse errors.
- Comentario de cabecera actualizado con el estado de fix raíz (el helper ya no
  encuentra huérfanos; se conserva como red de seguridad verificable).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/vegetacion/vegetation_spawner.gd` (patch +1 línea)
- `game/isla-ancestral/tests/unit/debug/test_debug_menu.gd` (reescrito, UTF-8 sin BOM)
- `DOCUMENTACION/11-BUGS.md` (entrada BUG-129: línea de cierre de deuda raíz, sin tocar marcas)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada de cierre)
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` (seguimiento)
- Informe de cierre en el canal (msg siguiente a 93)

## Notas

- Sin commits/stage/push (regla de la flota; los ejecuta el director).
- READ-ONLY sobre marcas de checklists: los resultados se reportan, los flips
  los aplica el director (regla permanente del msg 91/93).
- El stderr del runner muestra mojibake de consola (`Ã‰XITO` = É en latin-1 del
  stream redirigido) — es el codepage de la consola de Windows al redirigir
  stdout, no corrupción de archivos (los archivos verifican UTF-8 limpio).
