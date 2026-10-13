# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-13
#
# M105: Test iteración 8 — cierre de sesión al salir de la app + evento
# `chapter_completed` (higiene de los items 1 y 3 del informe 216).
#
# Por qué existe este test:
#  - Item 1 (código): antes de iter. 8 la ÚNICA ruta que finalizaba la sesión era
#    `establecer_opt_in(false)`. Cerrar la ventana (`NOTIFICATION_WM_CLOSE_REQUEST`)
#    o salir del árbol (`NOTIFICATION_EXIT_TREE`) NO emitía `session_ended` ni
#    `session_duration`. Aquí se FIJAN ambas rutas y la IDEMPOTENCIA del cierre.
#  - Item 3 (documental): el evento `chapter_completed` se mencionaba en el
#    checklist pero NO existía ni en el enum `EVT` ni como API pública. Se fija
#    la constante, el payload (`capitulo_id`) y la NO deduplicación por sesión
#    (a diferencia de los `*_first_*`).
#
# GUARDIÁN ANTI-FALSO-VERDE (trampas 61 y 62 del proyecto):
#  - Cada bloque declara `_fin("nombre")` al terminar.
#  - `_resumen()` corre en su PROPIO `call_deferred` (independiente de
#    `_ejecutar`), así un SCRIPT ERROR que aborte un bloque NO deja un
#    "0 fallos" falso: el resumen nombra los bloques faltantes y fuerza EXIT 1.
#  - `quit()` vive SOLO en `_resumen()`: llamarlo desde un `_process`/bloque
#    abortado no termina el proceso en Godot 4.7 (trampa 61).
#  - Piso `CHECKS_MINIMOS` MEDIDO en verde (no estimado).
#
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetria_iter8.gd
extends SceneTree

## Bloques que DEBEN completarse. Si alguno no llama `_fin()`, el resumen lo
## nombra y fuerza EXIT 1 (defensa contra el aborto silencioso).
const BLOQUES := [
	"autoload",
	"constante_evento",
	"chapter_completed",
	"chapter_no_dedup",
	"chapter_optout",
	"senal_chapter",
	"cierre_wm_close",
	"cierre_idempotente",
	"cierre_exit_tree",
	"cierre_optout_path",
	"limpieza",
]

## Piso de chequeos: MEDIDO en verde (17). Cierra el hueco de un bloque que llega
## a su `_fin()` saltándose checks en silencio (p. ej. un bucle sobre 0).
const CHECKS_MINIMOS := 17

var _fallos := 0
var _checks := 0
var _ad = null
var _stub = null
var _fin_bloques: Dictionary = {}
var _resumen_hecho := false
## Registro de señales capturadas (bloque `senal_chapter`).
var _senales: Dictionary = {}

class _AnalyticsStub:
	extends Node
	var calls: Array = []
	func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
		calls.append({"tipo": tipo, "datos": datos})
	func establecer_opt_out(_v: bool) -> void:
		pass

func _initialize() -> void:
	print("=== TEST TELEMETRIA M105 ITER8 (cierre de sesion + chapter_completed) ===")
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
	_ad._settings_path = "user://telemetry_test_iter8/telemetry.cfg"
	_stub = _AnalyticsStub.new()
	_ad.analytics_service = _stub
	_ad.establecer_opt_in(true)
	_check("opt-in ON tras establecer true", _ad.opt_in)
	_fin("autoload")

	_test_constante_evento()
	_test_chapter_completed()
	_test_chapter_no_dedup()
	_test_chapter_optout()
	_test_senal_chapter()
	_test_cierre_wm_close()
	_test_cierre_idempotente()
	_test_cierre_exit_tree()
	_test_cierre_optout_path()

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
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d): aborto silencioso dentro de un bloque" % [_checks, CHECKS_MINIMOS])
	print("=== TEST TELEMETRIA M105 ITER8: %d fallo(s) de %d cheque(s) ===" % [_fallos, _checks])
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

## Busca el `capitulo_id` de la primera llamada con evento `chapter_completed`.
func _capitulo_reportado() -> String:
	for call in _stub.calls:
		if call["datos"].get("evento", "") == "chapter_completed":
			return str(call["datos"].get("capitulo_id", ""))
	return ""

## ── Bloques ──────────────────────────────────────────────

## Item 3: la constante debe existir y valer el string del contrato.
func _test_constante_evento() -> void:
	var cs := _constantes()
	var evt: Dictionary = cs.get("EVT", {})
	_check("EVT.CHAPTER_COMPLETED == \"chapter_completed\"",
		evt.get("CHAPTER_COMPLETED", "") == "chapter_completed")
	_check("EVT conserva SESSION_ENDED (sin regresión del enum)",
		evt.get("SESSION_ENDED", "") == "session_ended")
	_fin("constante_evento")

## Item 3: `track_chapter_completed` emite el evento con el `capitulo_id`.
func _test_chapter_completed() -> void:
	_ad.establecer_opt_in(true)
	_ad._iniciar_sesion()
	_stub.calls.clear()
	_ad.track_chapter_completed("cap_1")
	_check("track_chapter_completed emite chapter_completed",
		_conteo_evento("chapter_completed") == 1)
	_check("el payload lleva capitulo_id == cap_1", _capitulo_reportado() == "cap_1")
	_fin("chapter_completed")

## Item 3: a diferencia de los `*_first_*`, cada capítulo se reporta (no dedup).
func _test_chapter_no_dedup() -> void:
	_stub.calls.clear()
	_ad.track_chapter_completed("cap_2")
	_ad.track_chapter_completed("cap_3")
	_check("dos capítulos distintos => dos eventos (NO deduplicado)",
		_conteo_evento("chapter_completed") == 2)
	_fin("chapter_no_dedup")

## Privacy: con opt-out no se captura nada (guard `if not opt_in`).
func _test_chapter_optout() -> void:
	_ad.establecer_opt_in(false)
	_stub.calls.clear()
	_ad.track_chapter_completed("cap_off")
	_check("con opt-out track_chapter_completed no emite nada", _stub.calls.size() == 0)
	_fin("chapter_optout")

## La señal pública `evento_rastreado` debe EMITIRSE para el nuevo evento.
func _test_senal_chapter() -> void:
	_ad.establecer_opt_in(true)
	_ad._iniciar_sesion()
	_senales.clear()
	_ad.evento_rastreado.connect(_on_evento_rastreado)
	_ad.track_chapter_completed("cap_senal")
	_check("senal evento_rastreado emitida con chapter_completed",
		_senales.get("evento", "") == "chapter_completed")
	_ad.evento_rastreado.disconnect(_on_evento_rastreado)
	_fin("senal_chapter")

## Item 1: cerrar la ventana debe finalizar la sesión (antes NUNCA salía).
func _test_cierre_wm_close() -> void:
	_ad.establecer_opt_in(true)
	_ad._iniciar_sesion()
	_ad._inicio_sesion_ms = Time.get_ticks_msec() - 5000  # 5 s de sesión
	_stub.calls.clear()
	_ad._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	_check("WM_CLOSE_REQUEST emite session_ended", _conteo_evento("session_ended") == 1)
	_check("WM_CLOSE_REQUEST registra session_duration",
		_conteo_metrica("session_duration") == 1)
	var v: Variant = _valor_metrica("session_duration")
	_check("session_duration del cierre refleja la sesión real (>= 4 s)",
		v != null and int(v) >= 4)
	_fin("cierre_wm_close")

## Item 1: `_finalizar_sesion()` es idempotente (no duplica eventos).
func _test_cierre_idempotente() -> void:
	_stub.calls.clear()
	_ad._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)  # 2ª vez: ya cerrada
	_check("2º cierre NO duplica session_ended", _conteo_evento("session_ended") == 0)
	_check("_sesion_cerrada queda en true tras el cierre", _ad._sesion_cerrada)
	_fin("cierre_idempotente")

## Item 1: `NOTIFICATION_EXIT_TREE` también cierra la sesión.
func _test_cierre_exit_tree() -> void:
	_ad.establecer_opt_in(true)
	_ad._iniciar_sesion()
	_stub.calls.clear()
	_ad._notification(Node.NOTIFICATION_EXIT_TREE)
	_check("EXIT_TREE emite session_ended", _conteo_evento("session_ended") == 1)
	_fin("cierre_exit_tree")

## Idempotencia cruzada: cerrar por ventana y luego hacer opt-out NO duplica.
func _test_cierre_optout_path() -> void:
	_ad.establecer_opt_in(true)
	_ad._iniciar_sesion()
	_stub.calls.clear()
	_ad._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	_check("cierre por ventana emite session_ended una vez",
		_conteo_evento("session_ended") == 1)
	_ad.establecer_opt_in(false)  # opt-out posterior: NO debe duplicar
	_check("opt-out tras el cierre NO duplica session_ended",
		_conteo_evento("session_ended") == 1)
	_fin("cierre_optout_path")

func _on_evento_rastreado(evento: String, _datos: Dictionary) -> void:
	_senales["evento"] = evento
