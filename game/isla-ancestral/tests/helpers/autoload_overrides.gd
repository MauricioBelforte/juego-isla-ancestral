# Modelo: DS-V4.1-Flash-Opencode (DeepSeek V4.1 Flash)
# Plataforma: OpenCode
# Fecha: 2026-10-16
#
# M112 — L152: Helper de tests para intercambiar autoloads por dobles (mocks).
#
# Problema: los tests de integración necesitan simular estados que en producción
# dependen de autoloads vivos (ej: inventario lleno) sin tocar el autoload real
# (su estado persistiría entre tests y contaminaría el resto de la suite).
#
# Solución: `swap(nombre, mock)` saca el autoload original de /root (conservando
# su referencia y sus hijos) e instala el mock con el MISMO nombre, de modo que
# `get_node("/root/<nombre>")` y las rutas hardcodeadas de los servicios siguen
# resolviendo. `restaurar(nombre)` devuelve el original.
#
# ⚠️ Advertencias documentadas:
# - Al sacar/re-agregar el original se disparan `_exit_tree`/`_enter_tree`, pero
#   `_ready` NO se re-ejecuta (estado interno preservado). Un autoload que
#   limpie recursos en `_exit_tree` puede degradarse tras un swap/restauración.
# - El mock NO se libera desde acá: lo libera el test que lo creó (al liberarse,
#   si seguía instalado, el helper avisa por `push_error`).
# - No usar sobre autoloads de infraestructura crítica (EventBus, GameSettings)
#   salvo que el test lo justifique.
#
# Uso típico:
#   var overrides := AutoloadOverrides.new(self)
#   overrides.swap("Inventario", mock)
#   ...
#   overrides.restaurar("Inventario")
#   mock.free()

class_name AutoloadOverrides
extends RefCounted

var _tree: SceneTree
var _guardados: Dictionary = {}
var _mocks: Dictionary = {}


func _init(tree: SceneTree) -> void:
	_tree = tree


## Intercambia el autoload `nombre` por `mock`. Devuelve true si se instaló.
## El mock pasa a llamarse `nombre` para conservar la ruta /root/<nombre>.
func swap(nombre: String, mock: Node) -> bool:
	if _tree == null or _tree.root == null:
		push_error("[AutoloadOverrides] sin SceneTree válido")
		return false
	if mock == null:
		push_error("[AutoloadOverrides] el mock de '%s' es null" % nombre)
		return false
	if _guardados.has(nombre):
		push_error("[AutoloadOverrides] ya hay un mock activo para '%s'" % nombre)
		return false
	var original: Node = _tree.root.get_node_or_null(nombre)
	if original == null:
		push_error("[AutoloadOverrides] no existe el autoload '%s'" % nombre)
		return false
	mock.name = nombre
	_tree.root.remove_child(original)
	_guardados[nombre] = original
	_mocks[nombre] = mock
	_tree.root.add_child(mock)
	return true


## Saca el mock y devuelve el autoload original. El mock queda en manos del test.
func restaurar(nombre: String) -> bool:
	if not _mocks.has(nombre) or not _guardados.has(nombre):
		push_error("[AutoloadOverrides] '%s' no tiene swap activo" % nombre)
		return false
	var mock: Node = _mocks[nombre]
	var original: Node = _guardados[nombre]
	_tree.root.remove_child(mock)
	_tree.root.add_child(original)
	_mocks.erase(nombre)
	_guardados.erase(nombre)
	return true


## Restaura todos los swaps activos (llamar al final de cada test).
func restaurar_todos() -> void:
	for nombre in _mocks.keys():
		restaurar(nombre)


## Cantidad de swaps activos.
func swaps_activos() -> int:
	return _mocks.size()


## true si `nombre` está actualmente mockeado.
func es_mock(nombre: String) -> bool:
	return _mocks.has(nombre)


## Node mock instalado para `nombre` (o null si no hay swap).
func mock_de(nombre: String) -> Node:
	return _mocks.get(nombre)
