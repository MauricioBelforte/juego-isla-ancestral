# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M67: QA del techo de altitud del dirigible (items [S] "Altitud maxima 60 m
# (mejorable a 90 m)" + "Dirigible con techo de altitud"; turno 2-BIS).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/vehiculos/qa_m67_altitud.gd

extends SceneTree

var _checks: int = 0
var _fallos: int = 0

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _summary() -> void:
	print("=== Resumen QA altitud M67: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _controlador(preset: VehiclePreset) -> Object:
	var ctrl: Object = (load("res://scripts/vehiculos/vehicle_controller.gd") as Script).new()
	ctrl.preset = preset
	return ctrl

func _preset(altitud_max: float) -> VehiclePreset:
	var p: VehiclePreset = (load("res://scripts/vehiculos/vehicle_preset.gd") as Script).new()
	p.id = &"dirigible_test"
	p.altitud_max = altitud_max
	p.velocidad_max = 10.0
	p.velocidad_crucero = 5.0
	return p

func _run() -> void:
	# 1. Subida y techo EXACTO 60 (sin mejoras)
	var c: Object = _controlador(_preset(60.0))
	for i in range(400):
		c.aplicar(0.1, false, 0, false, true, false)  # 400*0.1*2 = 80 m pedidos
	_check(float(c.altitud) == 60.0, "techo: altitud clamp EXACTO 60 m (=%s)" % str(c.altitud))
	# 2. Bajada: baja y piso 0
	for i in range(400):
		c.aplicar(0.1, false, 0, false, false, true)
	_check(float(c.altitud) == 0.0, "bajada: piso 0 (=%s)" % str(c.altitud))
	# 3. Barco (altitud_max=0) no vuela aunque pida subir
	var barco: Object = _controlador(_preset(0.0))
	barco.aplicar(0.1, false, 0, false, true, false)
	_check(float(barco.altitud) == 0.0, "barco: sin altitud_max no vuela")
	# 4. Retrocompatibilidad: llamada de 4 argumentos (tests viejos) sin tocar altitud
	c.altitud = 30.0
	c.aplicar(0.1, true, 0, false)
	_check(float(c.altitud) == 30.0, "retrocompatible: llamada de 4 args no toca la altitud")
	# 5. Mejoras: techo 60 -> 90 con nivel maximo (por_nivel altitud 30, tope 90)
	var p2: VehiclePreset = _preset(60.0)
	p2.mejoras = {"nivel_max": 2, "por_nivel": {"altitud": 30.0}, "topes": {"altitud": 90.0}}
	p2.nivel = 2
	_check(float(p2.altitud_max_efectiva()) == 90.0, "mejoras: altitud_max_efectiva == 90 con nivel 2 (=%s)" % str(p2.altitud_max_efectiva()))
	var c2: Object = _controlador(p2)
	for i in range(600):
		c2.aplicar(0.1, false, 0, false, true, false)  # pedir 120 m
	_check(float(c2.altitud) == 90.0, "mejoras: techo modo mejora clamp EXACTO 90 m (=%s)" % str(c2.altitud))
	_summary()
