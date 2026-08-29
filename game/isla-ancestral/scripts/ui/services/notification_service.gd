extends CanvasLayer
class_name NotificationService_
## Servicio de notificaciones toast con cola y tipos
##
## Muestra notificaciones temporales (obtención, evento, misión)
## con icono, texto y SFX. Cola de máximo 3 visibles.
## Fade 0.3s, vida 4s, desplazamiento vertical automático.

## ── Configuración ───────────────────────────────────────
## Máximo de toasts visibles simultáneamente
@export var max_active: int = 3
## Duración del toast antes de desaparecer (segundos)
@export var toast_lifetime: float = 4.0
## Duración del fade in/out (segundos)
@export var fade_duration: float = 0.3

## ── Estado ──────────────────────────────────────────────
## Cola de toasts activos
var _active: Array[Dictionary] = []
## Cola de toasts pendientes (cuando se supera el máximo)
var _queue: Array[Dictionary] = []

## ── Tipo de toast ───────────────────────────────────────
enum ToastType { ITEM, EVENT, QUEST }

## ── Ciclo de vida ──────────────────────────────────────

func _ready() -> void:
	pass


## ── API pública ─────────────────────────────────────────

## Agrega un toast a la cola
func push(toast: Dictionary) -> void:
	# toast: { text: String, type: ToastType, icon: String (opcional) }
	if _active.size() >= max_active:
		_dequeue_oldest()

	_active.append(toast)
	_spawn_node(toast)


## Limpia todos los toasts
func clear_all() -> void:
	for toast in _active:
		if toast.node and is_instance_valid(toast.node):
			toast.node.queue_free()
	_active.clear()
	_queue.clear()


## Ajusta el límite de la cola
func set_queue_limit(n: int) -> void:
	max_active = n


## ── Métodos privados ────────────────────────────────────

## Crea el nodo visual del toast
func _spawn_node(toast: Dictionary) -> void:
	var text: String = toast.get("text", "")
	var type: ToastType = toast.get("type", ToastType.EVENT)

	# Crear panel
	var panel := PanelContainer.new()
	panel.name = "Toast_%d" % _active.size()

	# Layout horizontal
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	panel.add_child(hbox)

	# Icono (placeholder)
	var icon_label := Label.new()
	icon_label.text = _get_type_icon(type)
	hbox.add_child(icon_label)

	# Texto
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(200, 0)
	hbox.add_child(label)

	# Estilo
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.10, 0.9)
	style.border_color = _get_type_color(type)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)

	add_child(panel)
	toast.node = panel

	# Posicionar arriba-derecha
	_position_toast(panel, _active.size() - 1)

	# Fade in
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, fade_duration).from(0.0)

	# Auto-remover después de lifetime
	await get_tree().create_timer(toast_lifetime).timeout
	_remove_toast(toast)


## Remueve el toast más antiguo
func _dequeue_oldest() -> void:
	if _active.is_empty():
		return
	var oldest: Dictionary = _active.pop_front()
	if oldest.node and is_instance_valid(oldest.node):
		# Fade out
		var tween := create_tween()
		tween.tween_property(oldest.node, "modulate:a", 0.0, fade_duration)
		tween.tween_callback(oldest.node.queue_free)


## Remueve un toast específico
func _remove_toast(toast: Dictionary) -> void:
	var idx := _active.find(toast)
	if idx != -1:
		_active.remove_at(idx)

	if toast.node and is_instance_valid(toast.node):
		var tween := create_tween()
		tween.tween_property(toast.node, "modulate:a", 0.0, fade_duration)
		tween.tween_callback(toast.node.queue_free)

	# Reposicionar toasts restantes
	_reposition_all()


## Reposiciona todos los toasts visibles
func _reposition_all() -> void:
	for i in range(_active.size()):
		if _active[i].node and is_instance_valid(_active[i].node):
			_position_toast(_active[i].node, i)


## Calcula la posición de un toast
func _position_toast(node: Control, index: int) -> void:
	var vp_size := get_viewport().get_visible_rect().size
	var margin := 16.0
	var spacing := 8.0

	var y_offset := margin + index * (node.size.y + spacing)
	node.position = Vector2(vp_size.x - node.size.x - margin, y_offset)


## Devuelve el icono según el tipo de toast
func _get_type_icon(type: ToastType) -> String:
	match type:
		ToastType.ITEM: return "📦"
		ToastType.EVENT: return "🔔"
		ToastType.QUEST: return "📋"
	return "💬"


## Devuelve el color del borde según el tipo
func _get_type_color(type: ToastType) -> Color:
	match type:
		ToastType.ITEM: return Color(0.4, 0.7, 0.4, 1.0)  # Verde suave
		ToastType.EVENT: return Color(0.7, 0.6, 0.3, 1.0)  # Dorado suave
		ToastType.QUEST: return Color(0.4, 0.5, 0.7, 1.0)  # Azul suave
	return Color(0.5, 0.5, 0.5, 1.0)
