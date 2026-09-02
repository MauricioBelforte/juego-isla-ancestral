# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M120: DLC y Expansiones — Test headless
# Valida: DlcManager (manifest data-driven, compatibilidad, activar/
# desactivar, bundles). Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M120] Test de DLC y Expansiones ===")
	_test_manifest()
	_test_compatibilidad()
	_test_bundles()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_manifest() -> void:
	print("--- Manifest: DLC data-driven ---")
	var dm := root.get_node_or_null("DlcManager")
	if dm == null:
		_check("DlcManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("DlcManager autoload presente", true)
	_check("2 DLC en manifest", dm.config.get("dlcs", []).size() == 2, "size=%d" % dm.config.get("dlcs", []).size())
	_check("isla_hielo existe", not dm.dlc("isla_hielo").is_empty())
	_check("dlc inexistente -> {}", dm.dlc("no_existe").is_empty())
	_check("versión base requerida 1.0.0", String(dm.config.get("version_base_requerida", "")) == "1.0.0")

func _test_compatibilidad() -> void:
	print("--- Compatibilidad y activación ---")
	var dm := root.get_node_or_null("DlcManager")
	_check("isla_hielo compatible con 1.0.0", dm.es_compatible("isla_hielo", "1.0.0") == true)
	_check("isla_hielo incompatible con 0.9.0", dm.es_compatible("isla_hielo", "0.9.0") == false)
	_check("dlc inexistente incompatible", dm.es_compatible("no_existe", "1.0.0") == false)
	_check("activar isla_hielo", dm.activar("isla_hielo") == true)
	_check("isla_hielo activo", dm.esta_activo("isla_hielo") == true)
	_check("activar inexistente falla", dm.activar("no_existe") == false)
	dm.desactivar("isla_hielo")
	_check("desactivar isla_hielo", dm.esta_activo("isla_hielo") == false)

func _test_bundles() -> void:
	print("--- Bundles: agrupación de DLC ---")
	var dm := root.get_node_or_null("DlcManager")
	_check("bundle_deluxe existe", not dm.bundle("bundle_deluxe").is_empty())
	_check("descuento 15%", float(dm.bundle("bundle_deluxe").get("descuento", 0)) == 0.15)
	_check("bundle inexistente -> {}", dm.bundle("no_existe").is_empty())
	var contiene = dm.bundles_que_contienen("isla_hielo")
	_check("bundle contiene isla_hielo", "bundle_deluxe" in contiene, "bundles=%s" % str(contiene))

func _summary() -> void:
	print("=== Resumen M120: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M120 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M120 OK — todos los checks pasaron")
		quit(0)