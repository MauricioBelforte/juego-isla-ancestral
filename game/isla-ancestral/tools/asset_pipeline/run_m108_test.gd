extends Node

func _ready() -> void:
    var log_lines: Array[String] = []
    log_lines.append("[M108 TEST] Iniciando test...")

    var logic: Object = load("res://tools/asset_pipeline/asset_validator_logic.gd")
    if logic == null:
        log_lines.append("[M108 TEST] ERROR: no se pudo cargar asset_validator_logic.gd")
        _guardar_log(log_lines, 1)
        return

    log_lines.append("[M108 TEST] Script cargado OK")

    var instancia: Object = logic.call("new")
    log_lines.append("[M108 TEST] Instancia creada OK")

    var resultado: Object = instancia.call("validar_pipeline", "res://assets/staging/")
    log_lines.append("[M108 TEST] Pipeline validado: %d errores, %d aprobados" % [resultado.get("errores_total"), resultado.get("aprobados")])

    var errores: int = instancia.call("escribir_reporte", resultado)

    log_lines.append("")
    log_lines.append("=== TEST M108: 5 checks, %d fallos ===" % errores)
    if errores > 0:
        var detalles: Array = resultado.get("detalles")
        for detalle in detalles:
            if not detalle.get("aprobado"):
                log_lines.append("  %s: %s" % [detalle.get("archivo"), ", ".join(detalle.get("errores"))])
    else:
        log_lines.append("Todos los checks pasaron.")

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
