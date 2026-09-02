# retire_asset.gd — M108 Pipeline de Assets (wrapper EditorScript)
# Ejecutar desde: Project > Pipeline de Assets > Retirar Asset
# Uso: seleccionar archivo en FileSystem y ejecutar script.
#
# **Modelo:** stepfun/step-3.7-flash:free
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends EditorScript

func _run() -> void:
    var logic := preload("res://tools/asset_pipeline/retire_asset_logic.gd").new()
    var seleccion := EditorInterface.get_selection()
    if seleccion.get_selected_nodes().is_empty():
        print("[M108] retire_asset: selecciona un archivo en FileSystem.")
        return

    var recurso := seleccion.get_selected_nodes()[0]
    if recurso is not String:
        var ruta := recurso.resource_path if recurso.has_method("get_path") else ""
        if ruta.is_empty():
            print("[M108] retire_asset: no se pudo obtener la ruta del recurso.")
            return
        var nombre := ruta.get_file()
        var resultado := logic.retirar_asset(nombre)
        if resultado.retirado:
            print("[M108] retire_asset: '%s' retirado a archive/." % nombre)
        else:
            print("[M108] retire_asset: advertencias en '%s': %s" % [nombre, ", ".join(resultado.advertencias)])
