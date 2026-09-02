# asset_memory_reporter.gd — M108 Pipeline de Assets (wrapper EditorScript)
# Ejecutar desde: Project > Pipeline de Assets > Memory Report
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends EditorScript

func _run() -> void:
    var logic := preload("res://tools/asset_pipeline/asset_memory_reporter_logic.gd").new()
    var reporte := logic.generar_reporte("res://assets/final/")
    print("[M108] memory_reporter: VRAM=%.2f MB, RAM=%.2f MB" % [reporte.total_vram_mb, reporte.total_ram_mb])
