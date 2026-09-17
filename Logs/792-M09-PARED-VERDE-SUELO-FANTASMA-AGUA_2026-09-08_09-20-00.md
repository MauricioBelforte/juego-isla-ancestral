# Log 792: M09 — pared perimetral del impostor verde + suelo fantasma agua/tierra
> **Nota de procedencia (2026-09-17, Log 974):** el titulo original de este
> archivo decia "Log 797", que colisiona con el log real
> `Logs/797-M09-VERIFICACION-IMPOSTOR-PASO64_2026-09-08_08-25-00.md` (contenido
> distinto). El nombre del archivo es la identidad (792) y el codigo de juego lo
> cita como "Log 792" en `terreno_horizonte.gd:255`; se corrigio el titulo para
> eliminar la colision silenciosa (trampa 67).

**Fecha:** 2026-09-08
**Hora:** 09:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Dos fixes del feedback del usuario:
1. El disco verde plano visto de canto (desde lejos, a nivel del mar) era una línea de subpíxeles — invisible. Agregado **muro vertical perimetral** (r 2096, doble cara) para que desde lejos se vea el borde verde-tierra de la isla sobre el mar.
2. El suelo fantasma apoyaba al jugador en la altura del generador — pero en la laguna central (h 0-3) eso lo dejaba BAJO el plano de agua (4.05) sin chunks para nadar → atrapado. Fix: en celdas de AGUA (h<4) el suelo fantasma apoya en y=4.45 (superficie, nadando).

## Cambios Realizados
- `terreno_horizonte.gd` (muro perimetral en _crear_disco_base: 2 caras × 64 segmentos).
- `player.gd` (suelo fantasma v2: h>=4 tierra, h<4 agua superficie 4.45).
- El bot de paseo queda fuera del autoload (herramienta re-ejecutable con `-- paseo`).

## Evidencia
- Captura `pared_verde_1.png`: la isla vista desde el borde con el relieve del impostor (bloques verdes escalonados) y el mar alrededor — el verde cubre el interior continuo.
- Boot: `[M09-Horizonte] impostor de montañas: 36 tiles` + `plano verde: 11 anillos` + `sistema completo` — 0 errores.
- `Chunk del spawn materializado (bloque 2 en Y=27) — física liberada tras 1.0s` (fix Log 786 funcionando).

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (pared perimetral)
- `game/isla-ancestral/scripts/player/player.gd` (suelo fantasma agua)
