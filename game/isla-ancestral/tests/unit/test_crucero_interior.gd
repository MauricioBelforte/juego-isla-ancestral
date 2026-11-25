# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M169: Tests de CruceroInterior (luces/puertas/spawn por cubierta).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/unit/test_crucero_interior.gd
#
# Convencion SceneTree del repo (ver tests/unit/test_crucero_manager.gd).
# Nota: las lambdas de GDScript capturan por VALOR; por eso los contadores de
# senales son variables MIEMBRO (no locales).

extends SceneTree

var _ok: int = 0
var _fallos: int = 0
var _it: Node3D = null
var _emit: int = 0
var _ult: int = -1


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _interior() -> Node3D:
	if _it != null:
		return _it
	_it = load("res://scripts/crucero/crucero_interior.gd").new()
	root.add_child(_it)
	return _it


func _nuevo_player() -> Node3D:
	var n := Node3D.new()
	n.add_to_group("player")
	root.add_child(n)
	return n


func _on_puerta(d: int) -> void:
	_emit += 1
	_ult = d


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO INTERIOR ===")
	var it := _interior()

	# Ciclo de puertas 1->2->3->4->1.
	it.cubierta = 1
	_check("destino 1 -> 2", it.destino_siguiente() == 2)
	it.cubierta = 4
	_check("destino 4 -> 1 (ciclo)", it.destino_siguiente() == 1)

	# Luces: _ready las apaga; activar las enciende; desactivar las apaga.
	var l := OmniLight3D.new()
	it.add_child(l)
	var arr: Array[OmniLight3D] = [l]
	it.luces = arr
	it._apagar_luces()
	_check("luces apagadas en reposo", l.visible == false)
	it.activar()
	_check("activar enciende luces", l.visible == true and it._activa == true)
	it.desactivar()
	_check("desactivar apaga luces", l.visible == false and it._activa == false)

	# Puerta: jugador en grupo player cruza -> emite puerta_cruzada(destino).
	it.puerta_cruzada.connect(_on_puerta)
	it.cubierta = 2
	it.activar()
	it._on_body_entered(_nuevo_player())
	_check("puerta emite al cruzar jugador", _emit == 1 and _ult == 3)

	# Un cuerpo que NO es jugador no dispara.
	it._on_body_entered(Node3D.new())
	_check("cuerpo no-jugador no dispara", _emit == 1)

	# configurar() fija cubierta y spawn.
	var spawn := Marker3D.new()
	it.configurar(3, [], null, spawn)
	_check("configurar fija cubierta 3", it.cubierta == 3)
	_check("punto_de_spawn usa el marcador", it.punto_de_spawn() == spawn.global_position)

	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)