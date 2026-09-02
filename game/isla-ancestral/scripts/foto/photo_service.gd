# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M56: PhotoService — núcleo del modo fotografía (RF5 presets + estado del modo).
# Data-driven desde data/foto/foto_presets.json (validado por FotoSchema).
# La cámara libre/lente se implementan en la iteración 2 (M49/M31).

extends Node

signal modo_foto_cambiado(activo: bool)
signal preset_aplicado(preset_id: String)

const RUTA_PRESETS := "res://data/foto/foto_presets.json"

var _activo: bool = false
var _presets: Dictionary = {}
var _activo_preset: String = "natural"

func _ready() -> void:
	_cargar_presets()

func _cargar_presets() -> void:
	if not FileAccess.file_exists(RUTA_PRESETS):
		push_warning("[M56] foto_presets.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_PRESETS))
	if typeof(parsed) == TYPE_DICTIONARY:
		_presets = parsed.get("presets", {})
	print("[M56] PhotoService listo (%d presets fotográficos)" % _presets.size())

func set_modo_foto(activo: bool) -> void:
	if _activo == activo:
		return
	_activo = activo
	modo_foto_cambiado.emit(activo)
	print("[M56] Modo fotografía: %s" % ("ACTIVO" if activo else "DESACTIVADO"))

func modo_foto() -> bool:
	return _activo

func aplicar_preset(preset_id: String) -> Dictionary:
	if not _presets.has(preset_id):
		push_warning("[M56] Preset inexistente: %s → natural" % preset_id)
		preset_id = "natural"
	_activo_preset = preset_id
	preset_aplicado.emit(preset_id)
	return _presets[preset_id]

func presets() -> Array:
	return _presets.keys()

func preset_actual() -> Dictionary:
	return _presets.get(_activo_preset, {})
