# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M28: Viajes — EmbarkTrigger (Area3D). Zona de interacción en el muelle.
# Cuando el jugador entra, se muestra el prompt "Hablar con el conserje"
# para abrir la pantalla de viaje (TravelUI) que consume TravelService.
#
# Sin class_name: nodo de escena (pitfall §9.17).

extends Area3D

## ID del Harbor al que pertenece este trigger (M27 vincula isla→harbor).
@export var harbor_id: String = ""

## Texto del prompt (i18n clave, no cadena cruda — M87).
@export var prompt_text: String = "Hablar con el conserje del puerto"

## Zona de activación (collider configurado desde el editor).
var _jugador_dentro: bool = false


func _ready() -> void:
	# Conectar señal de entrada/salida del área.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("[M28/EmbarkTrigger] Cargado en %s (harbor=%s)" % [name, harbor_id])


## Se llama desde TravelUI cuando el jugador confirma la reserva.
func abrir_pantalla_viaje() -> void:
	var ui := get_node_or_null("/root/TravelUI")
	if ui != null and ui.has_method("show_reservation_screen"):
		ui.show_reservation_screen(harbor_id)
	else:
		push_warning("[M28/EmbarkTrigger] TravelUI no encontrado; sin pantalla de reserva.")


# ── Señales de área ────────────────────────────────────────

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_jugador_dentro = true
		# Emitir señal para que M70 (InteractionManager) muestre el prompt.
		_emitar_prompt(true)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_jugador_dentro = false
		_emitar_prompt(false)


func _emitar_prompt(visible: bool) -> void:
	var bus := get_node_or_null("/root/EventBus")
	if bus != null and bus.interaction != null:
		if visible:
			bus.interaction.prompt_visible.emit(name, prompt_text, self)
		else:
			bus.interaction.prompt_hidden.emit(name)


## Consulta si el jugador está dentro del trigger.
func is_player_inside() -> bool:
	return _jugador_dentro
