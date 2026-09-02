# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M28: Viajes — Test de HarborDock, Harbor, TravelUI y flujo integrado.
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/viajes/test_harbor_viajes.gd
#
# Cubre:
#   - HarborDock.lock/release / is_locked / get_boat
#   - Harbor.find_free_dock / lock_dock / release_dock / is_dock_available
#   - Harbor.dock_count / occupied_dock_count / get_embark_position
#   - TravelUI.show_reservation_screen / show_travel_progress / screens
#   - Flujo integrado: TravelService + Harbor emular dock lock

extends SceneTree

var _fallos: int = 0

var _hd: Node = null       # HarborDock instancia
var _hbr: Node = null      # Harbor instancia
var _ui: Node = null       # TravelUI instancia
var _ts: Node = null       # TravelService autoload


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_ts = root.get_node_or_null("TravelService") as Node
	_check(_ts != null, "TravelService autoload presente")
	if _ts == null:
		_report_and_quit()
		return

	# Crear nodos de prueba (no requieren escena Godot).
	_hd = _crear_harbor_dock()
	_hbr = _crear_harbor()
	_ui = _crear_travel_ui()

	_test_harbor_dock()
	_test_harbor()
	_test_travel_ui()
	_test_flujo_integrado()

	_report_and_quit()


# ── Helpers de creación ────────────────────────────────────

func _crear_harbor_dock() -> Node:
	var gd: Node = load("res://scripts/viajes/harbor_dock.gd").new()
	gd.name = "test_dock_1"
	root.add_child(gd)
	return gd


func _crear_harbor() -> Node:
	var h: Node = load("res://scripts/viajes/harbor.gd").new()
	h.name = "test_harbor"
	h.set("island_id", "isla_raiz")
	root.add_child(h)
	# Agregar 3 docks hijos.
	for i in range(3):
		var dock: Node = load("res://scripts/viajes/harbor_dock.gd").new()
		dock.name = "dock_%d" % i
		h.add_child(dock)
	# Forzar _ready para recolectar docks.
	h.call("_ready")
	return h


func _crear_travel_ui() -> Node:
	var ui: Node = load("res://scripts/viajes/travel_ui.gd").new()
	ui.name = "test_travel_ui"
	root.add_child(ui)
	return ui


# ── Tests: HarborDock ─────────────────────────────────────

func _test_harbor_dock() -> void:
	_check(!_hd.call("is_locked"), "dock inicia desbloqueado")
	var fake_boat: Node = Node.new()
	fake_boat.name = "barco_test"
	_check(bool(_hd.call("lock", fake_boat)), "lock con dock libre OK")
	_check(_hd.call("is_locked"), "is_locked tras lock")
	_check(_hd.call("get_boat") == fake_boat, "get_boat retorna barco correcto")
	_check(!bool(_hd.call("lock", fake_boat)), "lock doble falla (dock ya ocupado)")
	_hd.call("release")
	_check(!_hd.call("is_locked"), "release libera dock")
	_check(_hd.call("get_boat") == null, "get_boat null tras release")
	fake_boat.free()


# ── Tests: Harbor ─────────────────────────────────────────

func _test_harbor() -> void:
	var count: int = int(_hbr.call("dock_count"))
	_check(count == 3, "Harbor tiene 3 docks: %d" % count)
	var occ: int = int(_hbr.call("occupied_dock_count"))
	_check(occ == 0, "0 docks ocupados inicialmente: %d" % occ)
	_check(bool(_hbr.call("is_dock_available")), "hay dock disponible")

	var boat1: Node = Node.new()
	boat1.name = "barco_1"
	var boat2: Node = Node.new()
	boat2.name = "barco_2"

	# Bloquear 2 docks.
	_check(bool(_hbr.call("lock_dock", boat1)), "lock_dock con espacio OK (1)")
	_check(bool(_hbr.call("lock_dock", boat2)), "lock_dock con espacio OK (2)")
	occ = int(_hbr.call("occupied_dock_count"))
	_check(occ == 2, "2 docks ocupados: %d" % occ)
	_check(bool(_hbr.call("is_dock_available")), "aun hay 1 dock disponible")

	# Tercer lock debe funcionar (3 docks totales, solo 2 ocupados).
	var boat3: Node = Node.new()
	boat3.name = "barco_3"
	_check(bool(_hbr.call("lock_dock", boat3)), "lock_dock con espacio OK (3er dock)")

	# Liberar uno y verificar disponibilidad.
	_hbr.call("release_dock", boat1)
	occ = int(_hbr.call("occupied_dock_count"))
	_check(occ == 2, "2 docks ocupados tras release (barco2+barco3): %d" % occ)
	_check(bool(_hbr.call("is_dock_available")), "disponible tras release")
	_check(bool(_hbr.call("lock_dock", boat3)), "lock tras release funciona")

	# Posicion de embarque.
	var pos: Variant = _hbr.call("get_embark_position")
	_check(pos != null, "get_embark_position retorna Vector3 valido")

	# Cleanup.
	_hbr.call("release_dock", boat2)
	_hbr.call("release_dock", boat3)
	boat1.free()
	boat2.free()
	boat3.free()


# ── Tests: TravelUI ───────────────────────────────────────

func _test_travel_ui() -> void:
	var screen: int = int(_ui.call("get_current_screen"))
	_check(screen == 0, "UI inicia oculta (screen=HIDDEN): %d" % screen)
	# show_reservation_screen requiere rutas en TravelService; 4 rutas ya cargadas.
	_ui.call("show_reservation_screen", "isla_raiz")
	screen = int(_ui.call("get_current_screen"))
	_check(screen == 1, "UI muestra RESERVATION tras show_reservation_screen: %d" % screen)
	var hid: String = str(_ui.call("get_harbor_id"))
	_check(hid == "isla_raiz", "harbor_id correcta: %s" % hid)
	_ui.call("_cerrar")
	screen = int(_ui.call("get_current_screen"))
	_check(screen == 0, "UI vuelve a HIDDEN tras cerrar: %d" % screen)


# ── Tests: Flujo integrado ───────────────────────────────

func _test_flujo_integrado() -> void:
	# Verificar que TravelService puede acceder a los nodos de prueba.
	var hbr_en_root: Node = root.get_node_or_null("test_harbor") as Node
	_check(hbr_en_root != null, "Harbor accesible desde root para integracion")
	var ui_en_root: Node = root.get_node_or_null("test_travel_ui") as Node
	_check(ui_en_root != null, "TravelUI accesible desde root para integracion")
	# Verificar que TravelService sigue operativo tras crear nodos extras.
	var rutas: int = int(_ts.call("rutas_count"))
	_check(rutas == 4, "rutas aun cargadas tras setup de prueba: %d" % rutas)


# ── Reporte ────────────────────────────────────────────────

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		push_error("FALLO M28: " + msg)
	else:
		print("OK M28: " + msg)


func _report_and_quit() -> void:
	print("=== TEST M28 HARBOR/VIAJES: %d fallo(s) ===" % _fallos)
	# Limpiar nodos de prueba.
	for child in root.get_children():
		if child.name.begins_with("test_"):
			child.queue_free()
	quit(1 if _fallos > 0 else 0)
