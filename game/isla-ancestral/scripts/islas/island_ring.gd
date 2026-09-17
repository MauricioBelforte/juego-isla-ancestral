# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M27: Islas del Mundo — IslandRing (enum compartido).
# El anillo controla distancia al núcleo y requisitos de desbloqueo.
# Vive en su propio archivo (y no dentro de IslandDefinition) porque lo
# necesitan M28 (viaje), M63 (streaming) y M54 (mapa) sin arrastrar la
# definición completa de una isla.
#
# Enum SIN nombre a propósito: así se usa como `IslandRing.CERCANO`, que es el
# nombre que fija el diseño (03-Diseno §2.5).

class_name IslandRing
extends RefCounted

enum { NUCLEO, CERCANO, MEDIO, LEJANO }

const NOMBRES: Array[String] = ["NUCLEO", "CERCANO", "MEDIO", "LEJANO"]

## Radio de vecindad de streaming por anillo (m): qué islas precarga M63 al
## acercarse. NUCLEO = 0 es un caso especial (Aurora no tiene radio propio: sus
## vecinas son TODOS los CERCANO). Los valores cubren la separación real de la
## disposición de anillos (CERCANO ~1905 m, MEDIO ~4157 m, LEJANO ~4400 m).
const RADIO_VECINDAD: Array[int] = [0, 2200, 4400, 6400]

## Requisito de desbloqueo por defecto (M22/M71): los anillos lejanos piden
## progreso de historia; NUCLEO y CERCANO están siempre disponibles.
const REQUIERE_PROGRESO: Array[bool] = [false, false, true, true]


static func nombre(valor: int) -> String:
	if valor < 0 or valor >= NOMBRES.size():
		return "DESCONOCIDO"
	return NOMBRES[valor]


static func desde_nombre(texto: String) -> int:
	var t: String = texto.strip_edges().to_upper()
	var i: int = NOMBRES.find(t)
	return i if i >= 0 else -1


static func es_valido(valor: int) -> bool:
	return valor >= 0 and valor < NOMBRES.size()


static func radio_vecindad(valor: int) -> int:
	if not es_valido(valor):
		return 0
	return RADIO_VECINDAD[valor]


static func distancia_max_anillo(valor: int) -> int:
	# Distancia máxima entre el centro del archipiélago y el ancla de la isla.
	match valor:
		NUCLEO:
			return 0
		CERCANO:
			return 1600
		MEDIO:
			return 3200
		_:
			return 6400
