extends Control
## M53 HUD — MinimapWidget: minimapa con textura caché generada por M54.

var _tex: Texture2D = null
var _jugador_pos := Vector2.ZERO
var _rotacion := 0.0

func set_textura(tex: Texture2D) -> void:
	_tex = tex
	_tex_changed()

func set_jugador(pos: Vector2) -> void:
	_jugador_pos = pos
	_tex_changed()

func set_rotacion(rad: float) -> void:
	_rotacion = rad
	_tex_changed()

func _tex_changed() -> void:
	queue_redraw()

func _draw() -> void:
	if _tex != null:
		draw_texture_rect(_tex, Rect2(Vector2.ZERO, get_size()), false)
	draw_circle(_jugador_pos * get_size() / 500.0, 3.0, Color.WHITE)
