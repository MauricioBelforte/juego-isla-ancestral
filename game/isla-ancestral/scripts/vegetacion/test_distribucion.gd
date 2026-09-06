# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-04
#
# M50: Debug de distribución — cuántas instancias cayeron cerca del spawn y
# cuántas fueron omitidas por agua. Ejecutar headless:
# Godot --headless --path game/isla-ancestral --script res://scripts/vegetacion/test_distribucion.gd

extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var PLAN = load("res://scripts/vegetacion/vegetation_plan.gd")
	var plan: Array = PLAN.generar_plan(Vector2(256, 256), 256.0, 42)
	print("=== M50 DISTRIBUCION ===")
	print("Total instancias del plan: %d" % plan.size())
	var cerca_spawn := 0
	var lejos := 0
	var por_bioma := {}
	for item in plan:
		var b := String(item["bioma"])
		por_bioma[b] = int(por_bioma.get(b, 0)) + 1
		var x := float(item["posicion"]["x"])
		var z := float(item["posicion"]["z"])
		var dist_spawn := Vector2(x, z).distance_to(Vector2(320, 320))
		if dist_spawn < 40.0:
			cerca_spawn += 1
		else:
			lejos += 1
	print("Por bioma: %s" % str(por_bioma))
	print("Cerca del spawn (320,320) < 40m: %d" % cerca_spawn)
	print("Lejos del spawn: %d" % lejos)
	# Mostrar 5 items de 'cercanias' con posiciones
	var mostrados := 0
	for item in plan:
		if String(item["bioma"]) == "cercanias" and mostrados < 5:
			print("  cercanias: %s en (%.0f, %.0f)" % [String(item["tipo"]), float(item["posicion"]["x"]), float(item["posicion"]["z"])])
			mostrados += 1
	quit(0)
