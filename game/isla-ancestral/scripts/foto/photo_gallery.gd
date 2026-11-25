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
var _miniaturas_cargadas: Dictionary = {}  # ruta -> TextureRect (texture != null)
var _nodos_fotos: Dictionary = {}  # ruta -> TextureRect (nodo reutilizado, texture puede ser null)
var _lista_fotos: Array[String] = []
var _indice_visible_inicio: int = 0
var _indice_visible_fin: int = 0


func _ready() -> void:
	_crear_ui()
	_cargar_lista_fotos()
	_crear_nodos_fotos()
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

## M56 L161: un TextureRect POR FOTO, creado una sola vez en orden de lista
## (el layout del GridContainer queda estable). Sin textura al crear: las
## texturas se cargan SOLO para el rango visible (presupuesto M61 <= 24) y se
## descargan fuera de él — nunca se re-crea un nodo al volver a una foto.
func _crear_nodos_fotos() -> void:
	for i in range(_lista_fotos.size()):
		var ruta: String = _lista_fotos[i]
		if _nodos_fotos.has(ruta):
			continue
		var tr := TextureRect.new()
		tr.custom_minimum_size = TAMANO_MINIATURA
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.set_meta("ruta", ruta)
		tr.set_meta("idx", i)
		tr.gui_input.connect(_on_miniatura_input.bind(ruta))
		_grid.add_child(tr)
		_nodos_fotos[ruta] = tr


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
	# Descargar texturas fuera del rango visible (LazyLoad): el nodo queda
	# (para el layout) pero su textura se libera (L161: sin duplicar texturas).
	_miniaturas_cargadas.clear()
	for ruta in _nodos_fotos:
		var tr_f: TextureRect = _nodos_fotos[ruta]
		if not is_instance_valid(tr_f):
			continue
		var idx_f: int = int(tr_f.get_meta("idx"))
		if idx_f < idx_inicio or idx_f >= idx_fin:
			tr_f.texture = null
	# Cargar texturas SOLO para las fotos visibles sin textura.
	var cargadas: int = 0
	for i in range(idx_inicio, idx_fin):
		if i < 0 or i >= _lista_fotos.size():
			continue
		var ruta := _lista_fotos[i]
		var tr: TextureRect = _nodos_fotos.get(ruta, null)
		if tr == null or not is_instance_valid(tr):
			continue
		if tr.texture != null:
			_miniaturas_cargadas[ruta] = tr
			continue
		if cargadas >= MAX_MINIATURAS_CARGADAS:
			continue
		_cargar_miniatura(ruta, tr)
		cargadas += 1


func _cargar_miniatura(ruta: String, tr: TextureRect) -> void:
	# Cargar la miniatura en background (no bloquear el hilo principal).
	# En Godot 4, Image.load_from_file es síncrono pero rápido para thumbnails.
	var img := Image.new()
	var err := img.load(ruta)
	if err != OK:
		return
	img.resize(TAMANO_MINIATURA.x, TAMANO_MINIATURA.y, Image.INTERPOLATE_BILINEAR)
	tr.texture = ImageTexture.create_from_image(img)


func _on_miniatura_input(event: InputEvent, ruta: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_abrir_foto(ruta)


func _abrir_foto(ruta: String) -> void:
	# Abrir la foto a tamaño completo (placeholder: log).
	print("[GALLERY] abrir foto: %s" % ruta)


func _on_scroll_changed(_value: float) -> void:
	_actualizar_visibles()


func recargar() -> void:
	# Limpiar texturas y nodos, recargar la lista y recrear los nodos en orden.
	for ruta in _nodos_fotos.keys():
		var tr: TextureRect = _nodos_fotos[ruta]
		if tr != null and is_instance_valid(tr):
			tr.queue_free()
	_nodos_fotos.clear()
	_miniaturas_cargadas.clear()
	_cargar_lista_fotos()
	_crear_nodos_fotos()
	_actualizar_visibles()