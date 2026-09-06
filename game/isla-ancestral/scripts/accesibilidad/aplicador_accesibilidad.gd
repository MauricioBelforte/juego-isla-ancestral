# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M58 iter 3: AplicadorAccesibilidad — aplica los factores (texto/contraste)
# a un Label/Control (API mínima de aplicación a la UI).
class_name AplicadorAccesibilidad
extends RefCounted

const SCHEMA := preload("res://scripts/accesibilidad/accesibilidad_schema.gd")
const APLICADOR := preload("res://scripts/accesibilidad/accesibilidad_aplicador.gd")

## Aplica el factor de texto a un Label (font_size base * factor).
static func aplicar_texto(label: Label, config: Dictionary, base_size: int = 16) -> bool:
	if label == null:
		return false
	var factor: float = APLICADOR.factor_texto(config)
	label.add_theme_font_size_override("font_size", int(float(base_size) * factor))
	return true

## Aplica el factor de contraste a un Button/Label (alpha del overlay).
static func aplicar_contraste(control: Control, config: Dictionary, color_base: Color) -> bool:
	if control == null:
		return false
	var factor: float = APLICADOR.factor_contraste(config)
	var c := color_base
	c.a = clampf(c.a * factor, 0.1, 1.0)
	return true
