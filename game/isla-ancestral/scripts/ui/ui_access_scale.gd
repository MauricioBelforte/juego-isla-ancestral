# Modelo: GLM-5.3-Flash (G-5.3-Flash-Agente)
# Plataforma: Kilo Code
# Fecha: 2026-10-23
#
# M58: escalado de accesibilidad del UIRoot (0.8 - 2.0).
# Helper SIN ACOPLE (metodologia seccion 15): no toca UIRoot ni M53; solo
# aplica y reporta la escala sobre un CanvasLayer existente. El menu llama
# aqui; el QA lo valida headless.

class_name UIAccessScale
extends RefCounted

const MIN_ESCALA := 0.8
const MAX_ESCALA := 2.0

## Aplica la escala (clampeada) a un CanvasLayer y devuelve el valor efectivo.
static func aplicar(canvas: CanvasLayer, escala: float) -> float:
	if canvas == null:
		return MIN_ESCALA
	var efectiva: float = clampf(escala, MIN_ESCALA, MAX_ESCALA)
	canvas.scale = Vector2(efectiva, efectiva)
	return efectiva

## Escala actualmente aplicada (0.0 si canvas nulo).
static func actual(canvas: CanvasLayer) -> float:
	if canvas == null:
		return 0.0
	return canvas.scale.x
