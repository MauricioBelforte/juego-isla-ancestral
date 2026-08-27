# Modelo: ox-alpha
# Plataforma: Cline
# Fecha: 2026-08-26
#
# M30.1: HUD Reloj — capa de DISPLAY + POLÍTICA (V0, sin visión ni assets)
# Consumidor del GameClock M29 ("/root/GameTime").
# Principio: M30 solo muestra lo que M29 ya calculó; cero lecturas de Time.* del SO.
#
# Responsabilidad de este archivo:
#  - Traducir el estado interno de GameTime a strings listos para Label.
#  - Decidir máscaras de formato (12h/24h, nombre de día, estación).
#  - Ofrecer helpers de estilo visual (color de estación) como constantes enumerables
#    para que la capa UI Toolkit (M30.2) las consuma sin lógica duplicada.
#
# Limitaciones (no resueltas aquí → pendientes `[?]` en checklist):
#  - Layout/posición/tipografía/color de fondo → UI Toolkit real (requiere visión).
#  - Animaciones de fade-in/out del tooltip → M52 shaders (visión).
#  - Localización M57 → consume NOMBRES_* de GameTime por ahora.
extends Node

# ── Formato de hora (configurable en Ajustes M46, default 24h) ───────────────
enum FormatoHora { HORAS_24, HORAS_12 }
enum SesionDia { MAÑANA, DIA, TARDE, NOCHE }

const FORMATO_DEFAULT: int = FormatoHora.HORAS_24

# Mapeo hora→sesión para color/semántica visual (usado por la capa UI).
const HORAS_POR_SESION := {
	SesionDia.MAÑANA:   [6, 7, 8, 9, 10, 11],
	SesionDia.DIA:      [12, 13, 14, 15, 16, 17, 18, 19],
	SesionDia.TARDE:    [20, 21, 22, 23],
	SesionDia.NOCHE:    [0, 1, 2, 3, 4, 5],
}

# Paleta de colores por estación (constantes visuales nombradas, V0/sin assets).
const COLOR_ESTACION := {
	0: Color(0.40, 0.85, 0.40),  # Primavera — verde
	1: Color(0.95, 0.70, 0.20),  # Verano — dorado
	2: Color(0.80, 0.45, 0.20),  # Otoño — rojo otoñal
	3: Color(0.75, 0.85, 0.95),  # Invierno — azul pálido
}

var _formato: int = FORMATO_DEFAULT
var _game_time: Object = null

func _ready() -> void:
	_formato = FORMATO_DEFAULT
	# GameTime es un autoload registrado; se accede como singleton, no con
	# get_node() absoluto (falla en autoload porque no está en el árbol aún).
	_game_time = get_tree().get_root().get_node_or_null("GameTime") if get_tree() else null
	if _game_time == null:
		push_warning("M30: GameTime no disponible en this context; usando mock para test.")

# ── API pública de formateo (consumida por Label.bind en UI Toolkit M30.2) ────
## "HH:MM" usando formato 12h/24h configurado.
func get_hora_str(hora: int = -1, minuto: int = -1) -> String:
	if _game_time != null:
		if hora < 0:   hora   = _game_time.get_hora()
		if minuto < 0: minuto = _game_time.get_minuto()
	if _formato == FormatoHora.HORAS_12:
		var h12 := hora % 12
		if h12 == 0: h12 = 12
		var sufijo := "AM" if hora < 12 else "PM"
		return "%02d:%02d %s" % [h12, minuto, sufijo]
	return "%02d:%02d" % [hora, minuto]

## "Lunes, 12 de Primavera, Año 1"
func get_fecha_str() -> String:
	if _game_time == null:
		return "Fecha desconocida"
	var semana_dia: int = _game_time.get_semana_dia()
	var fecha: Dictionary = _game_time.get_fecha()
	var dia_nombre: String = _game_time.NOMBRES_SEMANA[semana_dia]
	var estacion: int = _game_time.get_estacion()
	var estacion_nombre: String = _game_time.NOMBRES_ESTACIONES[estacion]
	return "%s, %d de %s, Año %d" % [
		dia_nombre, fecha.dia, estacion_nombre, fecha.anio
	]

## Devuelve Color según la estación actual (para fondos/emissive).
func get_color_estacion() -> Color:
	if _game_time == null:
		return COLOR_ESTACION[0]
	return COLOR_ESTACION[_game_time.get_estacion()]

## SESIÓN actual (MAÑANA/DIA/TARDE/NOCHE) para lógica de iluminación/HUD.
func get_sesion_dia(hora: int = -1) -> int:
	if _game_time != null and hora < 0:
		hora = _game_time.get_hora()
	for sesion in range(SesionDia.size()):
		if HORAS_POR_SESION[sesion].has(hora):
			return sesion
	return SesionDia.DIA  # fallback seguro

## SESIÓN actual (versión estática, para tests sin instancia).
static func get_sesion_dia_estatico(hora: int) -> int:
	for sesion in SesionDia.values():
		if HORAS_POR_SESION[sesion].has(hora):
			return sesion
	return SesionDia.DIA  # fallback seguro

## Color de estación (versión estática, para tests).
static func get_color_estacion_estatico(estacion: int) -> Color:
	return COLOR_ESTACION[estacion]

## Setter de formato (conectar a Ajustes M46). Dispara reconstrucción UI.
func set_formato_hora(fmt: int) -> void:
	_formato = fmt
	emit_signal("formato_cambiado", fmt)

signal formato_cambiado(fmt: int)

# ── Helpers para tests / datos de mock (NO consume GameTime) ──────────────────
## Variante pura para testing: formatea con parámetros explícitos.
static func formatear_hora(hora: int, minuto: int, fmt: int) -> String:
	if fmt == FormatoHora.HORAS_12:
		var h12 := hora % 12
		if h12 == 0: h12 = 12
		return "%02d:%02d %s" % [h12, minuto, "AM" if hora < 12 else "PM"]
	return "%02d:%02d" % [hora, minuto]
