# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21 (Task B): Test headless de DialogGraphValidator — validacion estatica de grafos.
#   - grafos reales (reaccion_regalo, reaccion_nivel) => 0 problemas.
#   - grafo roto: nodo huerfano => detectado.
#   - grafo roto: operador de condicion invalido => detectado.
#   - grafo roto: clave de mundo desconocida (con allowlist) => detectado.
#   - texto JSON malformado => ok=false.
#
# NOTA: en --script los autoloads se anaden al arbol DESPUES de _init(), por eso la
# ejecucion se difiere con call_deferred.

extends SceneTree

var _fallos: int = 0
var _validador = null

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	_validador = load("res://scripts/dialogos/dialog_graph_validator.gd")
	_test_grafos_reales_ok()
	_test_huerfano()
	_test_operador_invalido()
	_test_clave_mundo_desconocida()
	_test_json_malformado()
	print("=== TEST VALIDACION GRAFO M21 (DialogGraphValidator): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

## Los grafos de produccion no deben tener problemas (ni falsos positivos).
func _test_grafos_reales_ok() -> void:
	for id_grafo in ["reaccion_regalo", "reaccion_nivel"]:
		var g := DialogueGraph.load_from_json("res://data/dialogues/%s.json" % id_grafo)
		var problemas = _validador.validar(g)
		_check(problemas.is_empty(), "%s valido (sin problemas)" % id_grafo)

## Un nodo sin arista de entrada desde start es huerfano.
func _test_huerfano() -> void:
	var g := DialogueGraph.new()
	g.start_node_id = "start"
	var start := DialogueNode.new(); start.id = "start"; start.next_id = "fin"; g.nodes["start"] = start
	var fin := DialogueNode.new(); fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN; g.nodes["fin"] = fin
	var huerfano := DialogueNode.new(); huerfano.id = "huerfano"; g.nodes["huerfano"] = huerfano
	var problemas = _validador.validar(g)
	_check(not problemas.is_empty(), "grafo con huerfano reporta problemas")
	_check(_contiene(problemas, "huérfano"), "detecta nodo huérfano 'huerfano'")

## Operador de condicion que no esta en OPERADORES_VALIDOS.
func _test_operador_invalido() -> void:
	var g := DialogueGraph.new()
	g.start_node_id = "start"
	var start := DialogueNode.new(); start.id = "start"
	start.conditions = [{"clave": "k", "operador": "~~~"}]
	start.next_id = "fin"; g.nodes["start"] = start
	var fin := DialogueNode.new(); fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN; g.nodes["fin"] = fin
	var problemas = _validador.validar(g)
	_check(_contiene(problemas, "operador de condicion invalido"), "detecta operador '~~~' invalido")

## Con allowlist de claves de mundo, una clave ajena se reporta.
func _test_clave_mundo_desconocida() -> void:
	var g := DialogueGraph.new()
	g.start_node_id = "start"
	var start := DialogueNode.new(); start.id = "start"
	start.conditions = [{"clave": "foo_inexistente", "operador": "==", "valor": 1}]
	start.next_id = "fin"; g.nodes["start"] = start
	var fin := DialogueNode.new(); fin.id = "fin"; fin.tipo = DialogueNode.TIPO_FIN; g.nodes["fin"] = fin
	var problemas = _validador.validar(g, ["amistad_npc"])
	_check(_contiene(problemas, "clave de mundo desconocida"), "detecta clave de mundo 'foo_inexistente'")
	# Sin allowlist, NO se reporta (solo se valida sintaxis).
	var problemas_sin = _validador.validar(g, [])
	_check(not _contiene(problemas_sin, "clave de mundo desconocida"), "sin allowlist no reporta clave de mundo")

## JSON malformado => ok=false.
func _test_json_malformado() -> void:
	var r = _validador.validar_texto("{esto: no es json,}", [])
	_check(not r["ok"], "JSON malformado => ok=false")
	_check(r["error"].contains("invalido"), "JSON malformado reporta error")

func _contiene(problemas: Array, subcadena: String) -> bool:
	for p in problemas:
		if str(p).contains(subcadena):
			return true
	return false
