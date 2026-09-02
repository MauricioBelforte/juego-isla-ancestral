# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M124: Contenido Generado por Usuarios — Test headless
# Valida: UgcManager (catálogo, por estado/tipo) y UgcValidator.
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_VALIDATOR := preload("res://scripts/ugc/ugc_validator.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M124] Test de UGC ===")
	_test_manager()
	_test_catalogo()
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
	print("--- UgcManager: config data-driven ---")
	var um := root.get_node_or_null("UgcManager")
	if um == null:
		_check("UgcManager autoload presente", false)
		_summary()
		quit(1)
		return
	_check("UgcManager autoload presente", true)
	_check("3 piezas UGC", um.config.get("contenido", []).size() == 3, "size=%d" % um.config.get("contenido", []).size())
	_check("5 tipos válidos", um.tipos_validos().size() == 5, "size=%d" % um.tipos_validos().size())
	_check("4 estados válidos", um.estados_validos().size() == 4, "size=%d" % um.estados_validos().size())

func _test_catalogo() -> void:
	print("--- Catálogo: por estado y tipo ---")
	var um := root.get_node_or_null("UgcManager")
	var publicado = um.por_estado("publicado")
	_check("2 publicadas", publicado.size() == 2, "size=%d" % publicado.size())
	var revision = um.por_estado("revision")
	_check("1 en revisión", revision.size() == 1, "size=%d" % revision.size())
	var decoracion = um.por_tipo("decoracion")
	_check("2 decoraciones", decoracion.size() == 2, "size=%d" % decoracion.size())
	var c1 = um.contenido("creacion_1")
	_check("creacion_1 existe", not c1.is_empty() and c1.get("rating", 0) == 4.5)
	_check("contenido inexistente -> {}", um.contenido("no_existe").is_empty())

func _test_validator() -> void:
	print("--- UgcValidator: data real ---")
	var um := root.get_node_or_null("UgcManager")
	var errores = _SC_VALIDATOR.validar(um.config)
	_check("catálogo válido (0 errores)", errores.is_empty(), "errores=%s" % str(errores))
	_check("reporte OK", _SC_VALIDATOR.reporte([]).contains("OK"))

func _test_validator_errores() -> void:
	print("--- UgcValidator: errores detectados ---")
	var malo = {
		"tipos_validos": [],
		"estados_validos": [],
		"politica": {},
		"contenido": [
			{"id": "", "tipo": "zzz", "estado": "zzz"},
			{"id": "a", "tipo": "zzz", "estado": "zzz"}
		]
	}
	var errores = _SC_VALIDATOR.validar(malo)
	_check("sin tipos detectado", str(errores).contains("tipos"))
	_check("sin estados detectado", str(errores).contains("estados"))
	_check("sin política detectado", str(errores).contains("política"))
	_check("tipo inválido detectado", str(errores).contains("zzz"))
	_check("estado inválido detectado", str(errores).contains("zzz"))

func _summary() -> void:
	print("=== Resumen M124: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M124 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M124 OK — todos los checks pasaron")
		quit(0)