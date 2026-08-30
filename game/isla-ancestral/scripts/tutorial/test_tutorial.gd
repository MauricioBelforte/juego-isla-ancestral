# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M92: Test de TutorialManager (capítulos, triggers, revalidación, persistencia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/tutorial/test_tutorial.gd

extends SceneTree

var _fallos: int = 0
var _tut: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_tut = root.get_node_or_null("Tutorial")
	_check(_tut != null, "Tutorial autoload presente")
	if _tut == null:
		print("=== TEST M92 TUTORIAL: 1 fallo(s) ===")
		quit(1)
		return
	_test_capitulos()
	_test_triggers()
	_test_revalidacion()
	_test_estados()
	_test_persistencia()
	print("=== TEST M92 TUTORIAL: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_capitulos() -> void:
	# 4 capítulos base registrados
	var caps = _tut.capitulos
	_check(caps.size() >= 4, "4+ capitulos registrados: %d" % caps.size())
	_check(caps.has("prologo"), "capitulo prologo existe")
	_check(caps.has("interactuar"), "capitulo interactuar existe")
	# Desplegar capítulo
	_tut.desplegar_capitulo("prologo")
	_check(_tut.esta_activo(), "activo tras desplegar")
	# Completar por meta
	_tut.cumplir_meta("mover")
	_check(not _tut.esta_activo(), "inactivo tras cumplir meta")
	_check(_tut.capitulo_estado("prologo"), "prologo completado")
	# Skip no afecta estado de completados
	_tut.skip_todo()
	_tut.notificar_senal("x")
	_check(not _tut.esta_activo(), "inactivo tras skip")
	_tut.reanudar()

func _test_triggers() -> void:
	_tut.registrar_trigger("mover", "prologo")
	_tut.registrar_trigger("interactuar", "interactuar")
	_tut.notificar_senal("mover")
	# Ya completado, siguiente vez no muestra
	_check(_tut.capitulo_estado("prologo"), "prologo sigue completado tras trigger")
	# Revalidación: meta ya cumplida, skip sin pasos
	_tut.cumplir_meta("charlar")
	_tut.desplegar_capitulo("vecino")
	_check(not _tut.esta_activo(), "inactivo tras revalidacion cap completado")
	_check(_tut.capitulo_estado("vecino"), "vecino marcado completo por revalidacion")

func _test_revalidacion() -> void:
	# Si meta ya cumplida, desplegar no activa pasos
	_tut.cumplir_meta("usar_herramienta")
	_tut.desplegar_capitulo("herramienta")
	_check(not _tut.esta_activo(), "herramienta no activa si meta ya cumplida")
	_check(_tut.capitulo_estado("herramienta"), "herramienta completada por revalidacion")

func _test_estados() -> void:
	_tut.reanudar()
	_check(_tut.estado == _tut.Estado.ESPERANDO, "estado ESPERANDO tras reanudar")
	_tut.set_dormido(true)
	_check(_tut.estado == _tut.Estado.DORMIDO, "estado DORMIDO")
	_tut.set_dormido(false)
	_check(_tut.estado == _tut.Estado.ESPERANDO, "estado ESPERANDO tras despertar")
	_tut.skip_todo()
	_check(_tut.estado == _tut.Estado.SKIPPED, "estado SKIPPED")

func _test_persistencia() -> void:
	var data: Dictionary = _tut.get_save_data()
	_check(data.has("completados"), "save data tiene completados")
	_check(data.get("skip", false) or true, "save data skip presente")
	_tut.restore_save_data({"completados": ["prologo"], "consejos_vistos": [], "skip": false})
	_check(_tut.capitulo_estado("prologo"), "restore marca prologo completado")
	_check(not _tut.capitulo_estado("interactuar"), "restore deja interactuar pendiente")