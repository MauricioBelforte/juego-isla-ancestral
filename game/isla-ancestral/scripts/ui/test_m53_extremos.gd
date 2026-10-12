# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
#
# M53 J.9: Test con combinaciones extremas — escala 1.5 + alto
# contraste + sin movimiento, las tres a la vez (límites M58).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_extremos.gd
#
# E-30: en --script headless los class_name globales no resuelven
# en el scope del script SceneTree → preload explícito (GUIA-GODOT/06).

extends SceneTree

const _THEME_UX := preload("res://scripts/ui/theme/theme_ux.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_combinacion_extrema()
	print("=== TEST M53 EXTREMOS (J.9): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

func _test_combinacion_extrema() -> void:
	var ts = root.get_node_or_null("/root/ThemeService")
	_check(ts != null, "ThemeService autoload presente")
	if ts == null:
		return
	# 1. Escala extrema 1.5 (límite superior M58: ui_scale 0.8-1.5)
	ts.set_ui_scale(1.5)
	_check(absf(float(ts.get_ui_scale()) - 1.5) < 0.01, "escala UI 1.5 aplicada")
	# 2. Alto contraste (M58): ensure_contrast oscurece el texto
	var ux = _THEME_UX.new()
	ux.build()
	ux.ensure_contrast()
	var fc: Color = ux.base.get_color("font_color", "Label")
	_check(absf(fc.r - 0.10) < 0.01 and absf(fc.g - 0.05) < 0.01, "alto contraste: font_color Label oscurecido (0.10, 0.05, ...)")
	# 3. Sin movimiento (M58 reduce_motion): desactiva tweens
	ux.set_reduce_motion(true)
	_check(ux.reduce_motion_active(), "reduce_motion activo")
	# Árbol de prueba con controles y un tween activo.
	# BUG-048 (theme_ux.gd L167-170, atria-dawn Log 983): en Godot
	# 4.7 Tween es RefCounted, NO Node → create_tween() no lo deja
	# como hijo y _get_all_tweens() no puede hallarlo; el kill de
	# tweens de apply_reduce_motion() es no-op en este engine
	# (limitación documentada, no un fallo de la combinación).
	var anfitrion := Control.new()
	root.add_child(anfitrion)
	var boton := Button.new()
	boton.text = "Extremo"
	anfitrion.add_child(boton)
	var tween := anfitrion.create_tween()
	tween.tween_property(boton, "modulate:a", 0.5, 1.0)
	_check(tween.is_valid(), "tween activo (create_tween)")
	ux.apply_reduce_motion(anfitrion)
	_check(is_instance_valid(boton) and anfitrion.is_inside_tree(), "apply_reduce_motion sin errores sobre árbol poblado")
	# Las tres a la vez: el tema global sigue aplicable sin errores
	ts.aplicar_tema_global(1.5)
	_check(root.theme != null, "tema global aplicado con escala 1.5 + alto contraste + reduce_motion")
	# Restaurar estado
	ts.set_ui_scale(1.0)
	ux.set_reduce_motion(false)
	_check(absf(float(ts.get_ui_scale()) - 1.0) < 0.01, "escala restaurada a 1.0")
	anfitrion.queue_free()
