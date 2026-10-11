# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M155: EquipmentLayer — panel de vestimenta como capa M53 (reemplaza el
# esqueleto roto scripts/ui/equipment_ui.gd que esperaba $Panel/VBox/... sin
# escena). 4 slots + catálogo de prendas con desbloqueo progresivo (UnlockCondition)
# + bono de terreno del equipo. Abre con acción `equipamiento` (E), cierra con
# `equipamiento`/`pausa`. Copia el patrón de InventoryLayer (M53 sección E).

class_name EquipmentLayer
extends UILayer

const _CATALOGO_SLOTS: Array[String] = ["head", "body", "feet", "accessory"]

var _slots_btn: Dictionary = {}        # slot_type(int) -> Button
var _grid: GridContainer
var _bonus_label: Label
var _info_label: Label
var _manager: Node = null
## M155 L123: terreno actual para resaltar slots con bonos ("", = sin datos).
## En runtime se consulta al TerrainDetector del Player; los tests pueden forzarlo.
var _terreno_forzado: String = ""

func _ready() -> void:
	layer_type = UILayerType.Type.MODAL_SIMPLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_crear_ui()
	visible = false
	_manager = get_node_or_null("/root/EquipmentManager")
	if _manager:
		_manager.equipment_changed.connect(_on_equipment_changed)
		_manager.terrain_bonus_updated.connect(_on_terrain_bonus_updated)
	# M87 (Log 1118): al cambiar de idioma, re-generar los textos dinámicos
	# (los estáticos se re-traducen solos vía metadatos text_key + M87)
	_conectar_locale()

## ── Construcción (por código, patrón InventoryLayer) ─────

func _crear_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.4)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.name = "FondoDim"
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.92, 0.86, 0.98)
	sb.border_color = Color(0.72, 0.55, 0.30)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	var titulo := Label.new()
	# M87 (Log 1118): estático → clave + metadato (RetraductorUI lo re-traduce)
	UiI18n.meta_texto(titulo, "EQUIP.TITULO")
	titulo.add_theme_font_size_override("font_size", 26)
	vbox.add_child(titulo)

	_bonus_label = Label.new()
	_bonus_label.text = UiI18n.traducir_param("EQUIP.BONO", {"p": "0"})
	_bonus_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_bonus_label)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_info_label)

	var slots_box := GridContainer.new()
	slots_box.columns = 2
	slots_box.add_theme_constant_override("h_separation", 8)
	slots_box.add_theme_constant_override("v_separation", 6)
	vbox.add_child(slots_box)

	for tipo in _CATALOGO_SLOTS:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(230, 46)
		var st: int = _tipo_a_slot(tipo)
		btn.pressed.connect(_on_slot_clicked.bind(st))
		slots_box.add_child(btn)
		_slots_btn[st] = btn

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var grid_title := Label.new()
	UiI18n.meta_texto(grid_title, "EQUIP.CATALOGO_TITULO")
	grid_title.add_theme_font_size_override("font_size", 15)
	vbox.add_child(grid_title)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(480, 220)
	vbox.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_grid)

	var hint := Label.new()
	UiI18n.meta_texto(hint, "EQUIP.HINT")
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45))
	vbox.add_child(hint)

	_refresh_equipo()

## ── Refresh ─────────────────────────────────────────────

## M87 (Log 1118): los textos DINÁMICOS (parámetros {tipo}/{item}/{p}...) no los
## re-traduce el RetraductorUI global (no pasa parámetros); la capa los re-genera
## ella misma al cambiar de idioma. Los estáticos llevan metadato text_key y
## sí se re-traducen solos.
func _conectar_locale() -> void:
	var loc := get_node_or_null("/root/Localization")
	if loc and loc.has_signal("locale_changed"):
		loc.locale_changed.connect(_on_locale_changed)

func _on_locale_changed(_locale: String) -> void:
	if visible:
		_refresh_equipo()

func _refresh_equipo() -> void:
	if _manager == null:
		return
	var clave_terreno: String = _clave_terreno_actual()
	for tipo in _CATALOGO_SLOTS:
		var st: int = _tipo_a_slot(tipo)
		var btn: Button = _slots_btn.get(st)
		if btn == null:
			continue
		var slot: EquipmentSlot = _manager.get_equipped_item(st)
		var bonos: Dictionary = {}
		if slot != null and slot.is_equipped():
			btn.text = UiI18n.traducir_param("EQUIP.EQUIPADO", {"tipo": tipo.capitalize(), "item": slot.item_name})
			btn.tooltip_text = UiI18n.traducir_param("EQUIP.TOOLTIP_QUITAR", {"item": slot.item_id, "rareza": slot.rarity})
			bonos = slot.terrain_bonuses
		else:
			btn.text = UiI18n.traducir_param("EQUIP.EQUIPADO", {"tipo": tipo.capitalize(), "item": UiI18n.traducir("EQUIP.VACIO")})
			btn.tooltip_text = UiI18n.traducir("EQUIP.TOOLTIP_ELEGIR")
		# L123: resaltar el slot si el item equipado tiene bono para el terreno actual.
		var bono_terreno: float = 0.0
		if clave_terreno != "":
			bono_terreno = float(bonos.get(clave_terreno, 0.0))
		_aplicar_resaltado(btn, bono_terreno)
	var total_bonus := 0.0
	if _manager.has_method("get_terrain_bonus_total"):
		total_bonus = float(_manager.get_terrain_bonus_total())
	elif _manager.get("player_equipment") and _manager.player_equipment.has_method("get_total_terrain_bonus"):
		total_bonus = float(_manager.player_equipment.get_total_terrain_bonus("current"))
	_bonus_label.text = UiI18n.traducir_param("EQUIP.BONO_EQUIPO", {"p": str(int(total_bonus * 100.0))})

	# Grid de prendas con estado de desbloqueo
	for child in _grid.get_children():
		child.queue_free()
	var player_state: Dictionary = {"capitulo_actual": 1, "flags": {}}
	var items: Array = _manager.catalog.keys()
	items.sort()
	for item_id in items:
		var data: Dictionary = _manager.catalog[item_id]
		var desbloqueada: bool = _manager.is_item_unlocked(item_id, player_state)
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(220, 40)
		var nombre: String = String(data.get("name", item_id))
		var rareza: String = String(data.get("rarity", "?"))
		var slot_tipo: String = String(data.get("slot", "?"))
		var desc: String = String(data.get("description", ""))
		var unlock_data: Dictionary = data.get("unlock", {}) as Dictionary
		var req_text := ""
		if not desbloqueada and unlock_data.size() > 0:
			var tipo_req: String = String(unlock_data.get("tipo", ""))
			var valor_req: String = String(unlock_data.get("valor", ""))
			match tipo_req:
				"chapter": req_text = UiI18n.traducir_param("EQUIP.REQ_CAPITULO", {"c": valor_req})
				"flag": req_text = UiI18n.traducir_param("EQUIP.REQ_FLAG", {"c": valor_req})
				_: req_text = UiI18n.traducir_param("EQUIP.REQ", {"c": valor_req})
		btn.text = ("%s — %s (%s)" % [nombre, rareza, item_id]) if desbloqueada else ("🔒 %s (%s)" % [nombre, item_id])
		# Tooltip detallado: nombre, rareza, slot, descripcion, bonos terreno, requisito
		var tooltip_lines := PackedStringArray([nombre, "Rareza: %s" % rareza, "Slot: %s" % slot_tipo, desc])
		var bps: Dictionary = data.get("terrain_bonuses", {}) as Dictionary
		if bps.size() > 0:
			var bonos_txt := "Bonos terreno: "
			for k in bps:
				bonos_txt += "%s+%d%% " % [k, int(bps[k] * 100.0)]
			tooltip_lines.append(bonos_txt)
		if not desbloqueada and req_text != "":
			tooltip_lines.append(req_text)
		btn.tooltip_text = "\n".join(tooltip_lines)
		btn.disabled = not desbloqueada
		btn.pressed.connect(_on_item_pressed.bind(item_id))
		_grid.add_child(btn)
	_info_label.text = UiI18n.traducir_param("EQUIP.PRENDAS", {"n": str(items.size())})

## ── Interacción ──────────────────────────────────────────

func _on_slot_clicked(slot_type: int) -> void:
	if _manager == null:
		return
	var slot = _manager.get_equipped_item(slot_type)
	if slot and slot.is_equipped():
		_manager.unequip_slot(slot_type)
		_refresh_equipo()

func _on_item_pressed(item_id: String) -> void:
	if _manager == null:
		return
	var data: Dictionary = _manager.catalog.get(item_id, {})
	var slot_str: String = data.get("slot", "accessory")
	var result: bool = _manager.equip_item(item_id, _tipo_a_slot(slot_str))
	print("[EquipmentUI] equipar %s -> %s: %s" % [item_id, slot_str, "OK" if result else "rechazado"])
	_refresh_equipo()

func _on_equipment_changed(_slot_type: int, _new_item_id: String) -> void:
	if visible:
		_refresh_equipo()

func _on_terrain_bonus_updated(_total: float) -> void:
	if visible:
		_refresh_equipo()

## ── L123: highlight por terreno actual ───────────────────

## Fija el terreno actual sin necesitar un Player/terreno real (hook de test).
func forzar_terreno(clave: String) -> void:
	_terreno_forzado = clave
	_refresh_equipo()

## Clave de terreno actual ("" si no hay datos). Runtime: TerrainDetector del Player.
func _clave_terreno_actual() -> String:
	if _terreno_forzado != "":
		return _terreno_forzado
	var tid: int = _terreno_id_actual()
	if tid < 0:
		return ""
	return TerrainModifiers.clave_terreno_m155(tid)

## terrain_id actual del jugador (-1 si no hay detector).
func _terreno_id_actual() -> int:
	var jugadores := get_tree().get_nodes_in_group("player")
	if jugadores.is_empty():
		return -1
	var jugador: Node = jugadores[0]
	var det: Node = jugador.get_node_or_null("TerrainDetector")
	if det != null and det.has_method("get_current_terrain_id"):
		return int(det.call("get_current_terrain_id"))
	return -1

## Slots (slot_type) cuyo item tiene bono != 0 para el terreno dado.
## Puro/estatico -> testeable headless sin UI. `equipos`: {slot_type: terrain_bonuses}.
static func slots_resaltados(equipos: Dictionary, clave: String) -> Array:
	var out: Array = []
	if clave == "":
		return out
	for st in equipos.keys():
		var b: Variant = equipos[st]
		if b is Dictionary and absf(float((b as Dictionary).get(clave, 0.0))) > 0.0001:
			out.append(st)
	return out

## Aplica/quita el color de resaltado segun el bono (0 = sin resaltado).
func _aplicar_resaltado(btn: Button, bono: float) -> void:
	if is_zero_approx(bono):
		btn.remove_theme_color_override("font_color")
		return
	var color := Color(0.13, 0.52, 0.18) if bono > 0.0 else Color(0.62, 0.16, 0.16)
	btn.add_theme_color_override("font_color", color)

func _tipo_a_slot(tipo: String) -> int:
	match tipo:
		"head":
			return EquipmentSlot.SlotType.HEAD
		"body":
			return EquipmentSlot.SlotType.BODY
		"feet":
			return EquipmentSlot.SlotType.FEET
		_:
			return EquipmentSlot.SlotType.ACCESSORY

## ── Ciclo de capa ────────────────────────────────────────

func toggle() -> void:
	visible = not visible
	if visible:
		_refresh_equipo()
		focus_first()

func on_layer_opened() -> void:
	_refresh_equipo()

func on_layer_closed() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("equipamiento") or event.is_action_pressed("pausa"):
		visible = false
		get_viewport().set_input_as_handled()
