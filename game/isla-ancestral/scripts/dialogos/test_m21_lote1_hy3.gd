# Modelo: Hy3
# Plataforma: WorkBuddy (Hunyuan)
# Fecha: 2026-10-16
#
# M21 Lote 1 (autorizado por el director msg 243): cierre headless de los 4 items
# implementados por Hy3:
#   - L73 : resumen "[VAL-DGT] N errores, M advertencias" en start_dialogue
#   - E L100: filtrar opciones por condicion de mundo para DISPLAY en _entrar_nodo
#   - E L103: navegacion con KEY_UP/KEY_DOWN + ENTER elige la resaltada
#   - D L93 : color de texto por tipo de hablante (paleta theme_ux.gd)
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_m21_lote1_hy3.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Piso MEDIDO en ejecucion: 23 checks (ver Resumen).
const CHECKS_MINIMOS := 23
const _WB_BLOQUES: Array[String] = [
	"_test_l73_resumen_validacion",
	"_test_l100_filtrar_opciones",
	"_test_l103_navegacion_teclado",
	"_test_l93_color_hablante",
]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _fallos: int = 0

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
	print("=== Resumen M21 Lote1 Hy3: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, mensaje: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + mensaje)

## Doble de DialogueManager para testear la eleccion por teclado sin autoload real.
class FakeDM extends Node:
	var elegidas: Array = []
	var avanzos: int = 0
	func choose_option(i: int) -> void: elegidas.append(i)
	func advance() -> void: avanzos += 1
	func skip_all() -> void: pass

func _tecla(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	e.echo = false
	return e

func _init() -> void:
	call_deferred("_summary")
	_test_l73_resumen_validacion()
	_fin("_test_l73_resumen_validacion")
	_test_l100_filtrar_opciones()
	_fin("_test_l100_filtrar_opciones")
	_test_l103_navegacion_teclado()
	_fin("_test_l103_navegacion_teclado")
	_test_l93_color_hablante()
	_fin("_test_l93_color_hablante")
	_summary()

## L73: el resumen de validacion con conteo de errores/advertencias es correcto y
## se emite/almacena al validar un grafo invalido (sin crashear).
func _test_l73_resumen_validacion() -> void:
	var manager = load("res://scripts/dialogos/dialogue_manager.gd").new()
	# Grafo con 1 error (next inexistente) y 1 advertencia (sin nodo FIN).
	var g := DialogueGraph.new()
	g.dialogue_id = "t"
	g.start_node_id = "a"
	g.nodes["a"] = DialogueNode.new()
	g.nodes["a"].id = "a"
	g.nodes["a"].next_id = "fantasma"
	var problemas: Array = g.validate()
	var resumen: String = manager._resumen_validacion(problemas)
	_check(resumen == "[VAL-DGT] 1 errores, 1 advertencias", "L73 formato resumen: " + resumen)
	# Multiples errores sin advertencia.
	var resumen2: String = manager._resumen_validacion(["x", "y", "z"])
	_check(resumen2 == "[VAL-DGT] 3 errores, 0 advertencias", "L73 multiples errores: " + resumen2)
	# Integracion: _validar_grafo_y_reportar retorna false y guarda el resumen.
	var m2 = load("res://scripts/dialogos/dialogue_manager.gd").new()
	var ok: bool = m2._validar_grafo_y_reportar(g)
	_check(not ok, "L73 grafo invalido => false")
	_check(m2._ultimo_resumen_validacion == "[VAL-DGT] 1 errores, 1 advertencias", "L73 resumen almacenado")
	# Grafo valido (con FIN) => true y sin resumen.
	var gv := DialogueGraph.new()
	gv.dialogue_id = "tv"
	gv.start_node_id = "a"
	gv.nodes["a"] = DialogueNode.new()
	gv.nodes["a"].id = "a"
	gv.nodes["a"].tipo = DialogueNode.TIPO_FIN
	var m3 = load("res://scripts/dialogos/dialogue_manager.gd").new()
	_check(m3._validar_grafo_y_reportar(gv), "L73 grafo valido => true")

## E L100: las opciones cuya condicion de mundo no se cumple se filtran para DISPLAY
## (se emiten solo las visibles, preservando el orden).
func _test_l100_filtrar_opciones() -> void:
	var manager = load("res://scripts/dialogos/dialogue_manager.gd").new()
	var nodo := DialogueNode.new()
	nodo.id = "o"
	nodo.tipo = DialogueNode.TIPO_OPCIONES
	var op0 := DialogueOption.new(); op0.text_key = "SIEMPRE"
	var op1 := DialogueOption.new(); op1.text_key = "CONDICIONAL"
	op1.conditions = [{"clave": "flag_prueba", "operador": "==", "valor": true}]
	nodo.options = [op0, op1]
	var emitidas: Array = []
	manager.node_entered.connect(func(id, sp, txt, tp, ops): emitidas.append(ops))
	manager._entrar_nodo(nodo)
	_check(emitidas.size() == 1, "L100: node_entered emitido 1 vez")
	_check(emitidas.size() == 1 and emitidas[0].size() == 1, "L100: 1 opcion visible (filtrada)")
	_check(emitidas.size() == 1 and emitidas[0][0].text_key == "SIEMPRE", "L100: queda la opcion sin condicion")
	# Sin condiciones => todas visibles.
	var nodo2 := DialogueNode.new()
	nodo2.id = "o2"
	nodo2.tipo = DialogueNode.TIPO_OPCIONES
	var a := DialogueOption.new(); a.text_key = "A"
	var b := DialogueOption.new(); b.text_key = "B"
	nodo2.options = [a, b]
	emitidas.clear()
	manager._entrar_nodo(nodo2)
	_check(emitidas.size() == 1 and emitidas[0].size() == 2, "L100: sin condiciones => 2 visibles")

## E L103: KEY_UP/KEY_DOWN mueven la seleccion (wrap-around) y ENTER elige la
## resaltada; las teclas numericas eligen directo; ENTER sin opciones avanza.
## Nota: en modo --script los paths absolutos no resuelven, asi que inyectamos el
## DialogueManager fake directamente via la referencia cacheada _dm (mejora de prod).
func _test_l103_navegacion_teclado() -> void:
	var fake = FakeDM.new()
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui()
	# El retrato (NpcPortraitUI) requiere _ready para inicializar sus labels; en modo
	# --script no entra al arbol, asi que lo anulamos: el test no necesita el retrato.
	ui._portrait = null
	ui._dm = fake
	var ops: Array = []
	for i in 3:
		var o := DialogueOption.new()
		o.text_key = "OP%d" % i
		ops.append(o)
	ui._on_node_entered("n", "npc.x", "pregunta", DialogueNode.TIPO_OPCIONES, ops)
	_check(ui._indice_opcion_seleccionada == 0, "L103: seleccion inicia en 0")
	ui._input(_tecla(KEY_DOWN))
	_check(ui._indice_opcion_seleccionada == 1, "L103: KEY_DOWN -> 1")
	ui._input(_tecla(KEY_DOWN))
	_check(ui._indice_opcion_seleccionada == 2, "L103: KEY_DOWN -> 2")
	ui._input(_tecla(KEY_DOWN))
	_check(ui._indice_opcion_seleccionada == 0, "L103: KEY_DOWN wrap -> 0")
	ui._input(_tecla(KEY_UP))
	_check(ui._indice_opcion_seleccionada == 2, "L103: KEY_UP wrap -> 2")
	ui._input(_tecla(KEY_ENTER))
	_check(fake.elegidas.size() == 1 and fake.elegidas[0] == 2, "L103: ENTER elige resaltada (2)")
	ui._on_node_entered("n2", "npc.x", "preg2", DialogueNode.TIPO_OPCIONES, ops)
	ui._input(_tecla(KEY_2))
	_check(fake.elegidas.size() == 2 and fake.elegidas[1] == 1, "L103: tecla 2 elige indice 1")
	ui._on_node_entered("n3", "npc.x", "linea", DialogueNode.TIPO_LINEA, [])
	ui._input(_tecla(KEY_ENTER))
	_check(fake.avanzos == 1, "L103: ENTER sin opciones avanza")

## D L93: el color de texto por tipo de hablante usa la paleta theme_ux.gd y se
## aplica como override en el label al entrar al nodo.
func _test_l93_color_hablante() -> void:
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui()
	ui._portrait = null
	_check(ui._color_por_hablante("npc.riz_001") == ThemeUx.COLOR_SPEAKER_NPC, "L93 NPC => verde")
	_check(ui._color_por_hablante("npc") == ThemeUx.COLOR_SPEAKER_NPC, "L93 npc sin punto => verde")
	_check(ui._color_por_hablante("deidad.ancestro") == ThemeUx.COLOR_SPEAKER_DEIDAD, "L93 deidad => dorado")
	_check(ui._color_por_hablante("narrador") == ThemeUx.COLOR_SPEAKER_NARRADOR, "L93 narrador => cream")
	_check(ui._color_por_hablante("") == ThemeUx.COLOR_SPEAKER_NARRADOR, "L93 vacio => cream (default)")
	ui._on_node_entered("n", "npc.x", "hola", DialogueNode.TIPO_LINEA, [])
	_check(ui._color_texto_hablante == ThemeUx.COLOR_SPEAKER_NPC, "L93 color resuelto y aplicado en LINEA")
