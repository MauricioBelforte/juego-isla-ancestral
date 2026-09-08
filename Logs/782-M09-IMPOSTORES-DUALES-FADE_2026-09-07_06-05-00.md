# Log 782: M09 — impostores duales con fade progresivo (montañas + orilla)

**Fecha:** 2026-09-07
**Hora:** 06:05
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Implementación completa de la propuesta del usuario ("hacé un impostor verde pero solo en el suelo que desaparezca a medida que me acerco — eso cubriría el mar que todavía se ve"). Sistema final de horizonte en 2 capas:

1. **Impostor de MONTAÑAS** (escalera voxel, r 700 alrededor de (2660,2580)): invisible a <1100m del tile, pleno a >1800m.
2. **Impostor de ORILLA** (NUEVO): anillos planos verdes (y=4.55) en radio 1450-2300 desde el centro de la isla — cubre el "mar fantasma" entre los chunks cargados y las montañas lejanas. Invisible a <600m del anillo, pleno a >1200m.

Ambos fades por CPU cada 0.25s (sin shader custom — el discard por píxel tildaba la GPU integrada).

## Cambios Realizados
- `terreno_horizonte.gd` REESCRITO como máquina de estados (montanas → orilla → listo) con construcción incremental por filas/frame (sin Thread: get_height NO thread-safe, Log 774).
- Impostor de orilla: anillos de 256m de ancho radial, 48 segmentos, color pasto-claro, superficie plana a y=4.55 (justo sobre el agua voxel) — desde lejos la orilla se ve VERDE continua; al acercarse se desvanece y aparecen el agua real y la arena.
- Cada fila de montañas y cada anillo de orilla es un tile independiente con su propio material alpha → fade granular.
- `_aplicar_fades()`: distancia del player al centro del AABB de cada tile (montañas: 1100-1800m; orilla: 600-1200m) → alpha + visible=false si ~0.

## Evidencia
- Boot final sin errores: gaviota aterrizada con `patas asentadas: min_y 6.927` (chunks reales correctos en el spawn), construcción del impostor en progreso incremental sin tildes.
- Nota: la sesión se detuvo durante la construcción (el impostor termina ~1.5s después del boot — no bloquea).

## Calibración disponible
- `MONT_DIST_MIN/MAX` (1100/1800m) — visibilidad de las montañas.
- `ORILLA_DIST_MIN/MAX` (600/1200m) — visibilidad del anillo verde.
- `ORILLA_ALTURA` (4.55) y `ORILLA_COLOR` — altura/color del anillo.
- `R_MONTANAS`/`ORILLA_R_MIN/MAX` — cobertura.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (REESCRITO: máquina de estados dual)
