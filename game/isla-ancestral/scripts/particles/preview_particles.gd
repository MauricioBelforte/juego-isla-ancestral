extends Node3D

## Escena de preview de partículas (Módulo 52 — Partículas VFX)
## Demo visual para validar la vía V4 (godot-mcp): polen flotante.
## El emisor CPUParticles3D está en el .tscn (PollenEmitter); este script
## completa su configuración runtime para garantizar emisión visible.

@onready var _emitter: CPUParticles3D = $PollenEmitter
@onready var _cam: Camera3D = $CameraDemo
@onready var _fps_label: Label = $UI/FPSLabel

func _ready() -> void:
	print("Isla Ancestral - Preview de Partículas VFX (M52)")
	if not _emitter:
		print("Error: no se encontró el nodo PollenEmitter")
		return

	# Configuración runtime completa para emisión visible de polen
	# (solo propiedades válidas de CPUParticles3D en Godot 4)
	_emitter.emitting = true
	_emitter.amount = 200
	_emitter.lifetime = 5.0
	_emitter.initial_velocity_min = 0.3
	_emitter.initial_velocity_max = 1.2
	_emitter.gravity = Vector3(0, 0.05, 0)
	_emitter.direction = Vector3(0, 1, 0)
	_emitter.spread = 60.0
	_emitter.scale_amount_min = 2.0
	_emitter.scale_amount_max = 4.0
	_emitter.color = Color(1, 0.1, 0.1)
	_emitter.local_coords = false
	# AABB de visibilidad amplio: sin esto, Godot culla partículas fuera del cubo default
	_emitter.visibility_aabb = AABB(Vector3(-20, -20, -20), Vector3(40, 40, 40))

	# GPUParticles3D (recomendado por M52): CPUParticles3D no renderiza con D3D12
	var gp := GPUParticles3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.06, 0.06)  # polen pequeño (antes 0.25 → cuadrados gigantes)
	var qmat := StandardMaterial3D.new()
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qmat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Textura radial suave generada por código (sin assets externos)
	var tex := GradientTexture2D.new()
	tex.width = 64
	tex.height = 64
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
	grad.colors = PackedColorArray([
		Color(1.0, 0.95, 0.5, 1.0),   # centro cálido
		Color(1.0, 0.9, 0.25, 0.85),  # cuerpo amarillo
		Color(1.0, 0.85, 0.2, 0.0),   # borde difuminado
	])
	tex.gradient = grad
	qmat.albedo_texture = tex
	quad.material = qmat
	gp.draw_pass_1 = quad

	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 60.0
	pm.initial_velocity_min = 0.15
	pm.initial_velocity_max = 0.6
	pm.gravity = Vector3(0, 0.02, 0)  # caída muy lenta: polen suspendido
	pm.damping_min = 0.1
	pm.damping_max = 0.3
	pm.scale_min = 0.6
	pm.scale_max = 1.4
	pm.color = Color(1, 1, 1)  # el color ya viene de la textura
	# Emisión en caja ancha: distribuye el polen por toda la escena (no en un punto)
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(3.5, 0.5, 1.0)
	# Turbulencia: deriva horizontal suave tipo brisa (más orgánico que subir recto)
	pm.turbulence_enabled = true
	pm.turbulence_noise_strength = 0.4
	pm.turbulence_noise_scale = 1.8
	pm.turbulence_influence_min = 0.1
	pm.turbulence_influence_max = 0.4
	gp.process_material = pm
	gp.amount = 220
	gp.lifetime = 9.0
	gp.visibility_aabb = AABB(Vector3(-20, -20, -20), Vector3(40, 40, 40))
	gp.position = Vector3(0, 1, 0)
	gp.emitting = true
	gp.name = "PolenGPU"
	add_child(gp)
	print("GPUParticles3D polen creado (amount=150, quad 0.06 con textura radial suave)")

	print("Polen emisor configurado (amount=%d)" % _emitter.amount)
	print("  escala: %.2f–%.2f  vel: %.1f–%.1f" % [_emitter.scale_amount_min, _emitter.scale_amount_max, _emitter.initial_velocity_min, _emitter.initial_velocity_max])

	# Posicionar la cámara en frente del emisor mirando al origen
	if _cam:
		_cam.position = Vector3(0, 1.0, 3)
		_cam.look_at(Vector3(0, 1.2, 0))

## Actualiza el label de FPS cada 0.5s
func _process(_delta: float) -> void:
	if _fps_label and Engine.get_frames_per_second() < 60:
		_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()