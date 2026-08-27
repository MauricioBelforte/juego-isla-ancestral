# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-25

extends Node

## ItemDatabase — Autoload maestro (M159).
## Carga todos los `.tres` de `res://data/items/` al arranque y expone queries.
## Diseño: MiMo V2.5 → plan-actual/04-Codigo.md §2.2

const ITEMS_DIR: String = "res://data/items/"

var _items: Dictionary = {}                       # id → ItemData
var _by_category: Dictionary = {}                 # Categoria → Array[ItemData]
var _by_rarity: Dictionary = {}                   # Rareza →  Array[ItemData]
var _by_fuente: Dictionary = {}                   # String  → Array[ItemData]
var _interactive: Array[ItemData] = []            # todos los interactivos
var _placeable: Array[ItemData] = []              # todos los colocables (tamaño en grid)

## Señal de conveniencia para consumidores (M14/M16/M18/M39/M55).
signal catalogo_cargado(cant_total: int)

func _init() -> void:
	name = "ItemDatabase"  # nombre canónico del Autoload

func _ready() -> void:
	_load_all_items()
	catalogo_cargado.emit(_items.size())

## --- Carga --- ##

func _load_all_items() -> void:
	_items.clear()
	_by_category.clear()
	_by_rarity.clear()
	_by_fuente.clear()
	_interactive.clear()
	_placeable.clear()

	var dir := DirAccess.open(ITEMS_DIR)
	if dir == null:
		# Carpeta inexistente: crear placeholder (solo la primera vez).
		push_warning("M159: carpeta %s no existe; creando placeholder." % ITEMS_DIR)
		if DirAccess.make_dir_absolute("res://data") == OK and \
		   DirAccess.make_dir_absolute("res://data/items") == OK:
			return
		else:
			push_error("M159: no se pudo crear %s" % ITEMS_DIR)
			return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var item := load(ITEMS_DIR.path_join(file_name)) as ItemData
			if item != null:
				_registrar_item(item)
		file_name = dir.get_next()
	dir.list_dir_end()

func _registrar_item(item: ItemData) -> void:
	if item.id == "":
		push_warning("M159: item sin id en '%s', omitido." % item.resource_path)
		return
	if _items.has(item.id):
		push_warning("M159: id duplicado '%s', se ignora duplicado." % item.id)
		return

	_items[item.id] = item

	# índices derivados (Dictionary.get con default)
	if not _by_category.has(item.categoria):
		_by_category[item.categoria] = []
	_by_category[item.categoria].append(item)

	if not _by_rarity.has(item.rareza):
		_by_rarity[item.rareza] = []
	_by_rarity[item.rareza].append(item)

	if item.fuente != "":
		if not _by_fuente.has(item.fuente):
			_by_fuente[item.fuente] = []
		_by_fuente[item.fuente].append(item)

	if item.interactivo:
		_interactive.append(item)
	if item.tamano.x > 0 and item.tamano.y > 0:
		_placeable.append(item)

## --- Queries (6) --- ##

## Busca por ID exacto.
func get_item(id: String) -> ItemData:
	return _items.get(id)

func get_items_by_category(cat: ItemData.Categoria) -> Array[ItemData]:
	return _by_category.get(cat, [])

func get_items_by_rarity(r: ItemData.Rareza) -> Array[ItemData]:
	return _by_rarity.get(r, [])

func get_items_by_source(fuente: String) -> Array[ItemData]:
	return _by_fuente.get(fuente, [])

func get_interactive_items() -> Array[ItemData]:
	return _interactive.duplicate()

func get_placeable_items() -> Array[ItemData]:
	return _placeable.duplicate()

## --- Debug / validación --- ##

func validar_ids_unicos() -> bool:
	var ids: Array[String] = []
	for i in _items.values():
		if ids.has(i.id):
			return false
		ids.append(i.id)
	return true

func count() -> int:
	return _items.size()
