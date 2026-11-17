# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-15
#
# M169: Tests de CruceroEventos (actividades a bordo).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/unit/test_crucero_eventos.gd
#
# Sigue la convencion SceneTree del repo (tests/test_m65.gd). El autoload no se resuelve
# como identificador en modo --script, pero el script se puede instanciar directo.

extends SceneTree

var _ok: int = 0
var _fallos: int = 0
var _ev: Node = null


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _eventos() -> Node:
	if _ev != null:
		return _ev
	_ev = load("res://scripts/crucero/crucero_eventos.gd").new()
	root.add_child(_ev)
	return _ev


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO EVENTOS ===")
	var ev := _eventos()

	_check("5 actividades cargadas", ev.actividades().size() == 5)
	_check("casino cartas jugable", bool(ev.puede_jugar(&"crucero_casino_cartas").get("ok", false)))
	_check("rechaza actividad inexistente", not bool(ev.puede_jugar(&"no_existe").get("ok", true)))

	var limite := int(ev.info_actividad(&"crucero_casino_cartas").get("limite_diario", 1))
	var i := 0
	while i < limite + 1:
		ev.finalizar(&"crucero_casino_cartas", {"exito": true, "premio": 40})
		i += 1
	_check("contador diario = %d" % ev.veces_jugadas(&"crucero_casino_cartas"), ev.veces_jugadas(&"crucero_casino_cartas") == limite + 1)

	var p: Dictionary = ev.puede_jugar(&"crucero_casino_cartas")
	_check("bloquea por limite diario", not bool(p.get("ok", true)) and String(p.get("motivo","")) == "limite_diario")

	var tope := int(ev.info_actividad(&"crucero_torneo_cubierta").get("premio_max", 0))
	ev.finalizar(&"crucero_torneo_cubierta", {"exito": true, "premio": tope + 999})
	_check("premio por encima del tope no rompe", true)

	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)