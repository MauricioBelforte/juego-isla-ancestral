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
var _boton_borrar: Button = null
var _dirty_guardado := false

signal guardar_pedido
signal salir_pedido

var _buttons: Array[Button] = []
var _layer_stack_backup: Array[Node] = []
## G1-002: modo de raton previo a abrir la pausa (se restaura al cerrar).
var _mouse_previo: int = Input.MOUSE_MODE_CAPTURED

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
	# M59 L184 (DeepSeek-V4.1-Flash, 2026-10-30): se declara la clave con la
	# convencion M87 (`text_key`) en vez de asignar el texto a mano, para que el
	# menu se re-traduzca al cambiar de idioma en caliente (UIManager escucha
	# `locale_changed` y llama UiI18n.retraducir sobre las capas montadas).
	UiI18n.meta_texto(title, "SETTINGS.PAUSA")
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
	_boton_borrar = _agregar_boton(vbox, "SETTINGS.BORRAR_SLOT", func(): _pedir_confirmacion_borrado())
	# M59 ítem 4: botón Guardar deshabilitado si no hay cambios (is_dirty). El
	# refresh corre al abrir la pausa (on_layer_opened) y tras guardar.
	_boton_guardar.disabled = true
	_conectar_guardar_dirty()
	_boton_borrar.add_theme_color_override("font_color", Color(0.85, 0.45, 0.35))  # rojo suave: acción destructiva
	_agregar_boton(vbox, "SETTINGS.VOLVER_TITULO", func(): salir_pedido.emit())

func _agregar_boton(vbox: VBoxContainer, clave: String, cb: Callable) -> Button:
	var btn := Button.new()
	# M59 L184: misma convencion M87 que el titulo (re-traduccion en vivo).
	UiI18n.meta_texto(btn, clave)
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
	# G1-002 (DeepSeek-V4.1-Flash, 2026-10-26): el menu se navega tambien con
	# raton, asi que al abrirlo hay que LIBERAR el mouse (antes lo hacia
	# player.gd togglando a ciegas el mouse_mode en cada Esc). Se guarda el modo
	# previo para devolverlo al cerrar, en vez de capturar siempre.
	_mouse_previo = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _boton_guardar != null:
		_conectar_guardar_dirty()
	if _buttons.size() > 0:
		_buttons[0].grab_focus()

func on_layer_closed() -> void:
	visible = false
	Input.mouse_mode = _mouse_previo

func focus_first() -> Control:
	if _buttons.size() > 0:
		return _buttons[0]
	return null

## Item 1 del riel (M59/M44): Guardar con confirmación + feedback.
## ── M59 ítem 4 (G-5.3-Flash-Agente, 2026-10-21): guardado manual solo con cambios ──
## El botón Guardar se deshabilita cuando la sesión no registra cambios
## (is_dirty false) y se re-habilita con cualquier evento que marque dirty.
## Refresco: al abrir la pausa y tras cada guardado.

func _conectar_guardar_dirty() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null:
		_boton_guardar.disabled = false
		return
	if sm.has_signal("save_completed") and not sm.save_completed.is_connected(_on_guardado_ok):
		sm.save_completed.connect(_on_guardado_ok)
	if sm.has_signal("save_failed") and not sm.save_failed.is_connected(_on_guardado_fail):
		sm.save_failed.connect(_on_guardado_fail)
	_refrescar_guardar_dirty()


func _refrescar_guardar_dirty() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm == null or not sm.has_method("is_dirty"):
		return
	_boton_guardar.disabled = not sm.is_dirty()


## Abre el ConfirmPopup; al aceptar, guarda por SaveManager (M59, cola real)
## y emite toast de feedback. Sin popup (CI/standalone), guardado directo.
func _pedir_confirmacion_guardado() -> void:
	var popup := _buscar_confirm_popup()
	if popup != null:
		popup.configurar_texto(
			_t_local("SETTINGS.GUARDAR_TITULO"),
			_t_local("SETTINGS.GUARDAR_CONFIRMA"),
			_ejecutar_guardado_manual)
		return
	_ejecutar_guardado_manual()


## Cuerpo de guardado (tras confirmación). Bloqueos de guardado (ítem 3):
## capas visibles, SaveManager bloqueado o carga de escena.
func _ejecutar_guardado_manual() -> void:
	if _modal_visible():
		_toast_guardado(false, "SETTINGS.GUARDAR_BLOQUEADO")
		return
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null:
		if sm.has_method("is_save_blocked") and sm.is_save_blocked():
			_toast_guardado(false, "SETTINGS.GUARDAR_BLOQUEADO")
			return
		# M59 ítem 3 (G-5.3-Flash-Agente, 2026-10-21): impedir el guardado manual
		# durante una CARGA DE ESCENA en curso (StreamManager M63, autoload real).
		# Gate conservador: cualquier carga de recursos en vuelo (incluida la
		# precarga M63) bloquea el guardado manual — el dueño M63/M40 puede afinar
		# el umbral (p. ej. solo transición de escena) con el mismo patrón.
		var stm := get_node_or_null("/root/StreamManager")
		if stm != null and stm.has_method("rutas_en_carga") and int(stm.rutas_en_carga()) > 0:
			_toast_guardado(false, "SETTINGS.GUARDAR_BLOQUEADO")
			return
		# Ítem 1 (M59/M44): guardado REAL vía SaveManager (cola + providers).
		if not sm.save_completed.is_connected(_on_guardado_ok):
			sm.save_completed.connect(_on_guardado_ok)
		if not sm.save_failed.is_connected(_on_guardado_fail):
			sm.save_failed.connect(_on_guardado_fail)
		sm.request_save(1, "guardado_manual_pausa")
		return
	_toast_guardado(false, "SETTINGS.GUARDAR_FALLO")

## Ítem 7 (M59): borrar el slot con confirmación (acción destructiva).
func _pedir_confirmacion_borrado() -> void:
	var popup := _buscar_confirm_popup()
	if popup == null:
		_hacer_borrado_slot()
		return
	popup.configurar_texto(
		_t_local("SETTINGS.BORRAR_TITULO"),
		_t_local("SETTINGS.BORRAR_CONFIRMA"),
		_hacer_borrado_slot)


## Encuentra el ConfirmPopup montado por UIRoot (duck typing: buscar_texto/configurar_texto).
func _buscar_confirm_popup() -> Node:
	var ur := get_parent()
	if ur == null:
		return null
	for hijo in ur.get_children():
		if hijo != null and hijo.has_method("configurar_texto"):
			return hijo
	return null


func _hacer_borrado_slot() -> void:
	var ds := get_node_or_null("/root/DataStore")
	if ds == null or not ds.has_method("borrar_slot"):
		_toast_guardado(false, "SETTINGS.GUARDAR_FALLO")
		return
	var ok: bool = ds.borrar_slot(1)
	_toast_guardado(ok, "SETTINGS.BORRAR_EXITO" if ok else "SETTINGS.GUARDAR_FALLO")


func _on_guardado_ok(_slot: int, _reason: String) -> void:
	_toast_guardado(true, "SETTINGS.GUARDAR_EXITO")


func _on_guardado_fail(_slot: int, _reason: String) -> void:
	_toast_guardado(false, "SETTINGS.GUARDAR_FALLO")


## Capa que ya está visible y es modal (no la propia pausa).
func _modal_visible() -> bool:
	var um := get_node_or_null("/root/UIManager")
	if um == null:
		return false
	for capa in um._stack:
		if capa == null or not capa.visible or capa == self:
			continue
		if String(capa.name) in ["DialogLayer", "ConfirmPopup", "InventoryLayer", "ShopUI", "EquipmentLayer", "DiaryLayer", "CraftingUI", "SettingsAudioLayer", "MenusLayer"]:
			return true
	return false


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
