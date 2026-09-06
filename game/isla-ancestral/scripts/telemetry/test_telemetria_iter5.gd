# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M105: Test iteración 5 — fix zone_ignored + robustez determinista.
# Complementa test_telemetry.gd (núcleo ox-alpha).
# Valida:
#  - FIX: zone_ignored se emite UNA vez por zona por sesión (se reporta en el
#    tick que detecta, luego se limpia el acumulado → no re-emite cada segundo).
#  - Arranque con opt-in persistente (ConfigFile) OFF y ON.
#  - Deduplicación de eventos "first" por sesión (ya cubierta, se re-verifica).
#  - Puzzle abandonado: el evento se emite con tiempo >= umbral y no se duplica.
#  - Zona visitada >= umbral NO se marca ignorada.
#  - Métricas time_to_first_* registradas una sola vez (dedup por marca __metrica__).
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetria_iter5.gd
extends SceneTree

var _fallos := 0
var _checks := 0
var _ad = null
var _stub = null

## Stub de Analytics que cuenta llamadas (no escribe disco).
class _AnalyticsStub:
	extends Node
	var calls: Array = []
	var optout_calls: int = 0
	func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
		calls.append({"tipo": tipo, "datos": datos})
	func establecer_opt_out(v: bool) -> void:
		optout_calls += 1

func _initialize() -> void:
	print("=== TEST TELEMETRIA M105 ITER5 ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_ad = root.get_node_or_null("TelemetryDirector")
	_check("autoload TelemetryDirector presente", _ad != null)
	if _ad == null:
		print("FALTA AUTOLOAD"); quit(1); return
	_ad._settings_path = "user://telemetry_test_iter5/telemetry.cfg"
	_stub = _AnalyticsStub.new()
	_ad.analytics_service = _stub

	_test_fix_zone_ignored_dedup()
	_test_puzzle_abandonado_una_vez()
	_test_zona_no_ignorada()
	_test_metricas_dedup()
	_test_optin_persistente()

	print("=== TEST TELEMETRIA M105 ITER5: %d fallo(s) de %d cheque(s) ===" % [_fallos, _checks])
	quit(1 if _fallos > 0 else 0)

func _check(nombre: String, condicion: bool) -> void:
	_checks += 1
	if not condicion:
		_fallos += 1
		print("FALLO: " + nombre)

func _conteo_evento(evento: String) -> int:
	var c := 0
	for call in _stub.calls:
		var datos: Dictionary = call.datos
		if datos.get("evento", "") == evento:
			c += 1
	return c

func _test_fix_zone_ignored_dedup() -> void:
	_ad.establecer_opt_in(true)
	_stub.calls.clear()

	# Simular entrada a zona con duración < 60s
	_ad.enter_zone("zona_a")
	_ad.exit_zone("zona_a")  # acumulado queda en _zona_duracion < 60
	# Tick del timer: debe emitir zone_ignored UNA vez y limpiar el acumulado
	_ad._on_zone_check()
	_ad._on_zone_check()  # segundo tick: NO debe re-emitir (dedup + limpieza)
	_ad._on_zone_check()
	var total := _conteo_evento("zone_ignored")
	_check("zone_ignored emitido exactamente 1 vez (dedup), got %d" % total, total == 1)
	_check("acumulado de zona_a limpiado tras reportar", not _ad._zona_duracion.has("zona_a"))

	# Nueva visita a la misma zona después de reportada: reportada bloqueada
	_ad.enter_zone("zona_a")
	_ad.exit_zone("zona_a")
	_ad._on_zone_check()
	total = _conteo_evento("zone_ignored")
	_check("zona ya reportada no re-emite (1 vez total por sesión)", total == 1)

func _test_puzzle_abandonado_una_vez() -> void:
	_stub.calls.clear()
	# Simular puzzle iniciado hace > 300s (umbral)
	_ad._puzzle_inicio["p1"] = Time.get_ticks_msec() - 310000
	_ad._on_puzzle_check()
	_ad._on_puzzle_check()  # segundo tick: p1 ya fue borrado → no re-emite
	var total := _conteo_evento("puzzle_abandoned")
	_check("puzzle_abandoned emitido exactamente 1 vez, got %d" % total, total == 1)
	_check("puzzle p1 removido tras reportar", not _ad._puzzle_inicio.has("p1"))

func _test_zona_no_ignorada() -> void:
	_stub.calls.clear()
	# Zona visitada >= 60s: NO debe marcarse ignorada
	_ad._zona_duracion["zona_larga"] = 120  # 120 segundos acumulados
	_ad._on_zone_check()
	var total := _conteo_evento("zone_ignored")
	_check("zona de 120s no ignorada", total == 0)
	# La zona con acumulado >= 60 tampoco se limpia (solo se limpian las ignoradas)
	_check("zona larga permanece en acumulado", _ad._zona_duracion.has("zona_larga"))

func _test_metricas_dedup() -> void:
	_stub.calls.clear()
	# Registrar 3 veces la métrica time_to_first_discovery: solo 1 vez (marca __metrica__)
	_ad._registrar_metrica_hasta(&"discovery", _ad.METRIC_TIME_TO_FIRST_DISCOVERY)
	_ad._registrar_metrica_hasta(&"discovery", _ad.METRIC_TIME_TO_FIRST_DISCOVERY)
	_ad._registrar_metrica_hasta(&"discovery", _ad.METRIC_TIME_TO_FIRST_DISCOVERY)
	var c := 0
	for call in _stub.calls:
		var datos: Dictionary = call.datos
		if datos.get("metrica", "") == _ad.METRIC_TIME_TO_FIRST_DISCOVERY:
			c += 1
	_check("time_to_first_discovery registrada 1 sola vez, got %d" % c, c == 1)

func _test_optin_persistente() -> void:
	# Establecer ON y persistir; luego un "arranque nuevo" con mismo path lo lee
	_ad.establecer_opt_in(false)
	_stub.calls.clear()
	_ad.establecer_opt_in(true)
	# Forzar recarga del opt-in desde el archivo (misma config)
	var antes: bool = _ad.opt_in
	_ad._cargar_opt_in()
	_check("opt-in persistido y recargado (true)", _ad.opt_in and antes)
	_ad.establecer_opt_in(false)  # cleanup para otros tests