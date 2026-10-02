# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-02
#
# M131: CreditsLayer — test headless de la pantalla de créditos.
# Valida la Sección D del 05-Checklist (los 10 ítems de interfaz) ejecutando
# la capa real en árbol: montaje, open/close, controles, idioma, contraste,
# contador, salto de sección y tiempo máximo de 5 minutos.
#
# Preloads §9.52: nombre SIN colisionar con class_name CreditsLayer.

extends SceneTree

const _SC_LAYER := preload("res://scripts/ui/layers/credits_layer.gd")

var _fallos: int = 0
var _checks: int = 0
var _layer = null
var _mgr = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== [M131] Test de CreditsLayer ===")
	_setup()
	_test_montaje()
	_test_apertura()
	_test_controles()
	_test_idioma_contraste()
	_test_reloj_y_seccion()
	_teardown()
	_summary()


func _check(nombre: String, cond: bool, detalle: String = "") -> void:
	_checks += 1
	if cond:
		print("  [OK] %s" % nombre)
	else:
		_fallos += 1
		print("  [FAIL] %s %s" % [nombre, detalle])


func _setup() -> void:
	var root := get_root()
	_mgr = root.get_node_or_null("credits_manager")
	if _mgr == null:
		var ms := load("res://scripts/legal/credits_manager.gd")
		if ms:
			_mgr = ms.new()
			_mgr.name = "credits_manager"
			root.add_child(_mgr)
	_layer = _SC_LAYER.new()
	_layer.name = "CreditsLayer"
	root.add_child(_layer)


func _test_montaje() -> void:
	print("--- Montaje ---")
	_check("capa instanciada", _layer != null)
	_check("hereda de UILayer", _layer is UILayer)
	_check("tipo MODAL_FULL", _layer.layer_type == UILayerType.Type.MODAL_FULL)
	_check("arranca oculta", _layer.visible == false)
	_check("RichTextLabel creado", _layer._rich != null)
	_check("D1: texto con contenido", _layer._rich != null and _layer._rich.text.length() > 0)
	_check("D1: scroll activo", _layer._rich != null and _layer._rich.scroll_active)
	# Regresión 2026-10-02: el método real es get_v_scroll_bar (con guiones
	# bajos); get_vscroll_bar compila en --check-only pero revienta en runtime.
	_check("D1: scrollbar alcanzable", _layer._rich != null and _layer._rich.get_v_scroll_bar() != null)
	_check("D2-D6,D10: 6 controles", _layer._buttons.size() == 6, "size=%d" % _layer._buttons.size())
	_check("C38: contador visible", _layer._lbl_reloj != null)
	_check("D7: copyright con año", String(_layer._lbl_copy.text).contains("©"), "text=%s" % _layer._lbl_copy.text)
	_check("D7: año auto-dinámico", String(_layer._lbl_copy.text).contains(str(Time.get_datetime_dict_from_system().get("year", 0))))


func _test_apertura() -> void:
	print("--- open() / close() ---")
	_layer.open()
	_check("D10: visible al abrir", _layer.visible)
	_check("D9: reloj en 00:00", _layer._lbl_reloj.text == "00:00", "text=%s" % _layer._lbl_reloj.text)
	_check("D9: sin despedida al abrir", _layer._lbl_farewell.visible == false)
	_check("D10: foco inicial en un control", _layer.focus_first() != null)
	_layer.close()
	_check("close() oculta la capa", _layer.visible == false)


func _test_controles() -> void:
	print("--- Controles (Sección D) ---")
	_layer.open()
	var idx0: int = _layer._tamanio_idx
	_layer._ciclar_tamanio()
	_check("D3: tamaño cicla", _layer._tamanio_idx != idx0, "idx=%d" % _layer._tamanio_idx)
	_check("D3: tamaño S/M/L válido", _layer.TAMANOS.has(_layer.TAMANOS[_layer._tamanio_idx]))
	_check("D3: fuente aplicada", _layer._rich.get_theme_font_size("normal_font_size") == _layer.TAMANOS[_layer._tamanio_idx], "px=%d" % _layer._rich.get_theme_font_size("normal_font_size"))

	var vel0: int = _layer._velocidad_idx
	_layer._ciclar_velocidad()
	_check("D5: velocidad cicla", _layer._velocidad_idx != vel0, "idx=%d" % _layer._velocidad_idx)
	_check("D5: tres velocidades", _layer.VELOCIDADES.size() == 3)

	_layer._alternar_anim()
	_check("D2: pausa de animación", _layer._animando == false)
	_layer._alternar_anim()
	_check("D2: reanuda animación", _layer._animando == true)

	_layer._alternar_contraste()
	_check("D4: alto contraste activo", _layer._contraste == true)
	_check("D4: fondo en negro", _layer._bg.color == Color(0, 0, 0), "color=%s" % _layer._bg.color)
	_layer._alternar_contraste()
	_check("D4: vuelve a contraste normal", _layer._contraste == false)
	_check("D8: fondo cozy arena", _layer._bg.color == ThemeUx.COLOR_BG_ARENA, "color=%s" % _layer._bg.color)
	_layer.close()


func _test_idioma_contraste() -> void:
	print("--- Idioma en caliente (D6) ---")
	if _mgr == null:
		_check("credits_manager disponible", false)
		return
	_layer.open()
	var antes := String(_mgr.obtener_idioma())
	var texto_antes: String = _layer._rich.text
	_layer._alternar_idioma()
	var despues := String(_mgr.obtener_idioma())
	_check("D6: idioma conmutado", antes != despues, "%s -> %s" % [antes, despues])
	_check("D6: texto regenerado", _layer._rich.text != texto_antes)
	if despues == "en":
		_check("D6: contenido en inglés", _layer._rich.text.contains("Development"), "_layer._rich.text")
	_layer._alternar_idioma()
	_check("D6: vuelve al idioma original", String(_mgr.obtener_idioma()) == antes)
	_check("D6: contenido restaurado", _layer._rich.text.contains("Desarrollo") or _layer._rich.text.contains("Development"))


func _test_reloj_y_seccion() -> void:
	print("--- Reloj, salto de sección y tiempo máximo ---")
	_layer.open()
	var t0: float = _layer._reloj
	_layer._process(1.5)
	_check("C38: contador avanza", _layer._reloj > t0, "reloj=%.2f" % _layer._reloj)
	_check("C38: etiqueta mm:ss", _layer._lbl_reloj.text.match("*:*"), "text=%s" % _layer._lbl_reloj.text)

	_layer._saltar_seccion(1)
	_check("J104: salto a sección 1", _layer._seccion_actual == 1, "idx=%d" % _layer._seccion_actual)
	_layer._saltar_seccion(1)
	_check("J104: salto a sección 2", _layer._seccion_actual == 2, "idx=%d" % _layer._seccion_actual)
	_layer._saltar_seccion(-1)
	_check("J104: retroceso a sección 1", _layer._seccion_actual == 1, "idx=%d" % _layer._seccion_actual)
	_check("J104: etiqueta de sección con título", String(_layer._lbl_seccion.text).length() > 0, "text=%s" % _layer._lbl_seccion.text)

	_layer._reloj = 299.9
	_layer._process(0.2)
	_check("D9: fin a los 5 minutos", _layer._fin_alcanzado == true)
	_check("D9: animación detenida", _layer._animando == false)
	_check("J103/J106: despedida visible", _layer._lbl_farewell.visible == true)
	_check("J106: despedida con texto", String(_layer._lbl_farewell.text).length() > 0, "text=%s" % _layer._lbl_farewell.text)
	_layer.close()


func _teardown() -> void:
	if _layer and is_instance_valid(_layer):
		_layer.queue_free()


func _summary() -> void:
	print("=== Resumen M131 CreditsLayer: %d checks, %d fallos ===" % [_checks, _fallos])
	if _fallos > 0:
		print("TEST M131 LAYER FALLIDO — salida con código 1")
		quit(1)
	else:
		print("TEST M131 LAYER OK — todos los checks pasaron")
		quit(0)
