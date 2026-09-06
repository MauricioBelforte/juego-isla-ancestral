# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-06
#
# M51: medición REAL de la línea de costa — escanea rayos radiales desde el
# centro (256,256) con TerrainLocator y reporta el radio donde termina el
# agua (height<=3) y donde empieza la arena seca (height>=5).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/medir_costa_m51.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M51] Medición de costa real ===")
	var tl := root.get_node_or_null("TerrainLocator")
	if tl == null:
		print("TerrainLocator no disponible")
		quit(1)
		return
	# Esperar a que el terreno esté cargado (el autoload retrasa 1 frame)
	await create_timer(3.0).timeout
	var total_angeles := 24
	var radios_agua: Array = []   # primer radio con height<=3 (fin del agua)
	var radios_arena: Array = []  # primer radio con height>=5 (arena seca)
	for i in range(total_angeles):
		var ang := TAU * float(i) / float(total_angeles)
		var dir := Vector2(cos(ang), sin(ang))
		var r_agua := -1.0
		var r_arena := -1.0
		for r in range(20, 260, 2):
			var x := 256.0 + dir.x * float(r)
			var z := 256.0 + dir.y * float(r)
			var h := int(tl.get_height(x, z))
			if r_agua < 0.0 and h <= 3:
				r_agua = float(r)
			if r_agua >= 0.0 and r_arena < 0.0 and h >= 5:
				r_arena = float(r)
				break
		if r_agua >= 0.0:
			radios_agua.append(r_agua)
		if r_arena >= 0.0:
			radios_arena.append(r_arena)
		print("  ang=%3d° agua(r)=%s arena(r)=%s" % [rad_to_deg(ang), (str(r_agua) if r_agua >= 0.0 else "—"), (str(r_arena) if r_arena >= 0.0 else "—")])
	if radios_agua.size() > 0:
		radios_agua.sort()
		print("Radio FIN del agua (agua clara → orilla): min=%s med=%s max=%s" % [radios_agua[0], radios_agua[radios_agua.size() / 2], radios_agua[radios_agua.size() - 1]])
	if radios_arena.size() > 0:
		radios_arena.sort()
		print("Radio inicio de arena seca: min=%s med=%s max=%s" % [radios_arena[0], radios_arena[radios_arena.size() / 2], radios_arena[radios_arena.size() - 1]])
	quit(0)
