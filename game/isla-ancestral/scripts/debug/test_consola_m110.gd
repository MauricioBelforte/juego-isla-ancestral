# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy AI
# Fecha: 2026-11-02
# M110-UI: suite de la consola con filtros (checklist §G L132-L135 y §H L147-L149),
# overlay de FPS (§O L263), aviso de desarrollo (§M L243) y del defecto "la consola
# se usaba como cartel de pestaña" en debug_menu_ui.gd.
#
# Guardian de 3 capas (skill isla-ancestral-ciclo-modulo §2.11/§2.63):
#  1. `_fin(bloque)` al FINAL del cuerpo de cada bloque. Un SCRIPT ERROR aborta la
#     funcion y el LLAMADOR RETOMA, asi que un `_fin()` en el llamador seria ciego.
#  2. `CHECKS_MINIMOS` MEDIDO en verde (no estimado ni copiado).
#  3. `_summary()` en un `call_deferred` SEPARADO: si `_run()` aborta, la cola
#     diferida sigue y el resumen corre igual (si no, el SceneTree se CUELGA).
extends SceneTree

const MODULO := "M110-consola"
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
const CHECKS_MINIMOS := 55

var _checks := 0
var _fallos := 0
var _vistos: Dictionary = {}


## Logger falso: replica la firma REAL de GameLogger.line_emitted
## (scripts/logging/logger.gd). Si la firma cambia, los handlers del proyecto
## dejan de recibir y este fake lo delataria al no conectar.
class LoggerFalso extends Node:
	signal line_emitted(level: int, category: int, line: String)


## Backend falso con la API que la consola consume.
class BackendFalso extends Node:
	var lineas: Array = []
	var filtros := {"nivel": -1, "categoria": -1, "busqueda": "", "autoscroll": true}
	var fps_activo := false
	var peticiones: Array = []

	func console_get_lines() -> Array:
		return lineas

	func filtros_consola() -> Dictionary:
		return filtros.duplicate(true)

	func set_filtros_consola(f: Dictionary) -> Dictionary:
		peticiones.append(f.duplicate(true))
		for k in ["nivel", "categoria", "busqueda", "autoscroll"]:
			if f.has(k):
				filtros[k] = f[k]
		return filtros.duplicate(true)

	func toggle_activo(id_toggle: String) -> bool:
		if id_toggle == "fps":
			return fps_activo
		return false

	func esta_visible() -> bool:
		return false

	func alternar() -> void:
		pass


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _run() -> void:
	print("=== TEST %s: consola con filtros + overlay FPS + aviso dev ===" % MODULO)
	var cons_script: Script = load("res://scripts/debug/debug_console.gd")
	_check("A1 debug_console.gd carga", cons_script != null)
	if cons_script == null:
		return

	# ── Bloque A: los 4 widgets de filtro existen ──────────────────────────
	var cons: Control = cons_script.new()
	cons.call("_inyectar_backend", Node.new())
	cons.call("_inyectar_logger", Node.new())
	root.add_child(cons)
	_check("A2 la consola se monta como Control", cons is Control)
	var w: Dictionary = cons.call("widgets_filtros")
	_check("A3 hay exactamente 4 widgets de filtro", w.size() == 4)
	_check("A4 nivel, categoria, busqueda y autoscroll existen",
		bool(w.get("nivel", false)) and bool(w.get("categoria", false))
		and bool(w.get("busqueda", false)) and bool(w.get("autoscroll", false)))
	_check("A5 la barra 'Filtros' esta montada", cons.get_node_or_null("Filtros") != null)
	# Cruce contra el enum REAL del logger: si alguien agrega un nivel o una
	# categoria, esta suite se pone roja en vez de quedar desactualizada.
	var script_logger: Script = load("res://scripts/logging/logger.gd")
	var mapa: Dictionary = script_logger.get_script_constant_map()
	var mc: Dictionary = cons_script.get_script_constant_map()
	var niveles_ui: Array = mc.get("NIVELES", [])
	var categorias_ui: Array = mc.get("CATEGORIAS", [])
	_check("A6 NIVELES coincide con logger.Level (mas el comodin)",
		_coincide_enum(niveles_ui, _enum_ordenado(mapa, "Level")))
	_check("A7 CATEGORIAS coincide con logger.Category (mas el comodin)",
		_coincide_enum(categorias_ui, _enum_ordenado(mapa, "Category")))
	_fin("A")

	# ── Bloque B: filtro por nivel ─────────────────────────────────────────
	cons.call("limpiar")
	cons.call("_agregar_entrada", "d1 debug", 0, 2)
	cons.call("_agregar_entrada", "i1 info", 1, 2)
	cons.call("_agregar_entrada", "e1 ERROR grave", 3, 3)
	cons.call("aplicar_filtros", 3, -1, "", true)
	var vis_b: Array = cons.call("lineas_visibles")
	_check("B1 filtro nivel=ERROR deja 1 de 3", vis_b.size() == 1)
	_check("B2 la que queda es la de nivel ERROR", vis_b.size() == 1 and String(vis_b[0]) == "e1 ERROR grave")
	cons.call("aplicar_filtros", -1, -1, "", true)
	_check("B3 sin filtro vuelven las 3", (cons.call("lineas_visibles") as Array).size() == 3)
	cons.call("_agregar_linea", "sin metadato")
	cons.call("aplicar_filtros", 0, -1, "", true)
	_check("B4 una linea sin metadato no pasa un filtro de nivel",
		not _contiene(cons.call("lineas_visibles"), "sin metadato"))
	_fin("B")

	# ── Bloque C: filtro por categoria ─────────────────────────────────────
	cons.call("aplicar_filtros", -1, 3, "", true)
	_check("C1 filtro categoria=WORLD deja 1", (cons.call("lineas_visibles") as Array).size() == 1)
	cons.call("aplicar_filtros", 3, 3, "", true)
	_check("C2 nivel+categoria combinados dejan 1", (cons.call("lineas_visibles") as Array).size() == 1)
	cons.call("aplicar_filtros", 3, 2, "", true)
	_check("C3 una combinacion sin coincidencias deja 0", (cons.call("lineas_visibles") as Array).size() == 0)
	cons.call("aplicar_filtros", -1, -1, "", true)
	_check("C4 el reset devuelve las 4 entradas", (cons.call("lineas_visibles") as Array).size() == 4)
	_fin("C")

	# ── Bloque D: busqueda de texto ────────────────────────────────────────
	cons.call("aplicar_filtros", -1, -1, "error", true)
	_check("D1 la busqueda en minusculas encuentra 'ERROR'", (cons.call("lineas_visibles") as Array).size() == 1)
	cons.call("aplicar_filtros", -1, -1, "  GRAVE  ", true)
	_check("D2 la busqueda recorta espacios y no distingue mayusculas",
		(cons.call("lineas_visibles") as Array).size() == 1)
	cons.call("aplicar_filtros", -1, -1, "no-existe-xyz", true)
	_check("D3 una busqueda sin coincidencias deja 0", (cons.call("lineas_visibles") as Array).size() == 0)
	cons.call("aplicar_filtros", -1, -1, "", true)
	_check("D4 la busqueda vacia no filtra", (cons.call("lineas_visibles") as Array).size() == 4)
	_fin("D")

	# ── Bloque E: auto-scroll ──────────────────────────────────────────────
	_check("E1 el auto-scroll arranca encendido", bool(cons.call("autoscroll_activo")))
	var rich: RichTextLabel = cons.get_node_or_null("Consola")
	_check("E2 el RichTextLabel de la consola existe", rich != null)
	cons.call("aplicar_filtros", -1, -1, "", false)
	_check("E3 desmarcar apaga scroll_following", rich != null and not rich.scroll_following)
	cons.call("aplicar_filtros", -1, -1, "", true)
	_check("E4 volver a marcar lo enciende", rich != null and rich.scroll_following)
	_fin("E")

	# ── Bloque F: equivalencia con el filtro REAL del backend ──────────────
	# Dos implementaciones (widget y backend) que deben coincidir sobre los
	# mismos datos: si una deriva, esta suite lo delata.
	var datos := [
		[0, 2, "d1 debug"],
		[1, 2, "i1 info"],
		[3, 3, "e1 ERROR grave"],
		[2, 1, "w1 warn"],
		[4, 6, "c1 critico"],
		[3, 2, "e2 ERROR gameplay"],
	]
	var real_script: Script = load("res://scripts/debug/debug_menu.gd")
	var real: Node = real_script.new()
	for d in datos:
		real.call("_on_logger_line", int(d[0]), int(d[1]), String(d[2]))
	var cons2: Control = cons_script.new()
	cons2.call("_inyectar_backend", Node.new())
	cons2.call("_inyectar_logger", Node.new())
	root.add_child(cons2)
	for d in datos:
		cons2.call("_agregar_entrada", String(d[2]), int(d[0]), int(d[1]))
	_check("F1 el backend real acumula las 6 lineas", (real.call("console_get_lines") as Array).size() == 6)
	_check("F2 filtro por nivel identico al backend", _mismo_filtro(real, cons2, 3, -1, ""))
	_check("F3 filtro por categoria identico al backend", _mismo_filtro(real, cons2, -1, 2, ""))
	_check("F4 busqueda identica al backend", _mismo_filtro(real, cons2, -1, -1, "error"))
	_check("F5 nivel+categoria identico al backend", _mismo_filtro(real, cons2, 3, 2, ""))
	_check("F6 sin filtros identico al backend", _mismo_filtro(real, cons2, -1, -1, ""))
	_check("F7 busqueda parcial identica al backend", _mismo_filtro(real, cons2, -1, -1, "crit"))
	_fin("F")

	# ── Bloque G: persistencia (§N "Guardar filtros de consola") ───────────
	var bk: Node = BackendFalso.new()
	var cons3: Control = cons_script.new()
	cons3.call("_inyectar_backend", bk)
	cons3.call("_inyectar_logger", Node.new())
	root.add_child(cons3)
	cons3.call("aplicar_filtros", 3, 3, "x", false)
	var pet: Array = bk.get("peticiones")
	_check("G1 el backend recibe set_filtros_consola", pet.size() >= 1)
	var ult: Dictionary = {}
	if pet.size() >= 1:
		ult = pet[pet.size() - 1]
	_check("G2 la peticion lleva las 4 claves", ult.size() == 4 and ult.has("nivel")
		and ult.has("categoria") and ult.has("busqueda") and ult.has("autoscroll"))
	_check("G3 persiste nivel, categoria y busqueda",
		int(ult.get("nivel", -9)) == 3 and int(ult.get("categoria", -9)) == 3
		and String(ult.get("busqueda", "")) == "x")
	_check("G4 persiste autoscroll=false", bool(ult.get("autoscroll", true)) == false)
	var bk2: Node = BackendFalso.new()
	bk2.set("filtros", {"nivel": 3, "categoria": 3, "busqueda": "zz", "autoscroll": false})
	var cons4: Control = cons_script.new()
	cons4.call("_inyectar_backend", bk2)
	cons4.call("_inyectar_logger", Node.new())
	root.add_child(cons4)
	var f4: Dictionary = cons4.call("filtros_ui")
	_check("G5 al arrancar restaura los filtros guardados",
		int(f4.get("nivel", -9)) == 3 and int(f4.get("categoria", -9)) == 3
		and String(f4.get("busqueda", "")) == "zz" and bool(f4.get("autoscroll", true)) == false)
	_fin("G")

	# ── Bloque H: lineas vivas (el guard muerto que se corrigio) ───────────
	var log_f: Node = LoggerFalso.new()
	var cons5: Control = cons_script.new()
	cons5.call("_inyectar_backend", Node.new())
	cons5.call("_inyectar_logger", log_f)
	root.add_child(cons5)
	_check("H1 la consola queda suscrita a line_emitted", bool(cons5.call("conectado_al_logger")))
	_check("H2 con logger no hay motivo de fallo", String(cons5.call("motivo_sin_vivas")) == "")
	log_f.emit_signal("line_emitted", 3, 3, "linea viva ERROR")
	_check("H3 la linea viva llega a la consola", _contiene(cons5.call("lineas_visibles"), "linea viva ERROR"))
	cons5.call("aplicar_filtros", 3, -1, "", true)
	_check("H4 el metadato de la linea viva permite filtrar por nivel",
		(cons5.call("lineas_visibles") as Array).size() == 1)
	var cons6: Control = cons_script.new()
	cons6.call("_inyectar_backend", Node.new())
	cons6.call("_inyectar_logger", Node.new())
	root.add_child(cons6)
	_check("H5 sin logger la consola declara el motivo", String(cons6.call("motivo_sin_vivas")) != "")
	_fin("H")

	# ── Bloque I: overlay de FPS (§O L263) + aviso de desarrollo (§M L243) ─
	var escena: PackedScene = load("res://scenes/debug/debug_menu.tscn")
	_check("I1 la escena debug_menu.tscn carga", escena != null)
	if escena == null:
		return
	var ui: Node = escena.instantiate()
	var bk3: Node = BackendFalso.new()
	bk3.set("fps_activo", true)
	ui.call("_inyectar_menu", bk3)
	root.add_child(ui)
	var ov: Label = ui.call("obtener_overlay_fps")
	_check("I2 el overlay de FPS existe", ov != null)
	_check("I3 con el toggle fps activo el overlay se ve", ov != null and ov.visible)
	_check("I4 el overlay muestra el valor de FPS", ov != null and ov.text.begins_with("FPS: "))
	var t: Timer = ui.get_node_or_null("TimerFps")
	_check("I5 el timer refresca cada 0.5 s", t != null and is_equal_approx(t.wait_time, 0.5))
	bk3.set("fps_activo", false)
	ui.call("_actualizar_fps")
	_check("I6 con el toggle apagado el overlay se oculta", ov != null and not ov.visible)
	var av: Label = ui.call("obtener_aviso_dev")
	_check("I7 el aviso de desarrollo existe", av != null)
	_check("I8 el aviso dice 'SOLO PARA DESARROLLO'", av != null and av.text.find("SOLO PARA DESARROLLO") >= 0)
	_fin("I")

	# ── Bloque J: la consola NO se usa como cartel de pestaña ──────────────
	var ph: Label = ui.call("obtener_placeholder")
	var cons_ui: Control = ui.call("obtener_consola")
	_check("J1 placeholder y consola existen", ph != null and cons_ui != null)
	if cons_ui == null or ph == null:
		return
	cons_ui.call("agregar_linea_publica", "linea real de prueba")
	var tab: TabBar = ui.call("obtener_tab_bar")
	var ids: Array = ui.call("ids_pestanas")
	var i_jug: int = ids.find("jugador")
	var i_sis: int = ids.find("sistema")
	_check("J2 el config trae las pestañas jugador y sistema", i_jug >= 0 and i_sis >= 0)
	tab.current_tab = i_jug
	_check("J3 en 'jugador' se ve el cartel", ph.visible)
	_check("J4 en 'jugador' la consola esta oculta", not cons_ui.visible)
	tab.current_tab = i_sis
	_check("J5 en 'sistema' la consola esta visible", cons_ui.visible)
	# Afirmacion POSITIVA: el render tiene que ser el log real. Buscar solo el
	# literal viejo ("Panel: Sistema") no discriminaba: el defecto escribe el id
	# en minusculas ("Panel: sistema") y la sonda P5 pasaba en verde.
	var render := String(cons_ui.call("texto_renderizado"))
	_check("J6 el render es el log real y no un cartel 'Panel:'",
		render.find("linea real de prueba") >= 0 and render.to_lower().find("panel:") < 0)
	_check("J7 las lineas reales sobreviven al cambio de pestaña",
		_contiene(cons_ui.call("obtener_lineas"), "linea real de prueba"))
	_fin("J")

	ui.queue_free()
	cons.queue_free()
	cons2.queue_free()
	cons3.queue_free()
	cons4.queue_free()
	cons5.queue_free()
	cons6.queue_free()
	real.free()


## Filtra con el backend REAL y con el widget, y compara linea por linea.
func _mismo_filtro(real: Node, cons: Control, nivel: int, categoria: int, busqueda: String) -> bool:
	real.call("set_filtros_consola", {
		"nivel": nivel, "categoria": categoria, "busqueda": busqueda, "autoscroll": true,
	})
	cons.call("aplicar_filtros", nivel, categoria, busqueda, true)
	var a: Array = real.call("aplicar_filtros_consola")
	var b: Array = cons.call("lineas_visibles")
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if String(a[i]) != String(b[i]):
			return false
	return true


## Ordena las claves de un enum del script por su valor entero.
func _enum_ordenado(mapa: Dictionary, clave: String) -> Array[String]:
	var salida: Array[String] = []
	var e: Variant = mapa.get(clave, null)
	if not (e is Dictionary):
		return salida
	var d: Dictionary = e
	var pares: Array = []
	for k in d.keys():
		pares.append([int(d[k]), String(k)])
	pares.sort_custom(func(x, y): return int(x[0]) < int(y[0]))
	for p in pares:
		salida.append(String(p[1]))
	return salida


## La lista de la UI lleva el comodin en el indice 0; el resto debe coincidir
## (sin distinguir mayusculas) con el enum real, en orden.
func _coincide_enum(ui: Array, real: Array[String]) -> bool:
	if real.size() == 0:
		return false
	if ui.size() - 1 != real.size():
		return false
	for i in range(real.size()):
		if String(ui[i + 1]).to_upper() != real[i].to_upper():
			return false
	return true


func _contiene(arr: Variant, texto: String) -> bool:
	if not (arr is Array):
		return false
	for x in (arr as Array):
		if String(x) == texto:
			return true
	return false


func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s" % nombre)


func _fin(bloque: String) -> void:
	_vistos[bloque] = true


func _summary() -> void:
	for b in BLOQUES:
		if not _vistos.has(b):
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	quit(1 if _fallos > 0 else 0)
