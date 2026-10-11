# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-10
# M53 UI: MuseoSign — cartel de entrada del museo (capa MODAL DOM-UI).
# Muestra get_resumen_para_ui() del CollectionRegistry + toast de exposición completada.
# Consume el backend M37 sin modificarlo.
extends CanvasLayer
class_name MuseoSign

var _collection_registry: Node = null
var _donation_panel: CanvasLayer = null
var _panel: Panel = null
var _titulo: Label = null
var _progreso: Label = null
var _exposiciones: RichTextLabel = null
var _toast: Label = null
var _btn_donar: Button = null
var _visible := false

func _ready() -> void:
	_collection_registry = get_node_or_null("/root/CollectionRegistry")
	_construir_ui()
	visible = false
	# Conectar señal de exposición completada
	if _collection_registry != null and _collection_registry.has_signal("exhibition_completed"):
		_collection_registry.connect("exhibition_completed", _on_exposicion_completada)

func _construir_ui() -> void:
	_panel = Panel.new()
	_panel.set_name("MuseoSign")
	_panel.custom_minimum_size = Vector2(320, 250)
	add_child(_panel)
	
	var vbox := VBoxContainer.new()
	vbox.set_name("Contenido")
	_panel.add_child(vbox)
	
	_titulo = Label.new()
	_titulo.text = "Museo de Aurora"
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.add_theme_font_size_override("font_size", 18)
	vbox.add_child(_titulo)
	
	_progreso = Label.new()
	_progreso.text = ""
	_progreso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_progreso)
	
	_exposiciones = RichTextLabel.new()
	_exposiciones.custom_minimum_size = Vector2(300, 100)
	_exposiciones.bbcode_enabled = true
	_exposiciones.scroll_following = false
	vbox.add_child(_exposiciones)
	
	# Botón "Donar" → abre DonationPanel
	_btn_donar = Button.new()
	_btn_donar.text = "Donar pieza"
	_btn_donar.pressed.connect(_on_donar)
	vbox.add_child(_btn_donar)
	
	# Toast (aparece temporalmente)
	_toast = Label.new()
	_toast.text = ""
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.visible = false
	add_child(_toast)

## Actualiza el cartel con el resumen del museo.
func refrescar() -> void:
	if _collection_registry == null:
		return
	if not _collection_registry.has_method("get_resumen_para_ui"):
		return
	var resumen: Dictionary = _collection_registry.get_resumen_para_ui()
	var total_progreso: float = float(resumen.get("progreso_global", 0.0))
	_progreso.text = "Progreso global: %d%%" % int(total_progreso * 100)
	# Lista de exposiciones
	var expos: Array = resumen.get("exposiciones", [])
	var html := ""
	for ex in expos:
		var id: String = String(ex.get("id", ""))
		var nombre: String = String(ex.get("nombre", id))
		var completada: bool = bool(ex.get("completada", false))
		var progreso_ex: int = int(ex.get("progreso", 0))
		var total_ex: int = int(ex.get("total", 1))
		var icono := "✓" if completada else "○"
		html += "%s %s (%d/%d)\n" % [icono, nombre, progreso_ex, total_ex]
	_exposiciones.text = html

## Muestra un toast temporal (3 segundos).
func mostrar_toast(texto: String) -> void:
	_toast.text = texto
	_toast.visible = true
	get_tree().create_timer(3.0).timeout.connect(func():
		_toast.visible = false
	)

## Devuelve si el cartel está visible.
func esta_visible() -> bool:
	return visible

## Abre el cartel.
func abrir() -> void:
	visible = true
	refrescar()

## Cierra el cartel.
func cerrar() -> void:
	visible = false

## Devuelve el texto de progreso (para tests).
func obtener_progreso() -> String:
	return _progreso.text if _progreso != null else ""

## Devuelve el texto de exposiciones (para tests).
func obtener_exposiciones() -> String:
	return _exposiciones.text if _exposiciones != null else ""

func _on_donar() -> void:
	# Abre el DonationPanel (capa UI hermana)
	if _donation_panel == null:
		var donation_script: Script = load("res://scripts/ui/donation_panel.gd")
		if donation_script != null:
			_donation_panel = (donation_script as GDScript).new()
			get_parent().add_child(_donation_panel)
	if _donation_panel != null:
		_donation_panel.abrir(_obtener_expo_actual())

## Devuelve la exposición actual del cartel (para tests).
func _obtener_expo_actual() -> String:
	if _collection_registry != null and _collection_registry.has_method("get_resumen_para_ui"):
		var resumen: Dictionary = _collection_registry.get_resumen_para_ui()
		var expos: Array = resumen.get("exposiciones", [])
		if expos.size() > 0:
			return String(expos[0].get("id", ""))
	return ""

## Devuelve si el botón donar existe (para tests).
func tener_boton_donar() -> bool:
	return _btn_donar != null

## Devuelve el DonationPanel conectado (para tests).
func obtener_donation_panel() -> CanvasLayer:
	return _donation_panel

func _on_exposicion_completada(exposicion_id: String) -> void:
	var nombre := exposicion_id.to_upper()
	mostrar_toast("¡Exposición completada: " + nombre + "!")
