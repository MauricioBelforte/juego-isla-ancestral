# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M121: Soporte Post-Lanzamiento — SupportManager (autoload)
# FAQ data-driven, categorías de tickets, canales de soporte, política de
# respuesta. Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_FAQ := "res://data/support/faq.json"

var config: Dictionary = {}

func _ready() -> void:
	_cargar_faq()
	_registrar_servicio()
	print("[M121] SupportManager listo (%d FAQ, %d canales)" % [config.get("faq", []).size(), config.get("canales", []).size()])

func _cargar_faq() -> void:
	if not FileAccess.file_exists(RUTA_FAQ):
		push_warning("[M121] faq.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_FAQ))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("support"):
		sr.register("support", self)

func faq_por_categoria(categoria: String) -> Array:
	var resultado: Array = []
	for item in config.get("faq", []):
		if String(item.get("categoria", "")) == categoria:
			resultado.append(item)
	return resultado

func buscar_faq(termino: String) -> Array:
	var resultado: Array = []
	for item in config.get("faq", []):
		var texto := "%s %s %s" % [item.get("pregunta", ""), item.get("respuesta", ""), item.get("id", "")]
		if texto.to_lower().contains(termino.to_lower()):
			resultado.append(item)
	return resultado

func canales() -> Array:
	return config.get("canales", []).duplicate()

func categorias() -> Array:
	return config.get("categorias", []).duplicate()

func politica_respuesta() -> Dictionary:
	return config.get("politica_respuesta", {}).duplicate(true)