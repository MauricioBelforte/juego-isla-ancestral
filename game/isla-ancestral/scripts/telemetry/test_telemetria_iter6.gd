# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-11
#
# M105: Test iteración 6 — fix de INTEGRACIÓN de `zone_ignored`.
#
# Por qué existe este test: `test_telemetria_iter5.gd` valida la deduplicación de
# `zone_ignored` llamando `_on_zone_check()` A MANO, lo que enmascara el bug real:
# `exit_zone` detiene `_zone_check_timer` al salir de la última zona, así que en
# runtime `_on_zone_check` nunca corre y el evento NUNCA se emitía.
# Este test reproduce el camino REAL (sin llamar al chequeo a mano).
#
# Valida:
#  - zone_ignored se emite al SALIR de una zona < 60 s, sin invocar _on_zone_check().
#  - El timer de zonas queda DETENIDO tras salir (prueba de que el camino viejo
#    no habría emitido nunca).
#  - El acumulado se limpia al reportar.
#  - Dedup: una segunda visita a la misma zona no re-emite.
#  - Zona con acumulado >= umbral NO se reporta ni se limpia (contrato iter. 5).
#  - zone_entered / zone_exited siguen emitiéndose (no regresión).
#
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/telemetry/test_telemetria_iter6.gd
extends SceneTree

## Piso de chequeos: si un SCRIPT ERROR aborta parte de la suite, el
## conteo real cae por debajo y `_resumen()` lo denuncia (fail-safe).
const CHECKS_MINIMOS := 11
var _fallos := 0
var _checks := 0
var _ad = null
var _stub = null
## iter. 7 — guardian anti-falso-verde: `_ejecutar` marca `_terminado` al
## llegar al final. Si un SCRIPT ERROR lo aborta, `_terminado` queda en
## false y `_resumen()` (encolado APARTE, no al final de `_ejecutar`) lo
## denuncia con EXIT 1 en vez de imprimir un "0 fallos" falso.
var _terminado := false

class _AnalyticsStub:
	extends Node
	var calls: Array = []
	func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
		calls.append({"tipo": tipo, "datos": datos})
	func establecer_opt_out(_v: bool) -> void:
		pass

func _initialize() -> void:
	print("=== TEST TELEMETRIA M105 ITER6 (fix integracion zone_ignored) ===")
	# Dos deferred INDEPENDIENTES: si `_ejecutar` aborta, `_resumen` igual corre.
	call_deferred("_ejecutar")
	call_deferred("_resumen")

func _ejecutar() -> void:
	_ad = root.get_node_or_null("TelemetryDirector")
	_check("autoload TelemetryDirector presente", _ad != null)
	if _ad == null:
		print("FALTA AUTOLOAD"); quit(1); return
	_ad._settings_path = "user://telemetry_test_iter6/telemetry.cfg"
	_stub = _AnalyticsStub.new()
	_ad.analytics_service = _stub
	_ad.establecer_opt_in(true)

	_test_emision_al_salir()
	_test_dedup_segunda_visita()
	_test_zona_larga_no_reportada()
	_test_entered_exited_intactos()
	_test_optout_sigue_filtrando()

	# limpieza de settings aislados
	if FileAccess.file_exists(_ad._settings_path):
		DirAccess.remove_absolute(_ad._settings_path)
		DirAccess.remove_absolute(_ad._settings_path.get_base_dir())
	_ad.establecer_opt_in(false)

	_terminado = true

## Unico punto de terminacion. Detecta el aborto silencioso de `_ejecutar`.
func _resumen() -> void:
	if not _terminado:
		_fallos += 1
		print("[FAIL] la suite NO llego al final (aborto silencioso)")
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d): aborto silencioso dentro de un bloque" % [_checks, CHECKS_MINIMOS])
	print("=== TEST TELEMETRIA M105 ITER6: %d fallo(s) de %d cheque(s) ===" % [_fallos, _checks])
	quit(1 if _fallos > 0 else 0)

func _check(nombre: String, condicion: bool) -> void:
	_checks += 1
	if condicion:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FALLO] %s" % nombre)

func _conteo_evento(evento: String) -> int:
	var c := 0
	for call in _stub.calls:
		var datos: Dictionary = call.datos
		if datos.get("evento", "") == evento:
			c += 1
	return c

## EL test del fix: entrar y salir, SIN tocar el timer a mano.
func _test_emision_al_salir() -> void:
	_stub.calls.clear()
	_ad.enter_zone("z_fix")
	_ad.exit_zone("z_fix")
	# NO se llama _on_zone_check() — este es el camino real del juego.
	_check("zone_ignored emitido al SALIR (sin _on_zone_check manual)", _conteo_evento("zone_ignored") == 1)
	_check("el timer de zonas quedó DETENIDO al salir", _ad._zone_check_timer.is_stopped())
	_check("acumulado limpiado tras reportar", not _ad._zona_duracion.has("z_fix"))

func _test_dedup_segunda_visita() -> void:
	_stub.calls.clear()
	_ad.enter_zone("z_fix")
	_ad.exit_zone("z_fix")
	_check("segunda visita a zona ya reportada NO re-emite", _conteo_evento("zone_ignored") == 0)

func _test_zona_larga_no_reportada() -> void:
	_stub.calls.clear()
	_ad._zona_duracion["z_larga"] = 120
	_ad._on_zone_check()
	_check("zona de 120 s NO se reporta como ignorada", _conteo_evento("zone_ignored") == 0)
	_check("zona >= umbral permanece en el acumulado (contrato iter. 5)", _ad._zona_duracion.has("z_larga"))
	_ad._zona_duracion.erase("z_larga")

func _test_entered_exited_intactos() -> void:
	_stub.calls.clear()
	_ad.enter_zone("z_io")
	_ad.exit_zone("z_io")
	_check("zone_entered sigue emitiéndose", _conteo_evento("zone_entered") == 1)
	_check("zone_exited sigue emitiéndose", _conteo_evento("zone_exited") == 1)
	_check("zone_exited lleva zone_id y tiempo_seg", _tiene_zone_exited_con_tiempo())

func _tiene_zone_exited_con_tiempo() -> bool:
	for call in _stub.calls:
		var d: Dictionary = call.datos
		if d.get("evento", "") == "zone_exited" and d.has("zone_id") and d.has("tiempo_seg"):
			return true
	return false

func _test_optout_sigue_filtrando() -> void:
	_ad.establecer_opt_in(false)
	_stub.calls.clear()
	_ad.enter_zone("z_off")
	_ad.exit_zone("z_off")
	_check("con opt-out no se emite nada", _stub.calls.size() == 0)
	_ad.establecer_opt_in(true)
