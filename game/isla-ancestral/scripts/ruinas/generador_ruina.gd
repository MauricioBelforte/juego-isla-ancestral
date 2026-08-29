# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29
#
# M25: Ruina pequena y legible (tipo chocavil, banda Exploracion) construida con
# voxels sobre el mundo, con 1 puzzle de placa->puerta (framework M24). Verificable
# con vision (captura in-engine): estructura rota y legible + puerta que se abre.

class_name RuinaChozavil
extends Node3D

const B_PIEDRA := 3
const B_ARENA := 5
const B_MADERA := 7
const B_TIERRA := 1
const B_AIRE := 0

var _terreno: VoxelTerrain = null
var _sala: PuzzleRoom = null
var _puerta: PuzzlePuerta = null
var _placa: Area3D = null
var _sello_pos: Array = []

@export var base: Vector3 = Vector3(16, 9, 68)

func _ready() -> void:
	_terreno = _buscar_terreno()
	if _terreno == null:
		push_error("[M25] No se encontro VoxelTerrain")
		return
	_sala = PuzzleRoom.new([0])
	_sala.add_regla([0], "puerta")
	_construir_ruina()
	_crear_placa()
	_crear_puerta()
	print("[M25] Chozavil ruina construida en %s" % str(base))

func _construir_ruina() -> void:
	var vt := _terreno.get_voxel_tool()
	if vt == null:
		return
	vt.channel = VoxelBuffer.CHANNEL_TYPE
	var b: Vector3i = Vector3i(base)
	# sello (alcoba sellada): 4 bloques de piedra en el interior, detras de la placa
	_sello_pos = [
		Vector3i(b.x, b.y + 1, b.z + 2),
		Vector3i(b.x, b.y + 1, b.z + 3),
		Vector3i(b.x + 1, b.y + 1, b.z + 2),
		Vector3i(b.x + 1, b.y + 1, b.z + 3),
	]
	# muros de piedra rotos: 3 lados (pared oeste, sur, este) con vano (puerta) y hueco (muro roto)
	for dz in range(-2, 3):
		_pone(vt, Vector3i(b.x - 1, b.y, b.z + dz), B_PIEDRA)   # pared oeste
		_pone(vt, Vector3i(b.x + 1, b.y, b.z + dz), B_PIEDRA)   # pared este
	for dx in range(-1, 2):
		_pone(vt, Vector3i(b.x + dx, b.y, b.z - 2), B_PIEDRA)   # pared sur
	# muro roto (arena) en la parte alta: hueco visible
	_pone(vt, Vector3i(b.x, b.y, b.z + 2), B_AIRE)             # vano/puerta (oeste)
	_pone(vt, Vector3i(b.x + 1, b.y, b.z - 2), B_AIRE)         # hueco del muro roto (este)
	# columna rota (madera) sobresaliendo
	_pone(vt, Vector3i(b.x - 1, b.y + 1, b.z), B_MADERA)
	# piso de losas de arena dentro
	for dz in range(-1, 2):
		for dx in range(-1, 1):
			_pone(vt, Vector3i(b.x + dx, b.y - 1, b.z + dz), B_ARENA)
	# pequeno monticulo de tierra derrumbada al exterior
	_pone(vt, Vector3i(b.x + 2, b.y, b.z + 1), B_TIERRA)

func _pone(vt: VoxelTool, pos: Vector3i, value: int) -> void:
	vt.value = value
	vt.do_point(pos)

func _crear_placa() -> void:
	_placa = Area3D.new()
	_placa.name = "Placa"
	var col := CollisionShape3D.new()
	var forma := BoxShape3D.new()
	forma.size = Vector3(2, 2, 2)
	col.shape = forma
	_placa.add_child(col)
	add_child(_placa)
	_placa.position = Vector3(base) + Vector3(0, 0.5, 0)
	_placa.body_entered.connect(_on_placa_entered)

func _crear_puerta() -> void:
	_puerta = PuzzlePuerta.new()
	_puerta.name = "Puerta"
	add_child(_puerta)
	_puerta.configurar(_terreno, _sello_pos)

func _on_placa_entered(body: Node) -> void:
	if body is CharacterBody3D:
		_sala.set_emisor(0, true)
		var activos := _sala.recalcular()
		if "puerta" in activos and not _puerta.abierta:
			_puerta.abrir()
			print("[M25] Puzzle resuelto: placa pisada -> puerta abierta")

func _buscar_terreno() -> VoxelTerrain:
	var root := get_tree().current_scene
	if root == null:
		return null
	for child in root.get_children():
		if child is VoxelTerrain:
			return child as VoxelTerrain
	return null
