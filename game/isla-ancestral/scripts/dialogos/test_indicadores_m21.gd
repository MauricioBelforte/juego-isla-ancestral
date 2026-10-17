# Modelo: Hy3
# Plataforma: WorkBuddy (Hunyuan)
# Fecha: 2026-10-17
#
# M21 Lote 2 (msg 249): indicadores de tipeo (D L88 flecha, L89 puntos).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_indicadores_m21.gd

extends SceneTree

const CHECKS_MINIMOS := 7
const _WB_BLOQUES: Array[String] = [
	"_test_espera",
	"_test_completado",
	"_test_inicio_ocultos",
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
	print("=== Resumen M21 Indicadores Hy3: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

class FakeDM extends Node:
	func choose_option(i: int) -> void: pass
	func advance() -> void: pass
	func skip_all() -> void: pass
	func set_tipeando(v: bool) -> void: pass

func _nueva_ui() -> Node:
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui()
	ui._portrait = null
	ui._dm = FakeDM.new()
	ui.show()
	return ui

func _init() -> void:
	call_deferred("_summary")
	_test_inicio_ocultos()
	_fin("_test_inicio_ocultos")
	_test_espera()
	_fin("_test_espera")
	_test_completado()
	_fin("_test_completado")
	_summary()

## D L88/L89: antes de cualquier nodo, ambos indicadores ocultos.
func _test_inicio_ocultos() -> void:
	var ui = _nueva_ui()
	_check(not ui._indicador_puntos.visible and not ui._indicador_flecha.visible,
		"L88/L89: indicadores ocultos antes de cualquier nodo")

## D L89: mientras se escribe, puntos de espera visibles y flecha oculta.
func _test_espera() -> void:
	var ui = _nueva_ui()
	ui._on_node_entered("n", "npc.x", "Texto de espera mientras se escribe", DialogueNode.TIPO_LINEA, [])
	_check(ui._indicador_puntos.visible, "L89: puntos de espera visibles al iniciar")
	_check(not ui._indicador_flecha.visible, "L88: flecha oculta al iniciar")
	_check(ui._label.text == "", "L89: sin texto aun durante el tipeo")

## D L88: al completar, flecha visible y puntos ocultos.
func _test_completado() -> void:
	var ui = _nueva_ui()
	ui._on_node_entered("n", "npc.x", "Texto que se completa para el indicador", DialogueNode.TIPO_LINEA, [])
	for _i in 40:
		ui._tick_typewriter(1.0)
		if not ui._tipeando:
			break
	_check(not ui._tipeando, "L88: tipeo completo")
	_check(ui._indicador_flecha.visible, "L88: flecha visible al completar la linea")
	_check(not ui._indicador_puntos.visible, "L89: puntos ocultos al completar")
