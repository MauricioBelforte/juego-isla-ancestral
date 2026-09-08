class_name InventoryComponent
extends Node

## Componente reutilizable de inventario ligero (M111 - Código de Calidad).
## No reemplaza a M14; es un building-block de composición para entidades NPC/objetos.

signal item_added(item_id: String, amount: int)
signal item_removed(item_id: String, amount: int)

var items: Dictionary = {}

func add_item(item_id: String, amount: int = 1) -> void:
	items[item_id] = items.get(item_id, 0) + amount
	item_added.emit(item_id, amount)

func remove_item(item_id: String, amount: int = 1) -> bool:
	if items.get(item_id, 0) < amount:
		return false
	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)
	item_removed.emit(item_id, amount)
	return true

func count(item_id: String) -> int:
	return items.get(item_id, 0)
