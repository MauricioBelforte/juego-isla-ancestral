# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M68: Transporte y Navegación — TransportManager (autoload "TransportManager").
#
# Administra el grafo de transporte (TransportNetwork, única fuente de verdad),
# resuelve rutas para la UI (M53), cobra el boleto (M38), aplica descuentos
# (M20), respeta horarios (M29) y clima (M32), y persiste los waypoints (M59).
#
# ⚠️ Sin class_name: es autoload (GUIA-GODOT/09-godot4-migracion.md §9.17/§9.41).
# La convención del proyecto manda sobre el nombre del diseño.
#
# Integraciones por DUCK-TYPING tolerante: si M20/M29/M32/M38/M71 no están,
# el módulo sigue operativo (sin descuento, a las 12:00, sin clima, sin cobro,
# todo desbloqueado). Nunca se cae por una dependencia ausente.

extends Node

signal rutas_listadas(stop_id: StringName, rutas: Array)
signal viaje_iniciado(route_id: StringName, coste: int)
signal viaje_llegado(route_id: StringName, stop_id: StringName)
signal parada_desbloqueada(stop_id: StringName)
signal waypoint_agregado(stop_id: StringName)
signal waypoint_quitado(stop_id: StringName)

const RUTA_RED := "res://data/transporte/transport_network.tres"
const SECCION_GUARDADO := "transporte"
const PREFIJO_LOG := "[TRP]"
const NIVEL_AMISTAD_DESCUENTO := 5
## Códigos de clima adverso de M32 confirmados con M28 (TravelService):
## 3 = TORMENTA, 7 = TROPICAL. El código de "viento fuerte" del dirigible
## queda PENDIENTE de confirmación con M32 (ver Notas del Agente).
const CLIMAS_ADVERSOS: Array[int] = [3, 7]

var _red: TransportNetwork = null
var _paradas_desbloqueadas: Dictionary = {}   # id -> true (además de las iniciales)
var _waypoints: Array[String] = []            # ids de parada marcados por el jugador
var _viaje_activo: StringName = &""           # ruta en curso ("" = ninguno)

## ── Hooks de test ─────────────────────────────────────────
## Permiten fijar el contexto (hora/clima/estación/amistad) y simular una
## cartera, para que el test headless sea DETERMINISTA sin depender de M20/M29/
## M32/M38 reales. En producción quedan en -1/"" y se consultan los autoloads.
var _test_hora: int = -1
var _test_clima: int = -1
var _test_estacion: String = ""
var _test_amistad: int = -1
var _test_saldo: int = -1
## Hook de fecha (M29) para los viajes especiales: si está vacío se consulta el
## calendario real. Claves: dia, mes, anio, dia_absoluto, semana_dia, estacion.
var _test_fecha: Dictionary = {}

## Registros de la iter. 2 (secciones N/O/P/Q/V). Se crean en `_ready()`.
var _especiales: TransportSpecialTrips = null
var _narrativos: TransportNarrativeTrips = null
var _eventos_ruta: TransportRouteEvents = null
var _puente_m69: TransportM69Bridge = null
var _localizador: TransportLocalizer = null


func forzar_contexto(hora: int = -1, clima: int = -1, estacion: String = "", amistad: int = -1) -> void:
	_test_hora = hora
	_test_clima = clima
	_test_estacion = estacion
	_test_amistad = amistad


## Fija la fecha (M29) para los viajes especiales. -1 = no forzar ese campo.
func forzar_fecha(dia: int = -1, mes: int = -1, anio: int = -1, dia_absoluto: int = -1, semana_dia: int = -1, estacion: int = -1) -> void:
	_test_fecha = {}
	if dia > 0:
		_test_fecha["dia"] = dia
	if mes > 0:
		_test_fecha["mes"] = mes
	if anio > 0:
		_test_fecha["anio"] = anio
	if dia_absoluto > 0:
		_test_fecha["dia_absoluto"] = dia_absoluto
	if semana_dia >= 0:
		_test_fecha["semana_dia"] = semana_dia
	if estacion >= 0:
		_test_fecha["estacion"] = estacion


func fecha_forzada() -> Dictionary:
	return _test_fecha.duplicate()


## saldo < 0 desactiva la cartera simulada (vuelve a M38 real).
func forzar_cartera(saldo: int) -> void:
	_test_saldo = saldo


func saldo_simulado() -> int:
	return _test_saldo


func _ready() -> void:
	_cargar_red()
	_crear_registros()
	_registrar_servicio()
	_registrar_proveedor_guardado()


## Registros de la iter. 2. Se crean una vez y se exponen por API para que el
## validador y el test los usen sin duplicar la construcción.
func _crear_registros() -> void:
	_especiales = TransportSpecialTrips.new()
	_narrativos = TransportNarrativeTrips.new()
	_eventos_ruta = TransportRouteEvents.new()
	_puente_m69 = TransportM69Bridge.new()
	_localizador = TransportLocalizer.new(_red)


## ── Carga del grafo ───────────────────────────────────────

func _cargar_red() -> void:
	if not ResourceLoader.exists(RUTA_RED):
		push_warning("%s red de transporte no encontrada: %s" % [PREFIJO_LOG, RUTA_RED])
		_red = null
		return
	var rec: Resource = load(RUTA_RED)
	if rec == null or not (rec is TransportNetwork):
		push_error("%s %s no es un TransportNetwork" % [PREFIJO_LOG, RUTA_RED])
		_red = null
		return
	_red = rec as TransportNetwork
	var errores: Array[String] = _red.validar()
	if not errores.is_empty():
		push_error("%s red inválida (%d errores): %s" % [PREFIJO_LOG, errores.size(), errores[0]])
	print("%s red cargada: %d paradas, %d rutas" % [PREFIJO_LOG, _red.contar_stops(), _red.contar_rutas()])


func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr != null and sr.has_method("register_service"):
		sr.register_service("transporte", self)


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── API pública ───────────────────────────────────────────

func red() -> TransportNetwork:
	return _red


func tiene_red() -> bool:
	return _red != null and not _red.stops.is_empty()


func contar_paradas() -> int:
	return _red.contar_stops() if _red != null else 0


func contar_rutas() -> int:
	return _red.contar_rutas() if _red != null else 0


func parada(id: StringName) -> TransportStop:
	return _red.stop(id) if _red != null else null


## Rutas disponibles desde `stop_id` para la UI (M53): aplica desbloqueo (M71),
## horario (M29), clima (M32) y temporada, y calcula el precio con descuento
## (M20). Devuelve Array[Dictionary] con route_id, to, medio, precio, duracion,
## horario y motivo_bloqueo ("" si está disponible).
func list_routes(stop_id: StringName) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if _red == null:
		rutas_listadas.emit(stop_id, out)
		return out
	var hora: int = _hora_actual()
	var clima: int = _clima_actual()
	var nivel: int = _nivel_amistad()
	var estacion: String = _estacion_actual()
	for r in _red.rutas_desde(stop_id):
		var destino: TransportStop = _red.stop(r.to_id)
		if destino == null:
			continue
		# Sección N: un viaje especial programado NO aparece en el grafo normal.
		# Sólo se lista cuando su ventana (calendario M29 / evento M74) está activa.
		if ruta_oculta(String(r.id)) and not viaje_especial_activo(String(r.id)):
			continue
		var motivo: String = _motivo_bloqueo(r, destino, hora, clima, estacion)
		out.append({
			"route_id": String(r.id),
			"from": String(r.from_id),
			"to": String(r.to_id),
			"to_nombre": destino.nombre_fallback,
			"medio": r.medio,
			"precio": r.coste_con_descuento(nivel),
			"precio_base": r.base_cost,
			"duracion": r.duracion_con_clima(_factor_clima(r, clima)),
			"horario": destino.horario_texto(),
			"disponible": motivo.is_empty(),
			"motivo_bloqueo": motivo,
		})
	rutas_listadas.emit(stop_id, out)
	return out


## Compra el boleto de `route_id` desde `stop_id`. Cobra (M38), aplica el
## descuento (M20), marca el viaje como activo y registra TRIP-START.
## Devuelve {ok, motivo, precio, route_id}. NO mueve al jugador: eso es del
## TripService (necesita escena/jugador — fuera del alcance headless).
func buy_ticket(route_id: StringName, stop_id: StringName) -> Dictionary:
	if _red == null:
		return {"ok": false, "motivo": "sin red de transporte", "precio": 0}
	if not _viaje_activo.is_empty():
		return {"ok": false, "motivo": "ya hay un viaje en curso", "precio": 0}
	var r: TransportRoute = _red.ruta(route_id)
	if r == null:
		return {"ok": false, "motivo": "ruta inexistente", "precio": 0}
	if r.from_id != stop_id:
		return {"ok": false, "motivo": "la ruta no sale de esa parada", "precio": 0}
	var destino: TransportStop = _red.stop(r.to_id)
	if destino == null:
		return {"ok": false, "motivo": "destino inexistente", "precio": 0}
	var motivo: String = _motivo_bloqueo(r, destino, _hora_actual(), _clima_actual(), _estacion_actual())
	if not motivo.is_empty():
		return {"ok": false, "motivo": motivo, "precio": 0}
	var precio: int = r.coste_con_descuento(_nivel_amistad())
	if not _cobrar(precio):
		return {"ok": false, "motivo": "AO insuficiente: cuesta %d" % precio, "precio": precio}
	_viaje_activo = r.id
	_log("TRIP-START", {"route": String(r.id), "from": String(r.from_id), "to": String(r.to_id), "price": precio})
	viaje_iniciado.emit(r.id, precio)
	return {"ok": true, "motivo": "", "precio": precio, "route_id": String(r.id)}


## Cierra el viaje en curso (lo llama el TripService al terminar la transición).
## Registra TRIP-END y emite TRIP_FINISHED (M07) para M29/M74.
func notificar_llegada() -> Dictionary:
	if _viaje_activo.is_empty() or _red == null:
		return {"ok": false, "motivo": "sin viaje activo"}
	var r: TransportRoute = _red.ruta(_viaje_activo)
	_viaje_activo = &""
	if r == null:
		return {"ok": false, "motivo": "ruta huérfana"}
	_log("TRIP-END", {"route": String(r.id), "to": String(r.to_id)})
	viaje_llegado.emit(r.id, r.to_id)
	var eb := get_node_or_null("/root/EventBus")
	if eb != null and eb.has_signal("TRIP_FINISHED"):
		eb.emit_signal("TRIP_FINISHED", {"route": String(r.id), "to": String(r.to_id)})
	return {"ok": true, "route_id": String(r.id), "to": String(r.to_id)}


func viaje_en_curso() -> StringName:
	return _viaje_activo


## Camino más barato entre dos paradas, respetando desbloqueo y horario.
## Devuelve el diccionario de TransportNetwork.ruta_mas_barata + precio.
func planificar(origen: StringName, destino: StringName) -> Dictionary:
	if _red == null:
		return {"ok": false, "motivo": "sin red de transporte", "coste": -1, "saltos": 0}
	var hora: int = _hora_actual()
	var clima: int = _clima_actual()
	var estacion: String = _estacion_actual()
	var permitir := func(r: TransportRoute) -> bool:
		var d: TransportStop = _red.stop(r.to_id)
		return d != null and _motivo_bloqueo(r, d, hora, clima, estacion).is_empty()
	var res: Dictionary = _red.ruta_mas_barata(origen, destino, permitir)
	if bool(res.get("ok", false)):
		res["precio"] = int(res.get("coste", 0))
	return res


## ── Iter. 2: registros de viajes especiales, narrativos, eventos y M69 ────

func especiales() -> TransportSpecialTrips:
	return _especiales


func narrativos() -> TransportNarrativeTrips:
	return _narrativos


func eventos_de_ruta() -> TransportRouteEvents:
	return _eventos_ruta


func puente_m69() -> TransportM69Bridge:
	return _puente_m69


func localizador() -> TransportLocalizer:
	return _localizador


## ¿La ruta está oculta del grafo normal por ser de un viaje programado (N)?
func ruta_oculta(ruta_id: String) -> bool:
	if _especiales == null:
		return false
	return _especiales.ruta_oculta(ruta_id)


## ¿Hay algún viaje especial disponible AHORA que use esta ruta?
func viaje_especial_activo(ruta_id: String) -> bool:
	if _especiales == null:
		return false
	var fecha: Dictionary = _fecha_actual()
	var ctx: Dictionary = _contexto_eventos()
	for v in _especiales.viajes_con_ruta(ruta_id):
		var d: Dictionary = _especiales.disponible_en(v, fecha, ctx)
		if bool(d.get("ok", false)):
			return true
	return false


## Viajes especiales disponibles ahora, con su precio y su ruta (sección N).
func viajes_especiales_disponibles() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if _especiales == null:
		return out
	return _especiales.disponibles(_fecha_actual(), _contexto_eventos())


## Viajes narrativos disponibles para el capítulo actual (sección O).
func viajes_narrativos_disponibles() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if _narrativos == null:
		return out
	var capitulo: int = _capitulo_actual()
	var flags: Array = _flags_activas()
	for v in _narrativos.viajes():
		var d: Dictionary = _narrativos.disponible_para(v, capitulo, flags)
		if bool(d.get("ok", false)):
			out.append(v)
	return out


## Evento de ruta aplicable a una ruta (sección P). Determinista por semilla.
func evento_de_ruta(ruta_id: String, semilla: int = 0) -> Dictionary:
	if _eventos_ruta == null:
		return {"ok": false, "motivo": "sin registro de eventos", "evento": {}}
	var ctx: Dictionary = {
		"clima": _clima_actual(),
		"eventos_activos": _contexto_eventos().get("eventos_activos", []),
	}
	return _eventos_ruta.elegir(ruta_id, ctx, semilla, _red)


## Fecha actual (M29) con los hooks de test aplicados encima.
func _fecha_actual() -> Dictionary:
	var out: Dictionary = {
		"dia": 1, "mes": 1, "anio": 1, "dia_absoluto": 1,
		"semana_dia": 0, "estacion": 0, "hora": _hora_actual(),
	}
	for nombre in ["/root/TimeCalendar", "/root/GameTime"]:
		var n := get_node_or_null(nombre)
		if n == null:
			continue
		if n.has_method("get_fecha"):
			var f: Variant = n.call("get_fecha")
			if f is Dictionary:
				var fd: Dictionary = f
				for k in fd.keys():
					out[str(k)] = fd[k]
		if n.has_method("get_dia_absoluto"):
			out["dia_absoluto"] = int(n.call("get_dia_absoluto"))
		if n.has_method("get_semana_dia"):
			out["semana_dia"] = int(n.call("get_semana_dia"))
		if n.has_method("get_estacion"):
			out["estacion"] = int(n.call("get_estacion"))
		break
	for k2 in _test_fecha.keys():
		out[str(k2)] = _test_fecha[k2]
	return out


## Contexto de eventos de M74 (autoload `eventos`) para los viajes especiales.
func _contexto_eventos() -> Dictionary:
	var activos: Array[String] = []
	var ev := get_node_or_null("/root/eventos")
	if ev != null:
		if ev.has_method("get_evento_actual"):
			var a: Variant = ev.call("get_evento_actual")
			if a != null:
				var aid: Variant = a.get("id")
				if aid != null:
					activos.append(str(aid))
		if ev.has_method("get_eventos_del_dia"):
			var lista: Variant = ev.call("get_eventos_del_dia", _fecha_actual())
			if lista is Array:
				for e in lista:
					if e != null:
						var eid: Variant = e.get("id")
						if eid != null and not activos.has(str(eid)):
							activos.append(str(eid))
	return {"eventos_activos": activos}


func _capitulo_actual() -> int:
	var h := get_node_or_null("/root/Historia")
	if h != null and h.has_method("capitulo_actual"):
		return int(h.call("capitulo_actual"))
	return 0


func _flags_activas() -> Array:
	var out: Array = []
	var ws := get_node_or_null("/root/WorldState")
	if ws == null or not ws.has_method("flags"):
		return out
	var f: Variant = ws.call("flags")
	if f is Dictionary:
		var fd: Dictionary = f
		for k in fd.keys():
			if bool(fd[k]):
				out.append(str(k))
	elif f is Array:
		for x in f:
			out.append(str(x))
	return out


## ── Desbloqueo (M71) ──────────────────────────────────────

## ¿La parada está desbloqueada? (inicial, ya desbloqueada en runtime, o por
## flag de WorldState de M71/M22). El nombre NO puede ser `parada_desbloqueada`
## porque colisiona con la señal homónima (GDScript lo rechaza al compilar).
func esta_parada_desbloqueada(stop_id: StringName) -> bool:
	if _paradas_desbloqueadas.has(stop_id):
		return true
	var s: TransportStop = parada(stop_id)
	if s == null:
		return false
	if s.desbloqueada_inicial:
		return true
	if s.desbloquea_flag != &"":
		return _tiene_flag(s.desbloquea_flag)
	return false


func desbloquear_parada(stop_id: StringName) -> bool:
	if parada(stop_id) == null:
		return false
	if esta_parada_desbloqueada(stop_id):
		return false
	_paradas_desbloqueadas[stop_id] = true
	_log("STOP-UNLOCKED", {"stop": String(stop_id)})
	parada_desbloqueada.emit(stop_id)
	return true


## ── Waypoints (persistidos, M59) ──────────────────────────

func agregar_waypoint(stop_id: StringName) -> bool:
	if parada(stop_id) == null:
		return false
	if _waypoints.has(String(stop_id)):
		return false
	_waypoints.append(String(stop_id))
	waypoint_agregado.emit(stop_id)
	return true


func quitar_waypoint(stop_id: StringName) -> bool:
	var sid: String = String(stop_id)
	if not _waypoints.has(sid):
		return false
	_waypoints.erase(sid)
	waypoint_quitado.emit(stop_id)
	return true


func waypoints() -> Array[String]:
	return _waypoints.duplicate()


func tiene_waypoint(stop_id: StringName) -> bool:
	return _waypoints.has(String(stop_id))


## ── Persistencia (M59 / ISaveProvider) ────────────────────

func get_section_name() -> String:
	return SECCION_GUARDADO


func get_save_data() -> Dictionary:
	# Nunca devolver referencias vivas (BUG-014): copias explícitas.
	var desbloqueadas: Array[String] = []
	for k in _paradas_desbloqueadas.keys():
		desbloqueadas.append(String(k))
	desbloqueadas.sort()
	return {
		"desbloqueadas": desbloqueadas,
		"waypoints": _waypoints.duplicate(),
		"viaje_activo": String(_viaje_activo),
	}


func restore_save_data(datos: Dictionary) -> void:
	_paradas_desbloqueadas.clear()
	for k in datos.get("desbloqueadas", []):
		_paradas_desbloqueadas[StringName(String(k))] = true
	_waypoints.clear()
	for w in datos.get("waypoints", []):
		_waypoints.append(String(w))
	var activo: String = String(datos.get("viaje_activo", ""))
	if not activo.is_empty() and _red != null and _red.ruta(StringName(activo)) == null:
		# Ruta huérfana (dataset cambiado): se descarta el viaje, nunca soft-lock.
		_log("TRIP-ORPHAN", {"route": activo})
		activo = ""
	_viaje_activo = StringName(activo)


## ── Helpers de integración (duck-typing tolerante) ────────

func _motivo_bloqueo(r: TransportRoute, destino: TransportStop, hora: int, clima: int, estacion: String) -> String:
	if ruta_oculta(String(r.id)) and not viaje_especial_activo(String(r.id)):
		# Protege también `buy_ticket` y `planificar`, no sólo el listado.
		return "viaje especial: sólo programado"
	if not esta_parada_desbloqueada(r.to_id):
		return "destino bloqueado"
	if r.requiere_flag != &"" and not _tiene_flag(r.requiere_flag):
		return "requiere progreso: %s" % r.requiere_flag
	if not destino.abierta_a(hora):
		return "fuera de horario (%s)" % destino.horario_texto()
	if r.temporada != "" and r.temporada != "todas" and r.temporada != estacion:
		return "sólo en %s" % r.temporada
	if r.medio == "barco" and clima in CLIMAS_ADVERSOS:
		return "mar peligroso por clima (M32)"
	return ""


func _factor_clima(r: TransportRoute, clima: int) -> float:
	if r.afectada_por_clima() and clima in CLIMAS_ADVERSOS:
		return 1.0
	return 0.0


func _hora_actual() -> int:
	if _test_hora >= 0:
		return clampi(_test_hora, 0, 23)
	for nombre in ["/root/GameTime", "/root/TimeCalendar"]:
		var n := get_node_or_null(nombre)
		if n != null and n.has_method("get_hora"):
			return int(n.get_hora())
	return 12


func _estacion_actual() -> String:
	if not _test_estacion.is_empty():
		return _test_estacion
	var nombres: Array[String] = ["primavera", "verano", "otono", "invierno"]
	for nombre in ["/root/GameTime", "/root/TimeCalendar"]:
		var n := get_node_or_null(nombre)
		if n != null and n.has_method("get_estacion"):
			return nombres[clampi(int(n.get_estacion()), 0, 3)]
	return "primavera"


func _clima_actual() -> int:
	if _test_clima >= 0:
		return _test_clima
	var w := get_node_or_null("/root/Weather")
	if w != null and w.has_method("get_clima"):
		return int(w.get_clima())
	return 0


## Nivel de amistad para el descuento de M20. La API real de M20 es por vecino
## (`Friendship.get_nivel(vecino_id)`), y el diseño habla del nivel del pasajero
## con el destino — requiere contexto de NPC que M68 no tiene todavía. Se usa un
## nivel GLOBAL si M20 lo expone; si no, 0 (sin descuento). El test lo fuerza
## con `forzar_contexto(amistad = 5)`.
func _nivel_amistad() -> int:
	if _test_amistad >= 0:
		return _test_amistad
	var f := get_node_or_null("/root/Friendship")
	if f == null:
		return 0
	for nombre in ["nivel_global", "nivel_maximo", "nivel_promedio"]:
		if f.has_method(nombre):
			return int(f.call(nombre))
	return 0


func _tiene_flag(flag: StringName) -> bool:
	var ws := get_node_or_null("/root/WorldState")
	if ws != null and ws.has_method("has_flag"):
		return bool(ws.has_flag(String(flag)))
	return false


func _cobrar(monto: int) -> bool:
	if monto <= 0:
		return true
	if _test_saldo >= 0:
		# Cartera simulada (test determinista): no toca el saldo real de M38.
		if _test_saldo < monto:
			return false
		_test_saldo -= monto
		return true
	var eco := get_node_or_null("/root/EconomyManager")
	if eco == null:
		return true  # sin M38 no se bloquea el viaje (V0 tolerante)
	if eco.has_method("retirar_monedas"):
		return bool(eco.retirar_monedas(monto))
	if eco.has_method("spend"):
		return bool(eco.spend(monto))
	return true


func _log(evento: String, datos: Dictionary) -> void:
	var partes: Array[String] = []
	for k in datos.keys():
		partes.append("%s=%s" % [k, datos[k]])
	var linea := "%s %s %s" % [PREFIJO_LOG, evento, " ".join(partes)]
	var gl := get_node_or_null("/root/GameLogger")
	if gl != null and gl.has_method("info"):
		gl.info(linea)
	else:
		print(linea)
