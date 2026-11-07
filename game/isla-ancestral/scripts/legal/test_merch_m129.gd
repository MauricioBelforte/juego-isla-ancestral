# Modelo: agnes-3.0-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-05
#
# M129: Merchandising — Test headless (v3: datos enriquecidos + MerchManager + stock)
# Valida: MerchValidator (data-driven) + MerchManager (capa de servicio) +
# control de stock y numeracion de tiradas limitadas (item L101).
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
	print("=== [M129] Test de Merchandising v3 ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_test_margenes_precios()
	_test_manager()
	_test_stock()
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
	print("--- Datos: merchandising.json (v3) ---")
	var data = _cargar()
	_check("merchandising.json cargado", not data.is_empty())
	_check("version 3", int(data.get("version", 0)) == 3, "version=%s" % str(data.get("version")))
	var prods: Array = data.get("productos", [])
	_check("10 productos", prods.size() == 10, "size=%d" % prods.size())
	var ids := prods.map(func(p): return String(p.get("id", "")))
	_check("tiene camisetas", "camisetas" in ids)
	_check("tiene figuras", "figuras" in ids)
	_check("tiene peluches", "peluches" in ids)
	_check("politicas presentes", not data.get("politicas", {}).is_empty())
	var tiradas: Array = data.get("tiradas_limitadas", [])
	_check("3 tiradas limitadas", tiradas.size() == 3, "size=%d" % tiradas.size())
	var skus := tiradas.map(func(t): return String(t.get("sku", "")))
	_check("tiene artbook de pasta dura", "artbook_pasta_dura" in skus)
	_check("tiene vinilo", "vinilo_soundtrack" in skus)

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
	var malo_tiradas = {
		"productos": [{"id": "artbook", "producto": "Artbook", "tipo": "impreso", "estado": "diseno"}],
		"politicas": {"margen_objetivo": [0.4, 0.5]},
		"tiradas_limitadas": [
			{"sku": "a", "producto_id": "artbook", "unidades": 10},
			{"sku": "a", "producto_id": "artbook", "unidades": 0},
			{"sku": "b", "producto_id": "no_existe", "unidades": 5}
		]
	}
	var et := str(_SC_VALIDATOR.validar(malo_tiradas))
	_check("tirada duplicada detectada", et.contains("duplicada"))
	_check("tirada unidades<=0 detectada", et.contains("unidades debe ser > 0"))
	_check("tirada producto inexistente detectada", et.contains("no existe en productos"))

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

func _test_stock() -> void:
	print("--- MerchManager: stock y numeracion de tiradas limitadas ---")
	var mm: Variant = _SC_MANAGER.new()
	mm.cargar()
	var sku := "artbook_pasta_dura"
	_check("3 tiradas cargadas", mm.get_tirada_ids().size() == 3, "ids=%s" % str(mm.get_tirada_ids()))
	_check("artbook es tirada limitada", mm.es_tirada_limitada(sku))
	_check("artbook total 500", mm.unidades_totales(sku) == 500, "total=%d" % mm.unidades_totales(sku))
	_check("artbook disponibles 500", mm.unidades_disponibles(sku) == 500)
	_check("camisetas NO es tirada limitada", not mm.es_tirada_limitada("camisetas"))
	_check("no-limitada disponibles = -1", mm.unidades_disponibles("camisetas") == -1)
	_check("no-limitada no reserva",
		String(mm.reservar_unidades("camisetas", 1).get("motivo", "")) == "sku_no_limitado")
	# Preventa: reservar no asigna numero.
	var r1: Dictionary = mm.reservar_unidades(sku, 3)
	_check("reservar 3 ok", bool(r1.get("ok", false)), "r=%s" % str(r1))
	_check("reservadas 3", mm.unidades_reservadas(sku) == 3)
	_check("disponibles 497", mm.unidades_disponibles(sku) == 497)
	_check("reserva no asigna numeros", mm.get_numeros_asignados(sku).is_empty())
	# Venta parcial de la reserva: numeros correlativos.
	var v1: Dictionary = mm.confirmar_venta(sku, 2)
	_check("venta 2 ok", bool(v1.get("ok", false)), "v=%s" % str(v1))
	_check("venta 2 asigna [1,2]", v1.get("numeros", []) == [1, 2], "nums=%s" % str(v1.get("numeros")))
	_check("vendidas 2", mm.unidades_vendidas(sku) == 2)
	_check("reservadas 1 tras venta", mm.unidades_reservadas(sku) == 1)
	var v2: Dictionary = mm.confirmar_venta(sku, 2)
	_check("venta 2 consume reserva + libre", v2.get("numeros", []) == [3, 4], "nums=%s" % str(v2.get("numeros")))
	_check("reservadas 0", mm.unidades_reservadas(sku) == 0)
	_check("disponibles 496", mm.unidades_disponibles(sku) == 496)
	# Rechazos: no se puede sobrevender ni reservar de mas.
	var exceso: Dictionary = mm.reservar_unidades(sku, 10000)
	_check("sobre-reserva rechazada",
		not bool(exceso.get("ok", true)) and String(exceso.get("motivo", "")) == "stock_insuficiente",
		"r=%s" % str(exceso))
	_check("stock intacto tras rechazo", mm.unidades_disponibles(sku) == 496)
	var libres: Dictionary = mm.confirmar_venta(sku, 10000)
	_check("sobre-venta rechazada",
		not bool(libres.get("ok", true)) and String(libres.get("motivo", "")) == "stock_insuficiente")
	# Persistencia (contrato M59): las dos cifras y los numeros sobreviven.
	var data: Dictionary = mm.get_save_data()
	var mm2: Variant = _SC_MANAGER.new()
	mm2.cargar()
	mm2.restore_save_data(data)
	_check("save/restore vendidas 4", mm2.unidades_vendidas(sku) == 4)
	_check("save/restore disponibles 496", mm2.unidades_disponibles(sku) == 496)
	_check("save/restore numeros [1,2,3,4]", mm2.get_numeros_asignados(sku) == [1, 2, 3, 4])
	_check("numeros unicos", _unicos(mm2.get_numeros_asignados(sku)))
	_check("seccion de guardado = merch", mm.get_section_name() == "merch")
	# Reinicio explicito (nueva partida / test).
	mm2.reiniciar_tiradas()
	_check("reiniciar deja 0 vendidas", mm2.unidades_vendidas(sku) == 0)
	_check("reiniciar deja 500 disponibles", mm2.unidades_disponibles(sku) == 500)

func _unicos(arr: Array) -> bool:
	var vistos: Dictionary = {}
	for n in arr:
		if vistos.has(n):
			return false
		vistos[n] = true
	return true

func _summary() -> void:
	print("=== Resumen M129: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M129 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M129 OK — todos los checks pasaron")
		quit(0)
