# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M147: World Building — Test headless
# Valida: carga del canon data-driven, getters (personaje/lugar/símbolo),
# capas de revelación por Sello (get_capa_minima), ValidateWorld
# (consistencia del canon real), timeline ordenada.
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/world/validate_world.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M147] Test de World Building ===")
	_test_canon()
	_test_getters()
	_test_capas()
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

func _world() -> Node:
	return root.get_node_or_null("WorldBible")

func _test_canon() -> void:
	print("--- Canon: carga data-driven ---")
	var w := _world()
	if w == null:
		_check("WorldBible autoload presente", false)
		_summary()
		quit(1)
		return
	_check("WorldBible autoload presente", true)
	_check("canon_version 1.0.0", w.version() == "1.0.0", "v=%s" % w.version())
	_check("6 personajes", w._data.get("personajes", {}).size() == 6, "size=%d" % w._data.get("personajes", {}).size())
	_check("8 lugares", w._data.get("lugares", {}).size() == 8, "size=%d" % w._data.get("lugares", {}).size())
	_check("4 sellos", w._data.get("simbolos", {}).size() == 4)
	_check("4 capas por sello", w._data.get("capas_por_sello", {}).size() == 4)
	_check("timeline 5 epochs", w.linea_tiempo().size() == 5, "size=%d" % w.linea_tiempo().size())

func _test_getters() -> void:
	print("--- Getters: personaje/lugar/símbolo ---")
	var w := _world()
	var finneas = w.get_personaje("finneas")
	_check("get_personaje(finneas)", not finneas.is_empty() and finneas.get("rol", "") == "guia")
	var faro = w.get_lugar("faro")
	_check("get_lugar(faro)", not faro.is_empty() and faro.get("isla", "") == "raiz")
	var sello = w.get_simbolo("sello_marea")
	_check("get_simbolo(sello_marea)", not sello.is_empty())
	_check("get inexistente -> {}", w.get_personaje("no_existe").is_empty())

func _test_capas() -> void:
	print("--- Capas de revelación por Sello ---")
	var w := _world()
	var min_faro = w.get_capa_minima(["faro"])
	_check("faro visible desde sello 1", min_faro == 1, "capa=%d" % min_faro)
	var min_templo_raiz = w.get_capa_minima(["templo_raiz"])
	_check("templo_raiz capa 1", min_templo_raiz == 1)
	var min_volcan = w.get_capa_minima(["volcan"])
	_check("volcán capa 3", min_volcan == 3, "capa=%d" % min_volcan)
	var min_mixto = w.get_capa_minima(["faro", "volcan"])
	_check("mínima de conjunto = máxima requerida (3)", min_mixto == 3, "capa=%d" % min_mixto)
	var min_inexistente = w.get_capa_minima(["no_existe"])
	_check("id inexistente -> capa 0", min_inexistente == 0)

func _test_validator() -> void:
	print("--- ValidateWorld: canon real consistente ---")
	var w := _world()
	var errores = _SC_VALIDATOR.validar(w._data)
	_check("canon válido (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK cuando limpio", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- ValidateWorld: errores detectados ---")
	var malo = {
		"canon_version": "",
		"personajes": {"a": {"id": "a"}},
		"lugares": {"b": {"id": "b"}},
		"simbolos": {"sello_x": {"id": "sello_x"}},
		"capas_por_sello": {
			"sello_x": {"orden": 1, "revela": ["a", "no_existe"]},
			"sello_inexistente": {"orden": 2, "revela": ["b"]}
		},
		"linea_tiempo": [
			{"nombre": "e2", "orden": 2},
			{"nombre": "e1", "orden": 1}
		]
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("canon_version faltante detectado", str(errores).contains("canon_version"))
	_check("ref inexistente detectada", str(errores).contains("no_existe"))
	_check("sello en capas sin símbolo detectado", str(errores).contains("sello_inexistente"))
	_check("timeline desordenada detectada", str(errores).contains("Timeline"))
	_check("4+ errores", errores.size() >= 4, "size=%d" % errores.size())

func _summary() -> void:
	print("=== Resumen M147: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M147 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M147 OK — todos los checks pasaron")
		quit(0)