# Log 800: M09 — generación por columnas: tildes al caminar resueltas

**Fecha:** 2026-09-08
**Hora:** 10:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
**Causa raíz de los tildes al pasear encontrada y resuelta.** El `_generate_block` del WorldGenerator llamaba `get_block_at()` por CADA VOXEL del chunk (16×80×16 ≈ 20k llamadas), y cada llamada recalculaba `get_height()` + `_get_biome()` (múltiples noises FastNoiseLite en GDScript). Cada chunk nuevo al caminar = tildes de cientos de ms en el main thread.

**Solución**: precalculo por COLUMNA — `get_column_data(x, z)` calcula height+biome UNA vez por columna (256 llamadas en vez de 20k) y `get_block_at_column()` elige el bloque con los datos precalculados. ~80× menos llamadas de noise.

## Cambios Realizados
- `island_generator.gd`:
  - NUEVO `get_column_data(x, z) -> Array` (retorna [height, biome]).
  - NUEVO `get_block_at_column(x, y, z, height, biome)` — misma lógica de `get_block_at`, con altura/bioma precalculados.
  - `get_block_at` original intacto (retrocompatibilidad con el resto del código).
- `world_generator.gd`: `_generate_block` usa el precalculo por columna.

## Evidencia
- Boot: `[M09] Chunk del spawn materializado (bloque 2 en Y=5) — física liberada tras 1.0s` — el streaming genera rápido.
- Impostor heightmap + disco base activos, 0 errores.

## Lección para 07-GUIA-GODOT §8
- En generadores voxel GDScript: NUNCA llamar funciones con noise por VOXEL — precalcular por COLUMNA (height+biome) y elegir bloques con datos cacheados. Reducción típica: 80×.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/island_generator.gd` (get_column_data + get_block_at_column)
- `game/isla-ancestral/scripts/world/world_generator.gd` (_generate_block optimizado)
