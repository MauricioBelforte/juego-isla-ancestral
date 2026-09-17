# Log 805: M49 — fix winding del anillo de arena (era invisible por cull)

**Fecha:** 2026-09-09
**Hora:** 05:15
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Fix del anillo de arena que el usuario no veía: mismo bug de winding que el abanico del disco (Log 790) — el orden de vértices (q00, q01, q11) da normal hacia abajo con cull_back → invisible desde arriba.

## Solución
Orden corregido: (q00, q11, q01) + (q00, q10, q11) — antihorario visto desde arriba → normal hacia arriba → superficie visible.

## Evidencia
- Boot: `disco base de fondo marino: r 1801m a y=4.30` — 0 errores.
- Gaviotas aterrizando normalmente — el juego corre estable.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (winding del anillo)
