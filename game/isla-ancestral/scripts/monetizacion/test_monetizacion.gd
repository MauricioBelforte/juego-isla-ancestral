# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M95: Test headless del MonetizacionManager.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/monetizacion/test_monetizacion.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var m95 := root.get_node_or_null("MonetizacionManager")
	_check(m95 != null, "MonetizacionManager autoload presente")
	if m95 == null:
		print("=== TEST M95: 1 fallo(s) ===")
		quit(1)
		return
	# Catálogo cargado
	var ediciones: Dictionary = m95.get_ediciones()
	_check(ediciones.size() >= 3, "3 ediciones cargadas: %d" % ediciones.size())
	var dlcs: Dictionary = m95.get_dlc()
	_check(dlcs.size() >= 2, "2 DLC cargados: %d" % dlcs.size())
	# Compra de edición
	var r: Dictionary = m95.comprar_edicion("standard")
	_check(bool(r.get("ok", false)), "comprar_edicion(standard) OK")
	_check(float(r.get("precio", 0)) == 24.99, "precio standard = $24.99")
	# Ya comprada
	var r2: Dictionary = m95.comprar_edicion("standard")
	_check(not bool(r2.get("ok", true)), "re-compra rechazada")
	# Edición inexistente
	var r3: Dictionary = m95.comprar_edicion("inexistente")
	_check(not bool(r3.get("ok", true)), "edición inexistente rechazada")
	# DLC
	var r4: Dictionary = m95.comprar_dlc("expansion_corales")
	_check(bool(r4.get("ok", false)), "comprar_dlc(expansion) OK")
	_check(m95.esta_comprado("expansion_corales"), "esta_comprado(expansion) = true")
	# M94/M152: sin P2W
	var offenders: Array = m95.auditar_p2w()
	_check(offenders.size() == 0, "auditar_p2w sin offenders (M94/M152 OK)")
	# Impuestos
	var imp: float = m95.calcular_impuesto(24.99, "steam")
	_check(absf(imp - 24.99 * 0.30) < 0.01, "impuesto Steam 30%%: $%.2f" % imp)
	# Persistencia
	var compras: Dictionary = m95.get_compras()
	_check(compras.has("standard"), "compra persistida")
	_check(compras.has("expansion_corales"), "DLC persistido")
	print("=== TEST M95: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
