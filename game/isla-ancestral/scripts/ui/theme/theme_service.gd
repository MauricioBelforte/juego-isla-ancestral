# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-30
#
# M53: ThemeService (autoload "ThemeService").
# Construye el tema cozy (ThemeUx) UNA vez y lo aplica globalmente al root
# (theme del SceneTree). Todas las capas/widgets que no definan tema propio
# lo heredan. Reaplica en cambio de escala (M58) y recarga fuentes (M87/M88).
# ⚠️ Sin class_name: es autoload (pitfall 07-GUIA-GODOT §9.17/§9.41).

extends Node

var _theme_ux: ThemeUx = null
var _scale: float = 1.0

func _ready() -> void:
	_theme_ux = ThemeUx.new()
	aplicar_tema_global(1.0)

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
