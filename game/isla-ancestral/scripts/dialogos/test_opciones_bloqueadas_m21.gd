# Modelo: Hy3
# Plataforma: WorkBuddy (Hunyuan)
# Fecha: 2026-10-17
#
# M21 Lote 2 (msg 249): opciones bloqueadas (E L101 ocultar, L102 mostrar gris + alt).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_opciones_bloqueadas_m21.gd

extends SceneTree

const CHECKS_MINIMOS := 8
const _WB_BLOQUES: Array[String] = [
	"_test_ocultar_bloqueadas",
	"_test_mostrar_bloqueadas",
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
	print("=== Resumen M21 OpcionesBloqueadas Hy3: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

class FakeDM extends Node:
	var elegidas: Array = []
	var _nodo_actual = null
	func choose_option(i: int) -> void: elegidas.append(i)
	func advance() -> void: pass
	func skip_all() -> void: pass
	func set_tipeando(v: bool) -> void: pass

func _tecla(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	e.echo = false
	return e

func _nueva_ui(fake: Node, hide_blocked: bool) -> Node:
	var nodo := DialogueNode.new()
	nodo.hide_blocked = hide_blocked
	fake._nodo_actual = nodo
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui()
	ui._portrait = null
	ui._dm = fake
	ui.show()
	return ui

func _init() -> void:
	call_deferred("_summary")
	_test_ocultar_bloqueadas()
	_fin("_test_ocultar_bloqueadas")
	_test_mostrar_bloqueadas()
	_fin("_test_mostrar_bloqueadas")
	_summary()

## E L101: con hide_blocked=true, la opcion bloqueada NO se renderiza (pero el indice
## del manager se conserva para que choose_option siga alineado).
func _test_ocultar_bloqueadas() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake, true)
	var op_ok := DialogueOption.new(); op_ok.text_key = "ACEPTAR"
	var op_bloq := DialogueOption.new(); op_bloq.text_key = "CERRAR"; op_bloq.blocked_text_key = "Necesitas la llave dorada"
	ui._on_node_entered("n", "npc.x", "Elige", DialogueNode.TIPO_OPCIONES, [op_ok, op_bloq])
	_check(ui._opciones_activas.size() == 2, "L101: opciones activas = 2 (indice del manager preservado)")
	_check(ui._botones_opciones.size() == 1, "L101: opcion bloqueada NO se renderiza (hide_blocked)")
	ui._input(_tecla(KEY_1))
	_check(fake.elegidas == [0], "L101: se elige la opcion valida (indice 0)")

## E L102: con hide_blocked=false, la bloqueada se muestra grisada (deshabilitada) con
## su texto alternativo y no es elegible; la valida si lo es.
func _test_mostrar_bloqueadas() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake, false)
	var op_ok := DialogueOption.new(); op_ok.text_key = "ACEPTAR"
	var op_bloq := DialogueOption.new(); op_bloq.text_key = "CERRAR"; op_bloq.blocked_text_key = "Necesitas la llave dorada"
	ui._on_node_entered("n", "npc.x", "Elige", DialogueNode.TIPO_OPCIONES, [op_ok, op_bloq])
	_check(ui._botones_opciones.size() == 2, "L102: ambas opciones se renderizan (bloqueada visible)")
	var btn_bloq := ui._botones_opciones[1] as Button
	_check(btn_bloq.disabled, "L102: opcion bloqueada deshabilitada (gris)")
	_check(btn_bloq.text.contains("Necesitas la llave dorada"), "L102: muestra texto alternativo bloqueado")
	var antes := fake.elegidas.size()
	ui._input(_tecla(KEY_2))  # intentar elegir la bloqueada
	_check(fake.elegidas.size() == antes, "L102: opcion bloqueada NO es elegible")
	ui._input(_tecla(KEY_1))  # elegir la valida
	_check(fake.elegidas == [0], "L102: opcion valida elegible")
