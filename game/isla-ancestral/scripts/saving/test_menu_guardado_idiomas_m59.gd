# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-30
#
# M59 (iter. tanda 3, orden msg 459): suite del checklist L184 --
# "Testear menu de guardado en 3 idiomas".
#
# Por que existe: el item estaba en `[ ]` sin NINGUNA medicion. Las suites de M59
# (test_slots_m59, test_rotate_m59, qa_m59_*) prueban el mecanismo de guardado,
# pero ninguna abre el MENU (PauseLayer) y verifica que sus etiquetas salgan
# traducidas en es/en/pt. Se asumia que las claves SETTINGS.* estaban bien.
#
# Que mide, con datos REALES (no estimados):
#  A. PRE / anti-ceguera: los 3 catalogos cargan, las 10 claves del menu existen
#     y no estan vacias en los 3 idiomas, la capa se instancia VISIBLE y el panel
#     se mide ABIERTO (si midiera 1 px la medicion no valdria).
#  B. Etiquetas por idioma: se instancia la capa FRESCA por locale (la ruta real:
#     el menu se construye en _ready con el idioma activo) y se compara CADA texto
#     del arbol contra `traducir_clave(clave)` del catalogo. Incluye el titulo,
#     los 5 botones y los 4 textos del popup de confirmacion. Se verifica ademas
#     que ningun texto caiga al literal de la clave (fallback) y que los 5
#     botones sean DISTINTOS entre si (una clave mal cableada repetiria texto).
#  C. Expansion i18n es->en POR CLAVE (AnalizadorLayout, umbral documentado 1.30).
#     pt se REPORTA: no tiene umbral documentado y no se inventa uno.
#  D. Controles NEGATIVOS (el medidor no puede ser ciego): clave inexistente
#     devuelve el literal; a 96 px el panel DESBORDA el viewport; en != es para
#     "Guardar" (prueba que el locale activo se aplica de verdad).
#  E. Re-traduccion EN CALIENTE: capa montada en es -> set_locale("en") ->
#     UiI18n.retraducir(capa). Es el camino que usa UIManager._on_locale_changed_ui.
#     Si la capa no declara `text_key`, el menu se queda en el idioma viejo.
#  F. Determinismo: dos instancias en el mismo locale dan las mismas etiquetas.
#
# TRAMPA EVITADA (memoria del proyecto): un Label con AUTOWRAP dentro de un
# contenedor OCULTO colapsa a ~1 px. La capa se abre (`visible = true`) y se
# esperan frames REALES antes de medir.
#
# Guardian de 3 capas (patron M55/M105/M122): marcadores `_fin()` por bloque,
# `_summary()` en un `call_deferred` SEPARADO (corre aunque `_run()` aborte) y
# piso de checks MEDIDO en verde (no estimado).
#
# El locale se SNAPSHOTEA y se RESTAURA al final (no se persiste el cambio).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#   --script res://scripts/saving/test_menu_guardado_idiomas_m59.gd
extends SceneTree

## Piso de checks MEDIDO en verde (se re-mide cada vez que la suite crece).
const CHECKS_MINIMOS: int = 88

const RUTA_LAYER := "res://scripts/ui/layers/pause_layer.gd"
const ANALIZADOR := preload("res://scripts/localization/analizador_layout.gd")
const UI_I18N := preload("res://scripts/ui/i18n/ui_i18n.gd")
const LOCALES := ["es", "en", "pt"]
const BLOQUES := ["A", "B", "C", "D", "E", "F", "G"]
const EPS := 1.5

## Claves del menu de guardado: titulo + 5 botones (orden de creacion en
## PauseLayer._crear_ui) + 4 textos del popup de confirmacion.
const CLAVE_TITULO := "SETTINGS.PAUSA"
const CLAVES_BOTONES := ["SETTINGS.CONTINUAR", "SETTINGS.AJUSTES", "SETTINGS.GUARDAR",
	"SETTINGS.BORRAR_SLOT", "SETTINGS.VOLVER_TITULO"]
const CLAVES_POPUP := ["SETTINGS.GUARDAR_TITULO", "SETTINGS.GUARDAR_CONFIRMA",
	"SETTINGS.BORRAR_TITULO", "SETTINGS.BORRAR_CONFIRMA"]

var _vistos: Dictionary = {}
var _fallos: int = 0
var _checks: int = 0
var _terminado := false
var _cerrado := false
var _capa: Control = null
var _locale_previo: String = "es"


func _init() -> void:
	call_deferred("_arrancar")


## `_run()` es CORRUTINA (usa `await`). Si `_summary()` se difiere desde `_init()`
## corre en el PRIMER `await` de `_run()` --antes de que la suite termine-- y la
## declara fallida. Secuencia correcta: arrancar -> await _run -> summary.
## El watchdog cubre el caso en que `_run()` muera por SCRIPT ERROR sin reanudar.
func _arrancar() -> void:
	call_deferred("_watchdog")
	await _run()
	_summary()


func _watchdog() -> void:
	await create_timer(90.0).timeout
	if not _terminado and not _cerrado:
		_fallos += 1
		print("[FAIL] watchdog 90 s: _run() no termino (colgado o abortado)")
		_summary()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[bloque %s] checks acumulados: %d" % [nombre, _checks])


func _loc() -> Node:
	return root.get_node_or_null("Localization")


func _traducir(clave: String) -> String:
	var loc := _loc()
	if loc != null and loc.has_method("traducir_clave"):
		var res = loc.traducir_clave(clave)
		if res != clave:
			return str(res)
	return clave


## Instancia la capa FRESCA (la ruta real: el menu se construye en _ready con el
## idioma activo) y la deja ABIERTA. Libera la anterior.
func _montar() -> bool:
	if _capa != null and is_instance_valid(_capa):
		_capa.free()
		_capa = null
	var script = load(RUTA_LAYER)
	if script == null or not script.can_instantiate():
		return false
	_capa = script.new()
	if _capa == null:
		return false
	root.add_child(_capa)
	_capa.visible = true          # TRAMPA: medir una capa OCULTA colapsa el layout
	return true


## TRAMPA MEDIDA (30-oct, 4.7.2): los nodos creados en codigo SIN `name` reciben
## un nombre autogenerado `@Clase@id` (p. ej. `@CenterContainer@87`), asi que
## `find_child("VBoxContainer")` y `get_node_or_null("CenterContainer/PanelContainer")`
## devuelven NULL aunque el nodo exista. Hay que buscar POR TIPO.
func _buscar_tipo(raiz: Node, tipo: String) -> Node:
	if raiz == null:
		return null
	for h in raiz.get_children():
		if h.get_class() == tipo:
			return h
		var r := _buscar_tipo(h, tipo)
		if r != null:
			return r
	return null


func _panel() -> Control:
	return _buscar_tipo(_capa, "PanelContainer") as Control


## Cuenta nodos de animacion en el subarbol (Reduce Motion, item L215).
## Se cuentan por CLASE, no por `name`: los nodos creados en codigo sin `name`
## reciben `@Clase@id` en 4.7.2 y un `find_child` por nombre daria 0 siempre.
func _contar_animacion(raiz: Node) -> Dictionary:
	var total := 0
	if raiz == null:
		return {"nodos": 0}
	var pila: Array = [raiz]
	while not pila.is_empty():
		var n: Node = pila.pop_back()
		var c := n.get_class()
		if c == "AnimationPlayer" or c == "AnimationTree":
			total += 1
		for h in n.get_children():
			pila.append(h)
	return {"nodos": total}


## Cuenta `create_tween` en el FUENTE de un script. Segunda vista: un nodo de
## animacion puede no existir todavia y el tween crearse bajo demanda.
func _tween_en_fuente(ruta: String) -> int:
	if not FileAccess.file_exists(ruta):
		return -1
	var txt := FileAccess.get_file_as_string(ruta)
	return txt.count("create_tween")


func _vbox() -> Node:
	return _buscar_tipo(_capa, "VBoxContainer")


## El titulo es el primer Label del VBoxContainer del panel (PauseLayer._crear_ui).
func _titulo() -> Label:
	var vbox := _vbox()
	if vbox == null:
		return null
	for h in vbox.get_children():
		if h is Label:
			return h as Label
	return null


func _botones() -> Array:
	var salida: Array = []
	var vbox := _vbox()
	if vbox == null:
		return salida
	for h in vbox.get_children():
		if h is Button:
			salida.append(h)
	return salida


## Aplica el tamano tipografico a TODO el subarbol. TRAMPA: overridear solo el
## panel/VBox no cambia nada -- la fuente la consumen Label/Button, que estan mas
## abajo. Con la sonda aplicada solo al panel el control negativo daba 328x364
## (no desbordaba) y el medidor quedaba CIEGO.
func _aplicar_tamano(raiz: Node, tam: int) -> void:
	if raiz is Control:
		(raiz as Control).add_theme_font_size_override("font_size", tam)
	for h in raiz.get_children():
		_aplicar_tamano(h, tam)


func _run() -> void:
	root.size = Vector2i(1280, 720)
	await process_frame

	# ── A: PRE / anti-ceguera ──────────────────────────────────────────
	var loc := _loc()
	_check(loc != null, "A: autoload Localization presente")
	_check(loc != null and loc.has_method("set_locale"), "A: Localization.set_locale existe")
	_check(loc != null and loc.has_method("get_locale"), "A: Localization.get_locale existe")
	if loc != null:
		_locale_previo = String(loc.get_locale())
		for l in LOCALES:
			var ok: bool = loc.set_locale(String(l))
			_check(ok, "A: set_locale('%s') acepta el idioma" % String(l))
		loc.set_locale(_locale_previo)
		_check(String(loc.get_locale()) == _locale_previo,
			"A: el locale previo se restaura ('%s')" % _locale_previo)

	# Las 10 claves del menu existen y no estan vacias en los 3 idiomas.
	var todas: Array = [CLAVE_TITULO]
	todas.append_array(CLAVES_BOTONES)
	todas.append_array(CLAVES_POPUP)
	if loc != null and loc.has_method("catalogo"):
		for l in LOCALES:
			var cat: Dictionary = loc.catalogo(String(l))
			_check(cat.size() > 0, "A: catalogo '%s' cargado (%d claves)" % [String(l), cat.size()])
			var faltan: Array = []
			var vacias: Array = []
			for k in todas:
				if not cat.has(k):
					faltan.append(k)
				elif String(cat[k]).strip_edges() == "":
					vacias.append(k)
			_check(faltan.size() == 0,
				"A: '%s' tiene las 10 claves del menu (faltan: %s)" % [String(l), str(faltan)])
			_check(vacias.size() == 0,
				"A: '%s' no tiene claves vacias (vacias: %s)" % [String(l), str(vacias)])
	else:
		_check(false, "A: Localization.catalogo() no disponible -- no se pueden verificar claves")

	var script_layer = load(RUTA_LAYER)
	_check(script_layer != null, "A: el script de la capa carga")
	_check(script_layer != null and script_layer.can_instantiate(), "A: la capa es instanciable")
	if script_layer == null or not script_layer.can_instantiate():
		print("[FAIL] A: la capa no es instanciable -- la suite no puede medir nada")
		return
	if loc != null:
		loc.set_locale("es")
	_check(_montar(), "A: la capa se instancia")
	await process_frame
	await process_frame
	var p0 := _panel()
	_check(p0 != null, "A: el panel del menu existe en el arbol")
	_check(p0 != null and p0.size.x > 1.0,
		"A: la capa se midio ABIERTA (panel ancho %.0f px, no colapsado)"
		% (0.0 if p0 == null else p0.size.x))
	_check(_botones().size() == CLAVES_BOTONES.size(),
		"A: el menu tiene %d botones (medido %d)" % [CLAVES_BOTONES.size(), _botones().size()])
	_check(_titulo() != null, "A: el titulo del menu existe")
	_fin("A")

	# ── B: etiquetas por idioma (instancia FRESCA por locale) ──────────
	for l in LOCALES:
		var lc := String(l)
		if loc != null:
			loc.set_locale(lc)
		_check(_montar(), "B[%s]: la capa se instancia" % lc)
		await process_frame
		await process_frame
		var tit := _titulo()
		var esp_tit := _traducir(CLAVE_TITULO)
		_check(tit != null and String(tit.text) == esp_tit,
			"B[%s]: el titulo dice '%s' (esperado '%s')"
			% [lc, "" if tit == null else String(tit.text), esp_tit])
		var bts := _botones()
		_check(bts.size() == CLAVES_BOTONES.size(),
			"B[%s]: %d botones en el menu (medido %d)" % [lc, CLAVES_BOTONES.size(), bts.size()])
		var vistos_txt: Dictionary = {}
		var repetidos: Array = []
		for i in range(min(bts.size(), CLAVES_BOTONES.size())):
			var clave := String(CLAVES_BOTONES[i])
			var esperado := _traducir(clave)
			var real := String((bts[i] as Button).text)
			_check(real == esperado,
				"B[%s]: boton %d ('%s') dice '%s' (esperado '%s')" % [lc, i, clave, real, esperado])
			# No cae al literal de la clave NI queda vacio (una traduccion vacia
			# en el .po produce un boton mudo: medido por inyeccion, 30-oct).
			_check(real != clave and real.strip_edges() != "",
				"B[%s]: boton %d tiene texto traducido no vacio ('%s')" % [lc, i, real])
			if vistos_txt.has(real):
				repetidos.append(real)
			vistos_txt[real] = true
		_check(repetidos.size() == 0,
			"B[%s]: los %d botones tienen texto DISTINTO (repetidos: %s)"
			% [lc, CLAVES_BOTONES.size(), str(repetidos)])
		# Textos del popup de confirmacion (los usa _pedir_confirmacion_*).
		var mal_popup: Array = []
		for k in CLAVES_POPUP:
			var t := _traducir(String(k))
			if t == String(k) or t.strip_edges() == "":
				mal_popup.append(String(k))
		_check(mal_popup.size() == 0,
			"B[%s]: los 4 textos del popup resuelven (sin resolver: %s)" % [lc, str(mal_popup)])
		_fin("B_" + lc)
	_fin("B")

	# ── C: expansion i18n es->en POR CLAVE ────────────────────────────
	var fuente: Font = ThemeDB.fallback_font
	_check(fuente != null, "C: fuente de referencia disponible")
	var cat_es: Dictionary = {}
	var cat_en: Dictionary = {}
	var cat_pt: Dictionary = {}
	if loc != null and loc.has_method("catalogo"):
		cat_es = loc.catalogo("es")
		cat_en = loc.catalogo("en")
		cat_pt = loc.catalogo("pt")
	var ratio_en := 0.0
	var ratio_pt := 0.0
	var peor_en := ""
	var peor_pt := ""
	var sobre_umbral := 0
	var medibles := 0
	for k in todas:
		var t_es := String(cat_es.get(k, ""))
		var t_en := String(cat_en.get(k, ""))
		var t_pt := String(cat_pt.get(k, ""))
		if t_es == "":
			continue
		medibles += 1
		var w_es: float = ANALIZADOR.medir_linea(fuente, t_es, 16).x
		var w_en: float = ANALIZADOR.medir_linea(fuente, t_en, 16).x
		var w_pt: float = ANALIZADOR.medir_linea(fuente, t_pt, 16).x
		if w_es <= 1.0:
			continue
		var r_en: float = w_en / w_es
		var r_pt: float = w_pt / w_es
		if r_en > ratio_en:
			ratio_en = r_en
			peor_en = String(k)
		if r_pt > ratio_pt:
			ratio_pt = r_pt
			peor_pt = String(k)
		if r_en > ANALIZADOR.UMBRAL_EXPANSION:
			sobre_umbral += 1
	_check(medibles == todas.size(),
		"C: las %d claves del menu son medibles en los 3 idiomas (medidas %d)"
		% [todas.size(), medibles])
	_check(ratio_en > 0.0, "C: la razon en/es se MIDIO (> 0)")
	_check(ratio_en <= ANALIZADOR.UMBRAL_EXPANSION,
		"C: peor clave en/es %.3f dentro del umbral %.2f (%s)"
		% [ratio_en, ANALIZADOR.UMBRAL_EXPANSION, peor_en])
	print("      expansion POR CLAVE: en/es max %.3fx (%s), pt/es max %.3fx (%s)"
		% [ratio_en, peor_en, ratio_pt, peor_pt])
	print("      claves por encima del umbral %.2f: %d de %d"
		% [ANALIZADOR.UMBRAL_EXPANSION, sobre_umbral, todas.size()])
	print("      [informativo] pt/es %.3fx sin umbral documentado (peor: %s)" % [ratio_pt, peor_pt])
	_fin("C")

	# ── D: controles negativos (el medidor NO puede ser ciego) ─────────
	var inexistente := _traducir("SETTINGS.CLAVE_QUE_NO_EXISTE_XYZ")
	_check(inexistente == "SETTINGS.CLAVE_QUE_NO_EXISTE_XYZ",
		"D: una clave inexistente devuelve el literal (fallback probado): '%s'" % inexistente)
	if loc != null:
		loc.set_locale("en")
	var g_en := _traducir("SETTINGS.GUARDAR")
	if loc != null:
		loc.set_locale("es")
	var g_es := _traducir("SETTINGS.GUARDAR")
	_check(g_en != g_es, "D: 'Guardar' cambia con el locale (es='%s' en='%s')" % [g_es, g_en])
	# A 96 px el panel TIENE que desbordar el viewport de 1280x720.
	_check(_montar(), "D: la capa se instancia para la sonda de 96 px")
	await process_frame
	await process_frame
	var p96 := _panel()
	_aplicar_tamano(_capa, 96)
	await process_frame
	await process_frame
	await process_frame
	var vp: Vector2 = Vector2(root.size)
	_check(p96 != null and (p96.size.x > vp.x + EPS or p96.size.y > vp.y + EPS),
		"D: a 96 px el panel DESBORDA (%.0f x %.0f vs %.0f x %.0f) -- el medidor no es ciego"
		% [0.0 if p96 == null else p96.size.x, 0.0 if p96 == null else p96.size.y, vp.x, vp.y])
	_fin("D")

	# ── E: re-traduccion EN CALIENTE (camino de UIManager) ────────────
	if loc != null:
		loc.set_locale("es")
	_check(_montar(), "E: la capa se instancia en es")
	await process_frame
	await process_frame
	var bts_es := _botones()
	var txt_es := "" if bts_es.is_empty() else String((bts_es[2] as Button).text)
	if loc != null:
		loc.set_locale("en")
	var rep: Dictionary = UI_I18N.retraducir(_capa)
	await process_frame
	var bts_en := _botones()
	var txt_en := "" if bts_en.is_empty() else String((bts_en[2] as Button).text)
	var esperado_en := _traducir("SETTINGS.GUARDAR")
	print("      E: retraducir() -> traducidos=%d claves=%s"
		% [int(rep.get("traducidos", 0)), str(rep.get("claves", []))])
	_check(txt_en == esperado_en,
		"E: tras set_locale('en') el boton Guardar dice '%s' (esperado '%s'; antes '%s')"
		% [txt_en, esperado_en, txt_es])
	_check(int(rep.get("traducidos", 0)) >= 1,
		"E: la capa declara claves re-traducibles (traducidos=%d)" % int(rep.get("traducidos", 0)))
	_fin("E")

	# ── F: determinismo ───────────────────────────────────────────────
	if loc != null:
		loc.set_locale("es")
	_check(_montar(), "F: la capa se instancia (medicion 1)")
	await process_frame
	await process_frame
	var b1 := _botones()
	var t1: Array = []
	for b in b1:
		t1.append(String((b as Button).text))
	_check(_montar(), "F: la capa se instancia (medicion 2)")
	await process_frame
	await process_frame
	var b2 := _botones()
	var t2: Array = []
	for b in b2:
		t2.append(String((b as Button).text))
	_check(t1 == t2, "F: dos instancias en es dan las mismas etiquetas (%s vs %s)" % [str(t1), str(t2)])
	_fin("F")

	# ── G: Reduce Motion (M58) sobre el menu de guardado — item L215 ───
	# La exigencia es "el menu se puede usar con Reduce Motion". Se mide en las
	# DOS vistas: en RUNTIME (no hay nodos de animacion ni transform/alpha
	# animados en el subarbol instanciado) y en el FUENTE (ninguna llamada que
	# cree un tween). Un menu sin movimiento cumple Reduce Motion por
	# construccion, y la asercion queda viva: si alguien anima la capa, esto
	# se pone rojo.
	_check(_montar(), "G: la capa se instancia para medir Reduce Motion")
	await process_frame
	await process_frame
	var anim := _contar_animacion(_capa)
	_check(int(anim["nodos"]) == 0,
		"G: 0 nodos AnimationPlayer/AnimationTree en el subarbol (medido %d)" % int(anim["nodos"]))
	var panel_g := _panel()
	_check(panel_g != null and panel_g.modulate.is_equal_approx(Color(1, 1, 1, 1)),
		"G: el panel no tiene alpha animado (modulate %s)" % (str(panel_g.modulate) if panel_g != null else "sin panel"))
	_check(panel_g != null and panel_g.scale.is_equal_approx(Vector2(1, 1)),
		"G: el panel no tiene scale animado (%s)" % (str(panel_g.scale) if panel_g != null else "sin panel"))
	var tw := _tween_en_fuente("res://scripts/ui/layers/pause_layer.gd") + _tween_en_fuente("res://scripts/ui/layers/confirm_popup.gd")
	_check(tw == 0, "G: 0 llamadas create_tween en la capa y el popup de confirmacion (medido %d)" % tw)
	var titulo_g := _titulo()
	_check(titulo_g != null and titulo_g.modulate.is_equal_approx(Color(1, 1, 1, 1)),
		"G: el titulo no arranca transparente (modulate %s)" % (str(titulo_g.modulate) if titulo_g != null else "sin titulo"))
	_fin("G")

	_terminado = true


## Restaura locale y libera la capa. En un `call_deferred` aparte: si `_run()`
## aborta por SCRIPT ERROR, esta funcion CORRE igual y el fallo se reporta en vez
## de colgar el SceneTree.
func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	var loc := _loc()
	if loc != null and _locale_previo != "":
		loc.set_locale(_locale_previo)
	if _capa != null and is_instance_valid(_capa):
		_capa.free()
		_capa = null
	if not _terminado:
		_fallos += 1
		print("[FAIL] _run() NO termino (posible SCRIPT ERROR que aborto la funcion)")
	for n in BLOQUES:
		if not _vistos.has(n):
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto" % String(n))
	for l in LOCALES:
		var nb := "B_" + String(l)
		if not _vistos.has(nb):
			_fallos += 1
			print("[FAIL] el bloque %s NO se ejecuto" % nb)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo medido %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M59-MENU-IDIOMAS: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
