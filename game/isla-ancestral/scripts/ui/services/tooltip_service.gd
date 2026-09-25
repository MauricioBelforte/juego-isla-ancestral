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
## M87 (Log 1118): si el tooltip se pidió por clave, se guarda para
## re-traducir el visible al cambiar de idioma (sin re-pedir).
var _pending_key: String = ""
var _pending_params: Dictionary = {}
var _active_key: String = ""
var _active_params: Dictionary = {}

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	# Timer para el delay
	_delay_timer = Timer.new()
	_delay_timer.one_shot = true
	_delay_timer.timeout.connect(_on_delay_timeout)
	add_child(_delay_timer)
	# M87 (Log 1118): re-traducción en vivo del tooltip visible por clave
	_conectar_locale()


## ── API pública ─────────────────────────────────────────

## Muestra un tooltip con texto cerca de un control
func show_tooltip(text: String, at: Control, _anchor: Rect2i = Rect2i()) -> void:
	hide_tooltip()
	if text.is_empty():
		return

	_pending_text = text
	_pending_control = at
	_pending_key = ""
	_pending_params = {}
	_delay_timer.start(delay)


## M87 (Log 1118): muestra un tooltip por CLAVE de catálogo (ej "EQUIP.TOOLTIP_QUITAR"),
## resuelta al momento de mostrarse con el locale activo. El texto queda
## re-traducible en vivo: si cambia el idioma con el tooltip visible, se
## re-resuelve la clave (parámetros {item}/{rareza}... conservados).
func show_tooltip_key(clave: String, at: Control, _anchor: Rect2i = Rect2i(), params: Dictionary = {}) -> void:
	if clave.is_empty() or at == null:
		return
	hide_tooltip()
	_pending_key = clave
	_pending_params = params
	_pending_text = ""
	_pending_control = at
	_delay_timer.start(delay)


## Oculta el tooltip actual
func hide_tooltip() -> void:
	_delay_timer.stop()
	_pending_text = ""
	_pending_control = null
	_pending_key = ""
	_pending_params = {}
	_active_key = ""
	_active_params = {}

	if _active_tooltip:
		_active_tooltip.visible = false
		_pool.append(_active_tooltip)
		_active_tooltip = null


## M87 (Log 1118): resuelve el texto de una clave de tooltip con parámetros
## (expuesto para tests y para que otros módulos M53 re-traduzcan).
static func resolver_tooltip_key(clave: String, params: Dictionary = {}) -> String:
	var loc := _find_localization()
	if loc != null and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave, params)
		if res != clave:
			return str(res)
	return clave

static func _find_localization() -> Node:
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		return ((ml as SceneTree).root).get_node_or_null("Localization")
	return null


## Ajusta el delay de mostrado
func set_delay(ms: int) -> void:
	delay = ms / 1000.0


## ── Métodos privados ────────────────────────────────────

## M87 (Log 1118): al cambiar de idioma, re-resuelve el tooltip visible si
## fue pedido por clave (los pedidos por texto plano se conservan: son
## responsabilidad del emisor re-pedirlos).
func _conectar_locale() -> void:
	var loc := _find_localization()
	if loc != null and loc.has_signal("locale_changed"):
		loc.locale_changed.connect(_on_locale_changed)

func _on_locale_changed(_locale: String) -> void:
	# Solo los tooltips pedidos por CLAVE se re-traducen solos. Los pedidos
	# por texto plano (show_tooltip) son responsabilidad del emisor: debe
	# re-pedirlos si quiere ver el idioma nuevo.
	if _active_key.is_empty() or _active_tooltip == null:
		return
	var nuevo := resolver_tooltip_key(_active_key, _active_params)
	var body_label := _active_tooltip.get_node_or_null("VBox/Body")
	if body_label:
		body_label.text = nuevo

func _on_delay_timeout() -> void:
	var text := _pending_text
	var key := _pending_key
	var params := _pending_params
	_pending_text = ""
	_pending_key = ""
	_pending_params = {}
	if key != "":
		# M87 (Log 1118): resolver la clave en el locale activo del momento
		text = resolver_tooltip_key(key, params)
	if text.is_empty() or not _pending_control:
		return

	var tooltip := _get_from_pool()
	# M88: soporte para título y cuerpo separados por "|"
	var parts := text.split("|", true, 1)
	var title_label := tooltip.get_node_or_null("VBox/Title")
	var body_label := tooltip.get_node_or_null("VBox/Body")
	if title_label and body_label:
		if parts.size() >= 2:
			title_label.text = parts[0]
			body_label.text = parts[1]
			title_label.visible = true
		else:
			title_label.visible = false
			body_label.text = text
	elif tooltip.has_node("Label"):
		# Fallback para tooltips legacy
		tooltip.get_node("Label").text = text

	tooltip.visible = true
	tooltip.position = _calculate_position(_pending_control)
	tooltip.size = tooltip.get_minimum_size()

	_active_tooltip = tooltip
	# M87 (Log 1118): si este tooltip se pidió por clave, se guarda para
	# re-traducirlo en vivo al cambiar de idioma.
	_active_key = key
	_active_params = params
	_clamp_to_viewport(tooltip)


## Obtiene un tooltip del pool o crea uno nuevo
func _get_from_pool() -> PanelContainer:
	if not _pool.is_empty():
		return _pool.pop_back()

	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Título (M88: Fredoka One o negrita para títulos)
	var title := Label.new()
	title.name = "Title"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.85, 0.72, 0.35))
	vbox.add_child(title)

	# Cuerpo (M88: Nunito para cuerpo, tamaño legible)
	var body := Label.new()
	body.name = "Body"
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(180, 0)
	body.add_theme_font_size_override("font_size", 12)
	body.add_theme_color_override("font_color", Color(0.92, 0.88, 0.82))
	vbox.add_child(body)

	# Estilo del panel (cozy: esquinas redondeadas, fondo cálido)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.10, 0.94)
	style.border_color = Color(0.6, 0.5, 0.3, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
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
