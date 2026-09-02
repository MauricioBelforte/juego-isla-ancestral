# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M113: Escenario — BlockEditStress
# Edición masiva de bloques simulada (100k operaciones de edición voxel
# sobre un modelo de datos en memoria). Mide operaciones/s, memoria y
# tiempo de procesamiento batch. Cuando el M08 esté conectado, se puede
# sustituir la simulación por llamadas reales a VoxelTool.
# Diseño original (04-Codigo.md §1.1, escenario 1).

class_name BlockEditStress
extends StressScenario

const TOTAL_OPERACIONES: int = 100000
const CHUNK_SIZE: int = 16

var _mundo: Dictionary = {}  # coord_str -> chunk_data (PackedInt32Array)
var _stats: Dictionary = {}

func _init() -> void:
	_nombre = "BlockEditStress"

func setup() -> void:
	_mundo = {}
	_stats = {}
	print("[M113] BlockEditStress: %d operaciones simuladas" % TOTAL_OPERACIONES)

func execute() -> Dictionary:
	var inicio := Time.get_ticks_msec()
	var operaciones_ok := 0
	var seed := 0
	for i in range(TOTAL_OPERACIONES):
		# Simular coordenada pseudoaleatoria determinista
		seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
		var cx: int = (seed % 100) - 50
		seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
		var cy: int = (seed % 10) - 2
		seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
		var cz: int = (seed % 100) - 50
		seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
		var tipo: int = (seed % 5) + 1
		var clave := "%d_%d_%d" % [cx, cy, cz]
		if not _mundo.has(clave):
			_mundo[clave] = PackedInt32Array()
		var chunk: PackedInt32Array = _mundo[clave]
		chunk.append(tipo)
		operaciones_ok += 1
		# Registrar métrica cada 1000 operaciones
		if i % 1000 == 999:
			var pct := float(i + 1) / float(TOTAL_OPERACIONES) * 100.0
			_registrar_metrica("operaciones_ok", float(operaciones_ok))
			var tiempo_parcial := Time.get_ticks_msec() - inicio
			var ops_s := float(i + 1) / (float(tiempo_parcial) / 1000.0) if tiempo_parcial > 0 else 0.0
			_registrar_metrica("ops_s", ops_s)
	var duracion_total := Time.get_ticks_msec() - inicio
	_stats["chunks_generados"] = _mundo.size()
	_stats["duracion_ms"] = duracion_total
	_stats["ops_s"] = float(TOTAL_OPERACIONES) / (float(duracion_total) / 1000.0) if duracion_total > 0 else 0.0
	_stats["total_operaciones"] = operaciones_ok
	print("[M113] BlockEditStress: %d op en %d ms (%.0f ops/s) en %d chunks" % [operaciones_ok, duracion_total, _stats["ops_s"], _mundo.size()])
	return resumen_metricas()

func teardown() -> void:
	_mundo.clear()
	print("[M113] BlockEditStress: teardown completado")