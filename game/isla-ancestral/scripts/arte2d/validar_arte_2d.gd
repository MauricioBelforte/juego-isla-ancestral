# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M46: Arte 2D — Validador de assets 2D (V0 + iter. 1).
# Escanea assets/2d/ verificando: naming convention (prefijos RF15), existencia
# de textura, dimensiones mínimas/máximas, formato, múltiplo de 4, cuadrado
# para iconos/retratos, alfa sin halos en bordes, cobertura del inventario
# data/arte2d/inventario_2d.json (RF14).
# Ejecutar: Godot --headless --script res://scripts/arte2d/validar_arte_2d.gd

extends SceneTree

var _fallos: int = 0
var _assets_ok: int = 0
var _assets_err: int = 0

# RF15: prefijos por familia (ico=objetos/herramientas, pt=retratos,
# illus=ilustraciones/mapas, sym=símbolos, badge=insignias, ui=UI, logo=logo)
const NAMING_PATTERN := "^(ico|pt|illus|sym|badge|ui|logo|tex|spr)_[a-z0-9_]+$"
const PREFIJOS_CUADRADOS := ["ico_", "pt_", "sym_", "badge_"]
const RUTA_2D := "res://assets/2d/"
const RUTA_INVENTARIO := "res://data/arte2d/inventario_2d.json"
const DIM_MIN := 8
const DIM_MAX := 4096

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== M46 Validador de Arte 2D ===")
	var dir := DirAccess.open(RUTA_2D)
	if dir == null:
		print("WARN: assets/2d/ no existe — módulo sin assets aún")
		print("=== M46 VALIDADOR: 0 fallos (sin assets) ===")
		quit(0)
		return
	_escanear(RUTA_2D)
	var cobertura := _cobertura_inventario()
	print("Cobertura del inventario: %d/%d assets" % [cobertura["hechos"], cobertura["total"]])
	print("=== M46 VALIDADOR: %d fallo(s) — %d OK, %d errores ===" % [_fallos, _assets_ok, _assets_err])
	quit(1 if _fallos > 0 else 0)

func _escanear(ruta: String) -> void:
	var dir := DirAccess.open(ruta)
	if dir == null:
		return
	dir.list_dir_begin()
	var archivo := dir.get_next()
	while archivo != "":
		var path := ruta + "/" + archivo
		if dir.current_is_dir() and archivo != "." and archivo != "..":
			_escanear(path)
		elif archivo.ends_with(".png") or archivo.ends_with(".webp") or archivo.ends_with(".svg"):
			_validar(path, archivo)
		archivo = dir.get_next()
	dir.list_dir_end()

func _validar(path: String, nombre: String) -> void:
	# 1. Naming convention (RF15)
	var regex := RegEx.new()
	regex.compile(NAMING_PATTERN)
	var base := nombre.get_basename()
	if not regex.search(base):
		_err("naming: '%s' no matchea patrón %s" % [base, NAMING_PATTERN])
		return
	# 2. Cargar imagen (lectura manual: los PNG crudos sin .import no pasan
	# por el ResourceLoader; así el validador funciona con assets nuevos)
	var img := Image.new()
	var bytes := FileAccess.get_file_as_bytes(path)
	var err := img.load_png_from_buffer(bytes)
	if err != OK and not nombre.ends_with(".webp"):
		_err("no cargable como imagen (%s): %s" % [error_string(err), path])
		return
	if err != OK:
		err = img.load_webp_from_buffer(bytes)
		if err != OK:
			_err("no cargable como webp (%s): %s" % [error_string(err), path])
			return
	# 3. Dimensiones
	var w: int = img.get_width()
	var h: int = img.get_height()
	if w < DIM_MIN or h < DIM_MIN:
		_err("dimensiones muy pequeñas: %dx%d (%s)" % [w, h, base])
		return
	if w > DIM_MAX or h > DIM_MAX:
		_err("dimensiones muy grandes: %dx%d (%s)" % [w, h, base])
		return
	# 4. Múltiplo de 4 (RF13, compresión)
	if w % 4 != 0 or h % 4 != 0:
		_err("dimensiones no múltiplo de 4: %dx%d (%s)" % [w, h, base])
		return
	# 5. Cuadrado para iconos/retratos/símbolos/insignias (RF14)
	for pref in PREFIJOS_CUADRADOS:
		if base.begins_with(pref) and w != h:
			_err("no cuadrado para familia '%s': %dx%d (%s)" % [pref, w, h, base])
			return
	# 6. Alfa sin halos en bordes (RF14): borde con alfa semi (~1-254) = halo
	if not _alfa_bordes_limpio(img):
		_err("alfa con halos en bordes: %s" % base)
		return
	_assets_ok += 1
	print("OK: %s (%dx%d)" % [base, w, h])

## Verifica que los píxeles del borde sean 0 u 255 de alfa (sin halos).
func _alfa_bordes_limpio(img: Image) -> bool:
	var w := img.get_width()
	var h := img.get_height()
	for x in w:
		for y in [0, h - 1]:
			if not _alfa_ok(img.get_pixel(x, y)):
				return false
	for y in h:
		for x in [0, w - 1]:
			if not _alfa_ok(img.get_pixel(x, y)):
				return false
	return true

func _alfa_ok(px: Color) -> bool:
	var a := px.a * 255.0
	return a < 1.0 or a > 254.0

## RF14: cobertura del inventario data-driven (cuántos assets del JSON existen).
func _cobertura_inventario() -> Dictionary:
	var res := {"total": 0, "hechos": 0, "faltantes": []}
	if not FileAccess.file_exists(RUTA_INVENTARIO):
		print("WARN: inventario 2D no encontrado: %s" % RUTA_INVENTARIO)
		return res
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_INVENTARIO))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("assets"):
		return res
	for a in parsed["assets"]:
		res["total"] += 1
		var id := String(a.get("id", ""))
		var familia := String(a.get("familia", "iconos"))
		var encontrado := false
		for ext in [".png", ".webp", ".svg"]:
			if FileAccess.file_exists("%s%s/%s%s" % [RUTA_2D, familia, id, ext]):
				encontrado = true
				break
		if encontrado:
			res["hechos"] += 1
		else:
			res["faltantes"].append(id)
	return res

func _err(msg: String) -> void:
	_fallos += 1
	_assets_err += 1
	print("ERROR: " + msg)
