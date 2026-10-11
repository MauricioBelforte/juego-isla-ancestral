# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-09
# M18: InteriorCollision — colisiones básicas para habitaciones.
# Crea formas de colisión por habitación (paredes + suelo).
extends Node3D
class_name InteriorCollision

const PARED_GROSOR := 0.25
const PARED_ALTO := 2.5
const HABITACIONES_LIMITE := {
	"living": Vector3(8.0, 3.0, 8.0),
	"dormitorio": Vector3(6.0, 3.0, 6.0),
	"cocina": Vector3(8.0, 3.0, 6.0),
	"taller": Vector3(6.0, 3.0, 8.0),
	"sotano": Vector3(8.0, 2.5, 8.0),
}

var _habitacion_actual: String = ""
var _paredes: Array = []  # BoxMesh/Shape de colisión

## Genera las colisiones de una habitación (paredes + suelo).
func generar_colisiones(habitacion: String) -> int:
	_habitacion_actual = habitacion
	var tam: Vector3 = HABITACIONES_LIMITE.get(habitacion, Vector3(8, 3, 8))
	var count := 0
	# Suelo
	count += _crear_plano(tam)
	# 4 paredes
	count += _crear_paredes(tam)
	return count

## Devuelve la habitación actual.
func obtener_habitacion() -> String:
	return _habitacion_actual

## Devuelve si una posición está dentro de la habitación.
func es_interior(pos: Vector3, habitacion: String = "") -> bool:
	var hab: String = habitacion if habitacion != "" else _habitacion_actual
	var tam: Vector3 = HABITACIONES_LIMITE.get(hab, Vector3(8, 3, 8))
	return pos.x >= -tam.x/2 and pos.x <= tam.x/2 and pos.z >= -tam.z/2 and pos.z <= tam.z/2

## Cantidad de formas de colisión activas.
func cantidad_formas() -> int:
	return _paredes.size()

func _crear_plano(tam: Vector3) -> int:
	var f: BoxShape3D = BoxShape3D.new()
	f.size = Vector3(tam.x, PARED_GROSOR, tam.z)
	_paredes.append(f)
	return 1

func _crear_paredes(tam: Vector3) -> int:
	var count := 0
	for i in range(4):
		var f: BoxShape3D = BoxShape3D.new()
		if i < 2:
			f.size = Vector3(tam.x, PARED_ALTO, PARED_GROSOR)
		else:
			f.size = Vector3(PARED_GROSOR, PARED_ALTO, tam.z)
		_paredes.append(f)
		count += 1
	return count

## Limpia todas las colisiones (para tests).
func limpiar() -> void:
	_paredes.clear()
	_habitacion_actual = ""
