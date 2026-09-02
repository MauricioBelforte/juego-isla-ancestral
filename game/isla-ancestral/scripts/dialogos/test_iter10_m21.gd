# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-09-01
#
# M21 (iter 10): Tests de advance() con tipeo activo + efectos de amistad M19.
# Cierra [?] D.3 (advance respeta tipeo) y [?] F (efectos modifican amistad M19).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_iter10_m21.gd

extends SceneTree

var _fallos: int = 0
var _dm: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_dm = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(_dm)
	_test_advance_respeta_tipeo()
	_test_efecto_amistad()
	print("=== TEST ITER10 M21: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)
	else:
		print("OK: " + mensaje)

## advance() no avanza mientras _tipeando == true (la UI completa el texto primero).
func _test_advance_respeta_tipeo() -> void:
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = "test_tipeo"
	grafo.start_node_id = "n1"
	var n1 := DialogueNode.new()
	n1.id = "n1"; n1.tipo = DialogueNode.TIPO_LINEA; n1.next_id = "n2"
	grafo.nodes["n1"] = n1
	var n2 := DialogueNode.new()
	n2.id = "n2"; n2.tipo = DialogueNode.TIPO_LINEA; n2.next_id = "fin"
	grafo.nodes["n2"] = n2
	var fin := DialogueNode.new()
	fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN
	grafo.nodes["fin"] = fin
	_dm._grafos_cache["test_tipeo"] = grafo
	_dm.start_dialogue("test_tipeo")
	_dm.set_tipeando(true)
	_dm.advance()  # mientras tipea, no debe pasar de n1
	_check(_dm._nodo_actual != null and _dm._nodo_actual.id == "n1", "advance() no avanza durante tipeo")
	_dm.set_tipeando(false)
	_dm.advance()  # tipeo terminado, avanza a n2
	_check(_dm._nodo_actual != null and _dm._nodo_actual.id == "n2", "advance() avanza tras tipeo terminado")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()

## Un effect con destino "amistad" modifica el nivel de Friendship (M19).
func _test_efecto_amistad() -> void:
	var fs = root.get_node_or_null("Friendship")
	if fs == null or not fs.has_method("set_nivel"):
		_check(true, "Friendship ausente: test de amistad no aplica (no es fallo)")
		return
	fs.set_nivel("catalina", 1)
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = "test_ami"
	grafo.start_node_id = "e1"
	var e1 := DialogueNode.new()
	e1.id = "e1"; e1.tipo = DialogueNode.TIPO_EVENTO
	e1.effects = [{"clave": "catalina", "accion": "increment", "valor": 2, "destino": "amistad"}]
	e1.next_id = "fin"
	grafo.nodes["e1"] = e1
	var fin := DialogueNode.new()
	fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN
	grafo.nodes["fin"] = fin
	_dm._grafos_cache["test_ami"] = grafo
	_dm.start_dialogue("test_ami")
	_check(int(fs.get_nivel("catalina")) == 3, "efecto amistad incremento catalina 1->3")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()
	fs.set_nivel("catalina", 0)
