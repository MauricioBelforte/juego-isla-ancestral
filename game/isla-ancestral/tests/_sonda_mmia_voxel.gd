extends SceneTree

# Sonda propia (M112 / P1): ¿es el GDExtension de Voxel Tools el que hace lenta la SALIDA
# del motor? Se instancia SOLO un VoxelTerrain (sin la escena completa) y se mide la salida.
# Nombre propio: _sonda_mmia_voxel.gd (borrar SOLO este archivo al terminar).

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	var t0 := Time.get_ticks_msec()
	var vt = VoxelTerrain.new()
	vt.name = "TerrenoPrueba"
	root.add_child(vt)
	await process_frame
	print("[MMIA2] VoxelTerrain instanciado y montado en %d ms" % (Time.get_ticks_msec() - t0))
	print("[MMIA2] saliendo (si el deinit del GDExtension es lento, el proceso lo demorara)")
	quit(0)
