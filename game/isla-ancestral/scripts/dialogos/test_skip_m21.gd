# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M21 (iter 7): Test headless de skip_all (salto rapido) en DialogueManager.
#   - grafo LINEA*->FIN: skip_all termina el dialogo.
#   - grafo LINEA->OPCIONES: skip_all se detiene en la bifurcacion (dialogo activo).
#   - efectos de nodos LINEA se aplican durante el salto.
#   - tras detenerse en OPCIONES, choose_option sigue funcionando.
#
# Ejecutar: Godot --headless --path game/isla-ancestral \
#           --script res://scripts/dialogos/test_skip_m21.gd

extends SceneTree

var _fallos: int = 0
var _dm: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_dm = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(_dm)
	_test_skip_hasta_fin()
	_test_skip_se_detiene_en_opciones()
	_test_efectos_en_salto()
	_test_choose_tras_skip()
	print("=== TEST SKIP M21 (skip_all): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

func _grafo_lineas_a_fin() -> DialogueGraph:
	var g := DialogueGraph.new()
	g.dialogue_id = "skip_fin"
	g.start_node_id = "s"
	var s := DialogueNode.new(); s.id = "s"; s.tipo = DialogueNode.TIPO_LINEA; s.next_id = "a"; g.nodes["s"] = s
	var a := DialogueNode.new(); a.id = "a"; a.tipo = DialogueNode.TIPO_LINEA; a.next_id = "b"; g.nodes["a"] = a
	var b := DialogueNode.new(); b.id = "b"; b.tipo = DialogueNode.TIPO_LINEA; b.next_id = "fin"; g.nodes["b"] = b
	var fin := DialogueNode.new(); fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN; g.nodes["fin"] = fin
	return g

func _test_skip_hasta_fin() -> void:
	_dm._grafos_cache["skip_fin"] = _grafo_lineas_a_fin()
	_check(_dm.start_dialogue("skip_fin"), "start skip_fin OK")
	_dm.skip_all()
	_check(not _dm.is_dialogue_active(), "skip_all termina dialogo LINEA*->FIN")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()

func _grafo_linea_a_opciones() -> DialogueGraph:
	var g := DialogueGraph.new()
	g.dialogue_id = "skip_opt"
	g.start_node_id = "s"
	var s := DialogueNode.new(); s.id = "s"; s.tipo = DialogueNode.TIPO_LINEA; s.next_id = "opt"; g.nodes["s"] = s
	var opt := DialogueNode.new(); opt.id = "opt"; opt.tipo = DialogueNode.TIPO_OPCIONES
	opt.options = [
		{"text_key": "ir a c", "next_id": "c"},
		{"text_key": "ir a d", "next_id": "d"},
	]
	g.nodes["opt"] = opt
	var c := DialogueNode.new(); c.id = "c"; c.tipo = DialogueNode.TIPO_LINEA; c.next_id = "fin"; g.nodes["c"] = c
	var d := DialogueNode.new(); d.id = "d"; d.tipo = DialogueNode.TIPO_LINEA; d.next_id = "fin"; g.nodes["d"] = d
	var fin := DialogueNode.new(); fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN; g.nodes["fin"] = fin
	return g

func _test_skip_se_detiene_en_opciones() -> void:
	_dm._grafos_cache["skip_opt"] = _grafo_linea_a_opciones()
	_check(_dm.start_dialogue("skip_opt"), "start skip_opt OK")
	_dm.skip_all()
	_check(_dm.is_dialogue_active(), "skip_all deja dialogo activo en OPCIONES")
	if _dm._nodo_actual != null:
		_check(_dm._nodo_actual.id == "opt", "skip_all se detiene en nodo 'opt' (OPCIONES)")
		_check(_dm._nodo_actual.tipo == DialogueNode.TIPO_OPCIONES, "nodo detenido es OPCIONES")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()

func _test_efectos_en_salto() -> void:
	var g := DialogueGraph.new()
	g.dialogue_id = "skip_eff"
	g.start_node_id = "s"
	var s := DialogueNode.new(); s.id = "s"; s.tipo = DialogueNode.TIPO_LINEA
	s.effects = [{"clave": "visto_intro", "accion": "set", "valor": true}]
	s.next_id = "fin"; g.nodes["s"] = s
	var fin := DialogueNode.new(); fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN; g.nodes["fin"] = fin
	_dm._grafos_cache["skip_eff"] = g
	_check(_dm.start_dialogue("skip_eff"), "start skip_eff OK")
	_dm.skip_all()
	_check(bool(_dm.get_session_vars().get("visto_intro", false)), "efecto de LINEA aplicado durante skip_all")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()

func _test_choose_tras_skip() -> void:
	_dm._grafos_cache["skip_opt"] = _grafo_linea_a_opciones()
	_check(_dm.start_dialogue("skip_opt"), "start skip_opt (2) OK")
	_dm.skip_all()
	_check(_dm.is_dialogue_active(), "dialogo activo tras skip en OPCIONES")
	_dm.choose_option(0)  # elige ir a c -> nodo LINEA 'c' (no se auto-avanza)
	_check(_dm.is_dialogue_active(), "tras choose_option el dialogo queda en LINEA 'c' (espera avance)")
	if _dm._nodo_actual != null:
		_check(_dm._nodo_actual.id == "c", "choose_option(0) lleva al nodo 'c'")
	_dm.skip_all()  # fast-forward c -> fin -> stop
	_check(not _dm.is_dialogue_active(), "skip_all tras elegir termina el dialogo (c -> fin)")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()
