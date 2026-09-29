# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-19
#
# M25: test headless del fix V-3 (BUG-053) — colocación E-80 de antorcha_pared.
# Ejecutar:
#   & "D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64_console.exe" --headless --path "game/isla-ancestral" --quit --script "res://scripts/ruinas/test_colocar_props_m25.gd"
# Criterio de validez (lección 28): EXIT 0 Y sin SCRIPT ERROR del propio módulo.
# NOTA: el run de --script arranca los autoloads del proyecto (ruido esperado:
# warnings M39 conocidos, BUG-054) — no cuenta como fallo de este test.

extends SceneTree

var _fallos := 0

# Stub que espeja la API pública de TerrainLocator (scripts/core/terrain_locator.gd):
# get_height / posicionar_sobre_terreno / esta_sobre_superficie. Si falta alguna,
# los consumidores del boot de fondo (ResourceSpawner...) caen en Invalid call
# (lección 28: el stderr del run es parte del resultado).
class StubLocator extends Node3D:
	func get_height(x: int, z: int) -> int:
		return 7
	func posicionar_sobre_terreno(nodo: Node3D, x: float, z: float) -> bool:
		nodo.position.y = float(get_height(int(x), int(z))) + 1.0
		return true
	func esta_sobre_superficie(nodo: Node3D) -> bool:
		return nodo.position.y >= 7.0

func _check(cond: bool, desc: String) -> void:
	if cond:
		print("[OK] ", desc)
	else:
		_fallos += 1
		print("[FALLO] ", desc)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M25] Test colocación E-80 (fix V-3 antorcha_pared) ===")
	var Placer = load("res://scripts/ruinas/colocar_props_m25.gd")
	var placer: Node3D = Placer.new()
	root.add_child(placer)

	# z_min de referencia medidos con scripts/auditar_flotacion_glb.py (Log 1035):
	# alta 0.295 · media 0.340 · baja 0.340
	var rutas := {
		"alta": "res://assets/3d/alta/25-Ruinas-Templos_antorcha_pared.glb",
		"media": "res://assets/3d/media/25-Ruinas-Templos_antorcha_pared.glb",
		"baja": "res://assets/3d/baja/25-Ruinas-Templos_antorcha_pared.glb",
	}
	var z_ref := {"alta": 0.295, "media": 0.340, "baja": 0.340}

	# 1) Los 3 glb cargan
	for clave in rutas:
		var res: PackedScene = load(rutas[clave])
		_check(res != null, "%s carga" % clave)

	# 2) Medición runtime de z_min (API de superficies; si la versión no la expone,
	# devuelve 0.0 y el fix usa z_min_referencia de datos — ambas vías documentadas)
	var zm_media: float = placer.medir_z_min(load(rutas["media"]))
	if zm_media > 0.0:
		_check(absf(zm_media - z_ref["media"]) <= 0.02, "medición runtime media z_min=%.4f ≈ 0.340" % zm_media)
	else:
		print("[OK] medición runtime no disponible en esta versión (API de superficies) → vía de datos z_min_referencia (documentado)")

	# 3) Fallback sin TerrainLocator: z_base = 1.0 (documentado)
	var inst_suelo: Node3D = placer.colocar_prop(rutas["media"], 3.0, -3.0, "suelo")
	_check(inst_suelo != null, "modo suelo instancia")
	_check(absf(inst_suelo.position.y - 1.0) < 0.001, "modo suelo: origen en la referencia (y=%.4f) — la cara inferior (z_min +0.34) flota 0.34: ES EL BUG V-3" % inst_suelo.position.y)

	# 4) Fix E-80: cara inferior a 0.30 m sobre la referencia (y = z_base + 0.30 - z_min)
	var inst_e80: Node3D = placer.colocar_antorcha_pared(rutas["media"], 5.0, -3.0, 0.30, z_ref["media"])
	var y_esperado: float = 1.0 + 0.30 - z_ref["media"]
	_check(inst_e80 != null, "modo montado_e80 instancia")
	_check(absf(inst_e80.position.y - y_esperado) < 0.001, "E-80: y=%.4f (esperado %.4f) — cara inferior a 0.30 m de la referencia" % [inst_e80.position.y, y_esperado])

	# 5) Con TerrainLocator (regla de oro get_height+1): stub height=7 → z_base=8.
	# En --script el autoload real existe pero su get_height devuelve -1 (sin terreno
	# generado); se libera para inyectar el stub del test.
	var real_tl := root.get_node_or_null("TerrainLocator")
	if real_tl:
		real_tl.free()
	var stub := StubLocator.new()
	stub.name = "TerrainLocator"
	root.add_child(stub)
	var inst_tl: Node3D = placer.colocar_prop(rutas["media"], 9.0, 9.0, "suelo")
	_check(inst_tl != null, "coloca con TerrainLocator presente")
	_check(absf(inst_tl.position.y - 8.0) < 0.001, "z_base = get_height+1 = 8.0 (y=%.4f)" % inst_tl.position.y)
	var inst_tl_e80: Node3D = placer.colocar_antorcha_pared(rutas["alta"], 9.0, 11.0, 0.30, z_ref["alta"])
	_check(absf(inst_tl_e80.position.y - (8.0 + 0.30 - z_ref["alta"])) < 0.001,
			"E-80 con TerrainLocator (y=%.4f, esperado %.4f)" % [inst_tl_e80.position.y, 8.0 + 0.30 - z_ref["alta"]])

	if _fallos == 0:
		print("=== [M25] TEST COLACAR-PROPS: 0 fallos — fix V-3 verificado headless ===")
		quit(0)
	else:
		printerr("=== [M25] TEST COLACAR-PROPS: %d fallos ===" % _fallos)
		quit(1)
