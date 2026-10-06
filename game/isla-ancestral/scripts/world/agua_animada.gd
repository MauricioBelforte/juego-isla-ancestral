# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M51 iter. 2: plano de agua animado (shader de olas + fresnel + espuma)
# sobre el océano voxel. El MeshInstance3D se define en main_island.tscn;
# este script construye el ShaderMaterial (shaders/agua_olas.gdshader).

extends MeshInstance3D

const RUTA_SHADER := "res://shaders/agua_olas.gdshader"
## M09 iter.: mundo 5120×5120 — el plano cubre todo + margen de mar abierto.
## El shore-fade (depth texture) dibuja la orilla real donde corresponda.
const TAMANO_PLANO := 6200.0
## Superficie base del plano. BUG-105 (test 1): 4.05 -> 6.0. La costa real
## esta en y>=5 (M51 05-Checklist L265); con 4.05 la banda costera somera del
## shader era ancha y espuma_orilla inundaba la camara del jugador. Subir el
## plano a 6.0 (por encima de la orilla) elimina la banda de agua somera y con
## ella la espuma que inundaba la vista. Causa confirmada por SB (Log 1326,
## A/B controlado: no es albedo, es color_espuma del shader agua_olas.gdshader).
const Y_SUPERFICIE := 6.0
## Centro real de la isla (island_generator: island_radius=2560, mundo 5120²)
const CENTRO := Vector3(2560.0, Y_SUPERFICIE, 2560.0)


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
