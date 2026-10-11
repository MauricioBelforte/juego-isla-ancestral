extends Node3D
## CapturaPreview — M154 L114: captura automática de preview de personaje.

const CAPTURA_DIR := "res://tools/mcp/godot-mcp/capturas/154-Vision-Del-Agente/"
const ANGULOS := [0.0, PI/2, PI, -PI/2]
const ALTURAS := [0.8, 1.5, 2.5]

func _ready() -> void:
	_asegurar_directorio()
	_crear_placeholder()
	var total := 0
	for ang in ANGULOS:
		rotation.y = ang
		for h in ALTURAS:
			var cam := get_node("CamaraPreview") as Camera3D
			cam.global_position = Vector3(0, h, 3)
			var ruta := CAPTURA_DIR.path_join("preview_a%d_h%d.png" % [int(deg_to_rad(ang)*180/PI) if ang>0 else 270, int(h*10)])
			_capturar(ruta)
			total += 1
	print("[M154] Capturas preview: %d (dir %s)" % [total, CAPTURA_DIR])

func _asegurar_directorio() -> void:
	DirAccess.make_dir_recursive_absolute(CAPTURA_DIR)

func _crear_placeholder() -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 1.8, 0.5)
	mesh.mesh = box
	mesh.position = Vector3(0, 0.9, 0)
	add_child(mesh)

func _capturar(ruta: String) -> void:
	var img := get_viewport().get_texture().get_image()
	if img != null:
		img.save_png(ruta)
		print("[M154] Captura: %s" % ruta)
