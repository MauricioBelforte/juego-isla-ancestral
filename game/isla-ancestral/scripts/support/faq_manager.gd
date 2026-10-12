# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-12
#
# M121: Soporte Post-Lanzamiento — FAQManager
# Servicio data-driven de FAQ: carga, busqueda por texto y filtro por
# categoria. Diseno de referencia: 04-Codigo.md sec.5.
#
# Divergencia declarada con el diseno: el diseno pedia un autoload propio.
# Se implementa como RefCounted instanciado por SupportManager para NO tocar
# project.godot (archivo compartido por varios agentes, trampa AM del skill).
# Logica pura -> testeable en headless sin escena.

class_name FAQManager
extends RefCounted

const RUTA_FAQ := "res://data/support/faq.json"

var faq_data: Dictionary = {}
var _items: Array = []
var _ruta: String = RUTA_FAQ

func _init(ruta: String = RUTA_FAQ) -> void:
	_ruta = ruta
	load_faq()

func load_faq() -> bool:
	faq_data = {}
	_items = []
	if not FileAccess.file_exists(_ruta):
		return false
	var crudo := FileAccess.get_file_as_string(_ruta)
	var parsed: Variant = JSON.parse_string(crudo)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var d: Dictionary = parsed
	faq_data = d
	var lista: Array = d.get("faq", [])
	for item in lista:
		if typeof(item) == TYPE_DICTIONARY:
			_items.append(item)
	return not _items.is_empty()

func total() -> int:
	return _items.size()

func items() -> Array:
	return _items.duplicate()

func por_categoria(categoria: String) -> Array:
	var out: Array = []
	for item in _items:
		if String(item.get("categoria", "")) == categoria:
			out.append(item)
	return out

func search_faq(query: String) -> Array:
	var q := query.strip_edges().to_lower()
	var out: Array = []
	if q.is_empty():
		return out
	for item in _items:
		var texto := "%s %s %s" % [
			str(item.get("pregunta", "")),
			str(item.get("respuesta", "")),
			str(item.get("id", "")),
		]
		if texto.to_lower().contains(q):
			out.append({
				"id": str(item.get("id", "")),
				"categoria": str(item.get("categoria", "")),
				"pregunta": str(item.get("pregunta", "")),
				"respuesta": str(item.get("respuesta", "")),
			})
	return out

func categorias() -> Array:
	var cats: Array = []
	for item in _items:
		var c := str(item.get("categoria", ""))
		if c != "" and not cats.has(c):
			cats.append(c)
	cats.sort()
	return cats
