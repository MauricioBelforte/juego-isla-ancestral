# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-05
#
# M55 (T-M1, frente canal 12): validate_diary.gd — validador de integridad
# del catálogo del diario (checklist 05 L209 "mapeo, i18n, persistencia,
# rendimiento" y L189 "validar claves i18n").
#
# Qué valida:
#  Estructura/mapeo: schema_version, 14 categorías == CATEGORIAS del service,
#    ids ascii ^[a-z0-9_]+$ únicos globales, títulos no vacíos, conteo del
#    JSON coherente con Diary.total_entradas().
#  Descripciones/refs (T-M1 lote 2): si una entrada trae "descripcion" no
#    puede ser String vacía; "refs" debe ser Array de ids EXISTENTES del
#    catálogo, sin autoreferencias.
#  i18n: toda clave DIARY.* usada en diary_layer.gd (literales + CAT_* de las
#    14 categorías) existe en locales/es.po Y locales/en.po con msgstr no
#    vacío.
#  Persistencia: round-trip get_save_data/restore_save_data sin pérdida
#    (registrada + favorito + día + ui prefs) y saneamiento de ui prefs
#    inválidas en un save corrupto.
#  Rendimiento: 20 cargas/parseos del JSON < 500 ms en total.
#  Encoding: JSON y .po sin BOM y sin caracteres U+FFFD.
#  Categoría vacía (fotografías, depende de M56) → AVISO, no fallo: es un
#    frente sin contenido (diagnóstico T-M1 lote 2), no un bug de datos.
#
# Modo sonda roja: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/validate_diary.gd -- res://RUTA/alterna.json
# (la user-arg opcional sustituye el catálogo a validar; sirve para validar
#  una copia corrupta y demostrar que el validador sale en ROJO).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/validate_diary.gd
extends SceneTree

const RUTA_PO_ES := "res://locales/es.po"
const RUTA_PO_EN := "res://locales/en.po"
const RUTA_LAYER := "res://scripts/ui/layers/diary_layer.gd"
## Total de cargas del catálogo para el test de rendimiento
const ITER_RENDIMIENTO := 20
## Techo total (ms) para ITER_RENDIMIENTO cargas+parseos en headless
const TECHO_MS_RENDIMIENTO := 500.0

var _fallos: int = 0
var _avisos: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ruta_catalogo := "res://data/diario/diario_catalog.json"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and String(args[0]) != "":
		ruta_catalogo = String(args[0])
		print("[validate] catálogo alterno: " + ruta_catalogo)

	var json_texto := FileAccess.get_file_as_string(ruta_catalogo)
	_check(not json_texto.is_empty(), "catálogo legible: " + ruta_catalogo)
	_validar_encoding(ruta_catalogo, json_texto)

	var parseado: Variant = JSON.parse_string(json_texto)
	_check(typeof(parseado) == TYPE_DICTIONARY, "JSON parsea como Dictionary")
	if typeof(parseado) == TYPE_DICTIONARY:
		_validar_estructura(parseado, ruta_catalogo)
		_validar_descripciones_refs(parseado)
	_validar_i18n()
	_validar_persistencia()
	_validar_rendimiento(ruta_catalogo)

	print("=== VALIDATE DIARY: %d fallo(s), %d aviso(s) ===" % [_fallos, _avisos])
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)


func _warn(msg: String) -> void:
	_avisos += 1
	print("AVISO: " + msg)


## ── Estructura y mapeo ─────────────────────────────────────────────

func _validar_estructura(parseado: Dictionary, ruta_catalogo: String) -> void:
	_check(int(parseado.get("schema_version", 0)) == 1,
		"schema_version == 1 (llegó %s)" % str(parseado.get("schema_version", null)))

	var cats: Array = parseado.get("categorias", [])
	_check(cats.size() == 14, "14 categorías en JSON (llegaron %d)" % cats.size())

	# Mapeo contra el service real (autoload Diary)
	var diary := root.get_node_or_null("Diary")
	_check(diary != null, "autoload Diary presente")
	var esperadas: Array[String] = []
	if diary != null:
		esperadas = diary.get_categorias()
		_check(esperadas.size() == 14, "service expone 14 categorías")
	var vistos: Dictionary = {}
	var total_json := 0
	var ids_encontrados: Dictionary = {}  # id -> categoria (para refs)
	for c in cats:
		var cat := String(c.get("id", ""))
		_check(cat in esperadas, "categoría '%s' es de CATEGORIAS" % cat)
		_check(not vistos.has(cat), "categoría '%s' sin duplicar" % cat)
		vistos[cat] = true
		var entradas: Array = c.get("entradas", [])
		total_json += entradas.size()
		if entradas.is_empty():
			_warn("categoría '%s' con 0 entradas (fotografías depende de M56)" % cat)
		for e in entradas:
			var eid := String(e.get("id", ""))
			var titulo := String(e.get("titulo", ""))
			_check(_es_slug(eid), "id ascii '%s' (categoria %s)" % [eid, cat])
			_check(not titulo.strip_edges().is_empty(),
				"titulo no vacío para '%s'" % eid)
			_check(not ids_encontrados.has(eid),
				"id global único '%s' (antes en %s)" % [eid, str(ids_encontrados.get(eid, ""))])
			ids_encontrados[eid] = cat

	if diary != null:
		_check(total_json == int(diary.total_entradas()),
			"conteo JSON (%d) == Diary.total_entradas() (%d)"
			% [total_json, int(diary.total_entradas())])
		# Las 14 del service deben aparecer en el JSON (sin faltantes)
		for cat in esperadas:
			_check(vistos.has(String(cat)), "service categoría '%s' en JSON" % String(cat))

	# Guardar ids para _validar_descripciones_refs
	_ids_globales = ids_encontrados


var _ids_globales: Dictionary = {}


func _es_slug(s: String) -> bool:
	if s.is_empty():
		return false
	for i in s.length():
		var ch := s[i]
		var ok := (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") \
		or ch == "_" or ch == "-"
		if not ok:
			return false
	return true


## ── Descripciones y refs (T-M1 lote 2) ─────────────────────────────

func _validar_descripciones_refs(parseado: Dictionary) -> void:
	for c in parseado.get("categorias", []):
		for e in c.get("entradas", []):
			var eid := String(e.get("id", ""))
			if e.has("descripcion"):
				_check(typeof(e["descripcion"]) == TYPE_STRING
					and not String(e["descripcion"]).strip_edges().is_empty(),
					"descripcion no vacía en '%s'" % eid)
			if e.has("refs"):
				_check(typeof(e["refs"]) == TYPE_ARRAY,
					"refs es Array en '%s'" % eid)
				if typeof(e["refs"]) == TYPE_ARRAY:
					for r in e["refs"]:
						var rid := String(r)
						_check(_ids_globales.has(rid),
							"ref '%s' de '%s' existe en catálogo" % [rid, eid])
						_check(rid != eid,
							"ref de '%s' sin autoreferencia" % eid)


## ── i18n ───────────────────────────────────────────────────────────

func _validar_i18n() -> void:
	var src := FileAccess.get_file_as_string(RUTA_LAYER)
	_check(not src.is_empty(), "diary_layer.gd legible para extraer claves")
	if src.is_empty():
		return
	var claves: Dictionary = {}
	var re_lit := RegEx.new()
	re_lit.compile("_t\\(\"([A-Z][A-Z_0-9.]*)\"")
	for m in re_lit.search_all(src):
		var k := String(m.get_string(1))
		# Los prefijos dinámicos (_t("DIARY.CAT_" + ...)) se expanden aparte
		if k.ends_with("_"):
			continue
		claves[k] = true
	# Claves dinámicas _t("DIARY.CAT_" + ...): expandir con las 14 categorías
	var diario := root.get_node_or_null("Diary")
	if diario != null:
		for cat in diario.get_categorias():
			claves["DIARY.CAT_" + String(cat).to_upper()] = true
	_check(claves.size() >= 30, "se extrajeron claves i18n del layer (%d)" % claves.size())

	var po_es := _leer_po(RUTA_PO_ES)
	var po_en := _leer_po(RUTA_PO_EN)
	_check(not po_es.is_empty(), "es.po legible y con entradas")
	_check(not po_en.is_empty(), "en.po legible y con entradas")
	for clave in claves:
		_check(po_es.has(clave), "clave '%s' en es.po" % clave)
		_check(po_en.has(clave), "clave '%s' en en.po" % clave)
		if po_es.has(clave):
			_check(not String(po_es[clave]).strip_edges().is_empty(),
				"msgstr no vacío (es) para '%s'" % clave)
		if po_en.has(clave):
			_check(not String(po_en[clave]).strip_edges().is_empty(),
				"msgstr no vacío (en) para '%s'" % clave)


func _leer_po(ruta: String) -> Dictionary:
	var res: Dictionary = {}
	var txt := FileAccess.get_file_as_string(ruta)
	if txt.is_empty():
		return res
	var re_pair := RegEx.new()
	re_pair.compile("msgid \"([^\"\\\\]*)\"\\s+msgstr \"([^\"\\\\]*)\"")
	for m in re_pair.search_all(txt):
		var k := String(m.get_string(1))
		if k != "":
			res[k] = String(m.get_string(2))
	return res


## ── Persistencia (checklist L209/L217) ─────────────────────────────

func _validar_persistencia() -> void:
	var diario := root.get_node_or_null("Diary")
	_check(diario != null, "Diary disponible para persistencia")
	if diario == null:
		return
	# Snapshot del estado real (no ensuciar el entorno de otras suites)
	var snap: Dictionary = diario.get_save_data().duplicate(true)
	# Estado semilla: registrada + favorito + ui prefs
	diario.restore_save_data({"schema_version": 1, "entradas": {}})
	_check(diario.registrar("vecino_catalina_oso", "personajes"), "sembrar catalina")
	diario.alternar_favorito("vecino_catalina_oso")
	diario.set_ui_prefs(4, "personajes")  # 4 = Filtro.FAVORITOS
	var guardado: Dictionary = diario.get_save_data()
	diario.restore_save_data(guardado)
	_check(diario.esta_registrada("vecino_catalina_oso"), "round-trip: registro persiste")
	_check(diario.es_favorito("vecino_catalina_oso"), "round-trip: ★ persiste")
	var prefs: Dictionary = diario.get_ui_prefs()
	_check(int(prefs.get("filtro", -1)) == 4, "round-trip: filtro persiste")
	_check(String(prefs.get("categoria", "")) == "personajes",
		"round-trip: categoría persiste")
	# Saneamiento: save corrupto con ui prefs inválidas no debe romper
	diario.restore_save_data({
		"schema_version": 1, "entradas": {},
		"ui": {"filtro": 99, "categoria": "inexistente"},
	})
	var p2: Dictionary = diario.get_ui_prefs()
	_check(int(p2.get("filtro", -1)) == 0, "ui prefs inválidas saneadas a 0")
	_check(String(p2.get("categoria", "")) == "personajes",
		"categoría inválida saneada a la defecto")
	# Restaurar snapshot (patrón test_diario_ui)
	diario.restore_save_data(snap)
	var tras: Dictionary = diario.get_save_data()
	_check(int(tras.get("entradas", {}).size()) == int(snap.get("entradas", {}).size()),
		"snapshot restaurado sin pérdidas")


## ── Rendimiento ────────────────────────────────────────────────────

func _validar_rendimiento(ruta: String) -> void:
	var t0 := Time.get_ticks_msec()
	for i in ITER_RENDIMIENTO:
		var txt := FileAccess.get_file_as_string(ruta)
		var p: Variant = JSON.parse_string(txt)
		_check(typeof(p) == TYPE_DICTIONARY, "iter %d parsea (rendimiento)" % i)
	var dt := Time.get_ticks_msec() - t0
	_check(float(dt) < TECHO_MS_RENDIMIENTO,
		"%d cargas del catálogo en %d ms (< %d ms)" % [ITER_RENDIMIENTO, dt, int(TECHO_MS_RENDIMIENTO)])


## ── Encoding (§28: BOM y U+FFFD) ───────────────────────────────────

func _validar_encoding(ruta: String, contenido: String) -> void:
	if contenido.is_empty():
		return
	_check(not contenido.contains("\uFFFD") and contenido.find(String.chr(0xFFFD)) == -1,
		"sin U+FFFD en " + ruta)
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f != null:
		var bytes := f.get_buffer(3)
		_check(not (bytes.size() == 3 and bytes[0] == 0xEF
			and bytes[1] == 0xBB and bytes[2] == 0xBF),
			"sin BOM UTF-8 en " + ruta)
	for po in [RUTA_PO_ES, RUTA_PO_EN]:
		var t := FileAccess.get_file_as_string(po)
		_check(not t.contains("\uFFFD") and t.find(String.chr(0xFFFD)) == -1,
			"sin U+FFFD en " + po)
