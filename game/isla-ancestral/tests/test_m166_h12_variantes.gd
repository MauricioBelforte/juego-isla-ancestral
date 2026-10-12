extends SceneTree

## Test headless M166-H12 — variantes_disponibles en ItemData (Log a asignar).
## Verifica: (1) ItemData expone los campos M166; (2) los items heroicos con
## ALTA declaran ["alta","media","baja"]; (3) los GLB de la pasada ALTA existen
## en disco para cada modelo_id declarado; (4) el resto de items conserva el
## default ["media","baja"] (relleno D9, no es un hueco).
## Uso: godot --headless -s res://tests/test_m166_h12_variantes.gd
## Exit: 0 = todo OK, 1 = algun fallo.

var _passed := 0
var _failed := 0
var _fails: Array = []

const DIR_ITEMS := "res://data/items"
const DIR_ALTA := "res://assets/3d/alta"

# modelo_id -> (id_modulo Godot, GLB esperado en alta/). Match inequivoco por
# nombre entre el catalogo M159 (.tres) y el pipeline Blender M166.
const HEROES := {
	"cristal_ancestral": "15-Recursos_cristal_ancestral.glb",
	"pico_hierro": "13-Herramientas_pico_hierro.glb",
	"farola_fuego": "40-Infraestructura_farola_fuego.glb",
}


func _check(cond: bool, nombre: String, detalle := "") -> void:
	if cond:
		_passed += 1
	else:
		_failed += 1
		_fails.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))


func _initialize() -> void:
	print("=== M166-H12 variantes_disponibles (ItemData) ===")
	_test_campos_item_data()
	_test_heroes_declaran_alta()
	_test_glbs_alta_existen()
	_test_relleno_sin_alta()
	print("M166-H12: passed=%d failed=%d" % [_passed, _failed])
	for f in _fails:
		print("  FALLO: " + str(f))
	if _failed > 0:
		quit(1)
	else:
		quit(0)


func _test_campos_item_data() -> void:
	# El script debe exponer los tres campos M166 (03-Diseno.md §6).
	var script := load("res://scripts/data/item_data.gd")
	_check(script != null, "item_data.gd carga")
	if script == null:
		return
	var instancia: ItemData = script.new()
	_check("modelo_id" in instancia, "campo modelo_id existe")
	_check("usa_multimesh" in instancia, "campo usa_multimesh existe")
	_check("variantes_disponibles" in instancia, "campo variantes_disponibles existe")
	_check(instancia.variantes_disponibles == PackedStringArray(["media", "baja"]),
			"default variantes_disponibles = [media, baja]",
			str(instancia.variantes_disponibles))
	_check(instancia.modelo_id == "", "default modelo_id vacio")
	_check(not instancia.usa_multimesh, "default usa_multimesh false")



func _cargar_todos_los_items() -> Dictionary:
	var items := {}
	var dir := DirAccess.open(DIR_ITEMS)
	_check(dir != null, "abre directorio data/items")
	if dir == null:
		return items
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre.ends_with(".tres"):
			var ruta := DIR_ITEMS + "/" + nombre
			var recurso := load(ruta)
			if recurso != null and recurso is Resource:
				items[nombre] = recurso
		nombre = dir.get_next()
	dir.list_dir_end()
	_check(items.size() > 0, "items cargados", str(items.size()))
	return items


func _test_heroes_declaran_alta() -> void:
	var items := _cargar_todos_los_items()
	if items.is_empty():
		return
	var encontrados: Dictionary = {}
	for nombre in items:
		var item: Resource = items[nombre]
		if item.get("modelo_id") in HEROES.keys():
			encontrados[item.get("modelo_id")] = true
			var esperado := PackedStringArray(["alta", "media", "baja"])
			_check(item.get("variantes_disponibles") == esperado,
					"%s declara variantes ALTA" % nombre,
					str(item.get("variantes_disponibles")))
	_check(encontrados.size() == HEROES.size(),
			"todos los heroes con match estan declarados",
			"%d/%d" % [encontrados.size(), HEROES.size()])


func _test_glbs_alta_existen() -> void:
	for modelo_id in HEROES:
		var glb: String = HEROES[modelo_id]
		var ruta: String = DIR_ALTA + "/" + glb
		_check(ResourceLoader.exists(ruta) or FileAccess.file_exists(ruta),
				"GLB alta existe: %s" % glb, ruta)


func _test_relleno_sin_alta() -> void:
	var items := _cargar_todos_los_items()
	if items.is_empty():
		return
	var default := PackedStringArray(["media", "baja"])
	for nombre in items:
		var item: Resource = items[nombre]
		if item.get("modelo_id") in HEROES.keys():
			continue
		var vd = item.get("variantes_disponibles")
		_check(vd == null or vd == default,
				"%s conserva default (relleno D9)" % nombre,
				str(vd))
		_check(not ("alta" in (vd if vd != null else [])),
				"%s no declara ALTA sin modelo_id" % nombre,
				str(vd))
