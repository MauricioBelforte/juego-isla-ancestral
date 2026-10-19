# Smoke runtime de managers core (Bloque C item 51) — Hy3 verificador §21.8.
# Autor del script: Hy3 (test-writer). Objetivo: health-check de infra fundamental
# (EventBus / ServiceRegistry / GameSettings / Bootstrap / SaveManager), NO re-verificar
# un módulo sellado concreto. Se evita GameLogger/M103 (familia DeepSeek, §21.23).
extends SceneTree

const CHECKS_MINIMOS := 9  # medido: 5 non-null + 4 round-trip ServiceRegistry
var _checks := 0
var _fallos := 0
var _errores_script := 0

func _run() -> void:
	_assert_non_null(EventBus, "EventBus autoload registrado")
	_assert_non_null(ServiceRegistry, "ServiceRegistry autoload registrado")
	_assert_non_null(GameSettings, "GameSettings autoload registrado")
	_assert_non_null(Bootstrap, "Bootstrap autoload registrado")
	_assert_non_null(SaveManager, "SaveManager autoload registrado")

	var dummy := Node.new()
	dummy.name = "Hy3SmokeDummy"
	var ok := ServiceRegistry.register("hy3_smoke_svc", dummy)
	_assert_eq(ok, true, "ServiceRegistry.register devuelve true")
	var got = ServiceRegistry.get_service("hy3_smoke_svc")
	_assert_eq(got != null, true, "ServiceRegistry.get_service recupera la instancia")
	ServiceRegistry.unregister("hy3_smoke_svc")
	_assert_eq(ServiceRegistry.has("hy3_smoke_svc"), false, "ServiceRegistry.unregister elimina el contrato")
	dummy.free()

	_fin()
	call_deferred("_summary")

func _assert_non_null(obj, msg: String) -> void:
	_checks += 1
	if obj == null:
		_fallos += 1
		push_error("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _assert_eq(cond, expected, msg: String) -> void:
	_checks += 1
	if cond != expected:
		_fallos += 1
		push_error("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _fin() -> void:
	# Guarda anti-falso-verde: si no se ejercitaron los checks mínimos, el runner
	# no debe reportar "0 fallos" como verde heredado.
	if _checks < CHECKS_MINIMOS:
		push_error("GUARDIA: checks %d < minimo %d" % [_checks, CHECKS_MINIMOS])
		_errores_script += 1

func _summary() -> void:
	print("RESUMEN_HY3_SMOKE checks=%d fallos=%d script_errors=%d" % [_checks, _fallos, _errores_script])
	quit(0 if (_fallos == 0 and _errores_script == 0) else 1)
