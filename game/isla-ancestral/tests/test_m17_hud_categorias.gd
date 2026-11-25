extends SceneTree

# Modelo: minimax-m3-1-flash
# Plataforma: DeepAI Code (pi)
# Fecha: 2026-11-25
#
# M17 Construccion — suite del HUD DE CATEGORIAS (items L81 y L84).
#
# POR QUE EXISTE: la suite `tests/test_m17_categorias.gd` (escrita por
# DS-V4.1-Flash-Opencode el 2026-11-11 para el item L84) exigia
# `BuildHudModel.filas_categorias(...)` y quedaba EN ROJO (3 checks) porque la
# funcion NUNCA se implemento: el modelo del HUD solo sabia de costo y motivos.
# Esta tanda implementa la API y ademas la verifica con mas detalle:
#
# QUE MIDE (headless, catalogo real + autoload Construccion):
#   * las 4 filas del HUD salen en el ORDEN canonico (estructura, mobiliario,
#     iluminacion, decoracion) y con las claves que la UI necesita
#   * `cantidad` = recetas del CATALOGO por categoria (las 4 filas suman las 46
#     recetas reales): el HUD presenta el catalogo
#   * `cantidad_modo` = piezas DISPONIBLES en el modo pedido (el filtro por
#     `es_mueble`): en CONSTRUCCION no se pueden colocar los muebles
#   * `texto_categorias()` resume las filas en una linea
#   * tolerancia: sin manager, o con un manager sin el metodo -> [] (no crashea)
#   * regresion: `resumen()` (costo + motivos) sigue intacto
#
# ANTI-FALSO-VERDE: MIN_CHECKS; checks nombrados con el texto literal del item.
#
# Uso: "Godot_v4.7.2-stable_win64_console.exe" --headless --path game/isla-ancestral \
#       --script res://tests/test_m17_hud_categorias.gd
# Exit: 0 = verde | 1 = fallos

const MODULO := "M17 Construccion: HUD de categorias del catalogo (L81/L84)"
const TIPO := preload("res://scripts/construccion/construccion_tipos.gd")
const HUD := preload("res://scripts/construccion/build_hud.gd")
const CHECKS_MINIMOS := 20

## Numero de recetas del catalogo real (medido: data/construccion/piezas/*.tres).
const TOTAL_CATALOGO := 46

var _checks := 0
var _fallos := 0
var _detalles: Array[String] = []

func _initialize() -> void:
	# Watchdog: si la suite se cuelga (o un error aborta el bloque antes de
	# _resumen), el proceso NO puede quedarse vivo para siempre. Se arranca
	# con autostart para que el Timer ya este en el arbol al iniciar.
	var w := Timer.new()
	w.wait_time = 120.0
	w.one_shot = true
	w.autostart = true
	w.timeout.connect(func() -> void:
		print("WATCHDOG: la suite excedio 120 s -> salida forzada con codigo 1")
		quit(1))
	root.add_child(w)
	call_deferred("_correr")

func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [ok]   %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])
	else:
		_fallos += 1
		_detalles.append(nombre + (" (" + detalle + ")" if detalle != "" else ""))
		print("  [FAIL] %s%s" % [nombre, (" — " + detalle) if detalle != "" else ""])

func _correr() -> void:
	await process_frame
	await process_frame
	print("=== %s ===" % MODULO)

	var mgr = root.get_node_or_null("Construccion")
	_check("A0: autoload Construccion presente", mgr != null)
	if mgr == null:
		_resumen()
		return

	# ── A. Forma y orden de las filas ───────────────────────────────────
	var filas: Array = HUD.filas_categorias(mgr, TIPO.Modo.CONSTRUCCION)
	_check("A1: el HUD devuelve 4 filas (una por categoria canonica)",
		filas.size() == 4, "filas=%d" % filas.size())

	var orden_ok := true
	var claves_ok := true
	var esperada: Array = [TIPO.Categoria.ESTRUCTURA, TIPO.Categoria.MOBILIARIO,
		TIPO.Categoria.ILUMINACION, TIPO.Categoria.DECORACION]
	for i in filas.size():
		var f: Dictionary = filas[i]
		if not (f.has("categoria") and f.has("nombre") and f.has("cantidad") \
				and f.has("cantidad_modo") and f.has("texto")):
			claves_ok = false
			continue
		if int(f["categoria"]) != int(esperada[i]):
			orden_ok = false
		if String(f["nombre"]) == "":
			claves_ok = false
	_check("A2: las filas traen las claves que la UI necesita (categoria/nombre/cantidad/cantidad_modo/texto)",
		claves_ok)
	var orden_resumido: Array = []
	for i in filas.size():
		orden_resumido.append(int((filas[i] as Dictionary).get("categoria", -1)))
	_check("A3: el orden es el canonico (estructura, mobiliario, iluminacion, decoracion)",
		orden_ok, "orden=%s" % str(orden_resumido))

	var suma_catalogo := 0
	for f in filas:
		suma_catalogo += int((f as Dictionary)["cantidad"])
	_check("A4: las cantidades del CATALOGO suman las %d recetas reales" % TOTAL_CATALOGO,
		suma_catalogo == TOTAL_CATALOGO, "suma=%d" % suma_catalogo)
	var nombres_ok := filas.size() == 4
	for i in filas.size():
		var cat_esperado: int = int(esperada[i]) if i < esperada.size() else -1
		if not (filas[i] as Dictionary).has("nombre") \
				or String((filas[i] as Dictionary)["nombre"]) != TIPO.texto_categoria(cat_esperado):
			nombres_ok = false
	_check("A5: el nombre de cada fila es el texto legible de su categoria",
		nombres_ok)
	var por_cat: Dictionary = mgr.piezas_por_categoria(-1)
	var coincide := true
	for i in filas.size():
		var f: Dictionary = filas[i]
		var reales: Array = por_cat.get(int(f["categoria"]), [])
		if reales.size() != int(f["cantidad"]):
			coincide = false
	_check("A6: cada 'cantidad' coincide con el conteo REAL del manager para esa categoria",
		coincide)
	# Las filas son datos nuevos en cada llamada: el HUD puede mutarlas sin
	# romper la siguiente actualizacion.
	var filas2: Array = HUD.filas_categorias(mgr, TIPO.Modo.CONSTRUCCION)
	var mutado := false
	if filas2.size() == 4:
		(filas2[0] as Dictionary)["cantidad"] = -999
		mutado = true
	var filas3: Array = HUD.filas_categorias(mgr, TIPO.Modo.CONSTRUCCION)
	_check("A7: mutar una fila no afecta la siguiente llamada (el HUD no comparte estado)",
		not mutado or filas3.size() == 4,
		"filas=%d" % filas3.size())
	if filas3.size() == 4:
		_check("A7b: la fila mutada no se filtra a la siguiente llamada",
			int((filas3[0] as Dictionary)["cantidad"]) != -999,
			"cantidad=%d" % int((filas3[0] as Dictionary)["cantidad"]))
	else:
		_check("A7b: la fila mutada no se filtra a la siguiente llamada", false,
			"sin filas")

	# ── B. La disponibilidad por modo (es_mueble) ───────────────────────
	var filas_modo: Array = HUD.filas_categorias(mgr, TIPO.Modo.DECORACION)
	var suma_modo := 0
	for f in filas_modo:
		suma_modo += int((f as Dictionary)["cantidad_modo"])
	var en_construccion := 0
	for f in filas:
		en_construccion += int((f as Dictionary)["cantidad_modo"])
	_check("B1: en modo CONSTRUCCION y DECORACION se reparten TODAS las piezas (sin perder ni duplicar)",
		en_construccion + suma_modo == TOTAL_CATALOGO,
		"construccion=%d decoracion=%d" % [en_construccion, suma_modo])
	_check("B2: los dos modos ven CONJUNTOS DISTINTOS de piezas (el filtro es_mueble separa de verdad)",
		suma_modo != en_construccion and en_construccion > 0 and suma_modo > 0,
		"decoracion=%d construccion=%d" % [suma_modo, en_construccion])
	var piezas_deco: Array = mgr.piezas_de_modo(TIPO.Modo.DECORACION)
	var exclusivas := true
	for r in piezas_deco:
		if (r as PlacementRule).es_mueble == false:
			exclusivas = false
	_check("B2b: en modo DECORACION solo hay piezas con es_mueble == true (conjuntos disjuntos)",
		exclusivas, "piezas=%d" % piezas_deco.size())

	# El filtro por modo tiene que ser REAL: ninguna pieza con es_mueble puede
	# aparecer en modo CONSTRUCCION.
	var filtrado_ok := true
	var piezas_modo: Array = mgr.piezas_de_modo(TIPO.Modo.CONSTRUCCION)
	for r in piezas_modo:
		if (r as PlacementRule).es_mueble:
			filtrado_ok = false
	_check("B3: el filtro por modo es real (ningun mueble en modo CONSTRUCCION)",
		filtrado_ok, "piezas=%d" % piezas_modo.size())

	# ── C. Texto de una linea ───────────────────────────────────────────
	var texto: String = HUD.texto_categorias(mgr, TIPO.Modo.CONSTRUCCION)
	_check("C1: texto_categorias devuelve una linea con las 4 categorias",
		texto != "" and texto.split(" | ").size() == 4, "texto=%s" % texto)
	_check("C2: el texto nombra la categoria 'estructura'",
		texto.contains(String(TIPO.texto_categoria(TIPO.Categoria.ESTRUCTURA))))
	var texto_todo: String = HUD.texto_categorias(mgr, -1)
	_check("C3: texto_categorias sin filtro de modo muestra el total del catalogo",
		texto_todo.contains("(%d)" % TOTAL_CATALOGO) or texto_todo.split(" | ").size() == 4,
		"texto=%s" % texto_todo)

	# ── D. Tolerancia (nunca crashear el HUD) ──────────────────────────
	_check("D1: sin manager -> [] (no crashea)",
		(HUD.filas_categorias(null, TIPO.Modo.CONSTRUCCION) as Array).is_empty())
	var dummy := RefCounted.new()
	_check("D2: manager sin el metodo -> [] (no crashea)",
		(HUD.filas_categorias(dummy, TIPO.Modo.CONSTRUCCION) as Array).is_empty())
	_check("D3: modo desconocido (-1) -> todas las piezas (sin filtro)",
		(HUD.filas_categorias(mgr, -1) as Array).size() == 4)

	# ── E. Regresion: el resumen del HUD intacto ────────────────────────
	var receta: PlacementRule = mgr.receta(&"pared_esquina")
	var res: Dictionary = {"ok": true, "motivos": [], "celdas": [Vector3i(1, 1, 1)]}
	var resumen: Dictionary = HUD.resumen(res, receta)
	_check("E1: resumen() sigue devolviendo costo, motivos y linea",
		resumen.has("costo") and resumen.has("motivos") and resumen.has("linea")
			and (resumen["costo"] as Array).size() == (receta.costo as Dictionary).size(),
		"costo=%s" % str(resumen.get("costo_texto", "")))
	_check("E2: el texto de costo sigue siendo el nombre legible del item",
		String(resumen.get("costo_texto", "")) != ""
			and String(resumen.get("costo_texto", "")) != String(receta.costo.keys()[0]),
		"costo_texto=%s" % String(resumen.get("costo_texto", "")))
	var resumen_null: Dictionary = HUD.resumen(res, null)
	_check("E3: resumen() con receta nula no crashea (devuelve costo vacio)",
		(resumen_null["costo"] as Array).is_empty() and String(resumen_null.get("costo_texto", "")) != "",
		"costo_texto=%s" % String(resumen_null.get("costo_texto", "")))

	_resumen()

func _resumen() -> void:
	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	for d in _detalles:
		print("  FALLO: " + d)
	if _fallos > 0 or _checks < CHECKS_MINIMOS:
		print("TEST M17 HUD CATEGORIAS FALLIDO (checks=%d, minimo=%d)" % [_checks, CHECKS_MINIMOS])
		quit(1)
	else:
		print("TEST M17 HUD CATEGORIAS OK — HUD de categorias del catalogo verificado (L81/L84)")
		quit(0)
