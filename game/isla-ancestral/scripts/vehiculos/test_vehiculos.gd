# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M67: Test de VehicleManager + VehicleController (núcleo V0 iter. 1).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/vehiculos/test_vehiculos.gd
#
# Cubre: catálogo presets, enter/exit validación, física acotada (vel máx,
# giro, frenado, reversa), dock/zarpar, eventos EventBus.vehicle, persistencia.

extends SceneTree

var _fallos: int = 0
var _vm: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_vm = root.get_node_or_null("Vehiculos")
	_check(_vm != null, "VehicleManager autoload presente")
	if _vm == null:
		print("=== TEST M67 VEHICULOS: 1 fallo(s) ===")
		quit(1)
		return
	var bus := root.get_node_or_null("EventBus")
	_check(bus != null, "EventBus autoload presente")
	_check(bus != null and bus.vehicle != null and bus.vehicle.has_signal("vehicle_entered"), "EventBus.vehicle dominio presente (aditivo)")
	_test_catalogo()
	_test_enter_exit()
	_test_fisica_acotada()
	_test_reversa()
	_test_giro_riel()
	_test_dock_zarpar()
	_test_eventos()
	_test_persistencia()
	print("=== TEST M67 VEHICULOS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _test_catalogo() -> void:
	# barco + dirigible + submarino activos; locomotora condicional (M68 ausente)
	_check(_vm.presets_count() == 3, "3 presets activos (locomotora condicional M68): %d" % _vm.presets_count())
	var barco: Resource = _vm.get_preset("barco")
	_check(barco != null, "preset barco existe")
	if barco != null:
		_check(float(barco.velocidad_max) == 12.0, "barco vel max 12 (§3.1): %.1f" % float(barco.velocidad_max))
		_check(int(barco.baul_slots) == 12, "barco baúl 12 slots")
		_check(String(barco.tipo) == "agua", "barco tipo agua")
	var diri: Resource = _vm.get_preset("dirigible")
	if diri != null:
		_check(float(diri.altitud_max) == 60.0, "dirigible altitud máx 60 m")
	var sub: Resource = _vm.get_preset("submarino")
	if sub != null:
		_check(float(sub.profundidad_max) == -40.0, "submarino profundidad máx -40 m")


func _test_enter_exit() -> void:
	# Exit sin vehículo falla
	var res: Dictionary = _vm.exit()
	_check(not bool(res.ok), "exit sin vehículo rechazado")
	# Enter válido
	res = _vm.enter("barco")
	_check(bool(res.ok), "enter barco OK")
	_check(_vm.esta_en_vehiculo(), "estado en-vehículo tras enter")
	# Un solo vehículo a la vez
	var res2: Dictionary = _vm.enter("dirigible")
	_check(not bool(res2.ok), "segundo enter rechazado (uno a la vez)")
	_check(String(res2.motivo).contains("uno a la vez"), "motivo un-vehículo")
	# Exit válido
	res = _vm.exit()
	_check(bool(res.ok), "exit OK")
	_check(not _vm.esta_en_vehiculo(), "estado a pie tras exit")
	# Enter desconocido
	res = _vm.enter("ovni")
	_check(not bool(res.ok), "enter vehículo desconocido rechazado")


func _test_fisica_acotada() -> void:
	_vm.enter("barco")
	var ctrl: RefCounted = _vm.controller
	_check(ctrl != null, "controller activo tras enter")
	# Aceleración hasta vel max (clamp 12)
	for i in range(200):
		_vm.tick_conduccion(0.1, true, 0, false)
	_check(absf(float(ctrl.velocidad) - 12.0) < 0.01, "velocidad clamp a 12 m/s: %.2f" % float(ctrl.velocidad))
	# Frenado hasta 0
	for i in range(100):
		_vm.tick_conduccion(0.1, false, 0, true)
	_check(absf(float(ctrl.velocidad)) < 0.01, "frenado lleva a 0: %.2f" % float(ctrl.velocidad))
	_vm.exit()


func _test_reversa() -> void:
	_vm.enter("barco")
	var ctrl: RefCounted = _vm.controller
	# Reversa (acelerar=false, frenar=false → marcha atrás)
	for i in range(100):
		_vm.tick_conduccion(0.1, false, 0, false)
	_check(float(ctrl.velocidad) < 0.0, "barco tiene reversa: %.2f" % float(ctrl.velocidad))
	_check(absf(float(ctrl.velocidad)) <= 12.0 * 0.4 + 0.01, "reversa clamp a 40% vel max: %.2f" % float(ctrl.velocidad))
	_vm.exit()
	# Dirigible también reversa; locomotora no existe (condicional)
	_vm.enter("dirigible")
	for i in range(100):
		_vm.tick_conduccion(0.1, false, 0, false)
	_check(float(_vm.controller.velocidad) < 0.0, "dirigible reversa OK")
	_vm.exit()


func _test_giro_riel() -> void:
	# Giros con barco (giro 1.6 rad/s)
	_vm.enter("barco")
	var ctrl: RefCounted = _vm.controller
	var rumbo0: float = float(ctrl.rumbo)
	_vm.tick_conduccion(0.1, false, 1, false)
	_check(float(ctrl.rumbo) > rumbo0, "girar derecha incrementa rumbo")
	_vm.tick_conduccion(0.1, false, -1, false)
	_vm.tick_conduccion(0.1, false, -1, false)
	_check(float(ctrl.rumbo) < rumbo0, "girar izquierda dos ticks baja rumbo")
	_vm.exit()


func _test_dock_zarpar() -> void:
	_vm.enter("barco")
	_check(bool(_vm.docked), "vehículo inicia docked")
	var res: Dictionary = _vm.atracar(null)
	_check(bool(res.ok) and String(res.motivo) == "ya docked", "atracar ya-docked no rompe")
	res = _vm.zarpar()
	_check(bool(res.ok) and not bool(_vm.docked), "zarpar activa navegación")
	# Enter con vehículo no docked falla (validación §2.1)
	_vm.exit()
	var res2: Dictionary = _vm.enter("barco")
	_check(not bool(res2.ok), "enter con no-docked rechazado (validación estado)")
	_check(String(res2.motivo).contains("docked"), "motivo no-docked")
	# Zarpar sin vehículo falla
	var res3: Dictionary = _vm.zarpar()
	_check(not bool(res3.ok), "zarpar sin vehículo rechazado")
	# Restaurar estado limpio para los tests siguientes (cozy: docked)
	if not _vm.docked and not _vm.esta_en_vehiculo():
		_vm.docked = true


func _test_eventos() -> void:
	var bus: Node = root.get_node_or_null("EventBus")
	if bus == null:
		return
	var eventos: Array = []
	var cb_enter := func(id: String, tipo: String) -> void:
		eventos.append("enter:" + id)
	var cb_exit := func(id: String, tipo: String) -> void:
		eventos.append("exit:" + id)
	bus.vehicle.vehicle_entered.connect(cb_enter)
	bus.vehicle.vehicle_exited.connect(cb_exit)
	_vm.enter("dirigible")
	_vm.exit()
	_check(eventos.has("enter:dirigible"), "evento vehicle_entered emitido")
	_check(eventos.has("exit:dirigible"), "evento vehicle_exited emitido")
	bus.vehicle.vehicle_entered.disconnect(cb_enter)
	bus.vehicle.vehicle_exited.disconnect(cb_exit)


func _test_persistencia() -> void:
	_vm.enter("submarino")
	var data: Dictionary = _vm.get_save_data()
	_check(String(data.get("activo", "")) == "submarino", "save_data con vehículo activo")
	_check(int(data.get("version", 0)) == 1, "save_data versionado")
	_check(bool(data.get("docked", false)), "save restaura docked (cozy: sin perder vehículo en movimiento)")
	# Round-trip
	_vm.exit()
	_vm.restore_save_data(data)
	_check(_vm.esta_en_vehiculo(), "restore re-entra al vehículo")
	_check(String(_vm.vehicle_id_activo) == "submarino", "restore conserva id")
	_check(absf(float(_vm.controller.velocidad)) < 0.01, "restore a velocidad 0 (cozy)")
	# Limpieza final
	_vm.exit()
