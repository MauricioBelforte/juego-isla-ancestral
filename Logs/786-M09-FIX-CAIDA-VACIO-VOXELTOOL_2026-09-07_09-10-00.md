# Log 786: M09 — fix caída al vacío: física liberada solo cuando el chunk existe

**Fecha:** 2026-09-07
**Hora:** 09:10
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Fix del bug "aparecí arriba y luego debajo del agua / no me puedo mover": la física del jugador se liberaba con un **timer fijo de 8s**, pero en el mundo 10× el chunk voxel del spawn (r 3860) tarda más en materializarse → el jugador caía al vacío sin suelo (cámara bajo el agua, sin poder moverse). Reemplazado por **verificación real**: polling cada 0.5s con `VoxelTool.get_voxel()` hasta que el voxel de la superficie exista, con timeout de seguridad de 60s.

## Cambios Realizados
- `main_island.gd`:
  - `_liberar_fisica_player` (timer fijo 8s) → **`_verificar_chunk_y_liberar(player, sx, altura, sz, intento)`**: cada 0.5s consulta `terrain.get_voxel_tool().get_voxel(Vector3i(sx, altura, sz))`; si el bloque ≠ AIR (0), el chunk está materializado → libera física.
  - Timeout de seguridad: 120 chequeos (60s) → libera igual con warning (evita softlock).
  - Corregido en el camino: `get_voxel()` espera **Vector3i** (1 argumento), no 3 ints (parse error detectado en el primer boot).
- La verificación NO bloquea el hilo (polling por timer), el streaming sigue trabajando.

## Evidencia
- Boot: `[M09] Chunk del spawn materializado (bloque 2 en Y=27) — física liberada tras 1.0s` — el chunk existía en 1s con la firma corregida.
- El jugador aterriza sobre el terreno elevado por el boost (Y=27+3=30 al nacer, cae a 28 sobre el bloque).

## Lección para 07-GUIA-GODOT §8
- **Timer fijo para esperar streaming = bug intermitente**: el tiempo de materialización depende de la distancia al origen del mundo y de la carga. SIEMPRE verificar el voxel real con VoxelTool + polling con timeout.
- **VoxelTool.get_voxel firma**: `get_voxel(position: Vector3i) -> int` — un solo argumento Vector3i.

## Archivos Modificados
- `game/isla-ancestral/scripts/main_island.gd` (_verificar_chunk_y_liberar + firma Vector3i)
