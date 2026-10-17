# Modelo: Hy3
# Plataforma: WorkBuddy (Hunyuan)
# Fecha: 2026-10-17
#
# M21 Lote 2 (msg 249): polish (K L185 transicion, L186 retrato, L187 sonido,
# L188 shimmer, L189 ritmo, L190 dialogo de ejemplo localizado).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_polish_m21.gd

extends SceneTree

const CHECKS_MINIMOS := 11
const _WB_BLOQUES: Array[String] = [
	"_test_transicion",
	"_test_anim_retrato",
	"_test_sonido",
	"_test_shimmer",
	"_test_reduce_motion",
	"_test_dialogo_ejemplo",
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
	print("=== Resumen M21 Polish Hy3: %d checks, %d fallos ===" % [_checks, _fallos])
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
	_test_transicion()
	_fin("_test_transicion")
	_test_anim_retrato()
	_fin("_test_anim_retrato")
	_test_sonido()
	_fin("_test_sonido")
	_test_shimmer()
	_fin("_test_shimmer")
	_test_reduce_motion()
	_fin("_test_reduce_motion")
	_test_dialogo_ejemplo()
	_fin("_test_dialogo_ejemplo")
	_summary()

## K L185: la transicion de apertura es segura fuera del arbol (sin tween) y no rompe;
## con reduce_motion mantiene alpha 1.0.
func _test_transicion() -> void:
	var ui = _nueva_ui()
	ui._aplicar_transicion_apertura()
	_check(abs(ui._panel.modulate.a - 1.0) < 0.001, "L185: apertura no cambia alpha fuera del arbol (sin error)")
	ui.set_reduce_motion(true)
	ui._aplicar_transicion_apertura()
	_check(abs(ui._panel.modulate.a - 1.0) < 0.001, "L185: reduce_motion mantiene alpha 1.0")
	ui.set_reduce_motion(false)

## K L186: al cambiar de hablante se registra la animacion del retrato (estado audible).
func _test_anim_retrato() -> void:
	var ui = _nueva_ui()
	ui._portrait = null
	ui._on_node_entered("n", "npc.ana", "Hola", DialogueNode.TIPO_LINEA, [])
	_check(ui._ultima_anim_retrato == "npc.ana", "L186: anim de retrato registra el hablante")
	ui._on_node_entered("n2", "deidad.ancestro", "Bendicion", DialogueNode.TIPO_LINEA, [])
	_check(ui._ultima_anim_retrato == "deidad.ancestro", "L186: cambio de hablante actualiza la anim")

## K L187: el sonido de tipeo se emite (contador) en cada caracter revelado.
func _test_sonido() -> void:
	var ui = _nueva_ui()
	ui._on_node_entered("n", "npc.x", "Sonido de tipeo aqui presente", DialogueNode.TIPO_LINEA, [])
	for _i in 20:
		ui._tick_typewriter(0.2)
	_check(ui._conteo_sonido_tipeo > 0, "L187: se emite sonido de tipeo (contador > 0)")
	ui.set_reduce_motion(true)
	var antes: int = ui._conteo_sonido_tipeo
	ui._reproducir_sonido_tipeo()
	_check(ui._conteo_sonido_tipeo == antes + 1, "L187: reduce_motion sigue contando (no reproduce)")
	ui.set_reduce_motion(false)

## K L188: la linea seleccionada se resalta (base del shimmer) de forma sincrona.
func _test_shimmer() -> void:
	var fake := FakeDM.new()
	var ui = load("res://scripts/dialogos/ui/dialogue_ui.gd").new()
	ui._crear_ui(); ui._portrait = null; ui._dm = fake; ui.show()
	var op1 := DialogueOption.new(); op1.text_key = "A"
	var op2 := DialogueOption.new(); op2.text_key = "B"
	ui._on_node_entered("n", "npc.x", "Elige", DialogueNode.TIPO_OPCIONES, [op1, op2])
	var btn0 := ui._botones_opciones[0] as Button
	_check(btn0 != null, "L188: boton 0 existe")
	ui._resaltar_opcion(0)
	_check(btn0.has_theme_color_override("font_color"),
		"L188: linea seleccionada resaltada (shimmer base)")

## K L185/L186/L188/L189: reduce_motion no rompe y conserva el estado registrado.
func _test_reduce_motion() -> void:
	var ui = _nueva_ui()
	ui.set_reduce_motion(true)
	ui._aplicar_transicion_apertura()
	ui._animar_retrato_cambio("npc.x")
	var b := Button.new()
	ui._aplicar_shimmer(b)
	_check(ui._ultima_anim_retrato == "npc.x", "L185/186: reduce_motion no rompe, registra estado")
	ui.set_reduce_motion(false)

## K L190: el dialogo de ejemplo localizado existe y es JSON valido.
func _test_dialogo_ejemplo() -> void:
	var f := FileAccess.open("res://data/dialogues/ejemplo_localizado_m21.json", FileAccess.READ)
	_check(f != null, "L190: archivo de dialogo de ejemplo localizado existe")
	if f != null:
		var txt := f.get_as_text()
		f.close()
		var datos = JSON.parse_string(txt)
		_check(datos != null and datos.has("nodes"), "L190: JSON valido con 'nodes'")
