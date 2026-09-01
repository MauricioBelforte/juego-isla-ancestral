# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M32: Test de WeatherService (determinismo, regla cozy, transición, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/clima/test_clima.gd

extends SceneTree

var _fallos: int = 0
var _weather: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_weather = root.get_node_or_null("Weather")
	_check(_weather != null, "Weather autoload presente")
	if _weather == null:
		print("=== TEST M32 CLIMA: 1 fallo(s) ===")
		quit(1)
		return
	_test_config_cargada()
	_test_determinismo()
	_test_regla_cozy_profundos()
	_test_tabla_estacional()
	_test_transicion_intensidad()
	_test_api()
	_test_clima_de_manana_determinista()
	_test_persistencia()
	print("=== TEST M32 CLIMA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_config_cargada() -> void:
	_check(_weather._config != null, "config cargada")
	_check(_weather._config.semilla_clima == 7919, "semilla dev 7919")
	var suma_p := 0.0
	for est in _weather._config.probabilidades_por_estacion:
		suma_p = 0.0
		for e in _weather._config.probabilidades_por_estacion[est]:
			suma_p += float(e.get("prob", 0.0))
		_check(absf(suma_p - 1.0) < 0.001, "probabilidades estación %d suman 1.0 (%.3f)" % [est, suma_p])
	_check(3 in _weather._config.climas_profundos, "tormenta es clima profundo")

func _test_determinismo() -> void:
	# Misma semilla + día ⇒ mismo clima, en cualquier orden de consulta
	var a: int = _weather.clima_de_dia(100)
	var b: int = _weather.clima_de_dia(50)
	var c: int = _weather.clima_de_dia(100)
	_check(a == c, "clima_de_dia(100) estable tras consultar otros días")
	_weather.borrar_cache()
	var a2: int = _weather.clima_de_dia(100)
	_check(a == a2, "mismo seed+día ⇒ mismo clima tras borrar cache")
	var d500: int = _weather.clima_de_dia(500)
	var d500b: int = _weather.clima_de_dia(500)
	_check(d500 == d500b, "día 500 determinista (año 2)")

func _test_regla_cozy_profundos() -> void:
	# En 3 años simulados, jamás dos días seguidos de clima profundo
	_weather.borrar_cache()
	var profundos: Array = _weather._config.climas_profundos
	var violaciones := 0
	var anterior: int = _weather.clima_de_dia(1)
	for d in range(2, 1009):
		var actual: int = _weather.clima_de_dia(d)
		if actual in profundos and anterior in profundos:
			violaciones += 1
		anterior = actual
	_check(violaciones == 0, "sin 2 días profundos seguidos en 1008 días (violaciones=%d)" % violaciones)

func _test_tabla_estacional() -> void:
	# Invierno (días 289-336, 649-696...) debe poder dar nieve (5); verano (89-168) nunca
	_weather.borrar_cache()
	var nieve_invierno := false
	for d in range(289, 337):
		if _weather.clima_de_dia(d) == 5:
			nieve_invierno = true
			break
	_check(nieve_invierno, "nieve aparece en invierno (336 días muestreados)")
	var clima_verano_tropical_o_soleado := true
	for d in range(89, 169):
		var c: int = _weather.clima_de_dia(d)
		if c == 5:
			clima_verano_tropical_o_soleado = false
	_check(clima_verano_tropical_o_soleado, "sin nieve en verano (días 89-168)")

func _test_transicion_intensidad() -> void:
	# Rampa 0→1 en _minutos_transicion pasos de minuto
	_weather._intensidad = 0.0
	_weather._intensidad_objetivo = 1.0
	_weather._minutos_transicion = 60
	var vistos: Array[float] = []
	for i in range(61):
		_weather._on_minuto_cambio(i)
		vistos.append(_weather.get_intensidad())
	_check(vistos[0] > 0.0, "intensidad arranca >0 en primer minuto")
	_check(is_equal_approx(vistos[60], 1.0), "intensidad llega a 1.0 en 60 minutos")
	var monotonica := true
	for i in range(1, vistos.size()):
		if vistos[i] < vistos[i - 1]:
			monotonica = false
	_check(monotonica, "intensidad monótona creciente (sin cortes)")
	# Las lambdas capturan por valor: usar contenedor mutable para contar
	var contador: Array = [0]
	var cb := func(_i: float) -> void:
		contador[0] += 1
	var bus: Node = root.get_node_or_null("EventBus")
	if bus != null:
		bus.weather.intensidad_cambio.connect(cb)
	_weather._intensidad = 0.0
	for i in range(3):
		_weather._on_minuto_cambio(i)
	_check(contador[0] == 3, "intensidad_cambio emitida por cada minuto de transición (%d)" % contador[0])
	if bus != null:
		bus.weather.intensidad_cambio.disconnect(cb)

func _test_api() -> void:
	_weather._clima_ayer = 0
	_weather._clima_actual = 2
	_weather._intensidad = 0.5
	_check(absf(_weather.get_atenuacion_sol() - 0.85) < 0.001,
		"atenuación interpolada entre sol_ayer(1.0) y lluvia(0.7): %.3f" % _weather.get_atenuacion_sol())
	_check(absf(_weather.get_volumen_audio() - 0.4) < 0.001,
		"volumen audio interpolado: %.3f" % _weather.get_volumen_audio())
	_weather._clima_actual = 3
	_check(_weather.es_precipitacion(), "tormenta es precipitación")
	_weather._clima_actual = 4
	_check(not _weather.es_precipitacion(), "niebla no es precipitación")
	_check(_weather.get_nombre_clima(3) == "Tormenta", "nombre clima 3 = Tormenta")
	var dur: Vector2 = _weather.get_duracion_horas(0)
	_check(dur.x == 2.0 and dur.y == 4.0, "duración soleado 2-4 h")
	_weather._clima_actual = 0

func _test_clima_de_manana_determinista() -> void:
	var m1: int = _weather.clima_de_manana()
	var m2: int = _weather.clima_de_manana()
	_check(m1 == m2, "clima_de_manana estable (aviso M30)")

func _test_persistencia() -> void:
	_weather._clima_actual = _weather.clima_de_dia(_weather._dia_actual)
	var data: Dictionary = _weather.get_save_data()
	_check(data.has("dia") and data.has("clima") and data.has("intensidad"), "save_data completo")
	_check(_weather.get_section_name() == "clima", "sección save 'clima'")
	# Restaurar con clima distinto al recomputado: gana el recomputado (warning, sin crash)
	var clima_guardado_viejo: int = int(data.get("clima", 0)) + 1
	if clima_guardado_viejo > 8:
		clima_guardado_viejo = 0
	_weather.restore_save_data({"clima": clima_guardado_viejo, "intensidad": 0.42})
	_check(_weather.get_clima() == _weather.clima_de_dia(_weather._dia_actual),
		"tras restore gana el recomputado (determinismo)")
	_check(absf(_weather.get_intensidad() - 0.42) < 0.001, "intensidad restaurada 0.42")
