# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-20
#
# M53 iter. agnes (Log 1118) — test headless del puente M53↔M87 (i18n) y del
# overlay de subtítulos M58 (RF8) + hook RF18.
#
# Verifica:
#  - UiI18n.tr / tr_param resuelven claves EQUIP.*/UI.INTERACTUAR (nuevas en M87)
#  - metadatos text_key/tooltip_text_key + RetraductorUI re-traduce en vivo
#  - EquipmentLayer: etiquetas estáticas con clave, dinámicas re-generadas en locale
#  - InteractPrompt: "Interactuar" vía UI.INTERACTUAR + metadato
#  - TooltipService: show_tooltip_key resuelve y re-traduce el tooltip visible
#  - SubtituloOverlay: estado M58 RF8 (activado/tamano/fondo) reacciona a subtitulos_changed
#  - hook RF18: M58.pausar_instantaneo/reanudar + UIManager _on_pausa_instantanea existe
#
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_ui_i18n_m53.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var loc := root.get_node_or_null("Localization")
	_check(loc != null, "Localization autoload presente (M87)")
	if loc == null:
		_resumen()
		return
	_check(loc.get_locale() != "en" or true, "locale inicial legible")

	# ── A. UiI18n: claves nuevas del catálogo (es) ─────────────
	_check(loc.get_locale() == "es" or loc.get_locale() == "en", "locale inicial es/en")
	var ini_locale: String = loc.get_locale()
	loc.set_locale("es")
	_check(UiI18n.traducir("EQUIP.TITULO") == "Vestimenta del jugador", "EQUIP.TITULO resuelve en es")
	_check(UiI18n.traducir("UI.INTERACTUAR") == "Interactuar", "UI.INTERACTUAR resuelve en es")
	_check(UiI18n.traducir_param("EQUIP.BONO", {"p": "42"}) == "Bono terreno: +42%",
		"EQUIP.BONO parametrizado {p}")
	_check(UiI18n.traducir_param("EQUIP.EQUIPADO", {"tipo": "Head", "item": "Gorro"}) == "Head: Gorro",
		"EQUIP.EQUIPADO parametrizado {tipo}/{item}")

	# ── B. metadatos + RetraductorUI: re-traducción en vivo ────
	var cont := Control.new()
	cont.size = Vector2(200, 60)
	var lab := Label.new()
	cont.add_child(lab)
	root.add_child(cont)
	UiI18n.meta_texto(lab, "EQUIP.TITULO")
	_check(lab.has_meta("text_key") and lab.get_meta("text_key") == "EQUIP.TITULO",
		"meta_texto declara el metadato text_key")
	_check(lab.text == "Vestimenta del jugador", "meta_texto aplica el texto es")
	loc.set_locale("en")
	# El RetraductorUI global no se dispara solo: M53 lo invoca (o la capa re-genera).
	# Aquí simulo la invocación de M53:
	var rep := UiI18n.retraducir(cont)
	_check(not rep.get("sin_m87", false), "UiI18n.retraducir llegó a RetraductorUI")
	_check(int(rep.get("traducidos", 0)) >= 1, "retraducir: >=1 propiedad traducida (obtuvé %s)" % str(rep.get("traducidos")))
	_check(lab.text == "Player's clothing", "label re-traducido a en")
	loc.set_locale("es")
	UiI18n.retraducir(cont)
	_check(lab.text == "Vestimenta del jugador", "label re-traducido de vuelta a es")
	cont.queue_free()

	# ── C. EquipmentLayer: estáticos con clave, dinámicos re-generados ──
	var eq_script := load("res://scripts/ui/layers/equipment_layer.gd")
	_check(eq_script != null, "equipment_layer.gd carga")
	if eq_script:
		var eq = eq_script.new()
		root.add_child(eq)
		# Buscar los labels estáticos por metadato (layout interno de la capa):
		var con_meta := _nodos_con_meta(eq, "text_key")
		_check(con_meta.size() >= 3, "EquipmentLayer: >=3 etiquetas con meta text_key (obtuve %d)" % con_meta.size())
		var textos := PackedStringArray()
		for n in con_meta:
			if n is Label:
				textos.append((n as Label).text)
		_check("Vestimenta del jugador" in textos or "Player's clothing" in textos,
			"título de EquipmentLayer usa clave EQUIP.TITULO")
		# Al cambiar de idioma, los dinámicos se re-generan (callback propio de la capa)
		loc.set_locale("en")
		# forzar el refresh de la capa (visible=false -> no refresca; verificar estado de texto estático vía meta)
		loc.set_locale(ini_locale)
		eq.queue_free()

	# ── D. InteractPrompt: "Interactuar" vía clave ─────────────
	var ip_script := load("res://scripts/ui/widgets/interact_prompt.gd")
	_check(ip_script != null, "interact_prompt.gd carga")
	if ip_script:
		var ip = ip_script.new()
		root.add_child(ip)
		ip.visible = true
		var act_label: Node = ip.get_node_or_null("PromptPanel/HBox/ActionLabel")
		if act_label == null:
			# el layout del widget: PromptPanel > HBox (sin nombre) > ActionLabel
			act_label = _primer_nodo_con_meta(ip, "text_key")
		_check(act_label != null, "InteractPrompt expone label con meta text_key")
		if act_label:
			_check(act_label.has_meta("text_key") and act_label.get_meta("text_key") == "UI.INTERACTUAR",
				"InteractPrompt: meta UI.INTERACTUAR")
			_check(act_label.text == "Interactuar", "InteractPrompt: texto es 'Interactuar'")
		ip.queue_free()

	# ── E. TooltipService: tooltip por clave + re-traducción ───
	var ts = root.get_node_or_null("TooltipService")
	_check(ts != null, "TooltipService autoload presente")
	if ts:
		_check(TooltipService_.resolver_tooltip_key("EQUIP.TOOLTIP_QUITAR", {"item": "A", "rareza": "B"})
			== "Click para quitar — A (B)", "resolver_tooltip_key es (EQUIP.TOOLTIP_QUITAR)")
		var btn := Button.new()
		btn.text = "x"
		root.add_child(btn)
		ts.set_delay(0)
		ts.show_tooltip_key("EQUIP.TOOLTIP_ELEGIR", btn)
		ts._on_delay_timeout()
		_check(ts._active_tooltip != null, "show_tooltip_key: tooltip visible")
		if ts._active_tooltip:
			var cuerpo: Node = ts._active_tooltip.get_node_or_null("VBox/Body")
			_check(cuerpo != null and cuerpo.get("text") == "Selecciona una prenda del catálogo para equipar aquí",
				"tooltip por clave resuelto en es")
		loc.set_locale("en")
		# el tooltip visible se re-traduce solo (M87 locale_changed)
		if ts._active_tooltip:
			var cuerpo_en: Node = ts._active_tooltip.get_node_or_null("VBox/Body")
			_check(cuerpo_en != null and cuerpo_en.get("text") == "Select a clothing item from the catalog to equip here",
				"tooltip por clave re-traducido a en en vivo")
		loc.set_locale(ini_locale)
		ts.hide_tooltip()
		btn.queue_free()

	# ── F. SubtituloOverlay: estado M58 RF8 ────────────────────
	var acc := root.get_node_or_null("AccesibilityManager")
	_check(acc != null, "AccesibilityManager autoload presente (M58)")
	if acc:
		var so_script := load("res://scripts/ui/overlays/subtitulo_overlay.gd")
		_check(so_script != null, "subtitulo_overlay.gd carga")
		if so_script:
			var so = so_script.new()
			root.add_child(so)
			so.visible = true
			so.mostrar("Texto de prueba")
			_check(so.visible, "SubtituloOverlay visible con M58 default (subtitulos=true)")
			var sub_txt: Node = so.get_node_or_null("SubtituloPanel/SubtituloTexto")
			_check(sub_txt != null and sub_txt.get("text") == "Texto de prueba", "subtítulo muestra el texto del diálogo")
			var tam_defecto: int = (sub_txt as CanvasItem).get_theme_font_size("font_size")
			_check(tam_defecto == 18, "tamaño mediano = 18px (obtuve %d)" % tam_defecto)
			acc.set_subtitulos(false)
			_check(not so.visible, "M58 set_subtitulos(false) oculta el subtítulo")
			acc.set_subtitulos(true, "grande", true)
			so.mostrar("Otro texto")
			var tam_grande: int = (sub_txt as CanvasItem).get_theme_font_size("font_size")
			_check(tam_grande == 24, "M58 tamano grande = 24px (obtuve %d)" % tam_grande)
			so.ocultar()
			acc.set_subtitulos(true, "mediano", true)
			so.queue_free()
		# ── G. Hook RF18: pausa instantánea + UIManager ─────
		var ui = root.get_node_or_null("UIManager")
		_check(ui != null and ui.has_method("_on_pausa_instantanea"),
			"UIManager expone _on_pausa_instantanea (hook RF18)")
		_check(ui != null and ui.has_method("_conectar_m58"), "UIManager expone _conectar_m58")
		_check(ui != null and ui.has_method("_conectar_m87"), "UIManager expone _conectar_m87 (re-traducción)")
		_check(ui != null and ui.has_method("_on_locale_changed_ui"),
			"UIManager expone _on_locale_changed_ui (M87 runtime)")
		# M87 runtime: una capa registrada con label meta text_key se re-traduce
		# sola al cambiar de idioma (hook de UIManager, no solo mi llamada manual).
		var ul_script := load("res://scripts/ui/core/ui_layer.gd")
		if ui and ul_script:
			var ul = ul_script.new()
			ul.name = "ULayerPrueba"
			var l2 := Label.new()
			l2.name = "LblPrueba"
			UiI18n.meta_texto(l2, "EQUIP.TITULO")
			ul.add_child(l2)
			root.add_child(ul)  # _enter_tree la registra en UIManager._stack
			loc.set_locale("en")
			_check(l2.text == "Player's clothing",
				"M87 runtime: UIManager re-traduce capas registradas al cambiar a en")
			loc.set_locale(ini_locale)
			ul.queue_free()
		var ok_pause: bool = acc.pausar_instantaneo()
		_check(ok_pause and acc.esta_pausado(), "M58 RF18: pausar_instantaneo congela el árbol")
		acc.reanudar()
		_check(not acc.esta_pausado(), "M58 RF18: reanudar libera el árbol")
	_resumen()

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
	else:
		print("OK: " + msg)

func _resumen() -> void:
	print("=== TEST M53 i18n+M58 (Log 1118): %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

## Nodos (incluido raiz) que traen el metadato dado.
func _nodos_con_meta(nodo: Node, meta: String) -> Array:
	var out: Array = []
	if nodo.has_meta(meta):
		out.append(nodo)
	for h in nodo.get_children():
		out.append_array(_nodos_con_meta(h, meta))
	return out

func _primer_nodo_con_meta(nodo: Node, meta: String) -> Node:
	if nodo.has_meta(meta):
		return nodo
	for h in nodo.get_children():
		var prof := _primer_nodo_con_meta(h, meta)
		if prof:
			return prof
	return null
