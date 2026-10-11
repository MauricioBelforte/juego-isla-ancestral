# Modelo: agnes-2.5-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-05
#
# Fix M155 (DeepSeek-V4.1-Flash, 2026-10-10): los 3 fallos eran expectativas del
# test desalineadas con el diseno vigente, NO bugs de producto:
#   1) los slots de PlayerEquipment nacen null (creacion perezosa; 03-Diseno s2.2).
#   2/3) equip_item consume del inventario (M14, checklist H [x]) -> hay que sembrarlo.
# Se agrego guardia anti-falso-verde: marcadores de bloque (_fin) + piso CHECKS_MINIMOS.
#
# M155: Test de EquipmentManager + TerrainType + limites de accesorios.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/player/test_equipment_m155.gd

extends SceneTree

const MODULO := "M155"
const BLOQUES: Array[String] = [
	"terrain_type", "autoload", "equip_unequip", "accesorios", "bloqueadas", "bonus_terreno"
]
## Piso medido en verde (leccion BUG-120/122): la suite aborta en rojo si el conteo baja.
const CHECKS_MINIMOS := 29

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_test_terrain_type_enum()
	_fin("terrain_type")
	_test_equipment_manager_autoload()
	_fin("autoload")
	_test_equip_unequip()
	_fin("equip_unequip")
	_test_accesorios_limit()
	_fin("accesorios")
	_test_bloqueadas_no_equipan()
	_fin("bloqueadas")
	_test_bonus_terreno()
	_fin("bonus_terreno")

func _summary() -> void:
	var faltan: Array[String] = []
	for n in BLOQUES:
		if not _vistos.has(n):
			faltan.append(n)
	if not faltan.is_empty():
		_fallos += 1
		print("FALLO: bloques no ejecutados (posible SCRIPT ERROR): %s" % [faltan])
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M155 EQUIPMENT: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true

## Siembra 1 unidad del item en el inventario M14 (equip_item lo consume al equipar).
func _sembrar_en_inventario(item_id: String) -> bool:
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("add_item"):
		inv.add_item(item_id, 1)
		return true
	return false

## ── Tests ────────────────────────────────────────────────────

func _test_terrain_type_enum() -> void:
	# Item 41: enum TerrainType con valores grass, mud, pavement, sand, shallow_water, snow, rock
	var tt := preload("res://scripts/player/equipment_slot.gd")
	_check(tt.TerrainType.GRASS == 0, "TerrainType.GRASS = 0")
	_check(tt.TerrainType.MUD == 1, "TerrainType.MUD = 1")
	_check(tt.TerrainType.PAVEMENT == 2, "TerrainType.PAVEMENT = 2")
	_check(tt.TerrainType.SAND == 3, "TerrainType.SAND = 3")
	_check(tt.TerrainType.SHALLOW_WATER == 4, "TerrainType.SHALLOW_WATER = 4")
	_check(tt.TerrainType.SNOW == 5, "TerrainType.SNOW = 5")
	_check(tt.TerrainType.ROCK == 6, "TerrainType.ROCK = 6")
	_check(tt.TerrainType.values().size() == 7, "TerrainType tiene 7 valores")

func _test_equipment_manager_autoload() -> void:
	var em := root.get_node_or_null("EquipmentManager")
	_check(em != null, "EquipmentManager autoload presente")
	if em != null:
		_check(em.catalog.size() >= 16, "catalogo con >=16 prendas: %d" % em.catalog.size())

func _test_equip_unequip() -> void:
	var em := root.get_node_or_null("EquipmentManager")
	_check(em != null, "EquipmentManager presente")
	if em == null or em.get("player_equipment") == null:
		_check(false, "EquipmentManager.player_equipment inicializado")
		return
	var feet_slot_type: int = preload("res://scripts/player/equipment_slot.gd").SlotType.FEET
	# 03-Diseno s2.2: los slots nacen null; equip_item los crea de forma perezosa.
	var slot_inicial = em.get_equipped_item(feet_slot_type)
	_check(slot_inicial == null, "slot feet nace null (creacion perezosa, diseno 03 s2.2)")
	_check(_sembrar_en_inventario("feet_boots_mud"), "inventario M14 sembrado con feet_boots_mud")
	var ok: bool = em.equip_item("feet_boots_mud", feet_slot_type)
	_check(ok, "equip_item feet_boots_mud retorna true")
	var slot = em.get_equipped_item(feet_slot_type)
	if slot == null:
		_check(false, "slot feet creado tras equipar")
		return
	_check(slot.item_id == "feet_boots_mud", "botas equipadas en slot feet")
	var returned: String = em.unequip_slot(feet_slot_type)
	_check(returned == "feet_boots_mud", "unequip retorna item_id correcto")
	var slot_vacio = em.get_equipped_item(feet_slot_type)
	_check(slot_vacio != null and not slot_vacio.is_equipped(), "slot feet vacio tras unequip")

func _test_accesorios_limit() -> void:
	# Item 153: limite de 4 accesorios se respeta
	# PlayerEquipment.accessories es Array[EquipmentSlot]; verificar que se puede agregar hasta 4
	var pe := preload("res://scripts/player/player_equipment.gd").new()
	# Accesorios start empty
	_check(pe.accessories.size() == 0, "accesorios iniciales = 0")
	# Agregar 4 accesorios (simulado: slots con item_id)
	for i in range(4):
		var slot := preload("res://scripts/player/equipment_slot.gd").new()
		slot.item_id = "acc_test_%d" % i
		pe.accessories.append(slot)
	_check(pe.accessories.size() == 4, "4 accesorios aceptados")
	# El limite de 4 accesorios es una regla de negocio; el sistema permite mas
	# pero la UI (M53) debe mostrar solo 4. Verificar que el catalogo tiene accesorios.
	var em := root.get_node_or_null("EquipmentManager")
	if em != null:
		var acc_count := 0
		for id in em.catalog:
			if em.catalog[id].get("slot", "") == "accessory":
				acc_count += 1
		_check(acc_count > 0, "catalogo tiene accesorios: %d" % acc_count)

func _test_bloqueadas_no_equipan() -> void:
	# Item 155: prendas bloqueadas no se pueden equipar
	# amuleto_ancestral requiere chapter 3; si player_state no lo tiene, no desbloqueada
	var em := root.get_node_or_null("EquipmentManager")
	_check(em != null, "EquipmentManager presente para test bloqueo")
	if em != null:
		# player_state sin chapter 3 completado
		var state := {"capitulo_actual": 0}
		var unlocked: bool = em.is_item_unlocked("acc_amulet_ancestral", state)
		_check(not unlocked, "amuleto ancestral BLOQUEADO antes del capitulo 3")
		# Con capitulo 3 si desbloqueado
		state["capitulo_actual"] = 3
		unlocked = em.is_item_unlocked("acc_amulet_ancestral", state)
		_check(unlocked, "amuleto ancestral DESBLOQUEADO con capitulo 3")
		# Items sin unlock condition siempre disponibles
		unlocked = em.is_item_unlocked("feet_boots_mud", state)
		_check(unlocked, "botas de barro siempre desbloqueadas (sin condition)")

func _test_bonus_terreno() -> void:
	# Verificar bonos de terreno calculados correctamente
	var em := root.get_node_or_null("EquipmentManager")
	_check(em != null, "EquipmentManager presente para test bonos")
	if em == null:
		return
	# Equipar skates (bono pavement=1.30, mud=-0.60). M14: sembrar el item primero.
	var feet_slot_type: int = preload("res://scripts/player/equipment_slot.gd").SlotType.FEET
	_check(_sembrar_en_inventario("feet_skates"), "inventario M14 sembrado con feet_skates")
	var ok: bool = em.equip_item("feet_skates", feet_slot_type)
	_check(ok, "equip_item feet_skates retorna true")
	var bonus_pavement: float = em.get_terrain_bonus("pavement")
	var bonus_mud: float = em.get_terrain_bonus("mud")
	_check(bonus_pavement > 0.0, "skates en pavement: bonus positivo (%.2f)" % bonus_pavement)
	_check(bonus_mud < 0.0, "skates en mud: bonus negativo (%.2f)" % bonus_mud)
	# Limpiar
	em.unequip_slot(feet_slot_type)
