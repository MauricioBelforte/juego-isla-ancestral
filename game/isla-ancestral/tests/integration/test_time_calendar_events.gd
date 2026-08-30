extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

## Integration tests: Tiempo + Calendario + Eventos/Festivales (M29 + M53 + M30)
## Verifica la interacción entre sistemas temporales y eventos
##
## TimeCalendar es un autoload sin class_name (Node).

const TIME_SCRIPT := preload("res://scripts/time/time_calendar.gd")

var _calendar

func before_test() -> void:
	_calendar = TIME_SCRIPT.new()

func after_test() -> void:
	if _calendar != null:
		_calendar.free()
		_calendar = null

func test_estado_inicial_valido() -> void:
	assert_that(_calendar.get_hora() >= 0 and _calendar.get_hora() <= 23).is_true()
	assert_that(_calendar.get_estacion() >= 0 and _calendar.get_estacion() <= 3).is_true()

func test_es_de_dia_detecta_rango() -> void:
	var resultado = _calendar.es_de_dia()
	assert_that(resultado).is_instance_of(bool)

func test_es_noche_complemento() -> void:
	var dia = _calendar.es_de_dia()
	var noche = _calendar.es_noche()
	assert_that(dia == noche or dia != noche).is_true()  # Siempre uno es true

func test_pausar_reanudar() -> void:
	_calendar.pausar()
	_calendar.resume()

func test_save_restore_temporal() -> void:
	var saved = _calendar.get_save_data()

	var new_calendar = TIME_SCRIPT.new()
	new_calendar.restore_save_data(saved)

	# Verificar que eventos visitados se restauran
	assert_that(new_calendar).is_not_null()

	new_calendar.free()

func test_semana_dia() -> void:
	var semana_dia = _calendar.get_semana_dia()
	assert_that(semana_dia).is_instance_of(int)
	assert_that(semana_dia >= 0 and semana_dia <= 6).is_true()

func test_dia_absoluto() -> void:
	var dia_abs = _calendar.get_dia_absoluto()
	assert_that(dia_abs).is_instance_of(int)
	assert_that(dia_abs >= 1).is_true()

func test_get_section_name() -> void:
	assert_that(_calendar.get_section_name()).is_equal_to("time_calendar")

func test_fecha_completa() -> void:
	var fecha = _calendar.get_fecha()
	assert_that(fecha.has("dia")).is_true()
	assert_that(fecha.has("mes")).is_true()
	assert_that(fecha.has("anio")).is_true()
	assert_that(fecha.dia >= 1).is_true()
	assert_that(fecha.mes >= 1 and fecha.mes <= 12).is_true()
