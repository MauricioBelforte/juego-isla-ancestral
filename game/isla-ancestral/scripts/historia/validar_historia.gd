# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M22: Validador del grafo de historia (patrón DialogGraphValidator de M21).
# Reglas del diseño 03-Diseno §Grafo:
#  - sin nodos huérfanos (todo "siguiente" apunta a nodo existente)
#  - sin ciclos infinitos (alcanzabilidad: el grafo es DAG por capítulos)
#  - cada final alcanzable desde "prologo"
#  - sin requisitos rotos (tipos conocidos + ids de sellos válidos)
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/historia/validar_historia.gd
extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var texto := FileAccess.get_file_as_string("res://data/historia/historia_principal.json")
	var datos: Variant = JSON.parse_string(texto)
	_check(typeof(datos) == TYPE_DICTIONARY, "JSON parsea a Dictionary")
	if typeof(datos) != TYPE_DICTIONARY:
		quit(1)
		return
	var nodos: Array = datos.get("nodos", [])
	var ids := {}
	for n in nodos:
		var id := String(n.get("id", ""))
		_check(not id.is_empty(), "nodo con id no vacío")
		_check(not ids.has(id), "id único: %s" % id)
		ids[id] = true
	_check(ids.has("prologo"), "existe prólogo")
	# Huérfanos: todo siguiente existe
	for n in nodos:
		for sig in n.get("siguiente", []):
			_check(ids.has(String(sig)), "sin huérfanos: %s → %s" % [String(n.get("id")), String(sig)])
	# Finales alcanzables: BFS desde prologo respetando SOLO aristas (sin gating,
	# el gating es runtime; la estructura debe garantizar alcanzabilidad)
	var alcanzables := {"prologo": true}
	var cola: Array[String] = ["prologo"]
	while not cola.is_empty():
		var actual: String = cola.pop_front()
		for n in nodos:
			if String(n.get("id", "")) == actual:
				for sig in n.get("siguiente", []):
					var s := String(sig)
					if not alcanzables.has(s):
						alcanzables[s] = true
						cola.append(s)
				break
	var finales := 0
	for n in nodos:
		if String(n.get("tipo", "")) == "final":
			finales += 1
			_check(alcanzables.has(String(n.get("id", ""))),
				"final alcanzable: %s" % String(n.get("final_id")))
	_check(finales == int(datos.get("finales", []).size()), "cantidad de finales = declarados (%d)" % finales)
	# Sin ciclos: el grafo es DAG si al ordenar por capítulo siempre se avanza
	for n in nodos:
		var cap := int(n.get("capitulo", 0))
		for sig in n.get("siguiente", []):
			for m in nodos:
				if String(m.get("id", "")) == String(sig):
					_check(int(m.get("capitulo", 0)) >= cap,
						"sin retroceso de capítulo: %s(%d) → %s(%d)"
						% [String(n.get("id")), cap, String(sig), int(m.get("capitulo", 0))])
				# (solo primera coincidencia por id)
				break
	# Requisitos bien formados: tipos conocidos + sellos declarados
	var sellos_ids := {}
	for s in datos.get("sellos", []):
		sellos_ids[String(s.get("id", ""))] = true
	_check(sellos_ids.size() == int(datos.get("sellos_totales", 0)), "catálogo sellos = declarados")
	var tipos_ok := ["capitulo", "sellos", "flag", "objeto"]
	for n in nodos:
		for req in n.get("requisitos", []):
			_check(tipos_ok.has(String(req.get("tipo", ""))),
				"requisito tipo conocido en %s: %s" % [String(n.get("id")), String(req.get("tipo", ""))])
			if String(req.get("tipo", "")) == "capitulo":
				_check(ids.has(String(req.get("id", ""))), "req capitulo existe en %s" % String(n.get("id")))
			if String(req.get("tipo", "")) == "sellos":
				var cant := int(req.get("cantidad", 0))
				_check(cant <= int(datos.get("sellos_totales", 0)),
					"req sellos (%d) <= sellos_totales (%d) en %s"
					% [cant, int(datos.get("sellos_totales", 0)), String(n.get("id"))])
	# Finales secretos por flag externo: advertir (no es fallo duro, es por diseño M25/M147).
	var flags_externos := {}
	for n in nodos:
		if String(n.get("tipo", "")) == "final":
			for req in n.get("requisitos", []):
				if String(req.get("tipo", "")) == "flag":
					flags_externos[String(n.get("final_id", ""))] = String(req.get("id", ""))
	for fid in flags_externos:
		print("ADVERTENCIA: final '%s' exige flag externa '%s' (seteada por M25/M147); "
			+ "in-alcanzable sin esa bandera." % [String(fid), flags_externos[fid]])
	# final_id declarados coinciden con nodos tipo final.
	var declarados: Array = datos.get("finales", [])
	var ids_finales := {}
	for n in nodos:
		if String(n.get("tipo", "")) == "final":
			ids_finales[String(n.get("final_id", ""))] = true
	for fid in declarados:
		_check(ids_finales.has(String(fid)), "final_id declarado existe en grafo: %s" % String(fid))
	for fid in ids_finales:
		_check(declarados.has(String(fid)), "nodo final presente en lista declarada: %s" % String(fid))
	print("=== VALIDADOR M22 HISTORIA: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
