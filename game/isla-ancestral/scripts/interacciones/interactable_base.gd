# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M70: Interacciones — InteractableBase (Node3D con auto-registro).
# Clase base opcional para consumidores que quieren delegar el ciclo de vida al
# InteractionManager. NO obligatoria: cualquier nodo puede implementar IInteractable
# y llamar InteractionManager.registrar() manualmente.
# Comportamiento default: register en _ready, unregister en _exit_tree.

class_name InteractableBase
extends Node3D

## Categoria semantica (np | /cof | re /puerta /cosecha /animal /objeto /evento /decorativo).
@export var categoria: StringName = &"objeto"
## Prioridad base (RF5: mayor gana en empate).
@export var prioridad: int = 0
## Radio de deteccion (m). Default 1.5 m (sumado a DEFAULT_RANGO del manager = 4 m).
@export var radio: float = 1.5
## Si true, el nodo se auto-registra al entrar al arbol (default true).
@export var auto_register: bool = true

## Estado del interactuable (RF4 filtro).
var estado: int = 0  # EstadoInteractuable.DISPONIBLE

func _ready() -> void:
	if auto_register:
		var mgr := _get_manager()
		if mgr != null:
			mgr.registrar(self)

func _exit_tree() -> void:
	if auto_register:
		var mgr := _get_manager()
		if mgr != null:
			mgr.desregistrar(self)

## ── Implementacion por defecto del contrato IInteractable ─────

func obtener_estado() -> int:
	return estado

func obtener_categoria() -> StringName:
	return categoria

func obtener_posicion_interaccion() -> Vector3:
	return global_position

func obtener_radio() -> float:
	return radio

func obtener_nombre_prompt() -> String:
	# El consumidor deberia override; default al nombre del nodo.
	return name

func obtener_razon_no_disponible() -> String:
	return ""

func requisitos_cumplidos(_jugador) -> bool:
	return estado == 0  # DISPONIBLE

func interactuar(datos: Dictionary) -> void:
	# Default: delega a interact() legacy si existe en subclase.
	if has_method("interact"):
		call("interact", datos.get("jugador"))

func cancelar_interaccion() -> void:
	pass

func obtener_duracion_esperada() -> float:
	return 0.0

## ── Helpers ────────────────────────────────────────────────────

func _get_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("interacciones")