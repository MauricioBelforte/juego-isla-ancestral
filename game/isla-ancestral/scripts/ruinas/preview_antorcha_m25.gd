# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M25/M19: preview de la antorcha de pared (fix V-3, BUG-053) — ANTES/DESPUÉS.
# ANTES: flujo estándar de props de suelo (glb origen en la referencia del terreno):
#        la cara inferior de la pieza (z_min +0.34 del glb) queda flotando ~34 cm.
# DESPUÉS: regla E-80 de ColocarPropsM25 (scripts/ruinas/colocar_props_m25.gd):
#        la cara inferior queda a 0.30 m de la referencia, contra la pared.
# Uso: escena res://scenes/preview_antorcha_m25.tscn (captura V4 con screen capture).

extends Node3D

const RUTA_GLB := "res://assets/3d/media/25-Ruinas-Templos_antorcha_pared.glb"
## z_min de la variante media (scripts/auditar_flotacion_glb.py, Log 1035)
const Z_MIN_GLB := 0.34
## E-80: altura de montaje de la cara inferior de la antorcha
const ALTURA_MONTAJE := 0.30

func _ready() -> void:
	_luz()
	_suelo()
	_pared()
	_anterior()
	_corregido()
	_camara()
	print("[M25-PREVIEW] antorcha_pared antes/después: ANTES flota %.2f m; DESPUÉS cara inferior en +%.2f m (E-80)" % [Z_MIN_GLB, ALTURA_MONTAJE])

func _luz() -> void:
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, 30, 0)
	luz.light_energy = 1.8
	luz.shadow_enabled = true
	add_child(luz)
	var omni := OmniLight3D.new()
	omni.position = Vector3(0, 4, 6)
	omni.light_energy = 0.4
	add_child(omni)

func _suelo() -> void:
	var suelo := MeshInstance3D.new()
	var plano := PlaneMesh.new()
	plano.size = Vector2(12, 12)
	suelo.mesh = plano
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.82, 0.78, 0.58)  # arena
	suelo.material_override = mat
	suelo.rotation_degrees = Vector3(-90, 0, 0)
	add_child(suelo)

func _pared() -> void:
	var pared := MeshInstance3D.new()
	var caja := BoxMesh.new()
	caja.size = Vector3(10, 4, 0.3)
	pared.mesh = caja
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.58, 0.52)  # muro de ruina
	pared.material_override = mat
	pared.position = Vector3(0, 2, -3.15)
	add_child(pared)
	_etiqueta("PARED (ruina M25)", Vector3(4.2, 3.6, -3.1), Color(0.5, 0.5, 0.5), 0.35)

func _anterior() -> void:
	# BUG V-3: flujo estándar — glb origen en la referencia del suelo
	var res: PackedScene = load(RUTA_GLB)
	if res == null:
		push_error("[M25-PREVIEW] no se pudo cargar " + RUTA_GLB)
		return
	var inst: Node3D = res.instantiate()
	inst.position = Vector3(-1.6, 0.0, -3.0)  # origen en la referencia (y=0)
	add_child(inst)
	_marco_referencia(Vector3(-1.6, 0.0, -3.0))
	_etiqueta("ANTES: flota %.2f m" % Z_MIN_GLB, Vector3(-1.6, 0.9, -2.2), Color(0.95, 0.25, 0.25), 0.4)

func _corregido() -> void:
	# FIX E-80: cara inferior a ALTURA_MONTAJE de la referencia, contra la pared
	var res: PackedScene = load(RUTA_GLB)
	if res == null:
		return
	var inst: Node3D = res.instantiate()
	inst.position = Vector3(1.6, ALTURA_MONTAJE - Z_MIN_GLB, -3.0)
	add_child(inst)
	_marco_referencia(Vector3(1.6, ALTURA_MONTAJE, -3.0))
	_etiqueta("DESPUÉS: E-80, cara inferior +%.2f m" % ALTURA_MONTAJE, Vector3(1.6, 0.9, -2.2), Color(0.15, 0.85, 0.3), 0.42)

## Anillo fino a la altura del "suelo referencia" (o de la cara inferior en E-80)
## para que la flotación se lea a simple vista en la captura.
func _marco_referencia(pos: Vector3) -> void:
	var anillo := MeshInstance3D.new()
	var toro := CylinderMesh.new()
	toro.top_radius = 0.55
	toro.bottom_radius = 0.55
	toro.height = 0.02
	anillo.mesh = toro
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.9)
	anillo.material_override = mat
	anillo.position = pos
	add_child(anillo)

func _camara() -> void:
	var cam := Camera3D.new()
	cam.position = Vector3(0, 0.75, 1.6)
	cam.fov = 62.0
	cam.look_at(Vector3(0, 0.35, -3.0))
	add_child(cam)

func _etiqueta(texto: String, pos: Vector3, color: Color, escala: float) -> void:
	var lbl := Label3D.new()
	lbl.text = texto
	lbl.position = pos
	lbl.modulate = color
	lbl.scale = Vector3(escala, escala, escala)
	lbl.outline_size = 4
	add_child(lbl)
