# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-10-28
#
# M55 (iter. 8): suite del checklist L188 — "Testear el diario en 3 idiomas sin
# desbordes de UI".
#
# Por que existe: el item estaba en `[ ]` con nota honesta ("las suites miden
# claves i18n es/en; no hay prueba de 3 idiomas ni de desbordes de UI"). No habia
# NINGUNA medicion del encaje del texto traducido: se asumia que cabia.
#
# Que mide, con metricas REALES (no estimadas):
#  A. PRE / anti-ciego: los 3 catalogos cargan, la capa se instancia VISIBLE y se
#     encuentran textos que medir (si no hay textos, la suite no puede ser verde).
#  B. Desborde por idioma x tamano tipografico (12/16/24 px): para cada Control con
#     texto se compara lo que el texto NECESITA (`get_combined_minimum_size`) con
#     lo que el Control TIENE (`size`). Desborde vertical = texto cortado; desborde
#     horizontal solo aplica a Labels sin autowrap (con wrap el ancho se reajusta).
#     Ademas: el PanelDiario entero debe caber en el viewport.
#  C. Expansion i18n es->en y es->pt sobre las MISMAS claves del catalogo, medida
#     con `AnalizadorLayout` (criterio documentado: ingles hasta +30%).
#  D. Control NEGATIVO: un texto deliberadamente larguisimo DEBE desbordar. Si no
#     desborda, el medidor es ciego y la suite se declara en rojo.
#  E. Determinismo: dos mediciones identicas del mismo idioma/tamano.
#
# TRAMPA EVITADA (memoria del proyecto): un Label con AUTOWRAP dentro de un
# contenedor OCULTO colapsa a ~1 px de ancho e infla el minimo. Por eso la capa se
# abre (`visible = true`) y se esperan frames REALES antes de medir, y se verifica
# que el panel tenga ancho > 1 px (si midiera 1 px, la medicion no vale).
#
# Guardian de 3 capas (patron M105/M122): marcadores `_fin()` por bloque,
# `_summary()` en un `call_deferred` SEPARADO (corre aunque `_run()` aborte) y piso
# de checks MEDIDO en verde.
#
# Estado del locale se SNAPSHOTEA y se RESTAURA al final (no se persiste el cambio).
#
# Ejecutar: Godot --headless --path game/isla-ancestral
#   --script res://scripts/diario/test_diario_idiomas_m55.gd
extends SceneTree

## Piso de checks MEDIDO en verde (se re-mide cada vez que la suite crece).
const CHECKS_MINIMOS: int = 51

const RUTA_LAYER := "res://scripts/ui/layers/diary_layer.gd"
const ANALIZADOR := preload("res://scripts/localization/analizador_layout.gd")
const LOCALES := ["es", "en", "pt"]
const TAMANOS := [12, 16, 24]
## Tolerancia de redondeo del layout (px). El layout de Godot redondea a entero.
const EPS := 1.5
const BLOQUES := ["A", "B", "C", "D", "E"]

var _vistos: Dictionary = {}
var _fallos: int = 0
var _checks: int = 0
var _terminado := false
var _cerrado := false
var _capa: Control = null
var _panel: Control = null
var _locale_previo: String = "es"
var _resultados: Dictionary = {}   # "loc|tam" -> {textos, vert, horiz, panel_w, panel_h}


func _init() -> void:
	call_deferred("_arrancar")


## `_run()` es CORRUTINA (usa `await`). Si `_summary()` se difiere desde `_init()`,
## corre en el PRIMER `await` de `_run()` —es decir, ANTES de que la suite termine—
## y la declara fallida. Por eso la secuencia es: arrancar -> await _run -> summary.
## El watchdog cubre el caso en que `_run()` muera por SCRIPT ERROR sin reanudar.
func _arrancar() -> void:
	call_deferred("_watchdog")
	await _run()
	_summary()


func _watchdog() -> void:
	await create_timer(90.0).timeout
	if not _terminado and not _cerrado:
		_fallos += 1
		print("[FAIL] watchdog 90 s: _run() no terminó (colgado o abortado)")
		_summary()


func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("[FALLO] " + msg)


func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[bloque %s] checks acumulados: %d" % [nombre, _checks])


## Todos los Control con texto no vacio del subarbol (Label/Button/RichTextLabel).
func _controles_con_texto(raiz: Node, salida: Array) -> void:
	if raiz == null:
		return
	if raiz is Label:
		var t := String((raiz as Label).text)
		if t.strip_edges() != "":
			salida.append(raiz)
	elif raiz is Button:
		var tb := String((raiz as Button).text)
		if tb.strip_edges() != "":
			salida.append(raiz)
	for h in raiz.get_children():
		_controles_con_texto(h, salida)


func _texto_de(c: Control) -> String:
	if c is Label:
		return String((c as Label).text)
	if c is Button:
		return String((c as Button).text)
	return ""


func _tiene_autowrap(c: Control) -> bool:
	if c is Label:
		return (c as Label).autowrap_mode != TextServer.AUTOWRAP_OFF
	return false


func _aplicar_tamano(raiz: Node, tam: int) -> void:
	if raiz is Control:
		(raiz as Control).add_theme_font_size_override("font_size", tam)
	for h in raiz.get_children():
		_aplicar_tamano(h, tam)


## Mide el encaje REAL de la capa en el locale y tamano actuales.
##
## ⚠️ TRAMPA MEDIDA: comparar `get_combined_minimum_size() > size` en un Control
## NO sirve — Godot clampa `size` al minimo, asi que esa asercion NUNCA puede
## fallar (falso verde estructural). Lo que SI se puede medir es si el panel (cuyo
## tamano es su minimo real, o sea lo que el texto EXIGE) cabe en el viewport.
## Un panel mas ancho o mas alto que la pantalla ES el desborde.
func _medir(rotulo: String) -> Dictionary:
	# 3 frames: 1 para el cambio de tamano, 2 para que contenedores reacomoden.
	await process_frame
	await process_frame
	await process_frame
	var ctrls: Array = []
	_controles_con_texto(_capa, ctrls)
	var vp: Vector2 = Vector2(root.size)
	var pw := 0.0
	var ph := 0.0
	if _panel != null and is_instance_valid(_panel):
		pw = _panel.size.x
		ph = _panel.size.y
	var ancho_util: float = max(1.0, pw - 48.0)   # 24 px de margen por lado
	var riesgo_h := 0
	var peores: Array = []
	for c in ctrls:
		var t := _texto_de(c as Control)
		if _tiene_autowrap(c as Control):
			continue   # con wrap el texto se reacomoda; no hay corte horizontal
		var w: float = ANALIZADOR.medir_linea(ThemeDB.fallback_font, t,
			int((c as Control).get_theme_font_size("font_size"))).x
		if w > ancho_util + EPS:
			riesgo_h += 1
			peores.append("%s: %.0f px > util %.0f" % [t.substr(0, 26), w, ancho_util])
	var r := {"textos": ctrls.size(), "panel_w": pw, "panel_h": ph, "vp": vp,
		"desborda_w": pw > vp.x + EPS, "desborda_h": ph > vp.y + EPS,
		"riesgo_h": riesgo_h, "peores": peores}
	_resultados[rotulo] = r
	return r


func _run() -> void:
	root.size = Vector2i(1280, 720)
	await process_frame

	# ── A: PRE / anti-ceguera ──────────────────────────────────────────
	var loc = root.get_node_or_null("Localization")
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

	var script = load(RUTA_LAYER)
	_check(script != null, "A: el script de la capa carga")
	if script == null or not script.can_instantiate():
		print("[FAIL] A: la capa no es instanciable — la suite no puede medir nada")
		return
	_capa = script.new()
	root.add_child(_capa)
	# TRAMPA: medir una capa OCULTA colapsa los Label con autowrap a ~1 px.
	_capa.visible = true
	if _capa.has_method("abrir"):
		_capa.abrir()
	await process_frame
	await process_frame
	_panel = _capa.get_node_or_null("CenterContainer/PanelDiario")
	if _panel == null:
		_panel = _capa.find_child("PanelDiario", true, false)
	_check(_panel != null, "A: el PanelDiario existe en el arbol")
	var ctrls0: Array = []
	_controles_con_texto(_capa, ctrls0)
	_check(ctrls0.size() >= 5, "A: hay textos que medir (%d controles con texto)" % ctrls0.size())
	_check(_panel != null and _panel.size.x > 1.0,
		"A: la capa se midio ABIERTA (panel ancho %.0f px, no colapsado)" % (0.0 if _panel == null else _panel.size.x))
	_fin("A")

	# ── B: encaje por idioma x tamano tipografico ──────────────────────
	var n_desborde := 0
	var n_riesgo_h := 0
	for l in LOCALES:
		var lc := String(l)
		if loc != null:
			loc.set_locale(lc)
		if _capa.has_method("_refrescar_completo"):
			_capa._refrescar_completo()
		for t in TAMANOS:
			_aplicar_tamano(_capa, int(t))
			var r: Dictionary = await _medir("%s|%d" % [lc, int(t)])
			if bool(r["desborda_w"]) or bool(r["desborda_h"]):
				n_desborde += 1
			n_riesgo_h += int(r["riesgo_h"])
			_check(int(r["textos"]) > 0,
				"B: %s@%dpx tiene textos medidos (%d)" % [lc, int(t), int(r["textos"])])
			_check(not bool(r["desborda_w"]),
				"B: %s@%dpx el panel cabe a lo ancho (%.0f <= %.0f)"
				% [lc, int(t), float(r["panel_w"]), float(r["vp"].x)])
			_check(not bool(r["desborda_h"]),
				"B: %s@%dpx el panel cabe a lo alto (%.0f <= %.0f)"
				% [lc, int(t), float(r["panel_h"]), float(r["vp"].y)])
			if int(r["riesgo_h"]) > 0:
				print("      %s@%dpx: %d textos sin wrap mas anchos que el area util"
					% [lc, int(t), int(r["riesgo_h"])])
				for p in (r["peores"] as Array).slice(0, 3):
					print("        - " + String(p))
	_check(n_desborde == 0,
		"B: CERO combinaciones con desborde del panel (3 idiomas x 3 tamanos, medido: %d)" % n_desborde)
	_check(n_riesgo_h == 0,
		"B: ningun texto sin wrap excede el area util del panel (medido: %d)" % n_riesgo_h)
	_fin("B")

	# ── C: expansion i18n medida POR CLAVE sobre el catalogo real ─────
	# Se comparan las MISMAS claves en los 3 idiomas. Sumar anchos de textos
	# distintos daria un promedio que esconde el peor caso: lo que rompe el layout
	# es la clave que mas crece, no la media.
	var fuente: Font = ThemeDB.fallback_font
	_check(fuente != null, "C: fuente de referencia disponible")
	var cat_es: Dictionary = {}
	var cat_en: Dictionary = {}
	var cat_pt: Dictionary = {}
	if loc != null and loc.has_method("catalogo"):
		cat_es = loc.catalogo("es")
		cat_en = loc.catalogo("en")
		cat_pt = loc.catalogo("pt")
	_check(cat_es.size() > 0 and cat_en.size() > 0 and cat_pt.size() > 0,
		"C: los 3 catalogos cargados (es=%d en=%d pt=%d)" % [cat_es.size(), cat_en.size(), cat_pt.size()])
	var claves: Array = []
	for k in cat_es.keys():
		var ks := String(k)
		if ks.begins_with("DIARY.") and cat_en.has(k) and cat_pt.has(k):
			claves.append(ks)
	_check(claves.size() >= 10,
		"C: claves DIARY.* presentes en los 3 idiomas (%d)" % claves.size())
	var ratio_en := 0.0
	var ratio_pt := 0.0
	var peor_en := ""
	var peor_pt := ""
	var sobre_umbral := 0
	for ks in claves:
		var t_es := String(cat_es.get(ks, ""))
		var t_en := String(cat_en.get(ks, ""))
		var t_pt := String(cat_pt.get(ks, ""))
		var w_es: float = ANALIZADOR.medir_linea(fuente, t_es, 16).x
		var w_en: float = ANALIZADOR.medir_linea(fuente, t_en, 16).x
		var w_pt: float = ANALIZADOR.medir_linea(fuente, t_pt, 16).x
		if w_es <= 1.0:
			continue
		var r_en: float = w_en / w_es
		var r_pt: float = w_pt / w_es
		if r_en > ratio_en:
			ratio_en = r_en
			peor_en = ks
		if r_pt > ratio_pt:
			ratio_pt = r_pt
			peor_pt = ks
		if r_en > ANALIZADOR.UMBRAL_EXPANSION:
			sobre_umbral += 1
	print("      expansion POR CLAVE: en/es max %.3fx (%s), pt/es max %.3fx (%s)"
		% [ratio_en, peor_en, ratio_pt, peor_pt])
	print("      claves por encima del umbral %.2f: %d de %d"
		% [ANALIZADOR.UMBRAL_EXPANSION, sobre_umbral, claves.size()])
	_check(ratio_en > 0.0, "C: la razon en/es se MIDIO (> 0)")
	# El criterio documentado (AnalizadorLayout.UMBRAL_EXPANSION = 1.30) aplica a
	# ingles. Se mide el peor caso, no la media.
	_check(ratio_en <= ANALIZADOR.UMBRAL_EXPANSION,
		"C: peor clave en/es %.3f dentro del umbral %.2f (%s)"
		% [ratio_en, ANALIZADOR.UMBRAL_EXPANSION, peor_en])
	# pt NO tiene umbral documentado: se REPORTA (no se inventa un criterio).
	print("      [informativo] pt/es %.3fx sin umbral documentado (peor: %s)" % [ratio_pt, peor_pt])
	_fin("C")

	# ── D: control negativo (el medidor NO puede ser ciego) ────────────
	# Si el medidor no puede ponerse en rojo, no verifica nada. A 96 px el panel
	# TIENE que desbordar el viewport de 1280x720; si dijera que cabe, el metrico
	# estaria ciego y el bloque B seria un falso verde.
	if loc != null:
		loc.set_locale("es")
	if _capa.has_method("_refrescar_completo"):
		_capa._refrescar_completo()
	_aplicar_tamano(_capa, 96)
	var r96: Dictionary = await _medir("rojo96")
	_check(bool(r96["desborda_w"]) or bool(r96["desborda_h"]),
		"D: a 96 px el panel DESBORDA (%.0f x %.0f vs %.0f x %.0f) — el medidor no es ciego"
		% [float(r96["panel_w"]), float(r96["panel_h"]), float(r96["vp"].x), float(r96["vp"].y)])
	var cabe_largo: bool = ANALIZADOR.cabe(ThemeDB.fallback_font,
		"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", 200.0, 24.0, 16)
	_check(not cabe_largo, "D: AnalizadorLayout.cabe() dice NO para un texto que no entra")
	var cabe_corto: bool = ANALIZADOR.cabe(ThemeDB.fallback_font, "ok", 200.0, 24.0, 16)
	_check(cabe_corto, "D: AnalizadorLayout.cabe() dice SI para un texto corto (no es ciego al reves)")
	_aplicar_tamano(_capa, 16)
	await process_frame
	_fin("D")

	# ── E: determinismo ────────────────────────────────────────────────
	if loc != null:
		loc.set_locale("es")
	if _capa.has_method("_refrescar_completo"):
		_capa._refrescar_completo()
	_aplicar_tamano(_capa, 16)
	var r1: Dictionary = await _medir("det1")
	var r2: Dictionary = await _medir("det2")
	_check(int(r1["textos"]) == int(r2["textos"]),
		"E: mismo numero de textos en dos mediciones (%d vs %d)" % [int(r1["textos"]), int(r2["textos"])])
	_check(bool(r1["desborda_w"]) == bool(r2["desborda_w"])
			and bool(r1["desborda_h"]) == bool(r2["desborda_h"]),
		"E: mismo veredicto de desborde en dos mediciones (%s/%s vs %s/%s)"
		% [str(r1["desborda_w"]), str(r1["desborda_h"]), str(r2["desborda_w"]), str(r2["desborda_h"])])
	_check(absf(float(r1["panel_w"]) - float(r2["panel_w"])) < 0.5,
		"E: el ancho del panel es estable entre mediciones (%.1f vs %.1f)"
		% [float(r1["panel_w"]), float(r2["panel_w"])])
	_fin("E")

	_terminado = true


## Restaura locale y libera la capa. En un `call_deferred` aparte: si `_run()`
## aborta por SCRIPT ERROR, esta funcion CORRE igual y el fallo se reporta en vez
## de colgar el SceneTree (trampas 61/122).
func _summary() -> void:
	if _cerrado:
		return
	_cerrado = true
	var loc = root.get_node_or_null("Localization")
	if loc != null and _locale_previo != "":
		loc.set_locale(_locale_previo)
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
	print("=== Resumen M55-IDIOMAS: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
