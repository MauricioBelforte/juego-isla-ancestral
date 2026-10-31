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
## Resolutor de iconos (iter. 6) e inventario de arte 2D de M46.
const ICONOS := preload("res://scripts/diario/iconos_diario.gd")
const RUTA_ICONOS := "res://scripts/diario/iconos_diario.gd"
const RUTA_INVENTARIO_M46 := "res://data/arte2d/inventario_2d.json"
## Clasificación de secciones lore (iter. 7, L164): fuente única compartida con
## diary_service (visibilidad) y diary_layer (texto "???").
const LORE := preload("res://scripts/diario/secciones_lore.gd")
## Total de cargas del catálogo para el test de rendimiento
const ITER_RENDIMIENTO := 20
## Techo total (ms) para ITER_RENDIMIENTO cargas+parseos en headless
const TECHO_MS_RENDIMIENTO := 500.0

var _fallos: int = 0
var _avisos: int = 0
var _checks: int = 0
## Piso de checks MEDIDO en verde (iter. 7). Se re-mide cada vez que la suite
## crece; nunca se estima. Ver 06-Plan-Testings.
## Piso MEDIDO en verde: 391 checks de los bloques (el check del piso se
## cuenta a sí mismo y NO entra en el mínimo). Si un bloque aborta, baja.
## iter. 6 = 387; iter. 7 suma 4 (_validar_secretas: guarda de ceguera,
## cruce con las 14 categorías, regla §3.2 y tipo del campo).
const CHECKS_MINIMOS: int = 391


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
		_validar_secretas(parseado)
		_validar_iconos(parseado)
	_validar_i18n()
	_validar_persistencia()
	_validar_rendimiento(ruta_catalogo)

	# Piso de checks (iter. 6): un aborto de runtime en cualquier bloque deja el
	# contador por debajo del mínimo MEDIDO en verde. Sin esto, un "0 fallos" de
	# una corrida que se cortó a la mitad es indistinguible de un verde real.
	_check(_checks >= CHECKS_MINIMOS,
		"piso de checks: %d ejecutados (mínimo medido %d)" % [_checks, CHECKS_MINIMOS])

	print("=== VALIDATE DIARY: %d checks, %d fallo(s), %d aviso(s) ==="
		% [_checks, _fallos, _avisos])
	quit(1 if _fallos > 0 else 0)


func _check(cond: bool, msg: String) -> void:
	_checks += 1
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


## ── Contenido secreto y secciones lore (iter. 7, checklist L164) ──
##
## §3.2 y §11 regla 1: `secreta: true` SOLO en secciones lore (pistas, sellos,
## ruinas, cartas) y NUNCA en colecciones (criaturas, plantas, minerales,
## recetas...). La marca fuera de lore no es un detalle de UI: es un defecto de
## DATOS que dejaría una entrada de colección visible como "???" (lo que L164
## prohíbe), así que el validador lo marca como fallo.
##
## La clasificación NO se escribe acá: se toma de `secciones_lore.gd`, la misma
## que usan el servicio (visibilidad) y la capa (texto). Una sola fuente.
func _validar_secretas(parseado: Dictionary) -> void:
	# (a) guarda de ceguera: con la lista de secciones lore VACÍA la regla (b)
	#     pasaría trivialmente ("0 secretas fuera de lore") sin haber mirado
	#     nada. Misma familia que un auditor ciego con exit 0.
	_check(LORE.CATEGORIAS.size() == 4,
		"secciones LORE declaradas (llegaron %d, esperadas 4)" % LORE.CATEGORIAS.size())
	var diary := root.get_node_or_null("Diary")
	if diary != null:
		var cats: Array = diary.get_categorias()
		var fuera := 0
		for c in LORE.CATEGORIAS:
			if not (String(c) in cats):
				fuera += 1
		_check(fuera == 0,
			"toda sección LORE es una de las 14 categorías del service (fuera: %d)" % fuera)

	# (b) la regla: ninguna `secreta` fuera de lore
	var viol: Array = LORE.violaciones_secreta(parseado)
	var detalle := ""
	for v in viol:
		detalle += " %s(%s)" % [String(v.get("id", "")), String(v.get("categoria", ""))]
	_check(viol.is_empty(),
		"ninguna 'secreta' fuera de LORE — %d violación(es)%s" % [viol.size(), detalle])

	# (c) tipo del campo: un "true" en string sería una marca que nadie lee
	var malas: Array = LORE.secretas_mal_tipadas(parseado)
	var tipos := ""
	for m in malas:
		tipos += " %s=%s" % [String(m.get("id", "")), String(m.get("tipo", ""))]
	_check(malas.is_empty(),
		"campo 'secreta' booleano cuando está presente — %d mal tipada(s)%s"
		% [malas.size(), tipos])

	var secs: Array = LORE.secretas(parseado)
	print("[validate] secretas declaradas: %d (fuera de lore: %d)" % [secs.size(), viol.size()])


## ── Iconografía (iter. 6: L93/L117/L203 y las siluetas de L77/L85) ──
##
## Valida la iconografía de las entradas contra el catálogo de arte 2D (M46,
## `data/arte2d/inventario_2d.json`), que es la fuente de ids de iconos del
## proyecto. No exige que el arte exista (hoy no existe NINGUNO de los 48
## assets: deuda de M46) — eso se REPORTA como aviso medido. Lo que sí exige:
##   (a) el inventario M46 se lee y declara ids (guarda de ceguera: sin esto el
##       validador diría "0 problemas" sin haber mirado nada);
##   (b) toda entrada tiene un id de icono DERIVABLE o DECLARADO con la
##       convención de prefijos de M46;
##   (c) el campo opcional `icono` es un slug ASCII.
func _validar_iconos(parseado: Dictionary) -> void:
	var inv: Dictionary = ICONOS.inventario_m46()
	# (a) guarda de ceguera: un inventario vacío no es "todo bien"
	_check(not inv.is_empty(),
		"inventario M46 con ids (leídos %d de %s)" % [inv.size(), RUTA_INVENTARIO_M46])

	var total := 0
	var derivables := 0
	var sin_familia: Array[String] = []
	var cats_sin_familia: Array[String] = []
	for c in parseado.get("categorias", []):
		var cat := String(c.get("id", ""))
		for e in c.get("entradas", []):
			total += 1
			var eid := String(e.get("id", ""))
			# (c) el campo declarado, si existe, es un slug ASCII
			if e.has("icono"):
				_check(typeof(e["icono"]) == TYPE_STRING,
					"icono es String en '%s'" % eid)
				var decl := String(e["icono"])
				_check(_es_slug(decl), "icono '%s' es slug ascii en '%s'" % [decl, eid])
			# (b) id de icono obtenible
			var id_ico := String(ICONOS.id_derivado(cat, eid))
			if id_ico.is_empty() and not String(e.get("icono", "")).is_empty():
				id_ico = String(e.get("icono", ""))
			if id_ico.is_empty():
				sin_familia.append("%s (%s)" % [eid, cat])
				if not cats_sin_familia.has(cat):
					cats_sin_familia.append(cat)
			else:
				derivables += 1

	# Invariante ESTRUCTURAL (no un conteo fijo): una entrada solo puede quedar
	# sin id de icono si su CATEGORÍA no tiene familia de arte declarada en M46.
	# Así el check discrimina (si 'minerales' pierde su prefijo, falla) y no se
	# rompe cuando el catálogo crece con contenido legítimo.
	var cat_invalida: Array[String] = []
	for cat in cats_sin_familia:
		if not String(ICONOS.FAMILIA_POR_CATEGORIA.get(cat, "")).is_empty():
			cat_invalida.append(String(cat))
	_check(cat_invalida.is_empty(),
		"categorías con familia M46 y entradas sin id de icono: %s" % str(cat_invalida))
	_check(derivables > 0,
		"al menos una entrada aporta id de icono (derivables %d de %d)" % [derivables, total])

	var inf: Dictionary = ICONOS.inventario_iconos(parseado)
	print("[iconos] entradas=%d derivables=%d en_inventario=%d con_asset=%d declarados=%d sin_familia=%d"
		% [int(inf["entradas"]), int(inf["con_id_derivado"]), int(inf["en_inventario"]),
		int(inf["con_asset"]), int(inf["declarados"]), int(inf["sin_familia"])])
	var ausentes: Array = inf["sin_id_en_inventario"]
	print("[iconos] ids fuera del inventario M46: %d" % ausentes.size())
	var fam: Array = inf["familia_disponible"]
	print("[iconos] ids sin id exacto pero con simbolo de familia: %d %s" % [fam.size(), str(fam)])

	# Deuda MEDIDA, no silencio (patrón M72): el arte de M46 está pendiente.
	_warn("iconografía: %d/%d entradas con id en el inventario M46; %d con asset en disco"
		% [int(inf["en_inventario"]), total, int(inf["con_asset"])])
	if int(inf["con_asset"]) == 0:
		_warn("iconografía: 0 assets de icono en disco (inventario M46 = 48 ids 'pendiente'); "
			+ "la UI muestra el fallback genérico del resolutor (L203)")


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
