# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M67: Test de VehicleManager + VehicleController (núcleo V0 iter. 1).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/vehiculos/test_vehiculos.gd
#
# Cubre: catálogo presets, enter/exit validación, física acotada (vel máx,
# giro, frenado, reversa), dock/zarpar, eventos EventBus.vehicle, persistencia.
# Tanda 2 Step-5-WorkBuddy 2026-10-21 (Log 2088): bloques de independencia de
# delta 30/60 FPS (checklist G4) y salida a alta velocidad (checklist S2).

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
#     Piso actualizado a 61 por la tanda 3 (Step-5, 2026-10-21): 53 medidos + 8 del ciclo barco end-to-end.
const CHECKS_MINIMOS := 61
const _WB_BLOQUES: Array[String] = ["_test_catalogo", "_test_enter_exit", "_test_fisica_acotada", "_test_reversa", "_test_giro_riel", "_test_dock_zarpar", "_test_eventos", "_test_persistencia", "_test_delta_frameindependiente", "_test_salida_velocidad", "_test_ciclo_barco"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false


func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M67: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _fallos: int = 0
var _vm: Node = null


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_vm = root.get_node_or_null("Vehiculos")
	_check(_vm != null, "VehicleManager autoload presente")
	if _vm == null:
		_summary()
		return
	var bus := root.get_node_or_null("EventBus")
	_check(bus != null, "EventBus autoload presente")
	_check(bus != null and bus.vehicle != null and bus.vehicle.has_signal("vehicle_entered"), "EventBus.vehicle dominio presente (aditivo)")
	_test_catalogo()
	_fin("_test_catalogo")
	_test_enter_exit()
	_fin("_test_enter_exit")
	_test_fisica_acotada()
	_fin("_test_fisica_acotada")
	_test_reversa()
	_fin("_test_reversa")
	_test_giro_riel()
	_fin("_test_giro_riel")
	_test_dock_zarpar()
	_fin("_test_dock_zarpar")
	_test_eventos()
	_fin("_test_eventos")
	_test_persistencia()
	_fin("_test_persistencia")
	_test_delta_frameindependiente()
	_fin("_test_delta_frameindependiente")
	_test_salida_velocidad()
	_fin("_test_salida_velocidad")
	_test_ciclo_barco()
	_fin("_test_ciclo_barco")
	_summary()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
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
	_check(absf(float(ctrl.velocidad)) <= 12.0 * 0.4 + 0.01, "reversa clamp a 40%% vel max: %.2f" % float(ctrl.velocidad))
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
	# 5 ticks más a la derecha (rumbo ~0.96) para alejarse del wrap 0..TAU
	for i in range(5):
		_vm.tick_conduccion(0.1, false, 1, false)
	var rumbo_alto: float = float(ctrl.rumbo)
	_vm.tick_conduccion(0.1, false, -1, false)
	_vm.tick_conduccion(0.1, false, -1, false)
	_check(float(ctrl.rumbo) < rumbo_alto, "girar izquierda dos ticks baja rumbo (sin wrap)")
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
	# Camino real de atracar (log VEH-DOCK): entrar -> zparar -> atracar
	# (tanda 2 Step-5 2026-10-21: el atracar(null) de arriba salia por el early
	# return "ya docked" y NUNCA imprimia [VEH-DOCK]; la suite no lo ejercitaba)
	_vm.enter("barco")
	_vm.zarpar()
	var res_dock: Dictionary = _vm.atracar(null)
	_check(bool(res_dock.ok), "atracar tras zarpar OK (camino real, antes no ejercitado)")
	_check(bool(_vm.docked), "atracar deja docked")
	_vm.exit()
	if not _vm.docked:
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


func _test_delta_frameindependiente() -> void:
	# Checklist G4: física correcta a 30 y 60 FPS (delta correcto).
	# Mismo tiempo simulado (2 s acelerando) con distinto delta -> mismo estado.
	_vm.enter("barco")
	var c30: RefCounted = _vm.controller
	var p30 := Vector3.ZERO
	for i in range(60):
		c30.aplicar(1.0 / 30.0, true, 0, false)
		p30 += c30.desplazamiento(1.0 / 30.0)
	var v30: float = float(c30.velocidad)
	_vm.exit()
	_vm.enter("barco")
	var c60: RefCounted = _vm.controller
	var p60 := Vector3.ZERO
	for i in range(120):
		c60.aplicar(1.0 / 60.0, true, 0, false)
		p60 += c60.desplazamiento(1.0 / 60.0)
	var v60: float = float(c60.velocidad)
	_check(absf(v30 - v60) < 0.01, "30 vs 60 FPS: misma velocidad tras 2 s (%.4f vs %.4f)" % [v30, v60])
	_check(absf(v30 - 6.0) < 0.01, "2 s de aceleracion (3 m/s2) dan 6 m/s: %.4f" % v30)
	# Desplazamiento acumulado: igual salvo error de discretizacion Euler
	# (60 ticks de 1/30 s = 6.10 m; 120 ticks de 1/60 s = 6.05 m; integral = 6 m)
	_check(absf(p30.length() - p60.length()) < 0.1, "desplazamiento acumulado igual a 30 y 60 FPS: %.3f vs %.3f" % [p30.length(), p60.length()])
	_check(absf(p30.length() - 6.0) < 0.15 and absf(p60.length() - 6.0) < 0.15, "desplazamiento cerca del valor analitico 6 m: %.3f / %.3f" % [p30.length(), p60.length()])
	# delta <= 0 es no-op (no avanza, no divide por cero)
	var v_antes: float = float(c60.velocidad)
	c60.aplicar(0.0, true, 0, false)
	c60.aplicar(-1.0, true, 0, false)
	_check(absf(float(c60.velocidad) - v_antes) < 0.001, "delta <= 0 no avanza la fisica")
	# rumbo con wrapf permanece en [0, TAU) tras girar de mas
	for i in range(200):
		c60.aplicar(0.1, false, 1, false)
	_check(float(c60.rumbo) >= 0.0 and float(c60.rumbo) < TAU, "rumbo en [0, TAU) tras girar 20 s: %.3f" % float(c60.rumbo))
	_vm.exit()
	if not _vm.docked:
		_vm.docked = true


func _test_salida_velocidad() -> void:
	# Checklist S2: salir con el vehículo en movimiento rápido (rechazo cozy).
	_vm.enter("barco")
	_vm.zarpar()
	for i in range(50):
		_vm.tick_conduccion(0.1, true, 0, false)
	var vel: float = float(_vm.controller.velocidad)
	var res: Dictionary = _vm.exit()
	_check(not bool(res.ok), "salir a %.1f m/s sin dockear rechazado" % vel)
	_check(String(res.motivo).contains("velocidad"), "motivo de rechazo nombra la velocidad: %s" % String(res.motivo))
	_check(_vm.esta_en_vehiculo(), "el rechazo conserva el vehiculo activo")
	# Frenar hasta detenerse y salir OK
	for i in range(100):
		_vm.tick_conduccion(0.1, false, 0, true)
	res = _vm.exit()
	_check(bool(res.ok), "salir tras frenar OK")
	_check(not _vm.esta_en_vehiculo(), "estado a pie tras salir")
	if not _vm.docked:
		_vm.docked = true


func _test_ciclo_barco() -> void:
	# Checklist V2: ciclo barco end-to-end dock -> entrar -> navegar -> atracar -> salir.
	# Tanda 3 Step-5 2026-10-21: los bloques previos cubren las piezas por separado;
	# este bloque las ejecuta EN SECUENCIA sobre un mismo vehículo (un solo ciclo).
	# Va al final de _run(): no altera la premisa de los bloques previos.
	_check(not _vm.esta_en_vehiculo(), "ciclo barco: empieza a pie")
	_check(bool(_vm.docked), "ciclo barco: empieza docked")
	var res: Dictionary = _vm.enter("barco")
	_check(bool(res.ok), "ciclo barco: entrar OK")
	_check(_vm.esta_en_vehiculo(), "ciclo barco: en vehículo tras entrar")
	res = _vm.zarpar()
	_check(bool(res.ok) and not bool(_vm.docked), "ciclo barco: zarpar OK, navegando")
	var ctrl: RefCounted = _vm.controller
	var dist: float = 0.0
	for i in range(20):
		_vm.tick_conduccion(0.1, true, 0, false)
		dist += float(ctrl.desplazamiento(0.1))
	var vel: float = float(ctrl.velocidad)
	_check(absf(vel - 6.0) < 0.01, "ciclo barco: acelera a crucero 6 m/s en 2 s: %.2f" % vel)
	_check(dist > 1.0, "ciclo barco: el vehículo se desplaza al navegar: %.2f m" % dist)
	res = _vm.atracar(null)
	_check(bool(res.ok) and bool(_vm.docked), "ciclo barco: atracar OK (camino real VEH-DOCK)")
	res = _vm.exit()
	_check(bool(res.ok) and not _vm.esta_en_vehiculo(), "ciclo barco: salir OK tras atracar")
	_check(_vm.controller == null, "ciclo barco: controller liberado tras salir")
	if not _vm.docked:
		_vm.docked = true
