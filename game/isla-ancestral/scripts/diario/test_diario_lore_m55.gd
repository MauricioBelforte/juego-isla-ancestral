# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M55 (iter. 7): suite de la regla "??? SOLO en secciones lore" (checklist L164,
# diseno §3.2 y §11.1) y del campo opcional `icono` del catalogo.
#
# Por que existe: la capa mostraba "???" para CUALQUIER entrada marcada
# `secreta`, sin mirar la seccion. §3.2 dice "SOLO en secciones lore" y §11.1
# prohibe la marca en colecciones (criaturas, plantas, minerales, recetas), asi
# que una `secreta` mal puesta dejaba una entrada de coleccion visible como
# "???" en vez de invisible. Ahora la decision vive en UN solo lugar
# (secciones_lore.gd) que usan el servicio, la capa y el validador.
#
# Bloques:
#  A. modulo puro: clasificacion de las 14 categorias + tabla de verdad de
#     `bloqueada()` + cruce con CATEGORIAS del servicio.
#  B. servicio: visibilidad real con un catalogo sintetico (la secreta de lore
#     aparece como "???"; la de coleccion NO aparece hasta registrarse).
#  C. capa REAL instanciada en el arbol: texto de fila y de detalle para ambos
#     casos + fallback de categoria cuando falta "cat".
#  D. regla de datos: catalogo real sin violaciones + fixture que la dispara
#     (una regla que nunca puede fallar no verifica nada).
#  E. loader del catalogo: propaga `icono` (nivel 1 del resolutor alcanzable).
#
# Guardian de 3 capas (patron M105/M122): marcadores `_fin()` por bloque,
# `_summary()` en un `call_deferred` SEPARADO (corre aunque `_run()` aborte) y
# piso de checks MEDIDO en verde. Sonda de rojo: inyectar un aborto de runtime
# al inicio de un bloque -> debe nombrarlo, disparar el piso y salir EXIT 1.
#
# Estado del servicio y del catalogo se SNAPSHOTEA y se RESTAURA al final.
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/test_diario_lore_m55.gd
extends SceneTree

## Piso de checks MEDIDO en verde (se re-mide cada vez que la suite crece).
const CHECKS_MINIMOS: int = 67

const LORE := preload("res://scripts/diario/secciones_lore.gd")
const RUTA_CATALOGO := "res://data/diario/diario_catalog.json"
const RUTA_LAYER := "res://scripts/ui/layers/diary_layer.gd"
const BLOQUES := ["A", "B", "C", "D", "E"]

var _vistos: Dictionary = {}
var _fallos: int = 0
var _checks: int = 0
var _terminado := false
var _diary: Node = null
var _capa = null
var _snap_catalogo: Dictionary = {}
var _snap_save: Dictionary = {}


func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	# El desglose por bloque se MIDE (no se copia): la diferencia entre dos
	# acumulados consecutivos es lo que aporta cada bloque.
	print("[bloque %s] checks acumulados: %d" % [nombre, _checks])


func _run() -> void:
	_diary = root.get_node_or_null("Diary")
	if _diary != null:
		_snap_catalogo = (_diary._catalogo as Dictionary).duplicate(true)
		_snap_save = (_diary.get_save_data() as Dictionary).duplicate(true)

	# ── A: clasificación lore (módulo puro) ─────────────────────────────
	_check(LORE.CATEGORIAS.size() == 4,
		"A: 4 secciones lore declaradas (llegaron %d)" % LORE.CATEGORIAS.size())
	for c in ["pistas", "sellos", "ruinas", "cartas"]:
		_check(LORE.es_lore(String(c)), "A: '%s' es lore" % String(c))
	var colecciones := ["personajes", "lugares", "criaturas", "plantas", "minerales",
		"recetas", "descubrimientos", "misiones", "eventos", "fotografias"]
	for c in colecciones:
		_check(not LORE.es_lore(String(c)), "A: '%s' NO es lore (colección)" % String(c))
	_check(not LORE.es_lore(""), "A: categoría vacía no es lore")
	_check(not LORE.es_lore("PISTAS"), "A: la clasificación distingue mayúsculas")
	_check(not LORE.es_lore(" pistas"), "A: sin tolerancia a espacios")
	_check(LORE.bloqueada("pistas", true, false),
		"A: lore + secreta + no registrada -> '???'")
	_check(not LORE.bloqueada("pistas", true, true),
		"A: lore + secreta + registrada -> visible")
	_check(not LORE.bloqueada("pistas", false, false),
		"A: lore + no secreta -> visible")
	_check(not LORE.bloqueada("criaturas", true, false),
		"A: colección + secreta + no registrada -> NO '???' (L164)")
	_check(not LORE.bloqueada("criaturas", true, true),
		"A: colección + secreta + registrada -> visible")
	_check(not LORE.bloqueada("", true, false),
		"A: categoría vacía nunca bloquea")
	if _diary != null:
		var cats: Array = _diary.get_categorias()
		_check(cats.size() == 14, "A: el servicio expone 14 categorías (llegaron %d)" % cats.size())
		for c in LORE.CATEGORIAS:
			_check(String(c) in cats,
				"A: la sección lore '%s' existe en CATEGORIAS del servicio" % String(c))
	_fin("A")

	# ── B: visibilidad en el servicio (catálogo sintético) ──────────────
	_check(_diary != null, "B: autoload Diary presente")
	if _diary == null:
		_fin("B")
		_fin("C")
		_fin("D")
		_fin("E")
		_terminado = true
		return
	_diary._catalogo = {
		"pistas": [
			{"id": "probe_lore_secreta", "titulo": "Secreto de lore", "secreta": true,
				"descripcion": "d", "refs": [], "icono": ""},
			{"id": "probe_lore_normal", "titulo": "Pista normal", "secreta": false,
				"descripcion": "d", "refs": [], "icono": ""},
		],
		"criaturas": [
			{"id": "probe_col_secreta", "titulo": "Secreto de coleccion", "secreta": true,
				"descripcion": "d", "refs": [], "icono": "icono_declarado"},
			{"id": "probe_col_normal", "titulo": "Criatura normal", "secreta": false,
				"descripcion": "d", "refs": [], "icono": ""},
		],
	}
	_diary.restore_save_data({"schema_version": 1, "entradas": {}})
	var lore_vis: Array = _diary.entradas_de("pistas")
	var col_vis: Array = _diary.entradas_de("criaturas")
	_check(lore_vis.size() == 1,
		"B: en lore la secreta no registrada SÍ aparece (llegaron %d)" % lore_vis.size())
	_check(col_vis.size() == 0,
		"B: en colección la secreta no registrada NO aparece (llegaron %d)" % col_vis.size())
	if lore_vis.size() == 1:
		var e: Dictionary = lore_vis[0]
		_check(String(e.get("id", "")) == "probe_lore_secreta",
			"B: la visible en lore es la secreta (%s)" % String(e.get("id", "")))
		_check(bool(e.get("secreta", false)), "B: conserva secreta=true")
		_check(not bool(e.get("registrada", true)), "B: con registrada=false")
	_check(_diary.registrar("probe_col_normal", "criaturas"), "B: registrar la colección normal")
	_check(_diary.entradas_de("criaturas").size() == 1,
		"B: una colección normal registrada es visible")
	_check(_diary.registrar("probe_col_secreta", "criaturas"),
		"B: registrar la secreta de colección")
	_check(_diary.entradas_de("criaturas").size() == 2,
		"B: una secreta de colección registrada se ve como cualquier otra")
	_check(_diary.registrar("probe_lore_secreta", "pistas"), "B: registrar la secreta de lore")
	var lore_reg: Array = _diary.entradas_de("pistas")
	# Sigue siendo 1: la pista NORMAL del fixture no está registrada y no es
	# secreta, así que sigue invisible (anti-spoiler). La que cambia es el
	# estado de la secreta, que pasa a registrada.
	_check(lore_reg.size() == 1,
		"B: la pista normal sin registrar sigue invisible (llegaron %d)" % lore_reg.size())
	if lore_reg.size() == 1:
		_check(bool((lore_reg[0] as Dictionary).get("registrada", false)),
			"B: la secreta de lore queda registrada tras registrar()")
		_check(String((lore_reg[0] as Dictionary).get("id", "")) == "probe_lore_secreta",
			"B: y es la misma entrada (%s)" % String((lore_reg[0] as Dictionary).get("id", "")))
	_fin("B")

	# ── C: la capa REAL (texto de fila y de detalle) ────────────────────
	var ui = root.get_node_or_null("UIManager")
	var loc = root.get_node_or_null("Localization")
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("es")
	var script := load(RUTA_LAYER)
	_check(script != null, "C: diary_layer.gd carga")
	if script != null and script.can_instantiate():
		if ui != null:
			var previa = ui._buscar_capa("DiaryLayer")
			if previa != null:
				previa.free()
		_capa = script.new()
		_capa.name = "DiaryLayer"
		root.add_child(_capa)
		_check(_capa._lbl_det_titulo != null, "C: la capa construyó su UI (LblDetTitulo)")
		_check(String(_capa._t("DIARY.BLOQUEADO")) == "???",
			"C: DIARY.BLOQUEADO traduce a '???' en es")
		var e_lore := {"id": "probe_lore_secreta", "cat": "pistas",
			"titulo": "Secreto de lore", "secreta": true, "registrada": false,
			"estado": 0, "favorito": false}
		var e_col := {"id": "probe_col_secreta", "cat": "criaturas",
			"titulo": "Secreto de coleccion", "secreta": true, "registrada": false,
			"estado": 0, "favorito": false}
		_check(String(_capa._texto_fila(e_lore)) == "???",
			"C: fila de lore secreta = '???'")
		_check(String(_capa._texto_fila(e_col)).contains("Secreto de coleccion"),
			"C: fila de colección secreta muestra el título, no '???'")
		_capa._sel = e_lore
		_capa._refrescar_detalle()
		_check(String(_capa._lbl_det_titulo.text) == "???",
			"C: detalle de lore secreta = '???'")
		_capa._sel = e_col
		_capa._refrescar_detalle()
		_check(String(_capa._lbl_det_titulo.text) == "Secreto de coleccion",
			"C: detalle de colección secreta muestra el título")
		var sin_cat := {"id": "probe_lore_secreta", "titulo": "Secreto de lore",
			"secreta": true, "registrada": false, "estado": 0, "favorito": false}
		_check(String(_capa._cat_de(sin_cat)) == "pistas",
			"C: _cat_de resuelve por el servicio si falta 'cat'")
		_check(String(_capa._texto_fila(sin_cat)) == "???",
			"C: sin 'cat' la secreta de lore sigue bloqueada")
	else:
		_check(false, "C: diary_layer.gd no se puede instanciar")
	_fin("C")

	# ── D: regla de DATOS (catálogo real + fixture que la dispara) ──────
	var parseado: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
	_check(typeof(parseado) == TYPE_DICTIONARY, "D: el catálogo real parsea como Dictionary")
	if typeof(parseado) == TYPE_DICTIONARY:
		var real: Dictionary = parseado
		var secs: Array = LORE.secretas(real)
		var viol: Array = LORE.violaciones_secreta(real)
		print("[lore] catálogo real: %d secretas, %d fuera de lore" % [secs.size(), viol.size()])
		_check(viol.is_empty(),
			"D: catálogo real sin secretas fuera de lore (%d)" % viol.size())
		_check(LORE.secretas_mal_tipadas(real).is_empty(),
			"D: catálogo real sin 'secreta' mal tipada")
		var sint: Dictionary = {"categorias": [
			{"id": "criaturas", "entradas": [{"id": "c1", "secreta": true}]},
			{"id": "pistas", "entradas": [
				{"id": "p1", "secreta": true}, {"id": "p2", "secreta": false}]},
		]}
		var v2: Array = LORE.violaciones_secreta(sint)
		_check(v2.size() == 1, "D: el fixture produce 1 violación (llegaron %d)" % v2.size())
		if v2.size() == 1:
			var v0: Dictionary = v2[0]
			_check(String(v0.get("id", "")) == "c1",
				"D: la violación es la de la colección (%s)" % String(v0.get("id", "")))
			_check(String(v0.get("categoria", "")) == "criaturas",
				"D: y trae su categoría (%s)" % String(v0.get("categoria", "")))
		_check(LORE.secretas(sint).size() == 2,
			"D: cuenta 2 secretas; la de valor false no cuenta")
		var sint_tipo: Dictionary = {"categorias": [
			{"id": "pistas", "entradas": [{"id": "p3", "secreta": "true"}]},
		]}
		var malas: Array = LORE.secretas_mal_tipadas(sint_tipo)
		_check(malas.size() == 1, "D: detecta 'secreta' mal tipada (string) — %d" % malas.size())
		_check(LORE.secretas(sint_tipo).is_empty(),
			"D: una 'secreta' mal tipada no se cuenta como secreta")
	_fin("D")

	# ── E: el loader propaga `icono` (nivel 1 del resolutor) ────────────
	_diary._cargar_catalogo()
	var cat: Dictionary = _diary._catalogo
	var total := 0
	var con_clave := 0
	for k in cat:
		for e in cat[k]:
			total += 1
			if (e as Dictionary).has("icono"):
				con_clave += 1
	_check(total > 0, "E: catálogo real cargado (%d entradas)" % total)
	_check(con_clave == total,
		"E: el loader propaga 'icono' (%d/%d entradas con la clave)" % [con_clave, total])
	_diary._catalogo = {"pistas": [{"id": "p_icono", "titulo": "T", "secreta": false,
		"descripcion": "d", "refs": [], "icono": "icono_declarado"}]}
	_diary.restore_save_data({"schema_version": 1, "entradas": {}})
	_check(_diary.registrar("p_icono", "pistas"), "E: registrar la entrada sintética")
	var l2: Array = _diary.entradas_de("pistas")
	_check(l2.size() == 1, "E: entrada registrada visible (%d)" % l2.size())
	if l2.size() == 1:
		_check(String((l2[0] as Dictionary).get("icono", "")) == "icono_declarado",
			"E: nivel 1 del resolutor alcanzable (icono declarado)")
	var det: Dictionary = _diary.detalle_entrada("p_icono")
	_check(String(det.get("icono", "")) == "icono_declarado",
		"E: detalle_entrada también expone el icono")
	_fin("E")

	_terminado = true


## Restaura el estado del servicio y cierra. En un `call_deferred` aparte: si
## `_run()` aborta por un SCRIPT ERROR, esta función CORRE igual y el fallo se
## reporta en vez de colgar el SceneTree (trampa 61/122).
func _summary() -> void:
	if _diary != null:
		if not _snap_catalogo.is_empty():
			_diary._catalogo = _snap_catalogo.duplicate(true)
		if not _snap_save.is_empty():
			_diary.restore_save_data(_snap_save.duplicate(true))
		_diary._cargar_catalogo()
	if _capa != null and is_instance_valid(_capa):
		_capa.free()
		_capa = null
	if not _terminado:
		_fallos += 1
		print("[FAIL] _run() NO terminó (posible SCRIPT ERROR que abortó la función)")
	for n in BLOQUES:
		if not _vistos.has(n):
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecutó" % String(n))
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (mínimo medido %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M55-LORE: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
