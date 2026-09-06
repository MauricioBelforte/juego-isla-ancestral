# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M51 iter. 2: plano de agua animado (shader de olas + fresnel + espuma)
# sobre el océano voxel. El MeshInstance3D se define en main_island.tscn;
# este script construye el ShaderMaterial (shaders/agua_olas.gdshader).

extends MeshInstance3D

const RUTA_SHADER := "res://shaders/agua_olas.gdshader"
## Radio del mundo isla (512) + margen mar abierto
const TAMANO_PLANO := 1400.0
## Superficie base del plano: ENCIMA del top del agua voxel (4.0) para que
## las olas se vean de cerca aunque el terreno real esté cargado. El shader
## hunde el plano solo en la franja de arena (r 262-292).
const Y_SUPERFICIE := 4.05
## Centro del mundo isla (regla M167: centro = island_radius)
const CENTRO := Vector3(256.0, Y_SUPERFICIE, 256.0)


func _ready() -> void:
	var plano := PlaneMesh.new()
	plano.size = Vector2(TAMANO_PLANO, TAMANO_PLANO)
	plano.subdivide_depth = 80
	plano.subdivide_width = 80
	mesh = plano
	var shader := load(RUTA_SHADER) as Shader
	if shader == null:
		push_warning("[M51] shader de agua no encontrado: %s" % RUTA_SHADER)
		return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	material_override = mat
	# Sombra off: el plano no debe proyectar sombras sobre la isla
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	global_position = CENTRO
	print("[M51] Agua animada lista: plano %.0fx%.0f en y=%.2f (shader olas+fresnel)" % [TAMANO_PLANO, TAMANO_PLANO, Y_SUPERFICIE])
