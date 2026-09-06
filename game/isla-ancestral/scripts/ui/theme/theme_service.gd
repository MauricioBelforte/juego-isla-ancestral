# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: ThemeService (autoload "ThemeService").
# Construye el tema cozy (ThemeUx) UNA vez y lo aplica globalmente al root
# (theme del SceneTree). Todas las capas/widgets que no definan tema propio
# lo heredan. Reaplica en cambio de escala (M58), recarga fuentes (M87/M88)
# y se adapta a cambios de resolución (M90/T-053-063).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

var _theme_ux: ThemeUx = null
var _scale: float = 1.0

func _ready() -> void:
	_theme_ux = ThemeUx.new()
	aplicar_tema_global(1.0)
	# T-053-062: al cambio de idioma (M87), recargar fuentes y textos en vivo
	var loc = get_node_or_null("/root/Localization")
	if loc and loc.has_signal("locale_changed"):
		loc.locale_changed.connect(_on_locale_changed)
	# T-053-063: al cambio de resolución (M90), re-aplicar tema y guardas de layout
	var win := get_window()
	if win:
		win.size_changed.connect(_on_window_size_changed)

## Aplica el tema cozy globalmente (árbol completo).
func aplicar_tema_global(scale: float = 1.0) -> void:
	_scale = clampf(scale, 0.8, 1.5)  # límites M58 (ui_scale 0.8-1.5)
	if _theme_ux == null:
		_theme_ux = ThemeUx.new()
	_theme_ux.build()
	_theme_ux.apply(_scale)
	var tree := get_tree()
	if tree and tree.root:
		# El theme del root se hereda a todos los Controls del árbol
		tree.root.theme = _theme_ux.base
	print("[M53] Tema cozy global aplicado (escala %.2f)" % _scale)

## Cambia la escala de UI en vivo (M58 ui_scale 0.8-1.5)
func set_ui_scale(scale: float) -> void:
	aplicar_tema_global(scale)

func get_ui_scale() -> float:
	return _scale

## Recarga fuentes tras cambio de idioma (M87) o carga de M88
func recargar_fuentes() -> void:
	if _theme_ux:
		_theme_ux.reload_after_font_change()
	aplicar_tema_global(_scale)

## T-053-062: callback al cambio de idioma — recarga fuentes y reaplica tema
func _on_locale_changed(_locale: String) -> void:
	recargar_fuentes()

## T-053-063: callback al cambio de tamaño de ventana — re-aplica tema y layout
func _on_window_size_changed() -> void:
	# Reaplicar tema para que los widgets recalculen tamaños
	aplicar_tema_global(_scale)
	# Notificar a las capas abiertas que el viewport cambió
	var ui_mgr = get_node_or_null("/root/UIManager")
	if ui_mgr and ui_mgr.has_signal("viewport_resized"):
		ui_mgr.viewport_resized.emit()
