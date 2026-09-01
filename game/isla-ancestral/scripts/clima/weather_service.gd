# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M32: Clima — WeatherService (autoload "Weather")
# Núcleo determinista V0 (sin assets ni visión):
#  - Clima del día = f(semilla, dia_absoluto) vía PRNG; tabla estacional en clima_config.tres
#  - Regla cozy: clima profundo (tormenta/tropical) NUNCA dos días seguidos (fallback SOLEADO)
#  - Cambio de clima a medianoche del juego (GameClock M30); intensidad 0→1 en [60,90] min de juego
#  - Emite sobre EventBus M07: weather.clima_cambio / weather.intensidad_cambio
#  - Persistencia ISaveProvider (M59): sección "clima"; al cargar recomputa y valida
#    (si difieren, gana el recomputado — nunca data corrupta, 03-Diseno §3)
#  - Consumidores (M19/M33/M34/M36/M49/M50/M51/M52) escuchan señales, no internals
# ⚠️ Sin class_name: es autoload (pitfall documentado en 07-GUIA-GODOT §9.17/§9.41).
extends Node

enum Clima { SOLEADO, NUBLADO, LLUVIA, TORMENTA, NIEBLA, NIEVE, VIENTO, TROPICAL, ESPECIAL }

## Año Aurora (M29): 12 meses × 28 días = 336
const DIAS_POR_ANIO: int = 336
const DIAS_POR_MES: int = 28
const ESTACION_POR_MES: Array[int] = [0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3]
const NOMBRES_CLIMA: Array[String] = [
	"Soleado", "Nublado", "Lluvia", "Tormenta", "Niebla", "Nieve", "Viento", "Tropical", "Especial",
]
const CLIMAS_PRECIPITACION: Array[int] = [Clima.LLUVIA, Clima.TORMENTA, Clima.NIEVE, Clima.TROPICAL]

var _config: WeatherConfig = null
var _dia_actual: int = 1
var _clima_actual: int = Clima.SOLEADO
var _clima_ayer: int = Clima.SOLEADO
var _intensidad: float = 0.0
var _intensidad_objetivo: float = 1.0
var _minutos_transicion: int = 60
var _cache_clima: Dictionary = {}


func _ready() -> void:
	_cargar_config()
	_conectar_tiempo()
	_registrar_proveedor_guardado()
	_recalcular_dia_actual()


func _cargar_config() -> void:
	_config = load("res://data/clima/clima_config.tres") as WeatherConfig
	if _config == null:
		push_error("[Weather] clima_config.tres inválido o ausente; SOLEADO permanente")
		_config = WeatherConfig.new()


func _conectar_tiempo() -> void:
	var gt := get_node_or_null("/root/GameTime")
	if gt != null:
		gt.minuto_cambio.connect(_on_minuto_cambio)
		gt.dia_cambio.connect(_on_dia_cambio)
	else:
		push_warning("[Weather] GameTime no encontrado; clima estático")


func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)


## ── API pública (checklist H) ────────────────────────────

func get_clima() -> int:
	return _clima_actual


func get_intensidad() -> float:
	return _intensidad


func es_precipitacion() -> bool:
	return _clima_actual in CLIMAS_PRECIPITACION


## Clima de mañana (determinista, para el aviso con 1 día de M30/M29)
func clima_de_manana() -> int:
	return clima_de_dia(_dia_actual + 1)


## Atenuación de sol interpolada por intensidad (M31/M49 consultan; sin duplicar estado)
func get_atenuacion_sol() -> float:
	var sol_actual := float(_config.atenuacion_sol.get(_clima_actual, 1.0))
	var sol_ayer := float(_config.atenuacion_sol.get(_clima_ayer, 1.0))
	return lerpf(sol_ayer, sol_actual, _intensidad)


## Volumen del bus de audio climático interpolado (M42 consume en crossfade)
func get_volumen_audio() -> float:
	var vol_actual := float(_config.volumenes_audio.get(_clima_actual, 0.0))
	var vol_ayer := float(_config.volumenes_audio.get(_clima_ayer, 0.0))
	return lerpf(vol_ayer, vol_actual, _intensidad)


func get_nombre_clima(clima: int = -1) -> String:
	if clima < 0:
		clima = _clima_actual
	return NOMBRES_CLIMA[clampi(clima, 0, NOMBRES_CLIMA.size() - 1)]


## Duración del episodio en horas de juego (knobs para M29/UI)
func get_duracion_horas(clima: int = -1) -> Vector2:
	if clima < 0:
		clima = _clima_actual
	var d: Dictionary = _config.duraciones_horas.get(clima, {"min": 2.0, "max": 3.0})
	return Vector2(float(d.get("min", 2.0)), float(d.get("max", 3.0)))


## ── Determinismo (checklist C) ───────────────────────────

## Clima determinista del día `dia` (día absoluto monótono de GameClock M30).
## Cadena recursiva cacheada: clima(d) depende de clima(d-1) por la regla cozy.
func clima_de_dia(dia: int) -> int:
	if dia <= 0:
		return Clima.SOLEADO
	if _cache_clima.has(dia):
		return _cache_clima[dia]
	var mejor: int = 0
	for d in _cache_clima:
		if d < dia and d >= mejor:
			mejor = d
	var inicio: int = maxi(mejor + 1, 1)
	var anterior: int = Clima.SOLEADO
	if mejor >= 1:
		anterior = int(_cache_clima[mejor])
	for d in range(inicio, dia + 1):
		var c := _sortear_dia(d, anterior)
		_cache_clima[d] = c
		anterior = c
	return int(_cache_clima[dia])


## Limpia la cadena cacheada (solo tests/regeneración; el runtime no la usa)
func borrar_cache() -> void:
	_cache_clima.clear()


func _sortear_dia(dia: int, anterior: int) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = _config.semilla_clima * 1000003 + dia
	var eleccion := Clima.SOLEADO
	var r := rng.randf()
	var acumulado := 0.0
	var tabla: Array = _config.probabilidades_por_estacion.get(_estacion_de_dia(dia), [])
	for entrada in tabla:
		acumulado += float(entrada.get("prob", 0.0))
		if r <= acumulado:
			eleccion = int(entrada.get("clima", 0)) as Clima
			break
	# Regla cozy (03-Diseno §2): profundo nunca dos días seguidos → SOLEADO
	if eleccion in _config.climas_profundos and anterior in _config.climas_profundos:
		eleccion = Clima.SOLEADO
	return eleccion


func _estacion_de_dia(dia: int) -> int:
	var dia_anio: int = ((dia - 1) % DIAS_POR_ANIO) + 1
	var mes: int = floori((dia_anio - 1) / float(DIAS_POR_MES)) + 1
	return ESTACION_POR_MES[clampi(mes - 1, 0, ESTACION_POR_MES.size() - 1)]


## ── Transición (checklist D: medianoche + rampa por minutos de juego) ──

func _on_dia_cambio(_info: Dictionary) -> void:
	_recalcular_dia_actual()


func _recalcular_dia_actual() -> void:
	var gt := get_node_or_null("/root/GameTime")
	var dia: int = gt.dia_absoluto() if gt != null else _dia_actual
	var nuevo := clima_de_dia(dia)
	var ayer := clima_de_dia(dia - 1)
	var cambio := nuevo != _clima_actual
	_clima_ayer = ayer
	_clima_actual = nuevo
	_dia_actual = dia
	if cambio:
		var rng := RandomNumberGenerator.new()
		rng.seed = _config.semilla_clima * 1000003 + dia * 31 + 7
		_minutos_transicion = rng.randi_range(_config.transicion_min_minutos, _config.transicion_max_minutos)
		_intensidad = 0.0
		_intensidad_objetivo = 1.0
		EventBus.weather.clima_cambio.emit(_clima_actual)


func _on_minuto_cambio(_minuto: int) -> void:
	if is_equal_approx(_intensidad, _intensidad_objetivo):
		return
	var paso := 1.0 / float(maxi(_minutos_transicion, 1))
	_intensidad = move_toward(_intensidad, _intensidad_objetivo, paso)
	EventBus.weather.intensidad_cambio.emit(_intensidad)


## ── Persistencia (ISaveProvider M59) ─────────────────────

func get_section_name() -> String:
	return "clima"


func get_save_data() -> Dictionary:
	return {
		"dia": _dia_actual,
		"clima": _clima_actual,
		"intensidad": _intensidad,
	}


func restore_save_data(data: Dictionary) -> void:
	var guardado := int(data.get("clima", _clima_actual))
	var gt := get_node_or_null("/root/GameTime")
	if gt != null:
		_dia_actual = gt.dia_absoluto()
	_recalcular_dia_actual()
	_intensidad = clampf(float(data.get("intensidad", 1.0)), 0.0, 1.0)
	_intensidad_objetivo = 1.0
	_minutos_transicion = _config.transicion_max_minutos
	if guardado != _clima_actual:
		push_warning(
			"[Weather] clima guardado (%d) != recomputado (%d); gana el recomputado (determinismo)"
			% [guardado, _clima_actual]
		)
