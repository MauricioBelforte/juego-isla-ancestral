extends SceneTree

# Sonda propia (M112 / P1): medir el guardado asincrono que dispara el montaje de la escena.
# Nombre propio: _sonda_mmia_save.gd (borrar SOLO este archivo al terminar).
const ESCENA := "res://scenes/main_island.tscn"

func _initialize() -> void:
	call_deferred("_correr")

func _correr() -> void:
	await process_frame
	var t0 := Time.get_ticks_msec()
	var packed := load(ESCENA)
	var inst = packed.instantiate()
	root.add_child(inst)
	await process_frame
	var ds = root.get_node_or_null("/root/DataStore")
	if ds == null:
		print("[MMIA] sin DataStore")
		quit(0)
		return
	print("[MMIA] escena montada en %d ms; DataStore=%s" % [Time.get_ticks_msec() - t0, str(ds)])
	# observar el estado del guardado
	var visto_guardando := false
	var t_guardado := 0
	for i in 240:
		var en_curso := bool(ds.call("guardado_en_curso")) if ds.has_method("guardado_en_curso") else false
		if en_curso:
			if not visto_guardando:
				visto_guardando = true
				t_guardado = Time.get_ticks_msec()
				print("[MMIA] guardado EN CURSO (detectado en el frame %d)" % i)
		elif visto_guardando:
			print("[MMIA] guardado TERMINADO: %d ms (%d s)" % [Time.get_ticks_msec() - t_guardado, (Time.get_ticks_msec() - t_guardado) / 1000])
			break
		await create_timer(0.5).timeout
	if not visto_guardando:
		print("[MMIA] NO se detecto guardado en curso en 120 s")
	print("[MMIA] total antes de salir: %d ms" % (Time.get_ticks_msec() - t0))
	quit(0)
