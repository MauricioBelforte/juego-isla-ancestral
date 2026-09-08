extends Node3D

## Módulo 08/09/10: World Manager — SOLO material y mesher.
##
## ⚠️ M09 iter. (Log 776 — bug raíz encontrado con feedback del usuario
## "las montañas impostoras están sobre el agua"): este script ANTES creaba
## un VoxelGeneratorNoise2D + BlockyLibrary de 2 modelos (aire+cubo) que
## COMPETÍA con el WorldGenerator real (island 10×, biomas) que instala
## main_island.gd. El resultado era un terreno voxel que no coincidía con
## las alturas del generador real (spawn en lóbulo separado por mar,
## montañas impostoras sobre agua).
## FIX: el generador y la librería los instala ÚNICAMENTE main_island.gd
## (_conectar_terreno); este script solo pone el material.

## Referencia al VoxelTerrain (hermano, no hijo)
@onready var terrain: VoxelTerrain = $"../VoxelTerrain"

func _ready() -> void:
	_setup_terrain()
	print("WorldManager: material aplicado (generador lo instala main_island)")

## Solo el material — el generador/mesher/librería los pone main_island.gd
func _setup_terrain() -> void:
	if not terrain:
		print("WorldManager: ERROR - VoxelTerrain no encontrado")
		return

	# 1. Material con vertex color
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	terrain.material_override = mat
	print("WorldManager: Setup completado (solo material — sin generador competidor)")
