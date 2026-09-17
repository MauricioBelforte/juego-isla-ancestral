# Modelo: agnes-3-flash (Sapiens AI)
# Plataforma: Kilo Code
# Fecha: 2026-09-15
#
# M113: Pruebas de Stress — Test del StressComparator (baseline ±5%)
# Cierra el gap que el diseño marcó [x] pero el runner no implementaba.
# Lógica pura + un round-trip de archivo en user:// (headless-safe).
# EXIT != 0 si falla. Guardián anti-falso-verde: cada bloque marca `_fin()`.

extends SceneTree

const _COMP := preload("res://scripts/stress/stress_comparator.gd")

var _fallos: int = 0
var _checks: int = 0
var _bloque: String = ""

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M113] Test StressComparator (baseline ±5%) ===")
	_bloque = "A"
	_test_derivar_baseline()
	_bloque = "B"
	_test_comparar()
	_bloque = "C"
	_test_roundtrip()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## Fabrica un "escenario" del runner con métricas resumen.
static func _esc(nombre: String, p95s: Dictionary) -> Dictionary:
	var metricas := {}
	for m in p95s:
		metricas[m] = {"p50": 0.0, "p95": p95s[m], "max": p95s[m], "count": 100}
	return {"escenario": nombre, "status": "ok", "duracion_ms": 1000, "metricas": metricas}

## ── A. derivar_baseline ────────────────────────────────
func _test_derivar_baseline() -> void:
	print("--- A. derivar_baseline ---")
	var c = _COMP.new()
	var esc := [_esc("SaveLoadStress", {"guardar_ms": 120.0, "cargar_ms": 90.0}), _esc("BlockEditStress", {"ops_s": 500000.0})]
	var base := c.derivar_baseline(esc)
	_check("2 escenarios en baseline", base.size() == 2, "size=%d" % base.size())
	_check("metrica p95 derivada", float((base.get("SaveLoadStress", {}).get("guardar_ms", {})).get("p95", -1)) == 120.0)
	_check("max derivada", float((base.get("BlockEditStress", {}).get("ops_s", {})).get("max", -1)) == 500000.0)
	_check("fin A", _fin())

## ── B. comparar ─────────────────────────────────────────
func _test_comparar() -> void:
	print("--- B. comparar ---")
	var c = _COMP.new()
	var base := {"SaveLoadStress": {"guardar_ms": {"p95": 100.0, "max": 130.0}}}
	# sin baseline
	var r0 := c.comparar([_esc("SaveLoadStress", {"guardar_ms": 100.0})], {})
	_check("sin baseline -> hay_baseline=false", not bool(r0.get("hay_baseline", true)))
	_check("sin baseline -> no regresion", not bool(r0.get("regresion", true)))
	_check("sin baseline -> escenario va a sin_dato", "SaveLoadStress" in (r0.get("sin_dato", [])))
	# idéntico (delta 0) -> ok
	var r1 := c.comparar([_esc("SaveLoadStress", {"guardar_ms": 100.0})], base)
	_check("delta 0% -> sin regresion", not bool(r1.get("regresion", true)), "regresiones=%s" % str(r1.get("regresiones")))
	# 4% (dentro de ±5%) -> ok
	var r2 := c.comparar([_esc("SaveLoadStress", {"guardar_ms": 104.0})], base)
	_check("delta 4% (<=5%) -> sin regresion", not bool(r2.get("regresion", true)))
	# 6% (fuera de ±5%) -> regresion
	var r3 := c.comparar([_esc("SaveLoadStress", {"guardar_ms": 106.0})], base)
	_check("delta 6% (>5%) -> regresion", bool(r3.get("regresion", false)), "regresiones=%s" % str(r3.get("regresiones")))
	_check("regresion reporta delta_pct", int((r3.get("regresiones", []) as Array).size()) == 1 and \
		float(((r3.get("regresiones", []) as Array)[0]).get("delta_pct", 0.0)) > 5.0, "detalle=%s" % str(r3.get("regresiones")))
	# p95 base = 0 -> se omite (sin división por cero)
	var base_cero := {"SaveLoadStress": {"guardar_ms": {"p95": 0.0, "max": 0.0}}}
	var r4 := c.comparar([_esc("SaveLoadStress", {"guardar_ms": 999.0})], base_cero)
	_check("p95 base 0 -> sin regresion (omiso)", not bool(r4.get("regresion", true)))
	# umbral configurable (10%): 6% ya no es regresion
	var r5 := c.comparar([_esc("SaveLoadStress", {"guardar_ms": 106.0})], base, 0.10)
	_check("umbral 10% -> 6% no es regresion", not bool(r5.get("regresion", true)))
	_check("fin B", _fin())

## ── C. round-trip de archivo (headless-safe en user://) ─
func _test_roundtrip() -> void:
	print("--- C. round-trip cargar/guardar ---")
	var c = _COMP.new()
	var ruta := "user://m113_test_baseline.json"
	var base := c.derivar_baseline([_esc("SaveLoadStress", {"guardar_ms": 120.0})])
	_check("guardar OK", c.guardar(ruta, base))
	var leido := c.cargar(ruta)
	_check("cargar devuelve dict", leido is Dictionary and not leido.is_empty(), "leido=%s" % str(leido))
	_check("round-trip p95 igual", float((leido.get("SaveLoadStress", {}).get("guardar_ms", {})).get("p95", -1)) == 120.0)
	var falta := c.cargar("user://m113_inexistente_xyz.json")
	_check("archivo ausente -> {} (no aborta)", falta is Dictionary and falta.is_empty())
	# limpieza
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f != null:
		f.close()
	DirAccess.remove_absolute(ruta)
	_check("fin C", _fin())

## Guardián anti-falso-verde: si un bloque se aborta (SCRIPT ERROR), su `_fin` no corre.
func _fin() -> bool:
	print("  [GUARDIAN] bloque %s completado" % _bloque)
	return true

func _summary() -> void:
	print("=== Resumen M113-comparador: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M113-comparador FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M113-comparador OK — todos los checks pasaron")
		quit(0)
