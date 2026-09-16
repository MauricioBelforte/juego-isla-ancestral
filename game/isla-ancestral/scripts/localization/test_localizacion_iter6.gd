extends SceneTree
## M87 iter. 6 — AnalizadorLayout + Glosario + RetraductorUI.
##
## Cierra con MEDICIÓN REAL los ítems que hasta ahora figuraban como
## "requiere QA visual": encaje de textos en layouts, expansión inglés/español,
## palabras largas sin espacios, consistencia de terminología y coste de la
## re-traducción en vivo.
##
## Guardián anti-falso-verde (trampa 11 + 28):
##  · `_fin("X")` marca cada bloque que terminó.
##  · `_summary()` falla si falta algún bloque (un SCRIPT ERROR aborta la función
##    en silencio y el suite imprimiría "0 fallos" con bloques sin correr).
##  · watchdog en `_process`: si `_run()` no termina, sale con código 1 en vez de
##    colgar el SceneTree para siempre.

const MODULO := "M87 iter. 6"
const TIMEOUT_FRAMES := 900
const BLOQUES_ESPERADOS: Array[String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]

## Contenedor de referencia para el análisis de encaje (botón/label típico de UI).
const ANCHO_CONTENEDOR := 220.0
const ALTO_CONTENEDOR := 40.0
const TAMANO := 16

var _checks := 0
var _fallos := 0
var _checks_previo := 0
var _vistos: Dictionary = {}
var _frames := 0
var _terminado := false
var _raiz_ui: Node = null

func _init() -> void:
	call_deferred("_run")

func _process(_delta: float) -> bool:
	_frames += 1
	if not _terminado and _frames > TIMEOUT_FRAMES:
		_terminado = true
		_checks += 1
		_fallos += 1
		print("!! WATCHDOG: _run() no terminó en %d frames (posible SCRIPT ERROR que abortó la función)" % TIMEOUT_FRAMES)
		print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
		quit(1)
	return false

## ── Infraestructura de test ──────────────────────────────

func _check(ok: bool, msg: String) -> void:
	_checks += 1
	if ok:
		print("[OK]    ", msg)
	else:
		_fallos += 1
		print("[FALLO] ", msg)

func _fin(nombre: String) -> void:
	_vistos[nombre] = true
	print("[FIN] bloque %s (+%d checks)" % [nombre, _checks - _checks_previo])
	_checks_previo = _checks

func _fuente() -> Font:
	return ThemeDB.fallback_font

func _traductor_falso() -> Callable:
	return func(clave: String) -> String:
		return "T:" + clave

## ── Suite ────────────────────────────────────────────────

func _run() -> void:
	print("=== %s — suite de localización ===" % MODULO)
	var loc: Node = root.get_node_or_null("Localization")
	var fuente: Font = _fuente()

	_bloque_a_fuentes(fuente)
	_bloque_b_encaje(fuente)
	_bloque_c_expansion(loc, fuente)
	_bloque_d_palabras(fuente)
	_bloque_e_estrategias(fuente)
	_bloque_f_glosario_carga()
	_bloque_g_glosario_verifica(loc)
	_bloque_h_decision()
	_bloque_i_retraduccion(loc)
	_bloque_j_regresion(loc)
	_bloque_k_accesibilidad(loc, fuente)

	_limpiar_ui()
	_summary()

## A — ¿Se puede medir texto en headless? ¿Con qué fuente?
func _bloque_a_fuentes(fuente: Font) -> void:
	_check(fuente != null, "A1 ThemeDB.fallback_font disponible en headless")

	var m: Vector2 = AnalizadorLayout.medir_linea(fuente, "Jugar", TAMANO)
	_check(m.x > 0.0, "A2 la medición devuelve ancho > 0 (%.1f px)" % m.x)
	_check(m.y > 0.0, "A3 la medición devuelve alto > 0 (%.1f px)" % m.y)

	var m2: Vector2 = AnalizadorLayout.medir_linea(fuente, "Jugar", TAMANO)
	var m3: Vector2 = AnalizadorLayout.medir_linea(fuente, "Jugar", TAMANO)
	_check(m == m2 and m2 == m3, "A4 medición determinista (3 lecturas idénticas)")

	var grande: Vector2 = AnalizadorLayout.medir_linea(fuente, "Jugar", 24)
	_check(grande.x > m.x, "A5 la medición escala con el tamaño (@24 > @16): %.1f > %.1f" % [grande.x, m.x])

	# Fuente real del juego: sólo Nunito-Variable es un TTF válido (BUG-042).
	var f_var: Font = load("res://assets/fonts/Nunito-Variable.ttf")
	var m_var: Vector2 = AnalizadorLayout.medir_linea(f_var, "Jugar", TAMANO)
	_check(m_var.x > 0.0, "A6 Nunito-Variable.ttf mide de verdad (%.1f px) — fuente real utilizable" % m_var.x)

	var f_reg: Font = load("res://assets/fonts/Nunito-Regular.ttf")
	var m_reg: Vector2 = AnalizadorLayout.medir_linea(f_reg, "Jugar", TAMANO)
	_check(m_reg.x == 0.0, "A7 Nunito-Regular.ttf mide 0 px → BUG-042 confirmado (es una página HTML 404, no una fuente)")

	var sin_wrap: Vector2 = AnalizadorLayout.medir_linea(fuente, "Settings of the island game", TAMANO)
	var con_wrap: Vector2 = AnalizadorLayout.medir(fuente, "Settings of the island game", TAMANO, 60.0)
	# Ojo: el ancho del bloque envuelto NO baja del ancho de su palabra más larga
	# («Settings» mide 67 px, más que el contenedor de 60). Lo que prueba que hubo
	# wrap es que el ALTO crece (varias líneas) y el ancho se reduce respecto del texto libre.
	_check(con_wrap.y > sin_wrap.y and con_wrap.x < sin_wrap.x,
		"A8 el wrap reparte en varias líneas (alto %.1f > %.1f) y reduce el ancho (%.1f < %.1f)" % [
			con_wrap.y, sin_wrap.y, con_wrap.x, sin_wrap.x])

	var vacio: Vector2 = AnalizadorLayout.medir_linea(fuente, "", TAMANO)
	_check(vacio.x == 0.0, "A9 texto vacío mide 0")
	_fin("A")

## B — Encaje y desborde contra un contenedor.
func _bloque_b_encaje(fuente: Font) -> void:
	_check(AnalizadorLayout.cabe(fuente, "Jugar", ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO),
		"B1 un texto corto cabe en el contenedor de referencia")

	_check(not AnalizadorLayout.cabe(fuente, "Settings of the island game and all its options",
		ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO),
		"B2 un texto largo NO cabe (ancho insuficiente)")

	_check(not AnalizadorLayout.cabe(fuente, "Settings of the island game", ANCHO_CONTENEDOR, 12.0, TAMANO),
		"B3 un texto que envuelve NO cabe si el alto es insuficiente")

	_check(not AnalizadorLayout.cabe(fuente, "Jugar", 0.0, ALTO_CONTENEDOR, TAMANO),
		"B4 un contenedor de ancho 0 no admite nada (guarda de entrada)")

	_check(AnalizadorLayout.altura_linea(fuente, TAMANO) > 0.0, "B5 altura de línea > 0")
	_fin("B")

## C — Expansión inglés/español medida sobre el catálogo REAL.
func _bloque_c_expansion(loc: Node, fuente: Font) -> void:
	if loc == null:
		_check(false, "C1 autoload Localization no disponible")
		_fin("C")
		return
	var cat_es: Dictionary = loc.catalogo("es")
	var cat_en: Dictionary = loc.catalogo("en")
	_check(not cat_es.is_empty(), "C1 catálogo español cargado (%d claves)" % cat_es.size())
	_check(not cat_en.is_empty(), "C2 catálogo inglés cargado (%d claves)" % cat_en.size())

	var entradas: Dictionary = {}
	for clave in cat_es:
		if cat_en.has(clave):
			entradas[clave] = {"es": str(cat_es[clave]), "en": str(cat_en[clave])}
	_check(entradas.size() > 0, "C3 hay %d claves bilingües para comparar" % entradas.size())

	var r: Dictionary = AnalizadorLayout.analizar(entradas, fuente, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO)
	_check(float(r["expansion_media"]) > 0.0, "C4 expansión media en/es = %.3f" % float(r["expansion_media"]))
	_check(float(r["expansion_maxima"]) >= float(r["expansion_media"]),
		"C5 expansión máxima %.3f ≥ media %.3f" % [float(r["expansion_maxima"]), float(r["expansion_media"])])
	_check(int(r["caben_es"]) >= 0 and int(r["caben_es"]) <= entradas.size(),
		"C6 caben en español: %d de %d" % [int(r["caben_es"]), entradas.size()])
	print("   · MEDICIÓN expansión: media %.3f · máxima %.3f · sobre +30%%: %d · desbordan: %d" % [
		float(r["expansion_media"]), float(r["expansion_maxima"]),
		int(r["claves_sobre_umbral"]), (r["desbordan"] as Array).size(),
	])
	var informe: String = AnalizadorLayout.formatear_informe(r)
	_check(informe.contains("expansión"), "C7 el informe menciona la expansión")
	_check((r["detalle"] as Dictionary).size() == entradas.size(),
		"C8 el detalle cubre las %d claves" % entradas.size())
	_fin("C")

## D — Palabras largas sin espacios y mitigaciones (ítem 128).
func _bloque_d_palabras(fuente: Font) -> void:
	var largas: Array[String] = AnalizadorLayout.palabras_largas("Una palabra DesproporcionadamenteLarga aquí")
	_check(largas.size() == 1, "D1 detecta 1 palabra larga sin espacios (%d)" % largas.size())
	if largas.size() == 1:
		_check(largas[0] == "DesproporcionadamenteLarga", "D2 la palabra detectada es la correcta")

	var cortas: Array[String] = AnalizadorLayout.palabras_largas("Settings of the island")
	_check(cortas.is_empty(), "D3 no marca palabras cortas (%d)" % cortas.size())

	var palabra := "DesproporcionadamenteLarga"
	var partida: String = AnalizadorLayout.partir_palabra(palabra, 6)
	_check(partida.length() > palabra.length(), "D4 partir_palabra inserta cortes (%d > %d chars)" % [partida.length(), palabra.length()])

	_check(AnalizadorLayout.partir_palabra("corta", 6) == "corta", "D5 una palabra ya corta no se modifica")

	# La mitigación debe MEJORAR la medición, no sólo cambiar el texto.
	var ancho_entera: float = AnalizadorLayout.medir(fuente, palabra, TAMANO, ANCHO_CONTENEDOR).x
	var ancho_partida: float = AnalizadorLayout.medir(fuente, partida, TAMANO, ANCHO_CONTENEDOR).x
	print("   · MEDICIÓN palabra larga: entera %.1f px vs partida %.1f px (contenedor %.0f)" % [
		ancho_entera, ancho_partida, ANCHO_CONTENEDOR,
	])
	_check(ancho_partida <= ancho_entera, "D6 partir la palabra no empeora el encaje (%.1f ≤ %.1f)" % [ancho_partida, ancho_entera])

	var largo_real := "Settings of the island game and all its options"
	var truncado: String = AnalizadorLayout.truncar_con_puntos(fuente, largo_real, ANCHO_CONTENEDOR, TAMANO)
	_check(AnalizadorLayout.medir_linea(fuente, truncado, TAMANO).x <= ANCHO_CONTENEDOR + 0.5,
		"D7 el texto truncado cabe en el ancho (%.1f px)" % AnalizadorLayout.medir_linea(fuente, truncado, TAMANO).x)
	_check(truncado.ends_with("…") and truncado.length() < largo_real.length(),
		"D8 el truncado avisa con puntos suspensivos y acorta el texto")

	_check(AnalizadorLayout.truncar_con_puntos(fuente, "Jugar", ANCHO_CONTENEDOR, TAMANO) == "Jugar",
		"D9 un texto que ya cabe no se toca")
	_fin("D")

## E — Estrategias de mitigación.
func _bloque_e_estrategias(fuente: Font) -> void:
	_check(AnalizadorLayout.estrategia(fuente, "Jugar", ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO) == "cabe",
		"E1 texto corto → estrategia «cabe»")

	var largo_pero_partible := "Configuracion avanzada del sistema de opciones"
	var est_largo: String = AnalizadorLayout.estrategia(fuente, largo_pero_partible, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO)
	_check(est_largo != "cabe", "E2 un texto que no cabe recibe una estrategia distinta («%s»)" % est_largo)

	var larguisima := "DesproporcionadamenteLarguisimaPalabraSinEspacios"
	var est_palabra: String = AnalizadorLayout.estrategia(fuente, larguisima, 60.0, 24.0, TAMANO)
	_check(est_palabra == "partir_palabra" or est_palabra == "reducir_fuente",
		"E3 palabra sin espacios → «%s»" % est_palabra)

	var t_min: int = AnalizadorLayout.tamano_minimo_que_cabe(fuente, largo_pero_partible, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, 12, TAMANO)
	_check(t_min == -1 or (t_min >= 12 and t_min <= TAMANO),
		"E4 tamano_minimo_que_cabe devuelve un valor válido (%d)" % t_min)

	_check(AnalizadorLayout.tamano_minimo_que_cabe(fuente, larguisima, 4.0, 4.0, 8, TAMANO) == -1,
		"E5 devuelve -1 cuando no cabe ni al tamaño mínimo")
	_fin("E")

## F — Glosario: carga y normalización.
func _bloque_f_glosario_carga() -> void:
	var g: Dictionary = Glosario.cargar()
	_check(not g.is_empty(), "F1 el glosario carga desde data/localization/glosario.json")
	var ts: Array = Glosario.terminos(g)
	_check(ts.size() > 0, "F2 el glosario tiene %d términos" % ts.size())

	_check(Glosario.normalizar("Energía") == "energia", "F3 normalizar quita acentos («Energía» → «energia»)")
	_check(Glosario.normalizar("HERRERÍA") == "herreria", "F4 normalizar pasa a minúsculas")
	_check(Glosario.normalizar("Catálogo") == "catalogo", "F5 normalizar con acento en la á")

	var completos := true
	for bruto in ts:
		var t: Dictionary = bruto as Dictionary
		if str(t.get("id", "")).is_empty() or str(t.get("es", "")).is_empty() or str(t.get("en", "")).is_empty():
			completos = false
	_check(completos, "F6 todos los términos tienen id, es y en")
	_fin("F")

## G — Glosario: verificación real + detección de inconsistencia INYECTADA.
func _bloque_g_glosario_verifica(loc: Node) -> void:
	var g: Dictionary = Glosario.cargar()
	if loc == null or g.is_empty():
		_check(false, "G1 precondiciones no cumplidas (glosario o autoload)")
		_fin("G")
		return
	var cat_es: Dictionary = loc.catalogo("es")
	var cat_en: Dictionary = loc.catalogo("en")

	var r: Dictionary = Glosario.verificar(g, cat_es, cat_en)
	print("   · MEDICIÓN glosario: %d términos · %d en uso · %d sin uso · %d inconsistencias" % [
		int(r["total"]), (r["usados"] as Array).size(),
		(r["sin_uso"] as Array).size(), (r["inconsistencias"] as Array).size(),
	])
	_check(int(r["total"]) == Glosario.terminos(g).size(), "G1 el informe cubre todos los términos")
	_check((r["usados"] as Array).size() > 0, "G2 hay %d términos realmente en uso en el catálogo" % (r["usados"] as Array).size())
	_check(bool(r["ok"]) == (r["inconsistencias"] as Array).is_empty(),
		"G3 la bandera ok es coherente con la lista de inconsistencias")
	print("   · INFORME:\n%s" % Glosario.formatear_informe(r))

	# Inyección: un catálogo inglés con un sinónimo NO canónico debe ser detectado.
	# Sin esta prueba, un validador que siempre devuelve "OK" pasaría inadvertido.
	# Se elige una clave HOY CONSISTENTE, así la inyección suma exactamente 1.
	var base: int = (r["inconsistencias"] as Array).size()
	var cat_en_falso: Dictionary = cat_en.duplicate()
	var clave_objetivo := ""
	for clave in cat_es:
		var clave_s := str(clave)
		if not Glosario.normalizar(str(cat_es[clave])).contains("madera"):
			continue
		if not cat_en_falso.has(clave_s):
			continue
		if not Glosario.normalizar(str(cat_en_falso[clave_s])).contains("wood"):
			continue
		clave_objetivo = clave_s
		break
	if clave_objetivo.is_empty():
		_check(false, "G4 no hay una clave consistente con «Madera» donde inyectar")
		_fin("G")
		return
	cat_en_falso[clave_objetivo] = "Timber"
	var r_falso: Dictionary = Glosario.verificar(g, cat_es, cat_en_falso)
	var inc: Array = r_falso["inconsistencias"] as Array
	_check(not bool(r_falso["ok"]), "G4 la inyección rompe la consistencia (ok = false)")
	_check(inc.size() == base + 1, "G5 aparece exactamente 1 inconsistencia nueva (%d → %d)" % [base, inc.size()])
	var encontrada := false
	for i in inc:
		var d: Dictionary = i as Dictionary
		if str(d["clave"]) == clave_objetivo and str(d["termino"]) == "MADERA" and str(d["obtenido"]) == "Timber":
			encontrada = true
	_check(encontrada, "G6 nombra clave (%s), término (MADERA) y valor inyectado (Timber)" % clave_objetivo)
	_fin("G")

## H — RetraductorUI: decisión pura de visibilidad (ítem 147).
func _bloque_h_decision() -> void:
	var rect := Rect2(Vector2.ZERO, Vector2(1920, 1080))
	_raiz_ui = _construir_ui()

	var visible_nodo: Node = _raiz_ui.get_node_or_null("Visible")
	var invisible: Node = _raiz_ui.get_node_or_null("Invisible")
	var fuera: Node = _raiz_ui.get_node_or_null("Fuera")
	var suelto := Label.new()

	_check(RetraductorUI.debe_retraducir(visible_nodo, rect), "H1 un nodo visible dentro del viewport se re-traduce")
	_check(not RetraductorUI.debe_retraducir(invisible, rect), "H2 un nodo invisible se salta")
	_check(not RetraductorUI.debe_retraducir(fuera, rect), "H3 un nodo visible pero FUERA del viewport se salta")
	_check(not RetraductorUI.debe_retraducir(suelto, rect), "H4 un nodo fuera del árbol se salta")
	_check(RetraductorUI.debe_retraducir(fuera, Rect2()), "H5 sin rectángulo visible, el encuadre no se comprueba")
	_check(not RetraductorUI.debe_retraducir(null, rect), "H6 un nodo nulo se salta")
	suelto.free()
	_fin("H")

## I — Re-traducción en vivo con UI abierta + coste (ítems 166 y 181).
func _bloque_i_retraduccion(loc: Node) -> void:
	if _raiz_ui == null:
		_raiz_ui = _construir_ui()
	var rect := Rect2(Vector2.ZERO, Vector2(1920, 1080))
	var traductor: Callable = _traductor_falso()

	var r: Dictionary = RetraductorUI.retraducir(_raiz_ui, traductor, rect)
	_check(int(r["visitados"]) == _contar_nodos(_raiz_ui),
		"I1 visita los %d nodos del árbol" % int(r["visitados"]))
	_check(int(r["traducidos"]) == 1, "I2 traduce sólo el nodo visible con clave (%d)" % int(r["traducidos"]))
	_check(int(r["saltados"]) == 2, "I3 salta invisible + fuera de pantalla (%d)" % int(r["saltados"]))
	_check((r["claves"] as Array).size() == 1, "I4 registra 1 clave distinta")

	var lbl: Label = _raiz_ui.get_node_or_null("Visible") as Label
	_check(lbl != null and lbl.text == "T:HUD.ENERGIA", "I5 el texto del nodo visible quedó re-traducido")

	var inv: Label = _raiz_ui.get_node_or_null("Invisible") as Label
	_check(inv != null and inv.text != "T:HUD.VIDA", "I6 el nodo invisible conserva su texto (no se tocó)")

	# Cambio de idioma REAL con la UI abierta (ítem 166).
	if loc != null and loc.has_method("set_locale") and loc.has_method("traducir_clave"):
		var original: String = str(loc.get_locale())
		loc.set_locale("en")
		var traductor_real: Callable = Callable(loc, "traducir_clave")
		var r_en: Dictionary = RetraductorUI.retraducir(_raiz_ui, traductor_real, rect)
		var texto_en: String = str(lbl.text) if lbl != null else ""
		_check(int(r_en["traducidos"]) == 1, "I7 con la UI abierta, el cambio a inglés re-traduce el nodo visible")
		_check(not texto_en.is_empty() and not texto_en.begins_with("HUD."),
			"I8 el texto en inglés es real («%s»)" % texto_en)

		loc.set_locale(original)
		RetraductorUI.retraducir(_raiz_ui, traductor_real, rect)
		var texto_es: String = str(lbl.text) if lbl != null else ""
		_check(texto_es != texto_en, "I9 al volver al idioma original el texto cambia de nuevo («%s»)" % texto_es)
	else:
		_check(false, "I7 autoload Localization sin API para el cambio en vivo")

	# Coste de un HUD completo (ítem 181).
	var hud := _construir_hud(120)
	var r_hud: Dictionary = RetraductorUI.retraducir(hud, traductor, rect)
	print("   · MEDICIÓN HUD 120 labels: visitados %d · traducidos %d · %.3f ms" % [
		int(r_hud["visitados"]), int(r_hud["traducidos"]), float(r_hud["ms"]),
	])
	_check(int(r_hud["traducidos"]) == 120, "I10 traduce los 120 labels del HUD")
	_check(bool(r_hud["cabe_en_60fps"]),
		"I11 el coste cabe en el frame budget de 60 fps (%.3f ms ≤ %.2f ms)" % [
			float(r_hud["ms"]), RetraductorUI.PRESUPUESTO_MS_60FPS])
	_check(RetraductorUI.formatear_informe(r_hud).contains("60 fps"), "I12 el informe menciona el presupuesto")
	root.remove_child(hud)
	hud.free()
	_fin("I")

## J — Regresión: los catálogos y las suites previas siguen consistentes.
func _bloque_j_regresion(loc: Node) -> void:
	var par: Dictionary = ValidadorPO.validar_par("res://locales/es.po", "res://locales/en.po")
	_check(bool(par.get("ok", false)), "J1 ValidadorPO: el par es/en sigue válido")
	_check((par.get("errores", []) as Array).is_empty(),
		"J2 ValidadorPO sin errores (%d)" % (par.get("errores", []) as Array).size())
	_check((par.get("faltantes_en_traduccion", []) as Array).is_empty(),
		"J3 no hay claves faltantes en inglés (%d)" % (par.get("faltantes_en_traduccion", []) as Array).size())

	if loc != null:
		_check((loc.validar_catalogos() as Array).is_empty(), "J4 Localization.validar_catalogos() sin faltantes")
		var estado: Dictionary = loc.obtener_estado_catalogos()
		var todo_ok := true
		for idioma in estado:
			if not bool((estado[idioma] as Dictionary).get("ok", false)):
				todo_ok = false
		_check(todo_ok, "J5 todos los idiomas con cobertura completa")
		_check(not (loc.catalogo("es") as Dictionary).is_empty(), "J6 el acceso de lectura al catálogo funciona")
		_check((loc.claves_catalogo("es") as Array).size() > 0, "J7 las claves del catálogo se listan")
	else:
		_check(false, "J4 autoload Localization no disponible")

	var scripts: Array[String] = [
		"res://scripts/localization/localization_manager.gd",
		"res://scripts/localization/locale_utils.gd",
		"res://scripts/localization/validador_po.gd",
		"res://scripts/localization/auditor_claves.gd",
		"res://scripts/localization/analizador_layout.gd",
		"res://scripts/localization/glosario.gd",
		"res://scripts/localization/retraductor_ui.gd",
	]
	var faltan: Array[String] = []
	for s in scripts:
		if not FileAccess.file_exists(s):
			faltan.append(s)
	_check(faltan.is_empty(), "J8 los %d scripts del módulo existen" % scripts.size())

	_check(FileAccess.file_exists("res://data/localization/glosario.json"), "J9 el glosario.json existe en el proyecto")
	_fin("J")

## K — Accesibilidad M58: el tamaño de texto ajustable no rompe la traducción.
## M58 permite un `ui_scale` de 0.8 a 1.5 (ver `scripts/ui/theme/theme_service.gd`).
## Se mide el catálogo real a los tamaños equivalentes y se reporta cuántas claves
## dejan de caber en el contenedor de referencia: esa lista es lo que M53 necesita
## para ajustar layouts cuando el jugador agranda la letra.
func _bloque_k_accesibilidad(loc: Node, fuente: Font) -> void:
	if loc == null:
		_check(false, "K1 autoload Localization no disponible")
		_fin("K")
		return
	var cat_es: Dictionary = loc.catalogo("es")
	var cat_en: Dictionary = loc.catalogo("en")
	var entradas: Dictionary = {}
	for clave in cat_es:
		if cat_en.has(clave):
			entradas[clave] = {"es": str(cat_es[clave]), "en": str(cat_en[clave])}

	var tamano_chico := 12   # ≈ 16 × 0.8 (mínimo de M58)
	var tamano_grande := 24  # ≈ 16 × 1.5 (máximo de M58)
	var r_chico: Dictionary = AnalizadorLayout.analizar(entradas, fuente, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, tamano_chico)
	var r_base: Dictionary = AnalizadorLayout.analizar(entradas, fuente, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO)
	var r_grande: Dictionary = AnalizadorLayout.analizar(entradas, fuente, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, tamano_grande)

	var desb_chico: int = (r_chico["desbordan"] as Array).size()
	var desb_base: int = (r_base["desbordan"] as Array).size()
	var desb_grande: int = (r_grande["desbordan"] as Array).size()
	print("   · MEDICIÓN accesibilidad M58 (contenedor %.0f×%.0f): desbordan @%d = %d · @%d = %d · @%d = %d" % [
		ANCHO_CONTENEDOR, ALTO_CONTENEDOR,
		tamano_chico, desb_chico, TAMANO, desb_base, tamano_grande, desb_grande,
	])

	_check(desb_chico <= desb_base, "K1 a tamaño %d desbordan menos o igual que a %d (%d ≤ %d)" % [
		tamano_chico, TAMANO, desb_chico, desb_base])
	_check(desb_grande >= desb_base, "K2 a tamaño %d desbordan más o igual que a %d (%d ≥ %d) → el análisis responde a la escala" % [
		tamano_grande, TAMANO, desb_grande, desb_base])
	_check(desb_base > 0, "K3 hay %d claves que desbordan a tamaño %d (trabajo real para M53)" % [desb_base, TAMANO])

	if desb_base > 0:
		var clave_problema: String = str((r_base["desbordan"] as Array)[0])
		var texto: String = str((entradas[clave_problema] as Dictionary).get("en", ""))
		var t_min: int = AnalizadorLayout.tamano_minimo_que_cabe(
			fuente, texto, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, 8, TAMANO)
		var est: String = AnalizadorLayout.estrategia(fuente, texto, ANCHO_CONTENEDOR, ALTO_CONTENEDOR, TAMANO)
		_check(t_min == -1 or (t_min >= 8 and t_min <= TAMANO),
			"K4 la clave «%s» admite tamaño mínimo %d" % [clave_problema, t_min])
		_check(not est.is_empty(), "K5 la clave «%s» recibe la estrategia «%s»" % [clave_problema, est])
	else:
		_check(false, "K4 no hay claves que desborden para analizar la mitigación")

	_check(desb_chico <= entradas.size() and desb_grande <= entradas.size(),
		"K6 los conteos son coherentes con las %d claves analizadas" % entradas.size())
	_fin("K")

## ── Utilidades de UI para el test ────────────────────────

func _construir_ui() -> Node:
	var raiz := Node.new()
	raiz.name = "RaizTestM87"
	root.add_child(raiz)

	var visible := Label.new()
	visible.name = "Visible"
	visible.text = "Energía"
	visible.position = Vector2(10, 10)
	visible.size = Vector2(100, 20)
	visible.set_meta("text_key", "HUD.ENERGIA")
	raiz.add_child(visible)

	var invisible := Label.new()
	invisible.name = "Invisible"
	invisible.text = "Vida"
	invisible.visible = false
	invisible.position = Vector2(10, 40)
	invisible.size = Vector2(100, 20)
	invisible.set_meta("text_key", "HUD.VIDA")
	raiz.add_child(invisible)

	var fuera := Label.new()
	fuera.name = "Fuera"
	fuera.text = "Idioma"
	fuera.position = Vector2(5000, 5000)
	fuera.size = Vector2(100, 20)
	fuera.set_meta("text_key", "SETTINGS.IDIOMA")
	raiz.add_child(fuera)

	return raiz

func _construir_hud(cantidad: int) -> Node:
	var hud := Node.new()
	hud.name = "HudTestM87"
	root.add_child(hud)
	for i in cantidad:
		var l := Label.new()
		l.name = "L%d" % i
		l.text = "Texto %d" % i
		l.position = Vector2(10 + (i % 10) * 60, 10 + (i / 10) * 20)
		l.size = Vector2(56, 18)
		l.set_meta("text_key", "HUD.CLAVE_%d" % i)
		hud.add_child(l)
	return hud

func _contar_nodos(n: Node) -> int:
	var total := 1
	for h in n.get_children():
		total += _contar_nodos(h)
	return total

func _limpiar_ui() -> void:
	if _raiz_ui != null and is_instance_valid(_raiz_ui):
		root.remove_child(_raiz_ui)
		_raiz_ui.free()
		_raiz_ui = null

## ── Cierre ───────────────────────────────────────────────

func _summary() -> void:
	var faltantes: Array[String] = []
	for b in BLOQUES_ESPERADOS:
		if not _vistos.has(b):
			faltantes.append(b)
	_checks += 1
	if faltantes.is_empty():
		print("[OK]    los %d bloques se completaron" % BLOQUES_ESPERADOS.size())
	else:
		_fallos += 1
		print("[FALLO] los %d bloques se completaron — no terminaron: %s" % [BLOQUES_ESPERADOS.size(), str(faltantes)])

	print("=== Resumen %s: %d checks, %d fallos ===" % [MODULO, _checks, _fallos])
	_terminado = true
	quit(0 if _fallos == 0 else 1)
