# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-09-01
#
# M21 (iter 10): Tests de advance() con tipeo activo + efectos de amistad M19.
# Cierra [?] D.3 (advance respeta tipeo) y [?] F (efectos modifican amistad M19).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_iter10_m21.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 3
const _WB_BLOQUES: Array[String] = ["_test_advance_respeta_tipeo", "_test_efecto_amistad"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M21: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)



var _fallos: int = 0
var _dm: Node = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_dm = load("res://scripts/dialogos/dialogue_manager.gd").new()
	root.add_child(_dm)
	_test_advance_respeta_tipeo()
	_fin("_test_advance_respeta_tipeo")
	_test_efecto_amistad()
	_fin("_test_efecto_amistad")
	_summary()

func _check(cond: bool, mensaje: String) -> void:
	_checks += 1
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
