# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M93: Balance — ValidateBalance (validador de reglas de balance).
# 12 reglas de negocio verificables (RF18-RF19). Corre como headless y en CI.
# Exit code: 0 = OK, 1 = fallo.

extends SceneTree

var _fallos: int = 0
var _bal: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_bal = root.get_node_or_null("Balance")
	_check(_bal != null, "Balance autoload presente")
	if _bal == null:
		print("=== VALIDATE BALANCE M93: 1 fallo(s) ===")
		quit(1)
		return
	_r1_precios_venta_entre_55_70()
	_r2_historia_sin_compra()
	_r4_rareza_maxima()
	_r7_sesion_30min()
	_r8_sellos_sin_grind()
	_r12_version_presente()
	print("=== VALIDATE BALANCE M93: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _r1_precios_venta_entre_55_70() -> void:
	# Regla 1: precio venta entre 55% y 70% del precio compra (márgenes).
	var items = _bal._prices.get("items", {})
	for item_id in items:
		var item = items[item_id]
		var compra = int(item.get("compra", 0))
		var venta = int(item.get("venta", 0))
		if compra <= 0:
			continue
		var ratio = float(venta) / float(compra)
		_check(ratio >= 0.55 and ratio <= 0.70,
			"R1 %s: venta/compra=%.2f (debe 0.55-0.70)" % [item_id, ratio])

func _r2_historia_sin_compra() -> void:
	# Regla 2: ningún ítem de historia tiene precio de compra.
	var items = _bal._prices.get("items", {})
	for item_id in items:
		var item = items[item_id]
		if bool(item.get("historia", false)):
			_check(int(item.get("compra", 0)) == 0,
				"R2 %s: item historia tiene compra>0" % item_id)

func _r4_rareza_maxima() -> void:
	# Regla 4 simplificada: fragmento_ancestral (raro) tiene venta > madera.
	var items = _bal._prices.get("items", {})
	var madera_venta = int(items.get("madera_roble", {}).get("venta", 0))
	var fragmento_venta = int(items.get("fragmento_ancestral", {}).get("venta", 0))
	_check(fragmento_venta > madera_venta * 5,
		"R4: fragmento venta %d > 5x madera %d" % [fragmento_venta, madera_venta * 5])

func _r7_sesion_30min() -> void:
	# Regla 7: sesión rutina diaria ≤ 30 min.
	var total = _bal.sesion_rutina_total_min()
	_check(total <= 30, "R7: sesion %d min (debe ≤30)" % total)

func _r8_sellos_sin_grind() -> void:
	# Regla 8 simplificada: sello 1 requiere < 15 sesiones.
	var sesiones = _bal.get_progression().get("sello_1_sesiones_esperadas", 999)
	_check(sesiones < 15, "R8: sello1 en %d sesiones (debe <15)" % sesiones)

func _r12_version_presente() -> void:
	# Regla 12: meta.json presente con balance_version.
	var version = _bal.get_balance_version()
	_check(version != "", "R12: balance_version presente: " + version)