# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M29 — Test headless de integracion: Tiempo + Calendario + Eventos/Festivales.
#
#   A. Estado inicial           hora/estacion/fecha validas y coherentes
#   B. Dia/noche                es_de_dia()/es_noche() complementarios
#   C. Pausa/reanudar           pausa()/resume() sin GameClock no alteran el cache
#   D. Save/restore temporal    round-trip de eventos visitados entre instancias
#   E. Semana + dia absoluto    semana_dia 0..6, dia_absoluto >= 1 y coherente
#   F. Fecha completa           get_section_name + get_fecha + formatear_fecha_completa
#   G. Eventos                  obtener_eventos_hoy / hay_evento_hoy / festival
#   H. Eventos + persistencia   registrar evento -> save -> restore
#
# ⚠️ Guardia anti-falso-verde (3 capas, trampas 11/63/122):
#   1) cada bloque cierra con `_fin(letra)`; si aborta en silencio (M124) la letra
#      falta y `_summary()` FALLA;
#   2) piso `CHECKS_MINIMOS` MEDIDO en verde: un aborto parcial baja el conteo;
#   3) `_summary()` en un `call_deferred` SEPARADO (si `_run()` aborta, igual corre).
#   Watchdog por temporizador: si la suite no termina, cierra con codigo 1.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://tests/integration/test_time_calendar_events.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso de checks MEDIDO en verde (no estimado): un aborto parcial baja el conteo.
const CHECKS_MINIMOS := 51
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
	print("=== [M29] Integracion Tiempo + Calendario + Eventos ===")
	CAL = TIME_SCRIPT.new()
	CAL.call("_cargar_configuracion")
	_bloque_a_estado_inicial()
	_bloque_b_dia_noche()
	_bloque_c_pausa()
	_bloque_d_save_restore()
	_bloque_e_semana_dia_absoluto()
	_bloque_f_fecha_completa()
	_bloque_g_eventos()
	_bloque_h_eventos_persistencia()
	if CAL != null:
		CAL.free()
		CAL = null


func _on_watchdog() -> void:
	_abortado = true
	print("[M29-i] WATCHDOG: la suite no termino en %.0f s — ABORTO (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
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
	print("\n=== Resumen M29 eventos: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M29 eventos ABORTADO por watchdog")
		quit(1)
	elif _fallos == 0:
		print("TEST M29 eventos OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M29 eventos FALLO — %d checks fallaron" % _fallos)
		quit(1)


## ── A. Estado inicial ────────────────────────────────────

func _bloque_a_estado_inicial() -> void:
	_ini("A. Estado inicial")
	var h: int = int(CAL.call("get_hora"))
	var e: int = int(CAL.call("get_estacion"))
	_check("hora 0..23", h >= 0 and h <= 23, "h=%d" % h)
	_check("estacion 0..3", e >= 0 and e <= 3, "e=%d" % e)
	var f: Dictionary = CAL.call("get_fecha")
	_check("fecha dia >= 1", int(f.get("dia", 0)) >= 1)
	_check("fecha mes 1..12", int(f.get("mes", 0)) >= 1 and int(f.get("mes", 0)) <= 12)
	_check("fecha anio >= 1", int(f.get("anio", 0)) >= 1)
	_check("hora == _hora_actual", h == int(CAL.get("_hora_actual")))
	_check("estacion == _estacion_actual", e == int(CAL.get("_estacion_actual")))
	_fin("A. estado inicial")


## ── B. Dia/noche complementarios ─────────────────────────

func _bloque_b_dia_noche() -> void:
	_ini("B. Dia/noche complementarios")
	for h in [5, 8, 14, 20, 23]:
		CAL.set("_hora_actual", h)
		var dia: bool = bool(CAL.call("es_de_dia"))
		var noche: bool = bool(CAL.call("es_noche"))
		_check("h=%d: es_noche == not es_de_dia" % h, noche == (not dia))
		_check("h=%d: exactamente uno es true" % h, dia != noche)
	CAL.set("_hora_actual", 8)
	_fin("B. dia/noche")


## ── C. Pausa/reanudar ────────────────────────────────────

func _bloque_c_pausa() -> void:
	_ini("C. Pausa/reanudar")
	CAL.set("_game_clock", null)
	CAL.call("pausa")
	CAL.call("resume")
	_check("pausa/resume no alteran el cache", int(CAL.call("get_hora")) == 8,
		"h=%d" % int(CAL.call("get_hora")))
	_check("get_minuto() sigue int", typeof(CAL.call("get_minuto")) == TYPE_INT)
	_fin("C. pausa")


## ── D. Save/restore temporal ─────────────────────────────

func _bloque_d_save_restore() -> void:
	_ini("D. Save/restore temporal")
	CAL.call("registrar_evento_visitado", "evt_alfa")
	CAL.call("registrar_evento_visitado", "evt_beta")
	var saved: Dictionary = CAL.call("get_save_data")
	_check("save trae eventos_visitados", saved.has("eventos_visitados"))
	var nueva = TIME_SCRIPT.new()
	nueva.call("_cargar_configuracion")
	nueva.call("restore_save_data", saved)
	_check("nueva instancia no nula", nueva != null)
	_check("restore: evt_alfa visitado", bool(nueva.call("evento_ya_visitado", "evt_alfa")))
	_check("restore: evt_beta visitado", bool(nueva.call("evento_ya_visitado", "evt_beta")))
	_check("restore: evt_gamma NO visitado", not bool(nueva.call("evento_ya_visitado", "evt_gamma")))
	_check("restore: 2 eventos (sin duplicados)",
		(nueva.call("get_save_data").get("eventos_visitados", []) as Array).size() == 2)
	nueva.free()
	_fin("D. save/restore")


## ── E. Semana + dia absoluto ─────────────────────────────

func _bloque_e_semana_dia_absoluto() -> void:
	_ini("E. Semana + dia absoluto")
	var sd: int = int(CAL.call("get_semana_dia"))
	var da: int = int(CAL.call("get_dia_absoluto"))
	_check("semana_dia 0..6", sd >= 0 and sd <= 6, "sd=%d" % sd)
	_check("dia_absoluto >= 1", da >= 1, "da=%d" % da)
	# Coherencia con la fecha (sin GameClock, el cache se mantiene).
	var f: Dictionary = CAL.call("get_fecha")
	var esperado: int = (int(f.get("anio")) - 1) * 336 + (int(f.get("mes")) - 1) * 28 + int(f.get("dia"))
	_check("dia_absoluto coherente con la fecha", da == esperado, "da=%d esperado=%d" % [da, esperado])
	_check("es_fin_de_semana() coherente con semana_dia", bool(CAL.call("es_fin_de_semana")) == (sd >= 5))
	_fin("E. semana/dia")


## ── F. Fecha completa ────────────────────────────────────

func _bloque_f_fecha_completa() -> void:
	_ini("F. Fecha completa")
	_check("get_section_name() == 'time_calendar'", String(CAL.call("get_section_name")) == "time_calendar")
	var f: Dictionary = CAL.call("get_fecha")
	_check("fecha trae dia/mes/anio", f.has("dia") and f.has("mes") and f.has("anio"))
	_check("dia >= 1", int(f.get("dia")) >= 1)
	_check("mes 1..12", int(f.get("mes")) >= 1 and int(f.get("mes")) <= 12)
	var texto: String = String(CAL.call("formatear_fecha_completa"))
	_check("formatear_fecha_completa() no vacio", texto.length() > 0, texto)
	_check("formatear_fecha_completa() contiene el anio", texto.contains(str(int(f.get("anio")))), texto)
	_check("get_nombre_estacion() no vacio", String(CAL.call("get_nombre_estacion")).length() > 0)
	_check("get_nombre_mes() no vacio", String(CAL.call("get_nombre_mes")).length() > 0)
	_check("get_nombre_dia() no vacio", String(CAL.call("get_nombre_dia")).length() > 0)
	_fin("F. fecha completa")


## ── G. Eventos ───────────────────────────────────────────

func _bloque_g_eventos() -> void:
	_ini("G. Eventos")
	var hoy: Array = CAL.call("obtener_eventos_hoy")
	_check("obtener_eventos_hoy() es Array", hoy is Array)
	var hay: bool = bool(CAL.call("hay_evento_hoy"))
	_check("hay_evento_hoy() coherente con la lista", hay == (hoy.size() > 0), "n=%d" % hoy.size())
	var prox: Array = CAL.call("obtener_proximos_eventos")
	_check("obtener_proximos_eventos() es Array", prox is Array)
	_check("obtener_proximos_eventos(0) es Array", (CAL.call("obtener_proximos_eventos", 0) is Array))
	var fest_actual: Dictionary = CAL.call("obtener_festival_actual")
	_check("obtener_festival_actual() es Dictionary", fest_actual is Dictionary)
	var hay_fest: bool = bool(CAL.call("hay_festival_hoy"))
	var fest_real: bool = false
	for ev in hoy:
		if String((ev as Dictionary).get("tipo", "")) == "festival":
			fest_real = true
	_check("hay_festival_hoy() coherente con los eventos", hay_fest == fest_real)
	_check("obtener_festival_actual() vacio si no hay festival", (fest_actual.is_empty() == (not fest_real)))
	_fin("G. eventos")


## ── H. Eventos + persistencia ────────────────────────────

func _bloque_h_eventos_persistencia() -> void:
	_ini("H. Eventos + persistencia")
	var antes: Array = CAL.call("obtener_eventos_hoy")
	CAL.call("registrar_evento_visitado", "evt_hoy_1")
	_check("registrar no altera la lista de eventos de hoy",
		(CAL.call("obtener_eventos_hoy") as Array).size() == antes.size())
	_check("evento registrado queda visitado", bool(CAL.call("evento_ya_visitado", "evt_hoy_1")))
	var saved: Dictionary = CAL.call("get_save_data")
	var eventos: Array = saved.get("eventos_visitados", [])
	_check("el save incluye el evento registrado", eventos.has("evt_hoy_1"), str(eventos))
	# Round-trip completo.
	var otra = TIME_SCRIPT.new()
	otra.call("_cargar_configuracion")
	otra.call("restore_save_data", saved)
	_check("round-trip: evento recuperado", bool(otra.call("evento_ya_visitado", "evt_hoy_1")))
	_check("round-trip: obtener_eventos_hoy sigue respondiendo", (otra.call("obtener_eventos_hoy") is Array))
	otra.free()
	_fin("H. eventos+persistencia")
