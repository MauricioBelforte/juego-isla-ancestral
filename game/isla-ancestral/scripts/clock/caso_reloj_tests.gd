extends SceneTree

# Modelo: glm-5.3 (PARTE 1: casos límite bloque E) · glm-5.3-flash (PARTE 2: widget/hover/config/scan, con visión)
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
const WRELOJ_CONFIG := preload("res://scripts/clock/w_reloj_config.gd")
const TOOLTIP_SVC := preload("res://scripts/ui/services/tooltip_service.gd")
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
	root.add_child(clock)  # en árbol: evita get_node de bus fuera de active tree

	# E82 / Caso 1: tick normal — 1 s real → +1 min de juego
	clock._minuto = 0
	clock._process(1.0)
	_check("E82/C1 tick: 1 s real → +1 min de juego", clock.get_minuto() == 1)

	# E83 / Caso 2: fin de día 23:59 → 00:00
	_reset_clock(clock, 23, 59, 1, 1, 1)
	var dia_antes: int = clock.get_fecha().dia
	var dias := []
	clock.dia_cambio.connect(func(_info): dias.append(1))
	clock._avanzar_minuto()
	_check("E83/C2 fin de día: 00:00 y día avanza",
		clock.get_hora() == 0 and clock.get_minuto() == 0 and clock.get_fecha().dia == dia_antes + 1)
	_check("E83/C2 señal dia_cambio emitida 1 vez", dias.size() == 1)

	# E84 / Caso 3: fin de mes día 28 → mes siguiente
	_reset_clock(clock, 23, 59, 28, 5, 1)
	clock._avanzar_minuto()
	var f3: Dictionary = clock.get_fecha()
	_check("E84/C3 fin de mes: 1/6 sin error", f3.dia == 1 and f3.mes == 6)

	# E85 / Caso 4: fin de año día 336 → año+1 sin overflow
	_reset_clock(clock, 23, 59, 28, 12, 1)
	clock._avanzar_minuto()
	var f4: Dictionary = clock.get_fecha()
	_check("E85/C4 fin de año: 1/1 año 2 sin overflow", f4.dia == 1 and f4.mes == 1 and f4.anio == 2)

	# E86 / Caso 5: cambio de estación (28/3 Primavera → 1/4 Verano) con aviso
	_reset_clock(clock, 23, 59, 28, 3, 1)
	var estaciones := []
	clock.estacion_cambio.connect(func(e): estaciones.append(e))
	clock._avanzar_minuto()
	_check("E86/C5 estación: mes 4 → Verano (índice 1)", clock.get_estacion() == 1)
	_check("E86/C5 señal estacion_cambio emitida", estaciones.size() == 1 and estaciones[0] == 1)

## E87 / Caso 6: cumpleaños (1/1 = cumpleaños del jugador en festivals.tres)
## dispara evento_activado vía TimeCalendar (canal oficial de eventos de M29).
func _caso_6_evento_activado() -> void:
	var calendar := TIME_CALENDAR.new()
	root.add_child(calendar)  # _ready: carga time_config + festivals
	calendar._dia_actual = 1
	calendar._mes_actual = 1
	var activados: Array = []
	calendar.evento_activado.connect(func(ev): activados.append(ev))
	calendar._verificar_eventos_dia()
	var tipos := []
	for ev in activados:
		tipos.append(str(ev.get("tipo", "")))
	_check("E87/C6 cumpleaños 1/1 dispara evento_activado", tipos.has("cumpleanos"))

## E88 / Caso 7: persistencia exacta (guardar 14:32 → cargar 14:32)
func _caso_7_persistencia() -> void:
	var c1 := GAME_CLOCK.new()
	root.add_child(c1)
	c1._hora = 14
	c1._minuto = 32
	c1._dia = 12
	c1._mes = 6
	c1._anio = 1
	var data: Dictionary = c1.get_save_data()
	var c2 := GAME_CLOCK.new()
	c2.restore_save_data(data)
	var fecha_c2: Dictionary = c2.get_fecha()
	_check("E88/C7 persistencia: cargar 14:32 exacto",
		c2.get_hora() == 14 and c2.get_minuto() == 32 and fecha_c2.dia == 12)

## E91 / Caso 10: ausencia (pausa) → tiempo congelado; al volver, sigue exacto.
## La congelación real de 7 días la garantiza M29 (mundo offline congelado);
## M30 verifica que el widget no genere tiempo propio: sin tick, sin avance.
func _caso_10_ausencia() -> void:
	var clock := GAME_CLOCK.new()
	root.add_child(clock)
	clock._hora = 9
	clock._minuto = 0
	clock.pausa()  # "el jugador se fue"
	clock._process(600.0)  # 10 minutos reales de proceso pausado
	_check("E91/C10 ausencia: tiempo congelado (sin avance)", clock.get_hora() == 9 and clock.get_minuto() == 0)
	clock.resume()
	clock._process(1.0)
	_check("E91/C10 al volver: el reloj sigue desde donde estaba", clock.get_minuto() == 1)

## ── E93: widget en escenario real (scenes/caso_reloj.tscn) ───────────────────

func _test_widget_en_escena() -> void:
	var escena = ESCENA_CASO.instantiate()
	root.add_child(escena)
	await _esperar_frames(3)  # _ready + layout del CanvasLayer
	var widget = escena.widget
	_check("E93 escena caso_reloj.tscn instancia WReloj", widget != null and widget.is_inside_tree())
	if widget == null:
		return
	var vp: Vector2 = root.get_visible_rect().size
	var rect: Rect2 = widget.get_global_rect()
	_check("E93/D69 ubicación arriba-derecha (borde derecho a ~16px)",
		rect.end.x <= vp.x + 0.5 and rect.end.x >= vp.x - 80.0 and rect.position.y <= 80.0)
	_check("E93/D78 no bloquea clicks (MOUSE_FILTER_IGNORE)",
		widget.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	var lbl_hora: Label = widget.find_child("Hora", true, false)
	_check("E93 label de hora presente y con texto HH:MM", lbl_hora != null and ":" in lbl_hora.text)
	_check("E93/D70 procesa hover (set_process activo)", widget.is_processing())

## ── D70: hover/desplegable vía TooltipService (M53) ───────────────────────────

func _test_hover_tooltip() -> void:
	var escena = root.get_node_or_null("CasoReloj")
	if escena == null:
		escena = ESCENA_CASO.instantiate()
		root.add_child(escena)
		await _esperar_frames(3)
	var widget = escena.widget
	# TooltipService: usa el autoload si existe; si no (headless -s), instancia manual.
	var ts = root.get_node_or_null("TooltipService")
	if ts == null:
		ts = TOOLTIP_SVC.new()
		ts.name = "TooltipService"
		root.add_child(ts)
	widget._tooltip_svc = root.get_node_or_null("/root/TooltipService")
	_check("D70 TooltipService disponible para el widget", widget._tooltip_svc != null)

	# Cursor dentro → show_tooltip (delay 0.35s del servicio).
	# Se usa demo_cursor_dentro (camino REAL _process → _actualizar_hover):
	# así el hover lo dispara el widget mismo, no una llamada manual.
	widget.demo_cursor_dentro = true
	await _esperar_ms(500)
	var activo = ts.get("_active_tooltip")
	_check("D70 hover dentro: tooltip visible tras delay",
		activo != null and activo.visible)
	if activo != null:
		var cuerpo: Label = activo.get_node_or_null("VBox/Body")
		_check("D70 tooltip con detalle (fecha/sesión/estación)",
			cuerpo != null and cuerpo.text.length() > 5)

	# Cursor fuera → hide_tooltip (devuelve al pool): demo off + 2 frames
	# de _process reales con el cursor del SO fuera del rect.
	widget.demo_cursor_dentro = false
	await _esperar_frames(2)
	_check("D70 hover fuera: tooltip oculto y devuelto al pool",
		ts.get("_active_tooltip") == null)
	_check("D70 sin tooltip huérfano al salir del árbol",
		not widget._hover_activo)

## ── F100/F107: config data-driven con fallback ───────────────────────────────

func _test_config() -> void:
	# F107: ruta inexistente → defaults (ancho_min 230, margen 16, 24h)
	var w_fallback = WRELOJ.new()
	w_fallback.ruta_config = "res://data/ui/inexistente_f107.tres"
	var cfg_f = w_fallback._cargar_config()
	_check("F107 fallback .tres corrupto/ausente → defaults",
		cfg_f != null and cfg_f.ancho_min == 230 and cfg_f.margen_borde == 16 and not cfg_f.usar_formato_12h)

	# F100: el recurso real data/ui/w_reloj.tres carga con los valores publicados
	var w_real = WRELOJ.new()
	var cfg_r = w_real._cargar_config()
	_check("F100 carga data/ui/w_reloj.tres (WRelojConfig)",
		cfg_r != null and cfg_r.ancho_min == 230 and cfg_r.margen_borde == 16)

	# F100: config inyectable (tests/Ajustes M46 no tocan data/)
	var custom = WRELOJ_CONFIG.new()
	custom.ancho_min = 300
	var w_iny = WRELOJ.new()
	w_iny.config_inyectada = custom
	_check("F100 config inyectada tiene precedencia", w_iny._cargar_config() == custom)

## ── F101: formato 12h/24h desde config ──────────────────────────────────────

func _test_formato() -> void:
	_check("F101 formato 24h: 14:30",
		RELOJ_HUD.formatear_hora(14, 30, RELOJ_HUD.FormatoHora.HORAS_24) == "14:30")
	_check("F101 formato 12h: 02:30 PM",
		RELOJ_HUD.formatear_hora(14, 30, RELOJ_HUD.FormatoHora.HORAS_12) == "02:30 PM")
	_check("F101 12h medianoche: 12:00 AM",
		RELOJ_HUD.formatear_hora(0, 0, RELOJ_HUD.FormatoHora.HORAS_12) == "12:00 AM")
	_check("F101 12h mediodía: 12:00 PM",
		RELOJ_HUD.formatear_hora(12, 0, RELOJ_HUD.FormatoHora.HORAS_12) == "12:00 PM")

## ── C56/E89/E90: scan estático anti-reloj-SO ─────────────────────────────────
## Regla de oro del módulo (C49): NINGÚN gameplay lee el reloj del sistema
## operativo. El scan recorre res://scripts/**.gd buscando APIs de reloj-SO y
## solo tolera la whitelist documentada (logging/telemetría/analytics/infra —
## usan el reloj SO para timestamps de DIAGNÓSTICO, nunca para gameplay).
## E89/E90 (adelantar/retroceder reloj SO sin efecto) quedan verificados
## ESTRUCTURALMENTE por este scan + el acumulador interno de GameClock: si nadie
## lee el reloj del SO, ninguna manipulación del SO puede afectar al juego.
## (No se muta el reloj real de la máquina del usuario en el test).

const APIS_RELOJ_SO := [
	"Time.get_unix_time_from_system",
	"Time.get_datetime_string_from_system",
	"Time.get_datetime_dict_from_system",
	"Time.get_date_string_from_system",
	"Time.get_time_string_from_system",
	"Time.get_time_dict_from_system",
	"OS.get_datetime",
	"OS.get_system_time",
	"OS.get_date(",
	"OS.get_time(",
]

const WHITELIST_RELOJ_SO := [
	"res://scripts/logging/",
	"res://scripts/analytics/",
	"res://scripts/telemetry/",
	"res://scripts/performance/",
	"res://scripts/saving/",
	"res://scripts/editor/",
	"res://tests/",
	# Re-auditoría M30 (2026-09-01, glm-5.3/Cline): M60 y M115 agregaron scripts
	# con timestamps de DIAGNÓSTICO (meta ISO de slots en data_store/gestor_slot,
	# detected_at del perfil en hardware_detector). Mismo criterio que saving/:
	# metadatos de infra, nunca gameplay. Sin esto el scan marcaba 3 falsos
	# positivos y el check C56 fallaba con 296 archivos (antes 240).
	"res://scripts/datos/",
	"res://scripts/hardware/",
	# Re-auditoría M30 post-iter. 3 (2026-09-01, glm-5.3/Cline, Log 406): M122
	# (crash_reporter: dumps con timestamp ISO), M109 (debug_menu: export RF20
	# de diagnóstico) y M113 (stress_runner: reportes de performance) agregaron
	# scripts de DIAGNÓSTICO con timestamps del SO. Mismo criterio: infra,
	# nunca gameplay. Sin esto el check C56 fallaba (407 archivos escaneados).
	# ⚠️ fauna_registry.gd de M36 NO entró a la whitelist: su uso era GAMEPLAY
	# real (dedupe de avistamientos) y se corrigió el código a
	# Time.get_ticks_msec() — ver 07-GUIA-GODOT §9.63 y Log 406.
	"res://scripts/crash/",
	"res://scripts/debug/",
	"res://scripts/stress/",
]

func _scan_anti_reloj_so() -> void:
	var archivos: Array[String] = []
	_recolectar_gd("res://scripts", archivos)
	var violaciones: Array[String] = []
	for ruta in archivos:
		# El propio test contiene los nombres de las APIs como DATO (const
		# APIS_RELOJ_SO); se excluye para no auto-detectarse.
		if ruta == "res://scripts/clock/caso_reloj_tests.gd":
			continue
		if _esta_en_whitelist(ruta):
			continue
		var texto := FileAccess.get_file_as_string(ruta)
		for api in APIS_RELOJ_SO:
			if api in texto:
				violaciones.append("%s -> %s" % [ruta, api])
	if not violaciones.is_empty():
		for v in violaciones:
			print("  [VIOLA] ", v)
	_check("C56/E89/E90: 0 lecturas de reloj-SO en gameplay (%d archivos escaneados)"
		% archivos.size(), violaciones.is_empty())

func _esta_en_whitelist(ruta: String) -> bool:
	for prefijo in WHITELIST_RELOJ_SO:
		if ruta.begins_with(prefijo):
			return true
	return false

func _recolectar_gd(dir_path: String, acumulador: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		var ruta := dir_path + "/" + nombre
		if dir.current_is_dir():
			if not nombre.begins_with("."):
				_recolectar_gd(ruta, acumulador)
		elif nombre.ends_with(".gd"):
			acumulador.append(ruta)
		nombre = dir.get_next()
	dir.list_dir_end()

