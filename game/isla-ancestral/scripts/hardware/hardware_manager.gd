# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M115: Hardware — HardwareManager (autoload)
# Catálogo data-driven de perfiles de hardware (hardware_profiles.json):
# perfil mínimo/recomendado por plataforma, detección, FPS objetivo,
# escala de resolución, calidad de texturas, sombras, antialiasing.
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_PERFILES := "res://data/hardware/hardware_profiles.json"

var config: Dictionary = {}
var perfil_actual: String = "baja"

func _ready() -> void:
	_cargar_perfiles()
	_registrar_servicio()
	print("[M115] HardwareManager listo (%d perfiles)" % config.get("perfiles", []).size())

func _cargar_perfiles() -> void:
	if not FileAccess.file_exists(RUTA_PERFILES):
		push_warning("[M115] hardware_profiles.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_PERFILES))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("hardware"):
		sr.register("hardware", self)

func perfil(id: String) -> Dictionary:
	for p in config.get("perfiles", []):
		if String(p.get("id", "")) == id:
			return p
	return {}

func perfiles_ids() -> Array:
	var ids: Array = []
	for p in config.get("perfiles", []):
		ids.append(p.get("id", ""))
	return ids

func set_perfil_actual(id: String) -> bool:
	if perfil(id).is_empty():
		return false
	perfil_actual = id
	return true

func plataforma_requisitos(plataforma: String) -> Dictionary:
	return config.get("plataformas", {}).get(plataforma, {})

func perfil_minimo(plataforma: String) -> String:
	return String(plataforma_requisitos(plataforma).get("perfil_minimo", ""))

func perfil_recomendado(plataforma: String) -> String:
	return String(plataforma_requisitos(plataforma).get("perfil_recomendado", ""))

## Calidad de renderizado según perfil actual (M90).
func render_scale() -> float:
	match perfil_actual:
		"baja": return 0.75
		"media": return 1.0
		"alta": return 1.25
		_: return 1.0

func shadow_quality() -> String:
	match perfil_actual:
		"baja": return "baja"
		"media": return "media"
		"alta": return "alta"
		_: return "media"

func texture_quality() -> String:
	match perfil_actual:
		"baja": return "baja"
		"media": return "media"
		"alta": return "alta"
		_: return "media"

func antialiasing() -> String:
	match perfil_actual:
		"baja": return "FXAA"
		"media": return "MSAA2"
		"alta": return "MSAA4"
		_: return "FXAA"