extends CanvasLayer
class_name TooltipService_
## Servicio de tooltips con pool y delay configurable
##
## Muestra tooltips contextuales al hover de ratón o foco de teclado.
## Pool único de nodos para evitar allocaciones en caliente.
## Clamp de posición al viewport con margen de 8px.

## ── Configuración ───────────────────────────────────────
## Retardo antes de mostrar (segundos)
@export var delay: float = 0.35

## ── Pool de nodos tooltip ────────────────────────────────
var _pool: Array[PanelContainer] = []
var _active_tooltip: PanelContainer = null
var _delay_timer: Timer = null
var _pending_text: String = ""
var _pending_control: Control = null

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	# Timer para el delay
	_delay_timer = Timer.new()
	_delay_timer.one_shot = true
	_delay_timer.timeout.connect(_on_delay_timeout)
	add_child(_delay_timer)


## ── API pública ─────────────────────────────────────────

## Muestra un tooltip con texto cerca de un control
func show_tooltip(text: String, at: Control, _anchor: Rect2i = Rect2i()) -> void:
	hide_tooltip()
	if text.is_empty():
		return

	_pending_text = text
	_pending_control = at
	_delay_timer.start(delay)


## Oculta el tooltip actual
func hide_tooltip() -> void:
	_delay_timer.stop()
	_pending_text = ""
	_pending_control = null

	if _active_tooltip:
		_active_tooltip.visible = false
		_pool.append(_active_tooltip)
		_active_tooltip = null


## Ajusta el delay de mostrado
func set_delay(ms: int) -> void:
	delay = ms / 1000.0


## ── Métodos privados ────────────────────────────────────

func _on_delay_timeout() -> void:
	if _pending_text.is_empty() or not _pending_control:
		return

	var tooltip := _get_from_pool()
	tooltip.get_node("Label").text = _pending_text
	tooltip.visible = true
	tooltip.position = _calculate_position(_pending_control)
	tooltip.size = tooltip.get_minimum_size()

	_active_tooltip = tooltip
	_clamp_to_viewport(tooltip)


## Obtiene un tooltip del pool o crea uno nuevo
func _get_from_pool() -> PanelContainer:
	if not _pool.is_empty():
		return _pool.pop_back()

	var panel := PanelContainer.new()
	var label := Label.new()
	label.name = "Label"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(200, 0)
	panel.add_child(label)

	# Estilo básico (se aplicará desde ThemeUx cuando esté disponible)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.10, 0.08, 0.92)
	style.border_color = Color(0.6, 0.5, 0.3, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)

	add_child(panel)
	return panel


## Calcula la posición del tooltip cerca del control
func _calculate_position(control: Control) -> Vector2:
	var rect := control.get_global_rect()
	var vp_size := get_viewport().get_visible_rect().size

	var pos := Vector2(rect.position.x, rect.end.y + 4)

	# Si no cabe abajo, arriba
	if pos.y + 60 > vp_size.y:
		pos.y = rect.position.y - 64

	return pos


## Ajusta la posición para que nunca salga del viewport
func _clamp_to_viewport(node: Control) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var margin := 8.0

	if node.position.x + node.size.x > vp_size.x - margin:
		node.position.x = vp_size.x - node.size.x - margin
	if node.position.y + node.size.y > vp_size.y - margin:
		node.position.y = vp_size.y - node.size.y - margin
	if node.position.x < margin:
		node.position.x = margin
	if node.position.y < margin:
		node.position.y = margin
