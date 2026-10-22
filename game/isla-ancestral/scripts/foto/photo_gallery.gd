# Modelo: Reflection Beam 1.0
# Plataforma: Kilo Code
# Fecha: 2026-10-22
#
# M56: PhotoGallery — galería de fotos del jugador con LazyLoad de miniaturas.
# Solo carga las miniaturas visibles (M61: presupuesto de memoria, sin cargar
# todas las fotos en memoria). Paginación por scroll.
# Se integra con PhotoService (lista de fotos) y se muestra en el modo foto
# o en el menú del jugador.

extends Control

const CARPETA_FOTOS := "user://fotos/"
const TAMANO_MINIATURA := Vector2i(160, 90)
const MAX_MINIATURAS_CARGADAS := 24  # presupuesto M61: no cargar todas en memoria

var _scroll: ScrollContainer = null
var _grid: GridContainer = null
var _miniaturas_cargadas: Dictionary = {}  # ruta -> TextureRect
var _lista_fotos: Array[String] = []
var _indice_visible_inicio: int = 0
var _indice_visible_fin: int = 0


func _ready() -> void:
	_crear_ui()
	_cargar_lista_fotos()
	_actualizar_visibles()


func _crear_ui() -> void:
	_scroll = ScrollContainer.new()
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_scroll)
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	_scroll.add_child(_grid)
	_scroll.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)


func _cargar_lista_fotos() -> void:
	_lista_fotos.clear()
	var dir := DirAccess.open(CARPETA_FOTOS)
	if dir == null:
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".png"):
			_lista_fotos.append(CARPETA_FOTOS + fname)
		fname = dir.get_next()
	dir.list_dir_end()
	# Ordenar por nombre (timestamp en el nombre).
	_lista_fotos.sort()


func _actualizar_visibles() -> void:
	# Determinar qué miniaturas deberían estar visibles según el scroll.
	var scroll_y := _scroll.scroll_vertical
	var alto_viewport := _scroll.size.y
	var alto_fila := TAMANO_MINIATURA.y + 8
	var fila_inicio := int(scroll_y / alto_fila)
	var fila_fin := int((scroll_y + alto_viewport) / alto_fila) + 1
	var cols := _grid.columns
	var idx_inicio := fila_inicio * cols
	var idx_fin := mini(idx_inicio + (fila_fin - fila_inicio + 1) * cols, _lista_fotos.size())
	# Descargar miniaturas fuera del rango visible (LazyLoad).
	var a_descargar := []
	for ruta in _miniaturas_cargadas.keys():
		var idx := _lista_fotos.find(ruta)
		if idx < idx_inicio or idx >= idx_fin:
			a_descargar.append(ruta)
	for ruta in a_descargar:
		var tr: TextureRect = _miniaturas_cargadas[ruta]
		if tr != null and is_instance_valid(tr):
			tr.texture = null
		_miniaturas_cargadas.erase(ruta)
	# Cargar miniaturas visibles que no estén cargadas.
	for i in range(idx_inicio, idx_fin):
		if i < 0 or i >= _lista_fotos.size():
			continue
		var ruta := _lista_fotos[i]
		if _miniaturas_cargadas.has(ruta):
			continue
		if _miniaturas_cargadas.size() >= MAX_MINIATURAS_CARGADAS:
			break
		_cargar_miniatura(ruta, i)


func _cargar_miniatura(ruta: String, idx: int) -> void:
	# Cargar la miniatura en background (no bloquear el hilo principal).
	# En Godot 4, Image.load_from_file es síncrono pero rápido para thumbnails.
	var img := Image.new()
	var err := img.load(ruta)
	if err != OK:
		return
	img.resize(TAMANO_MINIATURA.x, TAMANO_MINIATURA.y, Image.INTERPOLATE_BILINEAR)
	var tex := ImageTexture.create_from_image(img)
	var tr := TextureRect.new()
	tr.texture = tex
	tr.custom_minimum_size = TAMANO_MINIATURA
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# Guardar la ruta para referencia.
	tr.set_meta("ruta", ruta)
	tr.gui_input.connect(_on_miniatura_input.bind(ruta))
	_grid.add_child(tr)
	_miniaturas_cargadas[ruta] = tr


func _on_miniatura_input(event: InputEvent, ruta: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_abrir_foto(ruta)


func _abrir_foto(ruta: String) -> void:
	# Abrir la foto a tamaño completo (placeholder: log).
	print("[GALLERY] abrir foto: %s" % ruta)


func _on_scroll_changed(_value: float) -> void:
	_actualizar_visibles()


func recargar() -> void:
	# Limpiar miniaturas cargadas y recargar la lista.
	for ruta in _miniaturas_cargadas.keys():
		var tr: TextureRect = _miniaturas_cargadas[ruta]
		if tr != null and is_instance_valid(tr):
			tr.queue_free()
	_miniaturas_cargadas.clear()
	_cargar_lista_fotos()
	_actualizar_visibles()