# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M24: Receptor (puerta) — reacciona cuando su regla se cumple: abre un sello
# (remueve voxels de una "pared" en el VoxelTerrain) para desbloquear el paso.
# Verificable en juego: al completar el puzzle, el sello desaparece.

class_name PuzzlePuerta
extends Node3D

## Posiciones voxel del sello (pared que se rompe al abrir)
var sello: Array = []
## VoxelTerrain donde vive el sello
var terreno: VoxelTerrain = null
## Abierta o no
var abierta: bool = false

@export var canal: int = 0

func configurar(terreno_voxel: VoxelTerrain, posiciones: Array) -> void:
	terreno = terreno_voxel
	sello = posiciones

## Abre la puerta: remueve el sello (una sola escritura de diff)
func abrir() -> void:
	if abierta:
		return
	abierta = true
	if terreno == null:
		print("[M24] Puerta abierta (sin terreno: %d posiciones de sello)" % sello.size())
		return
	var vt := terreno.get_voxel_tool()
	if vt == null:
		return
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	vt.value = 0
	for pos in sello:
		vt.do_point(pos)
	print("[M24] Puerta abierta (%d bloques de sello removidos)" % sello.size())

## Cierra la puerta (re-sella) — para escenarios de re-puzzle
func cerrar() -> void:
	abierta = false
	print("[M24] Puerta cerrada")
