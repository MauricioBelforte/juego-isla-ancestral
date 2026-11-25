# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M169: Tests de CruceroAmbiental (L-04, dialogo ambiental 1 linea por NPC).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/unit/test_crucero_ambiental.gd
#
# Convencion SceneTree del repo (ver tests/unit/test_crucero_manager.gd).

extends SceneTree

var _ok: int = 0
var _fallos: int = 0
var _amb: Node = null


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _ambiental() -> Node:
	if _amb != null:
		return _amb
	_amb = load("res://scripts/crucero/crucero_ambiental.gd").new()
	root.add_child(_amb)
	return _amb


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO AMBIENTAL ===")
	var amb := _ambiental()

	var npcs: Array = amb.npcs()
	_check("6 NPCs con linea ambiental", npcs.size() == 6)

	var todos_con_linea := true
	for id: Variant in npcs:
		if String(amb.linea(id)).strip_edges() == "":
			todos_con_linea = false
	_check("cada NPC tiene 1 linea no vacia", todos_con_linea)

	_check("capitan tiene linea", amb.tiene(&"capitan") and String(amb.linea(&"capitan")).begins_with("Capitan"))
	_check("NPC inexistente devuelve vacio", String(amb.linea(&"no_existe")) == "")
	_check("tiene() rechaza inexistente", amb.tiene(&"no_existe") == false)

	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)