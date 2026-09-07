# Log 758: M09 iter. — impostor de terreno para las montañas a lo lejos

**Fecha:** 2026-09-07
**Hora:** 22:30
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Solución definitiva al problema del usuario: "las montañas del centro no se ven a lo lejos porque cargan pocos chunks". Se implementó un **impostor de terreno**: un mesh estático generado UNA VEZ en el arranque con las columnas reales del IslandGenerator (la forma exacta de las montañas), siempre visible. Al acercarse, los chunks voxel reales lo cubren (el impostor está al 97% de su altura, anti z-fighting). Sin skyline falso (Log 752 retirado) ni chunks extra.

## Cambios Realizados
- `scripts/world/terreno_horizonte.gd` (NUEVO): impostor data-driven del generador:
  - Grilla de 6m sobre la zona de montañas (centro 2660,2580, radio 520m) — 22.586 columnas h>12, ~270k triángulos.
  - Prisma por columna hasta height×0.97 con vertex colors por altura (césped → transición → piedra → cima clara).
  - Se genera con reintento diferido (12× 0.5s) tras la conexión del generador.
  - 1 draw call, cast_shadow ON (las montañas proyectan sombra correcta al amanecer/atardecer).
  - Optimización en el camino: primera pasada paso 4m/H_MIN 7 → 811k triángulos; ajustada a paso 6m/H_MIN 12 → 270k (−66%).
- `scenes/main_island.tscn`: nodo TerrenoHorizonte (id 20_horizonte) centrado en (2560,2560).
- Complementa la iteración anterior (Log 753): view_distance 2048 + lod_split_count 6 (chunks reales a ~2km) — el impostor solo cubre el gap visual entre el fin del LOD lejano y las montañas del centro.

## Evidencia Visual (capturas/9/)
- `cap_9_..._montana_real_420m.png` — montaña real h=36 a 420m (chunks reales + LOD).
- `cap_9_..._impostor_desde_spawn.png` — DESDE EL SPAWN (1460m): montaña de piedra gris con cima clara + valle + laguna interior turquesa + colinas escalonadas. FPS 60.
- `cap_9_..._impostor_optimizado.png` — versión optimizada (−66% triángulos), misma vista.
- Boot: `[M09-Horizonte] impostor listo: 22586 columnas (paso 6m, altura 0.97×)` — 0 errores.

## Hallazgos técnicos
- **Impostor anti z-fighting**: el mesh estático debe quedar POR DEBAJO del terreno real (×0.97) — al materializarse los chunks reales lo tapan limpiamente.
- **Costo del impostor**: proporcional al área × densidad; incluir valles bajos multiplica triángulos sin aporte visual (H_MIN 12 recorta el 66%).
- El impostor está centrado en las montañas (2660,2580), no en el centro geométrico (2560,2560) — el perfil del generador es irregular (Log 753).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (NUEVO)
- `game/isla-ancestral/scenes/main_island.tscn` (nodo TerrenoHorizonte)
- `game/isla-ancestral/scripts/world/captura_montanas_m51.gd` (temporal, ELIMINADO)
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` + `CHECKLIST-GLOBAL.md` (fila 49)
