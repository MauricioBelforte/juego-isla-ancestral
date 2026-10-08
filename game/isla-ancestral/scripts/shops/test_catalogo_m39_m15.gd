# guardián anti-regresión BUG-106 (agnes-3-flash, 2026-10-08)
# Verifica que los item_ids de los catálogos M39 existan en M15 (data/items/*.tres).
# Si un catálogo vuelve a referenciar un id inexistente en M15, el test FALLE (exit 1).
extends SceneTree

const CAT_TIENDAS := "res://scripts/shops/catalogo_tiendas.gd"
const DATA_ITEMS := "res://data/items"

func _initialize() -> void:
	var m15 := _ids_m15()
	print("[BUG-106] M15: %d ids válidos" % m15.size())
	if m15.size() == 0:
		print("[BUG-106] FALLO: no pude leer los ids de M15 (ver DATA_ITEMS)")
		quit(1)
		return
	var m39 := _ids_m39()
	var faltantes := []
	for id in m39:
		if not m15.has(id):
			faltantes.append(id)
	if faltantes.size() > 0:
		print("[BUG-106] FALSO: M39 referencia %d ids INEXISTENTES en M15: %s" % [faltantes.size(), str(faltantes)])
		quit(1)
		return
	print("[BUG-106] OK: los %d item_ids de M39 existen en M15" % m39.size())
	quit(0)

## Extrae el campo 'id' de cada .tres de M15.
func _ids_m15() -> Dictionary:
	var ids := {}
	var dir := DirAccess.open(DATA_ITEMS)
	if dir == null:
		return ids
	for f in dir.get_files():
		if not f.ends_with(".tres"):
			continue
		var t := FileAccess.get_file_as_string(DATA_ITEMS + "/" + f)
		var re := RegEx.new()
		re.compile("(?m)^\\s*id\\s*=\\s*\"([^\"]+)\"")
		var m := re.search(t)
		if m:
			ids[m.get_string(1)] = true
	return ids

## Extrae los item_ids de M39 (llamadas _entry("ID", ...) del catálogo).
func _ids_m39() -> Array:
	var src := FileAccess.get_file_as_string(CAT_TIENDAS)
	var re := RegEx.new()
	# _entry("ALGUN_ID", ...  : captura el primer argumento de _entry
	re.compile("(_entry\\s*\\(\\s*)\"([A-Za-z0-9_-]+)\"")
	var ids := []
	for lm in re.search_all(src):
		var id := lm.get_string(2)
		if not ids.has(id):
			ids.append(id)
	return ids
