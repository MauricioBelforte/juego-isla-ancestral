# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M69: Test headless del FastTravelService (anclas, desbloqueo, viaje).
extends SceneTree

var _fallos := 0
var _checks := 0

## Guardián anti-falso-verde: piso MEDIDO en la corrida real.
const CHECKS_MINIMOS: int = 17

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
	var ok_viaje = svc.solicitar_viaje("LOC-RIZ-CASA-001")
	_check("Service: viaje solicitable (ancla desbloqueada)", ok_viaje)
	_check("Service: señal viaje emitida", solicitud[0])
	var ok_invalido = svc.solicitar_viaje("ancla_inexistente")
	_check("Service: ancla inexistente -> false", not ok_invalido)
	_b2_indice_costo(svc)
	svc.free()
	_resumen()

## D52 (O(1)) + RF4/P3 (costo de viaje).
func _b2_indice_costo(svc) -> void:
	_check("Índice O(1): ancla_de devuelve la ancla por id", svc.ancla_de("LOC-RIZ-PUB-001").get("nombre") == "Pueblo Raiz")
	_check("Índice O(1): id inexistente -> {} vacío", svc.ancla_de("no_existe").is_empty())
	# El índice deben cubrir todas las anclas cargadas.
	var n_idx := 0
	for a in svc.anclas():
		if not svc.ancla_de(String(a.get("id", ""))).is_empty():
			n_idx += 1
	_check("Índice O(1): cubre las %d anclas" % svc.anclas().size(), n_idx == svc.anclas().size())

	# Costo: por defecto gratuito.
	_check("Costo: por defecto 0 (viaje gratuito)", svc.costo_total() == 0)
	svc.set_costo_viaje({"moneda": 5})
	_check("Costo: configurable en recursos", svc.costo_total() == 5)
	svc.set_costo_viaje({"moneda": 3, "tiempo": 2})
	_check("Costo: varios recursos se suman", svc.costo_total() == 5)

	# Rechazo por costo con validador inyectable (M38/M59).
	var puede := [true]
	svc.set_puede_pagar_fn(func(_ancla_id: String) -> bool: return puede[0])
	var rechazos := []
	svc.viaje_rechazado.connect(func(id, motivo): rechazos.append([id, motivo]))
	var ok_pago = svc.solicitar_viaje("LOC-RIZ-PUB-001")
	_check("Costo: con saldo el viaje se concede", ok_pago and rechazos.is_empty())

	puede[0] = false
	var ok_sin_pago = svc.solicitar_viaje("LOC-RIZ-PUB-001")
	_check("Costo: sin saldo el viaje se rechaza", not ok_sin_pago)
	_check("Costo: el rechazo lleva motivo 'costo'", rechazos.size() == 1 and String(rechazos[0][1]) == "costo")
	_check("Costo: el rechazo nombra el ancla", String(rechazos[0][0]) == "LOC-RIZ-PUB-001")

func _on_viaje(ancla: Dictionary, contenedor: Array) -> void:
	contenedor[0] = true

func _resumen() -> void:
	print("=== RESUMEN M69: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("RESULTADO: FALLO (%d checks de %d, %d fallos)" % [_checks, CHECKS_MINIMOS, _fallos])
		quit(1)
		return
	print("RESULTADO: PASS")
	quit(0)