# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M155: Escena de preview del panel de equipamiento (QA visual iter 3).
# Monta la EquipmentLayer REAL y la abre (toggle) para verificar visualmente
# los 4 slots y el grid de 16 prendas con su estado de desbloqueo.
# Uso: godot_run_project scene scenes/preview_equipment.tscn

extends Node3D

func _ready() -> void:
	var cam := Camera3D.new()
	add_child(cam)

	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, 30, 0)
	luz.light_energy = 1.4
	add_child(luz)

	var capa = load("res://scripts/ui/layers/equipment_layer.gd").new()
	capa.name = "EquipmentLayer"
	add_child(capa)
	capa.toggle()
	print("=== M155: PREVIEW EQUIPAMIENTO (capas montadas) ===")
