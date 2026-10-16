extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var diary = root.get_node_or_null("Diary")
	var ui = root.get_node_or_null("UIManager")
	var loc = root.get_node_or_null("Localization")
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("es")
	var snap: Dictionary = diary.get_save_data().duplicate(true)
	diary.restore_save_data({"schema_version": 1, "entradas": {}})
	var previa = ui._buscar_capa("DiaryLayer")
	if previa != null:
		previa.free()
	var script := load("res://scripts/ui/layers/diary_layer.gd")
	var capa = script.new()
	capa.name = "DiaryLayer"
	root.add_child(capa)
	capa.open()
	diary.registrar("vecino_catalina_oso", "personajes")
	capa.open()  # refresco
	print("== tras registrar catalina ==")
	var lista = _buscar(capa, "ListaEntradas")
	print("hijos de lista: ", lista.get_children().size())
	for h in lista.get_children():
		print("  hijo: ", h.name, " (", h.get_class(), ")")
	print("filas en arbol: ", capa._filas.size())
	print("pool: ", capa._pool_filas.size())
	print("entradas_cache: ", capa._entradas_cache.size())
	print("ventana: ", capa._ventana, " paso: ", capa._paso, " first: ", capa._first_fila)
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("en")
	capa.open()
	print("== tras locale en + open ==")
	print("hijos de lista: ", lista.get_children().size())
	for h in lista.get_children():
		print("  hijo: ", h.name, " (", h.get_class(), ")")
	print("filas en arbol: ", capa._filas.size())
	var f = _buscar(capa, "Fila_vecino_catalina_oso")
	print("Fila_vecino_catalina_oso: ", f)
	if f != null:
		print("  texto: '", f.text, "'")
	print("categoria_actual: ", capa._categoria_actual, " filtro: ", capa._filtro, " busqueda: '", capa._busqueda, "'")
	diary.restore_save_data(snap)
	quit(0)

func _buscar(node: Node, nombre: String) -> Node:
	if node.name == nombre:
		return node
	for child in node.get_children():
		if child.name == nombre:
			return child
		var r := _buscar(child, nombre)
		if r:
			return r
	return null
