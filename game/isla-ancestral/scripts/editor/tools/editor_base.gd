# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M109: EditorBase — base común de editores internos (panel dock data-driven).
# Patrón: lista de entradas + formulario + guardado con backup (.bak) + reportes.
# Los editores concretos extienden esta clase (M109 RF1: 14 editores).

@tool
extends PanelContainer

const MARGEN_BACKUP := "M109"

var _items: Array[String] = []
var _selector: OptionButton
var _campos: Dictionary = {}
var _form_box: VBoxContainer
var _ruta_datos: String = ""
var _items_cargados: Callable
var _campos_form: Callable
var _guardado: Callable

func _ready() -> void:
	custom_minimum_size = Vector2(420, 320)
	var vbox := VBoxContainer.new()
	add_child(vbox)

	var titulo := Label.new()
	titulo.text = "Herramientas internas — M109"
	vbox.add_child(titulo)

	_selector = OptionButton.new()
	_selector.item_selected.connect(_on_selector)
	vbox.add_child(_selector)

	var botones := HBoxContainer.new()
	var btn_nuevo := Button.new()
	btn_nuevo.text = "+ Nueva"
	btn_nuevo.pressed.connect(_nueva_entrada)
	var btn_guardar := Button.new()
	btn_guardar.text = "Guardar"
	btn_guardar.pressed.connect(_guardar_entrada)
	var btn_borrar := Button.new()
	btn_borrar.text = "Borrar"
	btn_borrar.pressed.connect(_borrar_entrada)
	botones.add_child(btn_nuevo)
	botones.add_child(btn_guardar)
	botones.add_child(btn_borrar)
	vbox.add_child(botones)

	_form_box = VBoxContainer.new()
	vbox.add_child(_form_box)

	var estado := Label.new()
	estado.name = "Estado"
	estado.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	vbox.add_child(estado)

## Configura el editor (llamado por el plugin).
func configurar(editor_nombre: String, ruta_datos: String, items_cargados: Callable, campos_form: Callable, guardado: Callable) -> void:
	name = editor_nombre
	_ruta_datos = ruta_datos
	_items_cargados = items_cargados
	_campos_form = campos_form
	_guardado = guardado
	var titulo: Label = get_node("VBoxContainer" if false else "") if get_node_or_null("") else null
	recargar()

func recargar() -> void:
	if not _items_cargados.is_valid():
		return
	_selector.clear()
	_items = _items_cargados.call()
	for item in _items:
		_selector.add_item(item)
	if _items.size() > 0:
		_render_form(_items[0])

func _on_selector(indice: int) -> void:
	if indice >= 0 and indice < _items.size():
		_render_form(_items[indice])

func _render_form(item_id: String) -> void:
	for child in _form_box.get_children():
		child.queue_free()
	_campos = _campos_form.call(item_id)  # nombre -> [valor, editable]
	for campo in _campos:
		var fila := HBoxContainer.new()
		var label := Label.new()
		label.text = campo
		label.custom_minimum_size = Vector2(130, 0)
		fila.add_child(label)
		var edit := LineEdit.new()
		edit.name = campo
		edit.text = str(_campos[campo][0])
		edit.editable = bool(_campos[campo][1])
		fila.add_child(edit)
		_form_box.add_child(fila)

func _nueva_entrada() -> void:
	_estado_msg("Nueva entrada — completa los campos y Guardar (el ID se pide en el campo id)")

func _guardar_entrada() -> void:
	if not _guardado.is_valid():
		return
	var valores := {}
	for campo in _campos:
		var edit: LineEdit = _form_box.get_node_or_null(campo)
		if edit:
			valores[campo] = edit.text
	var res := _guardado.call(valores)
	_estado_msg(str(res))

func _borrar_entrada() -> void:
	_estado_msg("Borrar: hazlo desde el editor concreto (ver RecipeTool.borrar)")

func _estado_msg(msg: String) -> void:
	var estado: Label = get_node_or_null("Estado") if false else null
	var e := find_child("Estado", true, false)
	if e:
		e.text = msg
