# Log 563: BUG-021 RESUELTO — causa raíz: Debugger Break por propuesta inexistente (full_load_distance) + horizonte 512

**Fecha:** 2026-09-03
**Hora:** 05:55
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

**Causa raíz del "nunca carga":** la línea `mesher.full_load_distance = 256.0` que había quedado del intento anterior — **la propiedad `full_load_distance` NO existe en `VoxelMesherBlocky`** → `Debugger Break` ("Invalid assignment...", `debug>` esperando input) → el juego quedaba congelado en el splash SIN importar el view_distance. El "colapso" de la madrugada era esto, no la generación de chunks.

## Solución (aplicada y verificada)

1. **Quitada** la línea inválida (`scripts/main_island.gd:159`).
2. **view_distance = 512** (el horizonte doble pedido) + `terrain.lod_split = 2` + `terrain.lod_distance = 200.0` (cubos 2x lejos — la idea del usuario de "cubos con otra forma a lo lejos").
3. **Verificación visual (captura 05:55):** el juego carga a **FPS 59**, la **isla completa visible desde el spawn** (terreno hasta el horizonte + mar turquesa lejano + árboles), sin cortes a media distancia.

## Archivos Modificados/Creados

- Modificados: `scripts/main_island.gd` (sin full_load; view 512 + LOD), `Logs/ULTIMO_NUMERO.txt` (→563)
- Captura: `tools/mcp/godot-mcp/capturas/10-Mundo-Voxel/cap_10_2026-09-03_05-55-00_sin_break.png`

## Estado del bug

- BUG-021: **Resuelto** (pending actualización de 11-BUGS.md con este log).
