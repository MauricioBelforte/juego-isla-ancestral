# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M29: Tiempo y Calendario — GameClock (autoload "GameTime")
# Servicio temporal puro del mundo Aurora (V0, sin assets/visión):
#  - Día 24 min reales (1 s real = 1 min de juego, 1:40)
#  - Año 336 días (12 meses × 28 días), 4 estaciones de 3 meses
#  - Automático: acumulador de tiempo anti-drift en _process
#  - Emite sobre EventBus M07 calendar (day_started, season_changed) y señales
#    propias (dia_cambio/hora_cambio/estacion_cambio/evento_activado)
#  - Regla cozy: eventos repetibles, reloj no corre offline ni retrocede
#  - Persistencia ISaveProvider (M59): sección "time"
# ⚠️ Sin class_name: es autoload (pitfall documentado).
extends Node

## Duración de día de juego en segundos reales (24 min)
const SEG_DIA_REAL: float = 24.0 * 60.0
const MIN_POR_DIA: int = 24 * 60
const DIAS_POR_SEMANA: int = 7
const MESES: int = 12
const DIAS_POR_MES: int = 28
const DIAS_ANO: int = MESES * DIAS_POR_MES  # 336

const NOMBRES_SEMANA := ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]
const NOMBRES_ESTACIONES := ["Primavera", "Verano", "Otoño", "Invierno"]
const ESTACION_POR_MES := [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3]

signal dia_cambio(info: Dictionary)
signal hora_cambio(hora: int)
signal estacion_cambio(estacion: int)
signal evento_activado(evento: Dictionary)

var _dia: int = 1          # 1-based día del mes
var _mes: int = 1          # 1-based mes (1..12)
var _anio: int = 1
var _hora: int = 8         # 0..23 (mañana inicial)
var _minuto: int = 0
var _acumulador: float = 0.0
var _pausado: bool = false
var _estado_estacion: int = 0
var _eventos_visitados: Array = []

func _ready() -> void:
	_estado_estacion = get_estacion()
	_registrar_como_proveedor_guardado()

func _registrar_como_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

## Tick automático: 1 s real = 1 min de juego.
func _process(delta: float) -> void:
	if _pausado:
		return
	_acumulador += delta
	while _acumulador >= 1.0:
		_acumulador -= 1.0
		_avanzar_minuto()
## Avanza un minuto de juego; en cada hora emite hora_cambio, en día nuevo dia_cambio.
func _avanzar_minuto() -> void:
	_minuto += 1
	if _minuto < 60:
		return
	_minuto = 0
	var hora_ant := _hora
	_hora = (_hora + 1) % 24
	if _hora != hora_ant:
		hora_cambio.emit(_hora)
	if _hora == 0:
		_nuevo_dia()

func _nuevo_dia() -> void:
	_dia += 1
	if _dia > DIAS_POR_MES:
		_dia = 1
		_mes += 1
		if _mes > MESES:
			_mes = 1
			_anio += 1
	# Detecta cambio de estación (cambio de mes que cruza a otra estación)
	var est := get_estacion()
	if est != _estado_estacion:
		var ant := _estado_estacion
		_estado_estacion = est
		estacion_cambio.emit(est)
		_emit_bus_season(ant, est)
	dia_cambio.emit(_info_dia())
	_emit_bus_day()

## ── API pública (sección G) ───────────────────────────────
func get_hora() -> int:
	return _hora

func get_minuto() -> int:
	return _minuto

func get_fecha() -> Dictionary:
	return {"dia": _dia, "mes": _mes, "anio": _anio}

func get_estacion() -> int:
	return ESTACION_POR_MES[clampi(_mes - 1, 0, MESES - 1)]

func get_semana_dia() -> int:
	var dia_ano := (_mes - 1) * DIAS_POR_MES + _dia - 1
	return dia_ano % DIAS_POR_SEMANA

## Día absoluto monótono (colapsa año-mes-día). Consumidores con límites
## diarios, ventanas de oferta o restocks deben usar ESTE contador, no
## get_fecha().dia, porque se romperían cada paso de mes (28→1) o de año.
func dia_absoluto() -> int:
	return (_anio - 1) * DIAS_ANO + (_mes - 1) * DIAS_POR_MES + _dia

func es_de_dia() -> bool:
	return _hora >= 6 and _hora < 20

func pausa() -> void:
	_pausado = true

func resume() -> void:
	_pausado = false

## Dormir en cama: avanza en ráfagas hasta la hora indicada (por defecto 6:00).
func avanzar_hasta(hora: int, minuto: int = 0) -> void:
	var guardas := 0
	while not (_hora == hora and _minuto == minuto):
		guardas += 1
		if guardas > MIN_POR_DIA * 2:
			break  # salvaguarda anti-bucle
		_avanzar_minuto()

func proximos_eventos(dias: int = 7) -> Array:
	# Eventos de ejemplo repetibles (regla cozy). Data real en festivals.tres.
	var eventos := []
	for i in range(1, dias + 1):
		eventos.append({
			"dia": ((_dia - 1 + i) % DIAS_POR_MES) + 1,
			"tipo": "festival",
			"repetible": true,
		})
	return eventos

func _info_dia() -> Dictionary:
	return {
		"dia": _dia, "mes": _mes, "anio": _anio,
		"semana_dia": get_semana_dia(),
		"estacion": get_estacion(),
	}

## ── Emisión al EventBus M07 ──────────────────────────────
func _emit_bus_day() -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.calendar != null:
		bus.calendar.day_started.emit(_dia, NOMBRES_ESTACIONES[get_estacion()])

func _emit_bus_season(ant: int, nuevo: int) -> void:
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.calendar != null:
		bus.calendar.season_changed.emit(NOMBRES_ESTACIONES[ant], NOMBRES_ESTACIONES[nuevo])

## ── Persistencia (ISaveProvider M59) ──────────────────────
func get_section_name() -> String:
	return "time"

func get_save_data() -> Dictionary:
	return {
		"hora": _hora, "minuto": _minuto,
		"dia": _dia, "mes": _mes, "anio": _anio,
		"acumulador": _acumulador,
		"eventos_visitados": _eventos_visitados.duplicate(),
	}

func restore_save_data(data: Dictionary) -> void:
	_hora = clampi(int(data.get("hora", 8)), 0, 23)
	_minuto = clampi(int(data.get("minuto", 0)), 0, 59)
	_dia = clampi(int(data.get("dia", 1)), 1, DIAS_POR_MES)
	_mes = clampi(int(data.get("mes", 1)), 1, MESES)
	_anio = maxi(1, int(data.get("anio", 1)))
	_acumulador = float(data.get("acumulador", 0.0))
	_estado_estacion = get_estacion()
	_eventos_visitados.clear()
	for e in data.get("eventos_visitados", []):
		_eventos_visitados.append(str(e))