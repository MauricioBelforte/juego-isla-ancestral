extends Node

## Módulo 19: NPC y Vecinos — VillagerManager (autoload)
##
## Autoridad de la población: detecta interacción F, gestiona NPCs activos,
## emite señales para M20/M21/M64.

signal poblacion_cambio(lista_activa: Array)
signal regalo_recibido(vecino: Node, objeto_id: String)
signal interaccion_exitosa(vecino: Node)

const RANGO_DETECTAR: float = 3.0
const POBLACION_MAX: int = 10

var _activos: Array[Node] = []
var _target_actual: Node = null


func _ready() -> void:
	print("[VillagerManager] Inicializado (población max: %d)" % POBLACION_MAX)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		# Solo interactuar si el inventario NO está abierto
		var player := _obtener_jugador()
		if player and player.has_method("get"):
			var inv_open: bool = player.get("_inventory_open") if player.get("_inventory_open") != null else false
			if not inv_open:
				_intentar_interaccion()


## ── Detección de objetivo ──────────────────────────────

func _intentar_interaccion() -> void:
	var player := _obtener_jugador()
	if not player:
		return

	var mejor: Node = null
	var mejor_dist: float = RANGO_DETECTAR + 1.0

	for villager in _activos:
		if not is_instance_valid(villager):
			continue
		if villager.has_method("esta_disponible") and not villager.esta_disponible():
			continue
		var dist: float = player.global_position.distance_to(villager.global_position)
		if dist < mejor_dist:
			mejor_dist = dist
			mejor = villager

	if mejor:
		_target_actual = mejor
		mejor.interactuar(player)
		interaccion_exitosa.emit(mejor)
		print("[VillagerManager] Interacción con %s (dist=%.2f)" % [mejor.name, mejor_dist])
	else:
		_target_actual = null


func detectar_objetivo(pos_jugador: Vector3) -> Node:
	var mejor: Node = null
	var mejor_dist: float = RANGO_DETECTAR + 1.0

	for villager in _activos:
		if not is_instance_valid(villager):
			continue
		if villager.has_method("esta_disponible") and not villager.esta_disponible():
			continue
		var dist: float = pos_jugador.distance_to(villager.global_position)
		if dist < mejor_dist:
			mejor_dist = dist
			mejor = villager
	return mejor


## ── Gestión de población ───────────────────────────────

func registrar_villager(villager: Node) -> void:
	if villager not in _activos:
		_activos.append(villager)
		poblacion_cambio.emit(_activos)
		print("[VillagerManager] %s registrado (%d activos)" % [villager.name, _activos.size()])


func desregistrar_villager(villager: Node) -> void:
	_activos.erase(villager)
	poblacion_cambio.emit(_activos)
	print("[VillagerManager] %s desregistrado (%d activos)" % [villager.name, _activos.size()])


func obtener_activos() -> Array:
	return _activos.duplicate()


func obtener_vecino(id: String) -> Node:
	for v in _activos:
		if is_instance_valid(v) and v.name == id:
			return v
	return null


func plaza_libre() -> bool:
	return _activos.size() < POBLACION_MAX


func obtener_poblacion_actual() -> int:
	return _activos.size()


## ── Regalos ────────────────────────────────────────────

func entregar_regalo(vecino_id: String, objeto_id: String) -> void:
	var vecino: Node = obtener_vecino(vecino_id)
	if vecino and vecino.has_method("recibir_regalo"):
		vecino.recibir_regalo(objeto_id)
		regalo_recibido.emit(vecino, objeto_id)


## ── Utilidades ─────────────────────────────────────────

## Obtiene la altura del suelo en una posición XZ usando el generador de mundo.
## Retorna la coordenada Y de la superficie, o -1.0 si no encontró nada.
func get_ground_height(xz_pos: Vector2) -> float:
	var generator_script = load("res://scripts/world/island_generator.gd")
	if generator_script:
		var gen = generator_script.new(null, 42)
		gen.island_radius = 64
		gen.max_height = 40
		var h: int = gen.get_height(int(xz_pos.x), int(xz_pos.y))
		return float(h) if h > 0 else -1.0
	return -1.0


## Posiciona un nodo sobre el terreno en la posición XZ dada.
## Si no encuentra suelo, deja la posición actual.
func colocar_sobre_terreno(nodo: Node3D, xz_pos: Vector2) -> void:
	var h: float = get_ground_height(xz_pos)
	if h >= 0.0:
		nodo.global_position = Vector3(xz_pos.x, h, xz_pos.y)


func _obtener_terrain() -> VoxelTerrain:
	var root = get_tree().current_scene
	if root:
		var t = root.get_node_or_null("VoxelTerrain")
		if t is VoxelTerrain:
			return t
	# Fallback: buscar desde la raíz del árbol
	if get_tree().root:
		var t = get_tree().root.get_node_or_null("Main/VoxelTerrain")
		if t is VoxelTerrain:
			return t
	return null


func _obtener_jugador() -> Node:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
