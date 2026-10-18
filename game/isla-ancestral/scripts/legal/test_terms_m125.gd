# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M125: Términos de Servicio — Test headless
# Valida: TermsValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.
#
# Iteracion 2026-10-18 (DeepSeek-V4.1-Flash, Log 1972): se quito `cfg.free()` sobre un
# Resource (RefCounted) que emitia SCRIPT ERROR, y se anadio la guarda anti-falso-verde
# de 3 capas (bloques nombrados + piso CHECKS_MINIMOS medido + _summary() diferido).

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/terms_validator.gd")
const RUTA_DATA := "res://data/legal/terminos.json"

const MODULO := "M125"
const BLOQUES := ["Datos", "Validator", "ValidatorErrores", "TermsManager", "TermsConfig"]
# Piso MEDIDO en verde (no estimado): 18 checks en la corrida limpia.
const CHECKS_MINIMOS := 18

var _fallos: int = 0
var _checks: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	# Si _run() aborta por un SCRIPT ERROR, la cola diferida sigue y este corre igual.
	call_deferred("_summary")

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

func _run() -> void:
	print("=== [M125] Test de Términos de Servicio ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_test_terms_manager()
	_test_terms_config()

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
	_fin("Datos")

func _test_validator() -> void:
	print("--- TermsValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))
	_fin("Validator")

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
	_fin("ValidatorErrores")

func _test_terms_manager() -> void:
	print("--- TermsManager (autoload) ---")
	var tm := root.get_node_or_null("TermsManager")
	_check("TermsManager autoload presente", tm != null)
	if tm == null:
		_fin("TermsManager")
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
	_fin("TermsManager")

func _test_terms_config() -> void:
	print("--- TermsConfig (Resource) ---")
	var cfg = load("res://scripts/legal/terms_config.gd").new()
	_check("TermsConfig terms_version = 1", cfg.terms_version == 1)
	_check("TermsConfig accept_required = true", cfg.accept_required == true)
	_check("TermsConfig show_on_launch = true", cfg.show_on_launch == true)
	_check("TermsConfig terms_file no vacío", cfg.terms_file != "")
	# TermsConfig extends Resource -> es RefCounted: NO se libera con free() (eso emitia
	# "SCRIPT ERROR: Attempted to free a RefCounted object" y era un aborto silencioso
	# latente en la ultima linea del bloque). Se suelta la referencia y el refcount hace
	# el resto.
	cfg = null
	_fin("TermsConfig")

func _summary() -> void:
	for n in BLOQUES:
		if not _vistos.has(n):
			_fallos += 1
			print("  [FAIL] bloque %s NO se ejecutó (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] piso de checks: %d ejecutados, mínimo %d" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST M125 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M125 OK — todos los checks pasaron")
		quit(0)