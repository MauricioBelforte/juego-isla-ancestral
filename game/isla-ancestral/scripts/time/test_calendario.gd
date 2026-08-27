extends SceneTree

## Test del calendario Aurora (M29 GameClock).
## Valida: conversiones fecha→semana/estación, ciclo día→mes→año (transición
## limpia de año nuevo), pausa/resume, avanzar_hasta (dormir), es_de_dia y
## persistencia round-trip. No depende del tiempo real (usa métodos puros).

const CLOCK := preload("res://scripts/time/game_clock.gd")

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	print("=== TEST CALENDARIO M29 ===")
	var c = CLOCK.new()

	# Día inicial: Primavera, mes 1, año 1
	_check("estacion inicial Primavera", c.get_estacion() == 0)
	_check("fecha inicial dia1/mes1/anio1", c.get_fecha() == {"dia": 1, "mes": 1, "anio": 1})
	_check("es_de_dia a las 8h", c.es_de_dia())

	# Es de noche al cambiar a 22h
	c._hora = 22
	_check("no es de dia a las 22h", not c.es_de_dia())

	# Avanzar horas manuales hasta cruzar días y verificar ciclo día/mes/año
	c._hora = 23
	c._minuto = 0
	c._nuevo_dia()
	_check("dia avanzo a 2", c.get_fecha()["dia"] == 2)

	# Cruzar al mes 2: forzar fin de mes
	c._dia = 28
	c._nuevo_dia()
	_check("mes avanzo a 2", c.get_fecha()["mes"] == 2 and c.get_fecha()["dia"] == 1)

	# Cruzar año: forzar fin de año
	c._mes = 12
	c._dia = 28
	c._nuevo_dia()
	_check("anio avanzo a 2 (sin bug)", c.get_fecha()["anio"] == 2 and c.get_fecha()["mes"] == 1 and c.get_fecha()["dia"] == 1)

	# Transición de estación (mes 3 -> mes 4 va a Verano)
	c._mes = 3
	c._dia = 28
	c._estado_estacion = 0
	c._nuevo_dia()
	_check("cambio estacion Primavera->Verano", c.get_estacion() == 1)

	# pausa congelamiento
	c._pausado = true
	var antes: int = int(c._minuto)
	c._process(50)  # 50 segundos reales; pausado no debe avanzar
	_check("pausa congela el reloj", c._minuto == antes)

	# avanzar_hasta (dormir): desde Mediodía hasta las 6:00
	c._hora = 14
	c._minuto = 30
	c._pausado = false
	c.avanzar_hasta(6, 0)
	_check("avanzar_hasta llega a 6:00", c.get_hora() == 6 and c.get_minuto() == 0)

	# Semana: Lunes a las 0 días de semana
	var dia_sem := c.get_semana_dia()
	_check("semana_dia en rango", dia_sem >= 0 and dia_sem <= 6)

	# Persistencia round-trip
	var s := c.get_save_data()
	var c2 = CLOCK.new()
	c2.restore_save_data(s)
	_check("persistencia restaura hora", c2.get_hora() == c.get_hora())
	_check("persistencia restaura fecha", c2.get_fecha() == c.get_fecha())

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS CALENDARIO"); quit(1)
	else:
		print("CALENDARIO OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)