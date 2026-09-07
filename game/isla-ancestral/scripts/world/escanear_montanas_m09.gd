# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-07
#
# M09: escaneo del WorldGenerator para encontrar las columnas más altas
# (las montañas reales de la isla 10×). Grilla de 60m en todo el mundo.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/escanear_montanas_m09.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M09] Escaneo de montañas del generador ===")
	var gen = null
	var wg = load("res://scripts/world/world_generator.gd").new()
	wg.world_seed = 42
	wg.island_radius = 2560
	wg.max_height = 40
	gen = wg
	if gen == null:
		print("no se pudo crear el generador")
		quit(1)
		return
	var mejor := []
	var paso := 60
	for x in range(60, 5100, paso):
		for z in range(60, 5100, paso):
			var h: int = gen._get_island_gen().get_height(x, z)
			mejor.append(Vector3(x, h, z))
	mejor.sort_custom(func(a, b): return a.y > b.y)
	print("=== TOP 12 columnas más altas ===")
	for i in range(mini(12, mejor.size())):
		print("  (%d, h=%d, %d)" % [int(mejor[i].x), int(mejor[i].y), int(mejor[i].z)])
	# Histograma rápido
	var conteo := {"agua(0-3)": 0, "bajo(4-8)": 0, "medio(9-15)": 0, "alto(16-25)": 0, "montana(26+)": 0}
	for v in mejor:
		if v.y <= 3:
			conteo["agua(0-3)"] += 1
		elif v.y <= 8:
			conteo["bajo(4-8)"] += 1
		elif v.y <= 15:
			conteo["medio(9-15)"] += 1
		elif v.y <= 25:
			conteo["alto(16-25)"] += 1
		else:
			conteo["montana(26+)"] += 1
	print("=== Distribución de alturas (de %d muestras) ===" % mejor.size())
	for k in conteo:
		print("  %s: %d" % [k, conteo[k]])
	quit(0)
