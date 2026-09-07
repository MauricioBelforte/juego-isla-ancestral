# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M09 iter.: Punto único de verdad para el layout de la Isla Raíz.
# La isla procedural es 5120x5120 con centro en (2560, 2560) — pero todo el
# contenido (spawn, recursos, vegetación, NPCs, ruina) estaba apretado en la
# esquina (320,320) sobre la playa, lejos del interior real (bosque/montañas).
# Este autoload centraliza el centro real: cambiar UNA constante mueve la isla
# entera de contenido (jugador, fauna, vegetación, ruinas, recursos).
# M167 compatible: el generador no cambia, solo los consumidores.

extends Node

## Centro real de la Isla Raíz (island_generator: island_radius=2560, mundo 5120²)
const CENTRO := Vector2(2560.0, 2560.0)
## Radio nominal de la isla (para anillos de biomas: bosque/montaña/pradera)
const RADIO_ISLA := 1800.0
## Radio de orilla: agua voxel termina ~r 1700 (medido Log 750 con 24 rayos:
## fin del agua en r 180-204 de 2560 ⇒ escala real ≈ 180/256 * 2560 = 1800
## con transición a arena húmeda). Efectos de orilla usan medición, no esto.
const RADIO_ORILLA := 1700.0

## Spawn del jugador: llanura de césped/bosque a dist ~0.72 del centro
## (r 1838) — las montañas del centro quedan a ~430m en el horizonte.
const SPAWN_JUGADOR := Vector3(3860.0, 0.0, 3860.0)

## Contenido M15/M50/M16/M25 alrededor del spawn del jugador
const SPAWN_CONTENIDO := Vector3(3860.0, 0.0, 3860.0)

func centro_vec2() -> Vector2:
	return CENTRO

func centro_vec3(y: float = 0.0) -> Vector3:
	return Vector3(CENTRO.x, y, CENTRO.y)
