# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M169: Tests de CruceroPuerto (Area3D embarque/desembarco).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/unit/test_crucero_puerto.gd
#
# Convencion SceneTree del repo (ver tests/unit/test_crucero_manager.gd).
# Nota: las lambdas de GDScript capturan por VALOR; los contadores de senales
# son variables MIEMBRO (no locales).

extends SceneTree

var _ok: int = 0
var _fallos: int = 0
var _puerto: Area3D = null
var _cm: Node = null
var _emb: int = 0
var _desemb: int = 0
var _ult: String = ""


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _manager() -> Node:
	if _cm != null:
		return _cm
	_cm = root.get_node_or_null("CruceroManager")
	if _cm == null:
		var script: Script = load("res://scripts/crucero/crucero_manager.gd")
		_cm = script.new()
		_cm.name = "CruceroManager"
		root.add_child(_cm)
	return _cm


func _puerto_area() -> Area3D:
	if _puerto != null:
		return _puerto
	_puerto = load("res://scripts/crucero/crucero_puerto.gd").new()
	root.add_child(_puerto)
	return _puerto


func _nuevo_player() -> Node3D:
	var n := Node3D.new()
	n.add_to_group("player")
	root.add_child(n)
	return n


func _on_emb(_c: int) -> void:
	_emb += 1


func _on_desemb(d: String) -> void:
	_desemb += 1
	_ult = d


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO PUERTO ===")
	var cm := _manager()
	var p := _puerto_area()

	# Sin pasaje: embarcar debe rechazar (puede_embarcar false).
	cm.cargar_desde({"estado": 0, "cubierta_actual": 1})
	var n := _nuevo_player()
	p.jugador_embarco.connect(_on_emb)
	p._on_body_entered(n)
	_check("sin pasaje no embarca", _emb == 0)

	# Con pasaje ABORDO: embarca y emite jugador_embarco.
	cm.cargar_desde({
		"estado": 1, "cubierta_actual": 2, "camarote_asignado": "suite",
		"route_id": "ruta_test",
		"pasaje": {"route_id": "ruta_test", "origen": "isla_raiz", "destino": "isla_norte",
			"clase": "primera", "camarote": "suite", "precio": 140, "cubierta": 2},
	})
	p._on_body_entered(n)
	_check("con pasaje embarca", _emb == 1)
	_check("manager en ABORDO", int(cm.estado) == 1)

	# Desembarco: sale del area -> emite jugador_desembarco y libera pasaje.
	p.jugador_desembarco.connect(_on_desemb)
	p.destino = "isla_norte"
	p._on_body_exited(n)
	_check("desembarco emitido", _desemb == 1)
	_check("desembarco destino = isla_norte", _ult == "isla_norte")
	_check("pasaje liberado", cm.pasaje_actual == null)

	# Cuerpo no-jugador no dispara nada.
	var antes := _emb
	p._on_body_entered(Node3D.new())
	_check("no-jugador no embarca", _emb == antes)

	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)