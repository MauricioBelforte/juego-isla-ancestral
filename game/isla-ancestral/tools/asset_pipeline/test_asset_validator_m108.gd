# test_asset_validator_m108.gd — M108 Pipeline de Assets (test headless V0)
# Ejecutar: godot --headless --script res://tools/asset_pipeline/test_asset_validator_m108.gd
#
# **Modelo:** step-3.7-flash
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02

extends Node

var passed := 0
var failed := 0
var errors: Array[String] = []

func _ready() -> void:
    _run_tests()
    _print_summary()
    get_tree().quit(failed)

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------
func _run_tests() -> void:
    # Test 1: staging vacío → 0 errores
    _test_staging_vacio()

    # Test 2: archivo con nombre inválido → error NOMBRE
    _test_nombre_invalido()

    # Test 3: archivo con extensión prohibida → error FORMATO
    _test_extension_prohibida()

    # Test 4: archivo sin ficha → error FICHA
    _test_sin_ficha()

    # Test 5: archivo válido con ficha → aprobado
    _test_archivo_valido()

func _test_staging_vacio() -> void:
    var logic := preload("res://tools/asset_pipeline/asset_validator_logic.gd").new()
    var resultado := logic.validar_pipeline("res://assets/staging/")
    _assert_eq(resultado.errores_total, 0, "staging vacío → 0 errores")
    _assert_eq(resultado.aprobados, 0, "staging vacío → 0 aprobados")

func _test_nombre_invalido() -> void:
    _crear_archivo_staging("INVALID_NAME.glb", "")
    var logic := preload("res://tools/asset_pipeline/asset_validator_logic.gd").new()
    var resultado := logic.validar_pipeline("res://assets/staging/")
    _eliminar_archivo_staging("INVALID_NAME.glb")
    var tiene_nombre := false
    for detalle in resultado.detalles:
        if detalle.archivo.begins_with("INVALID_NAME"):
            for e in detalle.errores:
                if e.begins_with("NOMBRE"):
                    tiene_nombre = true
    _assert_true(tiene_nombre, "INVALID_NAME.glb → error NOMBRE")

func _test_extension_prohibida() -> void:
    _crear_archivo_staging("tex_pasto.fbx", "")
    var logic := preload("res://tools/asset_pipeline/asset_validator_logic.gd").new()
    var resultado := logic.validar_pipeline("res://assets/staging/")
    _eliminar_archivo_staging("tex_pasto.fbx")
    var tiene_formato := false
    for detalle in resultado.detalles:
        if detalle.archivo.begins_with("tex_pasto"):
            for e in detalle.errores:
                if e.begins_with("FORMATO"):
                    tiene_formato = true
    _assert_true(tiene_formato, "tex_pasto.fbx → error FORMATO")

func _test_sin_ficha() -> void:
    _crear_archivo_staging("tex_pasto.png", "")
    var logic := preload("res://tools/asset_pipeline/asset_validator_logic.gd").new()
    var resultado := logic.validar_pipeline("res://assets/staging/")
    _eliminar_archivo_staging("tex_pasto.png")
    var tiene_ficha := false
    for detalle in resultado.detalles:
        if detalle.archivo.begins_with("tex_pasto"):
            for e in detalle.errores:
                if e.begins_with("FICHA"):
                    tiene_ficha = true
    _assert_true(tiene_ficha, "tex_pasto.png sin ficha → error FICHA")

func _test_archivo_valido() -> void:
    _crear_archivo_staging("mdl_arbol_01.glb", "")
    _crear_ficha("mdl_arbol_01.md", "# Ficha: mdl_arbol_01\nLicencia: CC0\n")
    var logic := preload("res://tools/asset_pipeline/asset_validator_logic.gd").new()
    var resultado := logic.validar_pipeline("res://assets/staging/")
    _eliminar_archivo_staging("mdl_arbol_01.glb")
    _eliminar_ficha("mdl_arbol_01.md")
    var aprobado := false
    for detalle in resultado.detalles:
        if detalle.archivo.begins_with("mdl_arbol_01"):
            aprobado = detalle.aprobado
    _assert_true(aprobado, "mdl_arbol_01.glb con ficha → aprobado")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
func _crear_archivo_staging(nombre: String, contenido: String) -> void:
    var ruta := "res://assets/staging/%s" % nombre
    var dir := DirAccess.open("res://assets/staging/")
    if dir == null:
        return
    var f := FileAccess.open(ruta, FileAccess.WRITE)
    if f:
        f.store_string(contenido)
        f.close()

func _eliminar_archivo_staging(nombre: String) -> void:
    var ruta := ProjectSettings.globalize_path("res://assets/staging/%s" % nombre)
    if FileAccess.file_exists(ruta):
        DirAccess.remove_absolute(ruta)

func _crear_ficha(nombre: String, contenido: String) -> void:
    var ruta := "res://assets/fichas/%s" % nombre
    var f := FileAccess.open(ruta, FileAccess.WRITE)
    if f:
        f.store_string(contenido)
        f.close()

func _eliminar_ficha(nombre: String) -> void:
    var ruta := ProjectSettings.globalize_path("res://assets/fichas/%s" % nombre)
    if FileAccess.file_exists(ruta):
        DirAccess.remove_absolute(ruta)

# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------
func _assert_eq(actual, esperado, contexto: String) -> void:
    if actual == esperado:
        passed += 1
        print("[PASS] %s: %s == %s" % [contexto, actual, esperado])
    else:
        failed += 1
        errors.append("[FAIL] %s: esperado %s, actual %s" % [contexto, esperado, actual])

func _assert_true(valor, contexto: String) -> void:
    if valor:
        passed += 1
        print("[PASS] %s" % contexto)
    else:
        failed += 1
        errors.append("[FAIL] %s" % contexto)

func _assert_false(valor, contexto: String) -> void:
    _assert_true(not valor, contexto)

# ---------------------------------------------------------------------------
# Resumen
# ---------------------------------------------------------------------------
func _print_summary() -> void:
    print("")
    print("=== TEST M108: %d checks, %d fallos ===" % [passed + failed, failed])
    if failed > 0:
        print("Fallos:")
        for e in errors:
            print(e)
    else:
        print("Todos los checks pasaron.")
