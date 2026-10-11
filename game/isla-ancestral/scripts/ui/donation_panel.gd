# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-10
# M53 UI: DonationPanel — panel de donación al museo (capa MODAL DOM-UI).
# Consume el backend M37 (CollectionRegistry, DonationService, Museum) sin modificarlo.
# Regla §9: la UI llama al manager, no implementa lógica.
extends CanvasLayer
class_name DonationPanel

var _collection_registry: Node = null
var _donation_service: Node = null
var _museo: Node = null
var _panel: Panel = null
var _titulo: Label = null
var _lista_items: ItemList = null
var _info_item: Label = null
var _btn_donar: Button = null
var _btn_cerrar: Button = null
var _mensaje: Label = null
var _exposicion_actual: String = ""
var _item_seleccionado: String = ""

func _ready() -> void:
	_collection_registry = get_node_or_null("/root/CollectionRegistry")
	_donation_service = get_node_or_null("/root/DonationService")
	_museo = get_node_or_null("/root/Museum")
	_construir_ui()
	visible = false

func _construir_ui() -> void:
	_panel = Panel.new()
	_panel.set_name("DonationPanel")
	_panel.custom_minimum_size = Vector2(400, 350)
	add_child(_panel)
	
	var vbox := VBoxContainer.new()
	vbox.set_name("Contenido")
	_panel.add_child(vbox)
	
	_titulo = Label.new()
	_titulo.text = "Museo — Donaciones"
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_titulo)
	
	_mensaje = Label.new()
	_mensaje.text = ""
	_mensaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_mensaje)
	
	# Lista de items donables
	var lbl_lista := Label.new()
	lbl_lista.text = "Items donables:"
	vbox.add_child(lbl_lista)
	
	_lista_items = ItemList.new()
	_lista_items.custom_minimum_size = Vector2(380, 120)
	_lista_items.item_selected.connect(_on_item_seleccionado)
	vbox.add_child(_lista_items)
	
	_info_item = Label.new()
	_info_item.text = ""
	vbox.add_child(_info_item)
	
	# Botones
	var hbox := HBoxContainer.new()
	hbox.set_name("Botones")
	vbox.add_child(hbox)
	
	_btn_donar = Button.new()
	_btn_donar.text = "Donar"
	_btn_donar.disabled = true
	_btn_donar.pressed.connect(_on_donar)
	hbox.add_child(_btn_donar)
	
	_btn_cerrar = Button.new()
	_btn_cerrar.text = "Cerrar"
	_btn_cerrar.pressed.connect(_on_cerrar)
	hbox.add_child(_btn_cerrar)

## Abre el panel para una exposición específica.
func abrir(exposicion_id: String) -> void:
	_exposicion_actual = exposicion_id
	_titulo.text = "Museo — Donar a: " + exposicion_id.to_upper()
	_lista_items.clear()
	_mensaje.text = ""
	_btn_donar.disabled = true
	# Cargar items donables
	if _collection_registry != null and _collection_registry.has_method("donables_pendientes"):
		var donables: Array = _collection_registry.donables_pendientes(exposicion_id)
		for item_id in donables:
			_lista_items.add_item(String(item_id))
		if donables.is_empty():
			_mensaje.text = "No hay items donables para esta exposición."
	visible = true

## Cierra el panel.
func cerrar() -> void:
	visible = false

## Devuelve si el panel está visible.
func esta_visible() -> bool:
	return visible

## Devuelve la exposición actual.
func obtener_exposicion() -> String:
	return _exposicion_actual

## Devuelve el item seleccionado.
func obtener_item_seleccionado() -> String:
	return _item_seleccionado

## Devuelve el mensaje actual (para tests).
func obtener_mensaje() -> String:
	return _mensaje.text if _mensaje != null else ""

func _on_item_seleccionado(idx: int) -> void:
	var item_id: String = _lista_items.get_item_text(idx)
	_item_seleccionado = item_id
	_info_item.text = "Seleccionado: " + item_id
	_btn_donar.disabled = false

func _on_donar() -> void:
	if _item_seleccionado.is_empty() or _exposicion_actual.is_empty():
		return
	if _donation_service != null and _donation_service.has_method("donate"):
		var resultado: Dictionary = _donation_service.donate(_exposicion_actual, _item_seleccionado)
		if bool(resultado.get("ok", false)):
			_mensaje.text = "¡Gracias! Donaste: " + _item_seleccionado
			# Quitar de la lista (último item seleccionado)
			if _lista_items.get_item_count() > 0:
				_lista_items.remove_item(_lista_items.get_item_count() - 1)
			_item_seleccionado = ""
			_btn_donar.disabled = true
		else:
			var motivo: String = str(resultado.get("motivo", "desconocido"))
			_mensaje.text = "Rechazado: " + motivo
	else:
		_mensaje.text = "DonationService no disponible"

func _on_cerrar() -> void:
	visible = false
