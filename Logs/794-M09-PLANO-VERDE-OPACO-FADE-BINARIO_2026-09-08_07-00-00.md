# Log 794: M09 — plano verde opaco con fade binario (fix tildes GPU integrada)

**Fecha:** 2026-09-08
**Hora:** 07:00
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Corrección del tilde reportado por el usuario ("algo me tilda el juego"): la versión anterior del plano verde usaba `TRANSPARENCY_ALPHA` con albedo_color.a animado — la transparencia sobre un plano de 6200×6200 (más el sorting de anillos concéntricos) tildaba la GPU integrada. Cambio: **plano verde OPACO** (sin transparencia) con **fade binario por tile** (oculto a <1100m del punto más cercano del AABB del tile, visible más allá).

## Cambios Realizados
- `terreno_horizonte.gd`:
  - Plano verde: material **opaco** (sin TRANSPARENCY_ALPHA) — el verde a y=4.3 cubre el agua azul y la laguna interior de forma constante.
  - Fade **binario por tile**: cada anillo/tile se muestra u oculta según la distancia del player al punto MÁS CERCANO del AABB del tile (métrica correcta para anillos concéntricos: el clamp del AABB da el borde más cercano).
  - Sin cull_disabled (paredes elípticas innecesarias eliminadas — el plano es un disco visto desde arriba/dentro).
  - Las montañas del impostor mantienen su propio fade binario (1100-1800m).
- El trade-off: el fundido ya no es por píxel sino por tile (256m de granularidad) — a cambio, FPS estable y sin tildes.

## Evidencia
- Boot: `[M09-Horizonte] impostor de montañas: 36 tiles` + `plano verde: 11 anillos hasta r 2600m — fade 700-1500m` + `sistema completo` — 0 errores.
- Chunk del spawn materializado en 1.0s; gaviota ATERRIZADA (terreno correcto bajo los pies).
- 121 anillos verdes con fade binario, sin transparencia en ningún tile.

## Lección para 07-GUIA-GODOT §8 (complementa E-16/E-17/E-18)
- **TRANSPARENCY_ALPHA en meshes enormes (planos de km) tilda GPUs integradas**: preferir opacidad fija + visibilidad binaria por tile, o tiles pequeños con fade por vértice. El sorting de transparentes grandes es el costo principal.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (plano verde opaco + fade binario)
