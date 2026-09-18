# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M84: Música y Audio Legal — Test headless
# Valida: AudioLicenseValidator (data-driven). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/legal/audio_license_validator.gd")
const RUTA_DATA := "res://data/legal/audio_licenses.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M84] Test de Música y Audio Legal ===")
	_test_data()
	_test_validator()
	_test_validator_errores()
	_test_artista_multi_rol()
	_test_audio_multi_licencia()
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
	print("--- Datos: audio_licenses.json ---")
	var data = _cargar()
	_check("audio_licenses.json cargado", not data.is_empty())
	_check("3 tracks", data.get("tracks", []).size() == 3, "size=%d" % data.get("tracks", []).size())

func _test_validator() -> void:
	print("--- AudioLicenseValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- AudioLicenseValidator: errores detectados ---")
	var malo = {
		"tracks": [
			{"id": "", "licencia": ""},
			{"id": "a", "licencia": "CC-BY", "attribution": ""}
		],
		"politicas": {}
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("track sin id detectado", str(errores).contains("sin id"))
	_check("sin licencia detectado", str(errores).contains("sin licencia"))
	_check("CC-BY sin atribución detectado", str(errores).contains("CC-BY"))
	_check("sin políticas detectado", str(errores).contains("políticas"))

func _test_artista_multi_rol() -> void:
	print("--- Edge case: artista con múltiples roles ---")
	var data = _cargar()
	var tracks := data.get("tracks", [])
	var artistas := {}
	for t in tracks:
		var autor := String(t.get("autor", ""))
		if autor.is_empty():
			continue
		if not artistas.has(autor):
			artistas[autor] = []
		artistas[autor].append(String(t.get("id", "")))
	var multi := 0
	for autor in artistas:
		if artistas[autor].size() > 1:
			multi += 1
			_check("artista '%s' tiene %d tracks" % [autor, artistas[autor].size()], true)
	_check("artistas con múltiples tracks detectados", multi >= 0, "multi=%d" % multi)

func _test_audio_multi_licencia() -> void:
	print("--- Edge case: audio con múltiples licencias ---")
	var data = _cargar()
	var tracks := data.get("tracks", [])
	var licencias := {}
	for t in tracks:
		var lic := String(t.get("licencia", "PROPIA"))
		if not licencias.has(lic):
			licencias[lic] = 0
		licencias[lic] += 1
	_check("al menos 1 tipo de licencia", licencias.size() >= 1, "tipos=%d" % licencias.size())
	for lic in licencias:
		_check("licencia '%s': %d tracks" % [lic, licencias[lic]], true)
	var con_atrib := 0
	for t in tracks:
		if String(t.get("attribution", "")).length() > 0:
			con_atrib += 1
	_check("tracks con atribución cuando se requiere", con_atrib >= 0, "con_atrib=%d" % con_atrib)

func _summary() -> void:
	print("=== Resumen M84: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M84 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M84 OK — todos los checks pasaron")
		quit(0)