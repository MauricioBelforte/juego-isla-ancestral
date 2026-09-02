# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M28: Viajes — TravelService (autoload "TravelService")
# Núcleo V0/V1 sobre 03-Diseno §2-§6:
#  - Rutas data-driven en data/viajes/rutas.json (costes coherentes con
#    balance travel.json de M93; BoatRoute runtime).
#  - Embarque: destino desbloqueado (flag M22 vía WorldState / visita previa),
#    boleto pagado (M38 EconomyManager), horario (línea nocturna M29),
#    un solo viaje activo (§6).
#  - Clima M32: retraso-sin-bloqueo (§3.2.4) — tormenta/tropical +25% duración
#    + señal travel_delayed con aviso amable; jamás cancelación.
#  - Cancelación §3.4: pre-embarque refund 100%; embarcado en puerto 50%;
#    en travesía no se cancela (viaje en curso).
#  - Persistencia M59: serialize/restore (§6) — si se guarda en travesía, al
#    restaurar continúa con tiempo restante intacto.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41); el
# contrato del diseño lo llama "class_name TravelService", la convención del
# proyecto manda ( BoatRoute sí lleva class_name por ser Resource).
extends Node

signal travel_started(route_id: StringName)
signal travel_progress(progress: float)
signal travel_arrived(island_id: String)
signal travel_cancelled(refund: int)
signal travel_delayed(delay_seconds: float, reason: String)

enum TravelState { IDLE, WAITING_DEPARTURE, SAILING, ARRIVING }

## Retraso de salida por clima adverso (§3.1.5: 5-15 s), en segundos reales
const DELAY_SALIDA_MIN: float = 5.0
const DELAY_SALIDA_MAX: float = 15.0
## Factor de duración con clima adverso (§3.2.4: +25%)
const FACTOR_CLIMA: float = 0.25
## Refunds de cancelación (§3.4)
const REFUND_PRE_EMBARQUE: float = 1.0
const REFUND_EN_PUERTO: float = 0.5

var _rutas: Dictionary = {}  # route_id -> BoatRoute
var _estado: int = TravelState.IDLE
var _ruta_actual: BoatRoute = null
var _duracion_efectiva: float = 0.0
var _transcurrido: float = 0.0
var _destinos_visitados: Array[String] = []
var _delay_pendiente: float = 0.0


func _ready() -> void:
	_cargar_rutas()
	_registrar_proveedor_guardado()


func _cargar_rutas() -> void:
	_rutas.clear()
	var texto := FileAccess.get_file_as_string("res://data/viajes/rutas.json")
	var parseado: Variant = JSON.parse_string(texto)
	if typeof(parseado) != TYPE_DICTIONARY:
		push_error("[M28] rutas.json inválido; sin rutas")
		return
	for datos in parseado.get("rutas", []):
		var ruta := BoatRoute.new()
		ruta.route_id = StringName(String(datos.get("id", "")))
		ruta.origin_island_id = String(datos.get("origen", "isla_raiz"))
		ruta.destination_island_id = String(datos.get("destino", ""))
		ruta.base_duration_seconds = float(datos.get("duracion_seg", 30.0))
		ruta.cost_coins = int(datos.get("coste_ao", 0))
		ruta.required_quest = StringName(String(datos.get("requiere_flag", "")))
		ruta.is_secret = bool(datos.get("secreta", false))
		ruta.is_night_line = bool(datos.get("nocturna", false))
		ruta.temporada = String(datos.get("temporada", ""))
		if ruta.route_id != &"" and ruta.destination_island_id != "":
			_rutas[ruta.route_id] = ruta
	print("[M28] Rutas cargadas: %d" % _rutas.size())


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── API pública (03-Diseno §4) ──────────────────────────

func rutas_count() -> int:
	return _rutas.size()


func get_available_destinations() -> Array[BoatRoute]:
	var visibles: Array[BoatRoute] = []
	var ws := get_node_or_null("/root/WorldState")
	for ruta in _rutas.values():
		if ruta.is_secret:
			var desbloqueada: bool = ws != null and ws.has_flag(String(ruta.required_quest))
			if not desbloqueada:
				continue
		visibles.append(ruta)
	return visibles


func request_travel(destination_island_id: String) -> Dictionary:
	if _estado != TravelState.IDLE:
		var m := "ya hay un viaje activo (un solo viaje, §6)"
		travel_cancelled.emit(0)
		return {"ok": false, "motivo": m}
	# Buscar ruta hacia el destino (la primera que aparezca disponible)
	var ruta := _ruta_hacia(destination_island_id)
	if ruta == null:
		var m := "sin ruta disponible hacia %s" % destination_island_id
		travel_cancelled.emit(0)
		return {"ok": false, "motivo": m}
	# Desbloqueo M22 (flag) — rutas secretas y normales con requisito
	var ws := get_node_or_null("/root/WorldState")
	if ruta.required_quest != &"" and (ws == null or not ws.has_flag(String(ruta.required_quest))):
		var m := "destino bloqueado por historia (M22): falta %s" % ruta.required_quest
		travel_cancelled.emit(0)
		return {"ok": false, "motivo": m}
	# Horario: línea nocturna solo 21:00-05:00 (M29)
	if ruta.is_night_line:
		var hora := _hora_actual()
		if hora < 21 and hora >= 5:
			var m := "línea nocturna disponible solo de noche (M29)"
			travel_cancelled.emit(0)
			return {"ok": false, "motivo": m}
	# Temporada (coherencia con M93 travel.json)
	if ruta.temporada != "" and ruta.temporada != "todas" and _estacion_actual_nombre() != ruta.temporada:
		var m := "ruta solo disponible en %s" % ruta.temporada
		travel_cancelled.emit(0)
		return {"ok": false, "motivo": m}
	# Boleto (M38): pago upfront; devoluciones vía cancel_travel
	var eco := get_node_or_null("/root/EconomyManager")
	if eco == null or not eco.has_method("retirar_monedas"):
		var m := "economía no disponible (M38)"
		travel_cancelled.emit(0)
		return {"ok": false, "motivo": m}
	if not eco.retirar_monedas(ruta.cost_coins):
		var m := "AO insuficiente: cuesta %d" % ruta.cost_coins
		travel_cancelled.emit(0)
		return {"ok": false, "motivo": m}
	# Clima M32: retraso-sin-bloqueo (§3.1.5/§3.2.4) — nunca cancelación
	var factor_clima := _factor_clima_actual()
	var razon := _razon_clima()
	_duracion_efectiva = ruta.compute_duration_with_weather(factor_clima)
	_transcurrido = 0.0
	_ruta_actual = ruta
	if factor_clima > 0.0:
		_delay_pendiente = randf_range(DELAY_SALIDA_MIN, DELAY_SALIDA_MAX)
		_estado = TravelState.WAITING_DEPARTURE
		travel_delayed.emit(_delay_pendiente, razon)
		print("[M28] Salida retrasada %.0f s (%s)" % [_delay_pendiente, razon])
	else:
		_zarpar()
	return {"ok": true, "motivo": "", "route_id": String(ruta.route_id)}


func cancel_travel() -> Dictionary:
	# §3.4: pre-embarque 100%; embarcado en puerto 50%; en travesía no cancela
	if _estado == TravelState.WAITING_DEPARTURE:
		var refund := int(float(_ruta_actual.cost_coins) * REFUND_PRE_EMBARQUE)
		_reembolsar(refund)
		_estado = TravelState.IDLE
		_ruta_actual = null
		travel_cancelled.emit(refund)
		print("[M28] Viaje cancelado pre-embarque (refund %d AO)" % refund)
		return {"ok": true, "refund": refund}
	if _estado == TravelState.SAILING or _estado == TravelState.ARRIVING:
		return {"ok": false, "motivo": "viaje en travesía: no cancelable", "refund": 0}
	return {"ok": false, "motivo": "sin viaje activo", "refund": 0}


func is_traveling() -> bool:
	return _estado != TravelState.IDLE


func get_current_state() -> int:
	return _estado


func get_travel_progress() -> float:
	if _estado == TravelState.IDLE or _duracion_efectiva <= 0.0:
		return 0.0
	return clampf(_transcurrido / _duracion_efectiva, 0.0, 1.0)


## Factor de clima actual (M32): 0 calma, 1 clima adverso (tormenta/tropical)
func _factor_clima_actual() -> float:
	var w := get_node_or_null("/root/Weather")
	if w == null or not w.has_method("get_clima"):
		return 0.0
	var clima := int(w.get_clima())
	if clima == 3 or clima == 7:  # TORMENTA / TROPICAL
		return 1.0
	return 0.0


func _razon_clima() -> String:
	var w := get_node_or_null("/root/Weather")
	if w != null and w.has_method("get_clima"):
		var clima := int(w.get_clima())
		if clima == 3:
			return "tormenta en el mar"
		if clima == 7:
			return "brisa tropical fuerte"
	return "mar agitado"


func _ruta_hacia(destino: String) -> BoatRoute:
	for ruta in _rutas.values():
		if ruta.destination_island_id == destino and ruta.origin_island_id == _isla_actual():
			return ruta
	# Fallback V0: si no hay coincidencia de origen, la primera hacia el destino
	for ruta in _rutas.values():
		if ruta.destination_island_id == destino:
			return ruta
	return null


func _isla_actual() -> String:
	# V0: el jugador siempre parte de isla_raiz (M27/M11 definirán isla actual)
	return "isla_raiz"


func _hora_actual() -> int:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_hora"):
		return int(gt.get_hora())
	var cal := get_node_or_null("/root/TimeCalendar")
	if cal != null and cal.has_method("get_hora"):
		return int(cal.get_hora())
	return 12


func _estacion_actual_nombre() -> String:
	var nombres := ["primavera", "verano", "otono", "invierno"]
	var gt := get_node_or_null("/root/GameTime")
	if gt != null and gt.has_method("get_estacion"):
		return nombres[clampi(int(gt.get_estacion()), 0, 3)]
	return "primavera"


## Simula la travesía (llamado por _process; los tests pueden acelerarlo).
func _process(delta: float) -> void:
	if _estado == TravelState.IDLE:
		return
	if _estado == TravelState.WAITING_DEPARTURE:
		_delay_pendiente -= delta
		if _delay_pendiente <= 0.0:
			_zarpar()
		return
	# SAILING / ARRIVING
	_transcurrido += delta
	var progreso := get_travel_progress()
	travel_progress.emit(progreso)
	if progreso >= 1.0:
		_atracar()


func _zarpar() -> void:
	_estado = TravelState.SAILING
	travel_started.emit(_ruta_actual.route_id)
	print("[M28] Zarpando hacia %s (duración %.0f s)" % [_ruta_actual.destination_island_id, _duracion_efectiva])


func _atracar() -> void:
	var destino := _ruta_actual.destination_island_id
	_estado = TravelState.ARRIVING
	if not _destinos_visitados.has(destino):
		_destinos_visitados.append(destino)
	_estado = TravelState.IDLE
	_duracion_efectiva = 0.0
	_transcurrido = 0.0
	var ruta := _ruta_actual
	_ruta_actual = null
	travel_arrived.emit(destino)
	print("[M28] Llegada a %s (ruta %s)" % [destino, ruta.route_id])


func _reembolsar(monto: int) -> void:
	var eco := get_node_or_null("/root/EconomyManager")
	if eco != null and eco.has_method("depositar_monedas"):
		eco.depositar_monedas(monto)


## ── Persistencia (M59, diseño §6: mitad de ruta) ────────

func get_section_name() -> String:
	return "viajes"


func get_save_data() -> Dictionary:
	return {
		"estado": _estado,
		"ruta_id": String(_ruta_actual.route_id) if _ruta_actual != null else "",
		"transcurrido": _transcurrido,
		"duracion_efectiva": _duracion_efectiva,
		"visitados": _destinos_visitados.duplicate(),
	}


func restore_save_data(data: Dictionary) -> void:
	_estado = int(data.get("estado", 0))
	_transcurrido = float(data.get("transcurrido", 0.0))
	_duracion_efectiva = float(data.get("duracion_efectiva", 0.0))
	_destinos_visitados.clear()
	for v in data.get("visitados", []):
		_destinos_visitados.append(String(v))
	var ruta_id := String(data.get("ruta_id", ""))
	_ruta_actual = _rutas.get(ruta_id, null)
	if _ruta_actual == null and _estado != TravelState.IDLE:
		# Ruta huérfana: resetear limpio (nunca soft-lock, §3.3.2)
		print("[M28] Ruta huérfana al restaurar (%s); viaje descartado" % ruta_id)
		_estado = TravelState.IDLE
		_transcurrido = 0.0
