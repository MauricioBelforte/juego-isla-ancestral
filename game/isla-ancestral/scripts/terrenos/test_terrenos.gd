# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M156: Test de TerrainProvider + TerrainModifiers + TerrainDetector (V0/V1).
# Ejecutar: Godot --headless --path game\isla-ancestral --script res://scripts/terrenos/test_terrenos.gd

extends SceneTree

const TerrainModifiers = preload("res://scripts/terrenos/terrain_modifiers.gd")
const TerrainDetector = preload("res://scripts/terrenos/terrain_detector.gd")


var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var prov := root.get_node_or_null("TerrainProvider")
	_check(prov != null, "TerrainProvider autoload presente")
	if prov == null:
		print("=== TEST M156 TERRENOS: 1+ fallo(s) ===")
		quit(1)
		return
	_test_catalogo(prov)
	_test_modificadores(prov)
	_test_modifiers_calculo()
	_test_detector_clase()
	_test_suavizado_iter2()
	_test_puente_m155_iter2()
	print("=== TEST M156 TERRENOS: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_catalogo(prov: Node) -> void:
	_check(prov.terrenos_count() == 7, "7 terrenos cargados: %d" % prov.terrenos_count())
	_check(prov.get_terrain_name(1) == "Barro", "terreno 1 = Barro")
	_check(prov.get_speed_modifier(1) == 0.6, "barro 0.6 (diseño §4.2: 5.0→3.0)")
	_check(prov.get_speed_modifier(3) == 0.75, "arena 0.75 (5.0→3.75)")
	_check(prov.get_speed_modifier(4) == 0.7, "agua 0.7 (5.0→3.5)")
	_check(prov.get_speed_modifier(5) == 0.8, "nieve 0.8 (5.0→4.0)")
	_check(prov.get_speed_modifier(6) == 0.85, "rocas 0.85 (5.0→4.25)")
	# §10.2: terreno desconocido → 1.0
	_check(prov.get_speed_modifier(999) == 1.0, "terreno desconocido → 1.0 (§10.2)")

func _test_modificadores(prov: Node) -> void:
	# §1.4: calculate_effective_speed base × terreno × (1 + equipo)
	var eff: float = TerrainModifiers.calculate_effective_speed(5.0, 0.6, 0.0)
	_check(absf(eff - 3.0) < 0.01, "barro sin equipo = 3.0 m/s (§4.2)")
	eff = TerrainModifiers.calculate_effective_speed(5.0, 0.6, 0.35)
	_check(absf(eff - 4.05) < 0.01, "barro + botas barro 4.05 m/s (§4.2)")
	# Cap 50% de equipo
	eff = TerrainModifiers.calculate_effective_speed(5.0, 1.0, 0.9)
	_check(absf(eff - 7.5) < 0.01, "equipo cap 50% (§3.1)")
	# Modificador desde provider
	var mod: float = TerrainModifiers.get_terrain_modifier(prov, 1)
	_check(absf(mod - 0.6) < 0.01, "get_terrain_modifier desde provider")
	# Bonus de equipo con sistema ausente → 0.0 (§3.1 fallback)
	var bonus: float = TerrainModifiers.get_equipment_bonus(null, 1)
	_check(bonus == 0.0, "sin equipación → bonus 0.0 (§10.2)")

func _test_modifiers_calculo() -> void:
	# calculate_full end-to-end (usar la clase real, no el autoload)
	var prov := root.get_node_or_null("TerrainProvider")
	var Modifiers := load("res://scripts/terrenos/terrain_modifiers.gd")
	var eff: float = Modifiers.calculate_full(5.0, prov, 5, null)
	_check(absf(eff - 4.0) < 0.01, "calculate_full nieve = 4.0 m/s (§4.2)")

func _test_detector_clase() -> void:
	# La clase TerrainDetector existe y hereda RayCast3D
	var script := load("res://scripts/terrenos/terrain_detector.gd")
	_check(script != null, "terrain_detector.gd carga")
	if script != null:
		var detector: Node = script.new()
		_check(detector is RayCast3D, "TerrainDetector es RayCast3D (diseño §1.2)")
		_check(detector.has_signal("terrain_changed"), "señal terrain_changed presente")
		_check(absf(detector.detection_interval - 0.1) < 0.01, "detection_interval default 0.1")
		detector.free()

func _test_suavizado_iter2() -> void:
	# Iter. 2: suavizado de cambios de velocidad (transiciones cozy sin tirones)
	var v := 1.0
	var objetivo := 0.6
	# 1 tick no llega al objetivo
	var v1: float = TerrainModifiers.suavizar_velocidad(v, objetivo, 0.05)
	_check(v1 > objetivo and v1 < v, "suavizado baja progresivamente (1 tick: %.3f)" % v1)
	# Converge al objetivo (30 ticks de 0.05 = 1.5 s)
	var vi := 1.0
	for i in range(30):
		vi = TerrainModifiers.suavizar_velocidad(vi, objetivo, 0.05)
	_check(absf(vi - objetivo) < 0.01, "suavizado converge al objetivo (%.4f)" % vi)
	# Umbral: pega directo cerca del objetivo
	_check(TerrainModifiers.suavizar_velocidad(0.601, 0.6, 0.05) == 0.6, "umbral pega al objetivo (sin flicker)")
	# delta 0 no cambia nada
	_check(TerrainModifiers.suavizar_velocidad(1.0, 0.6, 0.0) == 1.0, "delta 0 = sin cambio")
	# calcular_suavizado end-to-end con provider real: barro 5.0 → objetivo 3.0
	var prov := root.get_node_or_null("TerrainProvider")
	var v2 := TerrainModifiers.calcular_suavizado(5.0, 5.0, prov, 1, null, 0.05)
	_check(v2 < 5.0 and v2 > 3.0, "calcular_suavizado barro progresivo (%.3f)" % v2)
	# Y converge al 3.0 con equipo nulo
	var v3 := 5.0
	for i in range(60):
		v3 = TerrainModifiers.calcular_suavizado(v3, 5.0, prov, 1, null, 0.05)
	_check(absf(v3 - 3.0) < 0.05, "calcular_suavizado converge a 3.0 m/s barro (%.3f)" % v3)

func _test_puente_m155_iter2() -> void:
	# Iter. 2: puente opcional M155 — EquipmentManager real devuelve bonus 0.0
	# si no hay equipación (contrato: M155 ausente o sin botas = 0.0, §3.1)
	var eq := root.get_node_or_null("EquipmentManager")
	var bonus: float = TerrainModifiers.get_equipment_bonus(eq, 1)
	_check(bonus == 0.0, "M155 real sin equipación → bonus 0.0 (got %.3f)" % bonus)
	# calculate_full con M155 real sigue capado al 50%
	var prov := root.get_node_or_null("TerrainProvider")
	var eff: float = TerrainModifiers.calculate_full(5.0, prov, 1, eq)
	_check(eff <= 3.0 * 1.5 + 0.01, "con M155 real barro ≤ cap 50%% (%.3f)" % eff)
