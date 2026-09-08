# Log 790: M09 — disco verde funcionando (12.941 celdas) + montañas de ~600m

**Fecha:** 2026-09-07
**Hora:** 21:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Dos fixes sobre el feedback del usuario ("NO VEO NINGUN IMPOSTOR... el disco quedó debajo o en otro lugar" + "el verde impostor tiene forma de arandela"):

1. **Disco verde funcionando**: el disco iteraba una grilla propia (paso 16 desde x=460) que NO coincidía con las claves del cache de alturas (paso 32 desde -40) — todas las consultas fallaban → 0 celdas. Fix: el disco ahora itera DIRECTAMENTE las claves del cache (agrupando por tile de 256m), con la altura cacheada en su offset de muestreo real (+8 centro de celda).

2. **Arandela eliminada**: el disco dibuja TODAS las celdas de tierra del disco (r 0-2100), excepto la zona de montañas (r 700 de (2660,2580)) que la cubre el impostor vertical — el usuario ve verde continuo hasta las montañas.

3. **Montañas visibles de verdad**: el noise de forma de esta semilla rara vez supera 0.2, por eso max_height 250 daba picos de solo 36m. Agregado `max_height_boost` al WorldGenerator (se propaga al IslandGenerator vía _get_island_gen — antes NO se propagaba): con boost 6.0 las montañas alcanzan ~600m (chamán a Y=595 confirmado).

## Estado final del horizonte (verificado en runtime)
- Impostor de montañas: 36 tiles (r 700 de (2660,2580)), alturas reales ×0.85 hasta ~570m.
- Disco de terreno: 243 tiles, 12.941 celdas — verde donde hay tierra, arena en playa, colores por bioma — salta zona de montañas y celdas de agua.
- Ambos ocultos <700m del player (los chunks reales mandan cerca), visibles más allá.
- Spawn: Y=81 sobre tierra (el terreno subió con el boost). FPS estable. 0 errores.

## Calibración
- `max_height_boost` (main_island.gd:147) — altura de montañas: 6.0 = ~600m. Bajar a 3.0 si se ven gigantes de cerca.
- `MONT_OCULTAR_UMBRAL` (700m) y `VERDE_DIST_MIN` (700m) — distancias de fade.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (disco itera el cache + helper _tile_mesh)
- `game/isla-ancestral/scripts/main_island.gd` (boost 6.0)
- `game/isla-ancestral/scripts/world/world_generator.gd` (propaga max_height_boost)
- `game/isla-ancestral/scripts/world/escanear_montanas_m09.gd` (escáner con boost)
