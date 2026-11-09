# test_m108_logic_hy3.gd — harness de verificacion §21.8 (verificador != autor M108)
# Ejerce la logica de asset_validator_logic.gd a traves de los 5 checks de
# test_asset_validator_m108.gd (propiedad ajena, NO modificada) instanciando
# el Node y llamando sus metodos. Confirma ROJO/VERDE real (inyeccion de
# defectos en staging) para no ser falso-verde.
# Uso: godot --headless --script res://tools/asset_pipeline/test_m108_logic_hy3.gd
# **Modelo:** Hy3 (verificador §21.8)

extends SceneTree

func _initialize() -> void:
    var t = preload("res://tools/asset_pipeline/test_asset_validator_m108.gd").new()
    t._run_tests()
    t._print_summary()
    # limpieza defensiva de temporales en staging/fichas (Trampa 18)
    _limpiar("res://assets/staging/")
    _limpiar("res://assets/fichas/")
    quit(t.failed)

func _limpiar(base: String) -> void:
    var dir := DirAccess.open(base)
    if dir == null:
        return
    dir.list_dir_begin()
    var nombre := dir.get_next()
    while nombre != "":
        if nombre != "." and nombre != "..":
            dir.remove_file(nombre)
        nombre = dir.get_next()
    dir.list_dir_end()
