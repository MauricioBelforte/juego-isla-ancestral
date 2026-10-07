# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M24: Emisor de puzzle — recibe accion del jugador (golpe de herramienta, peso,
# senal de un conector) y actualiza el estado de la sala a la que pertenece.
# Sin UI ni autoloads: se instancia en la escena del templo.

class_name PuzzleEmisor
extends Node3D

## Id del emisor dentro de su PuzzleRoom
var emisor_id: int = 0
## Etiqueta informativa (debug)
var etiqueta: String = ""
## Valor actual
var activado: bool = false
## PuzzleRoom al que pertenece (asignado por la sala)
var sala: PuzzleRoom = null

@export var id: int = 0
@export var etiqueta_export: String = ""

## M24 iter. 1 (DeepSeek-V4.1-Flash): umbral de peso para placas (items 75/76).
## 0 = emisor de accion directa (palanca/golpe). >0 = placa: se activa cuando el
## peso encima alcanza el umbral (1 = jugador / peso dinamico; 3 = caja / estatico).
var umbral_peso: int = 0
@export var umbral_peso_export: int = 0

func _ready() -> void:
	emisor_id = id
	etiqueta = etiqueta_export
	umbral_peso = umbral_peso_export

## El jugador golpea el emisor con una herramienta (M13) — alterna el estado
func recibir_golpe() -> void:
	activado = not activado
	if sala != null:
		sala.set_emisor(emisor_id, activado)
	print("[M24] Emisor '%s' (id %d) -> %s" % [etiqueta, emisor_id, "ON" if activado else "OFF"])

## Una placa se activa por peso (jugador o bloque encima)
func set_activo(valor: bool) -> void:
	activado = valor
	if sala != null:
		sala.set_emisor(emisor_id, activado)

## M24 iter. 1 (DeepSeek-V4.1-Flash): peso encima de la placa. Se activa si el peso
## alcanza `umbral_peso` (si el umbral es 0, basta con peso > 0). Actualiza la sala.
func recibir_peso(peso: int) -> void:
	if umbral_peso > 0:
		activado = peso >= umbral_peso
	else:
		activado = peso > 0
	if sala != null:
		sala.set_emisor(emisor_id, activado)
