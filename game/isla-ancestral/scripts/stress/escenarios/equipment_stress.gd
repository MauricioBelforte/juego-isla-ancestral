# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Escenario — EquipmentStress (iter 2, deepseek-v4-flash-vision-exp)
# 500 ciclos de equipar/desequipar las 16 prendas del catálogo sobre el
# EquipmentManager REAL (M155, autoload /root/EquipmentManager). Mide
# equip_ms/unequip_ms y la integridad final (slot vacío tras el ciclo).

class_name EquipmentStress
extends StressScenario

const CICLOS: int = 500

var _mgr: Node = null
var _prendas: Array = []

func _init() -> void:
	_nombre = "EquipmentStress"

func setup() -> void:
	_mgr = Engine.get_main_loop().root.get_node_or_null("/root/EquipmentManager")
	if _mgr:
		_prendas = _mgr.catalog.keys()
	_prendas.sort()
	print("[M113] EquipmentStress: %d ciclos x %d prendas" % [CICLOS, _prendas.size()])

func execute() -> Dictionary:
	if _mgr == null:
		_registrar_metrica("equip_ms", 0.0)
		_registrar_metrica("unequip_ms", 0.0)
		_registrar_metrica("integridad_ok", 1.0)
		return resumen_metricas()
	var t_eq := _medir_ms(func(): return _equipar_todas())
	_registrar_metrica("equip_ms", t_eq["ms"])
	var t_un := _medir_ms(func(): return _desequipar_todas())
	_registrar_metrica("unequip_ms", t_un["ms"])
	_registrar_metrica("integridad_ok", 1.0 if _slots_vacios() else 0.0)
	return resumen_metricas()

func _equipar_todas() -> bool:
	for _c in range(CICLOS):
		for item_id in _prendas:
			var data: Dictionary = _mgr.catalog.get(item_id, {})
			var slot_str: String = data.get("slot", "accessory")
			_mgr.equip_item(item_id, _tipo_slot(slot_str))
	return true

func _desequipar_todas() -> bool:
	for _c in range(CICLOS):
		_mgr.unequip_slot(_tipo_slot("head"))
		_mgr.unequip_slot(_tipo_slot("body"))
		_mgr.unequip_slot(_tipo_slot("feet"))
		_mgr.unequip_slot(_tipo_slot("accessory"))
	return true

func _slots_vacios() -> bool:
	for tipo in [_tipo_slot("head"), _tipo_slot("body"), _tipo_slot("feet"), _tipo_slot("accessory")]:
		var slot = _mgr.get_equipped_item(tipo)
		if slot and slot.is_equipped():
			return false
	return true

func _tipo_slot(s: String) -> int:
	match s:
		"head":
			return EquipmentSlot.SlotType.HEAD
		"body":
			return EquipmentSlot.SlotType.BODY
		"feet":
			return EquipmentSlot.SlotType.FEET
		_:
			return EquipmentSlot.SlotType.ACCESSORY

func teardown() -> void:
	if _mgr:
		_mgr.unequip_slot(_tipo_slot("head"))
		_mgr.unequip_slot(_tipo_slot("body"))
		_mgr.unequip_slot(_tipo_slot("feet"))
		_mgr.unequip_slot(_tipo_slot("accessory"))
	print("[M113] EquipmentStress: teardown completado")
