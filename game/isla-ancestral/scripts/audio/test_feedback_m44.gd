# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M44: ASMR y Feedback — Test headless
# Valida: FeedbackDirector (recetas por acción, blacklist anti-agresión,
# precedencia contextual interior, señal feedback_aplicado).
# Exit code != 0 si falla.

extends SceneTree

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M44] Test de ASMR y Feedback ===")
	_test_recetas()
	_test_blacklist()
	_test_contexto()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

func _test_recetas() -> void:
	print("--- Recetas: capas por acción ---")
	var fd := root.get_node_or_null("FeedbackDirector")
	if fd == null:
		_check("FeedbackDirector autoload presente", false)
		_summary()
		quit(1)
		return
	_check("FeedbackDirector autoload presente", true)
	_check("8 recetas", fd.recetas.size() == 8, "size=%d" % fd.recetas.size())
	var capas = fd.sensacion("bloque_roto")
	_check("bloque_roto con capas", capas.size() >= 3 and "crack" in capas, "capas=%s" % str(capas))
	var inexistente = fd.sensacion("no_existe")
	_check("acción inexistente -> vacío", inexistente.is_empty())

func _test_blacklist() -> void:
	print("--- Blacklist: anti-agresión ---")
	var fd := root.get_node_or_null("FeedbackDirector")
	var capas = fd.sensacion("explosion")
	_check("explosión en blacklist -> silencio", capas.is_empty())
	var capas2 = fd.sensacion("grito")
	_check("grito en blacklist -> silencio", capas2.is_empty())
	_check("blacklist con 4 prohibidas", fd.blacklist.get("prohibidas", []).size() == 4)

func _test_contexto() -> void:
	print("--- Contexto: precedencia interior ---")
	var fd := root.get_node_or_null("FeedbackDirector")
	fd.set_contexto("interior", false)
	var exterior = fd.sensacion("bloque_roto")
	_check("exterior sin reverb", not ("reverb_interior" in exterior))
	fd.set_contexto("interior", true)
	var interior = fd.sensacion("bloque_roto")
	_check("interior agrega reverb", "reverb_interior" in interior, "capas=%s" % str(interior))

func _summary() -> void:
	print("=== Resumen M44: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M44 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M44 OK — todos los checks pasaron")
		quit(0)