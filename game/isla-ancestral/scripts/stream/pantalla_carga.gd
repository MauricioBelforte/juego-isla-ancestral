# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M63 P1: Pantalla de carga con barra de progreso real (StreamManager).
# - CanvasLayer con barra ColorRect (progreso del StreamManager)
# - Se muestra/oculta con señal carga_iniciada/carga_completada (M40)
# - Usada por SceneManager/Bootstrap
# ⚠️ Sin class_name: autoload (07-GUIA §9.17).

extends CanvasLayer

signal pantalla_oculta

var _barra: ColorRect = null
var _fondo: ColorRect = null
var _texto: Label = null
var _stream: Node = null

func _ready() -> void:
	layer = 100  # por encima de todo
	_construir_ui()
	_conectar_stream()
	ocultar()

func _construir_ui() -> void:
	_fondo = ColorRect.new()
	_fondo.name = "Fondo"
	_fondo.color = Color(0.12, 0.08, 0.06)  # marrón oscuro cozy
	_fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_fondo)

	_barra = ColorRect.new()
	_barra.name = "Barra"
	_barra.color = Color(0.85, 0.65, 0.35)  # ámbar cálido
	_barra.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_barra.position = Vector2(210, 380)
	_barra.size = Vector2(500, 16)
	add_child(_barra)

	_texto = Label.new()
	_texto.name = "Texto"
	_texto.text = "Cargando..."
	_texto.add_theme_font_size_override("font_size", 18)
	_texto.add_theme_color_override("font_color", Color(0.95, 0.90, 0.80))
	_texto.position = Vector2(210, 350)
	add_child(_texto)

func _conectar_stream() -> void:
	_stream = get_node_or_null("/root/StreamManager")
	if _stream == null:
		return
	if _stream.has_signal("progreso_cambiado"):
		_stream.progreso_cambiado.connect(_on_progreso)
	if _stream.has_signal("operacion_completada"):
		_stream.operacion_completada.connect(_on_op_completada)

func _on_progreso(p: float) -> void:
	if not visible:
		return
	_barra.size.x = 500.0 * clampf(p, 0.0, 1.0)

func _on_op_completada(_op_id: String, _tipo: String) -> void:
	if _stream != null and _stream.has_method("progreso"):
		var p: float = float(_stream.progreso())
		_barra.size.x = 500.0 * clampf(p, 0.0, 1.0)
		_texto.text = "Cargando... %d%%" % int(p * 100)

## Muestra la pantalla de carga (llamado por SceneManager/Bootstrap).
func mostrar() -> void:
	visible = true

## Oculta la pantalla (llamado cuando la carga llega al 100%).
func ocultar() -> void:
	visible = false
	pantalla_oculta.emit()
