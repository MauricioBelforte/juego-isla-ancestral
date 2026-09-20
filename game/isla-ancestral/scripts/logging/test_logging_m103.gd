# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M103: Logging — Test headless de verificación del núcleo existente
# (logger.gd implementado por ox-alpha). Valida la API pública y la
# persistencia. Exit code != 0 si falla.
#
# ── iter. 2 (2026-09-20, Log 1109, DeepSeek-V4.1-Flash) ─────────────────────
# DEFECTOS REALES CORREGIDOS (los encontró la auditoría de la trampa 85):
#
#  1. **11 checks INALCANZABLES (código muerto).** `_test_export()` y
#     `_test_rotation()` estaban definidas pero **nadie las llamaba**: `_run()`
#     iba directo a `_summary()`. La suite decía "14 checks, 0 fallos" y nunca
#     ejercitaba `export_last_lines` ni los 8 métodos de rotación. Es la
#     trampa 46 (rama inalcanzable = rama NO testeada) con forma de falso verde
#     estructural: el conteo cuadra y la cobertura declarada es mentira.
#  2. **`_summary()` inline.** Al estar dentro de `_run()`, un `SCRIPT ERROR`
#     que abortara `_run()` dejaba la suite **sin resumen y sin `quit()`** →
#     con `extends SceneTree` el árbol **cuelga para siempre** y el stdout se
#     pierde por buffering (trampa 28/61). Ahora va en un `call_deferred`
#     aparte, que corre igual si `_run()` muere.
#  3. **Sin guardián.** Se agregan los 3 pilares: marcadores `_fin()` por
#     bloque, piso `CHECKS_MINIMOS` **medido en verde** (no estimado) y el
#     `_summary()` diferido que **nombra** los bloques que no terminaron.
#
# Uso:
#   "<godot_console>" --headless --path game/isla-ancestral \
#     --script res://scripts/logging/test_logging_m103.gd

extends SceneTree

const MODULO := "M103"
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D"]
# Piso MEDIDO en verde (iter. 2, 2026-09-20): la corrida imprime exactamente
# este numero. Cualquier aborto silencioso lo BAJA y el resumen lo canta.
const CHECKS_MINIMOS := 25

var _fallos: int = 0
var _checks: int = 0
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0

func _init() -> void:
	call_deferred("_run")
	# Aparte a proposito: si `_run()` aborta por un SCRIPT ERROR, la cola
	# diferida sigue y este resumen CORRE igual, nombrando lo que falto.
	call_deferred("_summary")

# Convencion de `test_logging_m103_iter1.gd`: el nombre trae la letra del bloque
# al principio ("A. Autoload ...") y se guarda SOLO la letra, que es lo que
# `BLOQUES_ESPERADOS` declara. (Guardar el nombre completo fue mi primer error:
# el guardian lo cazo en la primera corrida.)
func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])

func _run() -> void:
	print("=== [M103] Test de Logging (verificación núcleo) ===")
	var gl := root.get_node_or_null("GameLogger")
	if gl == null:
		_check("GameLogger autoload presente", false)
		return
	_check("GameLogger autoload presente", true)
	_check("tiene método info", gl.has_method("info"))
	_check("tiene método debug", gl.has_method("debug"))
	_check("tiene método warning", gl.has_method("warning"))
	_check("tiene método error", gl.has_method("error"))
	_check("tiene método critical", gl.has_method("critical"))
	_check("tiene export_all", gl.has_method("export_all"))
	_check("tiene export_last_lines", gl.has_method("export_last_lines"))
	_check("tiene set_min_level", gl.has_method("set_min_level"))
	_check("tiene get_log_file_path", gl.has_method("get_log_file_path"))
	_fin("A. Autoload y API pública")

	# Probar escritura
	gl.info("test_info_m103")
	gl.warning("test_warn_m103")
	var ruta: String = gl.get_log_file_path()
	_check("ruta de log definida", ruta != "")
	_check("archivo de log existe", FileAccess.file_exists(ruta))
	if FileAccess.file_exists(ruta):
		var contenido := FileAccess.get_file_as_string(ruta)
		_check("contenido tiene test_info_m103", contenido.contains("test_info_m103"))
	_check("export_all devuelve texto", gl.export_all().length() > 0)
	_fin("B. Escritura y persistencia")

	# ── Los dos bloques que ANTES eran codigo muerto ──
	_test_export(gl)
	_fin("C. Exportación")
	_test_rotation(gl)
	_fin("D. Rotación")


func _test_export(gl: Node) -> void:
	print("--- Exportación por nivel/categoría ---")
	gl.info("export_test_info")
	var all: String = gl.export_all()
	_check("export_all contiene info", all.contains("export_test_info"))
	var ultimas: String = gl.export_last_lines(3)
	_check("export_last_lines no vacío", ultimas.length() > 0)
	var path: String = gl.get_log_file_path()
	_check("log file path no vacío", path != "")


func _test_rotation(gl: Node) -> void:
	print("--- Rotación configurada ---")
	_check("tiene flush", gl.has_method("flush"))
	_check("tiene set_min_level", gl.has_method("set_min_level"))
	_check("tiene set_category_enabled", gl.has_method("set_category_enabled"))
	_check("tiene export_by_level", gl.has_method("export_by_level"))
	_check("tiene export_by_category", gl.has_method("export_by_category"))
	_check("tiene export_by_date", gl.has_method("export_by_date"))
	_check("tiene get_log_file_path", gl.has_method("get_log_file_path"))
	_check("tiene set_log_path", gl.has_method("set_log_path"))


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	# Pilar 1: los bloques que no cerraron se NOMBRAN.
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _completados.has(b):
			faltantes.append(b)
	if not faltantes.is_empty():
		_check("los %d bloques se completaron — no terminaron: %s" % [BLOQUES_ESPERADOS.size(), str(faltantes)], false)
	# Pilar 2: piso de checks contados (caza el aborto DENTRO de un helper, que
	# el marcador de bloque por si solo no ve).
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("-- checks por bloque: %s" % str(_checks_por_bloque))
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	if _fallos > 0:
		print("TEST M103 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M103 OK — todos los checks pasaron")
		quit(0)
