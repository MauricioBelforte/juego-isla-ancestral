# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M50 iter 2: VegetationManager — spawn de vegetación por bioma (data-driven:
# tipos por bioma + densidad; posiciones deterministas con PRNG por semilla).
# La instanciación de los GLB (assets M166) la hará el mundo (M08) al poblar;
# este servicio entrega la configuración y las posiciones.

class_name VegetationManager
extends RefCounted

const RUTA_CONFIG := "res://data/vegetacion/vegetacion_config.json"

static func cargar_config() -> Dictionary:
	if not FileAccess.file_exists(RUTA_CONFIG):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed.get("biomas", {})
	return {}

static func tipos_para_bioma(bioma: String) -> Array:
	var config := cargar_config()
	var data: Dictionary = config.get(bioma, {})
	return data.get("tipos", [])

static func densidad(bioma: String) -> int:
	var config := cargar_config()
	var data: Dictionary = config.get(bioma, {})
	return int(data.get("densidad", 0))

## Posiciones deterministas para un bioma (PRNG seed = semilla del mundo)
## alrededor del centro en un radio dado.
static func posiciones(bioma: String, centro: Vector2, radio: float, semilla: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla + semilla * int(bioma.hash())
	var n := densidad(bioma)
	var out := []
	for i in range(n):
		var ang := rng.randf_range(0.0, TAU)
		var dist := rng.randf_range(0.0, radio)
		out.append(centro + Vector2(cos(ang), sin(ang)) * dist)
	return out
