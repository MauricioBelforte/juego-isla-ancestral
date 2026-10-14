# run_m108_memory_test.gd — M108: test headless del memory reporter contra un caso conocido.
# Crea fixtures de tamaño exacto en assets/final/, ejecuta la lógica, verifica los
# números estimados (VRAM/RAM por extensión) y el path de error de archivo vacío,
# y limpia los fixtures. Self-contained: no deja rastro en assets/final/.
#
# Uso: godot --headless --path game/isla-ancestral -s res://tools/asset_pipeline/run_m108_memory_test.gd
#
# Caso conocido (reglas de asset_memory_reporter_logic.gd):
#   png 1 MiB -> RAM 1.00 MB, VRAM 0.80 MB (x0.8)
#   glb 2 MiB -> RAM 2.00 MB, VRAM 3.00 MB (x1.5)
#   ogg 0.5 MiB -> RAM 0.50 MB, VRAM 0.00 MB
#   png vacío -> ERROR "archivo vacío", 0 MB
#   Totales esperados: RAM 3.50 MB, VRAM 3.80 MB, 1 archivo con errores
#
# **Modelo:** Ling 3.1 Flash
# **Plataforma:** Kilo Code
# **Fecha:** 2026-10-14

extends SceneTree

const RAIZ := "res://assets/final/"
const TOLERANCIA := 0.001

const FIXTURES := [
	{ "archivo": "m108_test_a.png", "bytes": 1048576, "ram": 1.0, "vram": 0.8 },
	{ "archivo": "m108_test_b.glb", "bytes": 2097152, "ram": 2.0, "vram": 3.0 },
	{ "archivo": "m108_test_c.ogg", "bytes": 524288, "ram": 0.5, "vram": 0.0 },
	{ "archivo": "m108_test_d.png", "bytes": 0, "ram": 0.0, "vram": 0.0 },
]

var _fallos := 0

func _init() -> void:
	_limpiar_rastro()
	_crear_fixtures()

	var logic := preload("res://tools/asset_pipeline/asset_memory_reporter_logic.gd").new()
	var reporte := logic.generar_reporte(RAIZ)

	if reporte.detalles.size() != FIXTURES.size():
		_fallos += 1
		print("[M108 TEST MEM] FALLO: detalles=%d, esperado=%d" % [reporte.detalles.size(), FIXTURES.size()])
	else:
		print("[M108 TEST MEM] detalles: %d fixtures procesados" % reporte.detalles.size())

	for fx in FIXTURES:
		var detalle = _detalle_por(reporte, fx["archivo"])
		if detalle == null:
			_fallos += 1
			print("[M108 TEST MEM] FALLO: falta el detalle de %s" % fx["archivo"])
			continue
		var ram_ok = abs(detalle.ram_estimado_mb - float(fx["ram"])) < TOLERANCIA
		var vram_ok = abs(detalle.vram_estimado_mb - float(fx["vram"])) < TOLERANCIA
		if ram_ok and vram_ok:
			print("[M108 TEST MEM] %s: RAM=%.2f MB (esperado %.2f), VRAM=%.2f MB (esperado %.2f) — OK" % [detalle.archivo, detalle.ram_estimado_mb, float(fx["ram"]), detalle.vram_estimado_mb, float(fx["vram"])])
		else:
			_fallos += 1
			print("[M108 TEST MEM] FALLO %s: RAM=%.2f (esperado %.2f), VRAM=%.2f (esperado %.2f)" % [detalle.archivo, detalle.ram_estimado_mb, float(fx["ram"]), detalle.vram_estimado_mb, float(fx["vram"])])

	var ram_total_ok = abs(reporte.total_ram_mb - 3.50) < TOLERANCIA
	var vram_total_ok = abs(reporte.total_vram_mb - 3.80) < TOLERANCIA
	print("[M108 TEST MEM] Totales: VRAM=%.2f MB (esperado 3.80), RAM=%.2f MB (esperado 3.50)" % [reporte.total_vram_mb, reporte.total_ram_mb])
	if not (ram_total_ok and vram_total_ok):
		_fallos += 1
		print("[M108 TEST MEM] FALLO: totales fuera de tolerancia")

	var archivos_con_error := 0
	for detalle in reporte.detalles:
		if detalle.errores.size() > 0:
			archivos_con_error += 1
			print("[M108 TEST MEM] errores en %s: %s" % [detalle.archivo, ", ".join(detalle.errores)])
	if archivos_con_error != 1:
		_fallos += 1
		print("[M108 TEST MEM] FALLO: archivos con errores=%d, esperado 1 (fixture vacío)" % archivos_con_error)

	_limpiar_rastro()

	if _fallos == 0:
		print("[M108 TEST MEM] RESULTADO: PASS (caso conocido verificado: 4 fixtures, totales RAM 3.50 / VRAM 3.80 MB, path de archivo vacío OK)")
		quit(0)
	else:
		print("[M108 TEST MEM] RESULTADO: FAIL (%d fallos)" % _fallos)
		quit(1)

func _detalle_por(reporte, nombre: String):
	for detalle in reporte.detalles:
		if detalle.archivo == nombre:
			return detalle
	return null

func _crear_fixtures() -> void:
	var raiz_abs := ProjectSettings.globalize_path(RAIZ)
	DirAccess.make_dir_recursive_absolute(raiz_abs)
	for fx in FIXTURES:
		var ruta = RAIZ + fx["archivo"]
		var f := FileAccess.open(ruta, FileAccess.WRITE)
		if f == null:
			_fallos += 1
			push_error("[M108 TEST MEM] no se pudo crear el fixture %s" % ruta)
			continue
		if fx["bytes"] > 0:
			var buffer := PackedByteArray()
			buffer.resize(fx["bytes"])
			f.store_buffer(buffer)
		f.close()

func _limpiar_rastro() -> void:
	var raiz_abs := ProjectSettings.globalize_path(RAIZ)
	if not DirAccess.dir_exists_absolute(raiz_abs):
		return
	for fx in FIXTURES:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RAIZ + fx["archivo"]))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(RAIZ + "_memory_report.md"))
