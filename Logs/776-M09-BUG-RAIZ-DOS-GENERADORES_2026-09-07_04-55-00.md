# Log 776: M09 — BUG RAÍZ de la isla 10×: dos generadores competían

**Fecha:** 2026-09-07
**Hora:** 04:55
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Diagnóstico definitivo del feedback del usuario ("las montañas impostoras están sobre el agua" + "tengo que cruzar arena, agua clara y agua profunda para llegar a las montañas, nada que ver con mi isla"): **había DOS generadores de terreno compitiendo**. `world_manager.gd` creaba un `VoxelGeneratorNoise2D` (ruido plano, sin isla) + una BlockyLibrary de 2 modelos (aire+cubo) que PISABA el `WorldGenerator` real (isla 10×, biomas, montañas) que instala `main_island.gd`. Según el orden de _ready, el terreno voxel real podía quedar generado por el ruido plano: por eso el spawn caía en un lóbulo de tierra separado de las montañas por mar (forma de cruasán), y el impostor (que sí usa el generador real) mostraba montañas "sobre el agua".

## Cambios Realizados
- `world_manager.gd` REESCRITO: ya NO crea generador ni mesher ni librería — solo aplica el material de vertex color. El generador real (WorldGenerator island 10×) y la BlockyLibrary de 26 bloques de biomas los instala únicamente `main_island.gd` (`_conectar_terreno`). Documentado el motivo en el header del script.
- Con esto, terreno voxel real + TerrainLocator + impostor + spawn usan TODOS la misma fuente de verdad (WorldGenerator semilla 42, r 2560, max_height 90).

## Evidencia
- Boot final: `[WorldManager: Setup completado (solo material — sin generador competidor)]` + `[M163] Chaman del Monte spawneado en (2320.0, 37.0, 2300.0)` — el chamán sobre la montaña a Y=37 confirma que los CHUNKS REALES ahora usan las alturas del generador real (antes caía a Y=17 con las alturas del noise).
- FPS 60; gaviotas aterrizando y despegando (fauna viva en el spawn).
- Diagnóstico del usuario que cerró el caso: "llegué a las montañas impostoras y ahí hay solo agua, están sobre el agua" — el impostor (muestrea el generador REAL) no coincidía con el terreno voxel (generado por el NOISE).

## Lección crítica para 07-GUIA-GODOT §8
- **Un solo dueño por recurso del motor**: VoxelTerrain.generator debe tener UN único escritor. Dos scripts que lo configuran (aunque sea "para probar") producen estados dependientes del orden de _ready — bug intermitente e indeterminista. Si un script hermano necesita configurar el terrain, que lo haga SIEMPRE el mismo (aquí main_island.gd).

## Archivos Modificados
- `game/isla-ancestral/scripts/world/world_manager.gd` (solo material; generador/mesher eliminados)
- `Logs/776-M09-BUG-RAIZ-DOS-GENERADORES.md`
