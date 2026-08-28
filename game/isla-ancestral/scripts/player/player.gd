extends CharacterBody3D

## Módulo 06: Jugador — Movimiento estilo Animal Crossing
## Usa VoxelBoxMover para colisión voxel (Minecraft-like)
## + Edición de bloques con VoxelTool (raycast + break/place)
## + M13: ToolController para herramientas con stats y durabilidad

@export var move_speed: float = 5.0
@export var gravity: float = 20.0
@export var jump_force: float = 8.0
@export var edit_distance: float = 8.0  ## Alcance máximo para romper/colocar bloques

var _move_direction: Vector3 = Vector3.ZERO

## VoxelBoxMover — colisión rápida tipo Minecraft
var _box_mover: VoxelBoxMover = null
var _terrain: VoxelTerrain = null
## Bounding box del jugador (centro en pies, 0.8 ancho, 1.8 alto)
var _character_box: AABB = AABB(Vector3(-0.4, 0.0, -0.4), Vector3(0.8, 1.8, 0.8))
## True si VoxelBoxMover detectó suelo
var _on_ground: bool = false

## Edición de bloques
var _voxel_tool: VoxelTool = null
var _camera: Camera3D = null
var _esc_was_pressed: bool = false

## M13: Herramientas
var _tool_controller: ToolController = null
## Hotbar: slots de herramientas (índice 0 = tool activo)
var _hotbar: Array[ToolData] = []
var _hotbar_index: int = 0
## Bloque a colocar (ciclo por scroll o teclado)
var _block_to_place: int = 2  # Default: césped
## M13: cooldown del fallback de mano (sin herramienta utilizable)
var _mano_cooldown: float = 0.0
## M13: flanco del Q para el fallback de mano
var _q_prev_mano: bool = false
## Autoload Inventario (cache dinámico para evitar error de compilación MCP)
var _inventario: Node = null
var _item_database: Node = null

func _ready() -> void:
	add_to_group("player")
	_inventario = get_node_or_null("/root/Inventario")
	_item_database = get_node_or_null("/root/ItemDatabase")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Setup VoxelBoxMover
	_box_mover = VoxelBoxMover.new()
	_terrain = _find_terrain()
	if _terrain:
		print("[Player] VoxelBoxMover listo, terrain encontrado")
		_voxel_tool = _terrain.get_voxel_tool()
		_voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	else:
		print("[Player] WARNING: VoxelTerrain no encontrado")
	
	# Obtener referencia a la cámara
	_camera = get_viewport().get_camera_3d()
	
	# M13: Setup ToolController
	_tool_controller = ToolController.new()
	_tool_controller.name = "ToolController"
	add_child(_tool_controller)
	_tool_controller.configurar(_camera)
	_tool_controller.bloque_extraido.connect(_on_bloque_extraido)
	_tool_controller.bloque_colocado.connect(_on_bloque_colocado)
	_tool_controller.herramienta_equipada.connect(_on_herramienta_equipada)
	_tool_controller.durabilidad_cambiada.connect(_on_durabilidad_cambiada)

	# M13: Herramientas iniciales de prueba (M14/M16 darán la adquisición real)
	_crear_herramientas_iniciales.call_deferred()

	# M13/M57: Crear hotbar HUD de herramientas visible desde el inicio
	_create_hotbar_hud.call_deferred()

func _find_terrain() -> VoxelTerrain:
	var root = get_tree().current_scene
	if root:
		return root.get_node_or_null("VoxelTerrain")
	return null

func _unhandled_input(_event: InputEvent) -> void:
	# Teclas de UI/inventario (no requieren voxel_tool)
	if _event is InputEventKey and _event.pressed:
		match _event.keycode:
			KEY_B:
				_toggle_inventory()
			# M13: Teclas 1-6 para hotbar de herramientas
			KEY_1: _equip_hotbar_slot(0)
			KEY_2: _equip_hotbar_slot(1)
			KEY_3: _equip_hotbar_slot(2)
			KEY_4: _equip_hotbar_slot(3)
			KEY_5: _equip_hotbar_slot(4)
			KEY_6: _equip_hotbar_slot(5)
			# E5: F para toggle favorito en slot hover
			KEY_F:
				if _inventory_open and _hovered_slot >= 0:
					_on_toggle_favorite(_hovered_slot)

	# M13: E/Q los procesa ToolController (polling en _physics_process, evita handlers duplicados §9.29)
	# Scroll reservado a la cámara (lección 9.25: mouse solo para cámara)

## M13: Equipa un slot del hotbar
func _equip_hotbar_slot(index: int) -> void:
	if index < 0 or index >= _hotbar.size():
		return
	_hotbar_index = index
	var tool_data := _hotbar[index]
	if tool_data:
		_tool_controller.equipar(tool_data)
		print("[Player] Hotbar %d: %s" % [index + 1, tool_data.nombre])
	else:
		print("[Player] Hotbar %d: vacía" % [index + 1])

## M13: Cicla el hotbar con scroll
func _cycle_hotbar(direction: int) -> void:
	if _hotbar.is_empty():
		return
	_hotbar_index = (_hotbar_index + direction) % _hotbar.size()
	if _hotbar_index < 0:
		_hotbar_index += _hotbar.size()
	_equip_hotbar_slot(_hotbar_index)

## M13: Agrega una herramienta al hotbar (para testing)
func add_tool_to_hotbar(tool_data: ToolData) -> void:
	_hotbar.append(tool_data)
	if _hotbar.size() == 1:
		_equip_hotbar_slot(0)

## M13: Herramientas iniciales de cobre para probar el loop (M14/M16 darán adquisición real)
func _crear_herramientas_iniciales() -> void:
	add_tool_to_hotbar(ToolData.crear(ToolData.Tipo.PICO, ToolData.Nivel.COBRE))
	add_tool_to_hotbar(ToolData.crear(ToolData.Tipo.HACHA, ToolData.Nivel.COBRE))
	add_tool_to_hotbar(ToolData.crear(ToolData.Tipo.PALA, ToolData.Nivel.COBRE))
	add_tool_to_hotbar(ToolData.crear(ToolData.Tipo.AZADA, ToolData.Nivel.COBRE))
	add_tool_to_hotbar(ToolData.crear(ToolData.Tipo.MARTILLO, ToolData.Nivel.COBRE))
	print("[M13] Hotbar inicial: %d herramientas" % _hotbar.size())

## M13: Callback de equipado (refresca el HUD de herramientas)
func _on_herramienta_equipada(_tool: ToolData) -> void:
	_refresh_hotbar()

## M13: Callback de durabilidad (refresca el HUD de herramientas)
func _on_durabilidad_cambiada(_actual: int, _maximo: int) -> void:
	_refresh_hotbar()

func _break_block() -> void:
	# M13: fallback de mano — SOLO se llama sin herramienta utilizable
	# (con herramienta el flujo va por ToolController.intentar_golpe)
	var ray_result = _do_raycast()
	if ray_result == null:
		return
	var hit_pos: Vector3 = ray_result.position
	var normal: Vector3 = ray_result.normal
	var block_pos := (hit_pos - normal * 0.5).floor()
	_voxel_tool.mode = VoxelTool.MODE_REMOVE
	_voxel_tool.eraser_value = 0
	_voxel_tool.do_point(block_pos)
	print("[Player] Bloque roto (mano) en: ", block_pos)

func _place_block() -> void:
	# M13: fallback de mano — SOLO se llama sin herramienta con BUILD
	var result = _do_raycast()
	if result == null:
		return
	var hit_pos: Vector3 = result.position
	var normal: Vector3 = result.normal
	var place_pos := (hit_pos + normal * 0.5).floor()
	_voxel_tool.mode = VoxelTool.MODE_SET
	_voxel_tool.value = _block_to_place
	_voxel_tool.do_point(place_pos)
	print("[Player] Bloque colocado en: ", place_pos)

func _do_raycast():
	if not _camera:
		return null
	var viewport_size := get_viewport().get_visible_rect().size
	var center := viewport_size * 0.5
	var origin := _camera.project_ray_origin(center)
	var direction := _camera.project_ray_normal(center)
	return _voxel_tool.raycast(origin, direction, edit_distance)

## M13: Callbacks de señales del ToolController
func _on_bloque_extraido(_pos: Vector3i, block_id: int, drops: Array) -> void:
	# M14: Agregar drops al inventario
	for drop in drops:
		var item_id: String = str(drop.get("item_id", ""))
		var amount: int = int(drop.get("amount", 1))
		if item_id != "":
			var inv_node: Node = get_node_or_null("/root/Inventario")
			if inv_node and inv_node.has_method("add_item"):
				var sobrante: int = inv_node.add_item(item_id, amount)
				if sobrante > 0:
					print("[M14] Inventario lleno — %d x %s no caben" % [sobrante, item_id])
	print("[Player] Extraído bloque %d → inventario" % block_id)

func _on_bloque_colocado(_pos: Vector3i, block_id: int) -> void:
	print("[Player] Colocado bloque %d" % block_id)

func _physics_process(delta: float) -> void:
	# ESC toggle con debounce (solo detecta presión, no mantenida)
	var esc_pressed := Input.is_key_pressed(KEY_ESCAPE)
	if esc_pressed and not _esc_was_pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_esc_was_pressed = esc_pressed

	# M13: habilitación del controlador + fallback de mano (mutuamente excluyentes)
	if _tool_controller:
		_tool_controller.input_habilitado = not _inventory_open
		var herramienta_util: bool = _tool_controller.herramienta != null and not _tool_controller.herramienta.inutilizada()
		if not _inventory_open and not herramienta_util:
			_mano_cooldown = maxf(_mano_cooldown - delta, 0.0)
			var q_presionado: bool = Input.is_key_pressed(KEY_Q)
			if Input.is_key_pressed(KEY_E) and _mano_cooldown <= 0.0:
				_break_block()
				_mano_cooldown = 0.8
			if q_presionado and not _q_prev_mano:
				_place_block()
			_q_prev_mano = q_presionado
	
	# Gravedad (solo si no hay suelo)
	if not _on_ground:
		velocity.y -= gravity * delta
	
	_update_move_direction()
	
	# Movimiento horizontal
	velocity.x = _move_direction.x * move_speed
	velocity.z = _move_direction.z * move_speed
	
	if _box_mover and _terrain:
		var motion: Vector3 = velocity * delta
		motion = _box_mover.get_motion(global_position, motion, _character_box, _terrain)
		global_translate(motion)
		# Detectar suelo: si motion.y fue bloqueado (~0), estamos en el suelo
		_on_ground = abs(motion.y) < 0.001 and velocity.y <= 0.0
		if _on_ground:
			velocity.y = 0.0
	else:
		# Fallback: move_and_slide estándar
		move_and_slide()
		_on_ground = is_on_floor()
	
	_rotate_to_direction()

func _update_move_direction() -> void:
	_move_direction = Vector3.ZERO
	
	var input_dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_dir.y += 1.0
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1.0
	
	if input_dir.length() < 0.1:
		return
	
	input_dir = input_dir.normalized()
	
	# Movimiento relativo a la cámara
	if _camera and _camera.has_method("get_camera_forward_xz"):
		var cam_forward: Vector3 = _camera.get_camera_forward_xz()
		var cam_right: Vector3 = _camera.get_camera_right_xz()
		_move_direction = (cam_right * input_dir.x + cam_forward * -input_dir.y)
	else:
		_move_direction = Vector3(input_dir.x, 0.0, input_dir.y)

func _rotate_to_direction() -> void:
	if _move_direction.length() < 0.1:
		return
	var target_angle: float = atan2(_move_direction.x, _move_direction.z)
	rotation.y = target_angle

## ── M14: Inventario y Hotbar ──────────────────────────────

var _inventory_open: bool = false
var _inventory_panel: Control = null
var _hotbar_hud: Control = null
var _active_category: int = -1  # -1 = Todos
var _tooltip: Control = null
var _tooltip_timer: float = 0.0
var _tooltip_slot_idx: int = -1
var _context_menu: Control = null

## E3: Búsqueda por texto
var _search_text: String = ""
var _search_line: LineEdit = null

## E4: Sort con memoria
var _sort_mode: int = 0  # 0=favoritos+id, 1=nombre, 2=categoría, 3=rareza
const SORT_MODES := ["Favoritos+ID", "Nombre", "Categoría", "Rareza"]

## E5: Favoritos toggle
var _hovered_slot: int = -1

## E9: Feedback visual
var _feedback_tween: Tween = null

## E20: Drag-drop
var _dragging: bool = false
var _drag_slot_idx: int = -1
var _drag_preview: Control = null
var _drag_label: Label = null

const CATEGORY_NAMES := {
	-1: "Todos",
	0: "Mobiliario", 1: "Decoración", 2: "Iluminación",
	3: "Plantas", 4: "Alfombras", 5: "Cocina",
	6: "Trabajo", 7: "Exteriores", 8: "Naturaleza",
	9: "Construcción", 10: "Herramientas", 11: "Items",
	12: "Ropa", 13: "Arte", 14: "Evento", 15: "Secreto",
}

func _toggle_inventory() -> void:
	_inventory_open = not _inventory_open
	if _inventory_open:
		_open_inventory()
	else:
		_close_inventory()

func _open_inventory() -> void:
	if _inventory_panel == null:
		_create_inventory_panel()
	_inventory_panel.visible = true
	_active_category = -1
	_refresh_inventory_ui()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_inventory() -> void:
	if _inventory_panel != null:
		_inventory_panel.visible = false
	_hide_tooltip()
	_hide_context_menu()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _create_inventory_panel() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "InventoryCanvas"
	get_tree().current_scene.add_child(canvas)

	# Panel principal con fondo semi-transparente
	var bg := ColorRect.new()
	bg.name = "Backdrop"
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.add_child(bg)

	var panel := PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -320
	panel.offset_right = 320
	panel.offset_top = -240
	panel.offset_bottom = 240
	panel.z_index = 10
	bg.add_child(panel)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.name = "VBox"
	outer_vbox.add_theme_constant_override("separation", 6)
	panel.add_child(outer_vbox)

	# Header: título + capacidad
	var header := HBoxContainer.new()
	header.name = "Header"
	outer_vbox.add_child(header)

	var title := Label.new()
	title.name = "Title"
	title.text = "Inventario"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var info := Label.new()
	info.name = "CapacityLabel"
	info.text = "0/24"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(info)

	# Pestañas de categoría
	var tabs := HBoxContainer.new()
	tabs.name = "CategoryTabs"
	tabs.add_theme_constant_override("separation", 2)
	outer_vbox.add_child(tabs)

	# Botón "Todos"
	var btn_all := Button.new()
	btn_all.text = "Todos"
	btn_all.custom_minimum_size = Vector2(50, 24)
	btn_all.pressed.connect(_on_category_pressed.bind(-1))
	tabs.add_child(btn_all)

	# Pestañas por categoría (las 9 más relevantes)
	for cat_id in [9, 10, 14, 11, 8, 5, 6, 12, 13]:
		var btn := Button.new()
		btn.text = CATEGORY_NAMES.get(cat_id, "?")
		btn.custom_minimum_size = Vector2(50, 24)
		btn.pressed.connect(_on_category_pressed.bind(cat_id))
		tabs.add_child(btn)

	# E3: Barra de búsqueda
	var search_row := HBoxContainer.new()
	search_row.name = "SearchRow"
	search_row.add_theme_constant_override("separation", 4)
	outer_vbox.add_child(search_row)

	var search_line := LineEdit.new()
	search_line.name = "SearchLine"
	search_line.placeholder_text = "Buscar ítem..."
	search_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_line.text_changed.connect(_on_search_changed)
	search_row.add_child(search_line)
	_search_line = search_line

	var clear_btn := Button.new()
	clear_btn.text = "X"
	clear_btn.custom_minimum_size = Vector2(24, 24)
	clear_btn.pressed.connect(func() -> void:
		if _search_line:
			_search_line.text = ""
			_on_search_changed("")
	)
	search_row.add_child(clear_btn)

	# E4: Botón de sort
	var sort_btn_row := HBoxContainer.new()
	sort_btn_row.name = "SortRow"
	sort_btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	sort_btn_row.add_theme_constant_override("separation", 4)
	outer_vbox.add_child(sort_btn_row)

	var sort_label := Label.new()
	sort_label.text = "Ordenar:"
	sort_btn_row.add_child(sort_label)
	var sort_option := OptionButton.new()
	sort_option.name = "SortOption"
	for mode_name in SORT_MODES:
		sort_option.add_item(mode_name)
	sort_option.selected = _sort_mode
	sort_option.item_selected.connect(_on_sort_mode_changed)
	sort_btn_row.add_child(sort_option)

	var sort_btn := Button.new()
	sort_btn.text = "Aplicar"
	sort_btn.pressed.connect(_on_sort_pressed)
	sort_btn_row.add_child(sort_btn)

	# Grid de slots
	var grid := GridContainer.new()
	grid.name = "SlotGrid"
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	outer_vbox.add_child(grid)

	for i in 24:
		var slot_panel := PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(56, 56)
		slot_panel.name = "Slot_%d" % i
		# Habilitar mouse para tooltip, drag y click
		slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		slot_panel.gui_input.connect(_on_slot_input.bind(i))
		slot_panel.mouse_entered.connect(_on_slot_hover.bind(i))
		slot_panel.mouse_exited.connect(_on_slot_exit)
		var slot_vbox := VBoxContainer.new()
		slot_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		slot_panel.add_child(slot_vbox)
		var slot_label := Label.new()
		slot_label.name = "Label"
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.add_theme_font_size_override("font_size", 9)
		slot_vbox.add_child(slot_label)
		var qty_label := Label.new()
		qty_label.name = "Qty"
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty_label.add_theme_font_size_override("font_size", 8)
		slot_vbox.add_child(qty_label)
		# E5: Indicador de favorito
		var fav_label := Label.new()
		fav_label.name = "Fav"
		fav_label.text = "★"
		fav_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fav_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		fav_label.add_theme_font_size_override("font_size", 8)
		fav_label.visible = false
		slot_panel.add_child(fav_label)
		grid.add_child(slot_panel)

	# Botones de acción
	var action_bar := HBoxContainer.new()
	action_bar.name = "ActionBar"
	action_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	action_bar.add_theme_constant_override("separation", 8)
	outer_vbox.add_child(action_bar)

	var close_btn := Button.new()
	close_btn.text = "Cerrar (B)"
	close_btn.pressed.connect(_toggle_inventory)
	action_bar.add_child(close_btn)

	canvas.add_child(panel)
	_inventory_panel = panel

	# Tooltip (oculto al inicio)
	_create_tooltip(bg)
	# Context menu (oculto al inicio)
	_create_context_menu(bg)
	# E20: Drag preview (oculto al inicio)
	_create_drag_preview(bg)

	_inventario.inventario_actualizado.connect(_refresh_inventory_ui)
	_refresh_inventory_ui()

func _on_category_pressed(cat_id: int) -> void:
	_active_category = cat_id
	_refresh_inventory_ui()

func _refresh_inventory_ui() -> void:
	if _inventory_panel == null or not _inventory_panel.visible:
		return
	var grid := _inventory_panel.get_node_or_null("VBox/SlotGrid")
	if grid == null:
		return
	var bolsillo = _inventario._contenedor(0)
	# E3+E4: Filtrar slots por categoría + búsqueda
	var visible_slots: Array[int] = []
	for i in bolsillo.slots.size():
		var s: InventorySlot = bolsillo.slots[i]
		if s.esta_libre():
			visible_slots.append(i)
			continue
		# Filtro por categoría
		if _active_category != -1:
			var item = _item_database.get_item(s.item_id)
			if item != null and int(item.categoria) != _active_category:
				continue
		# E3: Filtro por texto de búsqueda
		if _search_text != "":
			var item = _item_database.get_item(s.item_id)
			var search_lower := _search_text.to_lower()
			var match_name: bool = (item != null and item.nombre.to_lower().contains(search_lower))
			var match_id: bool = s.item_id.to_lower().contains(search_lower)
			var match_desc: bool = (item != null and item.descripcion.to_lower().contains(search_lower))
			if not match_name and not match_id and not match_desc:
				continue
		visible_slots.append(i)

	for i in 24:
		var slot_node := grid.get_node_or_null("Slot_%d" % i)
		if slot_node == null:
			continue
		var label := slot_node.get_node_or_null("VBox/Label")
		var qty := slot_node.get_node_or_null("VBox/Qty")
		var fav := slot_node.get_node_or_null("Fav")
		if label == null or qty == null:
			continue
		if i < bolsillo.slots.size() and visible_slots.has(i):
			var s: InventorySlot = bolsillo.slots[i]
			if not s.esta_libre():
				var item = _item_database.get_item(s.item_id)
				var display_name := s.item_id
				if item != null:
					display_name = item.nombre
				label.text = display_name.left(8)
				qty.text = "x%d" % s.cantidad
				slot_node.visible = true
				# E5: Mostrar indicador de favorito
				if fav:
					fav.visible = s.favorito
			else:
				label.text = ""
				qty.text = ""
				slot_node.visible = true
				if fav:
					fav.visible = false
		else:
			slot_node.visible = false

	var info_label := _inventory_panel.get_node_or_null("VBox/Header/CapacityLabel")
	if info_label:
		info_label.text = "%d/%d" % [_inventario.used_slots(0), _inventario.total_slots(0)]

## ── Tooltip (lazy con delay) ──────────────────────────────

func _create_tooltip(parent: Control) -> void:
	var tt := PanelContainer.new()
	tt.name = "Tooltip"
	tt.visible = false
	tt.z_index = 20
	var tt_vbox := VBoxContainer.new()
	tt_vbox.name = "VBox"
	tt.add_child(tt_vbox)
	var tt_name := Label.new()
	tt_name.name = "Name"
	tt_name.add_theme_font_size_override("font_size", 12)
	tt_vbox.add_child(tt_name)
	var tt_desc := Label.new()
	tt_desc.name = "Desc"
	tt_desc.add_theme_font_size_override("font_size", 10)
	tt_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tt_desc.custom_minimum_size = Vector2(180, 0)
	tt_vbox.add_child(tt_desc)
	var tt_info := Label.new()
	tt_info.name = "Info"
	tt_info.add_theme_font_size_override("font_size", 9)
	tt_vbox.add_child(tt_info)
	parent.add_child(tt)
	_tooltip = tt

func _on_slot_hover(slot_idx: int) -> void:
	_tooltip_slot_idx = slot_idx
	_hovered_slot = slot_idx
	_tooltip_timer = 0.0

func _on_slot_exit() -> void:
	_tooltip_slot_idx = -1
	_hovered_slot = -1
	_hide_tooltip()
	if _dragging:
		_cancel_drag()

func _hide_tooltip() -> void:
	if _tooltip != null:
		_tooltip.visible = false

func _process(delta: float) -> void:
	# Tooltip delay
	if _tooltip_slot_idx >= 0 and _inventory_open:
		_tooltip_timer += delta
		if _tooltip_timer >= 0.5:
			_show_tooltip_at(_tooltip_slot_idx)
	# E20: Mover preview de drag con el mouse
	if _dragging and _drag_preview != null:
		_drag_preview.global_position = get_viewport().get_mouse_position() + Vector2(16, 16)
	# Cierre con ESC
	if _inventory_open and Input.is_action_just_pressed("ui_cancel"):
		if _dragging:
			_cancel_drag()
		else:
			_toggle_inventory()
	# M13: parpadeo de la herramienta activa cuando pide reparación (<20%, aviso no castigo)
	_blink_tiempo += delta
	if _tool_controller and _tool_controller.herramienta and _hotbar_hud:
		var slot_activo = _hotbar_hud.get_node_or_null("Slot_%d" % _hotbar_index)
		if _tool_controller.herramienta.necesita_reparacion() and slot_activo:
			var pulso: float = 0.5 + 0.5 * sin(_blink_tiempo * 8.0)
			slot_activo.modulate = Color(1.0, 0.35 + 0.35 * pulso, 0.35 + 0.35 * pulso)

func _show_tooltip_at(slot_idx: int) -> void:
	if _tooltip == null or _inventory_panel == null:
		return
	var bolsillo = _inventario._contenedor(0)
	if slot_idx >= bolsillo.slots.size():
		return
	var s: InventorySlot = bolsillo.slots[slot_idx]
	if s.esta_libre():
		_hide_tooltip()
		return
	var name_label := _tooltip.get_node_or_null("VBox/Name")
	var desc_label := _tooltip.get_node_or_null("VBox/Desc")
	var info_label := _tooltip.get_node_or_null("VBox/Info")
	var item = _item_database.get_item(s.item_id)
	if name_label:
		name_label.text = item.nombre if item else s.item_id
	if desc_label:
		desc_label.text = item.descripcion if item else ""
	if info_label:
		var rarezas := ["Común", "Poco común", "Raro", "Legendario"]
		var rareza_str: String = rarezas[item.rareza] if item else "?"
		var precio: int = item.precio_venta if item else 0
		var fav_str: String = " | ★ Favorito" if s.favorito else ""
		info_label.text = "%s | $%d | x%d%s" % [rareza_str, precio, s.cantidad, fav_str]
	# Posicionar tooltip cerca del slot
	var slot_node := _inventory_panel.get_node_or_null("VBox/SlotGrid/Slot_%d" % slot_idx)
	if slot_node:
		var slot_rect: Rect2 = slot_node.get_global_rect()
		_tooltip.global_position = Vector2(slot_rect.end.x + 8, slot_rect.position.y)
		_tooltip.visible = true

## ── Context menu (click derecho) ──────────────────────────

func _create_context_menu(parent: Control) -> void:
	var cm := PanelContainer.new()
	cm.name = "ContextMenu"
	cm.visible = false
	cm.z_index = 25
	var cm_vbox := VBoxContainer.new()
	cm_vbox.name = "VBox"
	cm.add_child(cm_vbox)
	parent.add_child(cm)
	_context_menu = cm

func _hide_context_menu() -> void:
	if _context_menu != null:
		_context_menu.visible = false

func _on_slot_input(event: InputEvent, slot_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_context_menu(slot_idx, event.global_position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_hide_context_menu()
			if _dragging:
				# E20: Soltar drag en este slot
				_finish_drag(slot_idx)
			else:
				# E20: Iniciar drag si el slot tiene item
				_try_start_drag(slot_idx)

func _show_context_menu(slot_idx: int, pos: Vector2) -> void:
	if _context_menu == null:
		return
	var bolsillo = _inventario._contenedor(0)
	if slot_idx >= bolsillo.slots.size():
		return
	var s: InventorySlot = bolsillo.slots[slot_idx]
	if s.esta_libre():
		_hide_context_menu()
		return

	# Limpiar opciones anteriores
	var cm_vbox := _context_menu.get_node_or_null("VBox")
	for child in cm_vbox.get_children():
		child.queue_free()

	var item = _item_database.get_item(s.item_id)

	# Opción: Usar
	var use_btn := Button.new()
	use_btn.text = "Usar"
	use_btn.custom_minimum_size = Vector2(100, 24)
	use_btn.pressed.connect(_on_use_item.bind(slot_idx))
	cm_vbox.add_child(use_btn)

	# Opción: Favorito
	var fav_btn := Button.new()
	fav_btn.text = "Desfavorecer" if s.favorito else "Favorito"
	fav_btn.custom_minimum_size = Vector2(100, 24)
	fav_btn.pressed.connect(_on_toggle_favorite.bind(slot_idx))
	cm_vbox.add_child(fav_btn)

	# Opción: Descartar
	if item == null or not item.protected_from_discard:
		var discard_btn := Button.new()
		discard_btn.text = "Descartar"
		discard_btn.custom_minimum_size = Vector2(100, 24)
		discard_btn.pressed.connect(_on_discard_item.bind(slot_idx))
		cm_vbox.add_child(discard_btn)

	_context_menu.global_position = pos
	_context_menu.visible = true

func _on_use_item(slot_idx: int) -> void:
	_hide_context_menu()
	# Por ahora solo imprime — M15/M16 definirán acciones reales
	var bolsillo = _inventario._contenedor(0)
	if slot_idx < bolsillo.slots.size():
		var s: InventorySlot = bolsillo.slots[slot_idx]
		if not s.esta_libre():
			print("[M14] Usar: %s" % s.item_id)

func _on_toggle_favorite(slot_idx: int) -> void:
	_hide_context_menu()
	var bolsillo = _inventario._contenedor(0)
	if slot_idx < bolsillo.slots.size():
		bolsillo.slots[slot_idx].favorito = not bolsillo.slots[slot_idx].favorito
		_refresh_inventory_ui()

func _on_discard_item(slot_idx: int) -> void:
	_hide_context_menu()
	var bolsillo = _inventario._contenedor(0)
	if slot_idx < bolsillo.slots.size():
		var s: InventorySlot = bolsillo.slots[slot_idx]
		if not s.esta_libre():
			print("[M14] Descartado: %s x%d" % [s.item_id, s.cantidad])
			s.vaciar()
			_refresh_inventory_ui()
			_inventario.slot_changed.emit(0, slot_idx)
			_inventario.inventario_actualizado.emit()

## ── M13/M57: Hotbar HUD de herramientas ───────────────────

var _hotbar_equipped_label: Label = null
var _blink_tiempo: float = 0.0

func _create_hotbar_hud() -> void:
	var ui := get_tree().current_scene.get_node_or_null("UI")
	var canvas := ui as CanvasLayer
	if canvas == null:
		canvas = CanvasLayer.new()
		canvas.name = "HotbarCanvas"
		canvas.layer = 10
		get_tree().current_scene.add_child(canvas)

	# Etiqueta de herramienta equipada (nombre + durabilidad)
	var equipped_panel := PanelContainer.new()
	equipped_panel.name = "EquippedPanel"
	var eq_sb := StyleBoxFlat.new()
	eq_sb.bg_color = Color(0.08, 0.08, 0.12, 0.75)
	eq_sb.set_corner_radius_all(6)
	eq_sb.content_margin_left = 10.0
	eq_sb.content_margin_right = 10.0
	eq_sb.content_margin_top = 2.0
	eq_sb.content_margin_bottom = 2.0
	equipped_panel.add_theme_stylebox_override("panel", eq_sb)
	equipped_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	equipped_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	equipped_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	equipped_panel.offset_bottom = -66
	equipped_panel.offset_top = -92
	var equipped := Label.new()
	equipped.name = "EquippedLabel"
	equipped.text = ""
	equipped.add_theme_font_size_override("font_size", 13)
	equipped.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipped_panel.add_child(equipped)
	canvas.add_child(equipped_panel)
	_hotbar_equipped_label = equipped

	var container := HBoxContainer.new()
	container.name = "Hotbar"
	container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	container.offset_top = -60
	container.offset_left = -160
	container.offset_right = 160
	container.offset_bottom = -10
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 4)
	canvas.add_child(container)

	for i in 6:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(48, 48)
		slot.name = "Slot_%d" % i
		var slot_sb := StyleBoxFlat.new()
		slot_sb.bg_color = Color(0.08, 0.08, 0.12, 0.7)
		slot_sb.set_corner_radius_all(6)
		slot_sb.border_color = Color(1, 1, 1, 0.25)
		slot_sb.set_border_width_all(1)
		slot.add_theme_stylebox_override("panel", slot_sb)
		var lbl := Label.new()
		lbl.name = "Label"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 9)
		slot.add_child(lbl)
		container.add_child(slot)

	_hotbar_hud = container
	_refresh_hotbar()
	_verificar_rect_hotbar.call_deferred()

func _verificar_rect_hotbar() -> void:
	if _hotbar_hud == null:
		return
	await get_tree().process_frame
	print("[M13] Hotbar HUD listo: ", _hotbar_hud.get_global_rect(), " padre=", _hotbar_hud.get_parent().name)

func _refresh_hotbar() -> void:
	if _hotbar_hud == null:
		return
	for i in 6:
		var slot_node := _hotbar_hud.get_node_or_null("Slot_%d" % i)
		if slot_node == null:
			continue
		var label := slot_node.get_node_or_null("Label")
		if label == null:
			continue
		if i < _hotbar.size():
			var tool: ToolData = _hotbar[i]
			var activo: bool = i == _hotbar_index
			var dur_texto: String = "INF" if tool.durabilidad_infinita() else "%d/%d" % [tool.durabilidad_actual, tool.durabilidad_max]
			label.text = "%s%s\n%s" % ["> " if activo else "", tool.nombre.left(7), dur_texto]
			if activo:
				slot_node.modulate = Color(1, 1, 0.55)
			elif tool.necesita_reparacion():
				slot_node.modulate = Color(1, 0.45, 0.45)
			else:
				slot_node.modulate = Color(1, 1, 1)
		else:
			label.text = ""
			slot_node.modulate = Color(1, 1, 1, 0.4)
	if _hotbar_equipped_label:
		var tool: ToolData = _tool_controller.herramienta if _tool_controller else null
		if tool:
			var dur_texto: String = "INF" if tool.durabilidad_infinita() else "%d/%d" % [tool.durabilidad_actual, tool.durabilidad_max]
			var aviso: String = "  ⚠ REPARAR" if tool.necesita_reparacion() else ""
			_hotbar_equipped_label.text = "%s  [%s]%s" % [tool.nombre, dur_texto, aviso]
		else:
			_hotbar_equipped_label.text = "Sin herramienta"

## ── E3: Búsqueda por texto ──────────────────────────────

func _on_search_changed(new_text: String) -> void:
	_search_text = new_text
	_refresh_inventory_ui()

## ── E4: Sort con memoria ────────────────────────────────

func _on_sort_mode_changed(index: int) -> void:
	_sort_mode = index

func _on_sort_pressed() -> void:
	_inventario.sort_container(0, _sort_mode)

## ── E20: Drag-drop entre slots ──────────────────────────

func _create_drag_preview(parent: Control) -> void:
	var preview := PanelContainer.new()
	preview.name = "DragPreview"
	preview.visible = false
	preview.z_index = 30
	preview.custom_minimum_size = Vector2(48, 48)
	var lbl := Label.new()
	lbl.name = "Label"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 9)
	preview.add_child(lbl)
	parent.add_child(preview)
	_drag_preview = preview
	_drag_label = lbl

func _try_start_drag(slot_idx: int) -> void:
	var bolsillo = _inventario._contenedor(0)
	if slot_idx >= bolsillo.slots.size():
		return
	var s: InventorySlot = bolsillo.slots[slot_idx]
	if s.esta_libre():
		return
	# Iniciar drag
	_dragging = true
	_drag_slot_idx = slot_idx
	if _drag_label:
		var item = _item_database.get_item(s.item_id)
		var display_name := s.item_id
		if item != null:
			display_name = item.nombre
		_drag_label.text = "%s\nx%d" % [display_name.left(6), s.cantidad]
	if _drag_preview:
		_drag_preview.visible = true
		_drag_preview.global_position = get_viewport().get_mouse_position() + Vector2(16, 16)
	_hide_tooltip()

func _cancel_drag() -> void:
	_dragging = false
	_drag_slot_idx = -1
	if _drag_preview:
		_drag_preview.visible = false

func _finish_drag(target_slot: int) -> void:
	if _drag_slot_idx < 0 or _drag_slot_idx == target_slot:
		_cancel_drag()
		return
	var bolsillo = _inventario._contenedor(0)
	if target_slot >= bolsillo.slots.size():
		_cancel_drag()
		return
	# Intentar swap
	var ok = _inventario.swap_items(0, _drag_slot_idx, 0, target_slot)
	if ok:
		_play_add_feedback(null)
	_cancel_drag()
	_refresh_inventory_ui()

## ── E9: Feedback visual ─────────────────────────────────

func _play_add_feedback(slot_node: Control) -> void:
	if slot_node == null:
		return
	if _feedback_tween and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(slot_node, "scale", Vector2(1.2, 1.2), 0.05)
	_feedback_tween.tween_property(slot_node, "scale", Vector2(1.0, 1.0), 0.1)
