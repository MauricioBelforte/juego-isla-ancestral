# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M39: ShopUI — panel de tienda (capa M53, MODAL_SIMPLE).
# Catálogo con precio/stock (RF: consulta a ShopManager.listar_stock + EconomyManager
# precios vigentes M93/M38), compra 1x/máx, venta de items del jugador aceptados por
# recompra, saldo en vivo. Solo consume ShopManager/EconomyManager/Inventario —
# nunca muta contenedores directamente (separación de capas).
# Textos localizados (M87). Abre con ShopUI.abrir(shop_id).

class_name ShopUI
extends UILayer

var _shop_id: String = ""
var _item_seleccionado: String = ""

var _title_label: Label
var _saldo_label: Label
var _lista_box: VBoxContainer
var _detalle_label: RichTextLabel
var _btn_comprar1: Button
var _btn_comprar_max: Button
var _btn_vender1: Button
var _btn_vender_max: Button
var _mensaje_label: Label
var _venta_box: VBoxContainer

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_SIMPLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	var sm = get_node_or_null("/root/ShopManager")
	if sm:
		sm.compra_exitosa.connect(_on_tx_ok)
		sm.venta_exitosa.connect(_on_tx_ok)
		sm.compra_rechazada.connect(_on_tx_rechazada)
		sm.venta_rechazada.connect(_on_tx_rechazada)
		sm.inventario_tienda_cambio.connect(_on_stock_cambio)

## ── Construcción de la UI ────────────────────────────────

func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.4)
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
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.custom_minimum_size = Vector2(480, 340)
	panel.add_child(vbox)

	var fila_titulo := HBoxContainer.new()
	fila_titulo.add_theme_constant_override("separation", 12)
	vbox.add_child(fila_titulo)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_titulo.add_child(_title_label)

	_saldo_label = Label.new()
	_saldo_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_BODY)
	_saldo_label.add_theme_color_override("font_color", Color(0.72, 0.55, 0.30))
	fila_titulo.add_child(_saldo_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var lbl_catalogo := Label.new()
	lbl_catalogo.text = _t("TIENDAS.CATALOGO")
	lbl_catalogo.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	vbox.add_child(lbl_catalogo)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 120)
	vbox.add_child(scroll)
	_lista_box = VBoxContainer.new()
	_lista_box.add_theme_constant_override("separation", 4)
	_lista_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_lista_box)

	var lbl_inventario := Label.new()
	lbl_inventario.text = _t("TIENDAS.VENDER_TITULO")
	lbl_inventario.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	vbox.add_child(lbl_inventario)

	_venta_box = VBoxContainer.new()
	_venta_box.add_theme_constant_override("separation", 4)
	vbox.add_child(_venta_box)

	_detalle_label = RichTextLabel.new()
	_detalle_label.bbcode_enabled = true
	_detalle_label.fit_content = true
	_detalle_label.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(_detalle_label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	_btn_comprar1 = Button.new()
	_btn_comprar1.pressed.connect(_on_comprar_1)
	hbox.add_child(_btn_comprar1)

	_btn_comprar_max = Button.new()
	_btn_comprar_max.pressed.connect(_on_comprar_max)
	hbox.add_child(_btn_comprar_max)

	_btn_vender1 = Button.new()
	_btn_vender1.pressed.connect(_on_vender_1)
	hbox.add_child(_btn_vender1)

	_btn_vender_max = Button.new()
	_btn_vender_max.pressed.connect(_on_vender_max)
	hbox.add_child(_btn_vender_max)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	var btn_cerrar := Button.new()
	btn_cerrar.text = _t("SETTINGS.CERRAR")
	btn_cerrar.pressed.connect(_cerrar)
	hbox.add_child(btn_cerrar)

	_mensaje_label = Label.new()
	_mensaje_label.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_SMALL)
	_mensaje_label.add_theme_color_override("font_color", Color(0.4, 0.55, 0.3))
	vbox.add_child(_mensaje_label)

## ── Apertura / cierre ────────────────────────────────────

func abrir(shop_id: String) -> void:
	_shop_id = shop_id
	_item_seleccionado = ""
	visible = true
	var sm = get_node_or_null("/root/ShopManager")
	var nombre_clave := "TIENDAS.GENERAL"
	if sm:
		var tienda = sm.obtener_tienda(shop_id)
		if tienda and tienda.definicion:
			nombre_clave = str(tienda.definicion.nombre_clave_i18n)
	_title_label.text = _t(nombre_clave)
	_mensaje_label.text = ""
	_refrescar()

func _cerrar() -> void:
	visible = false
	_shop_id = ""

## ── Refresh ──────────────────────────────────────────────

func _refrescar() -> void:
	if not visible:
		return
	_refrescar_saldo()
	_refrescar_catalogo()
	_refrescar_venta()
	_refrescar_detalle()

func _refrescar_saldo() -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	_saldo_label.text = "%s: %d" % [_t("TIENDAS.SALDO"), int(eco.saldo) if eco else 0]

func _refrescar_catalogo() -> void:
	for child in _lista_box.get_children():
		child.queue_free()
	var sm = get_node_or_null("/root/ShopManager")
	var eco = get_node_or_null("/root/EconomyManager")
	if sm == null or _shop_id == "":
		return
	var stock: Dictionary = sm.listar_stock(_shop_id)
	var item_ids := stock.keys()
	item_ids.sort()
	for item_id in item_ids:
		var cantidad: int = int(stock[item_id])
		if cantidad <= 0:
			continue
		var precio: int = eco.precio_compra_vigente(str(item_id), _npc_de(_shop_id)) if eco else 0
		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = "%s — %d AO (x%d)" % [_nombre_item(str(item_id)), precio, cantidad]
		btn.pressed.connect(_on_seleccionar.bind(str(item_id), precio))
		_lista_box.add_child(btn)

func _refrescar_venta() -> void:
	for child in _venta_box.get_children():
		child.queue_free()
	var sm = get_node_or_null("/root/ShopManager")
	var inv = get_node_or_null("/root/Inventario")
	var eco = get_node_or_null("/root/EconomyManager")
	if sm == null or inv == null or _shop_id == "":
		return
	var tienda = sm.obtener_tienda(_shop_id)
	if tienda == null or tienda.definicion == null:
		return
	var recompra: Array = tienda.definicion.catalogo_recompra
	for item_id in recompra:
		var cantidad: int = int(inv.count_item(str(item_id), true))
		if cantidad <= 0:
			continue
		var precio: int = eco.precio_venta_vigente(str(item_id)) if eco else 0
		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = "%s — %d AO (x%d)" % [_nombre_item(str(item_id)), precio, cantidad]
		btn.pressed.connect(_on_seleccionar_venta.bind(str(item_id), precio, cantidad))
		_venta_box.add_child(btn)

func _refrescar_detalle() -> void:
	var eco = get_node_or_null("/root/EconomyManager")
	if _item_seleccionado == "":
		_detalle_label.text = _t("TIENDAS.SELECCIONA")
		_actualizar_botones(0, 0)
		return
	var sm = get_node_or_null("/root/ShopManager")
	var inv = get_node_or_null("/root/Inventario")
	var stock: int = int(sm.listar_stock(_shop_id).get(_item_seleccionado, 0)) if sm else 0
	var precio_compra: int = eco.precio_compra_vigente(_item_seleccionado, _npc_de(_shop_id)) if eco else 0
	var precio_venta: int = eco.precio_venta_vigente(_item_seleccionado) if eco else 0
	var tengo: int = int(inv.count_item(_item_seleccionado, true)) if inv else 0
	var lineas: Array = []
	if stock > 0:
		lineas.append(_t("TIENDAS.COMPRA_INFO") % [precio_compra, stock])
	if tengo > 0:
		lineas.append(_t("TIENDAS.VENTA_INFO") % [precio_venta, tengo])
	_detalle_label.text = "\n".join(lineas)
	_actualizar_botones(stock, tengo)

func _actualizar_botones(stock: int, tengo: int) -> void:
	_btn_comprar1.text = _t("TIENDAS.COMPRAR_1")
	_btn_comprar_max.text = _t("TIENDAS.COMPRAR_N")
	_btn_vender1.text = _t("TIENDAS.VENDER_1")
	_btn_vender_max.text = _t("TIENDAS.VENDER_N")
	_btn_comprar1.disabled = _item_seleccionado == "" or stock < 1
	_btn_comprar_max.disabled = _item_seleccionado == "" or stock < 1
	_btn_vender1.disabled = _item_seleccionado == "" or tengo < 1
	_btn_vender_max.disabled = _item_seleccionado == "" or tengo < 1

## ── Acciones ─────────────────────────────────────────────

func _on_seleccionar(item_id: String, _precio: int) -> void:
	_item_seleccionado = item_id
	_refrescar_detalle()

func _on_seleccionar_venta(item_id: String, _precio: int, _cantidad: int) -> void:
	_item_seleccionado = item_id
	_refrescar_detalle()

func _on_comprar_1() -> void:
	_comprar(1)

func _on_comprar_max() -> void:
	var sm = get_node_or_null("/root/ShopManager")
	var eco = get_node_or_null("/root/EconomyManager")
	var inv = get_node_or_null("/root/Inventario")
	if sm == null or eco == null or inv == null or _item_seleccionado == "":
		return
	var stock: int = int(sm.listar_stock(_shop_id).get(_item_seleccionado, 0))
	var precio: int = eco.precio_compra_vigente(_item_seleccionado, _npc_de(_shop_id))
	var saldo: int = int(eco.saldo)
	var max_por_precio: int = int(saldo / maxf(float(precio), 1.0)) if precio > 0 else stock
	sm.comprar(_shop_id, _item_seleccionado, clampi(mini(stock, max_por_precio), 0, stock))

func _on_vender_1() -> void:
	_vender(1)

func _on_vender_max() -> void:
	var inv = get_node_or_null("/root/Inventario")
	if inv and _item_seleccionado != "":
		_vender(int(inv.count_item(_item_seleccionado, true)))

func _comprar(cantidad: int) -> void:
	var sm = get_node_or_null("/root/ShopManager")
	if sm and _item_seleccionado != "":
		sm.comprar(_shop_id, _item_seleccionado, cantidad)

func _vender(cantidad: int) -> void:
	var sm = get_node_or_null("/root/ShopManager")
	if sm and _item_seleccionado != "" and cantidad > 0:
		sm.vender(_shop_id, _item_seleccionado, cantidad)

## ── Callbacks ────────────────────────────────────────────

func _on_tx_ok(_p_shop_id: String, _item_id: String, _cantidad: int, _total: int, _precio: int) -> void:
	_mensaje_label.text = _t("TIENDAS.TRANSACCION_OK")
	_item_seleccionado = ""
	_refrescar()

func _on_tx_rechazada(_p_shop_id: String, _item_id: String, motivo) -> void:
	_mensaje_label.text = _motivo_texto(str(motivo))
	_refrescar()

func _motivo_texto(motivo: String) -> String:
	match motivo:
		"SIN_FONDOS":
			return _t("TIENDAS.SIN_FONDOS")
		"SIN_STOCK":
			return _t("TIENDAS.SIN_STOCK")
		"INVENTARIO_LLENO":
			return _t("TIENDAS.INVENTARIO_LLENO")
		"SIN_ITEMS_JUGADOR":
			return _t("TIENDAS.SIN_ITEMS")
		"CERRADA":
			return _t("TIENDAS.CERRADA")
		_:
			return _t("TIENDAS.TRANSACCION_FALLO")

func _on_stock_cambio(_p_shop_id: String, _item_id: String, _stock: int) -> void:
	if visible:
		_refrescar()

## ── Utilidades ───────────────────────────────────────────

func _npc_de(shop_id: String) -> String:
	var sm = get_node_or_null("/root/ShopManager")
	if sm:
		var tienda = sm.obtener_tienda(shop_id)
		if tienda and tienda.definicion:
			return str(tienda.definicion.npc_duenio_id)
	return ""

func _nombre_item(item_id: String) -> String:
	var limpio := item_id.replace("_", " ").strip_edges()
	if limpio.length() > 0:
		limpio = limpio[0].to_upper() + limpio.substr(1)
	return limpio

func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pausa"):
		_cerrar()
		get_viewport().set_input_as_handled()

func on_layer_opened() -> void:
	pass

func on_layer_closed() -> void:
	visible = false
