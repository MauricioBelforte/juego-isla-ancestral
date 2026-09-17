# Modelo: DeepSeek-V4.1-Flash / WorkBuddy
# Plataforma: WorkBuddy
# Fecha: 2026-09-13
#
# M148: Lore Ambiental — LoreGate (puerta de CI)
# Script headless que valida el catálogo de lore y FALLA (exit 1) si hay:
#   - IDs vacíos o duplicados
#   - canon_ref vacío (RF10)
#   - tipo fuera del enum o título/texto vacíos
#   - isla vacía o cobertura < 12 piezas por isla (RF9)
#   - pistas (MURAL/ESTATUA/MAPA/CANCION) sin consumidor o con consumidor
#     desconocido en data/lore/consumidores.json (RF3)
#
# Uso (CI):
#   godot --headless --path game/isla-ancestral \
#         --script res://scripts/lore/lore_gate.gd
# Salida: exit 0 = catálogo válido; exit 1 = violaciones (se imprimen).
#
# Preloads §9.52: nombres SIN colisionar con class_name de los scripts.

extends SceneTree

const _SC_CATALOGO := preload("res://scripts/lore/lore_catalogo.gd")
const _SC_AUDITOR := preload("res://scripts/lore/lore_auditor.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	print("=== [M148] LoreGate (CI) ===")
	var catalogo = _SC_CATALOGO.new()
	catalogo.cargar()

	if catalogo.cantidad_total() == 0:
		print("[M148] LoreGate: FALLO — catálogo vacío o no cargable")
		print("LoreGate FALLIDO — salida con código 1")
		quit(1)
		return

	var errores: Array = _SC_AUDITOR.validar(catalogo)
	var errores_grafo: Array = _SC_AUDITOR.validar_grafo(catalogo)
	var todos: Array = []
	todos.append_array(errores)
	todos.append_array(errores_grafo)

	print(_SC_AUDITOR.reporte_cobertura(catalogo))

	if todos.is_empty():
		print("[M148] LoreGate: OK — %d piezas, %d pistas, grafo consistente" % [catalogo.cantidad_total(), catalogo.pistas().size()])
		print("LoreGate OK — salida con código 0")
		quit(0)
	else:
		print("[M148] LoreGate: %d violaciones:" % todos.size())
		for e in todos:
			print("  - %s" % e)
		print("LoreGate FALLIDO — salida con código 1")
		quit(1)
