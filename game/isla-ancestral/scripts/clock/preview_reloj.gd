# Modelo: ox-alpha (GLM)
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M30.2: Preview del Widget de Reloj — validación VISUAL (vía V2 capturas).
# Escena generada por código: fondo de cielo + franja de pasto para evaluar
# contraste/legibilidad del HUD en la esquina superior derecha.
# Demo viva: cada 2 s avanza el GameTime real 25 minutos → el reloj cambia
# visiblemente entre capturas (prueba del binding por señales).
extends Control

const WReloj := preload("res://scripts/clock/w_reloj.gd")

var _game_time: Node = null
var _acum := 0.0

func _ready() -> void:
	# FIX M30 (2026-08-26 v4): en lugar de pelear con el escalado DPI de la ventana
	# (cliente ≠ pedido), se MAXIMIZA la ventana: Godot recalcula viewport y zoom
	# con el tamaño real del monitor y el HUD anclado TOP_RIGHT queda siempre
	# dentro del área visible.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	_construir_escena()
	_game_time = get_node_or_null("/root/GameTime")
	_auto_captura()

func _process(delta: float) -> void:
	# Demo: acelera el tiempo para que el reloj avance visiblemente
	if _game_time != null:
		_acum += delta
		while _acum >= 2.0:
			_acum -= 2.0
			for i in range(25):
				_game_time._avanzar_minuto()

func _auto_captura() -> void:
	# Captura in-engine (V4): guarda 2 frames del viewport con 6 s de diferencia
	# para verificar el reloj visible Y el avance de hora en vivo.
	var dir := "res://../../tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real"
	for i in range(2):
		await get_tree().create_timer(3.0 if i == 0 else 6.0).timeout
		var img := get_viewport().get_texture().get_image()
		if img != null:
			var ruta := "%s/cap_30_2026-08-26_20-06-%02d_inengine.png" % [dir, i]
			var err := img.save_png(ruta)
			print("[M30-CAP] frame ", i, " guardado (err=", err, "): ", ruta)

func _w_debug_rect(w: Control) -> void:
	await get_tree().process_frame
	print("[M30-DEBUG] WReloj rect global: ", w.get_global_rect(), " | visible: ", w.visible, " | en_arbol: ", w.is_inside_tree())
	print("[M30-DEBUG] Padre rect: ", get_global_rect(), " | viewport: ", get_viewport_rect().size)
	for hijo in get_children():
		if hijo is Control:
			print("[M30-DEBUG] hijo '", hijo.name, "' tipo=", hijo.get_class(), " rect=", hijo.get_global_rect())

func _construir_escena() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Cielo con gradiente vertical
	var cielo := TextureRect.new()
	var mat := Gradient.new()
	mat.colors = PackedColorArray([Color(0.55, 0.75, 0.95), Color(0.85, 0.92, 0.98)])
	var grad := GradientTexture2D.new()
	grad.gradient = mat
	grad.fill_from = Vector2(0, 0)
	grad.fill_to = Vector2(0, 1)
	cielo.texture = grad
	cielo.set_anchors_preset(Control.PRESET_FULL_RECT)
	cielo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cielo.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(cielo)

	# Franja de pasto abajo
	var pasto := ColorRect.new()
	pasto.color = Color(0.42, 0.62, 0.32)
	pasto.anchor_left = 0.0
	pasto.anchor_right = 1.0
	pasto.anchor_top = 0.78
	pasto.anchor_bottom = 1.0
	add_child(pasto)

	# Sol decorativo
	var sol := ColorRect.new()
	sol.color = Color(1.0, 0.9, 0.5)
	sol.size = Vector2(90, 90)
	sol.position = Vector2(120, 80)
	add_child(sol)

	# El widget en cuestión
	var w = WReloj.new()
	w.name = "WReloj"
	add_child(w)
	# DEBUG M30: verificar rect real del widget tras el layout
	_w_debug_rect.call_deferred(w)

	# Etiqueta informativa
	var hint := Label.new()
	hint.text = "M30 — Preview del Reloj HUD (avance de tiempo acelerado ×25)"
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.15, 0.2, 0.3))
	hint.position = Vector2(20, 12)
	add_child(hint)
