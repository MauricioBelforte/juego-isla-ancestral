extends SceneTree

# Modelo: DeepSeek-V4.1-Flash (OpenCode)
# Plataforma: OpenCode
# Fecha: 2026-11-11
#
# M17 Construccion — suite NUEVA del item L84 del checklist:
#   "Seleccion de pieza por categorias: estructura, mobiliario, iluminacion, decoracion [M]"
#
# POR QUE EXISTE: el catalogo tiene 12 familias canonicas (pared, piso, techo, puerta,
# ventana, escalera, camino, cerca, puente, mueble, iluminacion, decoracion) pero NINGUNA
# clasificacion por categoria: la marca L84 estaba en `[ ]` y el HUD no podia agrupar.
# Las categorias son un eje DISTINTO del modo (que filtra por `es_mueble`): un puente con
# `es_mueble = true` aparece en modo decoracion pero pertenece a la categoria estructura.
#
# ACCESO DINAMICO (medido en Godot 4.7.2, 2026-11-11): llamar a un `static func` sobre un
# `const preload` lo resuelve el PARSER y rompe la suite si la funcion aun no existe
# ("Static function ... not found in base"). Cargando el script con `load()` el objeto es
# un `Script`: `has_method()` y `call()` funcionan y la suite corre en RED con fallos
# medidos en vez de reventar al compilar. `get_script_constant_map()` expone enums y consts.
# (No llamar `call()` a un metodo INEXISTENTE sobre un Script: cuelga el proceso.)
#
# Uso:
#   "<godot>" --headless --path game/isla-ancestral --script res://tests/test_m17_categorias.gd
# Exit: 0 = verde medido | 1 = fallos

const CHECKS_MINIMOS := 23
const TOTAL_CATALOGO := 46

var _tipos: Script = load("res://scripts/construccion/construccion_tipos.gd")
var _hud: Script = load("res://scripts/construccion/build_hud.gd")
var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []


func _initialize() -> void:
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: la suite excedio 120 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	w.start()
	call_deferred("_correr")


func _check(nombre: String, ok: bool, detalle: String = "") -> void:
	_checks += 1
	if ok:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])


## Constantes del script de tipos (enums, arrays, diccionarios) sin romper el parser.
func _k(nombre: String) -> Variant:
	if _tipos == null:
		return null
	return _tipos.get_script_constant_map().get(nombre, null)


## id de categoria por nombre (ESTRUCTURA, MOBILIARIO, ...) o -1 si no existe.
func _cat(nombre: String) -> int:
	var enum_cat: Variant = _k("Categoria")
	if enum_cat == null or not (enum_cat is Dictionary):
		return -1
	return int((enum_cat as Dictionary).get(nombre, -1))


func _correr() -> void:
	await process_frame
	await process_frame
	print("=== M17 categorias de pieza (item L84) ===")

	var enum_cat: Variant = _k("Categoria")
	var categorias: Variant = _k("CATEGORIAS")
	var mapa_fam: Variant = _k("CATEGORIA_DE_FAMILIA")

	# ── A. Tipos: las 4 categorias canonicas del item L84 ──
	_check("ConstruccionTipos define el enum Categoria", enum_cat is Dictionary,
		"tipo=%s" % type_string(typeof(enum_cat)))
	var nombres := ["ESTRUCTURA", "MOBILIARIO", "ILUMINACION", "DECORACION"]
	var faltan: Array = []
	for n in nombres:
		if _cat(n) < 0:
			faltan.append(n)
	_check("el enum tiene las 4 categorias del item L84", faltan.is_empty(),
		"faltan=%s" % str(faltan))

	_check("CATEGORIAS existe y tiene 4 elementos",
		categorias is Array and (categorias as Array).size() == 4,
		"n=%s" % (str((categorias as Array).size()) if categorias is Array else "n/a"))
	var orden_ok := false
	if categorias is Array and (categorias as Array).size() == 4:
		orden_ok = (int((categorias as Array)[0]) == _cat("ESTRUCTURA")
			and int((categorias as Array)[1]) == _cat("MOBILIARIO")
			and int((categorias as Array)[2]) == _cat("ILUMINACION")
			and int((categorias as Array)[3]) == _cat("DECORACION"))
	_check("orden canonico: estructura, mobiliario, iluminacion, decoracion", orden_ok)

	# Las 12 familias reales del catalogo deben estar mapeadas.
	var familias_reales := [&"camino", &"cerca", &"decoracion", &"escalera", &"iluminacion",
		&"mueble", &"pared", &"piso", &"puente", &"puerta", &"techo", &"ventana"]
	var sin_mapa: Array = []
	if mapa_fam is Dictionary:
		for f in familias_reales:
			if not (mapa_fam as Dictionary).has(f):
				sin_mapa.append(String(f))
	else:
		sin_mapa = familias_reales.duplicate()
	_check("CATEGORIA_DE_FAMILIA cubre las 12 familias del catalogo", sin_mapa.is_empty(),
		"sin mapear=%s" % str(sin_mapa))

	var tiene_texto := _tipos != null and _tipos.has_method("texto_categoria")
	var textos: Array = []
	for n in nombres:
		textos.append(String(_tipos.call("texto_categoria", _cat(n))) if tiene_texto else "")
	var textos_ok := textos.size() == 4
	for t in textos:
		if String(t) == "":
			textos_ok = false
	_check("texto_categoria devuelve 4 textos no vacios", textos_ok, "textos=%s" % str(textos))

	if _tipos != null and _tipos.has_method("categoria_de_familia"):
		_check("familia 'pared' -> ESTRUCTURA",
			_cat("ESTRUCTURA") == int(_tipos.call("categoria_de_familia", &"pared")))
		_check("familia inventada -> DESCONOCIDA (-1), sin romper",
			int(_tipos.call("categoria_de_familia", &"familia_que_no_existe")) == -1)
	else:
		_check("familia 'pared' -> ESTRUCTURA", false, "falta categoria_de_familia()")
		_check("familia inventada -> DESCONOCIDA (-1), sin romper", false, "falta categoria_de_familia()")

	# ── B. Catalogo real ──
	var mgr = root.get_node_or_null("Construccion")
	_check("autoload Construccion presente", mgr != null)
	if mgr == null:
		_resumen()
		return

	var catalogo: Dictionary = mgr.catalogo()
	_check("catalogo carga %d recetas" % TOTAL_CATALOGO, catalogo.size() == TOTAL_CATALOGO,
		"n=%d" % catalogo.size())

	if not mgr.has_method("categoria_de"):
		_check("manager expone categoria_de()", false, "falta")
	else:
		var desconocidas: Array = []
		var reparto := {_cat("ESTRUCTURA"): 0, _cat("MOBILIARIO"): 0, _cat("ILUMINACION"): 0, _cat("DECORACION"): 0}
		for r in catalogo.values():
			var c: int = int(mgr.categoria_de(r))
			if not reparto.has(c):
				desconocidas.append(String((r as PlacementRule).id))
			else:
				reparto[c] = int(reparto[c]) + 1
		_check("ninguna receta con categoria desconocida", desconocidas.is_empty(),
			"desconocidas=%s" % str(desconocidas))
		_check("estructura = 26", int(reparto.get(_cat("ESTRUCTURA"), -1)) == 26,
			"n=%d" % int(reparto.get(_cat("ESTRUCTURA"), -1)))
		_check("mobiliario = 4", int(reparto.get(_cat("MOBILIARIO"), -1)) == 4,
			"n=%d" % int(reparto.get(_cat("MOBILIARIO"), -1)))
		_check("iluminacion = 3", int(reparto.get(_cat("ILUMINACION"), -1)) == 3,
			"n=%d" % int(reparto.get(_cat("ILUMINACION"), -1)))
		_check("decoracion = 13", int(reparto.get(_cat("DECORACION"), -1)) == 13,
			"n=%d" % int(reparto.get(_cat("DECORACION"), -1)))

	# ── C. Manager: seleccion por categoria ──
	if not mgr.has_method("piezas_por_categoria"):
		for nombre in ["categorias() devuelve 4", "piezas_por_categoria() tiene las 4 claves",
				"suma de categorias = 46", "estructura no mezcla muebles",
				"categoria desconocida -> []", "modo decoracion solo muebles"]:
			_check(nombre, false, "falta piezas_por_categoria()")
	else:
		if mgr.has_method("categorias"):
			_check("categorias() devuelve 4", (mgr.categorias() as Array).size() == 4,
				"n=%d" % (mgr.categorias() as Array).size())
		else:
			_check("categorias() devuelve 4", false, "falta categorias()")

		var por_cat: Dictionary = mgr.piezas_por_categoria()
		var claves_ok := por_cat.has(_cat("ESTRUCTURA")) and por_cat.has(_cat("MOBILIARIO")) \
			and por_cat.has(_cat("ILUMINACION")) and por_cat.has(_cat("DECORACION"))
		_check("piezas_por_categoria() tiene las 4 claves siempre", claves_ok,
			"claves=%s" % str(por_cat.keys()))

		var suma := 0
		for k in por_cat.keys():
			suma += (por_cat[k] as Array).size()
		_check("suma de categorias = %d (sin duplicados ni perdidas)" % TOTAL_CATALOGO,
			suma == TOTAL_CATALOGO, "suma=%d" % suma)

		var est: Array = mgr.piezas_de_categoria(_cat("ESTRUCTURA")) if mgr.has_method("piezas_de_categoria") else []
		var muebles_en_est: Array = []
		for r in est:
			if (r as PlacementRule).familia == &"mueble":
				muebles_en_est.append(String((r as PlacementRule).id))
		_check("estructura no mezcla la familia mueble", muebles_en_est.is_empty(),
			"colados=%s" % str(muebles_en_est))

		var vacia: Array = mgr.piezas_de_categoria(-1) if mgr.has_method("piezas_de_categoria") else [null]
		_check("categoria desconocida -> [] sin error", vacia.is_empty(), "n=%d" % vacia.size())

		var deco: Array = mgr.piezas_por_categoria(ConstruccionTipos.Modo.DECORACION).get(_cat("ESTRUCTURA"), [])
		var no_muebles: Array = []
		for r in deco:
			if not (r as PlacementRule).es_mueble:
				no_muebles.append(String((r as PlacementRule).id))
		_check("modo decoracion filtra por es_mueble tambien dentro de la categoria",
			no_muebles.is_empty(), "no-muebles=%s" % str(no_muebles))

	# ── D. HUD: filas listas para pintar ──
	var tiene_filas := _hud != null and _hud.has_method("filas_categorias")
	if not mgr.has_method("piezas_por_categoria") or not tiene_filas:
		_check("BuildHudModel.filas_categorias disponible", tiene_filas, "falta")
		_check("cada fila tiene categoria/nombre/cantidad", false, "sin filas")
		_check("las cantidades del HUD suman %d" % TOTAL_CATALOGO, false, "sin filas")
	else:
		var filas: Array = _hud.call("filas_categorias", mgr, ConstruccionTipos.Modo.CONSTRUCCION)
		_check("BuildHudModel.filas_categorias disponible", true)
		_check("cada fila tiene categoria/nombre/cantidad", filas.size() == 4,
			"filas=%d" % filas.size())
		var suma_hud := 0
		var forma_ok := true
		for f in filas:
			if not (f is Dictionary) or not (f as Dictionary).has("categoria") \
					or not (f as Dictionary).has("nombre") or not (f as Dictionary).has("cantidad"):
				forma_ok = false
			else:
				suma_hud += int((f as Dictionary)["cantidad"])
		_check("las cantidades del HUD suman %d" % TOTAL_CATALOGO,
			forma_ok and suma_hud == TOTAL_CATALOGO, "suma=%d forma_ok=%s" % [suma_hud, str(forma_ok)])

	_resumen()


func _resumen() -> void:
	print()
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("PISO DE CHECKS NO CUMPLIDO: %d < %d" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M17 categorias: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("Fallos:")
		for d in _detalles:
			print("  - " + d)
	quit(1 if _fallos > 0 else 0)
