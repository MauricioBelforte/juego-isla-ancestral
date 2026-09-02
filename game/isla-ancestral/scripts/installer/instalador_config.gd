# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M116: Instalador — InstaladorConfig (autoload)
# Configuración data-driven del instalador (instalador_config.json):
# plataformas, pasos de instalación, requisitos, verificación de checksum.
# Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_CONFIG := "res://data/installer/instalador_config.json"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_config()
	_registrar_servicio()
	print("[M116] InstaladorConfig listo (%d plataformas, %d pasos)" % [config.get("plataformas", []).size(), config.get("pasos", []).size()])

func _cargar_config() -> void:
	if not FileAccess.file_exists(RUTA_CONFIG):
		push_warning("[M116] instalador_config.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CONFIG))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("instalador"):
		sr.register("instalador", self)

func plataformas() -> Array:
	return config.get("plataformas", []).duplicate()

func pasos() -> Array:
	return config.get("pasos", []).duplicate(true)

func requisito(nombre: String) -> int:
	return int(config.get("requisitos", {}).get(nombre, 0))

func soporta_plataforma(p: String) -> bool:
	return p in config.get("plataformas", [])