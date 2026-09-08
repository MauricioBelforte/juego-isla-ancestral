# Log 787: M09 — suelo fantasma del generador: nunca más caída al vacío

**Fecha:** 2026-09-07
**Hora:** 09:25
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Fix definitivo del bug "me volví a buguear, caigo sin poder moverme": el jugador puede CAMINAR fuera de los chunks materializados (el streaming no alcanza a generar a la velocidad de caminar). Ahora el `_physics_process` del Player tiene un **suelo fantasma**: si está cayendo por debajo de la altura PRECALCULADA del generador (`get_height` — el mismo perfil que dibuja el impostor y spawnea todo), lo sostiene ahí hasta que el chunk real materialice.

## Cómo funciona
- En cada frame de física: si `_on_ground == false` y `velocity.y < -5` (cayendo rápido), consulta `island_gen.get_height(x, z)` del terreno real.
- Si el jugador está más de 1m por debajo de esa altura → se apoya (`global_position.y = h`, velocity 0, `_on_ground = true`).
- El acceso al generador es la MISMA instancia que usa el VoxelTerrain (`_terrain.generator._get_island_gen()`) — cero costos extra de creación.
- Cuando el chunk real materializa, el `VoxelBoxMover` colisiona con los bloques reales y el suelo fantasma deja de actuar (queda solo como red de seguridad).

## Cambios Realizados
- `scripts/player/player.gd`:
  - Bloque anti-caída en `_physics_process` (tras el cálculo de `_on_ground` del box mover).
  - Helper `_generador_isla()` con acceso seguro al generador.

## Evidencia
- Boot estable sin errores/Debugger breaks (el fix anterior de VoxelTool funciona: `Chunk del spawn materializado (bloque 2 en Y=27) — física liberada tras 1.0s`).
- El suelo fantasma se activa solo al caminar hacia zonas sin streamer — el resto del tiempo no interviene.

## Lección para 07-GUIA-GODOT §8 (complementa E-17)
- El polling del spawn (Log 786) cubre el ARRANQUE; el suelo fantasma cubre el MOVIMIENTO continuo. Ambos necesarios en mundos grandes con streaming móvil.

## Archivos Modificados
- `game/isla-ancestral/scripts/player/player.gd` (suelo fantasma + helper)
