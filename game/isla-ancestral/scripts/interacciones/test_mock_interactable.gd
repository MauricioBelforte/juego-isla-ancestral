# Modelo: minimax-m3-free
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M70: Test Mock IInteractable.
# Implementacion completa del contrato ampliado (M70) sobre Node3D.
# Usado SOLO en tests headless.

extends Node3D
class_name _MockInteractable  # no global; cargado via load("res://...")

# Configuracion via campos publicos (asignados por el test antes de anyadir al arbol)
var mock_id: String = ""
var mock_pos: Vector3 = Vector3.ZERO
var mock_prioridad: int = 0
var mock_categoria: StringName = &""
var mock_estado: int = 0
var mock_radio: float = 0.5
var mock_duracion: float = 0.0

# Conteo de interacciones recibidas (para asserts)
var mock_interacciones_recibidas: int = 0
var mock_ultimo_datos: Dictionary = {}

func obtener_estado() -> int:
	return mock_estado

func obtener_categoria() -> StringName:
	return mock_categoria

func obtener_posicion_interaccion() -> Vector3:
	return mock_pos

func obtener_radio() -> float:
	return mock_radio

func obtener_nombre_prompt() -> String:
	return mock_id

func obtener_razon_no_disponible() -> String:
	return ""

func requisitos_cumplidos(_jugador) -> bool:
	return mock_estado == 0

func interactuar(datos: Dictionary) -> void:
	mock_interacciones_recibidas += 1
	mock_ultimo_datos = datos.duplicate()

func cancelar_interaccion() -> void:
	pass

func obtener_duracion_esperada() -> float:
	return mock_duracion

# Compatibilidad con el contrato v1 (legacy)
func interact(_interactor) -> bool:
	mock_interacciones_recibidas += 1
	return true

func get_interaction_prompt(_interactor) -> String:
	return mock_id

func is_interactable(_interactor) -> bool:
	return mock_estado == 0

func get_interaction_priority() -> int:
	return mock_prioridad

func get_interaction_range() -> float:
	return mock_radio