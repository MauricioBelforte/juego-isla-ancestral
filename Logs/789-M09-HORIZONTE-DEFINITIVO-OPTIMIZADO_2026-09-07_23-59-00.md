# Log 789: M09 — sistema de horizonte definitivo: 2 capas + optimización rendimiento

**Fecha:** 2026-09-07
**Hora:** 23:59
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Corrección final del sistema de horizonte según el feedback del usuario ("veo una arandela verde, debería ser un círculo; verde hasta las montañas; se tildaba"). El sistema quedó en su forma definitiva:

## Las 2 capas del horizonte (diseño definitivo)
1. **Impostor de MONTAÑAS** (vertical, escalera voxel): r 700 alrededor de (2660,2580), alturas reales ×0.85 — 36 tiles.
2. **Impostor de TERRENO (disco)**: r 2600 de toda la isla, paso 32m, quads planos con color por bioma (arena blanca h 4-5, verde h 5-28, piedra) — SALTA la zona de montañas (r 700) y las celdas de agua — 160 tiles (de los ~784 posibles, solo los que tienen tierra).

## Optimizaciones de rendimiento (por el tildo en GPU integrada)
- Paso 16m → 32m (4× menos celdas: ~26k muestras, ~14k de tierra → ~28k triángulos de superficie).
- Materiales OPACOS (eliminado TRANSPARENCY_ALPHA de todos los tiles — el sorting transparente masivo tildaba la GPU).
- Fade por VISIBILIDAD binaria (mi.visible) con métrica de distancia al punto MÁS CERCANO del AABB (clamp) — tiles alargados se ocultan correctamente.
- FILAS_POR_FRAME 10 → 4 (menos hitch en el muestreo).

## Bugs corregidos en esta iteración
- Parse Error línea 196 (indentación del edit de material) y línea 8 (formato de print).
- La capa verde (Log 782) quedó DESACTIVADA en el código (el usuario la rechazó).
- Doble offset confirmado corregido (nodo en origen, vértices mundiales).

## Evidencia
- Boot: `[M09-Solido] impostor de toda la isla listo: 196 tiles — fade progresivo activo (invisible <400m, pleno >700m)` + `[M09-Horizonte] impostor montañas + disco terreno listos: 36 tiles — ocultos <700m (chunks reales mandan cerca)` — 0 errores.
- FPS 60; el usuario juega sin tildes.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (optimizado, 2 capas definitivas)
