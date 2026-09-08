# Log 788: M09 — suelo fantasma en agua: nadar en la superficie, no ir al fondo

**Fecha:** 2026-09-07
**Hora:** 09:58
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Complemento del suelo fantasma (Log 787): el usuario reportó "apenas aparezco me muevo recto y me voy al fondo del mapa" — el spawn está junto a la laguna central (valle con agua, h 0-3 del generador) y el suelo fantasma lo apoyaba en el FONDO del agua (y 0-3), debajo del plano de agua visual (4.05) y sin chunks de agua para nadar → atrapado. Fix: en celdas de agua (h<4), el suelo fantasma sostiene al jugador en la **superficie del agua (y=4.45)** — como nadando — hasta que los chunks reales carguen.

## Cambios Realizados
- `scripts/player/player.gd` (bloque suelo fantasma): si `get_height() < 4.0` → sostener en y=4.45 (superficie, encima del plano de agua animado 4.05); si tierra (h>=4) → sostener en la altura del terreno como antes.

## Evidencia
- Boot: `[M09] Chunk del spawn materializado (bloque 2 en Y=27) — física liberada tras 0.5s` — 0 errores.
- La lógica de agua se activa solo al caminar hacia la laguna con chunks sin materializar; con chunks cargados, el agua real (VoxelBoxMover con SHALLOW_WATER) toma el mando.

## Reglas del suelo fantasma (resumen final, Log 787+788)
| Terreno bajo los pies (generador) | El jugador queda en |
|---|---|
| Tierra h>=4 | y = h (caminando sobre el terreno) |
| Agua h<4 | y = 4.45 (nadando en la superficie) |

## Archivos Modificados
- `game/isla-ancestral/scripts/player/player.gd` (rama de agua en el suelo fantasma)
