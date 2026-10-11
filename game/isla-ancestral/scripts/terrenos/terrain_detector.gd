# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Terrenos — TerrainDetector (diseño §1.2 adaptado a VoxelTerrain M08).
# Raycast vertical desde el jugador; debounce anti-flickering (§10.2).
# Si el raycast no golpea voxel, consulta GameTime TerrainLocator (altura).
#
# M156 iter. 4 (B3, 2026-10-09, DeepSeek-V4.1-Flash) — 3 correcciones MEDIDAS:
#   G2  resolucion del terreno: grupo "voxel_terrain" -> TerrainLocator (duck-typed)
#       -> busqueda en la rama de escena -> arbol. Al hallarlo lo REGISTRA en el
#       grupo (el grupo estaba VACIO: 0 add_to_group en todo el proyecto).
#   G4  aislamiento del rayo: el terreno y los NPC comparten la capa 1 ("mundo"),
#       asi que el rayo se frenaba en un NPC. Se AGREGA al terreno un bit dedicado
#       (capa 6) sin quitarle la capa 1 (camera_spring y demas siguen igual) y el
#       RayCast3D usa SOLO ese bit. collide_with_areas=false (agua decorativa).
#   D1  FIX de codigo muerto: `_block_id_en()` exigia `terrain.get("storage")`,
#       propiedad que VoxelTerrain NO tiene en 4.7.2 (medido: "storage" in vt ==
#       false) => devolvia -1 SIEMPRE y el detector reportaba siempre cesped(0).
#       Ahora usa la API real (get_voxel_tool), patron de player.gd/farm_service.gd.
#       D1-bis: `pos` llega en MUNDO y el VoxelTool usa LOCAL; se convierte con
#       to_local() (en main_island el terreno esta en el origen y no se notaba).
class_name TerrainDetector
extends RayCast3D

## M156 iter. 4 (B3, G4): bit de fisica dedicado al terreno voxel.
## project.godot nombra 1=mundo 2=jugador 3=npc 4=interactuable 5=agua; el bit 6
## esta libre en runtime. La tabla §4.1 de 04-Codigo.md (capas 2-8, una por tipo
## de terreno) describe el modelo LEGACY "un StaticBody3D por bloque" y NO aplica
## al VoxelTerrain unico de M08 (ver 04-Codigo.md §4.4).
const LAYER_TERRENO_BIT: int = 6
## Mascara final del RayCast3D: SOLO el bit dedicado (valor 32). Es el valor que
## queda configurado en Player.tscn y el que aplica _ready().
const LAYER_TERRENO_MASK: int = 1 << (LAYER_TERRENO_BIT - 1)
## Grupo canonico donde se registra el terreno (convencion de debug_menu/M110).
const GRUPO_TERRENO: String = "voxel_terrain"

@export var detection_interval: float = 0.1
@export var ray_length: float = 2.0
## Debounce: cambios con menos de este intervalo se ignoran (§10.2 flickering)
@export var debounce_seg: float = 0.15

signal terrain_changed(new_terrain_id: int)

var current_terrain_id: int = 0
var detection_timer: float = 0.0
var _ultimo_cambio: float = 0.0
## Terreno resuelto (cache). Se re-resuelve si queda invalido (streaming tardio).
var _terreno: Node = null


func _ready() -> void:
	target_position = Vector3(0, -ray_length, 0)
	enabled = true
	# G4: solo cuerpos (el agua decorativa es Area3D en la capa 5) y SOLO el bit
	# dedicado del terreno, para que NPC/objetos de la capa "mundo" no lo frenen.
	collide_with_areas = false
	collide_with_bodies = true
	collision_mask = LAYER_TERRENO_MASK
	_resolver_terreno()


func _physics_process(delta: float) -> void:
	detection_timer += delta
	if detection_timer >= detection_interval:
		detection_timer = 0.0
		_detect_terrain()


func _detect_terrain() -> void:
	_resolver_terreno()
	if not is_colliding():
		return
	var collider: Object = get_collider()
	var new_terrain_id := current_terrain_id
	if collider is VoxelTerrain:
		# VoxelTerrain de M08: mapear block_id → terrain_id vía provider
		var pos := get_collision_point() - Vector3(0, 0.1, 0)
		new_terrain_id = _block_a_terrain(_block_id_en(pos))
	elif collider != null and collider.has_method("get_terrain_id"):
		# Contrato legacy §4.3: bloque de terreno con get_terrain_id()
		new_terrain_id = int(collider.get_terrain_id())
	else:
		# Colisionador que no es terreno (NPC, objeto, jugador): no cambia nada.
		return
	if new_terrain_id != current_terrain_id:
		var now := Time.get_ticks_msec() / 1000.0
		if now - _ultimo_cambio >= debounce_seg:
			_ultimo_cambio = now
			current_terrain_id = new_terrain_id
			terrain_changed.emit(current_terrain_id)


## M156 iter. 4 (B3, G2): resuelve el VoxelTerrain de la escena y lo REGISTRA en
## el grupo "voxel_terrain" (que estaba vacio). Orden de resolucion:
##   1. grupo "voxel_terrain"
##   2. TerrainLocator (M167/M168) si expone el nodo — hoy NO lo expone (medido:
##      solo get_height/posicionar_sobre_terreno/esta_sobre_superficie); se sondea
##      por duck-typing para que funcione el dia que su dueno lo exponga.
##   3. busqueda en la RAMA de escena del detector (mismo mecanismo que
##      TerrainLocator::_find_in_tree y debug_menu::_obtener_voxel_terrain).
##   4. busqueda en current_scene y en el arbol (fallback).
func _resolver_terreno() -> bool:
	if _terreno != null and is_instance_valid(_terreno):
		return true
	_terreno = null
	var arbol := get_tree()
	if arbol == null:
		return false
	var cand: Node = arbol.get_first_node_in_group(GRUPO_TERRENO)
	if cand == null:
		cand = _terreno_del_locator()
	if cand == null:
		cand = _buscar_en(_rama_de_escena())
	if cand == null:
		cand = _buscar_en(arbol.current_scene)
	if cand == null:
		cand = _buscar_en(arbol.root)
	if cand == null:
		return false
	_terreno = cand
	# G2: el grupo deja de estar vacio (registro en runtime, sin tocar M08).
	if not _terreno.is_in_group(GRUPO_TERRENO):
		_terreno.add_to_group(GRUPO_TERRENO)
	_asegurar_capa_dedicada()
	return true


## Rama de escena del detector: sube hasta el hijo directo de root.
func _rama_de_escena() -> Node:
	var n: Node = self
	while n.get_parent() != null and n.get_parent() != get_tree().root:
		n = n.get_parent()
	return n


func _buscar_en(raiz: Node) -> Node:
	if raiz == null:
		return null
	for n in raiz.find_children("*", "VoxelTerrain", true, false):
		return n
	return null


## Mecanismo de M167/M168 sondeado por duck-typing (no se toca ese modulo).
func _terreno_del_locator() -> Node:
	var loc := get_node_or_null("/root/TerrainLocator")
	if loc == null:
		return null
	if loc.has_method("get_terreno"):
		var t: Variant = loc.call("get_terreno")
		if t is VoxelTerrain:
			return t
	return null


## M156 iter. 4 (B3, G4): aísla el terreno en el bit dedicado.
## AGREGA el bit (no quita el 1) => los consumidores de "mundo" (camera_spring,
## movimiento fisico de NPC) siguen viendo el terreno; el rayo del detector usa
## SOLO el bit dedicado, asi que NPC/objetos de la capa 1 no lo interceptan.
func _asegurar_capa_dedicada() -> void:
	var vt_node: VoxelTerrain = _terreno as VoxelTerrain
	if vt_node == null:
		return
	var bit := LAYER_TERRENO_MASK
	if int(vt_node.collision_layer) & bit == 0:
		vt_node.collision_layer = int(vt_node.collision_layer) | bit
	collision_mask = bit


## Bloque voxel bajo el punto (M08 VoxelTool).
## M156 iter. 4 (B3, D1): la version previa exigia `terrain_node.get("storage")
## != null`; VoxelTerrain NO tiene esa propiedad en 4.7.2 => devolvia -1 SIEMPRE
## (el detector reportaba siempre cesped). Ahora usa la API real.
## M156 iter. 4 (B3, D1-bis): `pos` llega en coordenadas de MUNDO, pero el
## VoxelTool del terreno trabaja en coordenadas LOCALES del VoxelTerrain. En
## main_island el terreno esta en el origen (mundo == local) y por eso el bug no
## se veia, pero asumirlo es fragil: se convierte explicitamente con to_local().
func _block_id_en(pos: Vector3) -> int:
	if _terreno == null or not _terreno.has_method("get_voxel_tool"):
		return -1
	var vt: VoxelTool = _terreno.call("get_voxel_tool") as VoxelTool
	if vt == null:
		return -1
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	var local := pos
	var t3 := _terreno as Node3D
	if t3 != null:
		local = t3.to_local(pos)
	var celda := Vector3i(int(floor(local.x)), int(floor(local.y)), int(floor(local.z)))
	var bid: int = int(vt.get_voxel(celda))
	if bid < 0:
		return -1
	return bid & 0xFF


## Mapeo block_id (M08 `BlockType`, scripts/world/block_type.gd) → terrain_id (M156 §4.1).
## M156 iter. 3 (B1.2): mapa COMPLETO 7/7 — antes solo se alcanzaban {0,3,5,6} y
## barro(1), pavimento(2) y agua(4) eran INALCANZABLES (bloques reales de M08 no mapeados).
func _block_a_terrain(block_id: int) -> int:
	match block_id:
		# 0 Cesped: hierba, tierra y musgo
		BlockType.DIRT, BlockType.GRASS, BlockType.MOSS:
			return 0
		# 1 Barro: barro y arcilla
		BlockType.MUD, BlockType.CLAY:
			return 1
		# 2 Pavimento: superficies construidas (bloques de M08 construccion)
		BlockType.FLOOR_TILE, BlockType.ADOBE_WALL, BlockType.ROOF_TILE, BlockType.PLANKS, \
		BlockType.PRESSURE_PLATE, BlockType.LIGHT_RECEIVER, BlockType.GLYPH_EMITTER, \
		BlockType.SLIDING_BLOCK, BlockType.FLOW_VASE, BlockType.GLASS:
			return 2
		# 3 Arena
		BlockType.SAND:
			return 3
		# 4 Agua: agua y agua poco profunda
		BlockType.WATER, BlockType.SHALLOW_WATER:
			return 4
		# 5 Nieve: nieve y hielo
		BlockType.SNOW, BlockType.ICE:
			return 5
		# 6 Rocas: piedra, roca madre, grava, minerales, cristales y madera
		BlockType.STONE, BlockType.BEDROCK, BlockType.GRAVEL, BlockType.WOOD, \
		BlockType.COPPER_ORE, BlockType.IRON_ORE, BlockType.CRYSTAL, BlockType.GEMSTONE, \
		BlockType.ANCIENT_CRYSTAL, BlockType.LAMP_GLYPH:
			return 6
		-1, 0:
			return 0  # aire/unknown → césped = modificador neutro 1.0 (default §10.2)
		_:
			return 6  # rocas (default para sólidos desconocidos)


func get_current_terrain_id() -> int:
	return current_terrain_id


## M156 iter. 4 (B3): terreno resuelto (para tests/QA sin tocar la var privada).
func get_terreno() -> Node:
	return _terreno
