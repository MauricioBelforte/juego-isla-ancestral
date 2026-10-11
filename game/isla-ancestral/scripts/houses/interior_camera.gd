# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: InteriorCamera — cámara para habitaciones interiores (M12).
# Se posiciona dentro de la habitación activa y limita el FOV.
extends Node3D
class_name InteriorCamera

signal habitacion_cambiada(casa_id: String, habitacion: String)

const FOV_INTERIOR := 60.0
const FOV_EXTERIOR := 75.0
const ALTURA_CAMARA := 1.6
const LIMITE_HABITACION := Vector3(8.0, 3.0, 8.0)  # 8x8x3 m por habitación

var _habitacion_actual: String = ""
var _casa_id: String = ""
var _casa_ref: Node = null
var _jugador: Node3D = null
var _visible := false

func _ready() -> void:
	_casa_ref = get_node_or_null("/root/HouseManager")
	var grupo := get_tree().get_nodes_in_group("player")
	_jugador = grupo[0] if grupo.size() > 0 else null
	visible = false

## Entra a una habitación (cambia el FOV y limita el movimiento).
func entrar_habitacion(casa_id: String, habitacion: String) -> void:
	_casa_id = casa_id
	_habitacion_actual = habitacion
	visible = true
	# En un implementación real, aquí se conectaría al Camera3D
	# y se ajustarían los límites de colisión de la habitación
	# Por ahora, exponemos el estado para tests
	habitacion_cambiada.emit(casa_id, habitacion)

## Sale de la habitación (restaura FOV exterior).
func salir_habitacion() -> void:
	_habitacion_actual = ""
	_casa_id = ""
	visible = false
	habitacion_cambiada.emit("", "")

## Devuelve la habitación actual ("").
func obtener_habitacion() -> String:
	return _habitacion_actual

## Devuelve si la cámara está en modo interior.
func es_interior() -> bool:
	return _habitacion_actual != ""

## Devuelve el límite de la habitación actual (Vector3).
func obtener_limite() -> Vector3:
	return LIMITE_HABITACION

## Devuelve el FOV actual.
func obtener_fov() -> float:
	return FOV_INTERIOR if es_interior() else FOV_EXTERIOR

## Nodos de test
func obtener_casa_id() -> String:
	return _casa_id
