# Modelo: glm-5.3
# Plataforma: Cline
# Fecha: 2026-08-31
#
# M30 (F100): Config del widget de reloj (data/ui/w_reloj.tres).
# Los defaults replican el comportamiento previo del widget (valores que
# estaban hardcodeados) para que el fallback ante .tres ausente/corrupto
# sea 100% transparente (ítem F107).
# M46 (Ajustes) escribirá este recurso cuando exista; M30 solo lo LEE.
class_name WRelojConfig
extends Resource

## Formato de hora del HUD (F101: 12h/24h; default 24h como hasta ahora).
@export var usar_formato_12h: bool = false
## Margen del panel respecto a los bordes superior/derecho del HUD (px).
@export var margen_borde: int = 16
## Ancho mínimo del panel (px).
@export var ancho_min: int = 230
## Mostrar el chip de estación bajo la fecha.
@export var mostrar_chip_estacion: bool = true
## Fondo del panel (StyleBoxFlat.bg_color).
@export var color_fondo: Color = Color(0.08, 0.09, 0.12, 0.78)
