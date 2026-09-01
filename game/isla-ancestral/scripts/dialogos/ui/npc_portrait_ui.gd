# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M21/M53: NpcPortraitUI — retrato del hablante dentro de la caja de dialogo.
# Cambia la EXPRESION del NPC (feliz / neutral / feliz_intenso) segun la reaccion
# de regalo/nivel que llega desde M20 via DialogueManager. Es la "cara" grafica
# que lee get_ultima_reaccion() (DialogueUI lo expone).
#
# Sin assets de arte todavia: el retrato es un fondo de color (tint por expresion)
# + nombre + etiqueta de expresion. Cuando M87 aporte texturas de retrato, basta
# conectar set_texture() o cargar res://textures/portraits/<id>.png en set_speaker.

extends Control

class_name NpcPortraitUI

var _speaker: String = ""
var _expression: String = ""
var _bg: ColorRect = null
var _name_label: Label = null
var _expr_label: Label = null

## Tint del fondo por expresion (cozy: calidos para feliz, gris para neutral).
const EXPRESION_TINT := {
	"feliz_intenso": Color(1.0, 0.85, 0.5),
	"feliz": Color(1.0, 0.95, 0.82),
	"neutral": Color(0.82, 0.82, 0.88),
}

func _ready() -> void:
	custom_minimum_size = Vector2(150, 150)
	_bg = ColorRect.new()
	_bg.name = "Fondo"
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0.12, 0.12, 0.16, 1.0)
	add_child(_bg)
	_name_label = Label.new()
	_name_label.name = "Nombre"
	_name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_name_label.offset_top = 6
	_name_label.offset_bottom = 26
	_name_label.offset_left = 6
	_name_label.offset_right = -6
	_name_label.add_theme_font_size_override("font_size", 13)
	add_child(_name_label)
	_expr_label = Label.new()
	_expr_label.name = "Expresion"
	_expr_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_expr_label.offset_bottom = -6
	_expr_label.offset_top = -24
	_expr_label.offset_left = 6
	_expr_label.offset_right = -6
	_expr_label.add_theme_font_size_override("font_size", 11)
	add_child(_expr_label)
	_aplicar_expresion()

## M20 -> M21: fija el hablante (npc.<id>) y su nombre visible.
func set_speaker(speaker_key: String) -> void:
	_speaker = speaker_key
	_name_label.text = speaker_key
	# (futuro M87) cargar textura res://textures/portraits/<id>.png por convencion.

## M20 -> M21: fija la expresion y aplica el tint grafico correspondiente.
func set_expression(expresion: String) -> void:
	_expression = expresion
	_aplicar_expresion()

func _aplicar_expresion() -> void:
	if _bg == null:
		return
	if EXPRESION_TINT.has(_expression):
		_bg.color = EXPRESION_TINT[_expression]
	else:
		_bg.color = Color(0.12, 0.12, 0.16, 1.0)
	if _expr_label != null:
		_expr_label.text = _expression

func get_expression() -> String:
	return _expression

func get_speaker() -> String:
	return _speaker

## M87 (futuro): permite cambiar la textura del retrato por expresion/npc.
func set_texture(tex: Texture2D) -> void:
	_bg.texture = tex
