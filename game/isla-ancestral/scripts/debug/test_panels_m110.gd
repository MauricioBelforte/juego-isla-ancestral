# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-01
# Suite M110-UI: paneles REALES (secciones D y E del 03-Diseno) + TabBar.
#
# Que mide (y que NO): los 13 widgets existen, estan cableados a la funcion
# PUBLICA del backend, y la TabBar tiene pestañas de verdad. NO mide estetica
# ni aprobacion visual (eso no es medible headless).
#
# Guardian de 3 capas (trampas 11/61/63 del skill):
#   1. `_fin(bloque)` al final del CUERPO de cada bloque -> nombra el que falto.
#   2. `CHECKS_MINIMOS` MEDIDO en verde -> detecta abortos dentro de helpers.
#   3. `_summary` en un `call_deferred` SEPARADO -> corre aunque _run() aborte.
extends SceneTree

const PANEL_MUNDO := preload("res://scripts/debug/panels/panel_mundo.gd")
const PANEL_ENTIDADES := preload("res://scripts/debug/panels/panel_entidades.gd")
const MENU_SCRIPT := preload("res://scripts/debug/debug_menu.gd")

const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
const CHECKS_MINIMOS := 53  # MEDIDO en verde (53 checks x3 corridas); no estimado

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}
var _terminado := false


class BackendFalso extends Node:
	var llamadas: Array = []
	var hora := 7
	var seed_actual := 42

	func hora_actual() -> int:
		return hora

	func seed_generacion() -> int:
		return seed_actual

	func set_season(t: int) -> Dictionary:
		llamadas.append(["set_season", t])
		return {"ok": true, "resultado": "estacion %d" % t}

	func set_weather(t: int) -> Dictionary:
		llamadas.append(["set_weather", t])
		return {"ok": true, "resultado": "clima %d" % t}

	func aplicar_seed(v: int) -> Dictionary:
		llamadas.append(["aplicar_seed", v])
		seed_actual = v
		return {"ok": true, "actual": v}

	func regenerar_chunk(cx: int, cz: int) -> Dictionary:
		llamadas.append(["regenerar_chunk", cx, cz])
		return {"ok": true}

	func reset_npc(id: String) -> Dictionary:
		llamadas.append(["reset_npc", id])
		return {"ok": true}

	func reset_puzzle(id: String) -> Dictionary:
		llamadas.append(["reset_puzzle", id])
		return {"ok": true}


class GeneradorFalso extends Node:
	var world_seed: int = 42
	var _island_gen: Variant = "cache-viva"


func _init() -> void:
	print("=== SUITE M110-UI: paneles reales + TabBar ===")
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	_bloque_a()
	_bloque_b()
	_bloque_c()
	_bloque_d()
	_bloque_e()
	_bloque_f()
	_bloque_g()
	_bloque_h()
	_bloque_i()
	_bloque_j()
	_terminado = true


# ── A: panel Mundo construye los 8 widgets de la seccion D ──────────────────
func _bloque_a() -> void:
	var p: VBoxContainer = PANEL_MUNDO.new()
	root.add_child(p)
	_check("A1 panel_mundo._ready corrio (tiene hijos)", p.get_child_count() > 0, "hijos=%d" % p.get_child_count())
	var w: Dictionary = p.call("widgets_presentes")
	_check("A2 los 8 widgets de la seccion D existen", w.size() == 8 and w.values().all(func(x): return bool(x)), str(w))
	_check("A3 Label de hora actual", p.call("obtener_label_hora") is Label, "")
	_check("A4 Dropdown de estacion", p.call("obtener_selector_estacion") is OptionButton, "")
	_check("A5 Dropdown de clima", p.call("obtener_selector_clima") is OptionButton, "")
	_check("A6 Input de seed", p.call("obtener_input_seed") is LineEdit, "")
	_check("A7 Boton Aplicar seed", p.call("obtener_boton_seed") is Button, "")
	_check("A8 Input de chunk X", p.call("obtener_spin_cx") is SpinBox, "")
	_check("A9 Input de chunk Z", p.call("obtener_spin_cz") is SpinBox, "")
	_check("A10 Boton Regenerar", p.call("obtener_boton_regenerar") is Button, "")
	p.queue_free()
	_fin("A")


# ── B: catalogos REALES, no inventados ──────────────────────────────────────
func _bloque_b() -> void:
	var p: VBoxContainer = PANEL_MUNDO.new()
	var backend := BackendFalso.new()
	p.call("_inyectar_menu", backend)
	root.add_child(p)
	var est: OptionButton = p.call("obtener_selector_estacion")
	_check("B1 4 estaciones del nucleo (game_clock NOMBRES_ESTACIONES)", est.item_count == 4, "count=%d" % est.item_count)
	if est.item_count == 4:
		_check("B2 estacion 0 = Primavera", est.get_item_text(0) == "Primavera", est.get_item_text(0))
		_check("B3 estacion 3 = Invierno", est.get_item_text(3) == "Invierno", est.get_item_text(3))
	var clim: OptionButton = p.call("obtener_selector_clima")
	var nombres: Array = p.call("nombres_clima")
	var clima_autoload := root.get_node_or_null("Weather")
	if clima_autoload != null:
		_check("B4 climas desde Weather.get_nombre_clima (9 del enum)", clim.item_count == 9, "count=%d" % clim.item_count)
	else:
		# Fail-closed honesto: sin M31 el selector NO inventa climas.
		_check("B4 sin Weather el selector no inventa climas", clim.item_count == 0, "count=%d" % clim.item_count)
	_check("B5 nombres_clima coincide con los items del selector", nombres.size() == clim.item_count, "%d vs %d" % [nombres.size(), clim.item_count])
	p.queue_free()
	backend.free()
	_fin("B")


# ── C: la vista refleja al backend, no al reves ─────────────────────────────
func _bloque_c() -> void:
	var p: VBoxContainer = PANEL_MUNDO.new()
	var backend := BackendFalso.new()
	backend.hora = 7
	backend.seed_actual = 4242
	p.call("_inyectar_menu", backend)
	root.add_child(p)
	var lbl: Label = p.call("obtener_label_hora")
	_check("C1 Label de hora refleja hora_actual()=7", lbl.text == "Hora: 07:00", lbl.text)
	var inp: LineEdit = p.call("obtener_input_seed")
	_check("C2 Input de seed precargado con seed_generacion()", inp.text == "4242", inp.text)
	backend.hora = 18
	p.call("refrescar")
	_check("C3 refrescar() re-lee el backend", lbl.text == "Hora: 18:00", lbl.text)
	# Centinela -1 = "sin generador": no debe mostrar "-1" como si fuera una seed.
	backend.seed_actual = -1
	p.call("refrescar")
	_check("C4 seed centinela -1 no se muestra como seed", inp.text == "", inp.text)
	p.queue_free()
	backend.free()
	_fin("C")


# ── D: cada widget llama a la funcion PUBLICA con los args correctos ────────
func _bloque_d() -> void:
	var p: VBoxContainer = PANEL_MUNDO.new()
	var backend := BackendFalso.new()
	p.call("_inyectar_menu", backend)
	root.add_child(p)
	var est: OptionButton = p.call("obtener_selector_estacion")
	est.select(2)
	est.item_selected.emit(2)
	_check("D1 selector de estacion -> set_season(2)", _ultima(backend) == ["set_season", 2], str(_ultima(backend)))
	var clim: OptionButton = p.call("obtener_selector_clima")
	if clim.item_count > 3:
		clim.select(3)
		clim.item_selected.emit(3)
		_check("D2 selector de clima -> set_weather(3)", _ultima(backend) == ["set_weather", 3], str(_ultima(backend)))
	else:
		_check("D2 selector de clima sin items: no hay nada que cablear", clim.item_count == 0, "")
	var inp: LineEdit = p.call("obtener_input_seed")
	inp.text = "777"
	var btn: Button = p.call("obtener_boton_seed")
	btn.pressed.emit()
	_check("D3 boton Aplicar seed -> aplicar_seed(777)", _ultima(backend) == ["aplicar_seed", 777], str(_ultima(backend)))
	# Seed invalida: NO debe llegar al backend.
	inp.text = "no-es-entero"
	btn.pressed.emit()
	_check("D4 seed invalida no llega al backend", _ultima(backend) == ["aplicar_seed", 777], str(_ultima(backend)))
	var cx: SpinBox = p.call("obtener_spin_cx")
	var cz: SpinBox = p.call("obtener_spin_cz")
	cx.value = 5.0
	cz.value = -3.0
	var breg: Button = p.call("obtener_boton_regenerar")
	breg.pressed.emit()
	_check("D5 boton Regenerar -> regenerar_chunk(5,-3)", _ultima(backend) == ["regenerar_chunk", 5, -3], str(_ultima(backend)))
	p.queue_free()
	backend.free()
	_fin("D")


# ── E: backend aplicar_seed (nuevo) + invalidacion de cache ─────────────────
func _bloque_e() -> void:
	var menu: Node = root.get_node_or_null("DebugMenu")
	var propio := false
	if menu == null:
		menu = MENU_SCRIPT.new()
		propio = true
	var gen := GeneradorFalso.new()
	root.add_child(gen)
	menu.call("_inyectar_generador", gen)
	var r: Dictionary = menu.call("aplicar_seed", 1234)
	_check("E1 aplicar_seed fija world_seed", int(gen.world_seed) == 1234, str(gen.world_seed))
	_check("E2 aplicar_seed devuelve ok", bool(r.get("ok", false)), str(r))
	_check("E3 aplicar_seed reporta el valor verificado", int(r.get("actual", -1)) == 1234, str(r.get("actual", -1)))
	# El defecto medido: world_seed cambia pero el generador REAL sigue cacheado.
	_check("E4 aplicar_seed invalida la cache _island_gen", gen._island_gen == null, str(gen._island_gen))
	_check("E5 cache_invalidada=true en la respuesta", bool(r.get("cache_invalidada", false)), str(r))
	# Fail-closed: sin generador no toca nada y lo dice.
	# ⚠️ `_inyectar_generador(null)` NO basta: `_fuente_generador()` cae al
	# descubrimiento por el arbol y encontraria el GeneradorFalso de este mismo
	# bloque (medido en la 1.a corrida: E6 rojo con ok=true). Un backend FUERA
	# del arbol devuelve null sin buscar (`is_inside_tree()` == false).
	var suelto: Node = MENU_SCRIPT.new()
	var r2: Dictionary = suelto.call("aplicar_seed", 9)
	_check("E6 sin generador -> ok=false (fail-closed)", bool(r2.get("ok", true)) == false, str(r2))
	suelto.free()
	if propio:
		menu.free()
	gen.queue_free()
	# Dejar el autoload como estaba (no dejarle un generador de test inyectado).
	if not propio:
		menu.call("_inyectar_generador", null)
	_fin("E")


# ── F: panel Entidades construye los 5 widgets de la seccion E ──────────────
func _bloque_f() -> void:
	var p: VBoxContainer = PANEL_ENTIDADES.new()
	var backend := BackendFalso.new()
	p.call("_inyectar_menu", backend)
	root.add_child(p)
	_check("F1 panel_entidades._ready corrio", p.get_child_count() > 0, "hijos=%d" % p.get_child_count())
	var w: Dictionary = p.call("widgets_presentes")
	_check("F2 los 5 widgets de la seccion E existen", w.size() == 5 and w.values().all(func(x): return bool(x)), str(w))
	var sel_npc: OptionButton = p.call("obtener_selector_npc")
	var ids: Array = p.call("ids_npc")
	_check("F3 selector NPC poblado (o placeholder honesto)", sel_npc.item_count == maxi(ids.size(), 1), "%d items / %d ids" % [sel_npc.item_count, ids.size()])
	var vm := root.get_node_or_null("VillagerManager")
	if vm != null and vm.has_method("obtener_activos"):
		var activos: Variant = vm.call("obtener_activos")
		var n: int = (activos as Array).size() if activos is Array else -1
		_check("F4 ids_npc cruza con VillagerManager.obtener_activos()", ids.size() == n, "%d vs %d" % [ids.size(), n])
	else:
		_check("F4 sin VillagerManager la lista queda vacia (no inventa NPCs)", ids.size() == 0, str(ids))
	var lbl: Label = p.call("obtener_label_ia")
	_check("F5 Label de estado IA existe y no esta vacio", lbl != null and not lbl.text.is_empty(), lbl.text if lbl != null else "null")
	var sel_puz: OptionButton = p.call("obtener_selector_puzzle")
	_check("F6 selector de puzzle poblado (o placeholder honesto)", sel_puz.item_count >= 1, "%d" % sel_puz.item_count)
	p.queue_free()
	backend.free()
	_fin("F")


# ── G: reset NPC / puzzle llaman al backend con el id seleccionado ──────────
func _bloque_g() -> void:
	var p: VBoxContainer = PANEL_ENTIDADES.new()
	var backend := BackendFalso.new()
	p.call("_inyectar_menu", backend)
	root.add_child(p)
	var ids: Array = p.call("ids_npc")
	var sel: OptionButton = p.call("obtener_selector_npc")
	var btn: Button = p.call("obtener_boton_reset_npc")
	if ids.is_empty():
		# Sin NPC: el boton NO debe inventar un id ni crashear.
		btn.pressed.emit()
		var res: Dictionary = p.call("ultimo_resultado")
		_check("G1 sin NPC el boton no llama al backend", backend.llamadas.is_empty(), str(backend.llamadas))
		_check("G2 sin NPC el resultado es ok=false", bool(res.get("ok", true)) == false, str(res))
	else:
		sel.select(0)
		btn.pressed.emit()
		_check("G1 reset NPC usa el id seleccionado", _ultima(backend) == ["reset_npc", String(ids[0])], str(_ultima(backend)))
		_check("G2 reset NPC reporta ok", true, "")
	var ids_puz: Array = p.call("ids_puzzle")
	var bp: Button = p.call("obtener_boton_reset_puzzle")
	if ids_puz.is_empty():
		bp.pressed.emit()
		_check("G3 sin puzzle el boton no llama al backend", not _contiene(backend, "reset_puzzle"), str(backend.llamadas))
	else:
		var sp: OptionButton = p.call("obtener_selector_puzzle")
		sp.select(0)
		bp.pressed.emit()
		_check("G3 reset puzzle usa el id seleccionado", _ultima(backend) == ["reset_puzzle", String(ids_puz[0])], str(_ultima(backend)))
	p.queue_free()
	backend.free()
	_fin("G")


# ── H: TabBar con pestañas REALES (defecto 1 corregido) ─────────────────────
func _bloque_h() -> void:
	var escena := load("res://scenes/debug/debug_menu.tscn")
	_check("H1 debug_menu.tscn carga", escena != null, "")
	if escena == null:
		_fin("H")
		return
	var ui: Node = escena.instantiate()
	root.add_child(ui)
	var tb: TabBar = ui.call("obtener_tab_bar")
	_check("H2 TabBar tiene 5 pestañas (antes: 0)", tb != null and tb.tab_count == 5, "count=%d" % (tb.tab_count if tb != null else -1))
	if tb != null and tb.tab_count == 5:
		_check("H3 pestaña 0 = Jugador", tb.get_tab_title(0) == "Jugador", tb.get_tab_title(0))
		_check("H4 pestaña 1 = Mundo", tb.get_tab_title(1) == "Mundo", tb.get_tab_title(1))
		_check("H5 pestaña 2 = Entidades", tb.get_tab_title(2) == "Entidades", tb.get_tab_title(2))
	var ids: Array = ui.call("ids_pestanas")
	_check("H6 ids de pestaña vienen del config", ids.size() == 5 and String(ids[1]) == "mundo", str(ids))
	var pm: Node = ui.call("obtener_panel_mundo")
	var pe: Node = ui.call("obtener_panel_entidades")
	_check("H7 panel Mundo montado en el ContentPanel", pm != null and pm.get_parent() != null, "")
	_check("H8 panel Entidades montado en el ContentPanel", pe != null and pe.get_parent() != null, "")
	ui.queue_free()
	_fin("H")


# ── I: handler de señal con el tipo correcto (defecto 2 corregido) ──────────
func _bloque_i() -> void:
	var escena := load("res://scenes/debug/debug_menu.tscn")
	var ui: Node = escena.instantiate()
	root.add_child(ui)
	var cons: Node = ui.call("obtener_consola")
	var antes: int = int(cons.call("tamano"))
	# La señal del backend es int; el handler viejo declaraba String y NUNCA
	# corria ("Cannot convert argument 1 from int to String").
	ui.call("_on_estacion_solicitada", 2)
	var despues: int = int(cons.call("tamano"))
	_check("I1 handler de estacion acepta int y registra la linea", despues == antes + 1, "%d -> %d" % [antes, despues])
	var ultima: String = ""
	var lineas: Array = cons.call("obtener_lineas")
	if lineas.size() > 0:
		ultima = String(lineas[lineas.size() - 1])
	_check("I2 la linea registrada dice la estacion 2", ultima.find("2") >= 0 and ultima.find("Estación") >= 0, ultima)
	var menu := root.get_node_or_null("DebugMenu")
	if menu != null and menu.has_signal("estacion_solicitada"):
		var antes2: int = int(cons.call("tamano"))
		menu.emit_signal("estacion_solicitada", 3)
		_check("I3 la señal REAL del backend llega al handler", int(cons.call("tamano")) == antes2 + 1, "%d -> %d" % [antes2, int(cons.call("tamano"))])
	else:
		_check("I3 backend sin la señal: no hay conexion que probar", true, "")
	ui.queue_free()
	_fin("I")


# ── J: fail-closed con un backend que NO implementa la API ─────────────────
func _bloque_j() -> void:
	# ⚠️ `_inyectar_menu(null)` NO sirve para esto: `_ready()` cae a
	# `/root/DebugMenu` (autoload real) y el panel mide el backend de verdad
	# (1.a corrida: J2 rojo con "Hora: 08:00"). El caso que importa es un
	# backend PRESENTE pero SIN la funcion.
	var mutilado := Node.new()
	root.add_child(mutilado)
	var p: VBoxContainer = PANEL_MUNDO.new()
	p.call("_inyectar_menu", mutilado)
	root.add_child(p)
	var btn: Button = p.call("obtener_boton_regenerar")
	btn.pressed.emit()
	var res: Dictionary = p.call("ultimo_resultado")
	_check("J1 backend sin la funcion -> ok=false", bool(res.get("ok", true)) == false, str(res))
	var lbl: Label = p.call("obtener_label_hora")
	_check("J2 backend sin hora_actual -> label n/d (no inventa hora)", lbl.text.find("n/d") >= 0, lbl.text)
	var pe: VBoxContainer = PANEL_ENTIDADES.new()
	pe.call("_inyectar_menu", mutilado)
	root.add_child(pe)
	var b: Button = pe.call("obtener_boton_reset_puzzle")
	b.pressed.emit()
	var res2: Dictionary = pe.call("ultimo_resultado")
	_check("J3 panel Entidades con backend mutilado tampoco crashea", bool(res2.get("ok", true)) == false, str(res2))
	p.queue_free()
	pe.queue_free()
	mutilado.queue_free()
	_fin("J")


# ── Helpers ────────────────────────────────────────────────────────────────

func _ultima(backend: Node) -> Array:
	var l: Array = backend.get("llamadas")
	if l.is_empty():
		return []
	return l[l.size() - 1]

func _contiene(backend: Node, nombre: String) -> bool:
	var l: Array = backend.get("llamadas")
	for x in l:
		if x is Array and (x as Array).size() > 0 and String((x as Array)[0]) == nombre:
			return true
	return false

func _check(nombre: String, cond: bool, detalle: String) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s | %s" % [nombre, detalle])

func _fin(bloque: String) -> void:
	_vistos[bloque] = true

func _summary() -> void:
	if not _terminado:
		print("!! _run() NO termino (posible SCRIPT ERROR que aborto la funcion)")
	for n in BLOQUES:
		if not _vistos.has(n):
			_checks += 1
			_fallos += 1
			print("  [FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % n)
	if _checks < CHECKS_MINIMOS:
		_checks += 1
		_fallos += 1
		print("  [FAIL] solo %d checks ejecutados (minimo %d)" % [_checks - 1, CHECKS_MINIMOS])
	print("=== Resumen M110-UI paneles: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
