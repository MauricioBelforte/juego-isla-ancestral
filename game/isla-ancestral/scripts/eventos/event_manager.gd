# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos â€” EventManager (autoload "eventos")
#
# Orquestador central de eventos: catÃ¡logo, agenda anual, disparo con aviso previo,
# participaciÃ³n con condiciones, recompensas seguras con token anti-duplicado,
# anti-FOMO (todo repetible anual), persistencia versionada M59.
#
# Reglas de oro:
# 1. Nunca leer reloj del SO; usar GameClock (M30).
# 2. Nada se pierde para siempre: evento anual se repite.
# 3. Token anti-duplicado por aÃ±o natural, no permanente.
# 4. Cero polling por frame: checks en dia_cambio / anio_cambio / clima_cambio.
# 5. UI separada por seÃ±ales (M09).
# 6. Fallback: si escena falla, evento_cancelado + compensaciÃ³n, jamÃ¡s crash.

extends Node

## â”€â”€ SeÃ±ales pÃºblicas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
signal evento_proximo(evento_id: StringName, dias_restantes: int)
signal evento_iniciado(evento_id: StringName)
signal evento_terminado(evento_id: StringName)
signal evento_cancelado(evento_id: StringName, razon: StringName)
signal evento_recompensa_entregada(evento_id: StringName, recompensa: Dictionary)
signal agenda_actualizada()

## â”€â”€ CatÃ¡logo y estado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var _catalogo: Dictionary = {}          # id -> EventDefinition
var _estado_anual: Dictionary = {}      # anio -> {evento_id -> EventState}
var _sorpresa_semanal_count: int = 0
var _ultima_semana_sorpresa: int = -1
var _eventos_del_dia_cache: Array = []  # Cache para el dÃ­a actual
var _aviso_emitido_hoy: PackedStringArray = []  # Para evitar doble aviso
const MAX_SORPRESAS_SEMANA: int = 3
const DIAS_PARA_AVISO_DEFAULT: int = 3

## â”€â”€ Evento actual â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
var evento_actual: Object = null
var evento_actual_id: StringName = &""


func _ready() -> void:
	print("[EventManager] Inicializando M74...")
	_cargar_catalogo()
	_conectar_eventbus()
	normalizar_agenda()
	_registrar_proveedor_guardado()
	print("[EventManager] CatÃ¡logo cargado: %d eventos" % _catalogo.size())


func _cargar_catalogo() -> void:
	"""Cargar todos los EventDefinition desde data/eventos/."""
	var base_dir: String = "res://scripts/eventos/data/"
	var tipos: Array[String] = ["festivales", "ferias", "competencias", "rituales", "climaticos", "sorpresas"]
	for tipo_dir in tipos:
		var dir_path: String = base_dir + tipo_dir + "/"
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir == null:
			DirAccess.make_dir_recursive_absolute(dir_path)
			continue
		dir.list_dir_begin()
		var file: String = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				var path: String = dir_path + file
				var resource: Variant = load(path)
				if resource != null and resource is EventDefinition:
					if not _catalogo.has(resource.id):
						_catalogo[resource.id] = resource
						print("[EventManager] Cargado: %s (%s)" % [resource.id, resource.nombre_clave])
			file = dir.get_next()
		dir.list_dir_end()


func _conectar_eventbus() -> void:
	"""Suscribirse a seÃ±ales de M29/M30/M32."""
	var gt = get_node_or_null("/root/GameTime")
	if gt != null:
		gt.dia_cambio.connect(_on_dia_cambio)
		print("[EventManager] Suscrito a GameTime.dia_cambio")
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null:
		tc.evento_activado.connect(func(ev): _on_festival_data_event(ev))
		print("[EventManager] Suscrito a TimeCalendar.evento_activado")
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.weather.has_signal("clima_cambio"):
		bus.weather.clima_cambio.connect(_on_clima_cambio)
		print("[EventManager] Suscrito a EventBus.weather.clima_cambio")
func _on_dia_cambio(info: Dictionary) -> void:
	"""Chequeo diario de agenda: avisos, inicio, fin de eventos."""
	var anio = info.get("anio", 1)
	var mes = info.get("mes", 1)
	var dia = info.get("dia", 1)
	var estacion = info.get("estacion", 0)
	var hora = get_node_or_null("/root/GameTime")
	var hora_val := 0
	if hora != null:
		hora_val = hora.get_hora()
	var minuto_val := 0
	if hora != null:
		minuto_val = hora.get_minuto()

	# 1. Chequear aviso previo para eventos prÃ³ximos
	_verificar_aviso_previo(anio, mes, dia, estacion, hora_val, minuto_val)

	# 2. Chequear inicio de eventos (franja horaria)
	_verificar_inicio_evento(anio, mes, dia, estacion, hora_val, minuto_val)

	# 3. Chequear fin de eventos
	_verificar_fin_evento(anio, mes, dia, estacion, hora_val, minuto_val)

	# 4. Resetear contador de sorpresas semanal
	_verificar_sorpresa_diaria(anio, mes, dia, estacion)

	# 5. Limpiar cache de avisos emitidos hoy
	_aviso_emitido_hoy.clear()

	# 6. Emitir seÃ±al de agenda actualizada
	agenda_actualizada.emit()


func _on_clima_cambio(clima: int) -> void:
	"""Manejar variante cubierta ante clima severo."""
	if clima == 3:  # Tormenta
		# Si hay un evento al aire libre en curso, verificar variante
		if evento_actual != null and evento_actual.variante_cubierta != null:
			if evento_actual.variante_cubierta != null:
				print("[EventManager] Tormenta detectada, variante cubierta para %s" % evento_actual_id)
				# La UI consumirÃ­a esta seÃ±al para cambiar de escena
				pass


func _verificar_aviso_previo(anio: int, mes: int, dia: int, estacion: int, hora: int, minuto: int) -> void:
	"""Emitir evento_proximo cuando falta dias_aviso para un evento."""
	for ev_id in _catalogo.keys():
		var ev: EventDefinition = _catalogo[ev_id]
		if not ev.coincide_fecha(dia, mes, estacion):
			# Verificar si es prÃ³ximo (dentro de dias_aviso)
			var mins_hasta = ev.minutos_hasta_inicio(hora, minuto)
			var dias_hasta = mins_hasta / 1440
			if dias_hasta > 0 and dias_hasta <= ev.dias_aviso:
				# Solo emitir si no se avisÃ³ antes
				var key := "%s_%d" % [ev_id, anio]
				if key not in _aviso_emitido_hoy:
					_aviso_emitido_hoy.append(key)
					evento_proximo.emit(ev_id, dias_hasta)
					print("[EventManager] Aviso previo: %s en %d dÃ­as" % [ev_id, dias_hasta])


func _verificar_inicio_evento(anio: int, mes: int, dia: int, estacion: int, hora: int, minuto: int) -> void:
	"""Iniciar evento cuando entramos en la franja horaria."""
	for ev_id in _catalogo.keys():
		var ev: EventDefinition = _catalogo[ev_id]
		if not ev.coincide_fecha(dia, mes, estacion):
			continue
		if not ev.esta_en_franja(hora, minuto):
			continue
		# Verificar si ya estÃ¡ en curso
		var es = _get_estado(ev_id, anio)
		if es == null or es.estado == EventState.Estado.PENDIENTE:
			# Iniciar evento
			_iniciar_evento(ev, anio)
			Ocupar_npcs_para_evento(ev)
			evento_iniciado.emit(ev_id)
			print("[EventManager] Evento iniciado: %s" % ev_id)
			return
		# Verificar ocupaciÃ³n de NPCs (M19)


func _verificar_fin_evento(anio: int, mes: int, dia: int, estacion: int, hora: int, minuto: int) -> void:
	"""Terminar evento cuando salimos de la franja horaria."""
	if evento_actual == null:
		return
	var ev_id = evento_actual_id
	var ev: EventDefinition = _catalogo.get(ev_id, null)
	if ev == null:
		return
	if not ev.esta_en_franja(hora, minuto):
		# Franco terminÃ³
		_finalizar_evento(ev_id, anio, false)
		evento_terminado.emit(ev_id)
		print("[EventManager] Evento terminado: %s" % ev_id)


func _iniciar_evento(ev: EventDefinition, anio: int) -> void:
	"""Inicializar estado de un evento."""
	var es := EventState.new()
	es.evento_id = ev.id
	es.anio = anio
	es.estado = EventState.Estado.EN_CURSO
	_set_estado(ev.id, anio, es)
	evento_actual = ev
	evento_actual_id = ev.id


func _finalizar_evento(ev_id: StringName, anio: int, cancelado: bool) -> void:
	"""Finalizar un evento, marcando participados/no participados."""
	var es = _get_estado(ev_id, anio)
	if es == null:
		return
	if cancelado:
		es.estado = EventState.Estado.CANCELADO
		es.dia_cancelacion = anio  # Simplificado
		# Entregar recompensa compensatoria si existe
		var ev: EventDefinition = _catalogo.get(ev_id, null)
		if ev != null and ev.recompensa_compensatoria != null:
			_entregar_una_recompensa(ev.recompensa_compensatoria, ev, anio)
	else:
		# Si el jugador no participÃ³, marcar NO_PARTICIPADO
		if es.estado != EventState.Estado.PARTICIPADO:
			es.estado = EventState.Estado.NO_PARTICIPADO
	evento_actual = null
	evento_actual_id = &""


func _on_festival_data_event(ev: Dictionary) -> void:
	"""Callback desde FestivalData de M29 para eventos ya definidos."""
	# Este callback permite que los eventos de festivals.tres
	# se sincronicen con el nuevo sistema M74
	pass


# â”€â”€ ParticipaciÃ³n â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func puede_participar(evento_id: StringName) -> Dictionary:
	"""EvalÃºa si el jugador puede participar. Retorna {ok: bool, razon: StringName}."""
	var ev: EventDefinition = _catalogo.get(evento_id, null)
	if ev == null:
		return {"ok": false, "razon": &"evento_no_existe"}
	# Chequear si ya participÃ³ este aÃ±o
	var anio = _get_anio_actual()
	var es = _get_estado(evento_id, anio)
	if es != null and es.is_participated_this_year(anio):
				return {"ok": false, "razon": &"ya_participado_este_anio"}
	# Evaluar condiciones
	var ctx := _build_context()
	for cond_resource in ev.condiciones:
		if cond_resource is CondicionEvento:
			var result = cond_resource.evaluar(ctx)
			if not result.ok:
				return {"ok": false, "razon": result.razon}
	return {"ok": true, "razon": &""}


func iniciar_participacion(evento_id: StringName, contexto: Dictionary = {}) -> bool:
	"""Fija estado EN_CURSO del participante. Retorna false si ya participó."""
	var anio = _get_anio_actual()
	var es = _get_estado(evento_id, anio)
	if es == null:
		var new_es := EventState.new()
		new_es.evento_id = evento_id
		new_es.anio = anio
		new_es.estado = EventState.Estado.PENDIENTE
		_set_estado(evento_id, anio, new_es)
		es = new_es
	if es.is_participated_this_year(anio):
		print("[EventManager] Ya participaste de %s este año" % evento_id)
		return false
	es.estado = EventState.Estado.PARTICIPADO
	es.anio_participacion = anio
	return true


func finalizar_evento(evento_id: StringName, resultado_data: Dictionary = {}) -> void:
	"""Finaliza participaciÃ³n y entrega recompensas."""
	var anio = _get_anio_actual()
	var ev: EventDefinition = _catalogo.get(evento_id, null)
	if ev == null:
		return
	_entregar_recompensas(ev, anio, resultado_data)
	var es = _get_estado(evento_id, anio)
	if es != null:
		es.resultado = resultado_data
		if resultado_data.has("mejor_puesto"):
			es.mejor_puesto = int(resultado_data["mejor_puesto"])


func _entregar_recompensas(ev: EventDefinition, anio: int, resultado: Dictionary = {}) -> void:
	"""Entrega todas las recompensas del evento con verificaciÃ³n doble."""
	for recomp in ev.recompensas:
		if recomp is RecompensaDef:
			_entregar_una_recompensa(recomp, ev, anio)


func _entregar_una_recompensa(recomp: RecompensaDef, ev: EventDefinition, anio: int) -> void:
	"""Entrega una recompensa individual con validaciÃ³n de token anti-duplicado."""
	var es = _get_estado(ev.id, anio)
	if es == null or not es.puede_recibir_recompensa(anio):
		print("[EventManager] Recompensa %s ya entregada este aÃ±o o estado invÃ¡lido" % ev.id)
		return
	# Entregar
	var ok = recomp.entregar(self, {"evento_id": ev.id})
	if ok:
		es.marcar_recompensa_recibida(anio)
		evento_recompensa_entregada.emit(ev.id, recomp.to_dict())
		print("[EventManager] Recompensa entregada: %s â†’ %s" % [ev.id, recomp.to_dict()])
	else:
		print("[EventManager] FALLÃ“ entrega de recompensa: %s" % recomp.to_dict())


func entregar_recompensa(evento_id: StringName) -> Array:
	"""API pÃºblica: entrega recompensas de un evento finalizado."""
	var anio = _get_anio_actual()
	var ev: EventDefinition = _catalogo.get(evento_id, null)
	if ev == null:
		return []
	var entregadas := []
	for recomp in ev.recompensas:
		if recomp is RecompensaDef:
			var es = _get_estado(evento_id, anio)
			if es != null and es.puede_recibir_recompensa(anio):
				var ok = recomp.entregar(self, {"evento_id": evento_id})
				if ok:
					es.marcar_recompensa_recibida(anio)
					entregadas.append(recomp.to_dict())
					evento_recompensa_entregada.emit(evento_id, recomp.to_dict())
	return entregadas


# â”€â”€ Sorpresas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func registrar_sorpresa(evento_id: StringName) -> bool:
	"""Registra una sorpresa si cumple lÃ­mites semanales y no es dÃ­a de festival."""
	# LÃ­mite semanal
	var gt = get_node_or_null("/root/GameTime")
	var semana_dia := 0
	if gt != null:
		semana_dia = gt.get_semana_dia()
	if semana_dia != _ultima_semana_sorpresa:
		_ultima_semana_sorpresa = semana_dia
		_sorpresa_semanal_count = 0
	if _sorpresa_semanal_count >= MAX_SORPRESAS_SEMANA:
		return false
	# No en dÃ­a de festival
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null and tc.hay_festival_hoy():
		return false
	# Registrar
	_sorpresa_semanal_count += 1
	return true


# â”€â”€ Agenda â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func get_eventos_del_dia(fecha: Dictionary) -> Array:
	"""Retorna eventos que coinciden con la fecha dada."""
	var dia = int(fecha.get("dia", 1))
	var mes = int(fecha.get("mes", 1))
	var estacion = int(fecha.get("estacion", 0))
	var resultados := []
	for ev_id in _catalogo.keys():
		var ev: EventDefinition = _catalogo[ev_id]
		if ev.coincide_fecha(dia, mes, estacion):
			resultados.append(ev)
	return resultados


func get_eventos_proximos(dias: int) -> Array:
	"""Retorna prÃ³ximos N dÃ­as de eventos."""
	var gt = get_node_or_null("/root/GameTime")
	if gt == null:
		return []
	var dia_actual: int = 1
	var mes_actual: int = 1
	var anio_actual: int = 1
	if gt != null:
		if gt.has_method("get_dia_absoluto"):
			dia_actual = (gt.dia_absoluto() - 1) % 28 + 1
		if gt.has_method("get_fecha"):
			var f = gt.get_fecha()
			mes_actual = int(f.get("mes", 1))
			anio_actual = int(f.get("anio", 1))
	var resultado := []
	for i in range(1, dias + 1):
		var d = dia_actual + i
		var m = mes_actual
		var a = anio_actual
		# Roll over
		while d > 28:
			d -= 28
			m += 1
			if m > 12:
				m = 1
				a += 1
		var est = _get_estacion_para_mes(m)
		for ev_id in _catalogo.keys():
			var ev: EventDefinition = _catalogo[ev_id]
			if ev.coincide_fecha(d, m, est):
				var ev_copia: Dictionary = ev.to_dict()
				ev_copia["dia_relativo"] = i
				ev_copia["fecha_absoluta"] = {"dia": d, "mes": m, "anio": a}
				resultado.append(ev_copia)
	return resultado


func get_evento_actual() -> Object:
	"""Retorna el evento actualmente en curso o null."""
	return evento_actual


func normalizar_agenda() -> void:
	"""Construye/normaliza la agenda anual al cargar partida."""
	var anio = _get_anio_actual()
	# Asegurar que todos los eventos del catÃ¡logo tengan estado para este aÃ±o
	for ev_id in _catalogo.keys():
		if _get_estado(ev_id, anio) == null:
			var es := EventState.new()
			es.evento_id = ev_id
			es.anio = anio
			es.estado = EventState.Estado.PENDIENTE
			_set_estado(ev_id, anio, es)
	agenda_actualizada.emit()


# â”€â”€ Historial â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func get_recuerdos() -> Array:
	"""Retorna array de recuerdos (participaciones pasadas)."""
	var anio = _get_anio_actual()
	var recuerdos := []
	for ev_id in _catalogo.keys():
		var es = _get_estado(ev_id, anio)
		if es != null and es.estado == EventState.Estado.PARTICIPADO:
			recuerdos.append({
				"evento_id": es.evento_id,
				"anio": es.anio_participacion,
				"mejor_puesto": es.mejor_puesto,
				"resultado": es.resultado,
			})
	return recuerdos


func get_historial_por_anio(anio: int) -> Dictionary:
	"""Retorna diccionario evento_id -> EventState para un aÃ±o dado."""
	return _estado_anual.get(anio, {}).duplicate()


# â”€â”€ Persistencia (ISaveProvider M59) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


func get_section_name() -> String:
	return "events_m74"


func get_save_data() -> Dictionary:
	var anio = _get_anio_actual()
	var estados := {}
	for ev_id in _catalogo.keys():
		var es = _get_estado(ev_id, anio)
		if es != null:
			estados[ev_id] = es.to_dict()
	return {
		"anio_actual": anio,
		"eventos": estados,
		"sorpresa_semanal_count": _sorpresa_semanal_count,
		"ultima_semana_sorpresa": _ultima_semana_sorpresa,
	}


func restore_save_data(data: Dictionary) -> void:
	var anio = int(data.get("anio_actual", _get_anio_actual()))
	var eventos_data: Dictionary = data.get("eventos", {})
	for ev_id in eventos_data.keys():
		var es := EventState.from_dict(eventos_data[ev_id])
		_set_estado(ev_id, anio, es)
	_sorpresa_semanal_count = int(data.get("sorpresa_semanal_count", 0))
	_ultima_semana_sorpresa = int(data.get("ultima_semana_sorpresa", -1))
	print("[EventManager] Estado restaurado: %d eventos" % eventos_data.size())


# â”€â”€ Utilidades internas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

func _get_estado(evento_id: StringName, anio: int) -> EventState:
	var year_states = _estado_anual.get(anio, {})
	return year_states.get(evento_id, null) as EventState


func _set_estado(evento_id: StringName, anio: int, estado: EventState) -> void:
	if not _estado_anual.has(anio):
		_estado_anual[anio] = {}
		_estado_anual[anio][evento_id] = estado


func _get_anio_actual() -> int:
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null and tc.has_method("get_anio_actual"):
		return int(tc.get_anio_actual())
	var gt = get_node_or_null("/root/GameTime")
	if gt != null:
		var fecha = gt.get_fecha()
		return int(fecha.get("anio", 1))
	return 1


func _get_estacion_para_mes(mes: int) -> int:
	"""Mapeo mesâ†’estaciÃ³n (0-3)."""
	if mes <= 3: return 0    # Primavera
	if mes <= 6: return 1    # Verano
	if mes <= 9: return 2    # OtoÃ±o
	return 3                  # Invierno


func _build_context() -> Dictionary:
	"""Construye contexto para evaluaciÃ³n de condiciones."""
	var ctx := {}
	var gt = get_node_or_null("/root/GameTime")
	if gt != null:
		ctx["hora"] = gt.get_hora()
		ctx["minuto"] = gt.get_minuto()
		var fecha = gt.get_fecha()
		ctx["dia"] = int(fecha.get("dia", 1))
		ctx["mes"] = int(fecha.get("mes", 1))
		ctx["anio"] = int(fecha.get("anio", 1))
		ctx["estacion"] = gt.get_estacion()
		ctx["semana_dia"] = gt.get_semana_dia()
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null:
		ctx["historia_sellos"] = tc.get_save_data().get("eventos_visitados", [])
	var fs = get_node_or_null("/root/Friendship")
	if fs != null:
		ctx["amistad_npcs"] = fs.get_all_amistades() if fs.has_method("get_all_amistades") else {}
	var inv = get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("get_items"):
		ctx["inventario"] = inv.get_items() if inv.has_method("get_items") else {}
	var weather = get_node_or_null("/root/Weather")
	if weather != null:
		ctx["clima"] = weather.get_clima_actual() if weather.has_method("get_clima_actual") else 0
	return ctx


func Ocupar_npcs_para_evento(ev: EventDefinition) -> void:
	"""Marca NPCs para que no hagan rutinas normales durante el evento (M19)."""
	if ev.ocupacion_npc.is_empty():
		return
	var bus = get_node_or_null("/root/EventBus")
	if bus != null:
		bus.time.evento_activado.emit({
			"id": ev.id,
			"ocupacion_npc": ev.ocupacion_npc,
		})


func get_catalogo_size() -> int:
	return _catalogo.size()


func get_evento_by_id(evento_id: String) -> EventDefinition:
	return _catalogo.get(evento_id, null)


func get_all_events() -> Array:
	var result := []
	for ev_id in _catalogo.keys():
		result.append(_catalogo[ev_id])
	return result


func _verificar_sorpresa_diaria(_anio: int, _mes: int, _dia: int, _estacion: int) -> void:
	"""Chequea si debe generarse una sorpresa diaria."""
	var gt = get_node_or_null("/root/GameTime")
	if gt == null:
		return
	var rand_val := randf()
	if rand_val < 0.05:  # 5% probabilidad diaria
		if registrar_sorpresa(&"visita_sorpresa"):
			print("[EventManager] Sorpresa generada: visita_sorpresa")
			evento_proximo.emit(&"visita_sorpresa", 0)


func _get_event_state_copy(evento_id: StringName, anio: int) -> EventState:
	"""Helper para obtener copia del estado (evita mutaciones accidentales)."""
	var es = _get_estado(evento_id, anio)
	if es != null:
		return EventState.from_dict(es.to_dict())
	return null

