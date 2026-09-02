# apply_import_presets.gd — M108 Pipeline de Assets (wrapper EditorScript)
# Ejecutar desde: Project > Pipeline de Assets > Aplicar Presets
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends EditorScript

func _run() -> void:
    var logic := preload("res://tools/asset_pipeline/apply_import_presets_logic.gd").new()
    var resultado := logic.aplicar_presets("res://assets/staging/")

    print("[M108] apply_import_presets: %d corregidos, %d errores" % [resultado.corregidos, resultado.errores_total])
    for detalle in resultado.detalles:
        if not detalle.errores.is_empty():
            print("  %s: %s" % [detalle.archivo, ", ".join(detalle.errores)])
