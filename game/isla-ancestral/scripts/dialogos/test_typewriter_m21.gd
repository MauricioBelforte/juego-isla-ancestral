# Modelo: Hy3
# Plataforma: WorkBuddy (Hunyuan)
# Fecha: 2026-10-17
#
# M21 Lote 2 (msg 249): tipeo progresivo (D L81-L86).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_typewriter_m21.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Piso ajustado tras medicion en verde.
const CHECKS_MINIMOS := 19
const _WB_BLOQUES: Array[String] = [
	"_test_tipeo_basico",
	"_test_acelerar",
	"_test_completar_confirm",
	"_test_avanzar_confirm",
	"_test_skip_sostenido",
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
	print("=== Resumen M21 Typewriter Hy3: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

class FakeDM extends Node:
	var elegidas: Array = []
	var avanzos: int = 0
	var skips: int = 0
	var tipeando: bool = false
	var _nodo_actual = null
	func choose_option(i: int) -> void: elegidas.append(i)
	func advance() -> void: avanzos += 1
	func skip_all() -> void: skips += 1
	func set_tipeando(v: bool) -> void: tipeando = v

func _tecla(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	e.echo = false
	return e

func _nueva_ui(fake: Node) -> Node:
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui()
	ui._portrait = null
	ui._dm = fake
	ui.show()
	return ui

func _init() -> void:
	call_deferred("_summary")
	_test_tipeo_basico()
	_fin("_test_tipeo_basico")
	_test_acelerar()
	_fin("_test_acelerar")
	_test_completar_confirm()
	_fin("_test_completar_confirm")
	_test_avanzar_confirm()
	_fin("_test_avanzar_confirm")
	_test_skip_sostenido()
	_fin("_test_skip_sostenido")
	_summary()

## D L81/L82/L88/L89: el tipeo revela el texto poco a poco, con indicadores correctos.
func _test_tipeo_basico() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake)
	ui._on_node_entered("n", "npc.x", "Hola mundo lento de prueba", DialogueNode.TIPO_LINEA, [])
	_check(ui._tipeando, "L81: el tipeo inicia al entrar al nodo")
	_check(ui._label.text == "", "L81: sin tipeo aun, texto vacio")
	_check(ui._indicador_puntos.visible, "L89: puntos de espera visibles mientras se escribe")
	_check(not ui._indicador_flecha.visible, "L88: flecha oculta mientras se escribe")
	_check(fake.tipeando, "L81: manager set_tipeando(true) durante el tipeo")
	ui._tick_typewriter(1.0)
	_check(ui._label.text == "Hola ", "L81/L82: tras 1s revela 'Hola ' (5 chars a 300cpm)")
	_check(ui._tipeando, "L81: sigue tipeando")
	for _i in 40:
		ui._tick_typewriter(1.0)
		if not ui._tipeando:
			break
	_check(not ui._tipeando, "L81: el tipeo termina")
	_check(ui._label.text == "Hola mundo lento de prueba", "L81: texto completo al final")
	_check(ui._indicador_flecha.visible, "L88: flecha visible al completar")
	_check(not ui._indicador_puntos.visible, "L89: puntos ocultos al completar")
	_check(not fake.tipeando, "L81: manager set_tipeando(false) al completar")

## D L83: mantener la confirmacion acelera el tipeo.
func _test_acelerar() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake)
	ui._on_node_entered("n", "npc.x", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", DialogueNode.TIPO_LINEA, [])
	ui._tick_typewriter(0.5)
	var normal: int = ui._indice_tipeo
	ui._on_node_entered("n", "npc.x", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", DialogueNode.TIPO_LINEA, [])
	ui._acelerando = true
	ui._tick_typewriter(0.5)
	var acelerado: int = ui._indice_tipeo
	_check(acelerado > normal, "L83: mantener confirm acelera el tipeo (%d > %d)" % [acelerado, normal])

## D L84: el primer confirm completa la linea al instante.
func _test_completar_confirm() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake)
	ui._on_node_entered("n", "npc.x", "Linea que se completa con confirm", DialogueNode.TIPO_LINEA, [])
	_check(ui._tipeando, "L84: tipeando antes del confirm")
	ui._input(_tecla(KEY_ENTER))
	_check(not ui._tipeando, "L84: primer confirm completa la linea")
	_check(ui._label.text == "Linea que se completa con confirm", "L84: texto completo tras confirm")

## D L85: tras completar, el confirm avanza el nodo (no lo hace durante el tipeo).
func _test_avanzar_confirm() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake)
	ui._on_node_entered("n", "npc.x", "Linea para avanzar", DialogueNode.TIPO_LINEA, [])
	ui._input(_tecla(KEY_ENTER))  # completa
	ui._input(_tecla(KEY_ENTER))  # avanza nodo
	_check(fake.avanzos == 1, "L85: segundo confirm avanza el nodo (advance)")

## D L86: confirmacion sostenida => salto completo del dialogo.
func _test_skip_sostenido() -> void:
	var fake := FakeDM.new()
	var ui = _nueva_ui(fake)
	ui._on_node_entered("n", "npc.x", "Linea larga para salto sostenido de confirmacion", DialogueNode.TIPO_LINEA, [])
	ui._acelerando = true  # confirm sostenido
	ui._process(0.7)       # acumula > UMBRAL_SKIP_SOSTENIDO (0.6)
	_check(fake.skips == 1, "L86: confirmacion sostenida => skip_all (salto completo)")
	_check(not ui._acelerando, "L86: aceleracion se detiene tras el skip")
