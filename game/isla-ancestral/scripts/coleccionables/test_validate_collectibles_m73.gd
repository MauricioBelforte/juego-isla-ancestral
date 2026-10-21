# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-10-24
#
# M73: test headless del validador de coleccionables + integridad del catalogo.
# Se corre con: godot --headless --script res://scripts/coleccionables/test_validate_collectibles_m73.gd

extends SceneTree

var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("[OK] " + msg)
	else:
		_fallos += 1
		print("[FAIL] " + msg)

func _init() -> void:
	print("=== M73: test_validate_collectibles_m73 ===")
	var val = (load("res://scripts/coleccionables/validate_collectibles.gd") as GDScript).new()
	var r: Dictionary = val.validar()

	# 1. validador devolve un reporte con las claves
	_check(r.has("ok") and r.has("errores") and r.has("total") and r.has("categorias"),
		"validar() devuelve ok/errores/total/categorias")
	# 2. el catalogo es sano (0 errores)
	_check(bool(r.get("ok", false)), "catalogo sin errores de integridad (ids unicos + campos + rareza 0-3 + puntos>=0)")
	# 3. cantidad de items
	var total: int = int(r.get("total", 0))
	_check(total >= 23, "total de items >= 23 (actual: %d)" % total)
	# 4. categorias esperadas presentes
	var cats: Dictionary = r.get("categorias", {})
	_check(cats.has("minerales") and cats.has("animales") and cats.has("conchas"),
		"categorias base minerales/animales/conchas presentes")
	_check(cats.has("reliquias"), "categoria reliquias presente (M25/M26)")
	_check(cats.has("fragmentos"), "categoria fragmentos presente (reliquias rotas M25)")
	# 5. ids unicos (el validador ya lo cubre, pero confirmo el conteo)
	_check(int((r.get("errores", []) as Array).size()) == 0 or not r.get("ok", false),
		"si hay errores, ok debe ser false")

	# 6. chequeos de DATOS del JSON (descripcion + fuente excavar + M74 eventos)
	var fpath := "res://data/coleccionables/catalog.json"
	if FileAccess.file_exists(fpath):
		var contenido := FileAccess.get_file_as_string(fpath)
		var parsed: Variant = JSON.parse_string(contenido)
		if typeof(parsed) == TYPE_ARRAY:
			var arr: Array = parsed
			var reliquias_con_desc := 0
			var con_excavar := 0
			var con_evento := 0
			for e in arr:
				if e is Dictionary:
					var d: Dictionary = e
					if String(d.get("categoria", "")) == "reliquias" and not String(d.get("descripcion", "")).is_empty():
						reliquias_con_desc += 1
					if String(d.get("fuente", "")) == "excavar":
						con_excavar += 1
					if String(d.get("fuente", "")) == "playa_evento":
						con_evento += 1
			_check(reliquias_con_desc >= 3, "reliquias con descripcion narrativa (%d)" % reliquias_con_desc)
			_check(con_excavar >= 3, "items con fuente excavar (%d)" % con_excavar)
			_check(con_evento >= 1, "items con fuente playa_evento M74 (%d)" % con_evento)
		else:
			_check(false, "catalog.json parsea como array")
	else:
		_check(false, "catalog.json existe")

	print("=== M73: %d checks, %d fallos ===" % [8, _fallos])
	quit(_fallos)
