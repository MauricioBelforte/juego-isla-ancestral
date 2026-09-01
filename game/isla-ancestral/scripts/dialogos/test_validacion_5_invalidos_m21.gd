# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-09-01
#
# M21 (iter 9): Test de validacion con 5 grafos invalidos propositados.
# Cierra el [?] L.11 de la checklist: "Test de validacion: 5 grafos invalidos
# propositados detectados en editor". Verifica que DialogGraphValidator detecte
# cada clase de defecto (nodo huérfano, operador invalido, clave desconocida,
# next inexistente, goto inexistente).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_validacion_5_invalidos_m21.gd

extends SceneTree

var _fallos: int = 0
var _validator: RefCounted = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_validator = load("res://scripts/dialogos/dialog_graph_validator.gd")
	_check(_validator != null, "DialogGraphValidator cargado")
	if _validator == null:
		print("=== TEST VALIDACION 5 INVALIDOS M21: 1 fallo(s) ===")
		quit(1)
		return
	_test_huerfano()
	_test_operador_invalido()
	_test_clave_desconocida()
	_test_next_inexistente()
	_test_goto_inexistente()
	print("=== TEST VALIDACION 5 INVALIDOS M21: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)
	else:
		print("OK: " + mensaje)

## Construye un grafo de 2 nodos (inicio -> fin) valido por defecto.
func _grafo_base() -> DialogueGraph:
	var g := DialogueGraph.new()
	g.dialogue_id = "test_inv"
	g.start_node_id = "a"
	var a := DialogueNode.new()
	a.id = "a"
	a.tipo = DialogueNode.TIPO_LINEA
	a.next_id = "b"
	g.nodes["a"] = a
	var b := DialogueNode.new()
	b.id = "b"
	b.tipo = DialogueNode.TIPO_FIN
	g.nodes["b"] = b
	return g

## 1) Nodo huérfano: 'c' no es alcanzable desde start.
func _test_huerfano() -> void:
	var g := _grafo_base()
	var c := DialogueNode.new()
	c.id = "c"
	c.tipo = DialogueNode.TIPO_LINEA
	c.next_id = "b"
	g.nodes["c"] = c  # 'c' no tiene padre -> huérfano
	var p = _validator.validar(g, _validator.CLAVES_MUNDO_BASE)
	_check(_contiene(p, "huérfano"), "detecta nodo huérfano 'c'")

## 2) Operador de condición inválido.
func _test_operador_invalido() -> void:
	var g := _grafo_base()
	g.nodes["a"].conditions = [{"clave": "estacion", "operador": "~~", "valor": 0}]
	var p = _validator.validar(g, _validator.CLAVES_MUNDO_BASE)
	_check(_contiene(p, "operador"), "detecta operador inválido '~~'")

## 3) Clave de mundo desconocida (typo).
func _test_clave_desconocida() -> void:
	var g := _grafo_base()
	g.nodes["a"].conditions = [{"clave": "climaX", "operador": "==", "valor": "lluvia"}]
	var p = _validator.validar(g, _validator.CLAVES_MUNDO_BASE)
	_check(_contiene(p, "clave de mundo desconocida"), "detecta clave desconocida 'climaX'")

## 4) next_id apuntando a nodo inexistente.
func _test_next_inexistente() -> void:
	var g := _grafo_base()
	g.nodes["a"].next_id = "no_existe"
	var p = _validator.validar(g, _validator.CLAVES_MUNDO_BASE)
	_check(_contiene(p, "no existe") or _contiene(p, "inexistente"), "detecta next_id inexistente")

## 5) goto_id apuntando a nodo inexistente.
func _test_goto_inexistente() -> void:
	var g := _grafo_base()
	g.nodes["a"].goto_id = "tampoco_existe"
	var p = _validator.validar(g, _validator.CLAVES_MUNDO_BASE)
	_check(_contiene(p, "no existe") or _contiene(p, "inexistente"), "detecta goto_id inexistente")

## Helper: true si algun problema contiene la subcadena.
func _contiene(problemas: Array, sub: String) -> bool:
	for p in problemas:
		if sub in str(p):
			return true
	return false
