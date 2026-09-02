# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M97: Steam Store Page — Test headless
# Valida: StorePageValidator (descripción ES/EN, about, keywords, tags,
# requisitos, assets). Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/store/store_page_validator.gd")
const RUTA_DATA := "res://data/store/store_page.json"

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M97] Test de Steam Store Page ===")
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
	print("--- Datos: store_page.json ---")
	var data = _cargar()
	_check("store_page.json cargado", not data.is_empty())
	_check("descripción ES existe", not String(data.get("descripcion_corta", {}).get("es", "")).is_empty())
	_check("descripción EN existe", not String(data.get("descripcion_corta", {}).get("en", "")).is_empty())
	_check("6 secciones About", data.get("about_secciones", []).size() == 6, "size=%d" % data.get("about_secciones", []).size())
	_check("15 keywords", data.get("keywords", []).size() == 15, "size=%d" % data.get("keywords", []).size())
	_check("8 tags", data.get("tags", []).size() == 8, "size=%d" % data.get("tags", []).size())
	_check("8 assets", data.get("assets", []).size() == 8, "size=%d" % data.get("assets", []).size())

func _test_validator() -> void:
	print("--- StorePageValidator: data real ---")
	var data = _cargar()
	var errores = _SC_VALIDATOR.validar(data)
	_check("data válida (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- StorePageValidator: errores detectados ---")
	var malo = {
		"descripcion_corta": {"es": "", "en": "", "max_caracteres": 300},
		"about_secciones": [],
		"keywords": [],
		"tags": ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v"],
		"requisitos": {"so_min": "", "so_rec": "", "ram_min": "", "ram_rec": "", "disco": ""},
		"assets": []
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("descripción vacía detectada", str(errores).contains("vacía"))
	_check("sin secciones detectado", str(errores).contains("5"))
	_check("sin keywords detectado", str(errores).contains("keywords"))
	_check("más de 20 tags detectado", str(errores).contains("20"))
	_check("requisitos vacíos detectados", str(errores).contains("Requisito"))
	_check("assets vacíos detectados", str(errores).contains("assets"))

func _summary() -> void:
	print("=== Resumen M97: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M97 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M97 OK — todos los checks pasaron")
		quit(0)