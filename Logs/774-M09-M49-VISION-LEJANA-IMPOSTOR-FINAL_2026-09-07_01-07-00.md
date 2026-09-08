# Log 774: M09/M49 — visión lejana: impostor incremental, montañas de 90m y niebla reducida

**Fecha:** 2026-09-07
**Hora:** 01:07
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Sesión de diagnóstico y corrección del problema "no se ven las montañas de mi isla a lo lejos" (varias iteraciones con feedback del usuario). Causas reales encontradas y corregidas:
1. **Niebla del environment demasiado densa** (fog_density 0.0009 → a 1460m todo estaba fundido en niebla al 70%+): reducida a 0.00018 (horizonte claro como Minecraft).
2. **Impostor pisa los chunks reales cerca del jugador**: resuelto con reducción de su cobertura a la zona de montañas (r 700 desde (2660,2580)) + ocultamiento por distancia (>1600m de las montañas → visible; <1600m → los chunks reales lo cubren).
3. **Montañas bajas en proporción a la isla 10×** (36m en un mundo de 5120): elevadas a max_height 90 (el escáner confirmó ~80 reales).
4. **Tildes del juego**: (a) Thread con IslandGenerator.get_height() NO thread-safe mientras el streamer genera chunks → race de datos; reemplazado por construcción INCREMENTAL por filas en el main thread (6 filas/frame). (b) Shader fade por píxel con discard tildaba la GPU integrada → eliminado, fade por CPU (1 chequeo/frame).
5. **Caída doble del personaje**: el ajuste de spawn se ejecutaba 2 veces → guard `_spawn_ajustado = true` ANTES de posicionar.
6. **Impostor liso sobre chunks reales (valle)**: cobertura reducida a solo montañas (r 700, H_MIN alto implícito) — el valle/orilla queda para chunks reales + agua.

## Cambios Realizados
- `main_island.gd`: max_height 40→90; fog_density 0.0009→0.00018; guard anti doble-spawn; view_distance 2048 (restaurado tras probar 4096/1600).
- `scripts/world/terreno_horizonte.gd` (REESCRITO, impostor incremental): filas de 16m por frame (FILAS_POR_FRAME=6), sin Thread (race documentada), solo zona de montañas (CENTRO_MONTANAS 2660,2580, r 700), ocultamiento por distancia CPU (>1600m visible), colores por bioma.
- `shaders/terreno_horizonte.gdshader` (creado y luego ELIMINADO): el discard por píxel tildaba la GPU integrada — el fade por CPU es equivalente y gratis.
- `scripts/world/escanear_montanas_m09.gd` (herramienta): escaneo de 7056 muestras del generador.
- Skyline anterior ya retirado (Log 753), archivado en Obsoletos.

## Evidencia
- Boot final: `[M09-Horizonte] impostor de montañas listo: 7744 columnas — ~15488 triángulos (construcción incremental, sin tildes)` — 0 errores, sin deadlocks.
- `[M163] Chaman del Monte spawneado en (2320.0, 37.0, 2300.0)` — montañas de ~80 confirmadas en runtime.
- FPS 60 en todas las capturas de verificación.
- Log de diagnóstico eliminado tras confirmar `dist_montanas=1755 visible=false` (lógica correcta desde el spawn).

## Lecciones para 07-GUIA-GODOT §8
- **IslandGenerator/VoxelGenerator NO thread-safe**: nunca llamar get_height() desde un Thread mientras el streamer esté activo. Construcción incremental por frames es el patrón seguro.
- **Shaders con discard por píxel en meshes gigantes** tildan GPUs integradas — el fade por distancia de objetos grandes debe hacerse por CPU (visible/invisible) o por vértice.
- **fog_density en mundos grandes**: densidad visible debe calcularse como < 1/(3×distancia_objetivo). A 0.0009 nada sobrevive más allá de 800m.

## Pendientes (siguiente iteración)
- Captura final de confirmación visual del usuario (el impostor de montañas de 90m desde el spawn).
- La niebla podría calibrarse aún más fina por franja horaria (amanecer más denso, mediodía claro).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/main_island.gd` (max_height 90, fog 0.00018, guard spawn)
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (impostor incremental final)
- `game/isla-ancestral/scripts/world/escanear_montanas_m09.gd` (herramienta)
- `game/isla-ancestral/shaders/terreno_horizonte.gdshader` (creado→eliminado)
- `game/isla-ancestral/scripts/world/captura_fog_m49.gd` + `captura_montanas_m51.gd` (temporales, ELIMINADOS)
- `game/isla-ancestral/project.godot` (autoloads temporales limpiados)
- `CHECKLIST-GLOBAL.md` (fila 49)
