# Modelo: Atria-Dawn-Preview (atria-dawn-s2)
# Plataforma: Kilo Code
# Fecha: 2026-10-11
# M18: House — nodo exterior de una casa: etapa, obra y entrada al interior.
extends Node3D
class_name House

signal puerta_interactuada()
signal interior_abierto(house_id: String)

@export var etapa: int = 1
@export var en_obra: bool = false
@export var progreso_obra: int = 0
@export var parcela_id: String = ""
@export var house_id: String = ""
@export var vecino_id: String = ""

var _puerta_ocupada: bool = false
var _interior_cargado: bool = false

## Devuelve la etapa visual actual (cambia el modelo exterior).
func etapa_actual() -> int:
	return etapa

## ¿La casa está en construcción?
func esta_en_obra() -> bool:
	return en_obra

## Cartel de obra: el jugador sigue pudiendo transitar el mapa (no es sólido).
func cartel_bloquea_mapa() -> bool:
	return false

## Posición de la puerta (entrada al interior).
func obtener_entrada() -> Vector3:
	return global_position + Vector3.FORWARD * 2.0

## El jugador interactúa con la puerta: instancia el interior.
func abrir_interior() -> bool:
	if en_obra:
		return false
	if _puerta_ocupada:
		return false
	_puerta_ocupada = true
	puerta_interactuada.emit()
	interior_abierto.emit(house_id)
	_interior_cargado = true
	return true

## El jugador sale del interior.
func cerrar_interior() -> void:
	_puerta_ocupada = false
	_interior_cargado = false

## ¿El interior está cargado en memoria?
func interior_activo() -> bool:
	return _interior_cargado

## Reubica la casa a otra parcela si hay materiales. `inv` = InventarioService.
func reubicar(nueva_parcela_id: String, coste: Dictionary, inv: Node) -> bool:
	if nueva_parcela_id.is_empty() or nueva_parcela_id == parcela_id:
		return false
	if inv != null and inv.has_method("count_item"):
		for item_id in coste:
			if int(inv.count_item(String(item_id))) < int(coste[item_id]):
				return false
		for item_id in coste:
			inv.remove_item(String(item_id), int(coste[item_id]))
	parcela_id = nueva_parcela_id
	return true

## Estado para guardado (M58/M60).
func recolectar_estado() -> Dictionary:
	return {
		"house_id": house_id,
		"etapa": etapa,
		"en_obra": en_obra,
		"progreso_obra": progreso_obra,
		"parcela_id": parcela_id,
		"vecino_id": vecino_id,
	}

## Restaura el estado desde guardado.
func restaurar_estado(datos: Dictionary) -> void:
	house_id = String(datos.get("house_id", house_id))
	etapa = int(datos.get("etapa", etapa))
	en_obra = bool(datos.get("en_obra", false))
	progreso_obra = int(datos.get("progreso_obra", 0))
	parcela_id = String(datos.get("parcela_id", ""))
	vecino_id = String(datos.get("vecino_id", ""))
