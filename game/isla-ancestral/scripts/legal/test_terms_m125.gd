# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M125: Términos de Servicio — Test headless
# Valida: TermsValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/terms_validator.gd")
const RUTA_DATA := "res://data/legal/terminos.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M125] Test de Términos de Servicio ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_test_terms_manager()
	_test_terms_config()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_data() -> void:
	print("--- Datos: terminos.json ---")
	var data = _cargar()
	_check("terminos.json cargado", not data.is_empty())
	_check("5 secciones", data.get("secciones", []).size() == 5, "size=%d" % data.get("secciones", []).size())
	_check("2 políticas", data.get("politicas", {}).size() == 2, "size=%d" % data.get("politicas", {}).size())

func _test_validator() -> void:
	print("--- TermsValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- TermsValidator: errores detectados ---")
	var malo = {
		"secciones": [
			{"id": "", "titulo": "", "obligatoria": false}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sección sin id detectado", str(errores).contains("sin id"))
	_check("sin título detectado", str(errores).contains("sin título"))
	_check("menos de 3 secciones detectado", str(errores).contains("3"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _test_terms_manager() -> void:
	print("--- TermsManager (autoload) ---")
	var tm := root.get_node_or_null("TermsManager")
	_check("TermsManager autoload presente", tm != null)
	if tm == null:
		return
	_check("check_terms_acceptance inicial = false", tm.check_terms_acceptance() == false)
	tm.accept_terms()
	_check("tras accept: check = true", tm.check_terms_acceptance() == true)
	# No se muestra si ya aceptó
	var sig_count: Array = [0]
	tm.terms_updated.connect(func(): sig_count[0] += 1)
	tm.update_terms(2)
	_check("update_terms(v2) -> terms_updated emitida", sig_count[0] == 1)
	_check("tras update: re-aceptación (accepted=false)", tm.check_terms_acceptance() == false)
	# Limpiar persistencia
	DirAccess.remove_absolute("user://terminos_aceptados.json")

func _test_terms_config() -> void:
	print("--- TermsConfig (Resource) ---")
	var cfg = load("res://scripts/legal/terms_config.gd").new()
	_check("TermsConfig terms_version = 1", cfg.terms_version == 1)
	_check("TermsConfig accept_required = true", cfg.accept_required == true)
	_check("TermsConfig show_on_launch = true", cfg.show_on_launch == true)
	_check("TermsConfig terms_file no vacío", cfg.terms_file != "")
	cfg.free()

func _summary() -> void:
	print("=== Resumen M125: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M125 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M125 OK — todos los checks pasaron")
		quit(0)