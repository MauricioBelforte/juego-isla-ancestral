# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Pruebas de Stress — Test headless
# Valida: StressScenario (p50/p95/max), SaveLoadStress (100 ciclos
# con DataStore si disponible), BlockEditStress (100k ops simuladas).
# Exit code != 0 si falla.
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_BASE := preload("res://scripts/stress/stress_scenario.gd")
const _SC_BLOCK := preload("res://scripts/stress/escenarios/block_edit_stress.gd")
const _SC_SAVE := preload("res://scripts/stress/escenarios/save_load_stress.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M113] Test de Pruebas de Stress ===")
	_test_stress_scenario_base()
	_test_block_edit_stress()
	_test_save_load_stress()
	_summary()

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])

## ── StressScenario base ─────────────────────────────────

func _test_stress_scenario_base() -> void:
	print("--- StressScenario: metricas p50/p95 ---")
	var s = _SC_BASE.new()
	s._registrar_metrica("tiempo_ms", 1.0)
	s._registrar_metrica("tiempo_ms", 2.0)
	s._registrar_metrica("tiempo_ms", 3.0)
	s._registrar_metrica("tiempo_ms", 100.0)
	s._registrar_metrica("tiempo_ms", 200.0)
	var res := s.resumen_metricas()
	var t: Dictionary = res.get("tiempo_ms", {})
	_check("p50 presente", t.has("p50") and t["p50"] > 0, "p50=%s" % t.get("p50", "?"))
	_check("p95 presente", t.has("p95") and t["p95"] > 0, "p95=%s" % t.get("p95", "?"))
	_check("max presente", t.has("max") and t["max"] == 200.0, "max=%s" % t.get("max", "?"))
	_check("count correcto", t.get("count", 0) == 5, "count=%d" % t.get("count", 0))
	_check("p50 calculado", snappedf(t.get("p50", 0), 0.001) == 3.0, "p50=%s" % t.get("p50", "?"))
	_check("p95 calculado", snappedf(t.get("p95", 0), 0.001) == 180.0, "p95=%s" % t.get("p95", "?"))
	var vacia := s._resumen_metrica([])
	_check("metrica vacia -> ceros", vacia.get("count", -1) == 0 and vacia.get("p50", -1) == 0.0)
	var medido := s._medir_ms(func(): return 42)
	_check("medir ms devuelve ms >= 0", medido.get("ms", -1) >= 0)
	_check("medir ms devuelve resultado", int(medido.get("resultado", 0)) == 42)

## ── BlockEditStress ─────────────────────────────────────

func _test_block_edit_stress() -> void:
	print("--- BlockEditStress: 100k operaciones simuladas ---")
	var s = _SC_BLOCK.new()
	_check("nombre correcto", s.nombre() == "BlockEditStress")
	s.setup()
	var metrics := s.execute()
	s.teardown()
	_check("metricas no vacias", not metrics.is_empty(), "size=%d" % metrics.size())
	var ops_s_metric: Dictionary = metrics.get("ops_s", {})
	_check("ops_s medido", ops_s_metric.get("count", 0) > 0 and ops_s_metric.get("p50", 0) > 0, "p50=%s" % ops_s_metric.get("p50", "?"))

## ── SaveLoadStress ──────────────────────────────────────

func _test_save_load_stress() -> void:
	print("--- SaveLoadStress: 100 ciclos guardar/cargar ---")
	var ds := root.get_node_or_null("DataStore")
	if ds == null:
		_check("DataStore no disponible (build parcial)", true)
		return
	var s = _SC_SAVE.new()
	_check("nombre correcto", s.nombre() == "SaveLoadStress")
	s.setup()
	var metrics = s.execute()
	s.teardown()
	_check("metricas guardar_ms presentes", metrics.has("guardar_ms"), "keys=%s" % str(metrics.keys()))
	_check("metricas cargar_ms presentes", metrics.has("cargar_ms"))
	var guardar_metric: Dictionary = metrics.get("guardar_ms", {})
	var cargar_metric: Dictionary = metrics.get("cargar_ms", {})
	_check("guardar_ms count >= 100", guardar_metric.get("count", 0) >= 100, "count=%d" % guardar_metric.get("count", 0))
	_check("cargar_ms count >= 100", cargar_metric.get("count", 0) >= 100, "count=%d" % cargar_metric.get("count", 0))
	_check("guardar_ms p50 < 1000 ms", guardar_metric.get("p50", 99999) < 1000.0, "p50=%s" % guardar_metric.get("p50", "?"))
	_check("cargar_ms p50 < 1000 ms", cargar_metric.get("p50", 99999) < 1000.0, "p50=%s" % cargar_metric.get("p50", "?"))

## ── Summary ──────────────────────────────────────────────

func _summary() -> void:
	print("=== Resumen M113: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M113 FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M113 OK — todos los checks pasaron")
		quit(0)