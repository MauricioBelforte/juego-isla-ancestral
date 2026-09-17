# Log 801: M09 — spawn sin get_voxel bloqueante (causa del freeze al volar)

**Fecha:** 2026-09-08
**Hora:** 10:35
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
**CAUSA RAÍZ del freeze al volar encontrada**: el chequeo del spawn usaba `VoxelTool.get_voxel()` — y esta consulta **fuerza la generación SINCRÓNICA del chunk en el main thread**. En el mundo 10× con montañas de 600m (boost 6.0), generar un chunk de 600m de columna bloquea el main thread decenas de segundos. Al volar, cada movimiento generaba nuevos chunks → cada uno otro bloqueo sincrónico → freeze perpetuo.

El warning `Waiting for all tasks to be picked is taking a long time` del log es exactamente el main thread esperando a los workers del streaming saturados.

## Solución
- Eliminado el chequeo `get_voxel` del spawn (función `_verificar_chunk_y_liberar` completa).
- En su lugar: física congelada 10s (tiempo suficiente para el streaming inicial) + **el suelo fantasma del player (get_height O(1)) sostiene al jugador SIEMPRE** — nunca cae al vacío aunque los chunks tarden (Logs 787/788, E-17/E-18).
- Complementado con: `lod_split_count 5`, `view_distance 1024` (Log 789) — menos chunks por streaming.

## Evidencia
- Boot: `Chunk del spawn materializado` reemplazado por spawn limpio sin bloqueos; chamán, gaviota aterrizada, impostor 42 tiles — todo normal.
- main_island.gd + 3 scripts más verificados sintácticamente (OK).

## Regla crítica para 07-GUIA-GODOT §8 (complementa E-17)
- **NUNCA usar VoxelTool.get_voxel/set_voxel en el main thread sobre chunks no materializados** — fuerza generación sincrónica. El suelo fantasma con get_height (O(1), sin I/O) es el mecanismo correcto.

## Archivos Modificados
- `game/isla-ancestral/scripts/main_island.gd` (spawn await 10s + función eliminada)
