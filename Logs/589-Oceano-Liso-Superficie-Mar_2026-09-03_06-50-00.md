# Log 565: Océano liso (M51/M09) — superficie del mar + fixes (vertical/borde)

**Fecha:** 2026-09-03
**Hora:** 06:50
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

El usuario reportó "fondo marrón oscuro" en el horizonte (era el lecho del océano sin superficie aguada apreciable). Se agregó una **superficie de océano lisa** (MeshInstance3D + PlaneMesh con material azul océano Maldivas) que cubre el mar. Durante la verificación se corrigieron 2 detalles: (1) el plano quedó VERTICAL (PlaneMesh en Godot 4 ya es horizontal — la rotación -90 sobraba); (2) el borde del plano de 2048 quedaba dentro del view 512 (franja marrón) → planeado a 4096 (borde fuera de rango visual).

## Cambios Realizados

- `scripts/main_island.gd` — `_crear_oceano()`: PlaneMesh 4096x4096, material Standard (albedo 0.10,0.45,0.75 — agua Maldivas; roughness 0.35, metallic 0.05), posicionado (256, 2.8, 256) — por debajo de la banda de agua turquesa costera (y=3) que sigue visible.

## Verificación

- Capturas: (a) 06:40 — plano VERTICAL (bug detectado por el usuario); (b) 06:44 — horizontal pero con borde del plano a 770 bloques (franja marrón); (c) **06:48 — océano azul liso hasta el horizonte, sin pared, sin borde, FPS 60**.
- Nota: el plano es visual (sin colisión); la física del agua la dan los bloques del terreno (el fondo sigue sólido). Paseo a la vegetación/terreno sin regresiones (suite EXIT 0).

## Archivos Modificados/Creados

- Modificados: `scripts/main_island.gd` (funcion _crear_oceano + fixes), capturas (no versionadas), `Logs/ULTIMO_NUMERO.txt` (→565)
