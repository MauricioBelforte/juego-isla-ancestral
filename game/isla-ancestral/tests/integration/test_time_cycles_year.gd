# Modelo: DS-V4.1-Flash-Opencode
# Plataforma: OpenCode
# Fecha: 2026-10-16
#
# M112/M29 — Test headless de CICLOS DÍA→AÑO (cierre cruzado H123 de M29).
#
# Verifica el ciclo anual completo del GameClock (M29) sin depender del reloj real:
#   A. Año 1 completo       335 pasos 1/1/1 -> 12/28/1, invariantes por paso
#   B. Transición de año    12/28/1 -> 1/1/2 limpia (sin bug de año nuevo)
#   C. Año 2 completo       336 pasos 1/1/2 -> 1/1/3, invariantes por paso
#   D. Estaciones           8 transiciones en 2 años, secuencia 1-2-3-0 sin saltos
#   E. Día del año          fecha_a_dia_anio/dia_anio_a_fecha round-trip (CAL)
#   F. Persistencia         save/restore a mitad del ciclo conserva fecha/estación
#   G. Integridad final     emisiones dia_cambio == dia_absoluto-1 (672 en 2 años)
#
# ⚠️ Guardia anti-falso-verde (3 capas, trampas 11/63/122):
#   1) cada bloque cierra con `_fin(letra)`; si aborta en silencio (M124) la letra
#      falta y `_summary()` FALLA;
#   2) piso `CHECKS_MINIMOS` MEDIDO en verde: un aborto parcial baja el conteo;
#   3) `_summary()` en un `call_deferred` SEPARADO (si `_run()` aborta, igual corre).
#   Watchdog por temporizador: si la suite no termina, cierra con codigo 1.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://tests/integration/test_time_cycles_year.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso de checks MEDIDO en verde (no estimado): un aborto parcial baja el conteo.
const CHECKS_MINIMOS := 39
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G"]

const CLOCK := preload("res://scripts/time/game_clock.gd")
const TIME_SCRIPT := preload("res://scripts/time/time_calendar.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0

var _emis_dia: int = 0
var _emis_estacion: int = 0
var _secuencia_estaciones: Array[int] = []
var _ultima_info: Dictionary = {}
var C: Node = null
var CAL: Node = null


func _init() -> void:
	call_deferred("_run")
	# `_summary()` en la cola diferida: si `_run()` muere por un SCRIPT ERROR,
	# la cola sigue y el resumen CORRE igual (nombra los bloques faltantes).
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== [M112/M29] Ciclos día→año (cierre H123) ===")
	C = CLOCK.new()
	C.dia_cambio.connect(_on_dia)
	C.estacion_cambio.connect(_on_estacion)
	# Invariante base al estado inicial: estación cacheada coherente con el mes.
	C.set("_estado_estacion", int(C.call("get_estacion")))
	_bloque_a_anio_1()
	_bloque_b_transicion_anio()
	_bloque_c_anio_2()
	_bloque_d_estaciones()
	_bloque_e_dia_del_anio()
	_bloque_f_persistencia()
	_bloque_g_integridad()
	if CAL != null:
		CAL.free()
		CAL = null
	if C != null:
		C.free()
		C = null


func _on_watchdog() -> void:
	_abortado = true
	print("[M112-i] WATCHDOG: la suite no termino en %.0f s — ABORTO (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
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


func _on_dia(info: Dictionary) -> void:
	_emis_dia += 1
	_ultima_info = info


func _on_estacion(est: int) -> void:
	_emis_estacion += 1
	_secuencia_estaciones.append(est)


## Devuelve "" si el estado del reloj es coherente, o el detalle del primer fallo.
func _invariante(paso: int) -> String:
	var f: Dictionary = C.call("get_fecha")
	var d: int = int(f.get("dia"))
	var m: int = int(f.get("mes"))
	var a: int = int(f.get("anio"))
	if d < 1 or d > 28:
		return "paso %d: dia fuera de 1..28 (dia=%d)" % [paso, d]
	if m < 1 or m > 12:
		return "paso %d: mes fuera de 1..12 (mes=%d)" % [paso, m]
	var est_esperada: int = int(CLOCK.ESTACION_POR_MES[m - 1])
	var est: int = int(C.call("get_estacion"))
	if est != est_esperada:
		return "paso %d: estacion %d != %d para mes %d" % [paso, est, est_esperada, m]
	var abs_esperado: int = (a - 1) * 336 + (m - 1) * 28 + d
	var abs_act: int = int(C.call("dia_absoluto"))
	if abs_act != abs_esperado:
		return "paso %d: dia_absoluto %d != %d" % [paso, abs_act, abs_esperado]
	var sem_esperada: int = ((m - 1) * 28 + d - 1) % 7
	var sem: int = int(C.call("get_semana_dia"))
	if sem != sem_esperada:
		return "paso %d: semana_dia %d != %d" % [paso, sem, sem_esperada]
	return ""


func _summary() -> void:
	# Capa 1: bloques que no cerraron (aborto silencioso M124).
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("los 7 bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	# Capa 2: piso de checks medido en verde.
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== TEST CICLOS DÍA→AÑO: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M112 ciclos ABORTADO por watchdog")
		quit(1)
	elif _fallos == 0:
		print("TEST M112 ciclos OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M112 ciclos FALLO — %d checks fallaron" % _fallos)
		quit(1)


## ── A. Año 1 completo (335 pasos: día 1 -> día 336) ──────

func _bloque_a_anio_1() -> void:
	_ini("A. Año 1 completo")
	_check("estado inicial 1/1/1", C.call("get_fecha") == {"dia": 1, "mes": 1, "anio": 1},
		str(C.call("get_fecha")))
	var primer_fallo := ""
	for i in range(335):
		C.call("_nuevo_dia")
		if primer_fallo == "":
			primer_fallo = _invariante(i + 1)
	_check("335 pasos sin violaciones de invariantes (dia/mes/estacion/absoluto/semana)",
		primer_fallo == "", primer_fallo)
	_check("año 1 termina en 28/12/1 (día 336)", C.call("get_fecha") == {"dia": 28, "mes": 12, "anio": 1},
		str(C.call("get_fecha")))
	_check("dia_absoluto()==336 al cierre del año", int(C.call("dia_absoluto")) == 336)
	_check("estacion invierno (3) al cierre del año", int(C.call("get_estacion")) == 3)
	_check("335 emisiones de dia_cambio (una por día)", _emis_dia == 335, "emis=%d" % _emis_dia)
	_fin("A. año 1")


## ── B. Transición de año (día 336 -> año 2) ──────────────

func _bloque_b_transicion_anio() -> void:
	_ini("B. Transición de año")
	var emis_dia_antes: int = _emis_dia
	var emis_est_antes: int = _emis_estacion
	C.call("_nuevo_dia")
	var f: Dictionary = C.call("get_fecha")
	_check("transición limpia a 1/1/2 (sin bug de año nuevo)",
		f == {"dia": 1, "mes": 1, "anio": 2}, str(f))
	_check("dia_absoluto()==337 tras el cruce", int(C.call("dia_absoluto")) == 337)
	_check("estación vuelve a primavera (0)", int(C.call("get_estacion")) == 0)
	_check("emite dia_cambio en el cruce", _emis_dia == emis_dia_antes + 1)
	_check("emite estacion_cambio invierno→primavera en el cruce",
		_emis_estacion == emis_est_antes + 1)
	_check("info del día 1/1/2 correcta",
		_ultima_info.get("dia") == 1 and _ultima_info.get("mes") == 1
		and _ultima_info.get("anio") == 2 and _ultima_info.get("estacion") == 0
		and _ultima_info.get("semana_dia") == 0,
		str(_ultima_info))
	_fin("B. transición")


## ── C. Año 2 completo (336 pasos) ────────────────────────

func _bloque_c_anio_2() -> void:
	_ini("C. Año 2 completo")
	var primer_fallo := ""
	for i in range(335):
		C.call("_nuevo_dia")
		if primer_fallo == "":
			primer_fallo = _invariante(i + 1)
	_check("335 pasos sin violaciones de invariantes", primer_fallo == "", primer_fallo)
	_check("año 2 termina en 28/12/2 (día 672)", C.call("get_fecha") == {"dia": 28, "mes": 12, "anio": 2},
		str(C.call("get_fecha")))
	_check("dia_absoluto()==672 al cierre del año 2", int(C.call("dia_absoluto")) == 672)
	var emis_dia_antes: int = _emis_dia
	C.call("_nuevo_dia")
	_check("segundo cruce de año limpio a 1/1/3",
		C.call("get_fecha") == {"dia": 1, "mes": 1, "anio": 3}, str(C.call("get_fecha")))
	_check("emite dia_cambio en el segundo cruce", _emis_dia == emis_dia_antes + 1)
	# Hito intermedio: día 168 del año 2 = 28/6/2, absoluto 504.
	var c2 = CLOCK.new()
	c2.call("set", "_dia", 28)
	c2.call("set", "_mes", 6)
	c2.call("set", "_anio", 2)
	_check("día 168 del año 2 = 28/6/2 (mitad de año)",
		c2.call("get_fecha") == {"dia": 28, "mes": 6, "anio": 2}, str(c2.call("get_fecha")))
	_check("dia_absoluto() de la mitad del año 2 == 504", int(c2.call("dia_absoluto")) == 504)
	c2.free()
	_fin("C. año 2")


## ── D. Estaciones en 2 años ──────────────────────────────

func _bloque_d_estaciones() -> void:
	_ini("D. Estaciones")
	# 2 años: 4 transiciones por año (meses 4, 7, 10 y cruce de año).
	_check("8 transiciones de estación en 2 años", _emis_estacion == 8, "emis=%d" % _emis_estacion)
	var esperada: Array[int] = [1, 2, 3, 0, 1, 2, 3, 0]
	_check("secuencia Verano→Otoño→Invierno→Primavera ×2 sin saltos",
		_secuencia_estaciones == esperada, str(_secuencia_estaciones))
	_check("estación actual primavera (0) al inicio del año 3", int(C.call("get_estacion")) == 0)
	_check("estado interno de estación sincronizado",
		int(C.get("_estado_estacion")) == 0, "cache=%d" % int(C.get("_estado_estacion")))
	_fin("D. estaciones")


## ── E. Día del año (CAL: round-trip) ─────────────────────

func _bloque_e_dia_del_anio() -> void:
	_ini("E. Día del año")
	CAL = TIME_SCRIPT.new()
	CAL.call("_cargar_configuracion")
	_check("fecha_a_dia_anio(1,1)==1", int(CAL.call("fecha_a_dia_anio", 1, 1)) == 1)
	_check("fecha_a_dia_anio(28,12)==336", int(CAL.call("fecha_a_dia_anio", 28, 12)) == 336)
	var ok_rt := true
	var detalle := ""
	for d in [1, 28, 29, 168, 335, 336]:
		var f: Dictionary = CAL.call("dia_anio_a_fecha", d)
		var vuelta: int = int(CAL.call("fecha_a_dia_anio", int(f.get("dia")), int(f.get("mes"))))
		if vuelta != d:
			ok_rt = false
			detalle = "d=%d -> %s -> %d" % [d, str(f), vuelta]
			break
	_check("round-trip día_del_año ↔ fecha en bordes [1,28,29,168,335,336]", ok_rt, detalle)
	var f336: Dictionary = CAL.call("dia_anio_a_fecha", 336)
	_check("día 336 cae en 28/12", f336 == {"dia": 28, "mes": 12}, str(f336))
	var f337: Dictionary = CAL.call("dia_anio_a_fecha", 337)
	_check("día 337 clampa al límite del año (28/12)", f337 == {"dia": 28, "mes": 12}, str(f337))
	_fin("E. día del año")


## ── F. Persistencia a mitad del ciclo ────────────────────

func _bloque_f_persistencia() -> void:
	_ini("F. Persistencia")
	var s: Dictionary = C.call("get_save_data")
	_check("save incluye fecha y semilla", s.has("dia") and s.has("mes") and s.has("anio") and s.has("semilla_partida"))
	var c2 = CLOCK.new()
	c2.call("restore_save_data", s)
	_check("restore conserva la fecha (1/1/3)", c2.call("get_fecha") == {"dia": 1, "mes": 1, "anio": 3},
		str(c2.call("get_fecha")))
	_check("restore conserva dia_absoluto (673)", int(c2.call("dia_absoluto")) == 673)
	_check("restore conserva la estación (0)", int(c2.call("get_estacion")) == 0)
	c2.call("set", "_estado_estacion", 0)
	c2.call("_nuevo_dia")
	_check("el ciclo continúa tras el restore (2/1/3)", c2.call("get_fecha") == {"dia": 2, "mes": 1, "anio": 3},
		str(c2.call("get_fecha")))
	c2.free()
	_fin("F. persistencia")


## ── G. Integridad final ──────────────────────────────────

func _bloque_g_integridad() -> void:
	_ini("G. Integridad final")
	_check("año 3 inicia en 1/1/3", C.call("get_fecha") == {"dia": 1, "mes": 1, "anio": 3},
		str(C.call("get_fecha")))
	_check("dia_absoluto()==673 (2×336+1)", int(C.call("dia_absoluto")) == 673)
	# Integridad total: cada día transcurrido emitió exactamente una señal.
	_check("672 emisiones de dia_cambio en 2 años", _emis_dia == 672, "emis=%d" % _emis_dia)
	_check("emisiones == dia_absoluto()-1 (ningún día saltado ni duplicado)",
		_emis_dia == int(C.call("dia_absoluto")) - 1, "emis=%d abs=%d" % [_emis_dia, int(C.call("dia_absoluto"))])
	_check("semana_dia==0 al inicio de un año (336 % 7 == 0)", int(C.call("get_semana_dia")) == 0)
	_fin("G. integridad")
