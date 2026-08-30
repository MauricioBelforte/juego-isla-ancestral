# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# M105: Test headless del TelemetryDirector (verificación implementación).
# Uso: godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetry.gd
# Valida:
#  - Autoload TelemetryDirector presente y registrado en ServiceRegistry ("telemetry").
#  - Opt-in OFF por defecto (GDPR) y persistente (ConfigFile).
#  - Opt-in ON activa captura y registra sesión en M104 (stub inyectado).
#  - Los 11 eventos "first" enviados a M104 como tipo "telemetry".
#  - Métrica time_to_first_travel registrada.
#  - Deduplicación de eventos "first" por sesión.
#  - Detección de abandono de puzzle (umbral 300s, simulada).
#  - Entrada/salida de zona + zona ignorada (< 60s).
#  - difficulty_perceived con rating.
#  - Opt-out propagado a M104 y filtrado en caliente.
# NOTA: analytics_service se inyecta como stub (no toca disco de M104);
#       settings aislados en user://telemetry_test/ y limpiados al final.
extends SceneTree

var _fallos := 0
var _checks := 0
var _ad = null
var _stub = null

## Stub de Analytics que cuenta llamadas (no escribe disco). Extiende Node
## para satisfacer el tipado de TelemetryDirector.analytics_service.
class _AnalyticsStub:
	extends Node
	var calls: Array = []
	var optout_calls: int = 0
	func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
		calls.append({"tipo": tipo, "datos": datos})
	func establecer_opt_out(v: bool) -> void:
		optout_calls += 1

func _initialize() -> void:
	print("=== TEST TELEMETRIA M105 ===")
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_ad = root.get_node_or_null("TelemetryDirector")
	_check("autoload TelemetryDirector presente", _ad != null)
	if _ad == null:
		print("FALTA AUTOLOAD TelemetryDirector"); quit(1); return

	var sr = root.get_node_or_null("ServiceRegistry")
	_check("ServiceRegistry registra 'telemetry'",
		sr != null and sr.has_method("has") and sr.has("telemetry"))

	# Aislar settings del test (no tocar user://settings real).
	_ad._settings_path = "user://telemetry_test/telemetry.cfg"

	# Stub analytics (no escribe JSON real; no necesita estar en el árbol).
	_stub = _AnalyticsStub.new()
	_ad.analytics_service = _stub

	_check("opt-in OFF por defecto (GDPR)", not _ad.opt_in)

	# ── Activación ──
	_ad.establecer_opt_in(true)
	_check("opt-in ON despues de establecer true", _ad.opt_in)
	_check("settings persistidos en path test", FileAccess.file_exists(_ad._settings_path))
	var tiene_session := false
	for c in _stub.calls:
		if c["datos"].has("evento") and c["datos"]["evento"] == "gameplay_session_start":
			tiene_session = true
	_check("sesión de gameplay enviada a M104 tras opt-in", tiene_session)

	_stub.calls.clear()
	# ── Eventos "first" (RF1-RF11) ──
	_ad.track_tutorial_first_completed()
	_ad.track_resource_first_collected("madera")
	_ad.track_house_first_built()
	_ad.track_npc_first_interaction("npc_01")
	_ad.track_puzzle_first_completed("puzzle_01")
	_ad.track_seal_first_obtained("sello_01")
	_ad.track_travel_first_completed("isla_a", "isla_b")
	_ad.track_island_first_discovered("isla_b")
	_ad.track_museum_first_visited("museo_01")
	_ad.track_festival_first_participated("festival_01")
	_ad.track_community_project_first_completed("proyecto_01")
	var telemetry_events := 0
	var travel_metric := false
	for c in _stub.calls:
		if c["tipo"] == "telemetry":
			telemetry_events += 1
	for c2 in _stub.calls:
		if c2["tipo"] == "metrica" and c2["datos"].get("metrica") == "time_to_first_travel":
			travel_metric = true
	_check("11 eventos first enviados como tipo telemetry", telemetry_events == 11)
	_check("time_to_first_travel registrada tras primer viaje", travel_metric)

	# Deduplicación: repetir tutorial no debe volver a enviar.
	_stub.calls.clear()
	_ad.track_tutorial_first_completed()
	_check("deduplicacion: tutorial repetido NO reenvia", _stub.calls.size() == 0)

	# ── Puzzle + abandono simulado ──
	_stub.calls.clear()
	_ad.start_puzzle("p_aband")
	# Forzamos timestamp de inicio 400s en el pasado para superar el umbral (300s).
	_ad._puzzle_inicio["p_aband"] = Time.get_ticks_msec() - 400 * 1000
	_ad._on_puzzle_check()
	var aband := false
	for c in _stub.calls:
		if c["datos"].get("evento") == "puzzle_abandoned" and c["datos"].get("puzzle_id") == "p_aband":
			aband = true
	_check("puzzle abandonado (>300s) detectado", aband)

	# complete_puzzle envia puzzle_first_completed para puzzle nuevo.
	_ad.start_puzzle("p_nuevo")
	_ad.complete_puzzle("p_nuevo")
	var compl := false
	for c in _stub.calls:
		if c["datos"].has("evento") and c["datos"]["evento"] == "puzzle_first_completed" and c["datos"].get("puzzle_id") == "p_nuevo":
			compl = true
	_check("complete_puzzle envía puzzle_first_completed", compl)

	# ── Zonas + zona ignorada ──
	_stub.calls.clear()
	_ad.enter_zone("z1")
	_ad.exit_zone("z1")  # salida rápida → acumulado 0 < 60s
	_ad._on_zone_check()
	var ignored := false
	for c in _stub.calls:
		if c["datos"].has("evento") and c["datos"]["evento"] == "zone_ignored" and c["datos"].get("zone_id") == "z1":
			ignored = true
	_check("zona visitada <60s marcada como ignored", ignored)

	# ── Dificultad percibida ──
	_stub.calls.clear()
	_ad.track_difficulty_perceived("p1", 3)
	var diff := false
	for c in _stub.calls:
		if c["datos"].has("evento") and c["datos"]["evento"] == "difficulty_perceived" and c["datos"].get("rating") == 3:
			diff = true
	_check("difficulty_perceived con rating 3 registrada", diff)

	# ── Opt-out propaga a M104 y filtra captura ──
	_ad.establecer_opt_in(false)
	_check("opt-out propagado a M104 (establecer_opt_out)", _stub.optout_calls >= 1)
	_check("opt-in OFF tras opt-out", not _ad.opt_in)
	_stub.calls.clear()
	_ad.track_tutorial_first_completed()  # NOP con opt_in off
	_check("con opt-out, ningún evento se envía a M104", _stub.calls.size() == 0)

	# ── Limpieza ──
	if FileAccess.file_exists(_ad._settings_path):
		DirAccess.remove_absolute(_ad._settings_path)
		DirAccess.remove_absolute(_ad._settings_path.get_base_dir())
	root.remove_child(_stub)
	_stub.free()

	# Cleanup del stub (Node fuera del árbol → free directo).
	if is_instance_valid(_stub):
		_stub.free()

	print("=== Resumen: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("FALLOS DETECTADOS"); quit(1)
	else:
		print("TELEMETRIA M105 OK"); quit(0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)
