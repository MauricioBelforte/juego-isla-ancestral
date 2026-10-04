# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M117: Build System — Test headless
# Valida: BuildConfigManager (carga de build_targets.json, lectura de
# export_presets.cfg, targets por prioridad, validación con BuildValidator).
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/build/build_validator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M117] Test de Build System ===")
	_test_manager()
	_test_targets()
	_test_validator()
	_test_validator_errores()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_manager() -> void:
	print("--- BuildConfigManager: targets + presets ---")
	var bc := root.get_node_or_null("BuildConfigManager")
	if bc == null:
		_check("BuildConfigManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("BuildConfigManager autoload presente", true)
	_check("4 targets en config", bc.targets.get("targets", []).size() == 4, "size=%d" % bc.targets.get("targets", []).size())
	_check("export_presets.cfg leído (>=1 preset)", bc.presets_existentes.size() >= 1, "presets=%s" % str(bc.presets_existentes))

func _test_targets() -> void:
	print("--- Targets: por prioridad y lookup ---")
	var bc := root.get_node_or_null("BuildConfigManager")
	var windows = bc.obtener_target("windows")
	_check("windows P0", windows.get("prioridad", "") == "P0")
	_check("windows preset", String(windows.get("preset", "")) != "")
	_check("target inexistente -> {}", bc.obtener_target("no_existe").is_empty())
	var p0 = bc.targets_por_prioridad("P0")
	_check("P0 targets (windows)", p0.size() >= 1, "size=%d" % p0.size())

func _test_validator() -> void:
	print("--- BuildValidator: data real ---")
	var bc := root.get_node_or_null("BuildConfigManager")
	var errores = bc.validar()
	# El preset "Web" existe en export_presets.cfg; los targets piden Windows/macOS/Linux
	# que NO existen -> debe haber errores de preset faltante (esperado en dev)
	_check("validación detecta presets faltantes", not errores.is_empty(), "errores=%s" % str(errores))
	# Pero targets están bien formados (sin errores de estructura)
	var errores_estructura: Array = []
	for e in errores:
		if String(e).contains("sin preset") or String(e).contains("sin prioridad") or String(e).contains("sin id"):
			errores_estructura.append(e)
	_check("sin errores estructurales", errores_estructura.is_empty(), "estructurales=%s" % str(errores_estructura))

func _test_validator_errores() -> void:
	print("--- BuildValidator: errores estructurales ---")
	var malo = {
		"targets": [
			{"id": "", "preset": "", "prioridad": ""},
			{"id": "ok", "preset": "Windows", "prioridad": "P0"}
		]
	}
	var errores = _SC_VALIDATOR.validar(malo, ["Windows"])
	_check("target sin id detectado", str(errores).contains("sin id"))
	_check("target sin preset detectado", str(errores).contains("sin preset"))
	_check("target sin prioridad detectado", str(errores).contains("sin prioridad"))
	# config sin targets
	var vacio = _SC_VALIDATOR.validar({"targets": []}, ["Windows"])
	_check("sin targets detectado", str(vacio).contains("sin targets"))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _summary() -> void:
	print("=== Resumen M117: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M117 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M117 OK — todos los checks pasaron")
		quit(0)