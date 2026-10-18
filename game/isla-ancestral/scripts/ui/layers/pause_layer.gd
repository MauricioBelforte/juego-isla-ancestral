# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: PauseLayer — menú de pausa (modal completo).
# Muestra opciones de pausa (Continuar, Ajustes, Guardar, Volver al título).
# Registrada en UIManager; navegable por teclado y gamepad (MenuNavigator).
# T-053-066: deep-linking entre capas (ajustes → pausa, settings → volver).

class_name PauseLayer
extends UILayer

signal continuar_pedido
signal ajustes_pedido
var _boton_guardar: Button = null
var _dirty_guardado := false

signal guardar_pedido
signal salir_pedido

var _buttons: Array[Button] = []
var _layer_stack_backup: Array[Node] = []

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_FULL
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false

func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.name = "FondoDim"
	add_child(dim)
	dim.move_to_front()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = ThemeUx.COLOR_BG_ARENA
	sb.border_color = ThemeUx.COLOR_HIGHLIGHT_GOLD
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(280, 0)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = _t("SETTINGS.PAUSA")
	title.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var sep_small := VSeparator.new()
	sep_small.visible = false
	vbox.add_child(sep_small)

	_agregar_boton(vbox, "SETTINGS.CONTINUAR", func(): continuar_pedido.emit())
	_agregar_boton(vbox, "SETTINGS.AJUSTES", func(): _navegar_a_ajustes())
	_boton_guardar = _agregar_boton(vbox, "SETTINGS.GUARDAR", func(): _pedir_confirmacion_guardado())
	_agregar_boton(vbox, "SETTINGS.SALIR", func(): salir_pedido.emit())

func _agregar_boton(vbox: VBoxContainer, clave: String, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = _t(clave)
	btn.pressed.connect(cb)
	vbox.add_child(btn)
	_buttons.append(btn)
	return btn

func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave

## T-053-066: deep-linking — navegar a ajustes y volver aquí
func _navegar_a_ajustes() -> void:
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr == null:
		return
	# Guardar referencia para volver después
	_layer_stack_backup = ui_mgr._stack.duplicate()
	# Abrir ajustes (capa separada que vuelve a pausa)
	ajustes_pedido.emit()

## T-053-066: restaurar estado anterior después de ajustes
func restaurar_desde_ajustes() -> void:
	_layer_stack_backup.clear()

## ── UILayer virtual ──────────────────────────────────────

func on_layer_opened() -> void:
	if _buttons.size() > 0:
		_buttons[0].grab_focus()

func on_layer_closed() -> void:
	visible = false

func focus_first() -> Control:
	if _buttons.size() > 0:
		return _buttons[0]
	return null

## Item 1 del riel (M59/M44): Guardar con confirmación + feedback.
## Abre el ConfirmPopup; al aceptar, guarda por DataStore (M60) y emite toast.
## Recalcula el dirty-check cada vez que se abre la pausa (item 4 M59).
func open(initial_focus: Control = null) -> void:
	super.open(initial_focus)
	_actualizar_dirty()


## dirty = la sección player actual difiere del último guardado del slot 1,
## o no existe ningún guardado previo (entonces SIEMPRE se puede guardar).
func _actualizar_dirty() -> void:
	if _boton_guardar == null:
		return
	var ds := get_node_or_null("/root/DataStore")
	var prov = load("res://scripts/saving/player_save_provider.gd").new()
	var actual: Dictionary = prov.get_save_data()
	var guardado: Dictionary = {}
	var existe_slot := false
	if ds != null and ds.has_method("cargar_partida"):
		var res: Dictionary = ds.cargar_partida(1)
		if bool(res.get("ok", false)):
			existe_slot = true
			guardado = res.get("datos", {}).get("player", {})
	_dirty_guardado = (not existe_slot) or (actual != guardado)
	_boton_guardar.disabled = not _dirty_guardado


func _pedir_confirmacion_guardado() -> void:
	if _bloqueado_por_modal_o_carga():
		_toast_guardado(false, "SETTINGS.GUARDAR_BLOQUEADO")
		return
	var popup := _buscar_confirm_popup()
	if popup == null:
		# Sin popup disponible: guardado directo (comportamiento seguro).
		_hacer_guardado_manual()
		return
	var mensaje := _t_local("SETTINGS.GUARDAR_CONFIRMA")
	var meta := GestorSlot.leer_meta(1)
	var iso := str(meta.get("guardado_iso", ""))
	if iso != "":
		mensaje += "\n" + _t_local("SETTINGS.ULTIMO_GUARDADO") + ": " + iso
	else:
		mensaje += "\n" + _t_local("SETTINGS.SIN_GUARDADO_PREVIO")
	popup.configurar_texto(_t_local("SETTINGS.GUARDAR_TITULO"), mensaje, _hacer_guardado_manual)


## El guardado NO corre durante diálogo activo, carga de escena u otro modal.
func _bloqueado_por_modal_o_carga() -> bool:
	var um := get_node_or_null("/root/UIManager")
	if um != null:
		for capa in um._stack:
			if capa == null or not capa.visible:
				continue
			var nombre := String(capa.name)
			if nombre in ["DialogLayer", "LoadingLayer", "ConfirmPopup", "InventoryLayer", "ShopUI", "EquipmentLayer", "DiaryLayer", "CraftingUI", "SettingsAudioLayer", "MenusLayer"]:
				return true
	var flow := get_node_or_null("/root/GameFlowManager")
	if flow != null and flow.has_method("esta_cargando") and flow.esta_cargando():
		return true
	return false


func _buscar_confirm_popup() -> Node:
	var um := get_node_or_null("/root/UIManager")
	if um == null:
		return null
	for capa in um._stack:
		if capa != null and capa.name == "ConfirmPopup":
			return capa
	return null


func _hacer_guardado_manual() -> void:
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("guardar_partida"):
		_toast_guardado(false, "SETTINGS.GUARDAR_FALLO")
		return
	var payload := {"player": {}}
	var provider := PlayerSaveProvider.new()
	payload["player"] = provider.get_save_data()
	var res: Dictionary = ds.guardar_partida(1, payload)
	_toast_guardado(bool(res.get("ok", false)), "SETTINGS.GUARDAR_EXITO" if bool(res.get("ok", false)) else "SETTINGS.GUARDAR_FALLO")


func _toast_guardado(ok: bool, clave_texto: String) -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus == null or bus.ui == null or not bus.ui.has_signal("notify"):
		return
	bus.ui.notify.emit({
		"tipo": "info",
		"id": "guardado_manual",
		"titulo": _t_local("SETTINGS.GUARDAR_EXITO" if ok else "SETTINGS.GUARDAR_FALLO"),
		"texto": _t_local(clave_texto),
	})


func _t_local(clave: String) -> String:
	var loc := get_node_or_null("/root/Localization")
	if loc != null and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave
