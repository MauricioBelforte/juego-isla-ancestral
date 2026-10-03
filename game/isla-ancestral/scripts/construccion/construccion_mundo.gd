# Modelo: DeepSeek-V4.1-Flash (WorkBuddy)
# Fecha: 2026-10-03
#
# M17 Construccion iter. 1 — ConstruccionMundo: adaptador al mundo REAL.
#
# Aisla las dependencias del motor para que el nucleo (validator/history/manager)
# siga siendo testeable en headless:
#   * M08 Mundo Voxel: escribe/borra voxeles con `VoxelTool` y etiqueta la
#     superficie de una celda (terreno / agua / aire) leyendo el bloque real.
#   * M64 IA de NPC: `hay_npc_en` por duck-typing (inyectable); si no hay
#     proveedor, devuelve false y NO inventa NPCs.
#
# El adaptador NO decide: no valida, no cobra, no registra piezas. Solo traduce
# "mundo" a datos que el validador entiende. Es tolerante por diseno: sin
# terreno disponible devuelve "aire" y las escrituras son no-op (devuelven 0),
# de modo que el manager funciona en modo logico aunque el mundo no este cargado.
#
# Los ids de bloque son los de M08 (`BlockType`): AIR=0, WATER=17, SHALLOW_WATER=30.

class_name ConstruccionMundo
extends RefCounted

## VoxelTerrain activo (puede ser null: modo logico sin mundo).
var _terrain = null

## Proveedor opcional de NPCs: Callable(Vector3i) -> bool.
var _npc_provider: Callable = Callable()

## Contadores de diagnostico (lo que realmente se escribio en el mundo).
var escrituras: int = 0
var borrados: int = 0

## ── Conexion ────────────────────────────────────────────────────────────

## Conecta un VoxelTerrain explicito. Acepta null para desligar.
func conectar_terrain(t) -> void:
	_terrain = t

## Conecta un proveedor de NPCs (Callable(Vector3i) -> bool).
func conectar_npc(provider: Callable) -> void:
	_npc_provider = provider

func tiene_terreno() -> bool:
	return _terrain != null and is_instance_valid(_terrain)

func terrain():
	return _terrain

## Busca el VoxelTerrain en la escena actual (mismo criterio que TerrainLocator).
## Devuelve el terrain o null. No lo guarda si no lo encuentra.
func resolver_terreno():
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return null
	var raiz := arbol.current_scene
	if raiz != null:
		var t = raiz.get_node_or_null("VoxelTerrain")
		if t != null:
			_terrain = t
			return _terrain
	return _buscar_en(arbol.root)

func _buscar_en(nodo: Node):
	for hijo in nodo.get_children():
		if hijo is VoxelTerrain:
			_terrain = hijo
			return _terrain
		var r = _buscar_en(hijo)
		if r != null:
			return r
	return null

## ── Lectura ─────────────────────────────────────────────────────────────

## Superficie que ofrece una celda SEGUN EL TERRENO VOXEL (no conoce piezas):
##   "aire"    bloque AIR
##   "agua"    WATER / SHALLOW_WATER
##   "terreno" cualquier otro bloque solido (terreno generado o construccion M08)
## Sin terreno -> "aire" (modo logico).
func superficie_voxel(celda: Vector3i) -> StringName:
	if not tiene_terreno():
		return &"aire"
	var vt = _terrain.get_voxel_tool()
	if vt == null:
		return &"aire"
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	var id: int = int(vt.get_voxel(celda)) & 0xFF
	return _clasificar_bloque(id)

## Altura del terreno en (x, z), o -1 si no hay terreno. Usa el generador real
## si esta expuesto (`_get_island_gen`), igual que TerrainLocator.
func altura(x: int, z: int) -> int:
	if not tiene_terreno():
		return -1
	var gen = _terrain.generator
	if gen != null and gen.has_method("_get_island_gen"):
		return int(gen._get_island_gen().get_height(x, z))
	return -1

## true si hay un NPC activo en la celda. Solo si hay proveedor conectado.
func hay_npc_en(celda: Vector3i) -> bool:
	if not _npc_provider.is_valid():
		return false
	return bool(_npc_provider.call(celda))

## ── Escritura ───────────────────────────────────────────────────────────

## Escribe `bloque` en cada celda. Devuelve cuantas celdas se escribieron
## (0 si no hay terreno). Marca el chunk dirty (M08 lo orquesta por su cuenta).
func escribir_voxel(celdas: Array, bloque: int) -> int:
	if not tiene_terreno() or bloque <= 0:
		return 0
	var vt = _terrain.get_voxel_tool()
	if vt == null:
		return 0
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	vt.mode = VoxelTool.MODE_SET
	vt.value = bloque
	var n: int = 0
	for c in celdas:
		vt.do_point(c)
		n += 1
	escrituras += n
	return n

## Borra (deja aire) cada celda. Devuelve cuantas celdas se borraron.
func borrar_voxel(celdas: Array) -> int:
	if not tiene_terreno():
		return 0
	var vt = _terrain.get_voxel_tool()
	if vt == null:
		return 0
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	vt.mode = VoxelTool.MODE_REMOVE
	vt.eraser_value = 0
	var n: int = 0
	for c in celdas:
		vt.do_point(c)
		n += 1
	borrados += n
	return n

## Reinicia contadores de diagnostico.
func reiniciar_contadores() -> void:
	escrituras = 0
	borrados = 0

## ── Internos ────────────────────────────────────────────────────────────

static func _clasificar_bloque(id: int) -> StringName:
	if id == BlockType.AIR:
		return &"aire"
	if id == BlockType.WATER or id == BlockType.SHALLOW_WATER:
		return &"agua"
	return &"terreno"
