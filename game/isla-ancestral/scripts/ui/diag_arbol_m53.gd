# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-26
#
# M53 L210: volcado del arbol de una capa con tamanos, para localizar
# que hijo empuja el minimo. Instrumento de medicion, no suite de QA.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/diag_arbol_m53.gd -- <capa.gd>

extends SceneTree

var _objetivo: String = "diary_layer.gd"

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_objetivo = String(args[0])
	call_deferred("_run")

func _run() -> void:
	var raiz := get_root()
	raiz.size = Vector2i(1920, 1080)
	await process_frame
	await process_frame
	var lienzo: Vector2 = raiz.get_visible_rect().size
	print("=== lienzo %.0fx%.0f | capa %s ===" % [lienzo.x, lienzo.y, _objetivo])
	var scr = load("res://scripts/ui/layers/" + _objetivo)
	if scr == null:
		print("NO CARGA")
		quit(1)
		return
	var nodo = scr.new()
	raiz.add_child(nodo)
	for i in range(3):
		await process_frame
	if OS.get_cmdline_user_args().size() > 1:
		if nodo.has_method("open"):
			nodo.call("open")
		else:
			nodo.visible = true
		for i in range(3):
			await process_frame
	_volcar(nodo, 0, 6)
	quit(0)

func _volcar(n: Node, nivel: int, max_nivel: int) -> void:
	if nivel > max_nivel:
		return
	for c in n.get_children():
		if c is Control:
			var marca := ""
			if c.size.x > 1152.0 or c.size.y > 648.0:
				marca = "  <<< EXCEDE"
			print("%s%s [%s] size=%.0fx%.0f min=%.0fx%.0f%s" % [
				"  ".repeat(nivel), String(c.name), c.get_class(),
				c.size.x, c.size.y, c.get_combined_minimum_size().x, c.get_combined_minimum_size().y, marca])
			_volcar(c, nivel + 1, max_nivel)
		else:
			_volcar(c, nivel, max_nivel)
