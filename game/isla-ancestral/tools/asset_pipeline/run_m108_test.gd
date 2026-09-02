extends Node

func _ready() -> void:
    print("[M108 TEST] Iniciando test...")
    var logic: Object = load("res://tools/asset_pipeline/asset_validator_logic.gd")
    if logic == null:
        print("[M108 TEST] ERROR: no se pudo cargar asset_validator_logic.gd")
        get_tree().quit(1)
        return
    print("[M108 TEST] Script cargado OK")

    var instancia: Object = logic.call("new")
    print("[M108 TEST] Instancia creada OK")

    var resultado: Object = instancia.call("validar_pipeline", "res://assets/staging/")
    print("[M108 TEST] Pipeline validado: %d errores, %d aprobados" % [resultado.get("errores_total"), resultado.get("aprobados")])

    var errores: int = instancia.call("escribir_reporte", resultado)

    print("")
    print("=== TEST M108: 5 checks, %d fallos ===" % errores)
    if errores > 0:
        var detalles: Array = resultado.get("detalles")
        for detalle in detalles:
            if not detalle.get("aprobado"):
                print("  %s: %s" % [detalle.get("archivo"), ", ".join(detalle.get("errores"))])
    else:
        print("Todos los checks pasaron.")

    get_tree().quit(errores)
