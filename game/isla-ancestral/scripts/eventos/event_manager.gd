# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M74: Eventos — EventManager (autoload "eventos")
#
# Orquestador central de eventos: catálogo, agenda anual, disparo con aviso previo,
# participación con condiciones, recompensas seguras con token anti-duplicado,
# anti-FOMO (todo repetible anual), persistencia versionada M59.
#
# Reglas de oro:
# 1. Nunca leer reloj del SO; usar GameClock (M30).
# 2. Nada se pierde para siempre: evento anual se repite.
# 3. Token anti-duplicado por año natural, no permanente.
# 4. Cero polling por frame: checks en dia_cambio / anio_cambio / clima_cambio.
# 5. UI separada por señales (M09).
# 6. Fallback: si escena falla, evento_cancelado + compensación, jamás crash.

extends Node

## ── Señales públicas ─────────────────────────────────────
signal evento_proximo(evento_id: StringName, dias_restantes: int)
signal evento_iniciado(evento_id: StringName)
signal evento_terminado(evento_id: StringName)
signal evento_cancelado(evento_id: StringName, razon: StringName)
signal evento_recompensa_entregada(evento_id: StringName, recompensa: Dictionary)
signal agenda_actualizada()
## J8: un evento perdió un solape y fue corrido de día {evento_id, nueva_fecha}.
signal evento_reprogramado(evento_id: StringName, nueva_fecha: Dictionary)
## J7: dos o más eventos del mismo día; se resolvió por prioridad.
signal solape_resuelto(evento_id_ganador: StringName, perdedores: Array)

## ── Solapes (J7/J8) ──────────────────────────────────────────────────────
## evento_id -> {dia, mes, anio} efectivo cuando el evento fue corrido por
## perder un solape (J8). Persiste en el save.
var _reprogramados: Dictionary = {}

## ── Catálogo y estado ────────────────────────────────────
var _catalogo: Dictionary = {}          # id -> EventDefinition
var _estado_anual: Dictionary = {}      # anio -> {evento_id -> EventState}
var _sorpresa_semanal_count: int = 0
var _ultima_semana_sorpresa: int = -1
var _eventos_del_dia_cache: Array = []  # Cache para el día actual
var _aviso_emitido_hoy: PackedStringArray = []  # Para evitar doble aviso
## RF6.9/6.10: entregas que no entraron en el inventario (M14 lleno).
var _buzon: BuzonEntregas = BuzonEntregas.new()
const MAX_SORPRESAS_SEMANA: int = 3
const DIAS_PARA_AVISO_DEFAULT: int = 3
const LOG_HOT_PATH: bool = false  # logs del chequeo diario (hot path); true solo para debug

## ── Evento actual ────────────────────────────────────────
var evento_actual: Object = null
var evento_actual_id: StringName = &""
## RF4.11 / J1-J3: última fecha procesada por dia_cambio (idempotencia).
var _ultima_fecha_procesada: String = ""
## RF2.4 / RF7.1: último año procesado; al cambiar, la agenda se regenera.
var _ultimo_anio_procesado: int = -1


func _ready() -> void:
	print("[EventManager] Inicializando M74...")
	_cargar_catalogo()
	_conectar_eventbus()
	normalizar_agenda()
	_registrar_proveedor_guardado()
	print("[EventManager] Catálogo cargado: %d eventos" % _catalogo.size())


func _cargar_catalogo() -> void:
	"""Cargar todos los EventDefinition desde data/eventos/."""
	var base_dir: String = "res://scripts/eventos/data/"
	var tipos: Array[String] = ["festivales", "ferias", "competencias", "rituales", "climaticos", "sorpresas", "capitulos"]
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
	"""Suscribirse a señales de M29/M30/M32."""
	var gt = get_node_or_null("/root/GameTime")
	if gt != null:
		gt.dia_cambio.connect(_on_dia_cambio)
		if gt.has_signal("estacion_cambio"):
			gt.estacion_cambio.connect(_on_estacion_cambio)
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

	# RF4.11 / J1-J3 (idempotencia): si dia_cambio se dispara varias veces
	# para la misma fecha (p. ej. una transicion de ano que emite varios
	# dia_cambio), la segunda llamada se descarta. Sin esto los avisos se
	# duplicarian y un evento ya en curso se re-iniciaria.
	var clave_fecha := "%d_%d_%d" % [int(anio), int(mes), int(dia)]
	if clave_fecha == _ultima_fecha_procesada:
		if LOG_HOT_PATH:
			print("[EventManager] dia_cambio duplicado para %s: ignorado" % clave_fecha)
		return
	_ultima_fecha_procesada = clave_fecha

	# RF2.4 / RF7.1 (ano nuevo): al cambiar de ano la agenda se regenera para
	# el ano nuevo; todos los eventos vuelven a PENDIENTE (anti-FOMO, M94) y
	# el historial del ano anterior se conserva. M29 no expone una senal
	# `año_cambio` (verificado en game_clock.gd / time_calendar.gd), asi que
	# el ano se lee del `info` de dia_cambio.
	var anio_int := int(anio)
	if _ultimo_anio_procesado != -1 and anio_int != _ultimo_anio_procesado:
		_normalizar_agenda(anio_int)
		print("[EventManager] Año nuevo (%d): agenda regenerada, eventos reprogramados" % anio_int)
	_ultimo_anio_procesado = anio_int

	# I4: hora/minuto desde M30 (GameClock), nunca del reloj del SO.
	var mins := _get_minutos_dia()
	var hora_val := mins / 60
	var minuto_val := mins % 60

	# 0. Resolver solapes del día (J7/J8): corre los perdedores al día siguiente.
	resolver_solapes({"dia": dia, "mes": mes, "estacion": estacion, "anio": anio})

	# 1. Chequear aviso previo para eventos próximos
	_verificar_aviso_previo(anio, mes, dia, estacion, hora_val, minuto_val)

	# 2. Chequear inicio de eventos (franja horaria)
	_verificar_inicio_evento(anio, mes, dia, estacion, hora_val, minuto_val)

	# 3. Chequear fin de eventos
	_verificar_fin_evento(anio, mes, dia, estacion, hora_val, minuto_val)

	# 4. Resetear contador de sorpresas semanal
	_verificar_sorpresa_diaria(anio, mes, dia, estacion)

	# 5. Limpiar cache de avisos emitidos hoy
	_aviso_emitido_hoy.clear()

	# 6. Buzón (RF6.10): purgar entregas vencidas. Ninguna se pierde antes de
	#    RETENCION_DIAS (30).
	var gt_buzon = get_node_or_null("/root/GameTime")
	var dia_abs: int = 0
	if gt_buzon != null and gt_buzon.has_method("dia_absoluto"):
		dia_abs = int(gt_buzon.dia_absoluto())
	var vencidas: int = _buzon.purgar(dia_abs)
	if vencidas > 0:
		print("[EventManager] Buzón: %d entregas purgadas por retención cumplida" % vencidas)

	# 7. Emitir señal de agenda actualizada
	agenda_actualizada.emit()


func _on_clima_cambio(clima: int) -> void:
	"""Manejar variante cubierta ante clima severo."""
	if clima == 3:  # Tormenta
		# Si hay un evento al aire libre en curso, verificar variante
		if evento_actual != null and evento_actual.variante_cubierta != null:
			if evento_actual.variante_cubierta != null:
				print("[EventManager] Tormenta detectada, variante cubierta para %s" % evento_actual_id)
				# La UI consumiría esta señal para cambiar de escena
				pass


## I3: al cambiar la estación se refresca la agenda (los eventos estacionales
## dependen de ella) y se avisa a la UI.
func _on_estacion_cambio(_estacion: int) -> void:
	agenda_actualizada.emit()
	if LOG_HOT_PATH:
		print("[EventManager] Cambio de estación: agenda_actualizada emitida")


## I4: minutos desde las 00:00 según M30 (GameClock). Regla de oro 1: nunca se
## lee el reloj del sistema operativo.
func _get_minutos_dia() -> int:
	var gt = get_node_or_null("/root/GameTime")
	if gt == null:
		return 0
	return int(gt.get_hora()) * 60 + int(gt.get_minuto())


func _verificar_aviso_previo(anio: int, mes: int, dia: int, estacion: int, hora: int, minuto: int) -> void:
	"""Emitir evento_proximo cuando falta dias_aviso para un evento."""
	for ev_id in _catalogo.keys():
		var ev: EventDefinition = _catalogo[ev_id]
		if not ev.coincide_fecha(dia, mes, estacion):
			# Verificar si es próximo (dentro de dias_aviso).
			# OJO: `mins_hasta / 1440` con ints hacia division ENTERA y daba 0
			# para cualquier evento a menos de un dia -> el aviso del ultimo dia
			# NUNCA se emitia. Se fuerza float (M74, RF3.2).
			var mins_hasta: int = ev.minutos_hasta_inicio(hora, minuto)
			var dias_hasta: float = float(mins_hasta) / 1440.0
			if dias_hasta > 0.0 and dias_hasta <= float(ev.dias_aviso):
				# Solo emitir si no se avisó antes
				var key := "%s_%d" % [ev_id, anio]
				if key not in _aviso_emitido_hoy:
					_aviso_emitido_hoy.append(key)
					evento_proximo.emit(ev_id, dias_hasta)
				if LOG_HOT_PATH:
					print("[EventManager] Aviso previo: %s en %.2f dias" % [ev_id, dias_hasta])


func _verificar_inicio_evento(anio: int, mes: int, dia: int, estacion: int, hora: int, minuto: int) -> void:
	"""Iniciar evento cuando entramos en la franja horaria."""
	for ev_id in _catalogo.keys():
		var ev: EventDefinition = _catalogo[ev_id]
		if not ev.coincide_fecha(dia, mes, estacion):
			continue
		if not ev.esta_en_franja(hora, minuto):
			continue
		# Verificar si ya está en curso
		var es = _get_estado(ev_id, anio)
		if es == null or es.estado == EventState.Estado.PENDIENTE:
			# Iniciar evento
			_iniciar_evento(ev, anio)
			Ocupar_npcs_para_evento(ev)
			evento_iniciado.emit(ev_id)
			if LOG_HOT_PATH:
				print("[EventManager] Evento iniciado: %s" % ev_id)
			return
		# Verificar ocupación de NPCs (M19)


func _verificar_fin_evento(anio: int, mes: int, dia: int, estacion: int, hora: int, minuto: int) -> void:
	"""Terminar evento cuando salimos de la franja horaria."""
	if evento_actual == null:
		return
	var ev_id = evento_actual_id
	var ev: EventDefinition = _catalogo.get(ev_id, null)
	if ev == null:
		return
	if not ev.esta_en_franja(hora, minuto):
		# Franco terminó
		_finalizar_evento(ev_id, anio, false)
		evento_terminado.emit(ev_id)
		if LOG_HOT_PATH:
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
		# Si el jugador no participó, marcar NO_PARTICIPADO
		if es.estado != EventState.Estado.PARTICIPADO:
			es.estado = EventState.Estado.NO_PARTICIPADO
	evento_actual = null
	evento_actual_id = &""


func _on_festival_data_event(ev: Dictionary) -> void:
	"""Callback desde FestivalData de M29 para eventos ya definidos."""
	# Este callback permite que los eventos de festivals.tres
	# se sincronicen con el nuevo sistema M74
	pass


# ── Participación ──────────────────────────────────────────

func puede_participar(evento_id: StringName) -> Dictionary:
	"""Evalúa si el jugador puede participar. Retorna {ok: bool, razon: StringName}."""
	var ev: EventDefinition = _catalogo.get(evento_id, null)
	if ev == null:
		return {"ok": false, "razon": &"evento_no_existe"}
	# Chequear si ya participó este año
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
	"""Finaliza participación y entrega recompensas."""
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
	"""Entrega todas las recompensas del evento con verificación doble."""
	# J23: un evento sin recompensas definidas no es un error: se avisa y se
	# sigue (el evento ya quedó PARTICIPADO).
	if ev.recompensas.is_empty():
		push_warning("[EventManager] El evento %s no define recompensas" % ev.id)
		return
	for recomp in ev.recompensas:
		if recomp is RecompensaDef:
			_entregar_una_recompensa(recomp, ev, anio)


func _entregar_una_recompensa(recomp: RecompensaDef, ev: EventDefinition, anio: int) -> void:
	"""Entrega una recompensa individual con validación de token anti-duplicado."""
	var es = _get_estado(ev.id, anio)
	if es == null or not es.puede_recibir_recompensa(anio):
		print("[EventManager] Recompensa %s ya entregada este año o estado inválido" % ev.id)
		return
	# Entregar
	var ok = recomp.entregar(self, {"evento_id": ev.id})
	if ok:
		# Si el evento estaba CANCELADO se trata de compensatoria: consume el
		# token del anio pero CONSERVA CANCELADO (recibir el consuelo no es
		# participar). Antes siempre marcaba PARTICIPADO.
		if es.estado == EventState.Estado.CANCELADO:
			es.marcar_recompensa_compensatoria(anio)
		else:
			es.marcar_recompensa_recibida(anio)
		evento_recompensa_entregada.emit(ev.id, recomp.to_dict())
		print("[EventManager] Recompensa entregada: %s -> %s" % [ev.id, recomp.to_dict()])
	else:
		print("[EventManager] FALLO entrega de recompensa: %s" % recomp.to_dict())


func entregar_recompensa(evento_id: StringName) -> Array:
	"""API pública: entrega recompensas de un evento finalizado."""
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


# ── Sorpresas ─────────────────────────────────────────────

func registrar_sorpresa(evento_id: StringName) -> bool:
	"""Registra una sorpresa si cumple límites semanales y no es día de festival."""
	# Límite semanal
	var gt = get_node_or_null("/root/GameTime")
	var semana_dia := 0
	if gt != null:
		semana_dia = gt.get_semana_dia()
	if semana_dia != _ultima_semana_sorpresa:
		_ultima_semana_sorpresa = semana_dia
		_sorpresa_semanal_count = 0
	if _sorpresa_semanal_count >= MAX_SORPRESAS_SEMANA:
		return false
	# No en día de festival
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null and tc.hay_festival_hoy():
		return false
	# Registrar
	_sorpresa_semanal_count += 1
	return true


# ── Agenda ────────────────────────────────────────────────

func get_eventos_del_dia(fecha: Dictionary) -> Array:
	"""Retorna eventos que coinciden con la fecha dada (usando la fecha
	EFECTIVA: un evento reprogramado por solape aparece en su nuevo día)."""
	var dia = int(fecha.get("dia", 1))
	var mes = int(fecha.get("mes", 1))
	var estacion = int(fecha.get("estacion", 0))
	var resultados := []
	for ev_id in _catalogo.keys():
		var ev: EventDefinition = _catalogo[ev_id]
		if _coincide_efectiva(ev, dia, mes, estacion):
			resultados.append(ev)
	return resultados


## ¿Coincide `ev` con (dia, mes, estacion) considerando la reprogramación?
## Un evento reprogramado usa su fecha efectiva; los comodines del calendario
## (dia == 0, mes == -1, estacion == -1) siguen valiendo.
func _coincide_efectiva(ev: EventDefinition, dia: int, mes: int, estacion: int) -> bool:
	# Evento relativo SIN reprogramar: la regla manda (coincide_fecha la resuelve).
	if ev.es_relativa() and not _reprogramados.has(String(ev.id)):
		return ev.coincide_fecha(dia, mes, estacion)
	var f: Dictionary = fecha_efectiva(String(ev.id))
	if f.is_empty():
		return ev.coincide_fecha(dia, mes, estacion)
	var d_usar: int = int(f.get("dia", ev.dia))
	var m_usar: int = int(f.get("mes", ev.mes))
	if m_usar != -1 and m_usar != mes:
		return false
	if d_usar != 0 and d_usar != dia:
		return false
	if ev.estacion != -1 and ev.estacion != estacion:
		return false
	return true


## ── Solapes por prioridad (J7/J8) ────────────────────────────────────────

## Orden determinista: mayor `prioridad` gana; a igualdad, id alfabético (para
## que el resultado no dependa del orden del diccionario).
static func ordenar_por_prioridad(eventos: Array) -> Array:
	var copia: Array = eventos.duplicate()
	copia.sort_custom(func(a, b):
		var pa: int = int((a as EventDefinition).prioridad)
		var pb: int = int((b as EventDefinition).prioridad)
		if pa != pb:
			return pa > pb
		return String((a as EventDefinition).id) < String((b as EventDefinition).id))
	return copia

## Fecha efectiva de un evento: la reprogramada si perdió un solape (J8), o la
## que declara su definición.
func fecha_efectiva(evento_id: String) -> Dictionary:
	if _reprogramados.has(evento_id):
		return (_reprogramados[evento_id] as Dictionary).duplicate()
	var ev: EventDefinition = _catalogo.get(evento_id, null)
	if ev == null:
		return {}
	return {"dia": int(ev.dia), "mes": int(ev.mes)}

## Resuelve los solapes del día: gana el de mayor prioridad y los perdedores se
## corren al día siguiente (J8) con aviso. Devuelve {ganador, perdedores[], corridos[]}.
func resolver_solapes(fecha: Dictionary) -> Dictionary:
	var dia: int = int(fecha.get("dia", 1))
	var mes: int = int(fecha.get("mes", 1))
	var estacion: int = int(fecha.get("estacion", 0))
	var anio: int = int(fecha.get("anio", _get_anio_actual()))
	var del_dia: Array = get_eventos_del_dia({"dia": dia, "mes": mes, "estacion": estacion})
	if del_dia.is_empty():
		return {"ganador": null, "perdedores": [], "corridos": []}
	if del_dia.size() == 1:
		# Día con un solo evento: ES el ganador, no hay nada que correr.
		return {"ganador": del_dia[0], "perdedores": [], "corridos": []}
	var orden: Array = ordenar_por_prioridad(del_dia)
	var ganador = orden[0]
	var perdedores: Array = []
	var corridos: Array = []
	for i in range(1, orden.size()):
		var ev: EventDefinition = orden[i]
		perdedores.append(ev.id)
		var nueva: Dictionary = _siguiente_dia(dia, mes, anio)
		_reprogramados[String(ev.id)] = nueva.duplicate()
		corridos.append([String(ev.id), nueva.duplicate()])
		evento_reprogramado.emit(ev.id, nueva.duplicate())
	solape_resuelto.emit(ganador.id, perdedores.duplicate())
	return {"ganador": ganador, "perdedores": perdedores.duplicate(), "corridos": corridos}


## Día siguiente dentro del calendario Aurora (28 días por mes, 12 meses).
## Devuelve {dia, mes, anio}.
func _siguiente_dia(dia: int, mes: int, anio: int) -> Dictionary:
	var d: int = dia + 1
	var m: int = mes
	var a: int = anio
	if d > 28:
		d = 1
		m += 1
		if m > 12:
			m = 1
			a += 1
	return {"dia": d, "mes": m, "anio": a}

## Eventos actualmente reprogramados (para UI, QA y save).
func reprogramados() -> Dictionary:
	return _reprogramados.duplicate(true)

func limpiar_reprogramados() -> void:
	_reprogramados.clear()


func get_eventos_proximos(dias: int) -> Array:
	"""Retorna próximos N días de eventos."""
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
	_normalizar_agenda(_get_anio_actual())
	agenda_actualizada.emit()


## Versión parametrizable por año (usada por el cambio de año y por tests):
## asegura que todos los eventos del catálogo tengan estado PENDIENTE en ese
## año. RF7.1: la agenda se regenera cada año sin perder el historial.
func _normalizar_agenda(anio: int) -> void:
	for ev_id in _catalogo.keys():
		if _get_estado(ev_id, anio) == null:
			var es := EventState.new()
			es.evento_id = ev_id
			es.anio = anio
			es.estado = EventState.Estado.PENDIENTE
			_set_estado(ev_id, anio, es)


# ── Historial ─────────────────────────────────────────────

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
	"""Retorna diccionario evento_id -> EventState para un año dado."""
	return _estado_anual.get(anio, {}).duplicate()


## RF7.4: años en los que el jugador ganó este evento (mejor_puesto == 1).
## Base de los títulos de bicampeón (anillo dorado con los años ganados).
func get_anios_ganados(evento_id: String) -> Array:
	var out: Array[int] = []
	for anio in _estado_anual.keys():
		var es = _get_estado(StringName(evento_id), int(anio))
		if es != null and es.mejor_puesto == 1:
			out.append(int(anio))
	out.sort()
	return out


# ── Buzón de entregas (RF6.9 / RF6.10) ─────────────────────────────────

## El buzón de entregas pendientes (M14 lleno). Expuesto para la UI y para QA.
## Version del esquema de guardado de M74 (RN5). Se sube cuando cambia la
## forma de get_save_data()/restore_save_data().
const VERSION_SAVE: int = 1

func buzon() -> BuzonEntregas:
	return _buzon

## Reclama una entrega del buzón: reintenta el inventario y, si ahora entra,
## la quita del buzón. Devuelve {ok, motivo, recompensa}.
## Si el inventario sigue lleno, el pendiente NO se pierde.
func reclamar_buzon(entry_id: int) -> Dictionary:
	var entrada: Dictionary = _buzon.ver(entry_id)
	if entrada.is_empty():
		return {"ok": false, "motivo": &"no_existe", "recompensa": {}}
	var recomp: Dictionary = entrada.get("recompensa", {})
	var r := RecompensaDef.from_dict(recomp)
	var ctx: Dictionary = {"evento_id": entrada.get("evento_id", ""), "dia_absoluto": entrada.get("dia_absoluto", 0)}
	if r != null and r.entregar(self, ctx):
		_buzon.reclamar(entry_id)
		return {"ok": true, "motivo": &"entregada", "recompensa": recomp}
	return {"ok": false, "motivo": &"inventario_lleno", "recompensa": recomp}

## ── RF4.12: re-validar eventos al cargar ─────────────────────────────────

## Fecha/hora actuales según M30 (GameTime). Devuelve un Dictionary con
## {dia, mes, anio, estacion, hora, minuto, dia_absoluto}; si no hay GameTime,
## valores neutros (día 1, mes 1, 08:00).
func _fecha_actual() -> Dictionary:
	var gt = get_node_or_null("/root/GameTime")
	var f: Dictionary = {"dia": 1, "mes": 1, "anio": _get_anio_actual(),
		"estacion": 0, "hora": 8, "minuto": 0, "dia_absoluto": 0}
	if gt != null:
		if gt.has_method("get_fecha"):
			var gf: Dictionary = gt.get_fecha()
			f["dia"] = int(gf.get("dia", 1))
			f["mes"] = int(gf.get("mes", 1))
			f["anio"] = int(gf.get("anio", f["anio"]))
		if gt.has_method("get_estacion"):
			f["estacion"] = int(gt.get_estacion())
		if gt.has_method("get_hora"):
			f["hora"] = int(gt.get_hora())
		if gt.has_method("get_minuto"):
			f["minuto"] = int(gt.get_minuto())
		if gt.has_method("dia_absoluto"):
			f["dia_absoluto"] = int(gt.dia_absoluto())
	return f

## Al cargar la partida, un evento que quedó EN_CURSO se re-valida contra la
## fecha y la franja horaria ACTUALES.
##   * franja abierta  -> se reabre (evento_actual apunta a él).
##   * franja cerrada  -> se finaliza como NO_PARTICIPADO (terminó mientras el
##     juego estaba cerrado) y se emite evento_terminado. No se pierde el
##     histórico ni se duplica la recompensa.
## Devuelve {anio, reabiertos, cerrados}.
func revalidar_al_cargar() -> Dictionary:
	var anio: int = _get_anio_actual()
	var f: Dictionary = _fecha_actual()
	var reabiertos: int = 0
	var cerrados: int = 0
	var anio_estados: Dictionary = _estado_anual.get(anio, {})
	for ev_id in anio_estados.keys():
		var es = anio_estados[ev_id]
		if es == null or (es as EventState).estado != EventState.Estado.EN_CURSO:
			continue
		var ev: EventDefinition = _catalogo.get(ev_id, null)
		if ev == null:
			continue
		var abierta: bool = ev.coincide_fecha(int(f["dia"]), int(f["mes"]), int(f["estacion"])) \
			and ev.esta_en_franja(int(f["hora"]), int(f["minuto"]))
		if abierta:
			evento_actual = ev
			evento_actual_id = StringName(String(ev_id))
			reabiertos += 1
		else:
			_finalizar_evento(StringName(String(ev_id)), anio, false)
			evento_terminado.emit(StringName(String(ev_id)))
			cerrados += 1
	return {"anio": anio, "reabiertos": reabiertos, "cerrados": cerrados}

## Limpia el buzón (usado por tests y por "nueva partida").
func limpiar_buzon() -> void:
	_buzon.vaciar()


# ── Persistencia (ISaveProvider M59) ─────────────────────

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
		"version": VERSION_SAVE,
		"anio_actual": anio,
		"eventos": estados,
		"sorpresa_semanal_count": _sorpresa_semanal_count,
		"ultima_semana_sorpresa": _ultima_semana_sorpresa,
		# RF6.9/6.10: el buzón viaja en el save (si no, las recompensas
		# pendientes se perderían al guardar/cargar).
		"buzon": _buzon.to_dict(),
		"reprogramados": _reprogramados.duplicate(true),
	}


func restore_save_data(data: Dictionary) -> void:
	var anio = int(data.get("anio_actual", _get_anio_actual()))
	# RN6: un save corrupto (eventos que no es diccionario, estado con tipos
	# invalidos) NO puede tumbar la partida. Se descarta lo ilegible y se sigue.
	var eventos_data: Variant = data.get("eventos", {})
	if not (eventos_data is Dictionary):
		push_warning("[EventManager] save corrupto: 'eventos' no es diccionario, se descarta")
		return
	for ev_id in (eventos_data as Dictionary).keys():
		var crudo: Variant = (eventos_data as Dictionary)[ev_id]
		if not (crudo is Dictionary):
			push_warning("[EventManager] save corrupto: estado de %s no es diccionario" % ev_id)
			continue
		var es := EventState.from_dict(crudo as Dictionary)
		if es == null:
			continue
		_set_estado(StringName(String(ev_id)), anio, es)
	_sorpresa_semanal_count = int(data.get("sorpresa_semanal_count", 0))
	_ultima_semana_sorpresa = int(data.get("ultima_semana_sorpresa", -1))
	# RF6.9/6.10: restaurar el buzón (tolerante a schema corrupto).
	var repro_data: Variant = data.get("reprogramados", {})
	if repro_data is Dictionary:
		_reprogramados = (repro_data as Dictionary).duplicate(true)
	var buzon_data: Variant = data.get("buzon", {})
	if buzon_data is Dictionary:
		_buzon.from_dict(buzon_data as Dictionary)
	print("[EventManager] Estado restaurado: %d eventos, %d en buzón" % [
		(eventos_data as Dictionary).size(), _buzon.cantidad()])
	# RF4.12: re-validar los eventos que quedaron EN_CURSO al cerrar el juego.
	# Un save con la franja ya cerrada no debe revivir un evento terminado.
	revalidar_al_cargar()


# ── Utilidades internas ───────────────────────────────────

func _get_estado(evento_id: StringName, anio: int) -> EventState:
	var year_states = _estado_anual.get(anio, {})
	return year_states.get(evento_id, null) as EventState


func _set_estado(evento_id: StringName, anio: int, estado: EventState) -> void:
	if estado == null:
		return
	if not _estado_anual.has(anio):
		_estado_anual[anio] = {}
	# Antes solo escribia cuando el anio era NUEVO: un segundo _set_estado en el
	# mismo año (marcar recompensa, NO_PARTICIPADO, cancelacion) se perdía en
	# silencio. El fix: el diccionario del año se crea si falta y SIEMPRE se
	# escribe (M74, edge case de persistencia).
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
	"""Mapeo mes→estación (0-3)."""
	if mes <= 3: return 0    # Primavera
	if mes <= 6: return 1    # Verano
	if mes <= 9: return 2    # Otoño
	return 3                  # Invierno


func _build_context() -> Dictionary:
	"""Construye contexto para evaluación de condiciones."""
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

