extends SceneTree

# Modelo: glm-5.3
# Plataforma: Cline
# Fecha: 2026-08-31
#
# M30 (E92): Suite headless del bloque E — casos de límites de fecha (E81-E95)
# + widget en escenario (E93) + hover D70 + config F100/F107 + formato F101
# + scan anti-reloj-SO (C56/E89/E90).
#
# Ejecutar:
#   godot --headless res://scripts/clock/caso_reloj_tests.gd
# Salida: código 0 = todo OK · 1 = hubo fallos (ver print final).

const GAME_CLOCK := preload("res://scripts/time/game_clock.gd")
const TIME_CALENDAR := preload("res://scripts/time/time_calendar.gd")
const RELOJ_HUD := preload("res://scripts/clock/reloj_hud.gd")
const WRELOJ := preload("res://scripts/clock/w_reloj.gd")
const ESCENA_CASO := preload("res://scenes/caso_reloj.tscn")

var _fallos := 0
var _checks := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	print("=== TEST CASO RELOJ M30 (bloque E + D70 + F + C56) ===")
	_casos_limites_gameclock()
	_caso_6_evento_activado()
	_caso_7_persistencia()
	_caso_10_ausencia()
	await _test_widget_en_escena()
	await _test_hover_tooltip()
	await _test_config()
	await _test_formato()
	_scan_anti_reloj_so()
	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(nombre: String, ok: bool) -> void:
	_checks += 1
	if ok:
		print("  [OK] ", nombre)
	else:
		_fallos += 1
		print("  [FALLO] ", nombre)

func _esperar_frames(n: int) -> void:
	for i in range(n):
		await process_frame

func _esperar_ms(ms: int) -> void:
	await create_timer(ms / 1000.0).timeout

## ── Bloque E: casos de límites sobre GameClock (M29) ─────────────────────────

func _reset_clock(clock: Node, hora: int, minuto: int, dia: int, mes: int, anio: int) -> void:
	clock._hora = hora
	clock._minuto = minuto
	clock._dia = dia
	clock._mes = mes
	clock._anio = anio
	clock._estado_estacion = clock.get_estacion()

func _casos_limites_gameclock() -> void:
	var clock := GAME_CLOCK.new()

	# E82 / Caso 1: tick normal — 1 s real → +1 min de juego
	clock._minuto = 0
	clock._process(1.0)
	_check("E82/C1 tick: 1 s real → +1 min de juego", clock.get_minuto() == 1)

	# E83 / Caso 2: fin de día 23:59 → 00:00
	_reset_clock(clock, 23, 59, 1, 1, 1)
	var dia_antes := clock.get_fecha().dia
	var dias := []
	clock.dia_cambio.connect(func(_info): dias.append(1))
	clock._avanzar_minuto()
	_check("E83/C2 fin de día: 00:00 y día avanza",
		clock.get_hora() == 0 and clock.get_minuto() == 0 and clock.get_fecha().dia == dia_antes + 1)
	_check("E83/C2 señal dia_cambio emitida 1 vez", dias.size() == 1)

	# E84 / Caso 3: fin de mes día 28 → mes siguiente
	_reset_clock(clock, 23, 59, 28, 5, 1)
	clock._avanzar_minuto()
	var f3 := clock.get_fecha()
	_check("E84/C3 fin de mes: 1/6 sin error", f3.dia == 1 and f3.mes == 6)

	# E85 / Caso 4: fin de año día 336 → año+1 sin overflow
	_reset_clock(clock, 23, 59, 28, 12, 1)
	clock._avanzar_minuto()
	var f4 := clock.get_fecha()
	_check("E85/C4 fin de año: 1/1 año 2 sin overflow", f4.dia == 1 and f4.mes == 1 and f4.anio == 2)

	# E86 / Caso 5: cambio de estación (28/3 Primavera → 1/4 Verano) con aviso
	_reset_clock(clock, 23, 59, 28, 3, 1)
	var estaciones := []
	clock.estacion_cambio.connect(func(e): estaciones.append(e))
	clock._avanzar_minuto()
	_check("E86/C5 estación: mes 4 → Verano (índice 1)", clock.get_estacion() == 1)
	_check("E86/C5 señal estacion_cambio emitida", estaciones.size() == 1 and estaciones[0] == 1)

# === PARTE 2 ===
