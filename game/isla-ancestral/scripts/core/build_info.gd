# Modelo: step-3.7-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M117: Build System — BuildInfo (runtime)
# Expone versión y canal desde build. Si no hay datos empaquetados,
# devuelve valores seguros para no romper M104/M142/M143.

extends Node

const RUTA_INFO := "user://build_info.json"

var version: String = "0.0.0"
var channel: String = "dev"
var build_number: int = 0

func _ready() -> void:
	_cargar()

func _cargar() -> void:
	if not FileAccess.file_exists(RUTA_INFO):
		return
	var data := JSON.parse_string(FileAccess.get_file_as_string(RUTA_INFO))
	if typeof(data) != TYPE_DICTIONARY:
		return
	version = String(data.get("version", version))
	channel = String(data.get("channel", channel))
	build_number = int(data.get("build_number", build_number))

static func canal_por_tipo(tipo: String) -> String:
	match tipo:
		"dev": return "dev"
		"qa": return "qa"
		"staging": return "staging"
		"release": return "release"
		_: return "dev"
