extends SceneTree

## Prueba del límite diario de ventas por banda de rareza (M38, tabla §8 actualizada).
## Uso: godot --headless --path game/isla-ancestral --script res://scripts/economia/test_topos_banda.gd
## Valida:
##  - Comun/poco_comun -> limite 3
##  - Raro -> limite 2
##  - Epico -> limite 1
##  - item sin override -> default 3
##  - Registro de ventas: exceder el limite -> precio_rebajado_hoy

var _fallos := 0
var _checks := 0
var _pm = null

func _initialize() -> void:
	print("=== TEST TOPES POR BANDA DE RAREZA (M38) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	if cls == null or not cls.can_instantiate():
		print("[FAIL] no se pudo cargar price_manager.gd")
		quit(1)
		return
	_pm = cls.new()

	# Inyeccion de un catalogo falso que expone get_price_def(item_id) con el
	# campo "rareza", igual que EconomyPriceCatalog.get_price_def (M38).
	_pm._catalog = _CatFake.new()

	# Via 1: el catalogo define la banda explicitamente.
	_check("comun -> 3", _pm.limite_ventas_dia("item_comun") == 3)
	_check("poco_comun -> 3", _pm.limite_ventas_dia("item_poco") == 3)
	_check("raro -> 2", _pm.limite_ventas_dia("item_raro") == 2)
	_check("epico -> 1", _pm.limite_ventas_dia("item_epico") == 1)

	# Via 2: sin override -> default 3.
	_check("item sin override -> default 3", _pm.limite_ventas_dia("no_existe") == 3)
	_check("item vacio -> default 3", _pm.limite_ventas_dia("") == 3)

	# Normalizacion de variantes de escritura.
	_check("variante 'legendario' -> 1", _pm.limite_ventas_dia("item_legend") == 1)
	_check("variante 'uncommon' -> 3", _pm.limite_ventas_dia("item_uncommon") == 3)

	# Registro de ventas: rebaja cuando se excede el limite.
	_pm.registrar_venta("item_epico", 2, 1)
	_check("epico tras 2 ventas -> rebajado", _pm.precio_rebajado_hoy("item_epico"))
	_pm.registrar_venta("item_comun", 2, 1)
	_check("comun tras 2 ventas -> NO rebajado", not _pm.precio_rebajado_hoy("item_comun"))
	_pm.registrar_venta("item_comun", 2, 1)
	_check("comun tras 4 ventas -> rebajado", _pm.precio_rebajado_hoy("item_comun"))

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS")
		quit(1)
	else:
		print("TOPES POR BANDA OK")
		quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)


## Catalogo falso para la prueba: reproduce la interfaz publica minima de
## EconomyPriceCatalog.get_price_def(item_id) -> PriceDefinition | null.
class _CatFake:
	extends RefCounted

	func get_price_def(item_id: String):
		var defs := {
			"item_comun": "comun",
			"item_poco": "poco_comun",
			"item_raro": "raro",
			"item_epico": "epico",
			"item_legend": "legendario",
			"item_uncommon": "uncommon",
		}
		if not defs.has(item_id):
			return null
		return _Def.new(item_id, defs[item_id])

class _Def:
	extends RefCounted

	var item_id: String = ""
	var rareza: String = ""

	func _init(p_item_id: String, p_rareza: String) -> void:
		item_id = p_item_id
		rareza = p_rareza