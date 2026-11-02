# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-11-02
#
# M55 (COLA ACTIVA item 78) — lote de RECETAS: L97 + L98 + L99.
#
# Ejecutar:
#   Godot --headless --path game/isla-ancestral \
#     --script res://scripts/diario/test_diario_recetas_m55.gd
#
# Que mide (todo contra artefacto real en disco, no contra spec):
#   A  precondiciones: autoloads Diary/EventBus/Crafting y las 2 senales REALES
#      de M16 (crafting_service.gd:16 `receta_aprendida`, :18 `crafting_completed`).
#   B  la convencion de ids del catalogo M55 ("receta_" + rec_id de M16) es la
#      REAL: las 2 entradas de la categoria "recetas" resuelven a una receta
#      existente en Crafting (0 huerfanas).
#   C  L97 — aprender la receta DESBLOQUEA la entrada del diario: la senal real
#      `Crafting.receta_aprendida` deja la entrada registrada y visible.
#   D  L98 — el detalle de una receta trae INGREDIENTES con cantidad y RESULTADO,
#      y concuerda con la SEGUNDA fuente (data/balance/crafting.json crudo).
#   E  L99 — fabricar el item MARCA COMPLETADO la entrada (ruta real de la senal
#      `Crafting.crafting_completed`).
#   F  fail-closed: una receta que Crafting no conoce NO inventa ingredientes.
#
# Guardian: piso MEDIDO en verde + `_summary()` en un call_deferred APARTE, para
# que un SCRIPT ERROR que aborte un bloque no pueda publicar un "0 fallo(s)"
# con la mitad de los checks sin correr (trampa 63/85/14).

extends SceneTree

## Piso de checks MEDIDO en verde (se re-mide al correr la suite).
const CHECKS_MINIMOS: int = 40

var _fallos: int = 0
var _checks: int = 0
var _terminado := false
var _d: Node = null
var _bus: Node = null
var _craft: Node = null
## Fuente segunda, leida del disco: data/balance/crafting.json crudo.
var _json_crafting: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_d = root.get_node_or_null("Diary")
	_bus = root.get_node_or_null("EventBus")
	_craft = root.get_node_or_null("Crafting")
	_check(_d != null, "A1 autoload Diary presente")
	_check(_bus != null, "A2 autoload EventBus presente")
	_check(_craft != null, "A3 autoload Crafting (M16) presente")
	if _d == null or _bus == null or _craft == null:
		_terminado = true
		return
	_json_crafting = _leer_crafting_json()
	_test_precondiciones()
	_test_convencion_ids()
	_test_l97_receta_aprendida()
	_test_l98_ingredientes()
	_test_l99_fabricacion()
	_test_fail_closed()
	_terminado = true


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _summary() -> void:
	if not _terminado:
		_fallos += 1
		print("[FAIL] _run() NO termino (posible SCRIPT ERROR que aborto la funcion)")
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo medido %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M55 RECETAS: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)


## ── Bloque A: precondiciones ──────────────────────────────
func _test_precondiciones() -> void:
	_check(_craft.has_signal("receta_aprendida"), "A4 Crafting declara la senal real 'receta_aprendida'")
	_check(_craft.has_signal("crafting_completed"), "A5 Crafting declara la senal real 'crafting_completed'")
	_check(_craft.has_method("obtener_receta"), "A6 Crafting expone obtener_receta()")
	_check(not _json_crafting.is_empty(), "A7 data/balance/crafting.json legible con recetas")
	_check(int(_json_crafting.get("recetas", {}).size()) >= 2, "A8 crafting.json trae >= 2 recetas")


## Lee el JSON crudo de M16 (segunda fuente independiente del servicio).
func _leer_crafting_json() -> Dictionary:
	var f := FileAccess.open("res://data/balance/crafting.json", FileAccess.READ)
	if f == null:
		return {}
	var p: Variant = JSON.parse_string(f.get_as_text())
	if typeof(p) != TYPE_DICTIONARY:
		return {}
	return p


## ── Bloque B: convencion de ids del catalogo ─────────────
## El catalogo M55 nombra sus recetas "receta_" + <rec_id de M16>. Este bloque
## prueba que esa convencion NO es una suposicion mia: cada entrada de la
## categoria "recetas" resuelve a una receta REAL de Crafting.
func _test_convencion_ids() -> void:
	var ids: Array = _ids_de_categoria("recetas")
	_check(ids.size() == 2, "B1 la categoria 'recetas' tiene 2 entradas (medido %d)" % ids.size())
	var huerfanas := 0
	for eid in ids:
		var rec_id := _rec_id_de_entrada(eid)
		_check(not rec_id.is_empty(), "B2 '%s' deriva un rec_id no vacio" % eid)
		var receta = _craft.obtener_receta(rec_id)
		if receta == null:
			huerfanas += 1
			_check(false, "B3 '%s' -> rec_id '%s' NO existe en Crafting (huerfana)" % [eid, rec_id])
		else:
			_check(true, "B3 '%s' -> rec_id '%s' existe en Crafting" % [eid, rec_id])
	_check(huerfanas == 0, "B4 0 entradas de recetas huerfanas (medido %d)" % huerfanas)


## ids de las entradas de una categoria del catalogo.
func _ids_de_categoria(categoria: String) -> Array:
	var out: Array = []
	# _catalogo[categoria] es un ARRAY de entradas (diary_service.gd:86), no un
	# Dictionary: tipararlo como Dictionary aborta la funcion con SCRIPT ERROR.
	var cat: Array = _d._catalogo.get(categoria, [])
	for e in cat:
		out.append(String(e.get("id", "")))
	return out


## "receta_rec_mesa_robusta" -> "rec_mesa_robusta".
func _rec_id_de_entrada(entrada_id: String) -> String:
	if not entrada_id.begins_with("receta_"):
		return ""
	return entrada_id.substr(7)


## ── Bloque C: L97 aprender la receta desbloquea la entrada ─
func _test_l97_receta_aprendida() -> void:
	_d.restore_save_data({})
	var entrada_id := "receta_rec_mesa_robusta"
	_check(not _d.esta_registrada(entrada_id), "C1 la entrada de receta arranca NO registrada")
	var receta = _craft.obtener_receta("rec_mesa_robusta")
	_check(receta != null, "C2 la receta real 'rec_mesa_robusta' es obtenible")
	if receta == null:
		return
	# RUTA REAL: la senal que emite CraftingService al aprender una receta.
	_craft.receta_aprendida.emit(receta)
	_check(_d.esta_registrada(entrada_id), "C3 L97: receta_aprendida REGISTRA la entrada del diario")
	_check(_d.categoria_de(entrada_id) == "recetas", "C4 la entrada pertenece a la categoria 'recetas'")
	_check(int(_d.estado_de(entrada_id)) >= 1, "C5 la entrada queda al menos VISTA (estado %d)" % int(_d.estado_de(entrada_id)))
	var visible := false
	for e in _d.entradas_de("recetas"):
		if String(e.get("id", "")) == entrada_id:
			visible = bool(e.get("registrada", false))
	_check(visible, "C6 la entrada desbloqueada es VISIBLE en la lista de la categoria")


## ── Bloque D: L98 ingredientes con cantidades y resultado ─
func _test_l98_ingredientes() -> void:
	var entrada_id := "receta_rec_mesa_robusta"
	var det: Dictionary = _d.detalle_entrada(entrada_id)
	_check(not det.is_empty(), "D1 detalle_entrada() de una receta no viene vacio")
	_check(det.has("ingredientes"), "D2 el detalle expone 'ingredientes'")
	_check(det.has("resultado"), "D3 el detalle expone 'resultado'")
	var ing: Array = det.get("ingredientes", [])
	_check(ing.size() == 1, "D4 'rec_mesa_robusta' tiene 1 ingrediente (medido %d)" % ing.size())
	if ing.size() >= 1:
		var primero: Dictionary = ing[0]
		_check(primero.has("id") and primero.has("cantidad"), "D5 cada ingrediente trae id y cantidad")
		_check(String(primero.get("id", "")) == "madera_roble", "D6 el ingrediente es 'madera_roble' (medido '%s')" % String(primero.get("id", "")))
		_check(int(primero.get("cantidad", -1)) == 8, "D7 la cantidad es 8 (medido %d)" % int(primero.get("cantidad", -1)))
	var res: Dictionary = det.get("resultado", {})
	_check(String(res.get("id", "")) == "mesa_robusta", "D8 el resultado es 'mesa_robusta' (medido '%s')" % String(res.get("id", "")))
	_check(int(res.get("cantidad", -1)) == 1, "D9 la cantidad del resultado es 1 (medido %d)" % int(res.get("cantidad", -1)))

	# SEGUNDA FUENTE: el JSON crudo de M16. Si el servicio y el JSON discrepan,
	# el diario esta mostrando algo que el balance no dice.
	var cruda: Dictionary = _json_crafting.get("recetas", {}).get("rec_mesa_robusta", {})
	var coste: Dictionary = cruda.get("coste_recursos", {})
	_check(coste.size() == ing.size(), "D10 el servicio y el JSON coinciden en nº de ingredientes (%d vs %d)" % [ing.size(), coste.size()])
	for item_id in coste:
		var del_json := int(coste[item_id])
		var del_servicio := -1
		for i in ing:
			if String(i.get("id", "")) == String(item_id):
				del_servicio = int(i.get("cantidad", -1))
		_check(del_servicio == del_json, "D11 cantidad de '%s' coincide: servicio %d vs json %d" % [String(item_id), del_servicio, del_json])
	_check(String(cruda.get("resultado", "")) == String(res.get("id", "")), "D12 el resultado coincide con el JSON crudo")
	_check(int(cruda.get("resultado_cantidad", -1)) == int(res.get("cantidad", -2)), "D13 la cantidad del resultado coincide con el JSON crudo")

	# La receta de 2 ingredientes tambien: el detalle no es un caso unico.
	var det2: Dictionary = _d.detalle_entrada("receta_rec_pico_cobre")
	var ing2: Array = det2.get("ingredientes", [])
	_check(ing2.size() == 2, "D14 'rec_pico_cobre' tiene 2 ingredientes (medido %d)" % ing2.size())
	var total := 0
	for i in ing2:
		total += int(i.get("cantidad", 0))
	_check(total == 7, "D15 las cantidades suman 7 (medido %d)" % total)


## ── Bloque E: L99 fabricar el item marca completado ──────
func _test_l99_fabricacion() -> void:
	_d.restore_save_data({})
	var entrada_id := "receta_rec_pico_cobre"
	var receta = _craft.obtener_receta("rec_pico_cobre")
	_check(receta != null, "E1 la receta real 'rec_pico_cobre' es obtenible")
	if receta == null:
		return
	_check(not _d.esta_registrada(entrada_id), "E2 la entrada arranca NO registrada")
	# RUTA REAL: la senal que emite CraftingService al fabricar (crafting_service.gd:309).
	_craft.crafting_completed.emit(receta, 1)
	_check(_d.esta_registrada(entrada_id), "E3 L99: fabricar REGISTRA la entrada de la receta")
	_check(int(_d.estado_de(entrada_id)) == 2, "E4 L99: la entrada queda COMPLETADA (estado %d)" % int(_d.estado_de(entrada_id)))
	var completadas := 0
	for e in _d.entradas_de("recetas"):
		if int(e.get("estado", 0)) == 2:
			completadas += 1
	_check(completadas == 1, "E5 la lista muestra 1 receta completada (medido %d)" % completadas)
	var prog: Dictionary = _d.progreso_categoria("recetas")
	_check(int(prog.get("vistas", 0)) >= 1, "E6 el progreso de 'recetas' cuenta la receta (medido %d)" % int(prog.get("vistas", 0)))


## ── Bloque F: fail-closed ─────────────────────────────────
func _test_fail_closed() -> void:
	var datos: Dictionary = _d._datos_receta("rec_inexistente_xyz")
	_check(datos.has("ingredientes"), "F1 _datos_receta() devuelve la forma 'ingredientes'")
	_check((datos.get("ingredientes", []) as Array).is_empty(), "F2 una receta inexistente NO inventa ingredientes")
	_check((datos.get("resultado", {}) as Dictionary).is_empty(), "F3 una receta inexistente NO inventa resultado")
	var vacio: Dictionary = _d._datos_receta("")
	_check((vacio.get("ingredientes", []) as Array).is_empty(), "F4 un rec_id vacio NO inventa ingredientes")
	# Un id de entrada que no es de recetas NO deriva rec_id.
	_check(_d._rec_id_de_entrada("lugar_isla_raiz").is_empty(), "F5 un id de 'lugares' no deriva rec_id")
	_check(_d._rec_id_de_entrada("sello_x").is_empty(), "F6 un id de 'sellos' no deriva rec_id")
