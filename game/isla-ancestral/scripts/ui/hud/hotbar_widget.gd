extends Control
## M53 HUD — HotbarWidget: barra de accesos rápidos sincronizada con inventario (M11).

var _items: Array[ItemData] = []
var _slots: int = 8

func _ready() -> void:
	_items.resize(_slots)

func set_items(items: Array) -> void:
	for i in _slots:
		if i < items.size():
			_items[i] = items[i]
		else:
			_items[i] = null

func get_slot(index: int) -> ItemData:
	if index < 0 or index >= _slots:
		return null
	return _items[index]
