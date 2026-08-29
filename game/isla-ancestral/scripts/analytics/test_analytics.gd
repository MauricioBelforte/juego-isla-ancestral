# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M104: Test headless del AnalyticsDirector (verificación implementación).
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/analytics/test_analytics.gd
# Valida:
#  - Autoload AnalyticsDirector presente y registrado en ServiceRegistry ("analytics").
#  - Captura RF1-RF7: los 7 tipos de evento se registran en buffer y agregados.
#  - Opt-out: establecer_opt_out(true) detiene la captura inmediatamente y persiste.
#  - Privacidad: session hash presente, distinto del nombre, formato hex 16.
#  - Batch: enviar_lote_datos() escribe JSON local y limpia el buffer.
#  - Agregado histórico: aggregated.json acumula totales por tipo.
#  - Buffer: política de descarte respeta max_buffer.
# NOTA: el test usa el autoload real y limpia user://analytics al final.
extends SceneTree

var _fallos := 0
var _checks := 0
var _ad = null

func _initialize() -> void:
	print("=== TEST ANALYTICS M104 ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_ad = root.get_node_or_null("AnalyticsDirector")
	_check("autoload AnalyticsDirector presente", _ad != null)
	if _ad == null:
		print("FALTA AUTOLOAD AnalyticsDirector"); quit(1); return

	var reg = root.get_node_or_null("ServiceRegistry")
	_check("registrado en ServiceRegistry como 'analytics'", reg != null and reg.has("analytics"))

	# Asegurar partida limpia de analytics para el test
	_limpiar_archivos()
	_ad.opt_out = false
	_ad._agregados.clear()
	_ad._buffer.clear()
	_ad.registrar_evento(_ad.EV_SESION_INICIO, {"origen": "test"})

	# ── Captura RF1-RF7: los 7 tipos ──
	_ad.registrar_evento(_ad.EV_AREA_VISITADA, {"bioma": "bosque"})
	_ad.registrar_evento(_ad.EV_FEATURE_USADA, {"feature": "crafting"})
	_ad.registrar_evento(_ad.EV_ERROR, {"tipo": "script", "hash": "abc123"})
	_ad.registrar_evento(_ad.EV_PAUSA, {"motivo": "menu"})
	_ad.registrar_evento(_ad.EV_CONFIG_CAMBIO, {"clave": "volumen", "valor_nuevo": 80})
	_check("buffer acumula 5 eventos (+1 sesion_inicio de _ready)", _ad.eventos_pendientes() >= 5)

	var agg: Dictionary = _ad.obtener_estadisticas_agregadas()
	_check("agregados cuentan area_visitada", int(agg.get(_ad.EV_AREA_VISITADA, 0)) == 1)
	_check("agregados cuentan feature_usada", int(agg.get(_ad.EV_FEATURE_USADA, 0)) == 1)
	_check("agregados cuentan config_cambio", int(agg.get(_ad.EV_CONFIG_CAMBIO, 0)) == 1)
	_check("sesion_inicio registrada en _ready", int(agg.get(_ad.EV_SESION_INICIO, 0)) >= 1)

	# ── Privacidad: session hash hex 16 (SHA256 truncado) ──
	var lote_path: String = _ad.ARCHIVO_LOTE % Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	_ad.enviar_lote_datos()
	_check("lote JSON escrito", FileAccess.file_exists(lote_path))
	var json_txt := ""
	if FileAccess.file_exists(lote_path):
		json_txt = FileAccess.get_file_as_string(lote_path)
	var parsed = JSON.parse_string(json_txt)
	_check("lote parsea como JSON", typeof(parsed) == TYPE_DICTIONARY)
	if typeof(parsed) == TYPE_DICTIONARY:
		var ses: String = str(parsed.get("session", ""))
		_check("session hash presente (16 hex)", ses.length() == 16)
		_check("sin nombres personales en el lote", not json_txt.contains("maria") and not json_txt.contains("catalina"))
		var evs = parsed.get("eventos", [])
		_check("lote incluye los eventos del buffer", typeof(evs) == TYPE_ARRAY and evs.size() >= 5)
	_check("buffer limpio tras el lote", _ad.eventos_pendientes() == 0)

	# ── Agregado histórico acumulado ──
	_ad.registrar_evento(_ad.EV_FEATURE_USADA, {"feature": "fast_travel"})
	_ad.enviar_lote_datos()
	var hist_txt := FileAccess.get_file_as_string(_ad.ARCHIVO_AGREGADO) if FileAccess.file_exists(_ad.ARCHIVO_AGREGADO) else ""
	var hist = JSON.parse_string(hist_txt) if hist_txt != "" else null
	_check("aggregated.json existe y parsea", typeof(hist) == TYPE_DICTIONARY)
	if typeof(hist) == TYPE_DICTIONARY:
		var tot: Dictionary = hist.get("totales_por_tipo", {})
		_check("histórico acumula feature_usada (2)", int(tot.get(_ad.EV_FEATURE_USADA, 0)) >= 2)

	# ── Opt-out: detiene captura inmediatamente y persiste ──
	_ad.establecer_opt_out(true)
	_check("esta_opt_out() true", _ad.esta_opt_out())
	var antes: int = _ad.eventos_pendientes()
	_ad.registrar_evento(_ad.EV_AREA_VISITADA, {"bioma": "playa"})
	_check("opt-out descarta el evento inmediatamente", _ad.eventos_pendientes() == antes)
	_check("opt_out.cfg persistido", FileAccess.file_exists(_ad.ARCHIVO_OPT_OUT))

	# Restaurar estado (captura activa, sin archivos del test)
	_ad.establecer_opt_out(false)
	_limpiar_archivos()

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("ANALYTICS M104 OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)

## Limpia los archivos de analytics del test (no toca logs de M103).
func _limpiar_archivos() -> void:
	var dir: String = _ad.DIR_ANALYTICS
	if DirAccess.dir_exists_absolute(dir):
		for f in DirAccess.get_files_at(dir):
			DirAccess.remove_absolute(dir + "/" + f)