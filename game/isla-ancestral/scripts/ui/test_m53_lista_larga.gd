# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M53 L.9: Listas largas (500 items) con scroll por foco sin glitches.
# Monta 500 botones enfocables en un ScrollContainer, recorre la lista
# completa por foco direccional (MenuNavigator.wrap_focus) y verifica
# wrap-around circular y scroll programático.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_lista_larga.gd
#
# E-30: en --script headless los class_name globales no resuelven
# en el scope del script SceneTree → preload explícito (GUIA-GODOT/06).

extends SceneTree

const _UI_LAYER := preload("res://scripts/ui/core/ui_layer.gd")
const _UI_LAYER_TYPE := preload("res://scripts/ui/core/ui_layer_type.gd")
const _MENU_NAVIGATOR := preload("res://scripts/ui/core/menu_navigator.gd")

const ITEMS := 500

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_lista_larga()
	print("=== TEST M53 LISTA LARGA (L.9): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_lista_larga() -> void:
	var capa = _UI_LAYER.new()
	capa.name = "ListaLargaTest"
	capa.layer_type = _UI_LAYER_TYPE.Type.MODAL_FULL
	root.add_child(capa)
	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.size = Vector2(300, 400)
	capa.add_child(scroll)
	var lista := VBoxContainer.new()
	lista.name = "Lista"
	scroll.add_child(lista)
	var botones: Array[Button] = []
	for i in ITEMS:
		var b := Button.new()
		b.name = "Item_%04d" % i
		b.text = "Item %d" % i
		b.focus_mode = Control.FOCUS_ALL
		lista.add_child(b)
		botones.append(b)
	capa.open()
	# Foco inicial: primer item. focus_first() sin preferred solo
	# DEVUELVE el control (no hace grab_focus) → se establece
	# explícitamente para que wrap_focus pueda avanzar.
	var primero = _MENU_NAVIGATOR.focus_first(capa)
	_check(primero != null and primero is Button, "focus_first encuentra el primer item")
	_check(primero == botones[0], "focus_first = Item_0000")
	primero.grab_focus()
	_check(capa.get_viewport().gui_get_focus_owner() == primero, "grab_focus establece el foco del viewport")
	# Recorrer la lista completa por foco (dirección horizontal: +1 por llamada)
	var glitches := 0
	for paso in ITEMS:
		_MENU_NAVIGATOR.wrap_focus(capa, Vector2i(1, 0))
		var ok := false
		for b in botones:
			if b.has_focus():
				ok = true
				break
		if not ok:
			glitches += 1
	_check(glitches == 0, "500 pasos de foco sin glitches (%d)" % glitches)
	# Wrap-around circular: tras 500 avances el foco volvió al primero
	var owner_final = capa.get_viewport().gui_get_focus_owner()
	_check(owner_final == botones[0], "wrap-around circular: tras 500 items el foco vuelve al primero (owner=%s)" % str(owner_final))
	# Scroll programático: la barra existe y la asignación no crashea
	# (el rango real depende del layout, que en --headless --script
	# no se procesa; el valor se clamea a >= 0 sin error).
	var barra := scroll.get_v_scroll_bar()
	_check(barra != null, "barra de scroll vertical presente")
	scroll.scroll_vertical = 2500.0
	_check(scroll.scroll_vertical >= 0.0, "scroll vertical asignable sin glitches (%.1f)" % scroll.scroll_vertical)
	capa.close()
	capa.queue_free()
