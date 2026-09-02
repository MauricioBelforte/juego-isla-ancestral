# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M62: Memoria — GlobalPool
# Pooling global por familia (RF3): piscinas tipadas con API
# obtener/devolver/precalentar, límites y contadores.
# Diseño original (04-Codigo.md §2, GlobalPool).

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
	return pool.pop_back()

## Devuelve el objeto al pool si la familia existe y no supera el límite.
func devolver(familia: String, objeto: Node) -> bool:
	if objeto == null:
		return false
	if not _pools.has(familia):
		_pools[familia] = []
	var pool: Array = _pools[familia]
	var limite: int = _limites.get(familia, 256)
	if pool.size() >= limite:
		return false
	objeto.set_process(false)
	objeto.set_physics_process(false)
	if objeto is CanvasItem:
		objeto.visible = false
	pool.append(objeto)
	_tamanios_max[familia] = max(_tamanios_max.get(familia, 0), pool.size())
	return true

func set_limite(familia: String, limite: int) -> void:
	_limites[familia] = limite

func limite(familia: String) -> int:
	return int(_limites.get(familia, 256))

func tamanio(familia: String) -> int:
	return int(_pools.get(familia, []).size())

## Drena todos los pools (cambio de escena). Devuelve total liberado.
func liberar_todo() -> int:
	var total := 0
	for familia in _pools:
		total += (_pools[familia] as Array).size()
		_pools[familia] = []
	return total

func familias() -> Array:
	return _pools.keys()