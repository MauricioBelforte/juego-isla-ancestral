# Log 781: M09 iter. — impostor en tiles con fade progresivo por distancia

**Fecha:** 2026-09-07
**Hora:** 05:30
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Implementación del pedido del usuario: "¿no se podrá desactivar progresivamente a medida que me acerco?" — el impostor ahora se divide en **121 tiles de 128m**, cada uno con transparencia animada por CPU según la distancia del jugador al tile: invisible a menos de 1100m, fundido progresivo 1100-1800m, pleno a más de 1800m. Cerca del jugador mandan los chunks voxel reales detallados; lejos, el impostor dibuja las montañas de la isla.

## Cambios Realizados
- `terreno_horizonte.gd`:
  - Construcción: ahora cachea alturas por celda (`_alturas_celda`) durante el incremental y `_finalizar()` crea **tiles de 128m** (121 MeshInstance3D), cada uno con su StandardMaterial3D en modo `TRANSPARENCY_ALPHA`.
  - `_process()`: cada 0.25s actualiza `albedo_color.a` de cada tile por distancia (barato: 121 cálculos) y `visible=false` si alpha ≈ 0 (los tiles cercanos ni se dibujan).
  - Guard anti-spam: `_finalizar()` limpia `_st` para no re-ejecutarse cada frame (el run anterior lo llamaba 40+ veces por frame acumulando mensajes).
  - cast_shadow OFF en los tiles (la sombra doble con el terreno real se veía sucia).
- Escalera voxel mantenida del Log 780 (quads planos por celda de 16m, sin interpolación).

## Evidencia
- Boot: `[M09-Horizonte] 121 tiles de 128m creados — fade progresivo activo` — 1 sola vez (anti-spam verificado).
- FPS 60; el fade se puede calibrar con `DIST_VISIBLE_MIN/MAX` (constantes).

## Nota
- Con el mundo 10× (r 2560), el impostor cerca del player r 700 alrededor de (2660,2580): los tiles cercanos al SPAWN (3860,3860 → dist ~1754) quedan en pleno visibilidad — si el usuario prefiere ver solo chunks reales desde el spawn, subir DIST_VISIBLE_MIN/MAX.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (tiles + fade progresivo + anti-spam)
