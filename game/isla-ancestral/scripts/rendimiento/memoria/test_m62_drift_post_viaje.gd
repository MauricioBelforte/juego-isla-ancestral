# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-19
#
# M62 / M28: ITEM 15 de la COLA V3 (Log 2021).
#   "Teleport (M69/M28): drift-check obligatorio tras cada viaje largo"
#
# Cierra el hueco medido en el Log 2019: `drift_check()` existia y estaba
# probado, pero tenia **0 llamadores de produccion**. Este test verifica el
# PUNTO DE LLAMADA real (`TravelService._atracar()`), no una copia del
# mecanismo:
#
#   A  viaje CORTO  -> NO se chequea (no es "viaje largo")
#   B  viaje LARGO con drift dentro de limite -> chequeado, 0 fallos
#   C  viaje LARGO con drift FUERA de limite  -> chequeado, 1 fallo (ROJO)
#   D  viaje LARGO sin MemoryMonitor          -> NO MEDIBLE, nunca verde
#
# ⚠️ El caso C se fuerza por INYECCION de la baseline del monitor (bajarla a la
# mitad de la memoria actual), no esperando a que el azar produzca drift: un
# guardian que solo se probo en verde no esta probado.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/rendimiento/memoria/test_m62_drift_post_viaje.gd

extends SceneTree

const MODULO := "M62 drift post-viaje"
const RUTA_SVC := "res://scripts/viajes/travel_service.gd"
const RUTA_MON := "res://scripts/rendimiento/memoria/memory_monitor.gd"
const RUTA_REG := "res://scripts/core/service_registry.gd"
const CHECKS_MINIMOS := 12   # MEDIDO en verde (12 checks x3), no estimado

var _checks := 0
var _fallos := 0
var _svc: Node = null
var _mon: Node = null
var _reg: Node = null
var _llegadas := 0


func _initialize() -> void:
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if not ok:
		_fallos += 1
		print("  [FALL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


func _correr() -> void:
	await process_frame
	print("=== %s ===" % MODULO)

	# ServiceRegistry: si los autoloads no corrieron (modo --script), se crea uno.
	_reg = root.get_node_or_null("ServiceRegistry")
	if _reg == null:
		_reg = load(RUTA_REG).new()
		_reg.name = "ServiceRegistry"
		root.add_child(_reg)
		await process_frame
	_check("ServiceRegistry disponible", _reg != null)

	# El bootstrap del proyecto ya puede haber registrado SU monitor (medido: el
	# contrato "memoria" existia antes de crear el mio, y ese monitor ajeno no
	# tiene baseline -> drift_check() daba false y el caso B fallaba por la razon
	# equivocada). Se desregistra para que el test mida SU monitor, no uno ajeno.
	if bool(_reg.call("has", "memoria")):
		_reg.call("unregister", "memoria")
	_mon = load(RUTA_MON).new()
	_mon.name = "MemoryMonitor"
	root.add_child(_mon)
	await process_frame
	_check("MemoryMonitor instanciado y registrado",
		bool(_reg.call("has", "memoria")) and _reg.call("get_service", "memoria") == _mon)

	_svc = load(RUTA_SVC).new()
	_svc.name = "TravelService"
	root.add_child(_svc)
	await process_frame
	_svc.connect("travel_arrived", Callable(self, "_on_llegada"))

	# ── A: viaje corto (20 s) → no se chequea ──
	var corta: BoatRoute = _ruta("corta", 20.0)
	_atracar_con(corta)
	await process_frame
	_check("A: viaje corto NO dispara drift-check",
		int(_svc.call("drift_checks_post_viaje")) == 0,
		"checks=%d" % int(_svc.call("drift_checks_post_viaje")))

	# ── B: viaje largo (60 s) con drift dentro de limite ──
	_mon.call("estabilizar_baseline", true)
	var larga: BoatRoute = _ruta("larga", 60.0)
	_atracar_con(larga)
	await process_frame
	_check("B: viaje largo SI dispara drift-check",
		int(_svc.call("drift_checks_post_viaje")) == 1,
		"checks=%d" % int(_svc.call("drift_checks_post_viaje")))
	_check("B: sin fallos cuando el drift esta dentro de limite",
		int(_svc.call("drift_fallos_post_viaje")) == 0)

	# ── C: ROJO por inyeccion — baseline a la mitad de la memoria actual ──
	var actual: float = float(_mon.call("memoria_actual_mb"))
	_mon.set("_baseline_mb", maxf(1.0, actual * 0.5))
	var drift_forzado: float = float(_mon.call("drift_porciento"))
	_check("C: la inyeccion produce drift > 5%", absf(drift_forzado) > 5.0,
		"drift=%.1f%%" % drift_forzado)
	_atracar_con(_ruta("larga_roja", 45.0))
	await process_frame
	_check("C: drift fuera de limite se cuenta como fallo",
		int(_svc.call("drift_fallos_post_viaje")) == 1,
		"fallos=%d" % int(_svc.call("drift_fallos_post_viaje")))
	_check("C: drift_check() del monitor tambien da false",
		not bool(_mon.call("drift_check")))

	# ── D: viaje largo SIN monitor → NO MEDIBLE (nunca verde) ──
	_reg.call("unregister", "memoria")
	root.remove_child(_mon)
	_mon.queue_free()
	await process_frame
	_atracar_con(_ruta("larga_sin_monitor", 60.0))
	await process_frame
	_check("D: sin monitor el chequeo queda NO MEDIBLE",
		int(_svc.call("drift_no_medibles")) == 1,
		"no_medibles=%d" % int(_svc.call("drift_no_medibles")))
	_check("D: sin monitor NO se cuenta como chequeo exitoso",
		int(_svc.call("drift_checks_post_viaje")) == 2,
		"checks=%d" % int(_svc.call("drift_checks_post_viaje")))

	# ── El punto de llamada no rompe la senal de llegada ──
	_check("travel_arrived se emitio en los 4 viajes", _llegadas == 4,
		"llegadas=%d" % _llegadas)
	_check("umbral de viaje largo = 45 s (rutas.json: 20/30/45/60)",
		is_equal_approx(float(_svc.get("UMBRAL_VIAJE_LARGO_S")), 45.0))

	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FALLO] solo %d checks (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST %s FALLIDO — salida con codigo 1" % MODULO)
		quit(1)
	else:
		print("TEST %s OK — todos los checks pasaron" % MODULO)
		quit(0)


func _ruta(id: String, duracion: float) -> BoatRoute:
	var r := BoatRoute.new()
	r.route_id = StringName(id)
	r.origin_island_id = "isla_raiz"
	r.destination_island_id = "isla_" + id
	r.base_duration_seconds = duracion
	return r


## Ejercita el PUNTO DE LLAMADA real: setea la ruta en curso y llama `_atracar()`,
## que es lo que ejecuta el servicio cuando el progreso llega a 1.0.
func _atracar_con(r: BoatRoute) -> void:
	_svc.set("_ruta_actual", r)
	_svc.call("_atracar")


func _on_llegada(_isla: String) -> void:
	_llegadas += 1
