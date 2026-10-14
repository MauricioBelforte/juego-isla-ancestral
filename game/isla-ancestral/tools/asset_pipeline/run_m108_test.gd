# run_m108_test.gd — M108: test headless del pipeline de staging (RF11 / CI M118).
# Valida assets/staging/ con asset_validator_logic.gd, escribe el reporte en
# tools/reportes/ y devuelve el número de errores como exit code (0 = verde).
#
# Uso: godot --headless --path game/isla-ancestral scenes/tests/test_m108.tscn
#
# **Modelo:** step-3.7-flash:free (original); Ling 3.1 Flash (reparación 2026-10-14:
# migrado a la API real ResultadoPipeline — validar_pipeline no retorna Dictionary)
# **Plataforma:** Kilo Code
# **Fecha:** 2026-09-02 (reparación 2026-10-14)

extends Node

func _ready() -> void:
    var log_lines: Array[String] = []
    log_lines.append("[M108 TEST] Iniciando test...")

    var LogicClass := load("res://tools/asset_pipeline/asset_validator_logic.gd") as GDScript
    if LogicClass == null:
        log_lines.append("[M108 TEST] ERROR: no se pudo cargar asset_validator_logic.gd")
        _guardar_log(log_lines, 1)
        get_tree().quit(1)
        return

    log_lines.append("[M108 TEST] Script cargado OK")

    var instancia: Object = LogicClass.new()
    if instancia == null:
        log_lines.append("[M108 TEST] ERROR: no se pudo instanciar asset_validator_logic.gd")
        _guardar_log(log_lines, 1)
        get_tree().quit(1)
        return

    log_lines.append("[M108 TEST] Instancia creada OK")

    var resultado = instancia.validar_pipeline("res://assets/staging/")
    log_lines.append("[M108 TEST] Pipeline validado: %d errores, %d aprobados" % [resultado.errores_total, resultado.aprobados])

    var errores: int = instancia.escribir_reporte(resultado)
    log_lines.append("[M108 TEST] Reporte escrito en tools/reportes/_validacion_staging.md: %d errores" % errores)

    log_lines.append("")
    log_lines.append("=== TEST M108: 5 checks, %d fallos ===" % errores)
    if errores > 0:
        for detalle in resultado.detalles:
            if not detalle.aprobado:
                log_lines.append("  %s: %s" % [detalle.archivo, ", ".join(detalle.errores)])
    else:
        log_lines.append("Todos los checks pasaban.")

    _guardar_log(log_lines, errores)
    get_tree().quit(errores)

func _guardar_log(lineas: Array[String], codigo: int) -> void:
    var contenido := "\n".join(lineas) + "\nExit code: %d\n" % codigo
    var ruta := "user://test_m108_log.txt"
    var f := FileAccess.open(ruta, FileAccess.WRITE)
    if f:
        f.store_string(contenido)
        f.close()
    print(contenido)
