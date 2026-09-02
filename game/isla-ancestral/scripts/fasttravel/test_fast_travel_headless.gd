# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M69: Test headless del FastTravelService (anclas, desbloqueo, viaje).
extends SceneTree

var _fallos := 0
var _checks := 0

func _init() -> void:
	call_deferred("_run")

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _run() -> void:
	print("=== [M69] Test del FastTravelService ===")
	var svc = load("res://scripts/fasttravel/fast_travel_service.gd").new()
	root.add_child(svc)
	await process_frame
	_check("Service: 4 anclas cargadas", svc.anclas().size() == 4)
	_check("Service: las 4 desbloqueadas (base)", svc.anclas_desbloqueadas().size() == 4)
	_check("Service: ancla con coords (256,256)", svc.anclas()[0].get("x") == 256 and svc.anclas()[0].get("z") == 256)
	# desbloqueo incremental de una nueva
	var count_before = svc.anclas_desbloqueadas().size()
	svc.desbloquear("ancla_plaza")
	_check("Service: re-desbloqueo no duplica", svc.anclas_desbloqueadas().size() == count_before)
	# solicitud de viaje
	var solicitud = [false]
	svc.viaje_solicitado.connect(_on_viaje.bind(solicitud))
	var ok_viaje = svc.solicitar_viaje("ancla_faro")
	_check("Service: viaje solicitable (ancla desbloqueada)", ok_viaje)
	_check("Service: señal viaje emitida", solicitud[0])
	var ok_invalido = svc.solicitar_viaje("ancla_inexistente")
	_check("Service: ancla inexistente -> false", not ok_invalido)
	svc.free()
	print("=== Resumen M69: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _on_viaje(ancla: Dictionary, contenedor: Array) -> void:
	contenedor[0] = true
