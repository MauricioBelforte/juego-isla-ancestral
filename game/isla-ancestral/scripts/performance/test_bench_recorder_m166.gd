# Modelo: hy3 (WorkBuddy / Tencent Hunyuan)
# Plataforma: WorkBuddy
# Fecha: 2026-10-02
#
# M166 (Variantes-Y-Perfil-De-Rendimiento): Test del fix BUG-084 (Fase 2).
# Valida que bench_recorder.gd ubico los waypoints y el VoxelViewer en el centro
# REAL de la Isla Raiz (MundoRaiz.CENTRO = 2560,2560), no en la esquina vieja
# del mundo 512² (256,256). Es el gate que mantiene viva la migracion: si alguien
# revierte a 256, este test debe dar FALLO + exit 1.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/performance/test_bench_recorder_m166.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var inst = load("res://scripts/performance/bench_recorder.gd").new()
	var wps: Array = inst.calcular_waypoints()
	var n: int = wps.size()
	_check(n == 6, "6 waypoints (eran %d)" % n)

	var centro := MundoRaiz.CENTRO
	var radio := MundoRaiz.CENTRO.x   # 2560 = radio del generador del mundo real

	for i in range(n):
		var wp: Vector3 = wps[i]
		var dx := wp.x - centro.x
		var dz := wp.z - centro.y
		var d := sqrt(dx * dx + dz * dz)
		# No debe quedar en la esquina vieja del mundo 512² (256,256)
		_check(abs(wp.x - 256.0) > 100.0 or abs(wp.z - 256.0) > 100.0,
			"waypoint %d NO en esquina vieja 256,256 (x=%.0f z=%.0f)" % [i, wp.x, wp.z])
		# Debe estar dentro del mundo real (radio generador), con margen
		_check(d <= radio * 1.05,
			"waypoint %d dentro del mundo real (r=%.0f <= %.0f)" % [i, d, radio * 1.05])

	# VoxelViewer y punto de mira en el centro real
	var pv: Vector3 = inst.posicion_viewer()
	_check(abs(pv.x - centro.x) < 1.0 and abs(pv.z - centro.y) < 1.0,
		"viewer en centro real (%.0f,%.0f)" % [pv.x, pv.z])
	var ol: Vector3 = inst.objetivo_look()
	_check(abs(ol.x - centro.x) < 1.0 and abs(ol.z - centro.y) < 1.0,
		"look_at en centro real (%.0f,%.0f)" % [ol.x, ol.z])

	print("=== TEST M166 BENCH RECORDER (BUG-084): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
