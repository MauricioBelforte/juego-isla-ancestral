# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-11
#
# M155 (item L123): highlight visual de slots con bonos activos para el terreno actual.
# Suite headless (extends SceneTree) del helper puro + de la capa real (EquipmentLayer).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_equipment_highlight_m155.gd

extends SceneTree

const MODULO := "M155-L123-HIGHLIGHT"
const BLOQUES: Array[String] = ["helper_puro", "capa_sin_terreno", "capa_con_terreno"]
## Piso medido en verde (leccion BUG-120/122): la suite aborta en rojo si el conteo baja.
const CHECKS_MINIMOS := 21

const VERDE := Color(0.13, 0.52, 0.18)
const ROJO := Color(0.62, 0.16, 0.16)

var _checks: int = 0
var _fallos: int = 0
var _vistos: Dictionary = {}

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_test_helper_puro()
	_fin("helper_puro")
	_test_capa_sin_terreno()
	_fin("capa_sin_terreno")
	_test_capa_con_terreno()
	_fin("capa_con_terreno")

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
	print("=== TEST M155 HIGHLIGHT: %d checks, %d fallo(s) ===" % [_checks, _fallos])
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

func _sembrar_en_inventario(item_id: String) -> bool:
	var inv := root.get_node_or_null("/root/Inventario")
	if inv != null and inv.has_method("add_item"):
		inv.add_item(item_id, 1)
		return true
	return false

func _nueva_capa() -> Node:
	var capa: Node = load("res://scripts/ui/layers/equipment_layer.gd").new()
	root.add_child(capa)   # dispara _ready() -> _crear_ui() + _manager asignado (sincrono)
	return capa

func _tiene_resaltado(capa: Node, st: int) -> bool:
	var btn: Button = capa._slots_btn.get(st)
	if btn == null:
		return false
	return btn.has_theme_color_override("font_color")

func _color_resaltado(capa: Node, st: int) -> Color:
	var btn: Button = capa._slots_btn.get(st)
	if btn == null:
		return Color(0, 0, 0, 0)
	return btn.get_theme_color("font_color")

## ── Bloque A: helper puro (sin UI) ───────────────────────
func _test_helper_puro() -> void:
	var L: GDScript = load("res://scripts/ui/layers/equipment_layer.gd")
	var equipos: Dictionary = {
		0: {"pavement": 0.30, "mud": -0.60},
		1: {"grass": 0.10},
		2: {},
	}
	# pavement: solo el slot 0
	var r: Array = L.slots_resaltados(equipos, "pavement")
	_check(r == [0], "helper: pavement resalta solo slot 0 (recibido %s)" % [r])
	# mud: bono negativo tambien resalta
	r = L.slots_resaltados(equipos, "mud")
	_check(r == [0], "helper: mud (bono negativo) resalta slot 0 (recibido %s)" % [r])
	# grass: solo el slot 1
	r = L.slots_resaltados(equipos, "grass")
	_check(r == [1], "helper: grass resalta solo slot 1 (recibido %s)" % [r])
	# terreno sin bonos en ningun slot
	r = L.slots_resaltados(equipos, "snow")
	_check(r.is_empty(), "helper: snow (sin bonos) no resalta nada (recibido %s)" % [r])
	# clave vacia -> nunca resalta
	r = L.slots_resaltados(equipos, "")
	_check(r.is_empty(), "helper: clave vacia no resalta nada (recibido %s)" % [r])
	# bono 0.0 explicito no resalta
	r = L.slots_resaltados({0: {"grass": 0.0}}, "grass")
	_check(r.is_empty(), "helper: bono 0.0 no resalta (recibido %s)" % [r])

## ── Bloque B: capa sin terreno (sin highlight) ───────────
func _test_capa_sin_terreno() -> void:
	var capa := _nueva_capa()
	_check(capa._manager != null, "capa: _manager resuelto (/root/EquipmentManager)")
	_check(capa._slots_btn.size() == 4, "capa: 4 slots construidos (%d)" % capa._slots_btn.size())
	capa.forzar_terreno("")
	var st_feet: int = EquipmentSlot.SlotType.FEET
	_check(not _tiene_resaltado(capa, st_feet), "capa: sin terreno -> slot feet sin resaltado")
	_check(capa._clave_terreno_actual() == "", "capa: clave de terreno vacia")
	# Si hubiera un Player real en el arbol, el terreno se resolveria; en headless no hay.
	capa.free()

## ── Bloque C: capa con terreno forzado ───────────────────
func _test_capa_con_terreno() -> void:
	var em := root.get_node_or_null("/root/EquipmentManager")
	_check(em != null, "capa: EquipmentManager presente")
	if em == null:
		return
	var st_feet: int = EquipmentSlot.SlotType.FEET
	# Sembrar + equipar skates (catalogo: pavement:+0.30, mud:-0.60, sand:-0.70)
	_check(_sembrar_en_inventario("feet_skates"), "capa: inventario sembrado con feet_skates")
	var ok: bool = em.equip_item("feet_skates", st_feet)
	_check(ok, "capa: feet_skates equipado")
	var capa := _nueva_capa()
	# pavement -> resaltado VERDE (bono +0.30)
	capa.forzar_terreno("pavement")
	_check(_tiene_resaltado(capa, st_feet), "capa: pavement -> slot feet resaltado")
	_check(_color_resaltado(capa, st_feet).is_equal_approx(VERDE), "capa: pavement -> color VERDE")
	# mud -> resaltado ROJO (bono -0.60)
	capa.forzar_terreno("mud")
	_check(_tiene_resaltado(capa, st_feet), "capa: mud -> slot feet resaltado")
	_check(_color_resaltado(capa, st_feet).is_equal_approx(ROJO), "capa: mud -> color ROJO")
	# grass -> skates NO tiene bono en grass -> sin resaltado
	capa.forzar_terreno("grass")
	_check(not _tiene_resaltado(capa, st_feet), "capa: grass -> slot feet SIN resaltado")
	# limpiar terreno -> sin resaltado
	capa.forzar_terreno("")
	_check(not _tiene_resaltado(capa, st_feet), "capa: terreno limpiado -> sin resaltado")
	# otros slots vacios nunca se resaltan
	var st_head: int = EquipmentSlot.SlotType.HEAD
	capa.forzar_terreno("pavement")
	_check(not _tiene_resaltado(capa, st_head), "capa: slot head vacio nunca resalta")
	# limpieza del estado global
	em.unequip_slot(st_feet)
	_check(em.get_equipped_item(st_feet) == null or not em.get_equipped_item(st_feet).is_equipped(),
		"capa: estado limpiado (feet desequipado)")
	capa.free()
