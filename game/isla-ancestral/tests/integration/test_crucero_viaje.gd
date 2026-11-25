# Modelo: ERNIE-5.5-Flash-Preview
# Plataforma: Kilo Code
# Fecha: 2026-11-25
#
# M169: Test de INTEGRACION del viaje en crucero (B-08 / P-02).
# Cubre el ciclo completo: embarque -> zarpe -> navegacion -> llegada -> desembarco,
# ejercitando el contrato de senales entre CruceroManager (M169) y TransportManager (M68).
#
# Ejecutar: godot --headless --path game/isla-ancestral --script res://tests/integration/test_crucero_viaje.gd
#
# Convencion SceneTree del repo (ver tests/unit/test_crucero_manager.gd). El autoload no se
# resuelve como identificador en modo --script, pero existe en runtime como hijo del root:
# se obtiene con get_node_or_null y, si faltara, se instancia el script.

extends SceneTree

var _ok: int = 0
var _fallos: int = 0
var _cm: Node = null

# Contadores de senales recibidas.
var _n_embarque: int = 0
var _n_zarpe: int = 0
var _n_llegada: int = 0
var _n_desembarco: int = 0
var _ult_zarpe: String = ""
var _ult_llegada: String = ""


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
		root.add_child(_cm)
	return _cm


func _conectar_senales(cm: Node) -> void:
	cm.embarque.connect(func(_c: int) -> void: _n_embarque += 1)
	cm.zarpe.connect(func(origen: String, _destino: String) -> void:
		_n_zarpe += 1
		_ult_zarpe = origen)
	cm.llegada.connect(func(puerto: String) -> void:
		_n_llegada += 1
		_ult_llegada = puerto)
	cm.desembarco.connect(func(_d: String) -> void: _n_desembarco += 1)


func _correr() -> void:
	print("\n=== TEST M169 CRUCERO VIAJE (INTEGRACION) ===")

	var cm := _manager()
	_check("manager disponible", cm != null)
	if cm == null:
		print("RESULTADO: 0 OK / 1 FAIL (sin manager)")
		quit(1)
		return

	# J-02: el autoload CruceroManager debe estar registrado en el arbol (root).
	_check("CruceroManager es autoload (hijo del root)", root.get_node_or_null("CruceroManager") != null)

	_conectar_senales(cm)

	# Estado inicial: ATRACADO, sin pasaje.
	cm.cargar_desde({"estado": 0, "cubierta_actual": 1})
	_check("estado inicial ATRACADO", int(cm.estado) == 0)
	_check("sin pasaje no embarca", cm.puede_embarcar() == false)

	# Embarque: cargamos un pasaje ABORDO (estado 1) y embarcamos.
	cm.cargar_desde({
		"estado": 1,
		"cubierta_actual": 2,
		"camarote_asignado": "suite",
		"route_id": "ruta_test",
		"pasaje": {
			"route_id": "ruta_test",
			"origen": "isla_raiz",
			"destino": "isla_norte",
			"clase": "primera",
			"camarote": "suite",
			"precio": 140,
			"cubierta": 2,
		},
	})
	_check("puede embarcar con pasaje", cm.puede_embarcar() == true)
	_check("embarcar() acepta", cm.embarcar() == true)
	_check("senal embarque emitida", _n_embarque == 1)
	_check("cubierta = 2 tras embarcar", cm.cubierta_actual == 2)

	# Zarpe: M68 avisa que la ruta arranco.
	cm._on_viaje_iniciado(&"ruta_test", 140)
	_check("estado NAVEGANDO tras zarpe", int(cm.estado) == 2)
	_check("senal zarpe emitida", _n_zarpe == 1)
	_check("zarpe origen = isla_raiz", _ult_zarpe == "isla_raiz")

	# Llegada: M68 avisa que llegamos a puerto.
	cm._on_viaje_llegado(&"ruta_test", &"isla_norte")
	_check("estado ATRACADO tras llegada", int(cm.estado) == 0)
	_check("senal llegada emitida", _n_llegada == 1)
	_check("llegada puerto = isla_norte", _ult_llegada == "isla_norte")

	# Desembarco: libera camarote y cierra el ciclo.
	cm.desembarcar("isla_norte")
	_check("senal desembarco emitida", _n_desembarco == 1)
	_check("pasaje liberado tras desembarco", cm.pasaje_actual == null)
	_check("camarote liberado", String(cm.camarote_asignado) == "")
	_check("estado ATRACADO tras desembarco", int(cm.estado) == 0)
	_check("sin pasaje no se puede embarcar de nuevo", cm.puede_embarcar() == false)

	print("\nRESULTADO: %d OK / %d FAIL" % [_ok, _fallos])
	quit(1 if _fallos > 0 else 0)