extends Node

## Módulo 29: Tiempo y Calendario — Servicio principal (autoload "TimeCalendar")
##
## Fachada unificada que expone la API pública (sección G del checklist)
## Carga time_config.tres y festivals.tres, provee señales y consultas
## Consumidores: GameClock (M30), VillagerManager (M19), UI (M30/M55), Shops (M74), Crops (M33), Fauna (M36)

signal dia_cambio(info: Dictionary)
signal hora_cambio(hora: int)
signal minuto_cambio(minuto: int)
signal estacion_cambio(estacion: int)
signal evento_activado(evento: Dictionary)
signal evento_proximo(evento: Dictionary, horas_restantes: int)

var _config
var _festivales
var _game_clock: Node = null  # Referencia a GameClock (M30) para tick real

## Estado cacheado para consultas rápidas
var _hora_actual: int = 8
var _minuto_actual: int = 0
var _dia_actual: int = 1
var _mes_actual: int = 1
var _anio_actual: int = 1
var _estacion_actual: int = 0
var _semana_dia_actual: int = 0
var _dia_absoluto_actual: int = 1
var _eventos_visitados: Array[String] = []

func _ready() -> void:
	_cargar_configuracion()
	_conectar_gameclock()
	_registrar_proveedor_guardado()

func _cargar_configuracion() -> void:
	_config = load("res://data/time/time_config.tres")
	_festivales = load("res://data/time/festivals.tres")

	if _config == null:
		push_error("[TimeCalendar] No se pudo cargar time_config.tres")
		_config = Resource.new()

	if _festivales == null:
		push_error("[TimeCalendar] No se pudo cargar festivals.tres")
		_festivales = Resource.new()

	# Inicializar estado desde config
	_estacion_actual = _config.estacion_inicial
	_anio_actual = _config.anio_fundacion
	print("[TimeCalendar] Configuración cargada: día %d min, año %d días, 4 estaciones" % [_config.min_por_dia, _config.get_dias_por_anio()])

func _conectar_gameclock() -> void:
	# GameClock (M30) es la autoridad del tick; nosotros solo leemos su estado
	_game_clock = get_node_or_null("/root/GameTime")
	if _game_clock != null:
		# Conectar señales de GameClock para mantener cache sincronizado
		_game_clock.hora_cambio.connect(_on_hora_cambio.bind())
		_game_clock.dia_cambio.connect(_on_dia_cambio.bind())
		_game_clock.estacion_cambio.connect(_on_estacion_cambio.bind())
		_game_clock.evento_activado.connect(_on_evento_activado.bind())

		# Sincronizar estado inicial
		_hora_actual = _game_clock.get_hora()
		_minuto_actual = _game_clock.get_minuto()
		var fecha = _game_clock.get_fecha()
		_dia_actual = fecha.dia
		_mes_actual = fecha.mes
		_anio_actual = fecha.anio
		_estacion_actual = _game_clock.get_estacion()
		_semana_dia_actual = _game_clock.get_semana_dia()
		_dia_absoluto_actual = _game_clock.dia_absoluto()
	else:
		push_warning("[TimeCalendar] GameClock no encontrado en autoload; usando estado interno")

func _registrar_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

## ── Callbacks de GameClock (mantienen cache sincronizado) ──

func _on_hora_cambio(hora: int) -> void:
	_hora_actual = hora
	hora_cambio.emit(hora)
	_verificar_eventos_proximos()

func _on_dia_cambio(info: Dictionary) -> void:
	_dia_actual = info.dia
	_mes_actual = info.mes
	_anio_actual = info.anio
	_semana_dia_actual = info.semana_dia
	_dia_absoluto_actual = _game_clock.dia_absoluto() if _game_clock else (_anio_actual - 1) * _config.get_dias_por_anio() + (_mes_actual - 1) * _config.dias_por_mes + _dia_actual
	dia_cambio.emit(info)
	_verificar_eventos_dia()

func _on_estacion_cambio(estacion: int) -> void:
	_estacion_actual = estacion
	estacion_cambio.emit(estacion)

func _on_evento_activado(evento: Dictionary) -> void:
	evento_activado.emit(evento)
	if evento.id != null:
		_eventos_visitados.append(str(evento.id))

func _verificar_eventos_dia() -> void:
	var eventos = _festivales.obtener_eventos_fecha(_dia_actual, _mes_actual, _estacion_actual)
	for ev in eventos:
		if ev.id != null and str(ev.id) not in _eventos_visitados:
			evento_activado.emit(ev)
			_eventos_visitados.append(str(ev.id))

func _verificar_eventos_proximos() -> void:
	var proximos = _festivales.obtener_proximos_eventos(_dia_actual, _mes_actual, _anio_actual, _config.dias_proximos_eventos)
	for ev in proximos:
		if ev.dia_relativo == 1 and _hora_actual == (_config.hora_amanecer - _config.ventana_aviso_evento_horas):
			# Aviso 24h antes (configurable)
			evento_proximo.emit(ev, _config.ventana_aviso_evento_horas)

## ── API Pública (Sección G del checklist) ──

func get_hora() -> int:
	return _hora_actual

func get_minuto() -> int:
	return _minuto_actual

func get_fecha() -> Dictionary:
	return {"dia": _dia_actual, "mes": _mes_actual, "anio": _anio_actual}

func get_estacion() -> int:
	return _estacion_actual

func get_semana_dia() -> int:
	return _semana_dia_actual

func get_dia_absoluto() -> int:
	return _dia_absoluto_actual

func get_nombre_dia(semana_dia: int = -1) -> String:
	if semana_dia == -1:
		semana_dia = _semana_dia_actual
	return _config.nombres_dias[clampi(semana_dia, 0, _config.dias_por_semana - 1)]

func get_nombre_mes(mes: int = -1) -> String:
	if mes == -1:
		mes = _mes_actual
	return _config.nombres_meses[clampi(mes - 1, 0, _config.meses_por_anio - 1)]

func get_nombre_estacion(estacion: int = -1) -> String:
	if estacion == -1:
		estacion = _estacion_actual
	return _config.nombres_estaciones[clampi(estacion, 0, _config.nombres_estaciones.size() - 1)]

func es_de_dia() -> bool:
	return _hora_actual >= _config.hora_amanecer and _hora_actual < _config.hora_atardecer

func es_noche() -> bool:
	return not es_de_dia()

func es_fin_de_semana() -> bool:
	return _semana_dia_actual >= 5  # Sábado=5, Domingo=6

## Formato de hora para UI
func formatear_hora(hora: int = -1, minuto: int = -1, forzar_24h: bool = false) -> String:
	if hora == -1:
		hora = _hora_actual
	if minuto == -1:
		minuto = _minuto_actual

	if _config.usar_formato_12h and not forzar_24h:
		var sufijo = "AM" if hora < 12 else "PM"
		var h12 = hora % 12
		if h12 == 0:
			h12 = 12
		return "%02d:%02d %s" % [h12, minuto, sufijo]
	else:
		return "%02d:%02d" % [hora, minuto]

func formatear_fecha_completa(dia: int = -1, mes: int = -1, anio: int = -1) -> String:
	if dia == -1: dia = _dia_actual
	if mes == -1: mes = _mes_actual
	if anio == -1: anio = _anio_actual
	var nombre_dia = get_nombre_dia(((_mes_actual - 1) * _config.dias_por_mes + dia - 1) % _config.dias_por_semana)
	var nombre_mes = get_nombre_mes(mes)
	return "%s, %d de %s del año %d" % [nombre_dia, dia, nombre_mes, anio]

## ── Eventos ──

func obtener_eventos_hoy() -> Array[Dictionary]:
	return _festivales.obtener_eventos_fecha(_dia_actual, _mes_actual, _estacion_actual)

func obtener_proximos_eventos(dias: int = -1) -> Array[Dictionary]:
	if dias == -1:
		dias = _config.dias_proximos_eventos
	return _festivales.obtener_proximos_eventos(_dia_actual, _mes_actual, _anio_actual, dias)

func hay_evento_hoy() -> bool:
	return obtener_eventos_hoy().size() > 0

func hay_festival_hoy() -> bool:
	for ev in obtener_eventos_hoy():
		if ev.tipo == "festival":
			return true
	return false

func obtener_festival_actual() -> Dictionary:
	for ev in obtener_eventos_hoy():
		if ev.tipo == "festival":
			return ev
	return {}

func registrar_evento_visitado(evento_id: String) -> void:
	if evento_id not in _eventos_visitados:
		_eventos_visitados.append(evento_id)

func evento_ya_visitado(evento_id: String) -> bool:
	return evento_id in _eventos_visitados

## ── Control de tiempo (delegado a GameClock) ──

func pausa() -> void:
	if _game_clock != null and _game_clock.has_method("pausa"):
		_game_clock.pausa()

func resume() -> void:
	if _game_clock != null and _game_clock.has_method("resume"):
		_game_clock.resume()

func avanzar_hasta(hora: int, minuto: int = 0) -> void:
	if _game_clock != null and _game_clock.has_method("avanzar_hasta"):
		_game_clock.avanzar_hasta(hora, minuto)

## ── Configuración expuesta ──

func get_config():
	return _config

func get_festivales():
	return _festivales

## Convierte fecha a día del año (1-336)
func fecha_a_dia_anio(dia: int, mes: int) -> int:
	return (mes - 1) * _config.dias_por_mes + dia

## Convierte día del año (1-336) a fecha
func dia_anio_a_fecha(dia_anio: int) -> Dictionary:
	dia_anio = clampi(dia_anio, 1, _config.get_dias_por_anio())
	var mes = ((dia_anio - 1) / _config.dias_por_mes) + 1
	var dia = ((dia_anio - 1) % _config.dias_por_mes) + 1
	return {"dia": dia, "mes": mes}

## ── Persistencia (ISaveProvider M59) ──

func get_section_name() -> String:
	return "time_calendar"

func get_save_data() -> Dictionary:
	return {
		"eventos_visitados": _eventos_visitados.duplicate(),
		"config_override": {
			"usar_formato_12h": _config.usar_formato_12h,
		}
	}

func restore_save_data(data: Dictionary) -> void:
	_eventos_visitados.clear()
	for e in data.get("eventos_visitados", []):
		_eventos_visitados.append(str(e))

	if data.has("config_override"):
		var co = data.config_override
		if co.has("usar_formato_12h"):
			_config.usar_formato_12h = bool(co.usar_formato_12h)