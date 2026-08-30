extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Unit tests para TimeCalendar (M29)
## Verifica la funcionalidad del calendario y tiempo
##
## TimeCalendar es un autoload sin class_name (Node).
## Se instancia vía preload() del script.
## NOTA: TimeCalendar delega el estado de tiempo a GameClock (M30).
## Sin GameClock, los getters retornan defaults o estado interno cacheado.

const TIME_SCRIPT := preload("res://scripts/time/time_calendar.gd")

var _calendar

func before_test() -> void:
	_calendar = TIME_SCRIPT.new()

func after_test() -> void:
	if _calendar != null:
		_calendar.free()
		_calendar = null

func test_instantiation() -> void:
	assert_that(_calendar).is_not_null()

func test_get_hora_returns_int() -> void:
	var hora = _calendar.get_hora()
	assert_that(hora).is_instance_of(int)
	assert_that(hora >= 0 and hora <= 23).is_true()

func test_get_minuto_returns_int() -> void:
	var minuto = _calendar.get_minuto()
	assert_that(minuto).is_instance_of(int)
	assert_that(minuto >= 0 and minuto <= 59).is_true()

func test_get_estacion_returns_int() -> void:
	var estacion = _calendar.get_estacion()
	assert_that(estacion).is_instance_of(int)
	assert_that(estacion >= 0 and estacion <= 3).is_true()

func test_get_semana_dia_returns_int() -> void:
	var semana_dia = _calendar.get_semana_dia()
	assert_that(semana_dia).is_instance_of(int)
	assert_that(semana_dia >= 0 and semana_dia <= 6).is_true()

func test_get_dia_absoluto_returns_int() -> void:
	var dia_abs = _calendar.get_dia_absoluto()
	assert_that(dia_abs).is_instance_of(int)
	assert_that(dia_abs >= 1).is_true()

func test_es_de_dia() -> void:
	var result = _calendar.es_de_dia()
	assert_that(result).is_instance_of(bool)

func test_es_noche() -> void:
	var result = _calendar.es_noche()
	assert_that(result).is_instance_of(bool)

func test_es_fin_de_semana() -> void:
	var result = _calendar.es_fin_de_semana()
	assert_that(result).is_instance_of(bool)

func test_get_fecha() -> void:
	var fecha = _calendar.get_fecha()
	assert_that(fecha).is_instance_of(Dictionary)
	assert_that(fecha.has("dia")).is_true()
	assert_that(fecha.has("mes")).is_true()
	assert_that(fecha.has("anio")).is_true()

func test_pausar_reanudar() -> void:
	_calendar.pausar()
	# Sin GameClock, pausa/resume son no-ops pero no deben fallar
	_calendar.resume()

func test_get_section_name() -> void:
	assert_that(_calendar.get_section_name()).is_equal_to("time_calendar")

func test_get_save_data() -> void:
	var data = _calendar.get_save_data()
	assert_that(data).is_instance_of(Dictionary)
	assert_that(data.has("eventos_visitados")).is_true()

func test_restore_save_data() -> void:
	var data = {"eventos_visitados": ["evt_1", "evt_2"]}
	_calendar.restore_save_data(data)
	# Verificar que restauró los eventos visitados
	assert_that(_calendar.evento_ya_visitado("evt_1")).is_true()
	assert_that(_calendar.evento_ya_visitado("evt_2")).is_true()
	assert_that(_calendar.evento_ya_visitado("evt_3")).is_false()

func test_formatear_hora() -> void:
	var resultado = _calendar.formatear_hora(14, 30)
	assert_that(resultado).is_instance_of(String)
	assert_that(resultado.length()).is_greater(0)

func test_fecha_a_dia_anio() -> void:
	var dia_anio = _calendar.fecha_a_dia_anio(1, 1)
	assert_that(dia_anio).is_equal_to(1)

	var dia_anio_mes3 = _calendar.fecha_a_dia_anio(1, 3)
	assert_that(dia_anio_mes3).is_greater(1)
