# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Pruebas de Stress — StressRunner
# Orquestador headless (batch mode) de escenarios de stress.
# Adaptación GDScript del diseño Unity/C# de 04-Codigo.md §1.1/§2.
# Uso:
#   Godot --headless --path game/isla-ancestral --script res://scripts/stress/stress_runner.gd
# El runner registra escenarios, los ejecuta (setup->execute->teardown),
# consolida métricas, genera el reporte JSON y devuelve código de salida.
#
# ⚠️ Sin class_name: es el script raíz de SceneTree en modo batch.

extends SceneTree

## Preloads (nombres SIN colisionar con class_name §9.52 de guía 07).
const _SC_SAVE := preload("res://scripts/stress/escenarios/save_load_stress.gd")
const _SC_BLOCK := preload("res://scripts/stress/escenarios/block_edit_stress.gd")
const _SC_INVENTORY := preload("res://scripts/stress/escenarios/inventory_stress.gd")
const _SC_EQUIPMENT := preload("res://scripts/stress/escenarios/equipment_stress.gd")
const _SC_BASE := preload("res://scripts/stress/stress_scenario.gd")

const RUTA_REPORTE := "user://stress_report.json"

var _escenarios: Array = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_escenarios = _registrar_escenarios()
	if _escenarios.is_empty():
		push_error("[M113] Sin escenarios registrados")
		quit(1)
		return
	var reporte := _ejecutar_todos()
	_escribir_reporte(reporte)
	var ok := _es_check_status(reporte)
	print("=== [M113] StressRunner completado: %d escenarios ===" % _escenarios.size())
	quit(0 if ok else 1)

func _registrar_escenarios() -> Array:
	return [
		_SC_SAVE.new(),
		_SC_BLOCK.new(),
		_SC_INVENTORY.new(),
		_SC_EQUIPMENT.new(),
	]

func _ejecutar_todos() -> Dictionary:
	var corridas: Array = []
	var memoria_inicial := OS.get_static_memory_usage()
	var inicio_total := Time.get_ticks_msec()
	for escenario in _escenarios:
		corridas.append(_ejecutar_uno(escenario))
	var duracion_total := Time.get_ticks_msec() - inicio_total
	var memoria_final := OS.get_static_memory_usage()
	return {
		"generado_iso": Time.get_datetime_string_from_system(true),
		"duracion_total_ms": duracion_total,
		"memoria_static_inicial_kb": memoria_inicial / 1024,
		"memoria_static_final_kb": memoria_final / 1024,
		"escenarios": corridas,
	}

func _ejecutar_uno(escenario) -> Dictionary:
	var nombre: String = escenario.nombre()
	var status := "ok"
	var errores: Array = []
	var inicio := Time.get_ticks_msec()
	escenario.setup()
	var metrics = escenario.execute()
	escenario.teardown()
	var duracion := Time.get_ticks_msec() - inicio
	return {
		"escenario": nombre,
		"status": status,
		"duracion_ms": duracion,
		"metricas": metrics,
		"errores": errores,
	}

func _escribir_reporte(reporte: Dictionary) -> void:
	var json := JSON.stringify(reporte, "  ")
	var file := FileAccess.open(RUTA_REPORTE, FileAccess.WRITE)
	if file == null:
		push_warning("[M113] No se pudo escribir reporte en %s" % RUTA_REPORTE)
		return
	file.store_string(json)
	file.close()
	print("[M113] Reporte escrito: %s (%d bytes)" % [RUTA_REPORTE, json.length()])

func _es_check_status(reporte: Dictionary) -> bool:
	for escenario in reporte.get("escenarios", []):
		if String(escenario.get("status", "ok")) != "ok":
			return false
	return true