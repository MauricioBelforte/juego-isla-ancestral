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
signal minuto_cambio(minuto: int)
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
	_asegurar_semilla_partida()
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
## Avanza un minuto de juego; en cada minuto emite minuto_cambio, en cada hora
## hora_cambio, en día nuevo dia_cambio.
func _avanzar_minuto() -> void:
	_minuto += 1
	if _minuto >= 60:
		_minuto = 0
	minuto_cambio.emit(_minuto)
	if _minuto != 0:
		return
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

## ── Semilla de tiempo por partida (H120, M29 iter 1 — GLM-5.3 / Kilo Code, Log 824) ──
## PRNG determinista por partida: la misma partida produce la misma secuencia
## de valores "aleatorios" diarios entre sesiones (y entre cargas del mismo save).
## Patrones de consumo recomendados (los módulos dueños de contenido definen el suyo):
##   var v = GameTime.valor_diario("mi_modulo", 0, 99)   # entero estable del día actual
##   var r = GameTime.rng_diario("mi_modulo")            # RandomNumberGenerator fresh del día
## La flag usar_semilla_tiempo (time_config.tres, default true) activa la semilla por
## partida; en false se usa la semilla 0 (modo determinista global, útil para tests/QA).
var _semilla_partida: int = 0

func get_semilla_partida() -> int:
	return _semilla_partida

## Asigna la semilla de partida (la invoca M59 al crear partida nueva o restaurar
## el save; también la usan los tests para fijar determinismo).
func set_semilla_partida(semilla: int) -> void:
	_semilla_partida = int(semilla)

## Genera una semilla nueva para partida nueva (una sola vez por partida).
## Se llama desde _ready si el save no trajo semilla (primera partida).
## Nota C56/E89/E90: NO lee el reloj del SO (regla de oro del módulo: el
## gameplay jamás consume tiempo real). Usa randi() global del motor — la
## fuente de entropía idiomática de Godot 4, auto-inicializada por el runtime.
func _asegurar_semilla_partida() -> void:
	if _semilla_partida != 0:
		return
	var usar := true
	var config = _config_de_tiempo()
	if config != null and "usar_semilla_tiempo" in config:
		usar = bool(config.usar_semilla_tiempo)
	if not usar:
		_semilla_partida = 0  # modo determinista global (tests/QA reproducibles)
		return
	# Entropía del motor (randi() global, 64 bits en Godot 4): dos partidas
	# creadas en el mismo segundo difieren; nos quedamos con 31 bits para
	# evitar overflows en las multiplicaciones de los consumidores.
	_semilla_partida = int(randi() % 2147483647)

func _config_de_tiempo():
	if get_tree() == null:
		return null
	return load("res://data/time/time_config.tres")

## Valor entero determinista del día actual para un namespace de consumidor.
## misma partida + mismo día + mismo namespace → SIEMPRE el mismo valor.
## rango [min, max] inclusivo. Para valores continuos usar rng_diario().
func valor_diario(ns_consumidor: String, minimo: int = 0, maximo: int = 99) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = _hash_semilla_diaria(ns_consumidor)
	return rng.randi_range(minimo, maximo)

## RandomNumberGenerator determinista del día actual para un namespace.
## Los consumidores pueden llamar varios randi/randf del mismo día y
## obtener la misma secuencia en cualquier carga del mismo save.
func rng_diario(ns_consumidor: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = _hash_semilla_diaria(ns_consumidor)
	return rng

## Hash estable: semilla de partida + día absoluto + namespace (FNV-1a 32 bits,
## determinista entre sesiones a diferencia de hash() de Godot).
func _hash_semilla_diaria(ns_consumidor: String) -> int:
	var h: int = 2166136261
	var clave := str(_semilla_partida) + ":" + str(dia_absoluto()) + ":" + ns_consumidor
	for ch in clave.to_utf8_buffer():
		h = (h ^ int(ch)) * 16777619
		h = h % 2147483647  # mantener en 31 bits
	return h

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
		"semilla_partida": _semilla_partida,  # H120: misma semilla al recargar
	}

func restore_save_data(data: Dictionary) -> void:
	_hora = clampi(int(data.get("hora", 8)), 0, 23)
	_minuto = clampi(int(data.get("minuto", 0)), 0, 59)
	_dia = clampi(int(data.get("dia", 1)), 1, DIAS_POR_MES)
	_mes = clampi(int(data.get("mes", 1)), 1, MESES)
	_anio = maxi(1, int(data.get("anio", 1)))
	_acumulador = float(data.get("acumulador", 0.0))
	_estado_estacion = get_estacion()
	# H120: restaurar la semilla de partida del save (0 = genera nueva en _ready)
	_semilla_partida = int(data.get("semilla_partida", 0))
	if _semilla_partida == 0:
		_asegurar_semilla_partida()
	_eventos_visitados.clear()
	for e in data.get("eventos_visitados", []):
		_eventos_visitados.append(str(e))
