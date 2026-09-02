# atlas_builder.gd — M108 Pipeline de Assets (wrapper EditorScript)
# Ejecutar desde: Project > Pipeline de Assets > Construir Atlas
# Uso: seleccionar categoría en FileSystem y ejecutar script.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends EditorScript

func _run() -> void:
    var logic := preload("res://tools/asset_pipeline/atlas_builder_logic.gd").new()
    var categoria := "default"
    var seleccion := EditorInterface.get_selection()
    if not seleccion.get_selected_nodes().is_empty():
        var recurso := seleccion.get_selected_nodes()[0]
        if recurso is String and recurso.contains("/"):
            categoria = recurso.split("/")[-1]

    var resultado := logic.construir_atlas(categoria)
    print("[M108] atlas_builder: %d atlas generados, %d errores" % [resultado.atlas_generados, resultado.errores_total])
    for detalle in resultado.detalles:
        if not detalle.errores.is_empty():
            print("  %s: %s" % [detalle.atlas, ", ".join(detalle.errores)])
