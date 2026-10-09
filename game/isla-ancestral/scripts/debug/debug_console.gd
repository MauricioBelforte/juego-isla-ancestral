# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M110-UI slice 2: Consola visual del Debug Menu.
# Consume la API del backend debug_menu.gd (console_get_lines, registrar_evento, etc.).
# No reimplementa lógica de comandos; solo UI.
extends Control
class_name DebugConsole

const CONSOLA_MAX_LINEAS := 100
const CONSOLA_DEFAULT := 50

var _rich_label: RichTextLabel = null
var _input_line: LineEdit = null
var _debug_menu: Node = null
var _lineas: Array[String] = []

func _ready() -> void:
	_debug_menu = get_node_or_null("/root/DebugMenu")
	# Construir UI programática (headless-compatible)
	_rich_label = RichTextLabel.new()
	_rich_label.set_name("Consola")
	_rich_label.bbcode_enabled = true
	_rich_label.scroll_following = true
	_rich_label.custom_minimum_size = Vector2(400, 200)
	add_child(_rich_label)
	
	_input_line = LineEdit.new()
	_input_line.set_name("Entrada")
	_input_line.placeholder_text = "Escribir comando debug..."
	_input_line.custom_minimum_size = Vector2(400, 30)
	add_child(_input_line)
	_input_line.text_submitted.connect(_on_comando_sumbitido)
	
	# Conectar al backend si existe
	if _debug_menu != null:
		if _debug_menu.has_signal("console_line_added"):
			_debug_menu.connect("console_line_added", _on_console_line)
		if _debug_menu.has_method("console_get_lines"):
			var existentes: Array = _debug_menu.console_get_lines()
			for linea in existentes:
				_agregar_linea(str(linea))

func _on_comando_sumbitido(texto: String) -> void:
	if texto.strip_edges().is_empty():
		return
	_input_line.text = ""
	# Ejecutar vía el backend
	if _debug_menu != null and _debug_menu.has_method("ejecutar_comando"):
		var resultado: Variant = _debug_menu.ejecutar_comando(texto)
		if resultado is Dictionary:
			var msg := "→ " + str(resultado.get("comando", texto))
			if resultado.get("ok", false):
				_agregar_linea("[color=green]" + msg + " [ok][/color]")
			else:
				_agregar_linea("[color=red]" + msg + " [error: " + str(resultado.get("error", "")) + "[/color][/color]")
		else:
			_agregar_linea("→ " + texto)
	else:
		_agregar_linea("[color=yellow]Debug Menu no disponible (headless o release)[/color]")

func _on_console_line(texto: String) -> void:
	_agregar_linea(texto)

func _agregar_linea(texto: String) -> void:
	_lineas.append(texto)
	while _lineas.size() > CONSOLA_MAX_LINEAS:
		_lineas.pop_front()
	_refrescar_vista()

func _refrescar_vista() -> void:
	if _rich_label == null:
		return
	var html := ""
	for linea in _lineas:
		html += linea + "\n"
	_rich_label.text = html

## Devuelve las líneas actuales (para tests).
func obtener_lineas() -> Array[String]:
	return _lineas.duplicate()

## Limpia la consola.
func limpiar() -> void:
	_lineas.clear()
	_refrescar_vista()

## Tamano del historial.
func tamano() -> int:
	return _lineas.size()

## Devuelve si el debug menu backend está conectado.
func backend_conectado() -> bool:
	return _debug_menu != null
