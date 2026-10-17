# Modelo: Hy3
# Plataforma: WorkBuddy (Hunyuan)
# Fecha: 2026-10-17
#
# M21 Lote 2 (msg 249): salto de pagina automatico (D L91) + contador de paginas (D L92).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_pagejump_m21.gd

extends SceneTree

const CHECKS_MINIMOS := 15
const _WB_BLOQUES: Array[String] = [
	"_test_paginar",
	"_test_contador",
	"_test_avance_pagina_teclado",
	"_test_auto_pagina_process",
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
	print("=== Resumen M21 PageJump Hy3: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

class FakeDM extends Node:
	var avanzos: int = 0
	func choose_option(i: int) -> void: pass
	func advance() -> void: avanzos += 1
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
	_test_paginar()
	_fin("_test_paginar")
	_test_contador()
	_fin("_test_contador")
	_test_avance_pagina_teclado()
	_fin("_test_avance_pagina_teclado")
	_test_auto_pagina_process()
	_fin("_test_auto_pagina_process")
	_summary()

## D L91: un texto largo se divide en varias paginas.
func _test_paginar() -> void:
	var ui = _nueva_ui()
	var largo = "Esto es una linea muy larga. Tiene varias oraciones. Otra mas para forzar el paginado. Y otra todavia mas extensa que supera el umbral de ciento veinte caracteres con facilidad para probar el corte por oraciones."
	var pag: Array = ui._paginar_texto(largo)
	_check(pag.size() > 1, "L91: texto largo se pagina en varias paginas (%d)" % pag.size())
	for p in pag:
		_check(p.length() <= 120 + 80, "L91: pagina no excede demasiado el umbral (%d)" % p.length())

## D L92: con varias paginas, el contador se muestra y etiqueta "pág 1/N".
func _test_contador() -> void:
	var ui = _nueva_ui()
	var largo = "Primera oracion larga y descriptiva. Segunda oracion tambien bastante larga. Tercera oracion para completar el paginado de la linea extensa de ejemplo."
	ui._on_node_entered("n", "npc.x", largo, DialogueNode.TIPO_LINEA, [])
	_check(ui._total_paginas > 1, "L92: varias paginas => contador activo")
	_check(ui._contador_paginas.visible, "L92: contador visible con varias paginas")
	_check(ui._contador_paginas.text == "pág 1/%d" % ui._total_paginas, "L92: contador muestra pagina 1/N")

## D L91/L92: confirm tras completar la pagina avanza a la siguiente (no al nodo).
func _test_avance_pagina_teclado() -> void:
	var fake := FakeDM.new()
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui(); ui._portrait = null; ui._dm = fake; ui.show()
	var largo = "Pagina uno termina aqui. Pagina dos es esta otra oracion mas larga que se usa para verificar el salto de pagina con el confirm del jugador."
	ui._on_node_entered("n", "npc.x", largo, DialogueNode.TIPO_LINEA, [])
	_check(ui._total_paginas >= 2, "L91: linea se pagina")
	for _i in 60:
		ui._tick_typewriter(1.0)
		if not ui._tipeando:
			break
	_check(not ui._tipeando, "L91: pagina 1 completa")
	ui._input(_tecla(KEY_ENTER))  # siguiente pagina
	_check(ui._pagina_actual == 1, "L91: confirm avanza a pagina 2")
	_check(ui._tipeando, "L91: pagina 2 empieza a tipear")
	_check(ui._contador_paginas.text == "pág 2/%d" % ui._total_paginas, "L92: contador en pagina 2")

## D L90/L91: auto-advance salta de pagina solo cuando no hay opciones.
func _test_auto_pagina_process() -> void:
	var fake := FakeDM.new()
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui(); ui._portrait = null; ui._dm = fake; ui.show()
	ui._auto_advance_activo = true
	var largo = "Auto pagina uno. Auto pagina dos mas extensa para verificar el avance automatico entre paginas de una linea larga de prueba sin opciones visibles."
	ui._on_node_entered("n", "npc.x", largo, DialogueNode.TIPO_LINEA, [])
	_check(ui._total_paginas >= 2, "L91/L90: linea paginada y auto-advance activo")
	for _i in 60:
		ui._tick_typewriter(1.0)
		if not ui._tipeando:
			break
	_check(not ui._tipeando, "L91: pagina 1 completa antes del auto-advance")
	for _i in 12:
		ui._process(0.5)  # 6s total > delay 3s
	_check(ui._pagina_actual >= 1, "L91/L90: auto-advance pasa de pagina solo (pagina=%d)" % ui._pagina_actual)

func _tecla(code: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = code
	e.pressed = true
	e.echo = false
	return e
