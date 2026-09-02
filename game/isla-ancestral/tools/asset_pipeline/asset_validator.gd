# asset_validator.gd — M108 Pipeline de Assets (wrapper EditorScript)
# Ejecutar desde: Project > Pipeline de Assets > Validar
#
# **Modelo:** step-3.7-flash
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends EditorScript

func _run() -> void:
    var logic := preload("res://tools/asset_pipeline/asset_validator_logic.gd").new()
    var resultado := logic.validar_pipeline("res://assets/staging/")
    var errores := logic.escribir_reporte(resultado)

    if errores > 0:
        push_warning("[M108] Validación: %d errores encontrados." % errores)
    else:
        print("[M108] Validación: 0 errores. Todo OK.")
