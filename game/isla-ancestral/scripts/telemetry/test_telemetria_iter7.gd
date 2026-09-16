# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M105: Test iteración 7 — métricas `time_to_first_*` faltantes + guardián.
#
# Por qué existe este test:
#  - El diseño (02-Analisis.md, métricas) exige 5 métricas `time_to_first_*`
#    (RF12/RF13 + house/puzzle/seal); solo existían 2 (+ session_duration).
#    Aquí se FIJAN las 3 nuevas y su unicidad por sesión.
#  - `complete_puzzle` es la ruta de gameplay y BYPASSA `_track_first`: se
#    verifica que registre discovery+puzzle por sí sola.
#  - BUG corregido: `establecer_opt_in(false)` apagaba `opt_in` antes de
#    `_finalizar_sesion()` → `session_ended`/`session_duration` nunca salían.
#    Este test lo cubre con una duración forzada (no un 0 ambiguo).
#  - `solicitar_encuesta` estaba DECLARADA y NUNCA emitida (código muerto): M53
#    no tenía forma de enterarse de que debía mostrar la encuesta. Se emite al
#    completar el puzzle y aquí se asserta, junto con las otras 2 señales de la
#    API pública (`cambio_opt_in`, `evento_rastreado`).
#  - Privacy by design: se asserta que ningún payload de M105 lleva claves de PII.
#
# GUARDIÁN ANTI-FALSO-VERDE (trampas 61 y 62 del proyecto):
#  - Cada bloque declara `_fin("nombre")` al terminar.
#  - `_resumen()` corre en su PROPIO `call_deferred` (independiente de
#    `_ejecutar`), así un SCRIPT ERROR que aborte un bloque NO deja un
#    "0 fallos" falso: el resumen nombra los bloques faltantes y fuerza EXIT 1.
#  - `quit()` vive SOLO en `_resumen()`: llamarlo desde un `_process`/bloque
#    abortado no termina el proceso en Godot 4.7 (trampa 61).
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetria_iter7.gd
extends SceneTree

## Bloques que DEBEN completarse. Si alguno no llama `_fin()`, el resumen lo
## nombra y fuerza EXIT 1 (defensa contra el aborto silencioso).
const BLOQUES := [
	"autoload",
	"constantes",
	"metrica_house",
	"metrica_puzzle",
	"metrica_seal",
	"metrica_viaje",
	"complete_puzzle_ruta",
	"session_duration",
	"optout",
	"senales",
	"sin_pii",
	"limpieza",
]

var _fallos := 0
var _checks := 0
var _ad = null
var _stub = null
var _fin_bloques: Dictionary = {}
var _resumen_hecho := false
## Registro de senales capturadas (bloque `senales`).
var _senales: Dictionary = {}

class _AnalyticsStub:
	extends Node
	var calls: Array = []
	func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
		calls.append({"tipo": tipo, "datos": datos})
	func establecer_opt_out(_v: bool) -> void:
		pass

func _initialize() -> void:
	print("=== TEST TELEMETRIA M105 ITER7 (metricas time_to_first_* + guardian) ===")
	# DOS deferred independientes: si `_ejecutar` aborta por SCRIPT ERROR,
	# `_resumen` igual corre (es el camino de terminación real, trampa 61).
	call_deferred("_ejecutar")
	call_deferred("_resumen")

func _fin(bloque: String) -> void:
	_fin_bloques[bloque] = true

func _ejecutar() -> void:
	_ad = root.get_node_or_null("TelemetryDirector")
	_check("autoload TelemetryDirector presente", _ad != null)
	if _ad == null:
		_fin("autoload")
		return
	_ad._settings_path = "user://telemetry_test_iter7/telemetry.cfg"
	_stub = _AnalyticsStub.new()
	_ad.analytics_service = _stub
	_ad.establecer_opt_in(true)
	_check("opt-in ON tras establecer true", _ad.opt_in)
	_fin("autoload")

	_test_constantes()
	_test_metrica_house()
	_test_metrica_puzzle()
	_test_metrica_seal()
	_test_metrica_viaje()
	_test_complete_puzzle_ruta()
	_test_session_duration()
	_test_optout()
	_test_senales()
	_test_sin_pii()

	# limpieza de settings aislados
	if FileAccess.file_exists(_ad._settings_path):
		DirAccess.remove_absolute(_ad._settings_path)
		DirAccess.remove_absolute(_ad._settings_path.get_base_dir())
	_fin("limpieza")

## Único punto de terminación. Nombra los bloques que no cerraron.
func _resumen() -> void:
	if _resumen_hecho:
		return
	_resumen_hecho = true
	var faltantes: Array = []
	for b in BLOQUES:
		if not _fin_bloques.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_fallos += 1
		print("[FAIL] bloques NO completados (aborto silencioso): %s" % str(faltantes))
	print("=== TEST TELEMETRIA M105 ITER7: %d fallo(s) de %d cheque(s) ===" % [_fallos, _checks])
	quit(1 if _fallos > 0 else 0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _constantes() -> Dictionary:
	return _ad.get_script().get_script_constant_map()

func _conteo_evento(evento: String) -> int:
	var c := 0
	for call in _stub.calls:
		if call["datos"].get("evento", "") == evento:
			c += 1
	return c

func _conteo_metrica(nombre: String) -> int:
	var c := 0
	for call in _stub.calls:
		if call["tipo"] == "metrica" and call["datos"].get("metrica", "") == nombre:
			c += 1
	return c

func _valor_metrica(nombre: String) -> Variant:
	for call in _stub.calls:
		if call["tipo"] == "metrica" and call["datos"].get("metrica", "") == nombre:
			return call["datos"].get("valor", null)
	return null

## ── Bloques ──────────────────────────────────────────────

func _test_constantes() -> void:
	var cs := _constantes()
	var nombres: Array = []
	for k in cs.keys():
		if str(k).begins_with("METRIC_TIME_TO_FIRST_"):
			nombres.append(str(k))
	nombres.sort()
	_check("hay 5 metricas METRIC_TIME_TO_FIRST_* (diseño)", nombres.size() == 5)
	_check("METRIC_TIME_TO_FIRST_HOUSE == time_to_first_house",
		cs.get("METRIC_TIME_TO_FIRST_HOUSE", "") == "time_to_first_house")
	_check("METRIC_TIME_TO_FIRST_PUZZLE == time_to_first_puzzle",
		cs.get("METRIC_TIME_TO_FIRST_PUZZLE", "") == "time_to_first_puzzle")
	_check("METRIC_TIME_TO_FIRST_SEAL == time_to_first_seal",
		cs.get("METRIC_TIME_TO_FIRST_SEAL", "") == "time_to_first_seal")
	_check("las 2 previas intactas",
		cs.get("METRIC_TIME_TO_FIRST_DISCOVERY", "") == "time_to_first_discovery"
		and cs.get("METRIC_TIME_TO_FIRST_TRAVEL", "") == "time_to_first_travel")
	_fin("constantes")

func _test_metrica_house() -> void:
	_stub.calls.clear()
	_ad.track_house_first_built()
	_check("time_to_first_house registrada al construir la 1ª casa",
		_conteo_metrica("time_to_first_house") == 1)
	_ad.track_house_first_built()
	_check("2ª casa NO re-registra time_to_first_house",
		_conteo_metrica("time_to_first_house") == 1)
	_fin("metrica_house")

func _test_metrica_puzzle() -> void:
	_stub.calls.clear()
	_ad.track_puzzle_first_completed("pz_iter7")
	_check("time_to_first_puzzle registrada", _conteo_metrica("time_to_first_puzzle") == 1)
	_ad.track_puzzle_first_completed("pz_iter7_b")
	_check("2º puzzle NO re-registra time_to_first_puzzle",
		_conteo_metrica("time_to_first_puzzle") == 1)
	_fin("metrica_puzzle")

func _test_metrica_seal() -> void:
	_stub.calls.clear()
	_ad.track_seal_first_obtained("sello_iter7")
	_check("time_to_first_seal registrada", _conteo_metrica("time_to_first_seal") == 1)
	_ad.track_seal_first_obtained("sello_iter7_b")
	_check("2º sello NO re-registra time_to_first_seal",
		_conteo_metrica("time_to_first_seal") == 1)
	_fin("metrica_seal")

func _test_metrica_viaje() -> void:
	_stub.calls.clear()
	_ad.track_travel_first_completed("isla_a", "isla_b")
	_check("time_to_first_travel registrada", _conteo_metrica("time_to_first_travel") == 1)
	_ad.track_travel_first_completed("isla_a", "isla_c")
	_check("2º viaje NO re-registra time_to_first_travel (guard _track_first)",
		_conteo_metrica("time_to_first_travel") == 1)
	_fin("metrica_viaje")

## La ruta de gameplay: `complete_puzzle` NO pasa por `_track_first`.
func _test_complete_puzzle_ruta() -> void:
	_ad._iniciar_sesion()  # sesión nueva → `_tracked` limpio
	_stub.calls.clear()
	_ad.start_puzzle("pz_gameplay")
	_ad.complete_puzzle("pz_gameplay")
	_check("complete_puzzle emite puzzle_first_completed",
		_conteo_evento("puzzle_first_completed") == 1)
	_check("complete_puzzle registra time_to_first_puzzle",
		_conteo_metrica("time_to_first_puzzle") == 1)
	_check("complete_puzzle registra time_to_first_discovery",
		_conteo_metrica("time_to_first_discovery") == 1)
	_fin("complete_puzzle_ruta")

## Cubre el BUG corregido: la métrica de sesión debe salir al APAGAR opt-in.
func _test_session_duration() -> void:
	_ad._inicio_sesion_ms = Time.get_ticks_msec() - 5000  # 5 s de sesión
	_stub.calls.clear()
	_ad.establecer_opt_in(false)
	_check("session_ended emitido al cerrar sesión", _conteo_evento("session_ended") == 1)
	_check("session_duration registrada al cerrar sesión",
		_conteo_metrica("session_duration") == 1)
	var v: Variant = _valor_metrica("session_duration")
	_check("session_duration refleja la sesión real (>= 4 s)",
		v != null and int(v) >= 4)
	_fin("session_duration")

func _test_optout() -> void:
	_stub.calls.clear()
	_ad.track_tutorial_first_completed()
	_ad.enter_zone("z_off")
	_ad.exit_zone("z_off")
	_check("con opt-out no se emite nada", _stub.calls.size() == 0)
	_fin("optout")

## Las 3 senales de la API publica deben EMITIRSE de verdad (no solo declararse).
## `solicitar_encuesta` estaba declarada y NUNCA emitida antes de iter. 7.
func _test_senales() -> void:
	_senales.clear()
	_ad.cambio_opt_in.connect(_on_cambio_opt_in)
	_ad.evento_rastreado.connect(_on_evento_rastreado)
	_ad.solicitar_encuesta.connect(_on_solicitar_encuesta)

	_ad.establecer_opt_in(true)
	_check("senal cambio_opt_in emitida al activar opt-in", _senales.get("cambio", null) == true)

	_senales.clear()
	_ad.track_resource_first_collected("madera")
	_check("senal evento_rastreado emitida por un evento", _senales.has("evento"))

	_senales.clear()
	_ad.start_puzzle("pz_encuesta")
	_ad.complete_puzzle("pz_encuesta")
	_check("senal solicitar_encuesta emitida al completar puzzle (era codigo muerto)",
		_senales.get("encuesta", "") == "pz_encuesta")

	_ad.cambio_opt_in.disconnect(_on_cambio_opt_in)
	_ad.evento_rastreado.disconnect(_on_evento_rastreado)
	_ad.solicitar_encuesta.disconnect(_on_solicitar_encuesta)
	_fin("senales")

func _on_cambio_opt_in(habilitado: bool) -> void:
	_senales["cambio"] = habilitado

func _on_evento_rastreado(evento: String, _datos: Dictionary) -> void:
	_senales["evento"] = evento

func _on_solicitar_encuesta(puzzle_id: String) -> void:
	_senales["encuesta"] = puzzle_id

## Privacy by design: M105 NUNCA debe enviar PII (la anonimizacion es de M104).
func _test_sin_pii() -> void:
	_ad._iniciar_sesion()
	_stub.calls.clear()
	_ad.track_resource_first_collected("madera")
	_ad.track_difficulty_perceived("pz_pii", 3)
	_ad.enter_zone("z_pii")
	_ad.exit_zone("z_pii")
	var prohibidas := ["username", "user", "email", "ip", "ip_address", "nombre",
		"name", "device_id", "player_id", "steam_id", "nick"]
	var halladas: Array = []
	for call in _stub.calls:
		for k in call["datos"].keys():
			if str(k).to_lower() in prohibidas:
				halladas.append(str(k))
	_check("ningun payload de M105 lleva claves de PII (%d llamadas revisadas)" % _stub.calls.size(),
		halladas.is_empty())
	_check("el sobre interno lleva evento + ms_desde_sesion, sin identidad",
		_sobre_interno_ok())
	_fin("sin_pii")

func _sobre_interno_ok() -> bool:
	for call in _stub.calls:
		if call["tipo"] != "telemetry":
			continue
		var d: Dictionary = call["datos"]
		if not (d.has("evento") and d.has("ms_desde_sesion")):
			return false
	return true
