# Log 759: M09 iter. — terreno sólido de toda la isla (idea del usuario)

**Fecha:** 2026-09-07
**Hora:** 02:35
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
El usuario preguntó: "¿qué pasa si en vez de bloques es un terreno sólido?" — implementado EXACTAMENTE eso. El impostor de terreno (Log 758, que cubría solo la zona de montañas) se amplió a **toda la isla** como malla de alturas (heightmap mesh) de 83k triángulos generada una sola vez en el arranque. Ahora se ve el terreno de la isla completa desde cualquier punto — montañas incluidas — sin streaming de chunks lejanos. Los chunks reales detallados (minables) quedan solo cerca (1600m), con carga más rápida que antes.

## Cambios Realizados
- `terreno_horizonte.gd` REESCRITO como malla de superficie sólida:
  - Cubre TODA la isla: radio 2600 desde el centro (mundo 5120 completo).
  - Paso 16m: celda = quad superior con las 4 alturas reales del generador (interpoladas).
  - Solo columnas con h_prom ≥ 4 (el agua la cubre el plano animado; el fondo del mar se ve con el color del agua del shader).
  - Vertex colors por altura: arena (4-5) → césped (5-9) → transición (9-16) → piedra (16-27) → cima clara (27+).
  - 41.747 celdas = ~83.000 triángulos, 1 draw call. Anti z-fighting: al 0.97× de la altura real.
  - cast_shadow ON: las montañas lejanas proyectan sombra correcta.
- `main_island.gd`: `view_distance 2048 → 1600` y `lod_split_count 6 → 5` (los chunks detallados llegan a 1600m; más allá el impostor es el horizonte) — el streaming genera MENOS que antes → carga más rápida.
- Iteración intermedia descartada (view_distance 4096 + 8 LODs): el streaming a 4096m era demasiado pesado en generación — confirmó la intuición del usuario de que "los bloques reales cuestan recargar".

## La respuesta a la pregunta del usuario
"¿Qué pasa si en vez de bloques es un terreno sólido?" — Exactamente lo que hicimos: el terreno sólido (malla de alturas) es el horizonte SIEMPRE visible; los bloques voxel reales solo existen cerca del jugador donde se minan/construyen. Es el patrón estándar de juegos voxel grandes (LOD far-mesh + chunks near).

## Evidencia Visual (capturas/9/)
- `cap_9_..._terreno_solido_toda_isla.png` — vista desde el spawn (1460m de las montañas): valle con laguna interior, montaña de piedra gris con cima clara, todo el relieve de la isla al horizonte. FPS 60.
- Boot: `[M09-Solido] impostor de toda la isla: 41747 celdas (paso 16m) — ~83494 triángulos` — 0 errores.

## Tests
- Boot completo sin errores; FPS 60.
- No se modificaron sistemas con tests (config de streaming + mesh estático).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (reescrito: malla sólida de toda la isla)
- `game/isla-ancestral/scripts/main_island.gd` (view_distance 1600, lod_split_count 5)
- `game/isla-ancestral/scripts/world/captura_montanas_m51.gd` (temporal, ELIMINADO)
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` + `CHECKLIST-GLOBAL.md` (fila 09)
