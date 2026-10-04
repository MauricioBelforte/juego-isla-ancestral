# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-04
#
# M38 BUG-047: Test que FALLA contra el pre-fix (precio_venta = 0)
# y PASA post-fix (precio_venta = valor del catálogo).
# Los 5 items sell-only: fragmento_ancestral(75), talisman_ancestral(200),
# pico_cobre(60), hacha_cobre(55), caja_almacenamiento(40).

extends SceneTree

const _RUTA_CAT := "res://data/economy/econ_prices.tres"
var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M38 BUG-047] Test sell-only items ===")
	var em := root.get_node_or_null("EconomyManager")
	if em == null:
		print("[FAIL] EconomyManager no existe como autoload")
		quit(1)
		return
	var pm_ref = em.precios
	if pm_ref == null:
		em._asegurar_precios()
		pm_ref = em.precios
	if pm_ref == null:
		print("[FAIL] EconomyManager.precios es null")
		quit(1)
		return

	# Los 5 items sell-only y sus precios esperados del catálogo
	var items: Array = [
		["fragmento_ancestral", 75],
		["talisman_ancestral", 200],
		["pico_cobre", 60],
		["hacha_cobre", 55],
		["caja_almacenamiento", 40],
	]
	for entry in items:
		var id: String = entry[0]
		var esperado: int = entry[1]
		var actual: int = pm_ref.precio_venta_vigente(id)
		_check("precio_venta_vigente('%s') == %d" % [id, esperado], actual == esperado, "actual=%d" % actual)

	# Anti-arbitraje: venta del pico_cobre NO debe ser 0
	var venta_pico: int = pm_ref.precio_venta_vigente("pico_cobre")
	_check("anti-arbitraje: venta pico_cobre > 0", venta_pico > 0, "venta=%d" % venta_pico)

	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _summary() -> void:
	print("=== Resumen BUG-047: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST FALLIDO (rojo esperado pre-fix)")
		quit(1)
	else:
		print("TEST OK — todos los sell-only items tienen precio correcto")
		quit(0)
