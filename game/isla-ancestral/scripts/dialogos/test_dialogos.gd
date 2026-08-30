# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M21: Test headless del sistema de dialogos (grafo, manager, validador, opciones).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_dialogos.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	_test_carga_valida()
	_test_flujo_lineal()
	_test_opciones()
	_test_eventos_y_sesion()
	_test_validador_errores()
	_test_reinicio_dialogo()
	print("=== TEST DIALOGOS M21: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

func _test_carga_valida() -> void:
	var grafo := DialogueGraph.load_from_json("res://data/dialogues/catalina_hola.json")
	_check(grafo.dialogue_id == "catalina_hola", "grafo cargado con id")
	_check(grafo.nodes.size() >= 5, "grafo con nodos cargados")
	_check(grafo.validate().is_empty(), "grafo valido sin problemas")

func _test_flujo_lineal() -> void:
	var grafo := DialogueGraph.load_from_json("res://data/dialogues/catalina_hola.json")
	var manager = load("res://scripts/dialogos/dialogue_manager.gd").new()
	_check(manager.start_dialogue("catalina_hola"), "start_dialogue OK")
	_check(manager.is_dialogue_active(), "dialogo activo")
	_check(manager.get_current_speaker_key() == "npc.catalina", "hablante correcto")
	# avanzar hasta el nodo de opciones (saludo -> pregunta)
	manager.advance()
	_check(manager.is_dialogue_active(), "avance a pregunta")
	# limpiar para el siguiente test
	manager.stop_dialogue()
	manager._grafos_cache.clear()

func _test_opciones() -> void:
	var manager = load("res://scripts/dialogos/dialogue_manager.gd").new()
	manager.start_dialogue("catalina_hola")
	var elegidas: Array = []
	manager.option_selected.connect(func(i: int): elegidas.append(i))
	manager.advance()  # pregunta (opciones)
	_check(manager._nodo_actual.tipo == DialogueNode.TIPO_OPCIONES, "nodo de opciones")
	manager.choose_option(0)
	_check(not elegidas.is_empty() and elegidas[0] == 0, "opcion 0 elegida y emitida")
	manager.stop_dialogue()
	manager._grafos_cache.clear()

func _test_eventos_y_sesion() -> void:
	var manager = load("res://scripts/dialogos/dialogue_manager.gd").new()
	manager.start_dialogue("catalina_hola")
	var terminados: Array = []
	manager.dialogue_ended.connect(func(id, ultimo): terminados.append(id))
	# recorrer todo el arbol (bienvenida acumula amistad)
	for i in range(10):
		if not manager.is_dialogue_active():
			break
		if manager._nodo_actual.tipo == DialogueNode.TIPO_OPCIONES:
			manager.choose_option(0)
		else:
			manager.advance()
	_check(terminados.has("catalina_hola"), "dialogo terminado (FIN)")
	_check(manager.get_session_vars().get("catalina_amistad", 0.0) >= 1.0, "effect de amistad aplicado a la sesion")
	manager._grafos_cache.clear()

func _test_validador_errores() -> void:
	var grafo := DialogueGraph.new()
	_check(not grafo.validate().is_empty(), "grafo vacio invalido")
	var g2 := DialogueGraph.new()
	g2.dialogue_id = "mal"
	g2.start_node_id = "a"
	g2.nodes["a"] = DialogueNode.new()
	g2.nodes["a"].id = "a"
	g2.nodes["a"].next_id = "fantasma"
	_check(not g2.validate().is_empty(), "next inexistente detectado")


func _test_reinicio_dialogo() -> void:
	# Bug 'solo funciona una vez': debe poder iniciarse de nuevo tras terminar.
	var manager = load("res://scripts/dialogos/dialogue_manager.gd").new()
	var terminados: Array = []
	manager.dialogue_ended.connect(func(id, ultimo): terminados.append(id))
	# Primera ronda
	_check(manager.start_dialogue("catalina_hola"), "1er inicio OK")
	for i in range(10):
		if not manager.is_dialogue_active():
			break
		if manager._nodo_actual.tipo == DialogueNode.TIPO_OPCIONES:
			manager.choose_option(0)
		else:
			manager.advance()
	_check(not manager.is_dialogue_active(), "1er dialogo termino (no activo)")
	_check(terminados.size() == 1, "dialogue_ended emitido 1 vez")
	# Segunda ronda (BLOQUEO DEBERIA PERMITIRLO)
	_check(manager.start_dialogue("catalina_hola"), "2do inicio OK (reinicio)")
	for i in range(10):
		if not manager.is_dialogue_active():
			break
		if manager._nodo_actual.tipo == DialogueNode.TIPO_OPCIONES:
			manager.choose_option(1)
		else:
			manager.advance()
	_check(not manager.is_dialogue_active(), "2do dialogo termino")
	_check(terminados.size() == 2, "dialogue_ended emitido 2 veces (reinicio funciona)")
	manager._grafos_cache.clear()
	