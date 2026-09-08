# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-07
#
# M09: análisis de CONECTIVIDAD de tierra — ¿el spawn (3860,3860) está en la
# misma masa de tierra que las montañas (2660,2580)? Escaneo radial desde las
# montañas: hasta dónde hay tierra continua (h>=4 sin agua intermedia).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/escanear_conectividad_m09.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M09] Conectividad tierra desde las montañas ===")
	var wg = load("res://scripts/world/world_generator.gd").new()
	wg.world_seed = 42
	wg.island_radius = 2560
	wg.max_height = 90
	var gen = wg._get_island_gen()

	# 8 direcciones desde el centro de montañas: hasta qué radio hay tierra
	# continua (h>=4) SIN cruzar agua (h<=3)
	for i in range(8):
		var ang := TAU * float(i) / 8.0
		var dir := Vector2(cos(ang), sin(ang))
		var r_tierra_max := 0.0
		var cruzo_agua := false
		for r in range(20, 2600, 10):
			var x := 2660.0 + dir.x * float(r)
			var z := 2660.0 + dir.y * float(r)
			var h: int = gen.get_height(int(x), int(z))
			if h <= 3:
				cruzo_agua = true
			elif not cruzo_agua:
				r_tierra_max = float(r)
		var dir_nombre := ["E", "SE", "S", "SO", "O", "NO", "N", "NE"][i]
		print("  %s: tierra continua hasta r=%.0f%s" % [dir_nombre, r_tierra_max, (" (LUEGO HAY AGUA)" if cruzo_agua else " (todo tierra)")])

	# ¿Y hacia dónde está el spawn actual (3860,3860)?
	var dist_spawn_montanas := Vector2(3860, 3860).distance_to(Vector2(2660, 2580))
	var ang_spawn := Vector2(3860, 3860).angle_to(Vector2(2660, 2580))
	print("  spawn actual a %.0fm de las montañas" % dist_spawn_montanas)
	# Escaneo directo spawn → montañas: ¿hay agua en el medio?
	var desde := Vector2(3860, 3860)
	var hasta := Vector2(2660, 2580)
	var pasos := 60
	var agua_en_camino := false
	var primer_agua_r := -1.0
	for i in range(pasos):
		var t := float(i) / float(pasos - 1)
		var pos := desde.lerp(hasta, t)
		var h: int = gen.get_height(int(pos.x), int(pos.y))
		if h <= 3 and not agua_en_camino:
			agua_en_camino = true
			primer_agua_r = t * dist_spawn_montanas
			print("  AGUA en el camino a t=%.2f (r=%.0f del spawn), h=%d" % [t, primer_agua_r, h])
	if not agua_en_camino:
		print("  camino spawn→montañas: TODO TIERRA")
	quit(0)
