# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-09
#
# M156 iter. 3 (B1+B2) — Integracion:
#   B1.1 detector montado en Player.tscn + player.gd lo lee
#   B1.2 _block_a_terrain() con mapa 7/7 (antes solo {0,3,5,6} alcanzables)
#   B1.3 puente de nombres M155 NO vacuo (antes NOMBRES_TERRENO espanol -> bonus 0.0)
#   B2   player.gd aplica la velocidad efectiva (base x terreno x (1+equipo))
# Ejecutar: godot --headless --path game/isla-ancestral --script res://scripts/terrenos/test_terrenos_integracion.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Piso = checks reales MEDIDOS en verde (no estimado).
const CHECKS_MINIMOS := 39
const _WB_BLOQUES: Array[String] = [
	"_test_mapa_7_terrenos",
	"_test_clave_m155",
	"_test_bono_no_nulo",
	"_test_detector_montado",
	"_test_player_integracion",
]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false

func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true

func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M156-B1B2: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

const TerrainModifiers = preload("res://scripts/terrenos/terrain_modifiers.gd")
const TerrainDetectorScript = preload("res://scripts/terrenos/terrain_detector.gd")

var _fallos: int = 0

# Equipo falso: mismo contrato que M155.get_terrain_bonus(clave: String) -> float.
class FakeEquipo extends Node:
	var bonos: Dictionary = {}
	func get_terrain_bonus(t: String) -> float:
		return float(bonos.get(t, 0.0))

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_test_mapa_7_terrenos()
	_fin("_test_mapa_7_terrenos")
	_test_clave_m155()
	_fin("_test_clave_m155")
	_test_bono_no_nulo()
	_fin("_test_bono_no_nulo")
	_test_detector_montado()
	_fin("_test_detector_montado")
	_test_player_integracion()
	_fin("_test_player_integracion")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


## B1.2 — los 7 terrain_id (M156 §4.1) deben ser alcanzables desde bloques REALES de M08.
func _test_mapa_7_terrenos() -> void:
	var det: Node = TerrainDetectorScript.new()
	var representativos := {
		0: [BlockType.GRASS, BlockType.DIRT, BlockType.MOSS],
		1: [BlockType.MUD, BlockType.CLAY],
		2: [BlockType.FLOOR_TILE, BlockType.ADOBE_WALL, BlockType.ROOF_TILE, BlockType.PLANKS],
		3: [BlockType.SAND],
		4: [BlockType.WATER, BlockType.SHALLOW_WATER],
		5: [BlockType.SNOW, BlockType.ICE],
		6: [BlockType.STONE, BlockType.BEDROCK, BlockType.GRAVEL],
	}
	for tid in range(7):
		var alcanzado := false
		for bid in representativos[tid]:
			if det._block_a_terrain(bid) == tid:
				alcanzado = true
		_check(alcanzado, "terrain_id %d alcanzable desde bloques M08 reales" % tid)
	# Casos concretos que ANTES eran inalcanzables (bug B1.2):
	_check(det._block_a_terrain(BlockType.MUD) == 1, "MUD(29) -> barro(1)")
	_check(det._block_a_terrain(BlockType.CLAY) == 1, "CLAY(6) -> barro(1)")
	_check(det._block_a_terrain(BlockType.FLOOR_TILE) == 2, "FLOOR_TILE(24) -> pavimento(2)")
	_check(det._block_a_terrain(BlockType.WATER) == 4, "WATER(17) -> agua(4)")
	_check(det._block_a_terrain(BlockType.SHALLOW_WATER) == 4, "SHALLOW_WATER(30) -> agua(4)")
	_check(det._block_a_terrain(BlockType.ICE) == 5, "ICE(16) -> nieve(5)")
	_check(det._block_a_terrain(BlockType.BEDROCK) == 6, "BEDROCK(4) -> rocas(6)")
	_check(det._block_a_terrain(BlockType.AIR) == 0, "AIR(0) -> cesped(0) neutro")
	_check(det._block_a_terrain(-1) == 0, "-1 desconocido -> cesped(0) neutro")
	det.free()


## B1.3 — la clave de bono se deriva del enum de M155 (ingles, minusculas).
func _test_clave_m155() -> void:
	_check(TerrainModifiers.clave_terreno_m155(0) == "grass", "id 0 -> grass")
	_check(TerrainModifiers.clave_terreno_m155(1) == "mud", "id 1 -> mud")
	_check(TerrainModifiers.clave_terreno_m155(2) == "pavement", "id 2 -> pavement")
	_check(TerrainModifiers.clave_terreno_m155(3) == "sand", "id 3 -> sand")
	_check(TerrainModifiers.clave_terreno_m155(4) == "shallow_water", "id 4 -> shallow_water")
	_check(TerrainModifiers.clave_terreno_m155(5) == "snow", "id 5 -> snow")
	_check(TerrainModifiers.clave_terreno_m155(6) == "rock", "id 6 -> rock")
	_check(TerrainModifiers.clave_terreno_m155(7) == "", "id 7 fuera de enum -> vacio")
	_check(TerrainModifiers.clave_terreno_m155(-1) == "", "id -1 -> vacio")


## B1.3 — REGRESION del bug: con el mapa espanol el bonus era SIEMPRE 0.0. Ahora NO.
func _test_bono_no_nulo() -> void:
	var fe := FakeEquipo.new()
	fe.bonos["mud"] = 0.3
	var b: float = TerrainModifiers.get_equipment_bonus(fe, 1)
	_check(b > 0.0, "bonus barro NO nulo (%.3f) [regresion B1.3]" % b)
	_check(absf(b - 0.3) < 0.001, "bonus barro == 0.3")
	# Clave distinta -> 0.0 (el puente no inventa bonos)
	var b2: float = TerrainModifiers.get_equipment_bonus(fe, 0)
	_check(b2 == 0.0, "cesped sin bono -> 0.0 (clave distinta)")
	# End-to-end: barro 5.0 x 0.6 x (1+0.3) = 3.9
	var prov := root.get_node_or_null("TerrainProvider")
	var eff: float = TerrainModifiers.calculate_full(5.0, prov, 1, fe)
	_check(absf(eff - 3.9) < 0.01, "calculate_full barro+equipo = 3.9 (%.3f)" % eff)
	fe.free()


## B1.1 — Player.tscn monta el detector como RayCast3D con la API esperada.
func _test_detector_montado() -> void:
	var packed: PackedScene = load("res://scenes/player/Player.tscn")
	_check(packed != null, "Player.tscn carga")
	if packed == null:
		return
	var player: Node = packed.instantiate()
	var det: Node = player.get_node_or_null("TerrainDetector")
	_check(det != null, "Player.tscn monta TerrainDetector (B1.1)")
	if det != null:
		_check(det is RayCast3D, "TerrainDetector es RayCast3D")
		_check(det.has_method("get_current_terrain_id"), "detector expone get_current_terrain_id")
		_check(det.has_signal("terrain_changed"), "detector emite terrain_changed")
	player.free()


## B2 — player.gd usa la velocidad efectiva y ya NO el multiplicador de equipo viejo.
func _test_player_integracion() -> void:
	var f := FileAccess.open("res://scripts/player/player.gd", FileAccess.READ)
	_check(f != null, "player.gd legible")
	if f == null:
		return
	var src := f.get_as_text()
	f.close()
	_check(not src.contains("_equip_speed_mult"), "player.gd ya NO usa _equip_speed_mult (B2)")
	_check(src.contains("_current_effective_speed"), "player.gd usa _current_effective_speed (B2)")
	_check(src.contains("_update_effective_speed"), "player.gd define/llama _update_effective_speed (B2)")
	_check(src.contains("TerrainModifiers.calculate_full"), "player.gd integra TerrainModifiers (B2)")
