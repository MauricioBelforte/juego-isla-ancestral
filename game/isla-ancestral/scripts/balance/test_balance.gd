# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M93: Test de BalanceService (precios, recompensas, timing, progresión, amistad).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/balance/test_balance.gd

extends SceneTree

var _fallos: int = 0
var _bal: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_bal = root.get_node_or_null("Balance")
	_check(_bal != null, "Balance autoload presente")
	if _bal == null:
		print("=== TEST M93 BALANCE: 1 fallo(s) ===")
		quit(1)
		return
	_test_precios()
	_test_recompensas()
	_test_timing()
	_test_progresion()
	_test_amistad()
	_test_meta()
	print("=== TEST M93 BALANCE: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_precios() -> void:
	_check(_bal.get_price("madera_roble") == 10, "madera precio 10")
	_check(_bal.get_sell_price("madera_roble") == 6, "madera venta 6")
	_check(_bal.get_price("fragmento_ancestral") == 0, "fragmento sin precio compra (historia)")
	_check(_bal.es_item_historia("fragmento_ancestral"), "fragmento es historia")
	_check(not _bal.es_item_historia("madera_roble"), "madera no es historia")

func _test_recompensas() -> void:
	var rec: Dictionary = _bal.get_reward("recoleccion_madera")
	_check(rec.get("ao", 0) == 5, "recoleccion madera ao 5")
	var sello: Dictionary = _bal.get_reward("sello_obtenido")
	_check(sello.get("ao", 0) == 500, "sello ao 500")

func _test_timing() -> void:
	_check(_bal.sesion_rutina_total_min() == 30, "sesion rutina 30 min")
	var timing: Dictionary = _bal.get_timing()
	_check(timing.get("recoleccion_diaria_min", 0) == 10, "recoleccion 10 min")

func _test_progresion() -> void:
	var prog: Dictionary = _bal.get_progression()
	_check(prog.get("dinero_diario_promedio_ao", 0) == 80, "dinero diario 80 ao")
	_check(prog.get("sello_1_tiempo_horas", 0) == 8, "sello 1 en 8h")

func _test_amistad() -> void:
	var umbrales: Dictionary = _bal.get_friendship_thresholds()
	_check(umbrales.get("nivel_2", 0) == 30, "amistad nivel 2 = 30")
	var puntos: Dictionary = _bal.get_friendship_points()
	_check(puntos.get("charla", 0) == 5, "charla amistad 5 puntos")

func _test_meta() -> void:
	_check(_bal.get_balance_version() != "", "balance_version presente")
	var meta: Dictionary = _bal.obtener_meta()
	_check(meta.get("schema_version", 0) == 1, "schema_version 1")