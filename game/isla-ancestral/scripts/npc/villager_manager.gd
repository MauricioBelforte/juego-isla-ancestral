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

func _obtener_jugador() -> Node:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null
