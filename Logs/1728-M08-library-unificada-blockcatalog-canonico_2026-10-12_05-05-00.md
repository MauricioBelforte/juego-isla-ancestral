# Log 1728: M08 — VoxelBlockyLibrary unificada (BlockCatalog canónico)

**Fecha:** 2026-10-12
**Hora:** 05:05
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Unificación de la VoxelBlockyLibrary (encargo #27 del director mimo, deuda
técnica flagueada en el Log 1724): `BlockCatalog` es ahora la **fuente única y
canónica** de la library de bloques; `main_island.gd` deja de construir la
suya inline. M08: 105 → **108/108**.

## Cambios Realizados

- **block_catalog.gd (reescrito):** registra los 33 bloques (ids 0..32
  contiguos) y construye la library **en orden de id**, de modo que el índice
  del modelo == block id (invariante crítico: VoxelMesherBlocky usa el valor
  del canal CHANNEL_TYPE como índice). **Guarda de integridad:** si los ids
  no son contiguos desde 0, `push_error` + bake abortado (un hueco rompería el
  render silenciosamente). Tabla de colores canónicos con los colores afinados
  de la library vieja. `get_model_index(id)` ahora es `id` por construcción.
- **main_island.gd:** eliminada la library inline (45 líneas) + helper
  `_add_block` muerto; ahora usa `BlockCatalog.new().get_library()`.
- **island_generator.gd:** `get_debug_color()` tenía un dead path (el
  catálogo siempre es `null` en producción → crash si se llamaba); ahora tiene
  fallback a `BlockType.create_default(id).debug_color`.
- **test_block_catalog_m08.gd (nuevo):** 3 bloques con guardia anti-falso-verde
  — invariante índice==id + 33 modelos, get_block resuelve todos los ids con
  nombres, fallback de debug color sin catálogo (determinista).
- **M08 plan-actual:** 3 items nuevos en la sección B (unificación, invariante
  con guarda, consumo desde main_island) + Totales 108/108; nota completa en
  04-Codigo.md.

## Verificación (estática; Godot no ejecutable en el sandbox)

- Invariante índice==id verificado para los 33 modelos (parseo + cruce con
  ids de BlockType).
- **Sin regresión visual:** los 30 colores de la library vieja (HEAD de
  main_island.gd) son byte-identicos a la tabla canónica nueva.
- ids contiguos 0..32 sin faltantes; los 32 bloques no-aire tienen color
  canónico.
- Tests **no ejecutados** (sin Godot en el sandbox) — delegar a CI/headless.

## Archivos Modificados/Creados

- game/isla-ancestral/scripts/world/block_catalog.gd (reescrito)
- game/isla-ancestral/scripts/main_island.gd (modificado)
- game/isla-ancestral/scripts/world/island_generator.gd (modificado)
- game/isla-ancestral/scripts/world/test_block_catalog_m08.gd (nuevo)
- DOCUMENTACION/08-Mundo-Voxel/plan-actual/05-Checklist.md (modificado)
- DOCUMENTACION/08-Mundo-Voxel/plan-actual/04-Codigo.md (modificado)

## Restricciones respetadas

- NO se tocó CHECKLIST-GLOBAL.md. NO se hizo commit. UTF-8 puro + LF verificados.
- Libraries de harness ajenas (bench_recorder, preview_ruina, captura_playa)
  dejadas intactas a propósito — no renderizan el mundo.

## Deuda remanente (flagueada al director)

`bench_recorder.gd` (M61) arma su propia library para microbenchmarks. Es un
harness de perf autocontenido, pero si se quiere unificar TODO, es el último
punto. Fuera del alcance de este encargo.
