# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M29 — Test headless de TimeCalendar (fachada del modulo Tiempo y Calendario).
#
#   A. Instanciacion + config    carga de time_config.tres / festivals.tres
#   B. Tipos de retorno          get_* devuelven el tipo declarado (typeof + TYPE_*)
#   C. Rangos                    hora/minuto/estacion/semana_dia/dia_absoluto
#   D. Fecha                     get_fecha() trae dia/mes/anio coherentes
#   E. Dia/noche                 es_de_dia()/es_noche() en los bordes del horario (6..20)
#   F. Pausa/resume              pausa()/resume()/avanzar_hasta() sin GameClock
#   G. Persistencia              get_section_name + save/restore round-trip
#   H. Formato + conversion      formatear_hora() y fecha_a_dia_anio()/dia_anio_a_fecha()
#
# ⚠️ Guardia anti-falso-verde (3 capas, trampas 11/63/122):
#   1) cada bloque cierra con `_fin(letra)`; si aborta en silencio (M124) la letra
#      falta y `_summary()` FALLA;
#   2) piso `CHECKS_MINIMOS` MEDIDO en verde: un aborto parcial baja el conteo;
#   3) `_summary()` en un `call_deferred` SEPARADO (si `_run()` aborta, igual corre).
#   Watchdog por temporizador: si la suite no termina, cierra con codigo 1.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://tests/unit/time/test_time_calendar.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso de checks MEDIDO en verde (no estimado): un aborto parcial baja el conteo.
const CHECKS_MINIMOS := 74
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H"]

const TIME_SCRIPT := preload("res://scripts/time/time_calendar.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0
var CAL: Node = null


func _init() -> void:
	call_deferred("_run")
	# `_summary()` en la cola diferida: si `_run()` muere por un SCRIPT ERROR,
	# la cola sigue y el resumen CORRE igual (nombra los bloques faltantes).
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== [M29] TimeCalendar — fachada de Tiempo y Calendario ===")
	_bloque_a_instanciacion()
	_bloque_b_tipos()
	_bloque_c_rangos()
	_bloque_d_fecha()
	_bloque_e_dia_noche()
	_bloque_f_pausa()
	_bloque_g_persistencia()
	_bloque_h_formato()
	if CAL != null:
		CAL.free()
		CAL = null


func _on_watchdog() -> void:
	_abortado = true
	print("[M29] WATCHDOG: la suite no termino en %.0f s — ABORTO (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


## ── Helpers ─────────────────────────────────────────────

func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	# Capa 1: bloques que no cerraron (aborto silencioso M124).
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("los 8 bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	# Capa 2: piso de checks medido en verde.
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M29 TimeCalendar: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M29 TimeCalendar ABORTADO por watchdog")
		quit(1)
	elif _fallos == 0:
		print("TEST M29 TimeCalendar OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M29 TimeCalendar FALLO — %d checks fallaron" % _fallos)
		quit(1)


## ── A. Instanciacion + config ────────────────────────────

func _bloque_a_instanciacion() -> void:
	_ini("A. Instanciacion + config")
	CAL = TIME_SCRIPT.new()
	_check("instancia creada", CAL != null)
	CAL.call("_cargar_configuracion")
	var cfg = CAL.call("get_config")
	_check("time_config.tres cargada", cfg != null)
	var fest = CAL.call("get_festivales")
	_check("festivals.tres cargada", fest != null)
	_check("config: dias_por_mes == 28", int(cfg.get("dias_por_mes")) == 28)
	_check("config: dias_por_semana == 7", int(cfg.get("dias_por_semana")) == 7)
	_check("config: hora_amanecer == 6", int(cfg.get("hora_amanecer")) == 6)
	_check("config: hora_atardecer == 20", int(cfg.get("hora_atardecer")) == 20)
	_check("estacion_inicial aplicada (0)", int(CAL.get("_estacion_actual")) == 0)
	_check("anio_fundacion aplicado (1)", int(CAL.get("_anio_actual")) == 1)
	_fin("A. instanciacion")


## ── B. Tipos de retorno ──────────────────────────────────

func _bloque_b_tipos() -> void:
	_ini("B. Tipos de retorno")
	_check("get_hora() es int", typeof(CAL.call("get_hora")) == TYPE_INT)
	_check("get_minuto() es int", typeof(CAL.call("get_minuto")) == TYPE_INT)
	_check("get_estacion() es int", typeof(CAL.call("get_estacion")) == TYPE_INT)
	_check("get_semana_dia() es int", typeof(CAL.call("get_semana_dia")) == TYPE_INT)
	_check("get_dia_absoluto() es int", typeof(CAL.call("get_dia_absoluto")) == TYPE_INT)
	_check("get_fecha() es Dictionary", typeof(CAL.call("get_fecha")) == TYPE_DICTIONARY)
	_check("es_de_dia() es bool", typeof(CAL.call("es_de_dia")) == TYPE_BOOL)
	_check("es_noche() es bool", typeof(CAL.call("es_noche")) == TYPE_BOOL)
	_check("es_fin_de_semana() es bool", typeof(CAL.call("es_fin_de_semana")) == TYPE_BOOL)
	_check("formatear_hora() es String", typeof(CAL.call("formatear_hora")) == TYPE_STRING)
	_fin("B. tipos")


## ── C. Rangos ────────────────────────────────────────────

func _bloque_c_rangos() -> void:
	_ini("C. Rangos")
	var h: int = int(CAL.call("get_hora"))
	var m: int = int(CAL.call("get_minuto"))
	var e: int = int(CAL.call("get_estacion"))
	var sd: int = int(CAL.call("get_semana_dia"))
	var da: int = int(CAL.call("get_dia_absoluto"))
	_check("hora 0..23", h >= 0 and h <= 23, "h=%d" % h)
	_check("minuto 0..59", m >= 0 and m <= 59, "m=%d" % m)
	_check("estacion 0..3", e >= 0 and e <= 3, "e=%d" % e)
	_check("semana_dia 0..6", sd >= 0 and sd <= 6, "sd=%d" % sd)
	_check("dia_absoluto >= 1", da >= 1, "da=%d" % da)
	_fin("C. rangos")


## ── D. Fecha ─────────────────────────────────────────────

func _bloque_d_fecha() -> void:
	_ini("D. Fecha")
	var f: Dictionary = CAL.call("get_fecha")
	_check("get_fecha() trae dia", f.has("dia"))
	_check("get_fecha() trae mes", f.has("mes"))
	_check("get_fecha() trae anio", f.has("anio"))
	_check("dia >= 1", int(f.get("dia", 0)) >= 1)
	_check("mes 1..12", int(f.get("mes", 0)) >= 1 and int(f.get("mes", 0)) <= 12)
	_check("anio >= 1", int(f.get("anio", 0)) >= 1)
	_check("fecha.dia == _dia_actual", int(f.get("dia")) == int(CAL.get("_dia_actual")))
	_check("fecha.mes == _mes_actual", int(f.get("mes")) == int(CAL.get("_mes_actual")))
	_check("fecha.anio == _anio_actual", int(f.get("anio")) == int(CAL.get("_anio_actual")))
	_fin("D. fecha")


## ── E. Dia/noche (bordes del horario) ────────────────────

func _bloque_e_dia_noche() -> void:
	_ini("E. Dia/noche (horario 6..20)")
	var casos: Array = [
		[5, false, "05:00 antes del amanecer"],
		[6, true, "06:00 justo al amanecer"],
		[12, true, "12:00 mediodia"],
		[19, true, "19:00 ultima hora de dia"],
		[20, false, "20:00 justo al atardecer"],
		[23, false, "23:00 noche"],
	]
	for caso in casos:
		var c: Array = caso
		CAL.set("_hora_actual", int(c[0]))
		var dia: bool = bool(CAL.call("es_de_dia"))
		var noche: bool = bool(CAL.call("es_noche"))
		_check("a las %s: es_de_dia=%s" % [str(c[2]), str(c[1])], dia == bool(c[1]), "h=%d" % int(c[0]))
		_check("a las %s: es_noche complementario" % str(c[2]), noche == (not dia))
	CAL.set("_hora_actual", 8)
	_fin("E. dia/noche")


## ── F. Pausa/resume (sin GameClock) ──────────────────────

func _bloque_f_pausa() -> void:
	_ini("F. Pausa/resume sin GameClock")
	CAL.set("_game_clock", null)
	# Si alguna de estas llamadas lanzara, el bloque abortaria y `_fin` faltaria.
	CAL.call("pausa")
	CAL.call("resume")
	CAL.call("avanzar_hasta", 12, 0)
	_check("pausa/resume/avanzar_hasta no alteran el cache de hora", int(CAL.call("get_hora")) == 8,
		"h=%d" % int(CAL.call("get_hora")))
	_check("get_hora() sigue siendo int tras las llamadas", typeof(CAL.call("get_hora")) == TYPE_INT)
	_fin("F. pausa")


## ── G. Persistencia ──────────────────────────────────────

func _bloque_g_persistencia() -> void:
	_ini("G. Persistencia")
	_check("get_section_name() == 'time_calendar'", String(CAL.call("get_section_name")) == "time_calendar")
	var data: Dictionary = CAL.call("get_save_data")
	_check("get_save_data() trae eventos_visitados", data.has("eventos_visitados"))
	_check("get_save_data() trae config_override", data.has("config_override"))
	CAL.call("registrar_evento_visitado", "evt_1")
	CAL.call("registrar_evento_visitado", "evt_2")
	CAL.call("registrar_evento_visitado", "evt_1")
	_check("evento_ya_visitado(evt_1)", bool(CAL.call("evento_ya_visitado", "evt_1")))
	_check("evento_ya_visitado(evt_2)", bool(CAL.call("evento_ya_visitado", "evt_2")))
	_check("evento_ya_visitado(evt_3) false", not bool(CAL.call("evento_ya_visitado", "evt_3")))
	var guardado: Dictionary = CAL.call("get_save_data")
	var lista: Array = guardado.get("eventos_visitados", [])
	_check("sin duplicados (2 eventos)", lista.size() == 2, str(lista))
	# Round-trip en una instancia nueva.
	var cal2 = TIME_SCRIPT.new()
	cal2.call("_cargar_configuracion")
	cal2.call("restore_save_data", guardado)
	_check("round-trip: evt_1 restaurado", bool(cal2.call("evento_ya_visitado", "evt_1")))
	_check("round-trip: evt_2 restaurado", bool(cal2.call("evento_ya_visitado", "evt_2")))
	_check("round-trip: evt_3 sigue sin visitar", not bool(cal2.call("evento_ya_visitado", "evt_3")))
	_check("round-trip: section_name estable", String(cal2.call("get_section_name")) == "time_calendar")
	cal2.free()
	_fin("G. persistencia")


## ── H. Formato + conversion ──────────────────────────────

func _bloque_h_formato() -> void:
	_ini("H. Formato + conversion")
	_check("formatear_hora(14,30) == '14:30' (24h)", String(CAL.call("formatear_hora", 14, 30)) == "14:30",
		String(CAL.call("formatear_hora", 14, 30)))
	_check("formatear_hora(0,5) == '00:05'", String(CAL.call("formatear_hora", 0, 5)) == "00:05")
	_check("formatear_hora(14,30,true) sigue 24h", String(CAL.call("formatear_hora", 14, 30, true)) == "14:30")
	var cfg = CAL.call("get_config")
	var prev: bool = bool(cfg.get("usar_formato_12h"))
	cfg.set("usar_formato_12h", true)
	_check("12h: 14:30 -> '02:30 PM'", String(CAL.call("formatear_hora", 14, 30)) == "02:30 PM",
		String(CAL.call("formatear_hora", 14, 30)))
	_check("12h: 00:00 -> '12:00 AM'", String(CAL.call("formatear_hora", 0, 0)) == "12:00 AM",
		String(CAL.call("formatear_hora", 0, 0)))
	_check("12h: forzar_24h sigue '14:30'", String(CAL.call("formatear_hora", 14, 30, true)) == "14:30")
	cfg.set("usar_formato_12h", prev)
	_check("fecha_a_dia_anio(1,1) == 1", int(CAL.call("fecha_a_dia_anio", 1, 1)) == 1)
	_check("fecha_a_dia_anio(1,3) == 57", int(CAL.call("fecha_a_dia_anio", 1, 3)) == 57,
		str(CAL.call("fecha_a_dia_anio", 1, 3)))
	_check("fecha_a_dia_anio(28,12) == 336", int(CAL.call("fecha_a_dia_anio", 28, 12)) == 336)
	var f1: Dictionary = CAL.call("dia_anio_a_fecha", 1)
	_check("dia_anio_a_fecha(1) == dia1/mes1", int(f1.get("dia")) == 1 and int(f1.get("mes")) == 1)
	var f57: Dictionary = CAL.call("dia_anio_a_fecha", 57)
	_check("dia_anio_a_fecha(57) == dia1/mes3", int(f57.get("dia")) == 1 and int(f57.get("mes")) == 3)
	_check("round-trip: 57 -> (1,3) -> 57", int(CAL.call("fecha_a_dia_anio", 1, 3)) == 57)
	_check("nombre_estacion(0) == 'Primavera'", String(CAL.call("get_nombre_estacion", 0)) == "Primavera")
	_check("nombre_dia(0) == 'Lunes'", String(CAL.call("get_nombre_dia", 0)) == "Lunes")
	_check("nombre_mes(1) == 'Floracion'", String(CAL.call("get_nombre_mes", 1)) == "Floración")
	_fin("H. formato")
