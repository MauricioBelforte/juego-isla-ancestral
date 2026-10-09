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

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 2 (mis suites propias), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 100). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 6
const _WB_BLOQUES: Array[String] = ["_test_huerfano", "_test_operador_invalido", "_test_clave_desconocida", "_test_next_inexistente", "_test_goto_inexistente"]
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
var _validator: RefCounted = null

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_validator = load("res://scripts/dialogos/dialog_graph_validator.gd")
	_check(_validator != null, "DialogGraphValidator cargado")
	if _validator == null:
		print("=== TEST VALIDACION 5 INVALIDOS M21: 1 fallo(s) ===")
		_summary()
		return
	_test_huerfano()
	_fin("_test_huerfano")
	_test_operador_invalido()
	_fin("_test_operador_invalido")
	_test_clave_desconocida()
	_fin("_test_clave_desconocida")
	_test_next_inexistente()
	_fin("_test_next_inexistente")
	_test_goto_inexistente()
	_fin("_test_goto_inexistente")
	_summary()

func _check(cond: bool, mensaje: String) -> void:
	_checks += 1
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
