# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M33: CropTileVisual — presentación 3D del cultivo (placeholder cozy).
# Según 03-Diseno §2.5: placeholder BoxMesh por etapa (MultiMesh completo queda
# para iteración con M50/M61). Funciones: refresh, shake, play_water_fx, play_harvest_fx.

class_name CropTileVisual
extends Node3D

var _mesh: MeshInstance3D

func _ready() -> void:
	_mesh = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.35, 0.35, 0.35)
	_mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35, 0.65, 0.3)
	_mesh.material_override = mat
	add_child(_mesh)

## Refresca la presentación según la etapa y el cultivo.
func refresh(tile: CropTile) -> void:
	if tile == null or tile.crop_def == null or _mesh == null:
		return
	var def: CropDefinition = tile.crop_def
	# Escala crece con la etapa; color del cultivo; pausa = tono apagado
	var escala: float = 0.35 + 0.35 * float(tile.current_stage_index()) / maxf(1.0, float(def.stage_count))
	if tile.is_ready():
		escala *= 1.25
	_mesh.scale = Vector3(escala, escala, escala)
	var color: Color = def.color_visual()
	if tile.is_paused():
		color = color.darkened(0.45)
	if tile.is_ready():
		color = color.lightened(0.15)
	_mesh.material_override.albedo_color = color

## Agitación 1 s (pisoteo NPC) — sin pérdida de progreso.
func shake(_duration_s: float) -> void:
	var tw := create_tween()
	tw.tween_property(_mesh, "rotation_degrees:z", 8.0, 0.12)
	tw.tween_property(_mesh, "rotation_degrees:z", -8.0, 0.12)
	tw.tween_property(_mesh, "rotation_degrees:z", 0.0, 0.12)

## Feedback de riego (gotas ligeras → placeholder: pulso azul)
func play_water_fx() -> void:
	var mat := _mesh.material_override as StandardMaterial3D
	if mat:
		mat.albedo_color = Color(0.4, 0.6, 0.9)
		var tw := create_tween()
		tw.tween_interval(0.3)
		tw.tween_callback(func(): refresh_visual_color())

func play_harvest_fx() -> void:
	var tw := create_tween()
	tw.tween_property(_mesh, "scale", Vector3(0.05, 0.05, 0.05), 0.25)

func refresh_visual_color() -> void:
	pass  # el refresh real lo hace refresh(tile) del FarmService
