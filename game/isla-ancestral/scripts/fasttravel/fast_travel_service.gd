# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M69: FastTravelService — anclas de viaje rápido (data-driven anclas.json),
# desbloqueo por visita y solicitud de viaje por señal (la ejecución la hace
# M28/M59). Sin UI (iter 2 con M53/M57).

extends Node

signal ancla_desbloqueada(ancla_id: String)
signal viaje_solicitado(ancla: Dictionary)

const RUTA_ANCLAS := "res://data/fasttravel/anclas.json"

var _anclas: Array = []
var _desbloqueadas: Dictionary = {}

func _ready() -> void:
	_cargar()

func _cargar() -> void:
	if not FileAccess.file_exists(RUTA_ANCLAS):
		push_warning("[M69] anclas.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_ANCLAS))
	if typeof(parsed) == TYPE_DICTIONARY:
		var viajes: Dictionary = parsed.get("viajes", {})
		for isla in viajes:
			for ancla in viajes[isla].get("anclas", []):
				ancla["isla"] = isla
				_anclas.append(ancla)
				if bool(ancla.get("desbloquea", false)):
					_desbloqueadas[String(ancla["id"])] = true
	print("[M69] FastTravelService listo (%d anclas, %d desbloqueadas)" % [_anclas.size(), _desbloqueadas.size()])

func anclas() -> Array:
	return _anclas

func anclas_desbloqueadas() -> Array:
	var out := []
	for a in _anclas:
		if _desbloqueadas.has(String(a.get("id", ""))):
			out.append(a)
	return out

func desbloquear(ancla_id: String) -> bool:
	if _desbloqueadas.has(ancla_id):
		return false
	_desbloqueadas[ancla_id] = true
	ancla_desbloqueada.emit(ancla_id)
	return true

func esta_desbloqueada(ancla_id: String) -> bool:
	return _desbloqueadas.has(ancla_id)

func solicitar_viaje(ancla_id: String) -> bool:
	if not _desbloqueadas.has(ancla_id):
		push_warning("[M69] Ancla no desbloqueada: %s" % ancla_id)
		return false
	for a in _anclas:
		if String(a.get("id", "")) == ancla_id:
			viaje_solicitado.emit(a)
			return true
	return false
