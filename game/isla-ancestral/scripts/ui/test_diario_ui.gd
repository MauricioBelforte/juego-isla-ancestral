# Modelo: mimo-v2.6-flash-free
# Plataforma: opencode
# Fecha: 2026-10-04
#
# M55 (T-M1): Test headless del DiaryLayer (pantalla del diario) sobre DiaryService.
# Verifica de verdad la integración UI ↔ servicio:
#  - pestañas (14), apertura < 100 ms, capa MODAL_FULL registrada/oculta
#  - anti-spoiler §3.2: vacío correcto, solo descubiertos en lista, % siempre
#    sobre lo descubierto y acotado a [0,100]
#  - detalle en 2 clics (pestaña → fila), estado, día y favorito round-trip
#    con ★ re-pintada en la fila (undo visual)
#  - filtros por estado (5 opciones) y búsqueda (con y sin acento, M87)
#  - categoría vacía (fotografías) con mensaje amistoso
#  - i18n: sin claves crudas visibles, nombres propios sin traducir (es/en)
#  - input: acciones `diario` (J) y `favorito` vía ui_manager._unhandled_input
#  - Esc/close_top purga la capa VISIBLE (fix T-M1) + heal de re-registro
#  - persistencia round-trip get_save_data/restore_save_data sin pérdidas
#  - sin tweens ni partículas (checklist X: Reduce Motion / M52 estricto)
#  - texto largo: wrap en detalle + tooltip completo en fila (checklist W parcial)
#
# Estado de DiaryService se SNAPSHOTA y restaura al final (no ensuciar el entorno).
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_diario_ui.gd

extends SceneTree

## Piso de checks medido en verde (patrón M105)
const CHECKS_MINIMOS: int = 55

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var diary = root.get_node_or_null("Diary")
	var ui = root.get_node_or_null("UIManager")
	var loc = root.get_node_or_null("Localization")
	_check(diary != null, "Diary autoload presente")
	_check(ui != null, "UIManager autoload presente")
	if diary == null or ui == null:
		_resumen()
		return
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("es")  # i18n determinista para los checks de texto
	_check(InputMap.has_action("diario"), "InputMap tiene la acción 'diario'")
	_check(InputMap.has_action("favorito"), "InputMap tiene la acción 'favorito'")

	# ── Snapshot del estado real + arranque con diario vacío ─────────
	var snap0: Dictionary = diary.get_save_data().duplicate(true)
	diary.restore_save_data({"schema_version": 1, "entradas": {}})

	# ── Montar la capa ────────────────────────────────────────────────
	# Si UIRoot ya montó su DiaryLayer (escena principal cargada), se libera
	# para que esta capa de test SEA "DiaryLayer" (los toggles de input la
	# buscan por ese nombre en ui_manager).
	var previa = ui._buscar_capa("DiaryLayer")
	if previa != null:
		previa.free()
	var base_stack: int = ui.stack_size()
	var script := load("res://scripts/ui/layers/diary_layer.gd")
	_check(script != null, "diary_layer.gd carga")
	if script == null or not script.can_instantiate():
		# Sin can_instantiate(): un parse error haría colgar el proceso
		_check(false, "diary_layer.gd compila sin errores de parseo")
		_resumen()
		return
	var capa = script.new()
	capa.name = "DiaryLayer"
	root.add_child(capa)
	_check(capa.layer_type == UILayerType.Type.MODAL_FULL, "layer_type MODAL_FULL")
	_check(not capa.visible, "inicia oculta")
	_check(ui.stack_size() == base_stack + 1, "registrada en la pila al entrar al árbol (%d)" % ui.stack_size())

	# ── Apertura ──────────────────────────────────────────────────────
	var t0 := Time.get_ticks_usec()
	capa.open()
	var us_apertura := Time.get_ticks_usec() - t0
	_check(capa.visible, "open() la hace visible")
	_check(us_apertura < 100000, "abre en < 100 ms con el catálogo actual (%d µs)" % us_apertura)

	# ── Pestañas y estructura ─────────────────────────────────────────
	var cats: Array = diary.get_categorias()
	_check(cats.size() == 14, "14 categorías desde get_categorias() (obtuvo %d)" % cats.size())
	var box = _buscar(capa, "CategoriasBox")
	_check(box != null and box.get_child_count() == 14, "14 pestañas construidas (obtuvo %d)" % (box.get_child_count() if box else -1))
	_check(_buscar(capa, "Tab_personajes") != null, "Tab_personajes existe")
	_check(_buscar(capa, "Tab_fotografias") != null, "Tab_fotografias existe")
	_check(String(capa._categoria_actual) == "personajes", "categoría por defecto = personajes")

	# ── i18n inicial (es) ─────────────────────────────────────────────
	_check(_sin_claves_crudas(capa), "ningún texto visible es una clave i18n cruda (DIARY./SETTINGS.)")
	var lbl_t = _buscar(capa, "LblTitulo")
	_check(lbl_t != null and lbl_t.text == "Diario", "LblTitulo i18n = 'Diario' (obtuvo: %s)" % str(lbl_t.text) if lbl_t else "sin LblTitulo")
	var btn_c = _buscar(capa, "BtnCerrar")
	_check(btn_c != null and btn_c.text == "Cerrar", "BtnCerrar i18n = 'Cerrar' (obtuvo: %s)" % str(btn_c.text) if btn_c else "sin BtnCerrar")
	var lbl_cats = _buscar(capa, "LblCategorias")
	_check(lbl_cats != null and lbl_cats.text == "Categorías", "LblCategorias i18n = 'Categorías'")
	var tab_p = _buscar(capa, "Tab_personajes")
	_check(tab_p != null and tab_p.text == "Personajes", "Tab_personajes i18n = 'Personajes' (obtuvo: %s)" % str(tab_p.text) if tab_p else "sin tab")

	# ── Diario vacío (anti-spoiler) ───────────────────────────────────
	var vacio = _buscar(capa, "LblVacio")
	_check(vacio != null and vacio.visible, "estado vacío visible sin descubrimientos")
	var lista = _buscar(capa, "ListaEntradas")
	_check(lista != null and lista.get_child_count() == 0, "0 filas con diario vacío")
	var barra = _buscar(capa, "ProgresoCat")
	_check(barra != null and float(barra.value) == 0.0, "barra de % en 0 con diario vacío")
	var lbl_g = _buscar(capa, "LblProgresoGlobal")
	_check(lbl_g != null and String(lbl_g.text).ends_with("0%"), "progreso global 0%")

	# ── Registrar 1 entrada: solo esa es visible ──────────────────────
	_check(diary.registrar("vecino_catalina_oso", "personajes"), "registrar catalina OK")
	capa.open()  # reabrir refresca (on_layer_opened)
	_check(lista.get_child_count() == 1, "1 fila tras registrar (las otras 4 de personajes invisibles, §3.2)")
	var fila_c = _buscar(capa, "Fila_vecino_catalina_oso")
	_check(fila_c != null and fila_c.text.contains("Catalina Oso"), "fila con título crudo del catálogo (obtuvo: %s)" % str(fila_c.text) if fila_c else "sin fila catalina")
	_check(vacio != null and not vacio.visible, "estado vacío oculto cuando hay filas")
	_check(barra != null and float(barra.value) > 99.0, "barra ≈100% (1 de 1 descubierto — % sobre lo DESCUBIERTO)")
	_check(lbl_g != null and String(lbl_g.text).ends_with("100%"), "global 100% sobre lo descubierto")
	_check(_sin_claves_crudas(capa), "sin claves crudas tras refrescar")

	# ── Selección (2 clics) y detalle ─────────────────────────────────
	var det_t = _buscar(capa, "LblDetalleTitulo")
	var det_e = _buscar(capa, "LblDetalleEstado")
	var det_d = _buscar(capa, "LblDetalleDia")
	var sin_sel = _buscar(capa, "LblSinSeleccion")
	var btn_fav = _buscar(capa, "BtnFavoritoDetalle")
	_check(sin_sel != null and sin_sel.visible, "hint 'sin selección' visible al abrir")
	_check(fila_c != null, "fila catalina disponible para clic")
	if fila_c:
		fila_c.emit_signal("pressed")  # clic 2 de la navegación de 2 clics
	_check(det_t != null and det_t.text == "Catalina Oso", "detalle muestra el título (obtuvo: %s)" % str(det_t.text) if det_t else "sin detalle")
	_check(det_e != null and det_e.text == "Visto", "detalle estado 'Visto' (obtuvo: %s)" % str(det_e.text) if det_e else "sin estado")
	_check(det_d != null, "etiqueta de día existe")
	_check(sin_sel != null and not sin_sel.visible, "hint 'sin selección' oculto tras elegir")
	_check(btn_fav != null and not btn_fav.disabled, "btn favorito habilitado con selección")
	_check(diary.es_favorito("vecino_catalina_oso") == false, "favorito inicia false")

	# ── Favorito round-trip con ★ en la fila (undo visual) ────────────
	btn_fav.emit_signal("pressed")
	_check(diary.es_favorito("vecino_catalina_oso") == true, "alternar_favorito → true")
	_check(btn_fav.button_pressed == true, "botón favorito en estado presionado")
	var fila_fav = _buscar(capa, "Fila_vecino_catalina_oso")
	_check(fila_fav != null and fila_fav.text.begins_with("★"), "★ al inicio de la fila tras marcar favorito (obtuvo: %s)" % str(fila_fav.text) if fila_fav else "sin fila tras refresco")
	btn_fav.emit_signal("pressed")
	_check(diary.es_favorito("vecino_catalina_oso") == false, "segundo toggle → false (undo)")
	var fila_nofav = _buscar(capa, "Fila_vecino_catalina_oso")
	_check(fila_nofav != null and not fila_nofav.text.begins_with("★"), "★ retirada de la fila")

	# ── Filtros por estado (5 opciones) ───────────────────────────────
	var opt = _buscar(capa, "FiltroEstado")
	_check(opt != null and opt.item_count == 5, "filtro con 5 opciones (obtuvo %d)" % (opt.item_count if opt else -1))
	_check(opt != null and opt.get_item_text(0) == "Todos" and opt.get_item_text(4) == "Favoritos", "textos de filtro i18n (Todos/Favoritos)")
	capa._on_filtro_selected(3)  # COMPLETADOS: catalina está VISTO
	_check(lista.get_child_count() == 0, "filtro Completados: 0 filas (catalina solo Visto)")
	_check(vacio != null and vacio.visible, "vacío visible cuando el filtro no deja filas")
	capa._on_filtro_selected(1)  # NUEVOS (registrada esta sesión)
	_check(lista.get_child_count() == 1, "filtro Nuevos: 1 fila (registrada en esta sesión)")
	capa._on_filtro_selected(4)  # FAVORITOS (recién desmarcada)
	_check(lista.get_child_count() == 0, "filtro Favoritos: 0 filas (sin favoritos)")
	capa._on_filtro_selected(0)  # TODOS
	_check(lista.get_child_count() == 1, "filtro Todos: 1 fila de nuevo")

	# ── Búsqueda (con y sin acento, M87) ──────────────────────────────
	var busc = _buscar(capa, "Buscador")
	_check(busc != null, "Buscador existe")
	busc.text = "catalina"
	busc.text_changed.emit("catalina")
	_check(lista.get_child_count() == 1, "búsqueda 'catalina' → 1 fila")
	busc.text = "zzzz"
	busc.text_changed.emit("zzzz")
	_check(lista.get_child_count() == 0, "búsqueda sin resultados → 0 filas")
	_check(vacio != null and vacio.visible and vacio.text == "Sin resultados para la búsqueda.", "mensaje amistoso de sin resultados (obtuvo: %s)" % str(vacio.text) if vacio else "sin LblVacio")
	_check(diary.registrar("lugar_isla_raiz", "lugares"), "registrar Isla Raíz OK")
	busc.text = "raíz"
	busc.text_changed.emit("raíz")
	_check(_buscar(capa, "Fila_lugar_isla_raiz") != null, "búsqueda con acento 'raíz' encuentra 'Isla Raíz'")
	busc.text = "raiz"
	busc.text_changed.emit("raiz")
	_check(_buscar(capa, "Fila_lugar_isla_raiz") != null, "búsqueda SIN acento 'raiz' encuentra 'Isla Raíz' (diacríticos M87)")
	busc.text = ""
	busc.text_changed.emit("")

	# ── Cambio de pestaña y categoría vacía ───────────────────────────
	var tab_lug = _buscar(capa, "Tab_lugares")
	_check(tab_lug != null, "Tab_lugares existe")
	if tab_lug:
		tab_lug.emit_signal("pressed")
	_check(String(capa._categoria_actual) == "lugares", "clic de pestaña cambia la categoría")
	_check(lista.get_child_count() == 1, "lugares: 1 fila (las 4 no descubiertas invisibles)")
	var tab_foto = _buscar(capa, "Tab_fotografias")
	if tab_foto:
		tab_foto.emit_signal("pressed")
	_check(lista.get_child_count() == 0, "fotografías (catálogo 0 entradas): 0 filas")
	_check(vacio != null and vacio.visible and vacio.text == "Todavía no hay entradas en esta categoría.", "mensaje amistoso de categoría vacía (obtuvo: %s)" % str(vacio.text) if vacio else "sin LblVacio")

	# ── Cobertura del catálogo (honesto: 13 de 14) ────────────────────
	var con_entradas := 0
	var vacias: Array = []
	for cat in cats:
		var arr: Array = diary._catalogo.get(String(cat), [])
		if arr.size() > 0:
			con_entradas += 1
		else:
			vacias.append(String(cat))
	_check(con_entradas == 13, "13/14 categorías con ≥1 entrada en catálogo (vacías: %s — 'fotografias' al M56)" % str(vacias))

	# ── Scroll preservado al seleccionar (checklist T) ────────────────
	var scroll = _buscar(capa, "ScrollLista")
	_check(scroll != null, "ScrollLista existe")
	var v0 := 0.0
	if scroll:
		v0 = scroll.get_v_scroll_bar().value
		var tab_p2 = _buscar(capa, "Tab_personajes")
		if tab_p2:
			tab_p2.emit_signal("pressed")
		var fila_post = _buscar(capa, "Fila_vecino_catalina_oso")
		if fila_post:
			fila_post.emit_signal("pressed")
		_check(absf(scroll.get_v_scroll_bar().value - v0) < 0.01, "scroll intacto al seleccionar en el detalle")

	# ── Persistencia round-trip (checklist Y) ─────────────────────────
	var guardado: Dictionary = diary.get_save_data()
	diary.restore_save_data(guardado)
	_check(diary.esta_registrada("vecino_catalina_oso"), "guardar → cargar: catalina persiste")
	_check(diary.esta_registrada("lugar_isla_raiz"), "guardar → cargar: Isla Raíz persiste")
	_check(not diary.esta_registrada("mision_test_quest"), "guardar → cargar: no se cuelan entradas no guardadas")

	# ── % acotado a [0,100] tras registrar todo ───────────────────────
	for e in diary._catalogo.get("personajes", []):
		diary.registrar(String(e.get("id", "")), "personajes")
	capa.open()
	_check(barra != null and float(barra.value) <= 100.0 and float(barra.value) >= 0.0, "barra acotada a [0,100] (obtuvo %s)" % str(barra.value) if barra else "sin barra")
	_check(lbl_g != null and String(lbl_g.text).ends_with("100%"), "global ≤100% tras registrar todo lo descubierto")

	# ── Esc/close_top purga la capa VISIBLE + heal ────────────────────
	var estaba_settings: bool = ui._buscar_capa("SettingsAudioLayer") != null
	capa.open()
	_check(capa.visible, "diario visible antes de close_top")
	ui.close_top()
	_check(not capa.visible, "Esc (close_top) cierra el diario VISIBLE (no una capa oculta)")
	_check(ui.stack_size() == base_stack, "diario des-registrado tras close_top (pila=%d)" % ui.stack_size())
	if estaba_settings:
		_check(ui._buscar_capa("SettingsAudioLayer") != null, "SettingsAudioLayer NO fue purgada por mistake (bug T-M1)")
	capa.open()
	_check(capa.visible and ui.stack_size() == base_stack + 1, "on_layer_opened RE-REGISTRA tras Esc (heal)")

	# ── Acciones de input: `diario` (J) y `favorito` ───────────────────
	var ev_diario := InputEventAction.new()
	ev_diario.action = "diario"
	ev_diario.pressed = true
	ui._unhandled_input(ev_diario)
	_check(not capa.visible, "acción 'diario' cierra el diario abierto")
	ui._unhandled_input(ev_diario)
	_check(capa.visible, "acción 'diario' reabre el diario")
	# selección + favorito por input
	var tab_p3 = _buscar(capa, "Tab_personajes")
	if tab_p3:
		tab_p3.emit_signal("pressed")
	var fila_in = _buscar(capa, "Fila_vecino_catalina_oso")
	if fila_in:
		fila_in.emit_signal("pressed")
	var fav_antes: bool = diary.es_favorito("vecino_catalina_oso")
	var ev_fav := InputEventAction.new()
	ev_fav.action = "favorito"
	ev_fav.pressed = true
	ui._unhandled_input(ev_fav)
	_check(diary.es_favorito("vecino_catalina_oso") == not fav_antes, "acción 'favorito' alterna la selección del diario")
	ui._unhandled_input(ev_diario)  # cerrar
	var fav_cerrado: bool = diary.es_favorito("vecino_catalina_oso")
	ui._unhandled_input(ev_fav)
	_check(diary.es_favorito("vecino_catalina_oso") == fav_cerrado, "'favorito' ignorado con el diario cerrado")
	ui._unhandled_input(ev_diario)  # volver a abrir para el resto

	# ── Localización en inglés + nombres propios sin traducir ─────────
	if loc != null and loc.has_method("set_locale"):
		loc.set_locale("en")
		capa.open()
		_check(btn_c.text == "Close", "BtnCerrar en EN = 'Close' (obtuvo: %s)" % str(btn_c.text))
		var tab_en = _buscar(capa, "Tab_personajes")
		_check(tab_en != null and tab_en.text == "Characters", "Tab en EN = 'Characters' (obtuvo: %s)" % str(tab_en.text) if tab_en else "sin tab EN")
		var fila_en = _buscar(capa, "Fila_vecino_catalina_oso")
		_check(fila_en != null and fila_en.text.contains("Catalina Oso"), "nombre propio SIN traducir en EN (M87)")
		_check(_sin_claves_crudas(capa), "sin claves crudas en EN")
		loc.set_locale("es")
		capa.open()

	# ── Sin VFX/tweens (checklist X: M52 estricto / Reduce Motion) ────
	var src := FileAccess.get_file_as_string("res://scripts/ui/layers/diary_layer.gd")
	_check(not src.contains("create_tween") and not src.contains("GPUParticles") and not src.contains("CPUParticles"),
		"capa sin tweens ni partículas (Reduce Motion / M52 estricto)")
	_check(src.contains("text_key") and src.contains("_t("), "textos por claves i18n + metadato text_key (M87)")

	# ── Texto largo: wrap en detalle + tooltip completo en fila ───────
	_check(det_t != null and int(det_t.autowrap_mode) != TextServer.AUTOWRAP_OFF, "título del detalle con wrap (texto largo)")
	var fila_tip = _buscar(capa, "Fila_vecino_catalina_oso")
	_check(fila_tip != null and String(fila_tip.tooltip_text).contains("Catalina Oso"), "fila con tooltip del texto completo")

	# ── Restaurar snapshot y liberar ──────────────────────────────────
	diary.restore_save_data(snap0)
	var tras: Dictionary = diary.get_save_data()
	_check(int(tras.get("entradas", {}).size()) == int(snap0.get("entradas", {}).size()),
		"snapshot restaurado sin pérdidas (%d == %d)" % [int(tras.get("entradas", {}).size()), int(snap0.get("entradas", {}).size())])
	capa.free()  # inmediato: exit_tree des-registra
	_check(ui.stack_size() == base_stack, "free des-registra la capa")

	_resumen()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _buscar(node: Node, nombre: String) -> Node:
	if node.name == nombre:
		return node
	for child in node.get_children():
		if child.name == nombre:
			return child
		var r := _buscar(child, nombre)
		if r:
			return r
	return null

## Recorre los controles VISIBLES y detecta claves i18n sin traducir en texto
func _sin_claves_crudas(node: Node) -> bool:
	if node is Control and node.visible:
		if node is Label or node is Button:
			var txt := String((node as Control).get("text"))
			if txt.begins_with("DIARY.") or txt.begins_with("SETTINGS."):
				print("clave cruda en %s: %s" % [node.name, txt])
				return false
		elif node is LineEdit:
			var ph := String((node as Control).get("placeholder_text"))
			if ph.begins_with("DIARY.") or ph.begins_with("SETTINGS."):
				print("placeholder crudo en %s: %s" % [node.name, ph])
				return false
	for child in node.get_children():
		if not _sin_claves_crudas(child):
			return false
	return true

func _resumen() -> void:
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("FALLO: piso de checks no alcanzado (%d < %d)" % [_checks, CHECKS_MINIMOS])
	print("=== TEST M55 DIARIO UI: %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)
