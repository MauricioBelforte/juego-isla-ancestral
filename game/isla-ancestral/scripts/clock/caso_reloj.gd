# Modelo: glm-5.3
# Plataforma: Cline
# Fecha: 2026-08-31
#
# M30 (E93): escenario del test del reloj — fondo neutro + WReloj arriba-derecha.
# Lo instancia la suite headless scripts/clock/caso_reloj_tests.gd y también sirve
# de preview manual del hover (D70): godot scenes/caso_reloj.tscn
extends Node

const WRelojScript := preload("res://scripts/clock/w_reloj.gd")

## Widget expuesto para inspección (la suite usa get_node("CapaReloj/WReloj")).
var widget: PanelContainer = null

func _ready() -> void:
	# CanvasLayer en layer 0: queda DEBAJO del CanvasLayer del TooltipService
	# (autoload, layer 1) para que el tooltip del hover se dibuje encima.
	var capa := CanvasLayer.new()
	capa.name = "CapaReloj"
	capa.layer = 0
	add_child(capa)

	# Fondo neutro oscuro: contraste legible del panel y del tooltip del hover.
	var fondo := ColorRect.new()
	fondo.name = "Fondo"
	fondo.color = Color(0.16, 0.20, 0.28)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(fondo)

	widget = WRelojScript.new()
	widget.name = "WReloj"
	capa.add_child(widget)

	var hint := Label.new()
	hint.name = "Hint"
	hint.text = "M30 — escenario caso_reloj (E93): widget arriba-derecha, hover D70"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	hint.position = Vector2(16, 12)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(hint)
