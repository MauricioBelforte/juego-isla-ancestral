# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: HouseInterior — escena interior con habitaciones desbloqueables por etapa.
extends Node3D
class_name HouseInterior

signal interior_listo()
signal interior_cerrado()

var habitaciones: Array = []

## Carga las habitaciones iniciales (etapa 1: solo living).
func _init() -> void:
	habitaciones = ["living"]

## El jugador entra: desbloquea las habitaciones de su etapa.
func entrar(etapa: int) -> void:
	habitaciones = _habitaciones_por_etapa(etapa)
	interior_listo.emit()

## El jugador sale del interior.
func salir() -> void:
	interior_cerrado.emit()

## Devuelve las habitaciones desbloqueadas.
func obtener_habitaciones() -> Array:
	return habitaciones

## ¿La habitación está desbloqueada?
func habitacion_desbloqueada(nombre: String) -> bool:
	return habitaciones.has(nombre)

## Añade habitaciones (mejora de etapa, granjas, etc.).
func agregar_habitaciones(ids: Array) -> void:
	for id in ids:
		var sid: String = String(id)
		if not sid.is_empty() and not habitaciones.has(sid):
			habitaciones.append(sid)

## Desbloquea las habitaciones correspondientes a una etapa.
func desbloquear_etapa(etapa: int) -> void:
	habitaciones = _habitaciones_por_etapa(etapa)

## Mapeo etapa -> habitaciones (M18 03-Diseno §3).
func _habitaciones_por_etapa(etapa: int) -> Array:
	var base: Array = ["living"]
	match etapa:
		1:
			return base
		2:
			return base + ["dormitorio"]
		3:
			return base + ["dormitorio", "cocina"]
		4:
			return base + ["dormitorio", "cocina", "taller"]
		5:
			return base + ["dormitorio", "cocina", "taller", "sotano", "atico"]
	return base

## Estado para guardado (M58/M60).
func recolectar_estado() -> Dictionary:
	return {"habitaciones": habitaciones.duplicate()}

## Restaura el estado desde guardado.
func restaurar_estado(datos: Dictionary) -> void:
	var arr: Array = datos.get("habitaciones", [])
	habitaciones.clear()
	for h in arr:
		habitaciones.append(String(h))
