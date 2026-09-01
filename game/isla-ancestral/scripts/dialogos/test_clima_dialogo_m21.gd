# Modelo: Hy3
# Plataforma: WorkBuddy
# Fecha: 2026-08-31
#
# M21 (iter 8): Test de la condicion de clima (RF7 / F.11) — cierra el [?] de
# condiciones sobre clima delegando en WeatherService (M32).
# Verifica el CICLO COMPLETO de validacion + resolucion:
#   1. DialogGraphValidator ACEPTA "clima" como clave de mundo conocida.
#   2. DialogGraphValidator RECHAZA una clave inventada ("climaX").
#   3. WorldStateService.get_value("clima") resuelve contra M32 (String) sin crashear;
#      devuelve "" si M32 no esta cargado (fallback honesto).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_clima_dialogo_m21.gd
# ⚠️ En _init() de SceneTree no existe get_node_or_null(); usar root.get_node_or_null().
#    La logica corre con call_deferred para que los autoloads ya existan.

extends SceneTree

var _fallos: int = 0
var _ws: Node = null
var _validator: RefCounted = null

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_ws = root.get_node_or_null("WorldState")
	_validator = load("res://scripts/dialogos/dialog_graph_validator.gd")
	_check(_ws != null, "WorldState autoload presente")
	_check(_validator != null, "DialogGraphValidator cargado")
	if _ws == null or _validator == null:
		print("=== TEST CLIMA M21: 1 fallo(s) (dependencias ausentes) ===")
		quit(1)
		return
	_test_validador_acepta_clima()
	_test_validador_rechaza_clima_inexistente()
	_test_resolucion_clima_m32()
	print("=== TEST CLIMA M21: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)
	else:
		print("OK: " + mensaje)

## Construye un grafo minimo con una unica condicion sobre la clave dada.
func _grafo_con_condicion(clave: String) -> DialogueGraph:
	var grafo := DialogueGraph.new()
	grafo.dialogue_id = "test_clima_%s" % clave
	grafo.start_node_id = "inicio"
	var inicio := DialogueNode.new()
	inicio.id = "inicio"
	inicio.tipo = DialogueNode.TIPO_LINEA
	inicio.next_id = "cond"
	grafo.nodes["inicio"] = inicio
	var cond := DialogueNode.new()
	cond.id = "cond"
	cond.tipo = DialogueNode.TIPO_LINEA
	cond.conditions = [{"clave": clave, "operador": "==", "valor": "lluvia"}]
	cond.next_id = "fin"
	grafo.nodes["cond"] = cond
	var fin := DialogueNode.new()
	fin.id = "fin"
	fin.tipo = DialogueNode.TIPO_FIN
	grafo.nodes["fin"] = fin
	return grafo

## F.11 [?]: el validador debe ACEPTAR "clima" como clave conocida (no desconocida).
func _test_validador_acepta_clima() -> void:
	var grafo := _grafo_con_condicion("clima")
	var problemas := _validator.validar(grafo, _validator.CLAVES_MUNDO_BASE)
	var hay_clave_desconocida := false
	for p in problemas:
		if "clave de mundo desconocida" in str(p) and "clima" in str(p):
			hay_clave_desconocida = true
	_check(not hay_clave_desconocida, "validador ACEPTA clave 'clima' (no reporta desconocida)")

## Contra-prueba: una clave inventada debe ser rechazada (detecta typos en runtime/CI).
func _test_validador_rechaza_clima_inexistente() -> void:
	var grafo := _grafo_con_condicion("climaX")
	var problemas := _validator.validar(grafo, _validator.CLAVES_MUNDO_BASE)
	var hay_clave_desconocida := false
	for p in problemas:
		if "clave de mundo desconocida" in str(p):
			hay_clave_desconocida = true
	_check(hay_clave_desconocida, "validador RECHAZA clave inventada 'climaX' (detecta typo)")

## Resolucion real contra M32: get_value("clima") devuelve String (o "" si M32 ausente).
func _test_resolucion_clima_m32() -> void:
	var valor = _ws.get_value("clima", "<ausente>")
	_check(typeof(valor) == TYPE_STRING, "get_value('clima') devuelve String (tipo estable)")
	# No debe crashear con M32 presente o ausente; si M32 esta, el valor es un nombre de clima.
	var w := root.get_node_or_null("Weather")
	if w != null and w.has_method("get_nombre_clima"):
		var nombre := str(w.get_nombre_clima())
		_check(nombre != "", "WeatherService.get_nombre_clima() resuelve un nombre no vacio")
		_check(_ws.get_value("clima", "") == nombre, "WorldState clima == nombre de clima de M32")
	else:
		_check(_ws.get_value("clima", "") == "", "fallback honesto: clima '' si M32 ausente")
