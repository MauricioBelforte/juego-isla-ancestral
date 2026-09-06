# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M63 P1: Test de pantalla de carga (mostrar/ocultar/progreso real).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/stream/test_pantalla_carga.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var pc := root.get_node_or_null("PantallaCarga")
	_check(pc != null, "PantallaCarga autoload presente")
	if pc == null:
		print("=== TEST M63 P1: 1 fallo(s) ===")
		quit(1)
		return
	# Inicialmente oculta
	_check(not pc.visible, "pantalla inicia oculta")
	# Mostrar
	pc.mostrar()
	_check(pc.visible, "pantalla visible tras mostrar()")
	# Simular progreso del StreamManager
	var sm := root.get_node_or_null("StreamManager")
	_check(sm != null, "StreamManager presente")
	if sm != null:
		sm.encolar("test_carga_1", "chunk_lod0", 1, func(): pass)
		sm.encolar("test_carga_2", "textura_atlas", 1, func(): pass)
		sm.encolar("test_carga_3", "banco_audio", 1, func(): pass)
		# Procesar la cola
		for i in range(50):
			sm._process(0.016)
		# Verificar que la barra creció
		var barra: ColorRect = pc.get_node_or_null("Barra")
		_check(barra != null, "barra existe")
		if barra != null:
			_check(barra.size.x > 0, "barra con ancho > 0: %.1f" % barra.size.x)
	# Ocultar
	pc.ocultar()
	_check(not pc.visible, "pantalla oculta tras ocultar()")
	print("=== TEST M63 P1: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
