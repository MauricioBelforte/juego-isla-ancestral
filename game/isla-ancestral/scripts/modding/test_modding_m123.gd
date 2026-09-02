# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M123: Modding — Test headless
# Valida: ModdingManager (manifiesto, compatibilidad, conflictos) y
# ModValidator. Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/modding/mod_validator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M123] Test de Modding ===")
	_test_manifest()
	_test_compatibilidad()
	_test_conflictos()
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

func _test_manifest() -> void:
	print("--- Manifest: mods data-driven ---")
	var mm := root.get_node_or_null("ModdingManager")
	if mm == null:
		_check("ModdingManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("ModdingManager autoload presente", true)
	_check("2 mods", mm.config.get("mods", []).size() == 2, "size=%d" % mm.config.get("mods", []).size())
	_check("mod_aurora_items existe", not mm.mod("mod_aurora_items").is_empty())
	_check("mod inexistente -> {}", mm.mod("no_existe").is_empty())
	_check("carpeta mods user://mods", mm.carpeta_mods() == "user://mods")

func _test_compatibilidad() -> void:
	print("--- Compatibilidad y activación ---")
	var mm := root.get_node_or_null("ModdingManager")
	_check("mod compatible con 1.0.0", mm.es_compatible("mod_aurora_items", "1.0.0") == true)
	_check("mod incompatible con 0.8.0", mm.es_compatible("mod_aurora_items", "0.8.0") == false)
	_check("mod inexistente incompatible", mm.es_compatible("no_existe", "1.0.0") == false)
	_check("activar mod", mm.activar("mod_aurora_items") == true)
	_check("mod activo", mm.esta_activo("mod_aurora_items") == true)
	_check("activar inexistente falla", mm.activar("no_existe") == false)

func _test_conflictos() -> void:
	print("--- Conflictos: override ---")
	var mm := root.get_node_or_null("ModdingManager")
	var conflictos = mm.detectar_conflictos()
	_check("1 conflicto (mod_aurora_qol override)", conflictos.size() == 1, "size=%d" % conflictos.size())
	if conflictos.size() >= 1:
		_check("conflicto mod_aurora_qol -> mod_aurora_items", String(conflictos[0].get("override", "")) == "mod_aurora_items")

func _test_validator() -> void:
	print("--- ModValidator: data real ---")
	var mm := root.get_node_or_null("ModdingManager")
	var errores = _SC_VALIDATOR.validar(mm.config)
	_check("config válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- ModValidator: errores detectados ---")
	var malo = {
		"mods": [
			{"id": "", "version": "", "min_build": "", "override": []},
			{"id": "a", "version": "1.0", "min_build": "1.0", "override": ["b"]}
		]
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("mod sin id detectado", str(errores).contains("sin id"))
	_check("mod sin versión detectado", str(errores).contains("sin versión"))
	_check("override 'b' no existe detectado", str(errores).contains("b"))

func _summary() -> void:
	print("=== Resumen M123: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M123 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M123 OK — todos los checks pasaron")
		quit(0)
