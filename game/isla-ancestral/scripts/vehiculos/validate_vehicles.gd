# Modelo: Step-5-WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-10-21
#
# M67: Vehículos — validate_vehicles.gd (validador del módulo, diseño §1
# "validators/validate_vehicles.gd": física, streaming, colisiones, presupuestos).
#
# TANDA 2 Step-5-WorkBuddy (2026-10-21): validador PARCIAL honesto.
# Cubre lo que existe en disco hoy (iter. 1, núcleo V0):
#   A) catálogo data-driven (vehicles.json: esquema, ids, tipos, condicional M68)
#   B) presets contra la tabla de diseño 03-Diseno.md §3.1 (velocidades, slots)
#   C) invariantes de física del controller (clamp, frenado, reversa, delta,
#      wrap de rumbo, independencia 30/60 FPS)
#   D) integración con el autoload VehicleManager (si está presente)
# NO cubre (reportado como PENDIENTE, no como fallo): streaming (M10/M61),
# colisiones (M50), HUD (M53), cámara (M12/M57), audio (M43), mejoras,
# personalización, baúl real (M14) — verbos de la iter. 2 con dueños externos.
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/vehiculos/validate_vehicles.gd
# Salida: EXIT 0 = todo lo validado pasa; EXIT 1 = hay fallos (con detalle).

extends SceneTree

var _checks: int = 0
var _fallos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_validar_catalogo()
	_validar_presets_diseno()
	_validar_fisica()
	_validar_manager()
	_reportar_pendientes()
	_resumen()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FAIL] " + msg)


func _ok(msg: String) -> void:
	print("[OK] " + msg)


func _validar_catalogo() -> void:
	var ruta := "res://data/vehiculos/vehicles.json"
	_check(FileAccess.file_exists(ruta), "vehicles.json existe")
	if not FileAccess.file_exists(ruta):
		return
	var texto := FileAccess.get_file_as_string(ruta)
	var parseado: Variant = JSON.parse_string(texto)
	_check(typeof(parseado) == TYPE_DICTIONARY, "vehicles.json parsea a Dictionary")
	if typeof(parseado) != TYPE_DICTIONARY:
		return
	var doc: Dictionary = parseado
	_check(int(doc.get("schema_version", 0)) == 1, "schema_version == 1: %d" % int(doc.get("schema_version", 0)))
	var lista: Variant = doc.get("vehiculos", [])
	_check(typeof(lista) == TYPE_ARRAY, "clave 'vehiculos' es Array")
	if typeof(lista) != TYPE_ARRAY:
		return
	var vehiculos: Array = lista
	_check(vehiculos.size() == 4, "4 entradas en el catalogo: %d" % vehiculos.size())
	var ids: Array = []
	for v in vehiculos:
		if typeof(v) == TYPE_DICTIONARY:
			ids.append(String(v.get("id", "")))
	_check(ids.size() == 4 and "" not in ids, "todos con id no vacio")
	_check(_sin_duplicados(ids), "ids sin duplicados")
	for v in vehiculos:
		if typeof(v) != TYPE_DICTIONARY:
			continue
		var tipo := String(v.get("tipo", ""))
		_check(tipo in ["agua", "aire", "subagua", "riel"], "tipo valido '%s' (%s)" % [tipo, String(v.get("id", ""))])
	var loco: Variant = null
	for v in vehiculos:
		if typeof(v) == TYPE_DICTIONARY and String(v.get("id", "")) == "locomotora":
			loco = v
	_check(loco != null and String((loco as Dictionary).get("condicional", "")) == "M68", "locomotora condicional a M68")
	for v in vehiculos:
		if typeof(v) == TYPE_DICTIONARY and String(v.get("id", "")) != "locomotora":
			_check(String(v.get("condicional", "")) == "", "%s sin condicional" % String(v.get("id", "")))


func _sin_duplicados(ids: Array) -> bool:
	var vistos: Dictionary = {}
	for id in ids:
		if vistos.has(id):
			return false
		vistos[id] = true
	return true


func _validar_presets_diseno() -> void:
	# Tabla 03-Diseno.md §3.1 (medida en disco):
	# barco 12/6 m/s 12 slots | dirigible 15/8 m/s alt 60 8 slots |
	# submarino 8/4 m/s prof -40 10 slots | locomotora 20/20 m/s giro 0 16 slots
	var ruta := "res://data/vehiculos/vehicles.json"
	if not FileAccess.file_exists(ruta):
		return
	var doc: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	var por_id: Dictionary = {}
	for v in doc.get("vehiculos", []):
		if typeof(v) == TYPE_DICTIONARY:
			por_id[String(v.get("id", ""))] = v
	var barco: Dictionary = por_id.get("barco", {})
	_check(float(barco.get("velocidad_max", 0.0)) == 12.0, "barco vel max 12 (§3.1)")
	_check(float(barco.get("velocidad_crucero", 0.0)) == 6.0, "barco crucero 6 (§3.1)")
	_check(int(barco.get("baul_slots", 0)) == 12, "barco baul 12 slots (§3.1)")
	_check(float(barco.get("altitud_max", -1.0)) == 0.0 and float(barco.get("profundidad_max", 1.0)) == 0.0, "barco sin altitud/profundidad")
	var diri: Dictionary = por_id.get("dirigible", {})
	_check(float(diri.get("velocidad_max", 0.0)) == 15.0, "dirigible vel max 15 (§3.1)")
	_check(float(diri.get("altitud_max", 0.0)) == 60.0, "dirigible altitud max 60 (§3.1)")
	_check(int(diri.get("baul_slots", 0)) == 8, "dirigible baul 8 slots (§3.1)")
	var sub: Dictionary = por_id.get("submarino", {})
	_check(float(sub.get("velocidad_max", 0.0)) == 8.0, "submarino vel max 8 (§3.1)")
	_check(float(sub.get("profundidad_max", 0.0)) == -40.0, "submarino profundidad max -40 (§3.1)")
	_check(int(sub.get("baul_slots", 0)) == 10, "submarino baul 10 slots (§3.1)")
	var loco: Dictionary = por_id.get("locomotora", {})
	_check(float(loco.get("velocidad_max", 0.0)) == 20.0, "locomotora vel max 20 (§3.1)")
	_check(float(loco.get("giro", -1.0)) == 0.0, "locomotora giro fijo 0 (riel)")
	_check(int(loco.get("baul_slots", 0)) == 16, "locomotora baul 16 slots (§3.1)")
	_check(not bool(loco.get("tiene_reversa", true)), "locomotora sin reversa (§3.1)")


func _validar_fisica() -> void:
	# Invariantes del controller lógico (sin autoload: instancia directa).
	var ScriptCtrl: GDScript = load("res://scripts/vehiculos/vehicle_controller.gd")
	var p := VehiclePreset.desde_datos({"id": "barco", "tipo": "agua", "velocidad_max": 12.0, "velocidad_crucero": 6.0, "giro": 1.6, "frenado": 4.0})
	var c = ScriptCtrl.new()
	c.set("preset", p)
	for i in range(200):
		c.aplicar(0.1, true, 0, false)
	_check(absf(float(c.velocidad) - 12.0) < 0.01, "clamp a velocidad_max 12: %.2f" % float(c.velocidad))
	for i in range(100):
		c.aplicar(0.1, false, 0, true)
	_check(absf(float(c.velocidad)) < 0.01, "frenado lleva a 0")
	for i in range(100):
		c.aplicar(0.1, false, 0, false)
	_check(float(c.velocidad) < 0.0, "reversa con signo negativo")
	_check(absf(float(c.velocidad)) <= 12.0 * 0.4 + 0.01, "reversa clamp a -40%% de vel max: %.2f" % float(c.velocidad))
	var v_antes: float = float(c.velocidad)
	c.aplicar(0.0, true, 0, false)
	c.aplicar(-1.0, true, 0, false)
	_check(absf(float(c.velocidad) - v_antes) < 0.001, "delta <= 0 es no-op")
	for i in range(200):
		c.aplicar(0.1, false, 1, false)
	_check(float(c.rumbo) >= 0.0 and float(c.rumbo) < TAU, "rumbo en [0, TAU): %.3f" % float(c.rumbo))
	# Independencia de delta: 2 s simulados a 30 y 60 FPS -> misma velocidad
	var c30 = ScriptCtrl.new()
	c30.set("preset", p)
	for i in range(60):
		c30.aplicar(1.0 / 30.0, true, 0, false)
	var c60 = ScriptCtrl.new()
	c60.set("preset", p)
	for i in range(120):
		c60.aplicar(1.0 / 60.0, true, 0, false)
	_check(absf(float(c30.velocidad) - float(c60.velocidad)) < 0.01, "independencia de delta 30/60 FPS: %.4f vs %.4f" % [float(c30.velocidad), float(c60.velocidad)])


func _validar_manager() -> void:
	var vm := root.get_node_or_null("Vehiculos")
	if vm == null:
		_ok("VehicleManager no presente en esta corrida (sin autoload): se omite D")
		return
	_check(vm.presets_count() == 3, "3 presets activos (locomotora condicional M68): %d" % vm.presets_count())
	var res: Dictionary = vm.enter("barco")
	_check(bool(res.ok), "enter barco OK")
	var res2: Dictionary = vm.enter("dirigible")
	_check(not bool(res2.ok), "segundo enter rechazado (uno a la vez)")
	var res3: Dictionary = vm.exit()
	_check(bool(res3.ok), "exit OK")


func _reportar_pendientes() -> void:
	print("--- PENDIENTE (no validado hoy, iter. 2 con duenos externos) ---")
	print("[PEND] streaming chunk_target/LOD (M10/M61): vehicle_streaming.gd no existe en disco")
	print("[PEND] colisiones islas/rocas/vegetacion (M50): sin nodos 3D")
	print("[PEND] HUD (M53), camara (M12/M57), audio (M43), animaciones (M48)")
	print("[PEND] mejoras, personalizacion, baul real (M14), controles (M57)")


func _resumen() -> void:
	print("=== validate_vehicles M67: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
