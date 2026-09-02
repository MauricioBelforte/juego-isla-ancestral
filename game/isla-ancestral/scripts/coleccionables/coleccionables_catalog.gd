# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M73: Coleccionables - ColeccionablesCatalog (RefCounted).
# Carga el catalogo de items desde data/coleccionables/catalog.json.
# Si el JSON no existe o falla, carga un fallback in-code con items representativos
# de 4 fuentes: mineria, fauna, reliquias, conchas.
# Sin class_name: se preloadea (07-GUIA-GODOT §9.17).

extends RefCounted

const CATALOGO_PATH := "res://data/coleccionables/catalog.json"
const ItemRef = preload("res://scripts/coleccionables/coleccionable_item.gd")

## Categoria -> Array de Items
var _items: Dictionary = {}

## Carga el catalogo. Devuelve la cantidad total de items.
func cargar() -> int:
	_items.clear()
	if FileAccess.file_exists(CATALOGO_PATH):
		var contenido := FileAccess.get_file_as_string(CATALOGO_PATH)
		if contenido.is_empty():
			return _cargar_fallback()
		var parsed: Variant = JSON.parse_string(contenido)
		if typeof(parsed) != TYPE_ARRAY:
			push_warning("[M73] catalog.json no es array; usando fallback")
			return _cargar_fallback()
		return _cargar_desde_array(parsed)
	return _cargar_fallback()

func _cargar_desde_array(arr: Array) -> int:
	var cargados: int = 0
	for entrada in arr:
		if not (entrada is Dictionary):
			continue
		var item := _item_desde_dict(entrada)
		if item.es_valido():
			_agregar_item(item)
			cargados += 1
		else:
			push_warning("[M73] item invalido descartado: %s" % String(entrada.get("id", "?")))
	return cargados

func _item_desde_dict(data: Dictionary) -> Resource:
	var it = ItemRef.new()
	it.categoria = StringName(String(data.get("categoria", "")))
	it.id_local = StringName(String(data.get("id_local", "")))
	it.display_name = String(data.get("display_name", ""))
	it.rareza = int(data.get("rareza", 0))
	it.fuente = StringName(String(data.get("fuente", "")))
	it.recompensa_item = StringName(String(data.get("recompensa_item", "")))
	it.recompensa_cantidad = int(data.get("recompensa_cantidad", 0))
	it.puntos = int(data.get("puntos", 10))
	return it

func _cargar_fallback() -> int:
	_items.clear()
	var ejemplos: Array = [
		# Minerales (consumir senal M35 MiningManager)
		{"categoria": "minerales", "id_local": "001", "display_name": "Cobre", "rareza": 0, "fuente": "mineria", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 50, "puntos": 5},
		{"categoria": "minerales", "id_local": "002", "display_name": "Hierro", "rareza": 1, "fuente": "mineria", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 100, "puntos": 10},
		{"categoria": "minerales", "id_local": "003", "display_name": "Oro", "rareza": 2, "fuente": "mineria", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 200, "puntos": 25},
		{"categoria": "minerales", "id_local": "004", "display_name": "Cristal Estacional", "rareza": 2, "fuente": "mineria", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 250, "puntos": 25},
		{"categoria": "minerales", "id_local": "005", "display_name": "Mineral Ancestral", "rareza": 3, "fuente": "mineria", "recompensa_item": "gema_ancestral", "recompensa_cantidad": 1, "puntos": 100},
		# Animales (consumir senal M36 fauna_registry)
		{"categoria": "animales", "id_local": "001", "display_name": "Conejo de Pradera", "rareza": 0, "fuente": "fauna", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 30, "puntos": 5},
		{"categoria": "animales", "id_local": "002", "display_name": "Gaviota Playera", "rareza": 0, "fuente": "fauna", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 30, "puntos": 5},
		{"categoria": "animales", "id_local": "003", "display_name": "Nutria de Ribera", "rareza": 1, "fuente": "fauna", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 60, "puntos": 15},
		{"categoria": "animales", "id_local": "004", "display_name": "Salamandra Ancestral", "rareza": 3, "fuente": "fauna", "recompensa_item": "gema_ancestral", "recompensa_cantidad": 1, "puntos": 150},
		# Conchas
		{"categoria": "conchas", "id_local": "001", "display_name": "Concha Caracol", "rareza": 0, "fuente": "playa", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 20, "puntos": 5},
		{"categoria": "conchas", "id_local": "002", "display_name": "Concha Vieira", "rareza": 0, "fuente": "playa", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 25, "puntos": 5},
		{"categoria": "conchas", "id_local": "003", "display_name": "Concha Nacar Ancestral", "rareza": 2, "fuente": "playa", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 100, "puntos": 30},
		# Reliquias
		{"categoria": "reliquias", "id_local": "001", "display_name": "Mascara de Ancestro", "rareza": 3, "fuente": "ruinas", "recompensa_item": "gema_ancestral", "recompensa_cantidad": 1, "puntos": 200},
		{"categoria": "reliquias", "id_local": "002", "display_name": "Vasija Ancestral", "rareza": 2, "fuente": "ruinas", "recompensa_item": "moneda_ancestral", "recompensa_cantidad": 300, "puntos": 80},
		{"categoria": "reliquias", "id_local": "003", "display_name": "Idolo de Piedra", "rareza": 3, "fuente": "templo", "recompensa_item": "gema_ancestral", "recompensa_cantidad": 1, "puntos": 200},
	]
	return _cargar_desde_array(ejemplos)

## ── API publica ─────────────────────────────────────────────

func _agregar_item(it) -> void:
	if not _items.has(it.categoria):
		_items[it.categoria] = []
	_items[it.categoria].append(it)

func obtener(id_global: StringName) -> Resource:
	for cat in _items.keys():
		for it in _items[cat]:
			if it.id_global() == id_global:
				return it
	return null

func obtener_por_categoria(categoria: StringName) -> Array:
	return _items.get(categoria, [])

func cantidad_total() -> int:
	var n: int = 0
	for cat in _items.keys():
		n += _items[cat].size()
	return n

func cantidad_por_categoria(categoria: StringName) -> int:
	return _items.get(categoria, []).size()

func todas_las_categorias() -> Array:
	return _items.keys()
