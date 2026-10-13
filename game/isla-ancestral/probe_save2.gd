extends Node

var _intentos := 0

func _ready() -> void:
	_probar()

func _process(_delta: float) -> void:
	_intentos += 1
	if _intentos > 120:
		_finalizar("timeout: SaveManager no aparecio en 120 frames")
	set_process(false)

func _probar() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm == null:
		set_process(true)
		return
	var snap = null
	if sm.has_method("get") or true:
		snap = sm.get("snapshot")
	if snap == null:
		_finalizar("snapshot no accesible")
		return
	var provs = snap.get("_providers")
	if provs == null:
		_finalizar("_providers no accesible")
		return
	var secciones := []
	for k in provs:
		secciones.append(String(k))
	secciones.sort()
	var lineas := ["secciones=" + str(secciones.size())]
	for s in secciones:
		lineas.append("  - " + s)
	var gc = get_node_or_null("/root/gem_currency")
	lineas.append("gem_currency=" + str(gc != null))
	var ci = get_node_or_null("/root/combat_island")
	lineas.append("combat_island=" + str(ci != null))
	var tenia_gemas = false
	var tenia_combate = false
	for s in secciones:
		if s == "gemas_m164":
			tenia_gemas = true
		if s == "isla_combate_m164":
			tenia_combate = true
	lineas.append("GEMAS_M164_REGISTRADA=" + str(tenia_gemas))
	lineas.append("ISLA_COMBATE_M164_REGISTRADA=" + str(tenia_combate))
	_finalizar("|".join(lineas))

func _finalizar(msg: String) -> void:
	print("PROBE_RESULT: " + msg)
	get_tree().quit()
