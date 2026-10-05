# Modelo: agnes-3.0-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-05
#
# M129: Merchandising — Test headless (v2: datos enriquecidos + MerchManager)
# Valida: MerchValidator (data-driven) + MerchManager (capa de servicio).
# Exit code != 0 si falla. Se ejecuta: godot --headless -s res://scripts/legal/test_merch_m129.gd
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/merch_validator.gd")
const _SC_MANAGER := preload("res://scripts/legal/merch_manager.gd")
const RUTA_DATA := "res://data/legal/merchandising.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M129] Test de Merchandising v2 ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_test_margenes_precios()
	_test_manager()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_data() -> void:
	print("--- Datos: merchandising.json (v2) ---")
	var data = _cargar()
	_check("merchandising.json cargado", not data.is_empty())
	_check("version 2", int(data.get("version", 0)) == 2, "version=%s" % str(data.get("version")))
	var prods: Array = data.get("productos", [])
	_check("10 productos", prods.size() == 10, "size=%d" % prods.size())
	var ids := prods.map(func(p): return String(p.get("id", "")))
	_check("tiene camisetas", "camisetas" in ids)
	_check("tiene figuras", "figuras" in ids)
	_check("tiene peluches", "peluches" in ids)
	_check("politicas presentes", not data.get("politicas", {}).is_empty())

func _test_validator() -> void:
	print("--- MerchValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- MerchValidator: errores detectados ---")
	var malo = {
		"version": 2,
		"productos": [
			{"id": "", "producto": "", "tipo": "", "estado": ""},
			{"id": "x", "producto": "X", "tipo": "textil", "estado": "diseno",
			 "margen": [0.7, 0.4], "precio_usd": [0.0, 5]}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	var s := str(errores)
	_check("sin id detectado", s.contains("sin id"))
	_check("tipo desconocido NO en caso textil", not s.contains("desconocido"))
	_check("margen fuera de rango detectado", s.contains("margen"))
	_check("precio min>0 detectado", s.contains("min debe ser > 0") or s.contains("min"))
	_check("sin políticas detectado", s.contains("políticas"))

func _test_margenes_precios() -> void:
	print("--- Rangos: margenes y precios ---")
	var data = _cargar()
	var margenes_ok := true
	var precios_ok := true
	for p in data.get("productos", []):
		var m: Variant = p.get("margen", null)
		if m == null:
			m = [float(p["margen_estimado"]), float(p["margen_estimado"])] if p.has("margen_estimado") else [0.0, 0.0]
		if float(m[0]) < 0.0 or float(m[1]) > 1.0 or float(m[0]) > float(m[1]):
			margenes_ok = false
		var pr: Variant = p.get("precio_usd", null)
		if pr != null:
			if float(pr[0]) <= 0.0 or float(pr[0]) > float(pr[1]):
				precios_ok = false
	_check("todos los margenes en [0,1] y min<=max", margenes_ok)
	_check("todos los precios min>0 y min<=max", precios_ok)

func _test_manager() -> void:
	print("--- MerchManager: capa de servicio ---")
	var mm: Variant = _SC_MANAGER.new()
	mm.cargar()
	_check("manager cargado", mm.esta_cargado(), "error=%s" % str(mm._error_carga))
	_check("get_product_ids = 10", mm.get_product_ids().size() == 10, "size=%d" % mm.get_product_ids().size())
	_check("get_product('tazas') tipo=ceramica", str(mm.get_product("tazas").get("tipo", "")) == "ceramica")
	_check("get_margen('figuras') = [0.4,0.5]",
		mm.get_margen("figuras") == [0.4, 0.5], "margen=%s" % str(mm.get_margen("figuras")))
	_check("get_precio_usd('artbook') = [30.0,50.0]",
		mm.get_precio_usd("artbook") == [30.0, 50.0], "precio=%s" % str(mm.get_precio_usd("artbook")))
	_check("validar() = 0 errores", mm.validar().is_empty(), "errores=%s" % str(mm.validar()))
	_check("get_product inexistente = {}", mm.get_product("no_existe").is_empty())
	_check("get_politicas no vacio", not mm.get_politicas().is_empty())

func _summary() -> void:
	print("=== Resumen M129: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M129 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M129 OK — todos los checks pasaron")
		quit(0)
