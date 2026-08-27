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

func _ready() -> void:
	add_to_group("player")
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
	_tool_controller.bloque_extraido.connect(_on_bloque_extraido)
	_tool_controller.bloque_colocado.connect(_on_bloque_colocado)

func _find_terrain() -> VoxelTerrain:
	var root = get_tree().current_scene
	if root:
		return root.get_node_or_null("VoxelTerrain")
	return null

func _unhandled_input(event: InputEvent) -> void:
	if not _voxel_tool or not _camera:
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_E:
				_break_block()
			KEY_Q:
				_place_block()
			KEY_B:
				_toggle_inventory()
			# M13: Teclas 1-9 para hotbar
			KEY_1: _equip_hotbar_slot(0)
			KEY_2: _equip_hotbar_slot(1)
			KEY_3: _equip_hotbar_slot(2)
			KEY_4: _equip_hotbar_slot(3)
			KEY_5: _equip_hotbar_slot(4)
			KEY_6: _equip_hotbar_slot(5)
	
	# M13: Scroll para cambiar hotbar
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cycle_hotbar(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cycle_hotbar(1)

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

func _break_block() -> void:
	# M13: Si hay herramienta equipada, usar ToolController
	if _tool_controller.herramienta != null:
		var result := _tool_controller.try_extract()
		if result.get("ok", false):
			return
		# Si la herramienta no aplica, fallback a romper con mano
	
	# Fallback: romper sin herramienta (mano, sin drops)
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
	# M13: Si hay herramienta equipada con BUILD, usar ToolController
	if _tool_controller.herramienta != null and _tool_controller.herramienta.permite(ToolData.Accion.BUILD):
		var ok := _tool_controller.try_place(_block_to_place)
		if ok:
			return
	
	# Fallback: colocar sin herramienta
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
			var sobrante := Inventario.add_item(item_id, amount)
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
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_inventory() -> void:
	if _inventory_panel != null:
		_inventory_panel.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _create_inventory_panel() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "InventoryCanvas"
	get_tree().current_scene.add_child(canvas)

	var panel := PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -300
	panel.offset_right = 300
	panel.offset_top = -200
	panel.offset_bottom = 200

	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "Inventario"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var info := Label.new()
	info.name = "CapacityLabel"
	info.text = "Bolsillo: 0/24"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(info)

	var grid := GridContainer.new()
	grid.name = "SlotGrid"
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	vbox.add_child(grid)

	for i in 24:
		var slot_panel := PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(48, 48)
		slot_panel.name = "Slot_%d" % i
		var slot_label := Label.new()
		slot_label.name = "Label"
		slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot_label.add_theme_font_size_override("font_size", 10)
		slot_panel.add_child(slot_label)
		grid.add_child(slot_panel)

	var close_btn := Button.new()
	close_btn.text = "Cerrar (B)"
	close_btn.pressed.connect(_toggle_inventory)
	vbox.add_child(close_btn)

	canvas.add_child(panel)
	_inventory_panel = panel
	Inventario.inventario_actualizado.connect(_refresh_inventory_ui)
	_refresh_inventory_ui()

func _refresh_inventory_ui() -> void:
	if _inventory_panel == null or not _inventory_panel.visible:
		return
	var grid := _inventory_panel.get_node_or_null("VBox/SlotGrid")
	if grid == null:
		return
	var bolsillo := Inventario._contenedor(0)
	for i in mini(24, bolsillo.total_slots()):
		var slot_node := grid.get_node_or_null("Slot_%d" % i)
		if slot_node == null:
			continue
		var label := slot_node.get_node_or_null("Label")
		if label == null:
			continue
		if i < bolsillo.slots.size():
			var s: InventorySlot = bolsillo.slots[i]
			if not s.esta_libre():
				label.text = "%s\n%d" % [s.item_id.left(6), s.cantidad]
			else:
				label.text = ""
	var info_label := _inventory_panel.get_node_or_null("VBox/CapacityLabel")
	if info_label:
		info_label.text = "Bolsillo: %d/%d" % [Inventario.used_slots(0), Inventario.total_slots(0)]

## ── M14: Hotbar HUD ───────────────────────────────────────

func _create_hotbar_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HotbarCanvas"
	canvas.layer = 10
	get_tree().current_scene.add_child(canvas)

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
		var lbl := Label.new()
		lbl.name = "Label"
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		slot.add_child(lbl)
		container.add_child(slot)

	_hotbar_hud = container
	_refresh_hotbar()
	Inventario.inventario_actualizado.connect(_refresh_hotbar)

func _refresh_hotbar() -> void:
	if _hotbar_hud == null:
		return
	var bolsillo := Inventario._contenedor(0)
	for i in 6:
		var slot_node := _hotbar_hud.get_node_or_null("Slot_%d" % i)
		if slot_node == null:
			continue
		var label := slot_node.get_node_or_null("Label")
		if label == null:
			continue
		if i < bolsillo.slots.size():
			var s: InventorySlot = bolsillo.slots[i]
			if not s.esta_libre():
				label.text = "%s\n%d" % [s.item_id.left(6), s.cantidad]
			else:
				label.text = ""
