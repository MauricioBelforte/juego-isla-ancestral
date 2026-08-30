# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21: Test de condiciones/efectos con WorldStateService (RF5).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_condiciones_mundo.gd
# ⚠️ En _init() de un SceneTree script NO existe get_node_or_null() (aun no es Node);
# usar root.get_node_or_null(). La logica corre con call_deferred para que los
# autoloads ya existan.

extends SceneTree

var _fallos: int = 0
var _dm: Node = null
var _ws: Node = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ws = root.get_node_or_null("WorldState")
	_check(_ws != null, "WorldState autoload presente")
	if _ws == null:
		print("=== TEST CONDICIONES MUNDO M21: 1 fallo(s) (sin WorldState) ===")
		quit(1)
		return
	_dm = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(_dm)
	_test_condiciones_nodo()
	_test_efectos_bandera_world()
	_test_condicion_sesion()
	print("=== TEST CONDICIONES MUNDO M21: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

func _grafo_prueba() -> DialogueGraph:
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = "test_condiciones"
	grafo.start_node_id = "inicio"
	var inicio := DialogueNode.new()
	inicio.id = "inicio"
	inicio.tipo = DialogueNode.TIPO_LINEA
	inicio.next_id = "condicional"
	grafo.nodes["inicio"] = inicio
	var condicional := DialogueNode.new()
	condicional.id = "condicional"
	condicional.tipo = DialogueNode.TIPO_LINEA
	condicional.next_id = "fin"
	# Condicion: estacion == 0 (primavera)
	condicional.conditions = [{"clave": "estacion", "operador": "==", "valor": 0}]
	grafo.nodes["condicional"] = condicional
	var fin := DialogueNode.new()
	fin.id = "fin"
	fin.tipo = DialogueNode.TIPO_FIN
	grafo.nodes["fin"] = fin
	return grafo

func _test_condiciones_nodo() -> void:
	var grafo := _grafo_prueba()
	_dm._grafos_cache["test_condiciones"] = grafo
	var vistos: Array = []
	_dm.node_entered.connect(func(_id, _sk, _t, _tp, _op): vistos.append(_id))
	var estacion_real: int = int(_ws.get_value("estacion", -1))
	_check(_dm.start_dialogue("test_condiciones"), "start con condiciones OK")
	_dm.advance()  # inicio -> condicional
	var entro_condicional: bool = vistos.has("condicional")
	if estacion_real == 0:
		_check(entro_condicional, "condicional entro con estacion==0")
	else:
		_check(not entro_condicional, "condicional SALTADO con estacion!=0 (real=%d)" % estacion_real)
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()

func _test_efectos_bandera_world() -> void:
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = "test_flags"
	grafo.start_node_id = "n1"
	var n1 := DialogueNode.new()
	n1.id = "n1"
	n1.tipo = DialogueNode.TIPO_EVENTO
	n1.effects = [
		{"clave": "flag_hablo_con_catalina", "accion": "set", "valor": true, "destino": "world"},
		{"clave": "catalina_charlas", "accion": "increment", "valor": 1, "destino": "world"},
	]
	n1.next_id = "fin"
	grafo.nodes["n1"] = n1
	var fin := DialogueNode.new()
	fin.id = "fin"
	fin.tipo = DialogueNode.TIPO_FIN
	grafo.nodes["fin"] = fin
	_dm._grafos_cache["test_flags"] = grafo
	_dm.start_dialogue("test_flags")
	_check(bool(_ws.get_flag("flag_hablo_con_catalina", false)), "flag world seteada por effect")
	_check(float(_ws.get_flag("catalina_charlas", 0.0)) == 1.0, "flag world incrementada")
	_check(not _dm.is_dialogue_active(), "dialogo con evento termino")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()
	_ws.set_flag("flag_hablo_con_catalina", null)
	_ws.set_flag("catalina_charlas", null)

func _test_condicion_sesion() -> void:
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = "test_sesion"
	grafo.start_node_id = "s1"
	var s1 := DialogueNode.new()
	s1.id = "s1"
	s1.tipo = DialogueNode.TIPO_LINEA
	s1.next_id = "ramificacion"
	grafo.nodes["s1"] = s1
	var rama := DialogueNode.new()
	rama.id = "ramificacion"
	rama.tipo = DialogueNode.TIPO_LINEA
	rama.conditions = [{"clave": "catalina_amistad", "operador": ">=", "valor": 3}]
	rama.next_id = "fin"
	grafo.nodes["ramificacion"] = rama
	var fin := DialogueNode.new()
	fin.id = "fin"
	fin.tipo = DialogueNode.TIPO_FIN
	grafo.nodes["fin"] = fin
	_dm._grafos_cache["test_sesion"] = grafo
	var vistos: Array = []
	_dm.node_entered.connect(func(_id, _sk, _t, _tp, _op): vistos.append(_id))
	_dm.start_dialogue("test_sesion", {"catalina_amistad": 1.0})
	_dm.advance()  # s1 -> ramificacion (condicion amistad >= 3)
	_check(not vistos.has("ramificacion"), "rama bloqueada con amistad baja")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()
	_dm._session_vars.clear()
	vistos.clear()
	_dm._grafos_cache["test_sesion"] = grafo
	_dm.start_dialogue("test_sesion", {"catalina_amistad": 5.0})
	_dm.advance()
	_check(vistos.has("ramificacion"), "rama entra con amistad alta")
	_dm.stop_dialogue()
	_dm._grafos_cache.clear()
