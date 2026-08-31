# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M110: Debug Menu (autoload "DebugMenu") — solo activo en builds debug.
# Panel de QA con F12: info de tiempo (M29), dar items (M14/M15), AO (M38),
# log de acciones. V0 pragmático para acelerar pruebas de sistemas.
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).
# §9.47: NO monta widgets del HUD del juego — panel propio de dev con F12.

extends Node

const RUTA := "scripts/debug/debug_menu.gd"

var _panel: PanelContainer = null
var _log_label: Label = null
var _info_label: Label = null
var _activo: bool = false

func _ready() -> void:
	# Solo builds debug (nunca en release)
	if not OS.is_debug_build():
		set_process(false)
		return
	_construir_panel()

func _construir_panel() -> void:
	var capa := CanvasLayer.new()
	capa.name = "DebugLayer"
	capa.layer = 120
	add_child(capa)

	_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.10, 0.09, 0.08, 0.92)
	sb.border_color = Color(0.95, 0.6, 0.2)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(10)
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_panel.offset_right = -10
	_panel.offset_left = -260
	_panel.offset_top = 80
	_panel.offset_bottom = 560
	_panel.visible = false
	capa.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(vbox)

	var titulo := Label.new()
	titulo.text = "🛠 DEBUG (F12)"
	titulo.add_theme_font_size_override("font_size", 14)
	titulo.add_theme_color_override("font_color", Color(0.95, 0.6, 0.2))
	vbox.add_child(titulo)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(_info_label)

	_btn(vbox, "Abrir tienda general", _accion_abrir_tienda)
	_btn(vbox, "Día siguiente", _accion_dia_siguiente)
	_btn(vbox, "Hora 06:00 (mañana)", _accion_hora_mañana)
	_btn(vbox, "Hora 21:00 (noche)", _accion_hora_noche)
	_btn(vbox, "+10 madera", _accion_dar_madera)
	_btn(vbox, "+10 piedra", _accion_dar_piedra)
	_btn(vbox, "+10 bayas", _accion_dar_bayas)
	_btn(vbox, "+5 cobre", _accion_dar_cobre)
	_btn(vbox, "+100 AO", _accion_dar_ao)

	_log_label = Label.new()
	_log_label.add_theme_font_size_override("font_size", 10)
	_log_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.5))
	vbox.add_child(_log_label)

	_activo = true

func _btn(vbox: VBoxContainer, texto: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = texto
	btn.add_theme_font_size_override("font_size", 11)
	btn.pressed.connect(cb)
	vbox.add_child(btn)

## ── Toggle ───────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not _activo:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F12:
		_panel.visible = not _panel.visible
		get_viewport().set_input_as_handled()
	if _panel.visible and (event is InputEventKey and event.pressed):
		_refrescar_info()

## ── Acciones ─────────────────────────────────────────────

func _accion_dia_siguiente() -> void:
	var cal = get_node_or_null("/root/TimeCalendar")
	if cal == null:
		return
	# Avanzar 24h a paso de reloj (API disponible: avanzar_hasta por hora)
	var clock = get_node_or_null("/root/GameClock")
	if clock and clock.has_method("avanzar_hasta"):
		var dia_actual := int(cal.get_dia_absoluto())
		clock.avanzar_hasta(6, 0)
		_log("Avanzado a las 06:00 (día %d)" % dia_actual)
	_refrescar_info()

func _accion_hora_mañana() -> void:
	var cal = get_node_or_null("/root/TimeCalendar")
	if cal and cal.has_method("avanzar_hasta"):
		cal.avanzar_hasta(6, 0)
		_log("Hora: 06:00")
	_refrescar_info()

func _accion_hora_noche() -> void:
	var cal = get_node_or_null("/root/TimeCalendar")
	if cal and cal.has_method("avanzar_hasta"):
		cal.avanzar_hasta(21, 0)
		_log("Hora: 21:00")
	_refrescar_info()

func _accion_dar_madera() -> void:
	_dar("madera_roble", 10)

func _accion_dar_piedra() -> void:
	_dar("piedra_caliza", 10)

func _accion_dar_bayas() -> void:
	_dar("baya_roja", 10)

func _accion_dar_cobre() -> void:
	_dar("mineral_cobre", 5)

func _dar(item_id: String, cantidad: int) -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv and inv.has_method("agregar_items"):
		inv.agregar_items({item_id: cantidad})
		_log("+%d %s" % [cantidad, item_id])

func _accion_dar_ao() -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if eco and eco.has_method("depositar_monedas"):
		eco.depositar_monedas(100)
		_log("+100 AO (saldo %d)" % int(eco.saldo))
	_refrescar_info()

## M39: abre la ShopUI para verificación visual
func _accion_abrir_tienda() -> void:
	var shop_ui = get_node_or_null("/root/../../UIRoot") if false else _buscar_nodo("ShopUI")
	if shop_ui and shop_ui.has_method("abrir"):
		shop_ui.abrir("tienda_general")
		_log("ShopUI abierta")
	else:
		_log("ShopUI no montada")

func _buscar_nodo(nombre: String) -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return _buscar_rec(tree.root, nombre)

func _buscar_rec(node: Node, nombre: String) -> Node:
	for child in node.get_children():
		if child.name == nombre:
			return child
		var r := _buscar_rec(child, nombre)
		if r:
			return r
	return null

## ── Info y log ───────────────────────────────────────────

func _refrescar_info() -> void:
	if _info_label == null:
		return
	var cal = get_node_or_null("/root/TimeCalendar")
	var eco = get_node_or_null("/root/EconomyManager")
	var txt := ""
	if cal:
		var fecha: Dictionary = cal.get_fecha()
		txt += "Día %d · %02d:%02d · %s\n" % [
			int(cal.get_dia_absoluto()), cal.get_hora(), cal.get_minuto(),
			str(cal.get_nombre_estacion())]
	if eco:
		txt += "AO: %d" % int(eco.saldo)
	_info_label.text = txt

var _ultimo_mensaje: String = ""
func _log(mensaje: String) -> void:
	_ultimo_mensaje = mensaje
	if _log_label:
		_log_label.text = "> " + mensaje