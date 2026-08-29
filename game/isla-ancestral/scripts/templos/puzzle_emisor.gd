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

func _ready() -> void:
	emisor_id = id
	etiqueta = etiqueta_export

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
