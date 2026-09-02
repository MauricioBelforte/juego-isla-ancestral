# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M98: Trailer — Test headless
# Valida: TrailerValidator (duración coherente, formato, música por toma,
# subtítulos, anti-spoiler). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/marketing/trailer_validator.gd")
const RUTA_DATA := "res://data/marketing/trailer_spec.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M98] Test de Trailer ===")
	_test_data()
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

func _cargar() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_DATA))
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}

func _test_data() -> void:
	print("--- Datos: trailer_spec.json ---")
	var data = _cargar()
	_check("trailer_spec.json cargado", not data.is_empty())
	_check("duración 75s", int(data.get("trailer", {}).get("duracion_total_s", 0)) == 75)
	_check("12 tomas", data.get("tomas", []).size() == 12, "size=%d" % data.get("tomas", []).size())
	_check("6 idiomas subtítulos", data.get("trailer", {}).get("idiomas_subtitulos", []).size() == 6)
	_check("3 anti-spoiler", data.get("checklist_antiespoiler", []).size() == 3, "size=%d" % data.get("checklist_antiespoiler", []).size())

func _test_validator() -> void:
	print("--- TrailerValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- TrailerValidator: errores detectados ---")
	var malo = {
		"trailer": {"duracion_total_s": 100, "formato": "", "resolucion": "", "idiomas_subtitulos": ["es"]},
		"tomas": [
			{"id": "a", "duracion_s": 5, "musica": ""},
			{"id": "b", "duracion_s": 5, "musica": ""}
		],
		"checklist_antiespoiler": []
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("duración incoherente detectada", str(errores).contains("difiere"))
	_check("sin formato detectado", str(errores).contains("formato"))
	_check("toma sin música detectada", str(errores).contains("sin música"))
	_check("pocos subtítulos detectado", str(errores).contains("idiomas"))
	_check("anti-spoiler vacío detectado", str(errores).contains("spoiler"))

func _summary() -> void:
	print("=== Resumen M98: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M98 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M98 OK — todos los checks pasaron")
		quit(0)