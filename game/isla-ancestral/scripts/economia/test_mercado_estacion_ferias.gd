extends SceneTree

## Test headless M38 (iter. 3): RF9 mercado/estacion + RF11 anti-grind
## + RF13 reputacion + RF14 ferias. Uso:
## godot --headless --path game/isla-ancestral --script res://scripts/economia/test_mercado_estacion_ferias.gd

var _fallos := 0
var _checks := 0
var _pm = null
var _eco = null

func _initialize() -> void:
	print("=== TEST MERCADO: ESTACION + ANTI-GRIND + REPUTACION + FERIAS (M38 iter.3) ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	var cls: Script = load("res://scripts/economia/price_manager.gd")
	if cls == null or not cls.can_instantiate():
		print("[FAIL] no se pudo cargar price_manager.gd"); quit(1); return
	_pm = cls.new()
	_pm._catalog = _CatFake.new()
	_eco = root.get_node_or_null("EconomyManager")
	_check("autoload EconomyManager presente", _eco != null)
	if _eco == null:
		quit(1); return

	var compra_base: int = int(_pm.precio_compra_vigente("ECO-NO-SEASON"))
	var venta_base: int = int(_pm.precio_venta_vigente("ECO-NO-SEASON"))

	# ── RF11: sin estacion/feria, precios base estables ──
	_check("compra base 100 sin ajustes", compra_base == 100)
	_check("venta base 60 (tope 60%) sin ajustes", venta_base == 60)
	_check("RF11: venta SIEMPRE menor que compra (anti-grind)", venta_base < compra_base)

	# ── RF9: ajuste estacional ──
	_pm.forzar_estacion("verano")
	var compra_in: int = int(_pm.precio_compra_vigente("ECO-SEASON-IN"))
	var venta_in: int = int(_pm.precio_venta_vigente("ECO-SEASON-IN"))
	var compra_out: int = int(_pm.precio_compra_vigente("ECO-SEASON-OUT"))
	var venta_out: int = int(_pm.precio_venta_vigente("ECO-SEASON-OUT"))
	_check("RF9 estacional en-temporada +5 por ciento (compra 105)", compra_in == 105)
	_check("RF9 estacional en-temporada +5 por ciento (venta 63)", venta_in == 63)
	_check("RF9 fuera de temporada -10 por ciento (compra 90)", compra_out == 90)
	_check("RF9 fuera de temporada -10 por ciento (venta 54)", venta_out == 54)
	_pm.forzar_estacion("")
	var compra_reset: int = int(_pm.precio_compra_vigente("ECO-NO-SEASON"))
	_check("RF9 reset: compra vuelve a 100", compra_reset == 100)

	# ── RF14: precios especiales de feria ──
	_pm.aplicar_precios_feria(1.2, 1.2)
	var compra_feria: int = int(_pm.precio_compra_vigente("ECO-NO-SEASON"))
	var venta_feria: int = int(_pm.precio_venta_vigente("ECO-NO-SEASON"))
	_check("RF14 feria x1.2 en compra (120)", compra_feria == 120)
	_check("RF14 feria x1.2 en venta (72)", venta_feria == 72)
	_check("RF14 feria activa = true", _pm.esta_feria_activa())
	var emitidas: Array = [0]
	_pm.tabla_precios_actualizada.connect(func(t): emitidas[0] += 1)
	_pm.recalcular_tabla_dia()
	_check("RF14 recalcular_tabla_dia emite senal UI", emitidas[0] >= 1)
	_pm.limpiar_precios_feria()
	var compra_limp: int = int(_pm.precio_compra_vigente("ECO-NO-SEASON"))
	var venta_limp: int = int(_pm.precio_venta_vigente("ECO-NO-SEASON"))
	_check("RF14 limpiar feria vuelve a 100/60", compra_limp == 100 and venta_limp == 60)
	_check("RF14 feria activa = false tras limpiar", not _pm.esta_feria_activa())

	# ── RF11 reforzado: feria agresiva en venta NUNCA supera la compra ──
	_pm.aplicar_precios_feria(1.0, 5.0)
	var compra_agr: int = int(_pm.precio_compra_vigente("ECO-NO-SEASON"))
	var venta_agr: int = int(_pm.precio_venta_vigente("ECO-NO-SEASON"))
	_check("RF11 feria x5 en venta limitada a la compra (anti-rentable)", venta_agr <= compra_agr and venta_agr == compra_agr)
	_pm.limpiar_precios_feria()

	# ── RF13 (parcial): reputacion ──
	_check("reputacion inicial 50", int(_eco.get_reputacion()) == 50)
	var recibidas: Array = []
	_eco.reputacion_cambiada.connect(func(r): recibidas.append(r))
	_eco.ajustar_reputacion(20)
	_check("reputacion sube a 70", int(_eco.get_reputacion()) == 70)
	_check("senal reputacion_cambiada emitida", recibidas.size() >= 1)
	_eco.ajustar_reputacion(999)
	_check("reputacion clamp a REPUTACION_MAX (100)", int(_eco.get_reputacion()) == 100)

	var datos: Dictionary = _eco.get_save_data()
	_check("get_save_data incluye reputacion (100)", datos.has("reputacion") and int(datos["reputacion"]) == 100)
	_eco.restore_save_data({"reputacion": 33, "saldo": 10, "historial": []})
	_check("restore aplica reputacion (33)", int(_eco.get_reputacion()) == 33)
	var antes: int = int(_eco.get_reputacion())
	_eco.depositar_monedas(1)
	_check("depositar suma +1 de reputacion", int(_eco.get_reputacion()) == antes + 1)

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS")
		quit(1)
	else:
		print("MERCADO ESTACION + ANTI-GRIND + REPUTACION + FERIAS OK")
		quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)


## Catalogo falso: get_price_def(item_id) -> def con precio_compra y temporada_bonus.
class _CatFake:
	extends RefCounted

	func get_price_def(item_id: String):
		var d := {
			"ECO-NO-SEASON":   {"precio_compra": 100, "temporada_bonus": ""},
			"ECO-SEASON-IN":   {"precio_compra": 100, "temporada_bonus": "verano"},
			"ECO-SEASON-OUT":  {"precio_compra": 100, "temporada_bonus": "invierno"},
		}
		if not d.has(item_id):
			return null
		return _Def.new(d[item_id]["precio_compra"], d[item_id]["temporada_bonus"])

class _Def:
	extends RefCounted

	var precio_compra: int = 0
	var temporada_bonus: String = ""

	func _init(pc: int, tb: String) -> void:
		precio_compra = pc
		temporada_bonus = tb
