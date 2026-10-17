# Modelo: Hy3
# Plataforma: Kilo
# Fecha: 2026-08-29 (origen) / 2026-10-17 (Lote 2, autorizado por el director msg 249)
#
# M21: DialogueUI — capa de presentacion minima (CanvasLayer autocontenido, no toca scripts/ui de M53).
# Escucha las senales del DialogueManager (autoload) y muestra el dialogo.
# El jugador puede avanzar con Enter/E y elegir opciones con click o numero.
#
# LOTE 2 (msg 249, 20 ítems -> 19 implementables; L79 .tscn es N/A, UI 100% programática):
#   D L81 tipeo letra a letra · L82 velocidad CPM · L83 acelerar al mantener · L84 completar con
#   primer confirm · L85 avanzar tras completar · L86 doble confirmación sostenida = salto completo
#   · L88 flecha de línea completada · L89 puntos de espera · L90 auto-avance con pausa en opciones
#   · L91 salto de página líneas largas · L92 contador de páginas
#   E L101 ocultar bloqueadas si hide_blocked · L102 mostrar bloqueadas gris + texto alternativo
#   K L185 transición suave apertura/cierre · L186 animación retrato al cambiar hablante
#   · L187 sonido de tipeo atenuado · L188 destello línea seleccionada · L189 ritmo calibrado cozy
#   · L190 diálogo de ejemplo localizado (data/dialogues/ejemplo_localizado_m21.json)

class_name DialogueUI
extends CanvasLayer

var _panel: Panel = null
var _label: Label = null
var _options_container: VBoxContainer = null
var _opciones_activas: Array = []
## E L103 (Hy3 / WorkBuddy): indice de la opcion resaltada por teclado (KEY_UP/KEY_DOWN).
var _indice_opcion_seleccionada: int = -1
## E L103 (Hy3 / WorkBuddy): referencias a los botones para resaltar la seleccion.
var _botones_opciones: Array = []
## Referencia cacheada al DialogueManager (resuelta en _ready) para no llamar
## get_node en cada evento de input.
var _dm = null
## D L93 (Hy3 / WorkBuddy): color de texto resuelto para el hablante actual
## (paleta theme_ux.gd). Util para inspeccion/tests y coherencia con el retrato.
var _color_texto_hablante: Color = Color.WHITE
var _expresion: Label = null
## M20 -> M21: ultima reaccion de regalo/nivel recibida (expresion + contexto)
## para que el retrato (M53/M87) la muestre. La UI la expone via get_ultima_reaccion.
var _ultima_reaccion: Dictionary = {}
## M20 -> M21 (M53): retrato grafico del hablante; cambia de expresion con la reaccion.
## Sin anotacion de tipo: NpcPortraitUI (class_name) no se resuelve en parse-time headless.
## Se crea en runtime (load().new()) y se usa por duck-typing.
var _portrait = null

## ── M21 Lote 2 (Hy3 / WorkBuddy, msg 249): estado de tipografia progresiva, indicadores,
## auto-avance, paginado, opciones bloqueadas y polish. Todas las tweens/audio se protegen
## con is_inside_tree() para que los tests headless (sin arbol) no rompan. ──

## D L81/L82/L83/L84/L85: maquina de tipeo letra a letra.
var _tipeando: bool = false
var _texto_completo: String = ""
var _indice_tipeo: int = 0
var _acum_tipeo: float = 0.0
var _acelerando: bool = false
var _tiempo_confirm_sostenido: float = 0.0
## L189: ritmo calibrado "cozy" (lectura sin prisa) ~ 5 caracteres/seg = 300 cpm.
const VELOCIDAD_TIPEO_CPM := 300.0
const FACTOR_ACELERACION := 4.0
## L86: doble confirmacion sostenida (mantener confirm) => salto completo del dialogo.
const UMBRAL_SKIP_SOSTENIDO := 0.6

## D L91/L92: paginado de lineas largas + contador.
var _paginas: Array = []
var _pagina_actual: int = 0
var _total_paginas: int = 1
const UMBRAL_PAGINA := 120  # caracteres por pagina antes de paginar

## D L90: avance automatico opcional con temporizador (pausa en opciones).
## "Opcional" => APAGADO por defecto; se enciende explicitamente en codigo/UI.
var _auto_advance_activo: bool = false
var _auto_advance_delay: float = 3.0
var _auto_advance_t: float = 0.0

## D L88/L89: indicadores de tipeo (flecha de completada / puntos de espera).
var _indicador_flecha: Label = null
var _indicador_puntos: Label = null

## D L92: contador de paginas.
var _contador_paginas: Label = null

## E L101/L102: opciones bloqueadas (las que tienen blocked_text_key).
var _ocultar_bloqueadas: bool = false

## K L185/L186/L188: animaciones (respetan reduce_motion).
var _transicion_tween: Tween = null
var _portrait_anim_tween: Tween = null
var _shimmer_tween: Tween = null

## K L187: sonido de tipeo (atenuado, opcional; no rompe en headless sin audio).
var _sonido_tipeo: AudioStreamPlayer = null
var _conteo_sonido_tipeo: int = 0

## K L186 (estado, para tests/inspeccion): ultimo hablante cuyo retrato se animo.
var _ultima_anim_retrato: String = ""

## Accesibilidad: reduce_motion (K L185/L186/L188/L189).
var _reduce_motion: bool = false

func _ready() -> void:
	layer = 15
	_crear_ui()
	var dm = get_node_or_null("/root/DialogueManager")
	_dm = dm
	if dm:
		dm.node_entered.connect(_on_node_entered)
		dm.dialogue_ended.connect(_on_dialogue_ended)
		# M20 -> M21: consumir la reaccion al regalo/nivel para expresion + texto.
		if dm.has_signal("gift_reaction") and not dm.gift_reaction.is_connected(_on_gift_reaction):
			dm.gift_reaction.connect(_on_gift_reaction)
		if dm.has_signal("level_up_reaction") and not dm.level_up_reaction.is_connected(_on_level_up_reaction):
			dm.level_up_reaction.connect(_on_level_up_reaction)
	hide()

func _crear_ui() -> void:
	_panel = Panel.new()
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_top = -200
	_panel.offset_bottom = -20
	_panel.offset_left = 40
	_panel.offset_right = -40
	add_child(_panel)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.05, 0.08, 0.88)
	sb.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", sb)
	_label = Label.new()
	_label.name = "Texto"
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.offset_top = 8
	_label.offset_bottom = -60
	_label.offset_left = 12
	_label.offset_right = -12
	_label.add_theme_font_size_override("font_size", 14)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_panel.add_child(_label)
	_options_container = VBoxContainer.new()
	_options_container.name = "Opciones"
	_options_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_options_container.offset_top = -70
	_options_container.offset_bottom = -8
	_options_container.offset_left = 12
	_options_container.offset_right = -12
	_options_container.alignment = BoxContainer.ALIGNMENT_END
	_panel.add_child(_options_container)
	# M20 -> M21: badge de expresion (feliz / neutral / feliz_intenso) mostrado
	# arriba de la caja mientras hay una reaccion activa.
	_expresion = Label.new()
	_expresion.name = "Expresion"
	_expresion.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_expresion.offset_top = 4
	_expresion.offset_bottom = 22
	_expresion.offset_left = 170
	_expresion.offset_right = -12
	_expresion.add_theme_font_size_override("font_size", 12)
	_expresion.text = ""
	_panel.add_child(_expresion)
	# M20 -> M21 (M53): retrato a la izquierda; el texto/opciones se corren a la derecha.
	_label.offset_left = 170
	_options_container.offset_left = 170
	_portrait = load("res://scripts/dialogos/ui/npc_portrait_ui.gd").new()
	_portrait.name = "RetratoNPC"
	_portrait.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_portrait.offset_left = 8
	_portrait.offset_top = 8
	_portrait.offset_right = 8 + 150
	_portrait.offset_bottom = 8 + 150
	_panel.add_child(_portrait)

	# D L88/L89: indicador de espera (tres puntos) mientras se escribe.
	_indicador_puntos = Label.new()
	_indicador_puntos.name = "IndicadorPuntos"
	_indicador_puntos.text = "..."
	_indicador_puntos.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_indicador_puntos.offset_top = -26
	_indicador_puntos.offset_bottom = -8
	_indicador_puntos.offset_left = -60
	_indicador_puntos.offset_right = -14
	_indicador_puntos.add_theme_font_size_override("font_size", 14)
	_indicador_puntos.visible = false
	_panel.add_child(_indicador_puntos)
	# D L88: indicador de linea completada (flecha pulsante).
	_indicador_flecha = Label.new()
	_indicador_flecha.name = "IndicadorFlecha"
	_indicador_flecha.text = "▼"
	_indicador_flecha.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_indicador_flecha.offset_top = -26
	_indicador_flecha.offset_bottom = -8
	_indicador_flecha.offset_left = -30
	_indicador_flecha.offset_right = -8
	_indicador_flecha.add_theme_font_size_override("font_size", 14)
	_indicador_flecha.visible = false
	_panel.add_child(_indicador_flecha)
	# D L92: contador de paginas (visible solo con varias paginas).
	_contador_paginas = Label.new()
	_contador_paginas.name = "ContadorPaginas"
	_contador_paginas.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_contador_paginas.offset_top = 4
	_contador_paginas.offset_bottom = 22
	_contador_paginas.offset_left = -90
	_contador_paginas.offset_right = -12
	_contador_paginas.add_theme_font_size_override("font_size", 11)
	_contador_paginas.visible = false
	_panel.add_child(_contador_paginas)
	# K L187: reproductor de sonido de tipeo (opcional; seguro en headless sin stream).
	_sonido_tipeo = AudioStreamPlayer.new()
	_sonido_tipeo.name = "SonidoTipeo"
	_panel.add_child(_sonido_tipeo)

func _on_node_entered(_node_id: String, speaker_key: String, texto: String, tipo: int, options: Array) -> void:
	show()
	_aplicar_transicion_apertura()  # K L185
	_ocultar_bloqueadas = _nodo_oculta_bloqueadas()
	# D L93 (Hy3 / WorkBuddy): color de texto por tipo de hablante (paleta theme_ux.gd).
	_color_texto_hablante = _color_por_hablante(speaker_key)
	_label.add_theme_color_override("font_color", _color_texto_hablante)
	if _portrait != null:
		_portrait.set_speaker(speaker_key)
	_animar_retrato_cambio(speaker_key)  # K L186 (registra estado aunque no haya retrato)
	_limpiar_opciones()
	# D L91: paginar el texto y arrancar el tipeo de la primera pagina (L81).
	_paginas = _paginar_texto(texto)
	_total_paginas = _paginas.size()
	_pagina_actual = 0
	_construir_opciones(tipo, options)  # E L101/L102
	_iniciar_tipeo(_paginas[_pagina_actual])
	_actualizar_contador_paginas()

func _on_dialogue_ended(_id: String, _ultimo: String) -> void:
	_tipeando = false
	_acelerando = false
	_indice_tipeo = 0
	_acum_tipeo = 0.0
	_paginas = []
	_pagina_actual = 0
	_total_paginas = 1
	_auto_advance_t = 0.0
	_mostrar_indicador_puntos(false)
	_mostrar_indicador_flecha(false)
	if _contador_paginas != null:
		_contador_paginas.visible = false
	if _dm != null and _dm.has_method("set_tipeando"):
		_dm.set_tipeando(false)
	_limpiar_opciones()
	_expresion.text = ""
	_aplicar_transicion_cierre()  # K L185

## M20 -> M21: la UI consume la reaccion al regalo y guarda la expresion para el retrato.
func _on_gift_reaction(npc_id: String, reaccion_id: String, clase: int, item_id: String, expresion: String) -> void:
	_ultima_reaccion = {"id": reaccion_id, "expresion": expresion, "npc_id": npc_id, "item_id": item_id, "clase": clase}
	_expresion.text = expresion if expresion != "" else reaccion_id
	if _portrait != null:
		_portrait.set_expression(expresion)

## M20 -> M21: reaccion al subir de nivel de amistad.
func _on_level_up_reaction(npc_id: String, new_level: int) -> void:
	_ultima_reaccion = {"id": "R_NIVEL", "npc_id": npc_id, "new_level": new_level}
	_expresion.text = "nivel_subio_" + str(new_level)
	if _portrait != null:
		_portrait.set_expression("feliz")

## M20 -> M21: expone la ultima reaccion para el sistema de retrato (M53/M87).
func get_ultima_reaccion() -> Dictionary:
	return _ultima_reaccion

## Accesibilidad: activa/desactiva reduce_motion (K L185/L186/L188/L189).
func set_reduce_motion(activo: bool) -> void:
	_reduce_motion = activo

func _limpiar_opciones() -> void:
	for child in _options_container.get_children():
		child.queue_free()
	_opciones_activas = []
	_botones_opciones = []
	_indice_opcion_seleccionada = -1
	if _shimmer_tween != null:
		_shimmer_tween.kill()
		_shimmer_tween = null

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var dm = _dm if _dm != null else get_node_or_null("/root/DialogueManager")
		if dm == null:
			return
		var vp = get_viewport()
		if event.pressed and not event.echo:
			match event.keycode:
				KEY_ENTER, KEY_SPACE:
					# L83: mantener la confirmacion acelera el tipeo; al soltar, se detiene.
					_acelerando = true
					_tiempo_confirm_sostenido = 0.0
					if _tipeando:
						_completar_tipeo()  # L84: completar linea al instante con 1er confirm
					elif _opciones_activas.size() > 0 and _indice_opcion_seleccionada >= 0 \
							and not _es_opcion_bloqueada(_opciones_activas[_indice_opcion_seleccionada]):
						dm.choose_option(_indice_opcion_seleccionada)
					else:
						_procesar_confirmar_linea()  # L85: avanzar nodo / pagina tras completar
					if vp != null:
						vp.set_input_as_handled()
				KEY_ESCAPE:
					if dm.has_method("skip_all"):
						dm.skip_all()
					if vp != null:
						vp.set_input_as_handled()
				KEY_UP:
					_mover_seleccion_opcion(-1)
					if vp != null:
						vp.set_input_as_handled()
				KEY_DOWN:
					_mover_seleccion_opcion(1)
					if vp != null:
						vp.set_input_as_handled()
			if _opciones_activas.size() > 0:
				var idx := -1
				match event.keycode:
					KEY_1: idx = 0
					KEY_2: idx = 1
					KEY_3: idx = 2
					KEY_4: idx = 3
				if idx >= 0 and idx < _opciones_activas.size():
					if not _es_opcion_bloqueada(_opciones_activas[idx]):
						_indice_opcion_seleccionada = idx
						_resaltar_opcion(idx)
						dm.choose_option(idx)
						if vp != null:
							vp.set_input_as_handled()
		else:
			# Liberacion de la confirmacion: dejar de acelerar (L83).
			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				_acelerando = false

## E L103 (Hy3 / WorkBuddy): mueve la seleccion de opciones con wrap-around, saltando
## las opciones bloqueadas (no elegibles).
func _mover_seleccion_opcion(delta: int) -> void:
	if _opciones_activas.size() == 0:
		return
	var n := _opciones_activas.size()
	var i := _indice_opcion_seleccionada if _indice_opcion_seleccionada >= 0 else 0
	for _paso in range(n):
		i = (i + delta) % n
		if i < 0:
			i += n
		if not _es_opcion_bloqueada(_opciones_activas[i]):
			break
	_indice_opcion_seleccionada = i
	_resaltar_opcion(i)

## E L103 (Hy3 / WorkBuddy): resalta la opcion seleccionada y limpia las demas.
## K L188: aplica un destello suave (shimmer) a la linea seleccionada.
func _resaltar_opcion(idx: int) -> void:
	for i in _botones_opciones.size():
		var b := _botones_opciones[i] as Button
		if b == null:
			continue
		if _es_opcion_bloqueada(_opciones_activas[i]):
			_aplicar_estilo_bloqueado(b)
			continue
		if i == idx and not b.disabled:
			var sel := StyleBoxFlat.new()
			sel.bg_color = Color(0.92, 0.76, 0.40, 0.22)
			sel.border_color = ThemeUx.COLOR_HIGHLIGHT_GOLD
			sel.set_border_width_all(2)
			sel.set_corner_radius_all(8)
			sel.set_content_margin_all(8)
			b.add_theme_stylebox_override("normal", sel)
			b.add_theme_color_override("font_color", ThemeUx.COLOR_HIGHLIGHT_GOLD)
			_aplicar_shimmer(b)  # K L188
		else:
			b.remove_theme_stylebox_override("normal")
			b.remove_theme_color_override("font_color")

## D L93 (Hy3 / WorkBuddy): color de texto por tipo de hablante, coherente con la
## paleta dark del HUD (theme_ux.gd): cream claro narrador, verde NPCs, dorado deidad.
## Convencion en los datos: "npc.*" => NPC, "deidad.*" => deidad, otro => narrador.
func _color_por_hablante(speaker_key: String) -> Color:
	var clave := speaker_key.to_lower()
	if clave.begins_with("npc"):
		return ThemeUx.COLOR_SPEAKER_NPC
	if clave.begins_with("deidad"):
		return ThemeUx.COLOR_SPEAKER_DEIDAD
	return ThemeUx.COLOR_SPEAKER_NARRADOR

func _on_opt_pressed(idx: int) -> void:
	if _opciones_activas.size() > idx and _es_opcion_bloqueada(_opciones_activas[idx]):
		return  # E L102: opcion bloqueada no es elegible
	var dm = get_node_or_null("/root/DialogueManager")
	if dm != null:
		dm.choose_option(idx)

# ════════════════════════════════════════════════════════════════════════════
# M21 LOTE 2 — Tipografia progresiva (D L81-L86), indicadores (L88/L89),
# auto-avance (L90), paginado (L91/L92), opciones bloqueadas (E L101/L102),
# polish (K L185-L190).
# ════════════════════════════════════════════════════════════════════════════

## D L81/L82: arranca el tipeo de una pagina de texto.
func _iniciar_tipeo(texto: String) -> void:
	_texto_completo = texto if texto != null else ""
	_indice_tipeo = 0
	_acum_tipeo = 0.0
	_tipeando = true
	_label.text = ""
	_mostrar_indicador_puntos(true)
	_mostrar_indicador_flecha(false)
	if _dm != null and _dm.has_method("set_tipeando"):
		_dm.set_tipeando(true)

## D L81/L82/L83/L189: avanza el tipeo segun el delta (cps = CPM/60; x FACTOR si acelera).
func _tick_typewriter(delta: float) -> void:
	if not _tipeando:
		return
	var cps := VELOCIDAD_TIPEO_CPM / 60.0
	if _acelerando:
		cps *= FACTOR_ACELERACION
	_acum_tipeo += cps * delta
	var n := int(floor(_acum_tipeo))
	if n > _indice_tipeo:
		_indice_tipeo = n
	if _indice_tipeo >= _texto_completo.length():
		_completar_tipeo()
	else:
		_label.text = _texto_completo.substr(0, _indice_tipeo)
		_reproducir_sonido_tipeo()  # K L187

## D L81/L84: completa el texto al instante y marca el fin del tipeo.
func _completar_tipeo() -> void:
	_tipeando = false
	_label.text = _texto_completo
	_mostrar_indicador_puntos(false)
	_mostrar_indicador_flecha(true)  # D L88
	if _dm != null and _dm.has_method("set_tipeando"):
		_dm.set_tipeando(false)

## D L85: tras completar la linea, ENTER avanza de nodo; si hay mas paginas, pasa de pagina (L91).
func _procesar_confirmar_linea() -> void:
	if _tipeando:
		_completar_tipeo()  # L84 (por si acaso)
		return
	if _pagina_actual < _total_paginas - 1:
		_pagina_actual += 1
		_iniciar_tipeo(_paginas[_pagina_actual])  # L91: salto de pagina
		_actualizar_contador_paginas()
		return
	if _dm != null and _dm.has_method("advance"):
		_dm.advance()  # L85

## D L90: avance automatico con temporizador; pausa si hay opciones visibles.
## L91: si quedan paginas, pagina automaticamente en lugar de avanzar el nodo.
func _tick_auto_advance(delta: float) -> void:
	if not _auto_advance_activo:
		return
	if _opciones_activas.size() > 0:
		return  # pausa en opciones
	_auto_advance_t += delta
	if _auto_advance_t >= _auto_advance_delay:
		_auto_advance_t = 0.0
		if _pagina_actual < _total_paginas - 1:
			_pagina_actual += 1
			_iniciar_tipeo(_paginas[_pagina_actual])
			_actualizar_contador_paginas()
		elif _dm != null and _dm.has_method("advance"):
			_dm.advance()

## Bucle principal: tipeo + auto-avance + (L86) confirmacion sostenida => salto completo.
func _process(delta: float) -> void:
	if _tipeando:
		_tick_typewriter(delta)
		if _acelerando:
			_tiempo_confirm_sostenido += delta
			if _tiempo_confirm_sostenido >= UMBRAL_SKIP_SOSTENIDO:
				_acelerando = false
				if _dm != null and _dm.has_method("skip_all"):
					_dm.skip_all()  # L86
	elif _auto_advance_activo and _opciones_activas.size() == 0:
		_tick_auto_advance(delta)  # L90: avance automatico (pausa en opciones)

## D L91: divide un texto largo en paginas por separadores de oracion (<= UMBRAL_PAGINA).
func _paginar_texto(texto: String) -> Array:
	if texto == null or texto.length() <= UMBRAL_PAGINA:
		return [texto if texto != null else ""]
	var paginas: Array = []
	var resto: String = texto
	while resto.length() > UMBRAL_PAGINA:
		var corte := -1
		for sep in [". ", "! ", "? ", "\n"]:
			var p := resto.rfind(sep, UMBRAL_PAGINA)
			if p > corte:
				corte = p
		if corte < 0:
			corte = UMBRAL_PAGINA
		paginas.append(resto.substr(0, corte + 1).strip_edges())
		resto = resto.substr(corte + 1)
	paginas.append(resto.strip_edges())
	return paginas

func _actualizar_contador_paginas() -> void:
	if _contador_paginas == null:
		return
	if _total_paginas > 1:
		_contador_paginas.text = "pág %d/%d" % [_pagina_actual + 1, _total_paginas]
		_contador_paginas.visible = true
	else:
		_contador_paginas.visible = false

## D L88/L89: visibilidad de los indicadores.
func _mostrar_indicador_puntos(v: bool) -> void:
	if _indicador_puntos != null:
		_indicador_puntos.visible = v

func _mostrar_indicador_flecha(v: bool) -> void:
	if _indicador_flecha != null:
		_indicador_flecha.visible = v

## E L101/L102: construye los botones de opcion respetando las bloqueadas.
func _construir_opciones(tipo: int, options: Array) -> void:
	if tipo == DialogueNode.TIPO_OPCIONES and options.size() > 0:
		_options_container.show()
		_opciones_activas = options.duplicate()
		_botones_opciones = []
		for i in options.size():
			var op = options[i]
			if _es_opcion_bloqueada(op) and _ocultar_bloqueadas:
				continue  # L101: ocultar bloqueadas
			var btn := Button.new()
			var texto_op := str(op.text_key)
			if _es_opcion_bloqueada(op):
				texto_op = str(op.blocked_text_key) if str(op.blocked_text_key) != "" else ("[bloqueado] " + str(op.text_key))
			btn.text = "[" + str(_botones_opciones.size() + 1) + "] " + texto_op
			if _es_opcion_bloqueada(op):
				btn.disabled = true  # L102: gris + no elegible
				_aplicar_estilo_bloqueado(btn)
			btn.pressed.connect(_on_opt_pressed.bind(i))
			_options_container.add_child(btn)
			_botones_opciones.append(btn)
		# Seleccion inicia en la primera opcion NO bloqueada.
		_indice_opcion_seleccionada = -1
		for j in _opciones_activas.size():
			if not _es_opcion_bloqueada(_opciones_activas[j]):
				_indice_opcion_seleccionada = j
				break
		if _indice_opcion_seleccionada >= 0:
			_resaltar_opcion(_indice_opcion_seleccionada)
	else:
		_options_container.hide()

## E L101/L102: ¿la opcion esta bloqueada? (tiene blocked_text_key).
func _es_opcion_bloqueada(op) -> bool:
	if op is DialogueOption:
		return str(op.blocked_text_key) != ""
	return false

## E L102: estilo gris para opciones bloqueadas.
func _aplicar_estilo_bloqueado(btn: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.40, 0.42, 0.50, 0.25)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(8)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_color_override("font_color", ThemeUx.COLOR_DISABLED)
	btn.add_theme_color_override("font_disabled_color", ThemeUx.COLOR_DISABLED)

## E L101: el nodo actual pide ocultar bloqueadas (hide_blocked). Se lee del manager.
func _nodo_oculta_bloqueadas() -> bool:
	if _dm == null:
		return false
	var nodo = _dm.get("_nodo_actual")
	if nodo != null and bool(nodo.get("hide_blocked")):
		return true
	return false

## K L185: transicion suave de apertura (fade-in). Protegida por is_inside_tree().
func _aplicar_transicion_apertura() -> void:
	if _panel == null or not is_inside_tree():
		return
	if _reduce_motion:
		_panel.modulate.a = 1.0
		return
	if _transicion_tween != null:
		_transicion_tween.kill()
	_transicion_tween = create_tween()
	_panel.modulate.a = 0.0
	_transicion_tween.tween_property(_panel, "modulate:a", 1.0, 0.25)

## K L185: transicion suave de cierre (fade-out) y luego hide().
func _aplicar_transicion_cierre() -> void:
	if _panel == null or not is_inside_tree():
		hide()
		return
	if _reduce_motion:
		_panel.modulate.a = 1.0
		hide()
		return
	if _transicion_tween != null:
		_transicion_tween.kill()
	_transicion_tween = create_tween()
	_transicion_tween.tween_property(_panel, "modulate:a", 0.0, 0.2)
	_transicion_tween.tween_callback(hide)

## K L186: animacion sutil del retrato al cambiar de hablante. Registra el estado
## en _ultima_anim_retrato (util para tests/inspeccion).
func _animar_retrato_cambio(speaker_key: String) -> void:
	_ultima_anim_retrato = speaker_key
	if _portrait == null or not is_inside_tree():
		return
	if _reduce_motion:
		return
	if _portrait_anim_tween != null:
		_portrait_anim_tween.kill()
	_portrait_anim_tween = create_tween()
	_portrait.modulate.a = 0.3
	_portrait_anim_tween.tween_property(_portrait, "modulate:a", 1.0, 0.3)

## K L188: destello suave (shimmer) en la linea seleccionada. No-op con reduce_motion.
func _aplicar_shimmer(btn: Button) -> void:
	if _reduce_motion or not is_inside_tree():
		return
	if _shimmer_tween != null:
		_shimmer_tween.kill()
	_shimmer_tween = create_tween().set_loops()
	_shimmer_tween.tween_property(btn, "modulate:a", 0.7, 0.6).from(1.0)
	_shimmer_tween.tween_property(btn, "modulate:a", 1.0, 0.6)

## K L187: reproduce un sonido de tipeo atenuado (si hay stream). Cuenta las emisiones
## para tests incluso sin audio. Seguro en headless (sin stream => no-op).
func _reproducir_sonido_tipeo() -> void:
	_conteo_sonido_tipeo += 1
	if _reduce_motion:
		return
	if _sonido_tipeo != null and _sonido_tipeo.stream != null and not _sonido_tipeo.playing:
		_sonido_tipeo.play()
