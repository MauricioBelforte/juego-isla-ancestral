# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-28
#
# M13: Herramientas — ToolController (Fase 3: mundo voxel real)
# Apuntado por cámara (raycast VoxelTool.raycast, patrón probado en follow_camera.gd),
# extracción progresiva multi-golpe (2-6 según bloque), highlight "late" solo en
# objetivos válidos, cooldown por velocidad de herramienta, área 3x3 desde T3.
# Contrato try_extract/try_place (M08) preservado.

## Controlador de herramienta equipada: raycast, extracción y colocación.
class_name ToolController
extends Node3D

## Herramienta actualmente equipada
var herramienta: ToolData = null

## Alcance del rayo más allá del jugador (RF7: 4 m)
const ALCANCE: float = 4.0

## Bloques por ID (BlockType, M08)
const B_AIR: int = 0
const B_DIRT: int = 1
const B_GRASS: int = 2
const B_STONE: int = 3
const B_BEDROCK: int = 4
const B_SAND: int = 5
const B_CLAY: int = 6
const B_WOOD: int = 7
const B_PLANKS: int = 8
const B_COPPER: int = 9
const B_IRON: int = 10
const B_CRYSTAL: int = 11
const B_GEMSTONE: int = 12
const B_GLASS: int = 13
const B_ICE: int = 16
const B_WATER: int = 17
const B_SNOW: int = 26
const B_GRAVEL: int = 27
const B_MOSS: int = 28
const B_MUD: int = 29

## Señales para feedback (snake_case, 07-GUIA-GODOT §1.1)
signal objetivo_actualizado(pos: Vector3i, block_id: int, valido: bool, progreso: float)
signal golpe_conectado(pos: Vector3i, block_id: int, material: String, progreso: float)
signal golpe_fallido(pos: Vector3i, razon: String)
signal bloque_extraido(pos: Vector3i, block_id: int, drops: Array)
signal bloque_colocado(pos: Vector3i, block_id: int)
signal herramienta_equipada(tool: ToolData)
signal durabilidad_cambiada(actual: int, maximo: int)
signal herramienta_agotada(tool_name: String)

## Referencia a la cámara (para el rayo de apuntado)
var _camera: Camera3D = null

## Referencia al terreno voxel
var _terrain: VoxelTerrain = null

## Highlight del bloque apuntado (solo objetivos válidos)
var _highlight: MeshInstance3D = null
var _highlight_mat: StandardMaterial3D = null

## Daño acumulado por posición (clave "x,y,z" → golpes dados)
var _danio: Dictionary = {}

## Cooldown restante para el próximo golpe
var _cooldown: float = 0.0

## Flanco del Q (colocar con una pulsación)
var _q_prev: bool = false

## Habilitación de input (el jugador la apaga con el inventario abierto)
var input_habilitado: bool = true

## Golpes requeridos por bloque (tiempos base 03-Diseno §6: 0.6 s tierra → 1.5 s mineral)
const GOLPES := {
	B_DIRT: 2, B_GRASS: 2, B_SAND: 2, B_CLAY: 2, B_MUD: 2, B_GRAVEL: 2, B_SNOW: 2,
	B_WOOD: 3,
	B_STONE: 4,
	B_COPPER: 5, B_IRON: 5,
	B_CRYSTAL: 6, B_GEMSTONE: 6,
	B_PLANKS: 1, B_GLASS: 1, B_ICE: 1, B_MOSS: 1,
}

const GOLPES_DEFECTO: int = 1

func _ready() -> void:
	_crear_highlight()
	var feedback := ToolFeedback.new()
	feedback.name = "ToolFeedback"
	add_child(feedback)
	golpe_conectado.connect(feedback._on_golpe_conectado)
	bloque_extraido.connect(feedback._on_bloque_extraido)
	bloque_colocado.connect(feedback._on_bloque_colocado)
	golpe_fallido.connect(feedback._on_golpe_fallido)

## Configura la cámara de apuntado (llamado por el jugador).
func configurar(camara: Camera3D) -> void:
	_camera = camara

func _physics_process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = maxf(_cooldown - delta, 0.0)
	if _camera == null:
		_camera = get_viewport().get_camera_3d()
	_actualizar_objetivo()
	var hay_util: bool = herramienta != null and not herramienta.inutilizada()
	if input_habilitado and hay_util:
		var e_presionado: bool = Input.is_key_pressed(KEY_E)
		var q_presionado: bool = Input.is_key_pressed(KEY_Q)
		if e_presionado and _cooldown <= 0.0:
			intentar_golpe()
		if q_presionado and not _q_prev:
			try_place(2)
		_q_prev = q_presionado

## Crea el mesh de highlight (caja wireframe-ish translúcida).
func _crear_highlight() -> void:
	_highlight = MeshInstance3D.new()
	_highlight.name = "Highlight"
	var box := BoxMesh.new()
	box.size = Vector3(1.04, 1.04, 1.04)
	_highlight.mesh = box
	_highlight_mat = StandardMaterial3D.new()
	_highlight_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_highlight_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_highlight_mat.albedo_color = Color(1, 1, 1, 0.35)
	_highlight.material_override = _highlight_mat
	_highlight.top_level = true
	_highlight.visible = false
	add_child(_highlight)

## VoxelTool fresco con canal TYPE configurado (get_voxel_tool retorna instancia nueva).
## Nota: la lectura de bloques es vt.get_voxel(pos) — VoxelTerrain NO expone get_voxel.
func _get_vt() -> VoxelTool:
	_terrain = _find_terrain()
	if _terrain == null:
		return null
	var vt := _terrain.get_voxel_tool()
	if vt == null:
		return null
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	return vt

## Raycast desde la cámara a través del centro de pantalla.
## max_dist = distancia cámara→jugador + ALCANCE (4 m alrededor del jugador).
func _raycast_camara():
	if _camera == null:
		return null
	var vt = _get_vt()
	if vt == null:
		return null
	var origin: Vector3 = _camera.global_position
	var direction: Vector3 = -_camera.global_transform.basis.z.normalized()
	var max_dist: float = origin.distance_to(global_position + Vector3(0, 1, 0)) + ALCANCE
	var result = vt.raycast(origin, direction, max_dist)
	return result

## Convierte el resultado del raycast a posiciones voxel.
func _voxel_de_hit(hit) -> Dictionary:
	if hit == null:
		return {}
	var normal_v: Vector3 = Vector3(hit.normal) * 0.5
	var hit_pos: Vector3 = Vector3(hit.position)
	var centro: Vector3 = hit_pos - normal_v
	var frente: Vector3 = hit_pos + normal_v
	return {
		"pos": Vector3i(centro.floor()),
		"place_pos": Vector3i(frente.floor()),
		"normal": hit.normal,
	}

## Actualiza el objetivo actual y el highlight (cada frame de física).
func _actualizar_objetivo() -> void:
	var hit = _raycast_camara()
	var info := _voxel_de_hit(hit)
	if info.is_empty():
		_highlight.visible = false
		objetivo_actualizado.emit(Vector3i(-999, -999, -999), -1, false, 0.0)
		return
	var pos: Vector3i = info["pos"]
	var vt = _get_vt()
	if vt == null:
		return
	var block_id: int = int(vt.get_voxel(pos))
	var valido: bool = _objetivo_valido(block_id)
	if not valido:
		_highlight.visible = false
		objetivo_actualizado.emit(pos, block_id, false, 0.0)
		return
	var progreso: float = _progreso_de(pos, block_id)
	_highlight.visible = true
	_highlight.global_position = Vector3(pos) + Vector3(0.5, 0.5, 0.5)
	if progreso >= 0.6:
		_highlight_mat.albedo_color = Color(1, 0.85, 0.2, 0.45)
	else:
		_highlight_mat.albedo_color = Color(1, 1, 1, 0.3)
	objetivo_actualizado.emit(pos, block_id, true, progreso)

## ¿El bloque apuntado es un objetivo válido para la herramienta equipada?
func _objetivo_valido(block_id: int) -> bool:
	if herramienta == null or herramienta.inutilizada():
		return false
	if block_id == B_AIR or block_id == B_WATER:
		return false
	if block_id == B_BEDROCK:
		return false
	return _herramienta_aplica(block_id)

## ¿La herramienta equipada aplica a este bloque? (mapea ToolData.Tipo → categoría M08)
func _herramienta_aplica(block_id: int) -> bool:
	if not herramienta.permite(ToolData.Accion.EXTRACT):
		return false
	match herramienta.tipo:
		ToolData.Tipo.PICO:
			return block_id in [B_STONE, B_COPPER, B_IRON, B_CRYSTAL, B_GEMSTONE]
		ToolData.Tipo.PALA:
			return block_id in [B_DIRT, B_GRASS, B_SAND, B_CLAY, B_MUD, B_GRAVEL, B_SNOW]
		ToolData.Tipo.HACHA:
			return block_id == B_WOOD
		ToolData.Tipo.AZADA:
			return block_id in [B_GRASS, B_DIRT]
		_:
			return block_id in [B_PLANKS, B_GLASS, B_ICE, B_MOSS]

## Categoría de material para feedback (sonido/partículas).
func _material_de_bloque(block_id: int) -> String:
	if block_id in [B_DIRT, B_GRASS, B_SAND, B_CLAY, B_MUD, B_GRAVEL, B_SNOW, B_MOSS]:
		return "tierra"
	if block_id in [B_STONE, B_COPPER, B_IRON, B_CRYSTAL, B_GEMSTONE]:
		return "piedra"
	if block_id in [B_WOOD, B_PLANKS]:
		return "madera"
	return "generico"

## Golpes requeridos para extraer un bloque.
func _golpes_de(block_id: int) -> int:
	return int(GOLPES.get(block_id, GOLPES_DEFECTO))

## Progreso de extracción (0-1) de una posición.
func _progreso_de(pos: Vector3i, block_id: int) -> float:
	var dados: int = int(_danio.get(_clave(pos), 0))
	var requeridos: int = _golpes_de(block_id)
	return clampf(float(dados) / float(requeridos), 0.0, 1.0)

func _clave(pos: Vector3i) -> String:
	return "%d,%d,%d" % [pos.x, pos.y, pos.z]

## Intenta un golpe de extracción (respeta cooldown). Llamado por el jugador con E.
func intentar_golpe() -> void:
	if _cooldown > 0.0:
		return
	try_extract()

## CONTRATO M08: intenta extraer el bloque apuntado (progresivo).
## Devuelve {} si no hay target o el golpe no completó la extracción.
func try_extract() -> Dictionary:
	if herramienta == null:
		return {}
	if herramienta.inutilizada():
		_emitir_fallo_actual("inutilizada")
		return {}
	if not herramienta.permite(ToolData.Accion.EXTRACT):
		return {}

	var hit = _raycast_camara()
	var info := _voxel_de_hit(hit)
	if info.is_empty():
		return {}
	var pos: Vector3i = info["pos"]
	var vt = _get_vt()
	if vt == null:
		return {}
	var block_id: int = int(vt.get_voxel(pos))

	if block_id == B_AIR or block_id == B_WATER:
		return {}
	if block_id == B_BEDROCK:
		print("[M13] Roca madre — no extraíble")
		_emitir_fallo_actual("permanente")
		return {}
	if not _herramienta_aplica(block_id):
		print("[M13] %s no aplica a bloque %d" % [herramienta.nombre, block_id])
		_emitir_fallo_actual("herramienta_equivocada")
		return {}

	var material: String = _material_de_bloque(block_id)
	var zona: Array[Vector3i] = _area_de_golpe(pos)
	for p in zona:
		var bid: int = int(vt.get_voxel(p))
		if _bloque_daniable(bid):
			_danio[_clave(p)] = int(_danio.get(_clave(p), 0)) + 1
	_gastar_durabilidad()
	_cooldown = herramienta.velocidad_efectiva()

	var progreso: float = _progreso_de(pos, block_id)
	golpe_conectado.emit(pos, block_id, material, progreso)

	var extraidos: Array = []
	for p in zona:
		var bid: int = int(vt.get_voxel(p))
		if not _bloque_daniable(bid):
			continue
		if int(_danio.get(_clave(p), 0)) >= _golpes_de(bid):
			var drops := _extraer_voxel(p, bid)
			extraidos.append({"pos": p, "block_id": bid, "drops": drops})
			_danio.erase(_clave(p))
			bloque_extraido.emit(p, bid, drops)
	if not extraidos.is_empty():
		return {"ok": true, "block_id": block_id, "pos": pos, "drops": extraidos[0]["drops"], "extracciones": extraidos}
	return {}

## CONTRATO M08/M17: intenta colocar un bloque en la cara adyacente al apuntado.
func try_place(block_id: int, _metadata: Dictionary = {}) -> bool:
	if herramienta == null or herramienta.inutilizada():
		return false
	if not herramienta.permite(ToolData.Accion.BUILD):
		return false

	var hit = _raycast_camara()
	var info := _voxel_de_hit(hit)
	if info.is_empty():
		return false
	var place_pos: Vector3i = info["place_pos"]

	var vt = _get_vt()
	if vt == null:
		return false
	var current_value = int(vt.get_voxel(place_pos))
	if current_value != B_AIR:
		print("[M13] Posición %s ocupada (bloque %d)" % [place_pos, current_value])
		return false

	vt.value = block_id
	vt.do_point(place_pos)
	bloque_colocado.emit(place_pos, block_id)
	print("[M13] Colocado bloque %d en %s" % [block_id, place_pos])
	return true

## Bloques que pueden recibir daño de herramienta (ni aire, ni agua, ni roca madre).
func _bloque_daniable(block_id: int) -> bool:
	return block_id != B_AIR and block_id != B_WATER and block_id != B_BEDROCK

## Área de golpe: 1 bloque, o 3×3 horizontal desde nivel 3 (RF6).
func _area_de_golpe(pos: Vector3i) -> Array[Vector3i]:
	var zona: Array[Vector3i] = [pos]
	if herramienta.area == 9:
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dz == 0:
					continue
				zona.append(Vector3i(pos.x + dx, pos.y, pos.z + dz))
	return zona

## Extrae un voxel (una sola escritura de diff, M08).
func _extraer_voxel(pos: Vector3i, block_id: int) -> Array:
	var vt = _get_vt()
	if vt == null:
		return []
	vt.value = B_AIR
	vt.do_point(pos)
	var drops := _get_drops(block_id)
	print("[M13] Extraído bloque %d en %s → drops: %s" % [block_id, pos, drops])
	return drops

## Consume 1 punto de durabilidad y notifica.
func _gastar_durabilidad() -> void:
	herramienta.gastar_uso()
	durabilidad_cambiada.emit(herramienta.durabilidad_actual, herramienta.durabilidad_max)
	if herramienta.inutilizada():
		herramienta_agotada.emit(herramienta.nombre)

## Fallo asociado al bloque apuntado actual (para feedback).
func _emitir_fallo_actual(razon: String) -> void:
	var hit = _raycast_camara()
	var info := _voxel_de_hit(hit)
	var pos: Vector3i = Vector3i(-999, -999, -999)
	if not info.is_empty():
		pos = info["pos"]
	golpe_fallido.emit(pos, razon)

## Equipa una herramienta y actualiza el feedback.
func equipar(tool_data: ToolData) -> void:
	herramienta = tool_data
	_danio.clear()
	print("[M13] Equipada: %s (dur %d/%d)" % [tool_data.nombre, tool_data.durabilidad_actual, tool_data.durabilidad_max])
	herramienta_equipada.emit(tool_data)
	durabilidad_cambiada.emit(tool_data.durabilidad_actual, tool_data.durabilidad_max)

## Mapea block_id (int) a item_id (string) para Inventario (constantes BlockType, M08).
static func _block_to_item_id(block_id: int) -> String:
	match block_id:
		B_DIRT: return "dirt"
		B_GRASS: return "grass"
		B_STONE: return "stone"
		B_SAND: return "sand"
		B_CLAY: return "clay"
		B_WOOD: return "wood"
		B_PLANKS: return "planks"
		B_COPPER: return "copper_ore"
		B_IRON: return "iron_ore"
		B_CRYSTAL: return "crystal"
		B_GEMSTONE: return "gemstone"
		B_GLASS: return "glass"
		14: return "ancient_crystal"
		15: return "lamp_glyph"
		B_ICE: return "ice"
		B_SNOW: return "snow"
		B_GRAVEL: return "gravel"
		B_MOSS: return "moss"
		B_MUD: return "mud"
		_: return "unknown_%d" % block_id

## Drops de un bloque (drop = el mismo bloque como item; M15 refinará).
func _get_drops(block_id: int) -> Array:
	var item_id := _block_to_item_id(block_id)
	return [{"item_id": item_id, "amount": 1}]

func _find_terrain() -> VoxelTerrain:
	var root := get_tree().current_scene
	if root == null:
		return null
	for child in root.get_children():
		if child is VoxelTerrain:
			return child as VoxelTerrain
	return null

## Devuelve info del último objetivo para debug/HUD.
func get_debug_info() -> String:
	if herramienta == null:
		return "[M13] Sin herramienta"
	return "[M13] %s | dur %d/%d | cooldown %.2f" % [herramienta.nombre, herramienta.durabilidad_actual, herramienta.durabilidad_max, _cooldown]
