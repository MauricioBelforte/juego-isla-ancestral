# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-04
#
# M55 (T-M1, frente del canal 12): DiaryLayer — pantalla del diario del jugador.
# Reescritura completa del esqueleto T-053-067 (API muerta get_categorias/
# get_entradas_por_categoria) contra la API real de DiaryService (iter. 1 glm):
#   get_categorias(), entradas_de(cat), buscar(q), progreso_categoria(cat),
#   estado_de(), es_favorito(), alternar_favorito(), nuevas_sesion().
#
# Diseño (plan-actual 03-Diseno §2):
#   - Tres columnas cozy (panel estilo settings/inventory): pestañas por
#     categoría (14) | lista con búsqueda y filtros | detalle de la entrada.
#   - Dos clics a cualquier entrada: pestaña → fila (checklist A).
#   - Barra de % por categoría en la cabecera + % global; SIEMPRE sobre lo
#     DESCUBIERTO (§3.2 anti-spoiler: el % nunca revela contenido oculto;
#     tooltip DIARY.PROGRESO_CAT: "del contenido descubierto").
#   - Fila = estrella ★ (si favorito) + título crudo (M87: nombres propios sin
#     traducir) + estado; secreta no registrada = "???" (DIARY.BLOQUEADO).
#   - Lista SOLO sale de entradas_de() (ya filtra no-descubiertas).
#   - Todo texto por claves i18n vía _t(); al abrir re-traduce (on_layer_opened).
#   - Abrir: open() (patrón sancionado ui_manager L457); on_layer_opened
#     re-registra la capa (heal tras Esc/close_top) y refresca todo.
#
# Input (ui_manager._unhandled_input): acción `diario` (J) → toggle(); acción
# `favorito` → alterna el favorito de la entrada seleccionada si la capa está
# visible. Esc → close_top (purga la capa VISIBLE — fix T-M1 en ui_manager).
#
# Rendimiento: lista con free() inmediato y sin pool — la virtualización es
# checklist W (Lote 2). Ver 04-Codigo.md Notas del Agente.
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_diario_ui.gd

class_name DiaryLayer
extends UILayer

## Índices del filtro de estado (orden de FiltroEstado)
enum Filtro { TODOS, NUEVOS, VISTOS, COMPLETADOS, FAVORITOS }

var _categoria_actual: String = ""
var _busqueda: String = ""
var _filtro: int = Filtro.TODOS
var _sel: Dictionary = {}  # copia de la entrada seleccionada en la lista

var _tabs: Array[Button] = []
var _filas: Array[Button] = []

var _lbl_titulo: Label
var _lbl_cats: Label
var _lbl_filtro: Label
var _lbl_det_hdr: Label
var _lbl_global: Label
var _barra_cat: ProgressBar
var _btn_cerrar: Button
var _categorias_box: VBoxContainer
var _buscador: LineEdit
var _filtro_op: OptionButton
var _lista: VBoxContainer
var _lbl_vacio: Label
var _lbl_det_titulo: Label
var _lbl_det_estado: Label
var _lbl_det_dia: Label
var _btn_det_fav: Button
var _lbl_sin_sel: Label


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
	panel.name = "PanelDiario"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.name = "VBoxPrincipal"
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	# ── Cabecera: título | barra de % de categoría + % global | cerrar ──
	var header := HBoxContainer.new()
	header.name = "Cabecera"
	header.add_theme_constant_override("separation", 12)
	vbox.add_child(header)

	_lbl_titulo = Label.new()
	_lbl_titulo.name = "LblTitulo"
	_lbl_titulo.text = _t("DIARY.TITULO")
	_lbl_titulo.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H1)
	header.add_child(_lbl_titulo)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)

	_barra_cat = ProgressBar.new()
	_barra_cat.name = "ProgresoCat"
	_barra_cat.min_value = 0.0
	_barra_cat.max_value = 100.0
	_barra_cat.value = 0.0
	_barra_cat.show_percentage = false
	_barra_cat.custom_minimum_size = Vector2(150, 14)
	_barra_cat.tooltip_text = _t("DIARY.PROGRESO_CAT")
	_barra_cat.set_meta("tooltip_text_key", "DIARY.PROGRESO_CAT")
	header.add_child(_barra_cat)

	_lbl_global = Label.new()
	_lbl_global.name = "LblProgresoGlobal"
	_lbl_global.text = "%s: 0%%" % _t("DIARY.PROGRESO_GLOBAL")
	_lbl_global.tooltip_text = _t("DIARY.PROGRESO_CAT")
	_lbl_global.set_meta("tooltip_text_key", "DIARY.PROGRESO_CAT")
	header.add_child(_lbl_global)

	_btn_cerrar = Button.new()
	_btn_cerrar.name = "BtnCerrar"
	_btn_cerrar.text = _t("SETTINGS.CERRAR")
	_btn_cerrar.pressed.connect(close)
	header.add_child(_btn_cerrar)

	vbox.add_child(HSeparator.new())

	# ── Cuerpo: categorías | lista | detalle ────────────────────────────
	var cuerpo := HBoxContainer.new()
	cuerpo.name = "Cuerpo"
	cuerpo.add_theme_constant_override("separation", 20)
	vbox.add_child(cuerpo)

	# Columna izquierda: pestañas por categoría
	var col_izq := VBoxContainer.new()
	col_izq.name = "ColCategorias"
	col_izq.custom_minimum_size = Vector2(210, 0)
	cuerpo.add_child(col_izq)

	_lbl_cats = Label.new()
	_lbl_cats.name = "LblCategorias"
	_lbl_cats.text = _t("DIARY.CATEGORIAS")
	_lbl_cats.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	col_izq.add_child(_lbl_cats)

	col_izq.add_child(HSeparator.new())

	_categorias_box = VBoxContainer.new()
	_categorias_box.name = "CategoriasBox"
	_categorias_box.add_theme_constant_override("separation", 4)
	col_izq.add_child(_categorias_box)

	# Columna central: búsqueda + filtro + lista
	var col_centro := VBoxContainer.new()
	col_centro.name = "ColLista"
	col_centro.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_centro.add_theme_constant_override("separation", 8)
	cuerpo.add_child(col_centro)

	var fila_ctrl := HBoxContainer.new()
	fila_ctrl.name = "FilaControles"
	fila_ctrl.add_theme_constant_override("separation", 8)
	col_centro.add_child(fila_ctrl)

	_buscador = LineEdit.new()
	_buscador.name = "Buscador"
	_buscador.placeholder_text = _t("DIARY.BUSCAR")
	_buscador.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_buscador.clear_button_enabled = true
	_buscador.text_changed.connect(_on_busqueda_changed)
	fila_ctrl.add_child(_buscador)

	_lbl_filtro = Label.new()
	_lbl_filtro.name = "LblFiltro"
	_lbl_filtro.text = _t("DIARY.FILTRO")
	fila_ctrl.add_child(_lbl_filtro)

	_filtro_op = OptionButton.new()
	_filtro_op.name = "FiltroEstado"
	_filtro_op.add_item(_t("DIARY.FILTRO_TODOS"), Filtro.TODOS)
	_filtro_op.add_item(_t("DIARY.FILTRO_NUEVOS"), Filtro.NUEVOS)
	_filtro_op.add_item(_t("DIARY.FILTRO_VISTOS"), Filtro.VISTOS)
	_filtro_op.add_item(_t("DIARY.FILTRO_COMPLETADOS"), Filtro.COMPLETADOS)
	_filtro_op.add_item(_t("DIARY.FILTRO_FAVORITOS"), Filtro.FAVORITOS)
	_filtro_op.item_selected.connect(_on_filtro_selected)
	fila_ctrl.add_child(_filtro_op)

	var scroll := ScrollContainer.new()
	scroll.name = "ScrollLista"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 320)
	col_centro.add_child(scroll)

	_lista = VBoxContainer.new()
	_lista.name = "ListaEntradas"
	_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lista.add_theme_constant_override("separation", 4)
	scroll.add_child(_lista)

	_lbl_vacio = Label.new()
	_lbl_vacio.name = "LblVacio"
	_lbl_vacio.text = _t("DIARY.SIN_ENTRADAS")
	_lbl_vacio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_vacio.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_vacio.visible = false
	col_centro.add_child(_lbl_vacio)

	# Columna derecha: detalle de la entrada
	var col_der := VBoxContainer.new()
	col_der.name = "ColDetalle"
	col_der.custom_minimum_size = Vector2(280, 0)
	col_der.add_theme_constant_override("separation", 8)
	cuerpo.add_child(col_der)

	_lbl_det_hdr = Label.new()
	_lbl_det_hdr.name = "LblDetalle"
	_lbl_det_hdr.text = _t("DIARY.DETALLE")
	_lbl_det_hdr.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	col_der.add_child(_lbl_det_hdr)

	col_der.add_child(HSeparator.new())

	_lbl_det_titulo = Label.new()
	_lbl_det_titulo.name = "LblDetalleTitulo"
	_lbl_det_titulo.add_theme_font_size_override("font_size", ThemeUx.FONT_SIZE_H2)
	_lbl_det_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_det_titulo.text = ""
	col_der.add_child(_lbl_det_titulo)

	_lbl_det_estado = Label.new()
	_lbl_det_estado.name = "LblDetalleEstado"
	_lbl_det_estado.text = ""
	col_der.add_child(_lbl_det_estado)

	_lbl_det_dia = Label.new()
	_lbl_det_dia.name = "LblDetalleDia"
	_lbl_det_dia.text = ""
	col_der.add_child(_lbl_det_dia)

	_btn_det_fav = Button.new()
	_btn_det_fav.name = "BtnFavoritoDetalle"
	_btn_det_fav.text = _t("DIARY.FAVORITO")
	_btn_det_fav.toggle_mode = true
	_btn_det_fav.disabled = true
	_btn_det_fav.pressed.connect(_on_favorito_pressed)
	col_der.add_child(_btn_det_fav)

	_lbl_sin_sel = Label.new()
	_lbl_sin_sel.name = "LblSinSeleccion"
	_lbl_sin_sel.text = _t("DIARY.SIN_SELECCION")
	_lbl_sin_sel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_sin_sel.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	col_der.add_child(_lbl_sin_sel)


## Alterna la visibilidad (patrón inventory_layer.toggle)
func toggle() -> void:
	if visible:
		close()
	else:
		open()


## ── Datos (defensivo: sin Diary la capa muestra estados vacíos) ─────

func _diario() -> Node:
	return get_node_or_null("/root/Diary")


func _refrescar_completo() -> void:
	if _categoria_actual == "":
		var d = _diario()
		if d != null:
			var cats: Array = d.get_categorias()
			if cats.size() > 0:
				_categoria_actual = String(cats[0])
	_construir_tabs()
	_refrescar_lista()
	_refrescar_detalle()
	_refrescar_progreso()


func _construir_tabs() -> void:
	for h in _categorias_box.get_children():
		if h is Button:
			h.free()
	_tabs.clear()
	var d = _diario()
	if d == null:
		return
	for cat in d.get_categorias():
		var b := Button.new()
		b.name = "Tab_" + String(cat)
		b.text = _t("DIARY.CAT_" + String(cat).to_upper())
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.tooltip_text = _t("DIARY.PROGRESO_CAT")
		b.set_meta("tooltip_text_key", "DIARY.PROGRESO_CAT")
		b.pressed.connect(_on_tab.bind(String(cat)))
		_categorias_box.add_child(b)
		_tabs.append(b)
	_pintar_tabs_activos()


func _pintar_tabs_activos() -> void:
	for b in _tabs:
		var activo := String(b.name).substr(4) == _categoria_actual
		b.add_theme_color_override("font_color",
			Color(0.45, 0.28, 0.10) if activo else Color(0.32, 0.26, 0.20))


## Entradas visibles: catálogo filtrado por la capa (búsqueda + filtro de estado)
func _entradas_visibles() -> Array:
	var d = _diario()
	if d == null:
		return []
	var base: Array[Dictionary] = []
	if _busqueda.strip_edges() != "":
		var ids: Array = d.buscar(_busqueda)
		for cat in d.get_categorias():
			for e in d.entradas_de(cat):
				if ids.has(String(e.get("id", ""))):
					var c: Dictionary = (e as Dictionary).duplicate()
					c["cat"] = String(cat)
					base.append(c)
	else:
		if _categoria_actual == "":
			return []
		for e in d.entradas_de(_categoria_actual):
			var c: Dictionary = (e as Dictionary).duplicate()
			c["cat"] = _categoria_actual
			base.append(c)
	if _filtro == Filtro.TODOS:
		return base
	var nuevas: Array = d.nuevas_sesion()
	var res: Array[Dictionary] = []
	for e in base:
		var eid := String(e.get("id", ""))
		var ok := false
		match _filtro:
			Filtro.NUEVOS:
				ok = nuevas.has(eid)
			Filtro.VISTOS:
				ok = int(e.get("estado", 0)) == 1
			Filtro.COMPLETADOS:
				ok = int(e.get("estado", 0)) == 2
			Filtro.FAVORITOS:
				ok = bool(e.get("favorito", false))
		if ok:
			res.append(e)
	return res


func _texto_estado(est: int) -> String:
	match est:
		1:
			return _t("DIARY.ESTADO_VISTO")
		2:
			return _t("DIARY.ESTADO_COMPLETADO")
	return _t("DIARY.ESTADO_NUEVO")


func _texto_fila(e: Dictionary) -> String:
	var secreta := bool(e.get("secreta", false))
	var reg := bool(e.get("registrada", false))
	if secreta and not reg:
		return _t("DIARY.BLOQUEADO")  # "???" (solo lore §3.2)
	var txt := String(e.get("titulo", ""))
	if bool(e.get("favorito", false)):
		txt = "★ " + txt
	if _busqueda.strip_edges() != "":
		txt = "%s · %s" % [_t("DIARY.CAT_" + String(e.get("cat", "")).to_upper()), txt]
	txt += "  ·  " + _texto_estado(int(e.get("estado", 0)))
	return txt


func _refrescar_lista() -> void:
	for f in _filas:
		if is_instance_valid(f):
			f.free()
	_filas.clear()
	var entradas := _entradas_visibles()
	for e in entradas:
		var b := Button.new()
		b.name = "Fila_" + String(e.get("id", ""))
		b.text = _texto_fila(e)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.tooltip_text = String(e.get("titulo", ""))  # texto completo (checklist W)
		b.pressed.connect(_on_fila_pressed.bind((e as Dictionary).duplicate()))
		_lista.add_child(b)
		_filas.append(b)
	_lbl_vacio.visible = entradas.is_empty()
	if entradas.is_empty():
		_lbl_vacio.text = _t("DIARY.SIN_RESULTADOS") if _busqueda.strip_edges() != "" else _t("DIARY.SIN_ENTRADAS")


func _refrescar_detalle() -> void:
	var hay := _sel.size() > 0
	_lbl_sin_sel.visible = not hay
	if not hay:
		_lbl_det_titulo.text = ""
		_lbl_det_estado.text = ""
		_lbl_det_dia.text = ""
		_btn_det_fav.disabled = true
		_btn_det_fav.set_pressed_no_signal(false)
		return
	var secreta := bool(_sel.get("secreta", false))
	var reg := bool(_sel.get("registrada", false))
	if secreta and not reg:
		_lbl_det_titulo.text = _t("DIARY.BLOQUEADO")
		_lbl_det_estado.text = _t("DIARY.BLOQUEADO")
		_lbl_det_dia.text = ""
		_btn_det_fav.disabled = true
		_btn_det_fav.set_pressed_no_signal(false)
		return
	_lbl_det_titulo.text = String(_sel.get("titulo", ""))
	_lbl_det_estado.text = _texto_estado(int(_sel.get("estado", 0)))
	var dia := int(_sel.get("dia", 0))
	_lbl_det_dia.text = (_t("DIARY.DIA") % str(dia)) if dia > 0 else ""
	_btn_det_fav.disabled = false
	_btn_det_fav.set_pressed_no_signal(bool(_sel.get("favorito", false)))


func _refrescar_progreso() -> void:
	var d = _diario()
	var vistas := 0
	var total := 0
	var pct_cat := 0.0
	if d != null:
		for cat in d.get_categorias():
			var p: Dictionary = d.progreso_categoria(cat)
			var v := int(p.get("vistas", 0))
			var t := int(p.get("descubiertas", 0))
			vistas += v
			total += t
			if String(cat) == _categoria_actual and t > 0:
				pct_cat = clampf(float(p.get("percent", 0.0)) * 100.0, 0.0, 100.0)
	_barra_cat.value = pct_cat
	var pct_g := 0
	if total > 0:
		pct_g = clampi(int(round(100.0 * float(vistas) / float(total))), 0, 100)
	_lbl_global.text = "%s: %d%%" % [_t("DIARY.PROGRESO_GLOBAL"), pct_g]


## ── Señales de widgets ──────────────────────────────────────────────

func _on_tab(cat: String) -> void:
	_categoria_actual = cat
	_sel = {}
	if _busqueda != "":
		_busqueda = ""
		_buscador.text = ""  # sin text_changed (ya refrescamos abajo)
	_pintar_tabs_activos()
	_refrescar_lista()
	_refrescar_detalle()
	_refrescar_progreso()


func _on_busqueda_changed(txt: String) -> void:
	_busqueda = txt
	_sel = {}
	_refrescar_lista()
	_refrescar_detalle()


func _on_filtro_selected(idx: int) -> void:
	_filtro = idx
	_sel = {}
	_refrescar_lista()
	_refrescar_detalle()


func _on_fila_pressed(e: Dictionary) -> void:
	_sel = e
	_refrescar_detalle()


func _on_favorito_pressed() -> void:
	var d = _diario()
	if d == null or _sel.is_empty():
		return
	var eid := String(_sel.get("id", ""))
	if not d.esta_registrada(eid):
		return
	# alternar_favorito devuelve el NUEVO estado (false al desmarcar):
	# no se usa como guard, solo esta_registrada arriba.
	d.alternar_favorito(eid)
	_sel["favorito"] = d.es_favorito(eid)
	_btn_det_fav.set_pressed_no_signal(bool(_sel.get("favorito", false)))
	_refrescar_lista()  # re-pinta la ★ de la fila (undo visual, checklist T)


## Para la acción `favorito` (ui_manager): alterna sobre la selección actual
func alternar_favorito_seleccionado() -> void:
	if not _btn_det_fav.disabled and not _sel.is_empty():
		_on_favorito_pressed()


## ── UILayer virtual ─────────────────────────────────────────────────

## Re-aplica los textos estáticos al abrir (cambios de locale en caliente, M87)
func _aplicar_textos_estaticos() -> void:
	_lbl_titulo.text = _t("DIARY.TITULO")
	_lbl_cats.text = _t("DIARY.CATEGORIAS")
	_lbl_det_hdr.text = _t("DIARY.DETALLE")
	_lbl_filtro.text = _t("DIARY.FILTRO")
	_btn_cerrar.text = _t("SETTINGS.CERRAR")
	_btn_det_fav.text = _t("DIARY.FAVORITO")
	_lbl_sin_sel.text = _t("DIARY.SIN_SELECCION")
	_buscador.placeholder_text = _t("DIARY.BUSCAR")
	_barra_cat.tooltip_text = _t("DIARY.PROGRESO_CAT")
	_lbl_global.tooltip_text = _t("DIARY.PROGRESO_CAT")
	_filtro_op.set_item_text(Filtro.TODOS, _t("DIARY.FILTRO_TODOS"))
	_filtro_op.set_item_text(Filtro.NUEVOS, _t("DIARY.FILTRO_NUEVOS"))
	_filtro_op.set_item_text(Filtro.VISTOS, _t("DIARY.FILTRO_VISTOS"))
	_filtro_op.set_item_text(Filtro.COMPLETADOS, _t("DIARY.FILTRO_COMPLETADOS"))
	_filtro_op.set_item_text(Filtro.FAVORITOS, _t("DIARY.FILTRO_FAVORITOS"))


func on_layer_opened() -> void:
	# Re-registrar por si un Esc (close_top) des-registró la capa:
	# register_layer es idempotente (no-op si ya está en la pila).
	var um := _get_ui_manager()
	if um and um.has_method("register_layer"):
		um.register_layer(self)
	_aplicar_textos_estaticos()
	_refrescar_completo()


func on_layer_closed() -> void:
	pass  # visible=false lo gestiona UILayer.close()


func focus_first() -> Control:
	if _tabs.size() > 0:
		return _tabs[0]
	return null


func _t(clave: String) -> String:
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return res
	return clave
