# Modelo: atria (Atria-Dawn-Preview)
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M08: Tests del BlockCatalog canónico (unificación Log 1728).
# Cobertura: la library tiene un modelo por id (0..32 contiguos), el índice
# del modelo == block id para todos, get_block resuelve todos los ids, y el
# fallback de get_debug_color del IslandGenerator sin catálogo.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/world/test_block_catalog_m08.gd

extends SceneTree

# Guardia anti-falso-verde (instrumentación LOTE 2, Log 1490)
const CHECKS_MINIMOS := 15
const _WB_BLOQUES: Array[String] = ["_test_invariante_library", "_test_get_block", "_test_debug_color_sin_catalogo"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false
var _fallos: int = 0

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
	print("=== Resumen M08 BlockCatalog: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	_test_invariante_library()
	_fin("_test_invariante_library")
	_test_get_block()
	_fin("_test_get_block")
	_test_debug_color_sin_catalogo()
	_fin("_test_debug_color_sin_catalogo")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## C1: la library canónica tiene un modelo por id, contiguo, índice == id.
## Invariante crítico: el canal CHANNEL_TYPE guarda el id y VoxelMesherBlocky
## lo usa como índice del modelo.
func _test_invariante_library() -> void:
	var cat := BlockCatalog.new()
	_check(cat.get_model_count() == 33, "la library tiene 33 modelos (0..32), tiene %d" % cat.get_model_count())
	_check(cat.get_library() != null, "get_library() no es null")
	for id in range(33):
		_check(cat.get_model_index(id) == id, "get_model_index(%d) == %d" % [id, id])
	# TIERRA_ARADA (M33) presente en la library canónica
	_check(cat.get_model_index(BlockType.TIERRA_ARADA) == 31, "TIERRA_ARADA en el indice 31")
	_check(cat.get_model_index(BlockType.TIERRA_ARADA_HUMEDA) == 32, "TIERRA_ARADA_HUMEDA en el indice 32")

## C2: get_block resuelve todos los ids registrados con sus datos.
func _test_get_block() -> void:
	var cat := BlockCatalog.new()
	for id in range(33):
		_check(cat.get_block(id) != null, "get_block(%d) resuelve un BlockType" % id)
	var bt_tierra := cat.get_block(BlockType.TIERRA_ARADA)
	_check(bt_tierra != null and bt_tierra.display_name == "Tierra Arada", "TIERRA_ARADA tiene el nombre 'Tierra Arada'")
	var bt_humeda := cat.get_block(BlockType.TIERRA_ARADA_HUMEDA)
	_check(bt_humeda != null and bt_humeda.display_name == "Tierra Arada Húmeda", "TIERRA_ARADA_HUMEDA tiene el nombre 'Tierra Arada Húmeda'")
	_check(bt_humeda != null and bt_humeda.tool_required == BlockType.ToolRequirement.SHOVEL, "la tierra arada requiere pala")
	# id fuera de rango: null (no crash)
	_check(cat.get_block(999) == null, "get_block(999) devuelve null sin crash")

## C3: get_debug_color del IslandGenerator funciona sin catálogo (como en
## producción, donde se pasa null) — antes era un dead path que crasheaba.
func _test_debug_color_sin_catalogo() -> void:
	var gen := IslandGenerator.new(null, 42)
	var id_en_pos := gen.get_block_at(10, 5, 10)
	var color := gen.get_debug_color(10, 5, 10)
	var esperado := BlockType.create_default(id_en_pos).debug_color
	_check(color == esperado, "get_debug_color sin catalogo == create_default(%d).debug_color" % id_en_pos)
	var color2 := gen.get_debug_color(10, 5, 10)
	_check(color == color2, "get_debug_color es determinista para la misma posicion")
