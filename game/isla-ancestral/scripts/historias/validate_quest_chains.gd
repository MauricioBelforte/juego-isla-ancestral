# Modelo: Step 3.7 Flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M23: Historias Secundarias — Validador de cadenas (EditorScript).
# Ejecutar desde Editor: valida todas las cadenas en data/historias/
# contra reglas de anti-repetición (contexto >= 10 chars, 3+ pasos,
# recompensa única, referencias alcanzables).

extends EditorScript

func _run() -> void:
    var service := _load_service()
    if service == null:
        print("[M23] ERROR: QuestChainService no encontrado")
        return
    var errores := service.validar_todas()
    if errores.is_empty():
        print("[M23] OK: todas las cadenas válidas (%d)" % service._cadenas.size())
    else:
        print("[M23] ERRORES (%d):" % errores.size())
        for e in errores:
            print("  - " + e)

func _load_service() -> Script:
    var path := "res://scripts/historias/quest_chain_service.gd"
    var script := load(path)
    if script == null:
        return null
    # Instanciar temporalmente para acceder a métodos de instancia
    var node := Node.new()
    node.set_script(script)
    return node
