# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Memoria — GlobalPool
# Pooling global por familia (RF3): piscinas tipadas con API
# obtener/devolver/precalentar, límites y contadores.
# Diseño original (04-Codigo.md §2, GlobalPool).
# Iter. 2 (Log 604, glm-5.3-flash): auditoría de señales al devolver
# (desconexión explícita — checklist RN), fallback honesto documentado,
# drenar_familia() para cambio de escena parcial.

class_name GlobalPool
extends RefCounted

var _pools: Dictionary = {}   # familia -> Array de objetos (pool)
var _limites: Dictionary = {} # familia -> int
var _tamanios_max: Dictionary = {}  # familia -> int (máximo visto)

## Precalienta `cantidad` objetos de `familia` (el caller los crea con factory).
func precalentar(familia: String, cantidad: int, factory: Callable = Callable()) -> void:
	if not _pools.has(familia):
		_pools[familia] = []
	if factory.is_valid():
		for i in range(cantidad):
			(_pools[familia] as Array).append(factory.call())

## Devuelve un objeto de la familia (o null si está vacía sin factory).
func obtener(familia: String) -> Node:
	var pool: Array = _pools.get(familia, [])
	if pool.is_empty():
		return null
	var obj: Node = pool.pop_back()
	# Al salir del pool el objeto queda activo y visible (estado de uso)
	obj.set_process(true)
	obj.set_physics_process(true)
	if obj is CanvasItem:
		obj.visible = true
	return obj

## Devuelve el objeto al pool. Auditoría de señales (RN del checklist):
## desconecta TODAS las conexiones entrantes del objeto antes de
## estacionarlo (evita callbacks a nodos liberados). Si la familia está
## llena, fallback honesto: el objeto se libera con queue_free (sin
## crecer sin tope). Ítem devuelto: invisible, quieto, sin señales.
func devolver(familia: String, objeto: Node) -> bool:
	if objeto == null:
		return false
	if not _pools.has(familia):
		_pools[familia] = []
	var pool: Array = _pools[familia]
	var limite: int = _limites.get(familia, 256)
	if pool.size() >= limite:
		# Fallback honesto (checklist RF): no crecer sin tope
		objeto.queue_free()
		return false
	objeto.set_process(false)
	objeto.set_physics_process(false)
	if objeto is CanvasItem:
		objeto.visible = false
	_auditar_senales(objeto)
	pool.append(objeto)
	_tamanios_max[familia] = max(_tamanios_max.get(familia, 0), pool.size())
	return true


## RN Auditoría de señales: desconecta las conexiones ENTRANTES al objeto
## (las que otros nodos le conectaron a él) para que un ítem estacionado
## no retenga callbacks a objetos que podrían liberarse primero.
func _auditar_senales(objeto: Node) -> void:
	var lista := objeto.get_incoming_connections()
	for conn in lista:
		var señal: Signal = conn.get("signal")
		var callable: Callable = conn.get("callable")
		if señal != null and callable.is_valid():
			if señal.is_connected(callable):
				señal.disconnect(callable)

func set_limite(familia: String, limite: int) -> void:
	_limites[familia] = limite

func limite(familia: String) -> int:
	return int(_limites.get(familia, 256))

func tamanio(familia: String) -> int:
	return int(_pools.get(familia, []).size())

## Drena UNA familia (cambio de escena parcial). Devuelve liberados.
func drenar_familia(familia: String) -> int:
	var pool: Array = _pools.get(familia, [])
	var n := pool.size()
	_pools[familia] = []
	return n

## Drena todos los pools (cambio de escena). Devuelve total liberado.
func liberar_todo() -> int:
	var total := 0
	for familia in _pools:
		total += (_pools[familia] as Array).size()
		_pools[familia] = []
	return total

func familias() -> Array:
	return _pools.keys()