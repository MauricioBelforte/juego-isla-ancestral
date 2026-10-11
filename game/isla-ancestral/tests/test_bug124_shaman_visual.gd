# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-09
#
# BUG-124 (encargo msg 82, parte 2): el ShamanMonte se instanciaba con
# shaman_npc.gd puro (InteractableBase, logica de dialogo/encantamiento) y NO
# tenia ninguna malla: en las 3 iteraciones de camara del QA M154 la colina
# quedo vacia. villager.gd::_crear_visuales() es el patron canonico (capsula +
# cabeza + Label3D).
#
# Esta suite instancia ShamanNPC igual que main_island._crear_shaman()
# (script.new() + add_child) y afirma que el placeholder visual existe:
#   1) Body  = MeshInstance3D + CapsuleMesh
#   2) Head  = MeshInstance3D + SphereMesh
#   3) LabelNombre = Label3D con "Chaman"
#   4) exactamente 2 MeshInstance3D y SIN CollisionShape3D (nodo Node3D
#      plano; la interaccion es por radio, la colision de villager es de su
#      CharacterBody3D y no aplica aca)
# Ejecutar:
#   godot --headless --path game/isla-ancestral --script res://tests/test_bug124_shaman_visual.gd

extends SceneTree

var _fallos: int = 0
var _ok: int = 0


func _init() -> void:
	call_deferred("_correr")


func _check(nombre: String, cond: bool) -> void:
	if cond:
		_ok += 1
		print("[OK] %s" % nombre)
		return
	_fallos += 1
	printerr("[FAIL] %s" % nombre)


func _resumen() -> void:
	print("\n%d checks, %d fallos" % [_ok + _fallos, _fallos])


func _correr() -> void:
	print("=== BUG-124: ShamanMonte con placeholder visual (encargo msg 82, parte 2) ===")
	var shaman_script = load("res://scripts/enchantment/shaman_npc.gd")
	_check("shaman_npc.gd carga", shaman_script != null)
	if shaman_script == null:
		_resumen()
		quit(1)
		return

	var sh = shaman_script.new()
	_check("ShamanNPC se instancia", sh != null and is_instance_valid(sh))
	_check("es un Node3D (InteractableBase)", sh is Node3D)
	root.add_child(sh)
	await process_frame

	var body = sh.get_node_or_null("Body")
	_check("hijo Body existe", body != null)
	_check("Body es MeshInstance3D", body is MeshInstance3D)
	_check("Body usa CapsuleMesh", body is MeshInstance3D and body.mesh is CapsuleMesh)

	var head = sh.get_node_or_null("Head")
	_check("hijo Head existe", head != null)
	_check("Head es MeshInstance3D con SphereMesh",
			head is MeshInstance3D and head.mesh is SphereMesh)

	var label = sh.get_node_or_null("LabelNombre")
	_check("hijo LabelNombre existe", label != null)
	_check("LabelNombre es Label3D con texto 'Chaman'",
			label is Label3D and label.text == "Chamán")

	var mallas := 0
	var colisiones := 0
	for hijo in sh.get_children():
		if hijo is MeshInstance3D:
			mallas += 1
		elif hijo is CollisionShape3D:
			colisiones += 1
	_check("exactamente 2 MeshInstance3D (Body + Head)", mallas == 2)
	_check("sin CollisionShape3D (decision documentada en el codigo)", colisiones == 0)

	# Limpieza rapida (el nodo es Node3D puro: free directo es seguro; ver
	# guia 06: NO free() de main_island, eso si cuelga por los threads voxel).
	sh.queue_free()
	await process_frame

	_resumen()
	quit(1 if _fallos > 0 else 0)
