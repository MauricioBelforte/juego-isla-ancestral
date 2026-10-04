# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-04
#
# M156 — Test headless de TerrainModifiers (M156) + TerrainDataProvider (M08).
#
# Convertido desde la suite gdUnit4 ORIGINAL (BUG-093): usaba
# `assert_that(x).is_equal_to(y)` (4x) e `is_greater_than` (1x), metodos que
# NO existen en gdUnit4 (0 apariciones en addons/gdUnit4/; los reales son
# `is_equal`/`is_greater`). La suite PARSEABA (EXIT 0) pero MORIA en runtime ->
# nunca afirmaba nada (clase de suite muerta mas silenciosa que is_instance_of).
# Se reescribe al estandar headless del proyecto (`extends SceneTree` + asserts
# nativos, metodo 12.1).
#
#   A. TerrainModifiers (M156)    calculate_effective_speed: formula, cap 50%, clamp
#   B. TerrainDataProvider (M08)  speed_modifier de los .tres reales + fallback 1.0
#
# ⚠️ Guardia anti-falso-verde (3 capas, trampas 11/63/122):
#   1) cada bloque cierra con `_fin(letra)`; si aborta en silencio, la letra falta y `_summary()` FALLA;
#   2) piso `CHECKS_MINIMOS` MEDIDO en verde;
#   3) `_summary()` en un `call_deferred` SEPARADO (si `_run()` aborta, igual corre).
#   Watchdog por temporizador: si la suite no termina, cierra con codigo 1.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral --script res://tests/unit/terrain/test_terrain_modifiers.gd

extends SceneTree

const TIMEOUT_SEG := 60.0
## Piso de checks MEDIDO en verde (no estimado): un aborto parcial baja el conteo.
const CHECKS_MINIMOS := 10
const BLOQUES_ESPERADOS: Array[String] = ["A", "B"]

const MODIFIERS := preload("res://scripts/terrenos/terrain_modifiers.gd")
const PROVIDER := preload("res://scripts/terrain/terrain_data_provider.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = "(inicio)"
var _abortado: bool = false
var _completados: Array[String] = []
var _checks_por_bloque: Dictionary = {}
var _checks_marca: int = 0


func _init() -> void:
	call_deferred("_run")
	# `_summary()` en la cola diferida: si `_run()` muere por un SCRIPT ERROR,
	# la cola sigue y el resumen CORRE igual (nombra los bloques faltantes).
	call_deferred("_summary")


func _run() -> void:
	create_timer(TIMEOUT_SEG, true).timeout.connect(_on_watchdog)
	print("=== [M156] TerrainModifiers + TerrainDataProvider (headless) ===")
	_bloque_a_modifiers()
	_bloque_b_provider()


func _on_watchdog() -> void:
	_abortado = true
	print("[M156] WATCHDOG: la suite no termino en %.0f s — ABORTO (ultimo bloque: %s)" % [TIMEOUT_SEG, _bloque])
	quit(1)


## ── Helpers ─────────────────────────────────────────────

func _ini(nombre: String) -> void:
	_bloque = nombre
	_checks_marca = _checks
	print("\n-- %s --" % nombre)


func _fin(nombre: String) -> void:
	var letra: String = nombre.substr(0, 1)
	if not _completados.has(letra):
		_completados.append(letra)
	var delta: int = _checks - _checks_marca
	_checks_por_bloque[letra] = int(_checks_por_bloque.get(letra, 0)) + delta
	_checks_marca = _checks
	print("[FIN] %s (+%d checks)" % [nombre, delta])


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _summary() -> void:
	# Capa 1: bloques que no cerraron (aborto silencioso M124).
	var faltantes: Array[String] = []
	for letra in BLOQUES_ESPERADOS:
		if not _completados.has(letra):
			faltantes.append(letra)
	_check("los 2 bloques se completaron (sin abortos silenciosos)", faltantes.is_empty(),
		"bloques que no terminaron: %s" % str(faltantes))
	# Capa 2: piso de checks medido en verde.
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("Checks por bloque: %s" % str(_checks_por_bloque))
	print("\n=== Resumen M156 TerrainModifiers: %d checks, %d fallos ===" % [_checks, _fallos])
	if _abortado:
		print("TEST M156 TerrainModifiers ABORTADO por watchdog")
		quit(1)
	elif _fallos == 0:
		print("TEST M156 TerrainModifiers OK — todos los checks pasaron")
		quit(0)
	else:
		print("TEST M156 TerrainModifiers FALLO — %d checks fallaron" % _fallos)
		quit(1)


## ── A. TerrainModifiers (M156) ───────────────────────────

func _bloque_a_modifiers() -> void:
	_ini("A. TerrainModifiers.calculate_effective_speed")
	# Formula (diseño §3.1): base × max(terreno, 0.1) × (1 + clamp(equipo, 0, 0.5))
	# NOTA: el test gdUnit4 original esperaba 4.2 para (5.0, 0.8, 0.2); el codigo y el
	# diseño dan 4.8 (= 5.0 × 0.8 × 1.2). 4.2 era una expectativa OBSOLETA (BUG-093).
	var v1: float = MODIFIERS.calculate_effective_speed(5.0, 0.8, 0.2)
	_check("5.0 × 0.8 × (1+0.2) == 4.8", is_equal_approx(v1, 4.8), "v=%.4f" % v1)
	# Cap de equipo 50% (§3.1): 0.9 se clampa a 0.5.
	var v2: float = MODIFIERS.calculate_effective_speed(5.0, 1.0, 0.9)
	_check("cap equipo 50%: 5.0 × 1.0 × 1.5 == 7.5", is_equal_approx(v2, 7.5), "v=%.4f" % v2)
	# Equipo negativo se clampa a 0 (no reduce por debajo de base×terreno).
	var v3: float = MODIFIERS.calculate_effective_speed(1.0, 0.1, -2.0)
	_check("equipo negativo clampa a 0: 1.0 × 0.1 × 1.0 == 0.1", is_equal_approx(v3, 0.1), "v=%.4f" % v3)
	_check("velocidad efectiva siempre > 0", v3 > 0.0, "v=%.4f" % v3)
	_fin("A. modifiers")


## ── B. TerrainDataProvider (M08) ─────────────────────────

func _bloque_b_provider() -> void:
	_ini("B. TerrainDataProvider (M08) speed modifiers")
	var provider: Node = PROVIDER.new()
	_check("provider instanciado", provider != null)
	provider._ready()
	var s0: float = provider.get_speed_modifier(0)
	var s1: float = provider.get_speed_modifier(1)
	var s999: float = provider.get_speed_modifier(999)
	_check("get_speed_modifier(0) == 1.0 (cesped)", is_equal_approx(s0, 1.0), "v=%.4f" % s0)
	_check("get_speed_modifier(1) == 0.6 (barro)", is_equal_approx(s1, 0.6), "v=%.4f" % s1)
	_check("get_speed_modifier(999) == 1.0 (fallback)", is_equal_approx(s999, 1.0), "v=%.4f" % s999)
	_check("get_speed_modifier devuelve float", typeof(s0) == TYPE_FLOAT)
	provider.free()
	_fin("B. provider")
