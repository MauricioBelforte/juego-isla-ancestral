# Log 783: M09 — restauración del impostor aprobado (capa verde retirada)

**Fecha:** 2026-09-07
**Hora:** 06:57
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
El usuario rechazó la capa verde de orilla del Log 782 ("lo arruinaste, ahora se ve pura agua alrededor y las montañas desaparecieron") y pidió volver al estado aprobado: "las montañas impostoras tenían que seguir ahí como estaban y desaparecer cuando me acercaba". **Impostor restaurado EXACTAMENTE al estado del Log 781** (el que el usuario aprobó) y capa verde retirada por completo.

## Cambios Realizados
- `terreno_horizonte.gd` RESTAURADO al estado Log 781: impostor de montañas (escalera voxel, r 700 sobre (2660,2580)), 121 tiles de 128m, fade progresivo (invisible <1100m del tile, pleno >1800m), construcción incremental por filas, guard anti-spam, coords mundiales (nodo en origen, fix Log 778).
- Capa verde de orilla ELIMINADA por completo (anillos + fades de orilla).
- `max_height` restaurado a 40 (el 90 fue parte de la iteración rechazada — el chamán volvió a Y=17).
- Warnings limpiados en el camino: `_st` sin usar eliminado, formato de print `%.0f` corregido.

## Lección (para el registro del agente)
- Cuando una iteración nueva se rechaza, la restauración debe ser EXACTA al estado aprobado (no "parecido"): en este caso reescribí el archivo completo al estado del Log 781 en vez de parchar encima de la versión dual.
- La capa verde falló por diseño (los anillos planos a y=4.55 sobre el agua se veían como agua-color-Verde desde lejos, y las montañas se perdían detrás) — no por implementación. Si se reintenta en el futuro, la lección es: el usuario quiere MONTAÑAS en el horizonte, no plano verde.

## Evidencia
- Boot final: `[M09-Horizonte] impostor restaurado (Log 781): 121 tiles de 128m — fade 1100-1800m activo` — 0 errores, 0 warnings nuevos.
- `[M163] Chaman del Monte spawneado en (2320.0, 17.0, 2300.0)` — alturas restauradas (max_height 40).
- FPS 60; gaviota aterrizada (min_y 5.927 = chunks reales correctos).

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (restaurado a Log 781)
- `game/isla-ancestral/scripts/main_island.gd` (max_height 40)
- `CHECKLIST-GLOBAL.md` (fila 09)
