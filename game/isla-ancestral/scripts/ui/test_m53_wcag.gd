# Modelo: Ling 3.1 Flash
# Plataforma: Kilo Code
# Fecha: 2026-10-12
# Actualizado (D102c, dark contract): 2026-10-18 — G-5.3-Flash-Agente / Kilo Code
#
# M53 I.8: Verificación de legibilidad WCAG AA de la paleta ThemeUx.
# Calcula el ratio de contraste (WCAG 2.x, luminancia relativa) de
# las combinaciones texto/fondo de la paleta y verifica los colores
# que CreditsLayer aplica a sus labels en modo normal y alto contraste.
# Desde la flip dark D102 (orden fundador 2026-10-16): assertions alineadas a
# texto claro (cream/casi blanco) sobre paneles noche; el ocre SÍ pasa como
# texto sobre noche (antes no pasaba sobre arena clara).
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_wcag.gd
#
# E-30: en --script headless los class_name globales no resuelven
# en el scope del script SceneTree → preload explícito (GUIA-GODOT/06).

extends SceneTree

const _THEME_UX := preload("res://scripts/ui/theme/theme_ux.gd")
const _CREDITS := preload("res://scripts/ui/layers/credits_layer.gd")
const _TOOLTIP_SVC := preload("res://scripts/ui/services/tooltip_service.gd")
const _NOTIF_SVC := preload("res://scripts/ui/services/notification_service.gd")

var _fallos: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_aplicar_tema_global()
	_test_paleta_wcag()
	_test_credits_colores()
	_test_capas_oscuras()
	print("=== TEST M53 WCAG (I.8): %d checks, %d fallo(s) ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

## Aplica el tema global como en runtime (ThemeService setea tree.root.theme),
## para que los Labels sin override hereden el color real del tema.
func _aplicar_tema_global() -> void:
	var theme_ux = _THEME_UX.new()
	theme_ux.build()
	root.theme = theme_ux.base

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)

## Luminancia relativa WCAG (canales sRGB linealizados)
static func _luminancia(c: Color) -> float:
	return 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b)

static func _lin(v: float) -> float:
	if v <= 0.03928:
		return v / 12.92
	return pow((v + 0.055) / 1.055, 2.4)

## Ratio de contraste WCAG entre dos colores (siempre >= 1.0)
static func _ratio(a: Color, b: Color) -> float:
	var l1 := _luminancia(a)
	var l2 := _luminancia(b)
	if l1 < l2:
		var t := l1
		l1 = l2
		l2 = t
	return (l1 + 0.05) / (l2 + 0.05)

func _test_paleta_wcag() -> void:
	var texto: Color = _THEME_UX.COLOR_TEXT_DARK
	var fondo: Color = _THEME_UX.COLOR_BG_ARENA
	_check(_ratio(texto, fondo) >= 4.5, "TEXT_DARK/BG_ARENA AA (%.2f:1)" % _ratio(texto, fondo))
	_check(_ratio(texto, _THEME_UX.COLOR_HOVER) >= 4.5, "TEXT_DARK/HOVER AA (%.2f:1)" % _ratio(texto, _THEME_UX.COLOR_HOVER))
	_check(_ratio(texto, _THEME_UX.COLOR_PRESSED) >= 4.5, "TEXT_DARK/PRESSED AA (%.2f:1)" % _ratio(texto, _THEME_UX.COLOR_PRESSED))
	_check(_ratio(texto, _THEME_UX.COLOR_DISABLED) >= 4.5, "TEXT_DARK/DISABLED AA (%.2f:1)" % _ratio(texto, _THEME_UX.COLOR_DISABLED))
	_check(_ratio(_THEME_UX.COLOR_HIGHLIGHT_GOLD, fondo) >= 4.5, "GOLD como texto resaltado sobre fondo noche AA (%.2f:1)" % _ratio(_THEME_UX.COLOR_HIGHLIGHT_GOLD, fondo))
	# Alto contraste (ensure_contrast, tema dark desde D102): el texto pasa a
	# casi blanco sobre el panel noche; NUNCA oscuro (era ilegible sobre dark).
	var hc := Color(0.97, 0.96, 0.93)
	_check(_ratio(hc, fondo) >= 4.5, "alto-contraste texto claro/panel noche AA (%.2f:1)" % _ratio(hc, fondo))
	# Documentado (D102c): con la paleta dark, el ocre SÍ pasa AA como texto
	# sobre el panel noche (antes, sobre arena clara, era 2.46:1 y no pasaba).
	# Reserva del dorado: deidad y foco (8.5:1 sobre noche).
	var ocre: Color = _THEME_UX.COLOR_ACCENT_OCRE
	_check(_ratio(ocre, fondo) >= 4.5, "ACCENT_OCRE como texto sobre panel noche AA tras D102 (%.2f:1)" % _ratio(ocre, fondo))
	# El ocre como BORDE no tiene requisito WCAG (no es texto)

func _test_credits_colores() -> void:
	var layer = _CREDITS.new()
	layer.name = "CreditsWcagTest"
	root.add_child(layer)
	# Acceso directo a los labels (find_child no los localiza
	# en --headless --script; los campos son accesibles).
	var copy: Control = layer._lbl_copy
	var farewell: Control = layer._lbl_farewell
	_check(copy != null, "label Copyright presente")
	_check(farewell != null, "label Despedida presente")
	var fondo: Color = _THEME_UX.COLOR_BG_ARENA
	if copy != null:
		var fc: Color = copy.get_theme_color("font_color")
		_check(_ratio(fc, fondo) >= 4.5, "Copyright modo normal AA sobre arena (%.2f:1)" % _ratio(fc, fondo))
	if farewell != null:
		var fc2: Color = farewell.get_theme_color("font_color")
		_check(_ratio(fc2, fondo) >= 4.5, "Despedida modo normal AA sobre arena (%.2f:1)" % _ratio(fc2, fondo))
	# Alternar alto contraste: el acento dorado sobre negro pasa AA
	if layer.has_method("_alternar_contraste"):
		layer._alternar_contraste()
		var negro := Color(0.0, 0.0, 0.0)
		if copy != null:
			var fch: Color = copy.get_theme_color("font_color")
			_check(_ratio(fch, negro) >= 4.5, "Copyright alto contraste AA sobre negro (%.2f:1)" % _ratio(fch, negro))
		if farewell != null:
			var fch2: Color = farewell.get_theme_color("font_color")
			_check(_ratio(fch2, negro) >= 4.5, "Despedida alto contraste AA sobre negro (%.2f:1)" % _ratio(fch2, negro))
	layer.queue_free()

## I.8 (barrido completo): paneles oscuros de servicio (tooltip/toast).
## Sin override de font_color, los Labels heredan el default del tema
## (TEXT_DARK sobre fondo oscuro = ~1.26:1, ilegible). Se instancian
## los servicios reales y se leen los colores aplicados en código.
func _test_capas_oscuras() -> void:
	# Tooltip: título y cuerpo sobre panel oscuro (0.15,0.12,0.10)
	var tooltip_svc = _TOOLTIP_SVC.new()
	tooltip_svc.name = "WcagTooltipSvc"
	root.add_child(tooltip_svc)
	var panel = tooltip_svc._get_from_pool()
	var vbox = panel.get_node("VBox")
	var title = vbox.get_node("Title")
	var body = vbox.get_node("Body")
	var bg: Color = panel.get_theme_stylebox("panel").bg_color
	_check(_ratio(title.get_theme_color("font_color"), bg) >= 4.5, "tooltip título AA sobre panel oscuro (%.2f:1)" % _ratio(title.get_theme_color("font_color"), bg))
	_check(_ratio(body.get_theme_color("font_color"), bg) >= 4.5, "tooltip cuerpo AA sobre panel oscuro (%.2f:1)" % _ratio(body.get_theme_color("font_color"), bg))
	tooltip_svc.queue_free()
	# Toast: icono y texto sobre panel oscuro. _spawn_node crea el panel
	# sincrónicamente (el await del auto-remover viene después).
	var notif_svc = _NOTIF_SVC.new()
	notif_svc.name = "WcagNotifSvc"
	root.add_child(notif_svc)
	notif_svc._spawn_node({text = "Test WCAG", type = _NOTIF_SVC.ToastType.EVENT})
	var toast_panel = notif_svc.get_node("Toast_0")
	var hbox = toast_panel.get_child(0)
	var icon = hbox.get_child(0)
	var texto = hbox.get_child(1)
	var bg2: Color = toast_panel.get_theme_stylebox("panel").bg_color
	_check(_ratio(icon.get_theme_color("font_color"), bg2) >= 4.5, "toast icono AA sobre panel oscuro (%.2f:1)" % _ratio(icon.get_theme_color("font_color"), bg2))
	_check(_ratio(texto.get_theme_color("font_color"), bg2) >= 4.5, "toast texto AA sobre panel oscuro (%.2f:1)" % _ratio(texto.get_theme_color("font_color"), bg2))
	notif_svc.queue_free()
