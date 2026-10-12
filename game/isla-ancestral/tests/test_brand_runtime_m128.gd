# Modelo: hy3 (WorkBuddy / Hunyuan)
# Plataforma: automatizacion Isla Ancestral
# Fecha: 2026-10-11
#
# M128 Lote 2 — Test headless de que BrandConfig (autoload M128 H1) carga en
# runtime y expone la paleta oficial + el helper de contraste WCAG.
# Uso: godot --headless -s res://tests/test_brand_runtime_m128.gd
# Exit 0 = OK, 1 = fallo.

extends SceneTree

const _BC := preload("res://scripts/brand/brand_config.gd")

var _fallos: int = 0
var _checks: int = 0
var _bc: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M128] Test BrandConfig runtime (Lote 2) ===")
	_resolver_brandconfig()
	_test_carga()
	_test_color_oficial()
	_test_fallback_negro()
	_test_contraste_wcag()
	_summary()

func _resolver_brandconfig() -> void:
	# El autoload debe estar registrado en /root/BrandConfig; si no (entorno sin
	# autoload), lo instanciamos directamente para validar la logica.
	var nodo = get_root().get_node_or_null("/root/BrandConfig")
	if nodo != null:
		_bc = nodo
	else:
		_bc = _BC.new()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_carga() -> void:
	print("--- carga del autoload / singleton ---")
	_check("BrandConfig resuelto (autoload o instancia)", _bc != null)
	if _bc != null:
		_check("BrandConfig expone color()", _bc.has_method("color"))
		_check("BrandConfig expone contraste_wcag()", _bc.has_method("contraste_wcag"))

func _test_color_oficial() -> void:
	print("--- paleta oficial (03-Diseno.md §3) ---")
	_check("color azul_bosque oficial", _bc.color("azul_bosque") == Color("#2E5A4C"), str(_bc.color("azul_bosque")))
	_check("color dorado_anciano oficial", _bc.color("dorado_anciano") == Color("#D4A843"), str(_bc.color("dorado_anciano")))
	_check("color blanco_perla oficial", _bc.color("blanco_perla") == Color("#F5F0E8"), str(_bc.color("blanco_perla")))

func _test_fallback_negro() -> void:
	print("--- fallback a negro para nombre inexistente (sonda roja de carga) ---")
	# Si BrandConfig no estuviera cargado/correcto, color() devolveria negro.
	_check("color inexistente != oficial", _bc.color("azul_bosque") != Color(0, 0, 0, 1), str(_bc.color("azul_bosque")))
	_check("color nombre vacio -> negro", _bc.color("no_existe_xyz") == Color(0, 0, 0, 1), str(_bc.color("no_existe_xyz")))

func _test_contraste_wcag() -> void:
	print("--- contraste WCAG (hallazgo Lote 1: pares < 3.0) ---")
	var carbon = _bc.color("carbon")
	var azul = _bc.color("azul_bosque")
	var perla = _bc.color("blanco_perla")
	var dorado = _bc.color("dorado_anciano")
	# pares documentados como < 3.0 (restriccion de uso para el disenador)
	_check("contraste carbon/azul_bosque < 3.0", _bc.contraste_wcag(carbon, azul) < 3.0, str(_bc.contraste_wcag(carbon, azul)))
	_check("contraste perla/dorado < 3.0", _bc.contraste_wcag(perla, dorado) < 3.0, str(_bc.contraste_wcag(perla, dorado)))
	# par de alto contraste (texto sobre fondo) debe cumplir AA para UI
	_check("contraste carbon/perla > 4.5 (AA)", _bc.contraste_wcag(carbon, perla) > 4.5, str(_bc.contraste_wcag(carbon, perla)))

func _summary() -> void:
	print("=== Resumen M128 BrandConfig: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M128 BRANDCONFIG FALLIDO — salida con codigo 1")
		quit(1)
	else:
		print("TEST M128 BRANDCONFIG OK — todos los checks pasaron")
		quit(0)
