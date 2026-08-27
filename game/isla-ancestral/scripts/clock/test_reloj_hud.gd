# Test headless para M30 RelojHud — lógica de formateo, sin autoload ni visión.
# Patrón idéntico al test M29 (test_calendario.gd): extends SceneTree + preload + new().
# Corre con:
#   godot --headless --path game/isla-ancestral --script res://scripts/clock/test_reloj_hud.gd
extends SceneTree

const RelojHud := preload("res://scripts/clock/reloj_hud.gd")

var _falls := 0
var _checks := 0

func _initialize() -> void:
	call_deferred("_ejecutar")

func _ejecutar() -> void:
	print("=== TEST M30 RelojHud (formateo puro) ===")

	# 24h
	_check("24h 08:00", RelojHud.formatear_hora(8, 0, RelojHud.FormatoHora.HORAS_24) == "08:00")
	_check("24h 23:59", RelojHud.formatear_hora(23, 59, RelojHud.FormatoHora.HORAS_24) == "23:59")
	_check("24h 00:05", RelojHud.formatear_hora(0, 5, RelojHud.FormatoHora.HORAS_24) == "00:05")
	print("[OK] formateo_24h")

	# 12h
	_check("12h 00:00 AM", RelojHud.formatear_hora(0, 0, RelojHud.FormatoHora.HORAS_12) == "12:00 AM")
	_check("12h 12:00 PM", RelojHud.formatear_hora(12, 0, RelojHud.FormatoHora.HORAS_12) == "12:00 PM")
	_check("12h 14:30 PM", RelojHud.formatear_hora(14, 30, RelojHud.FormatoHora.HORAS_12) == "02:30 PM")
	_check("12h 08:05 AM", RelojHud.formatear_hora(8, 5, RelojHud.FormatoHora.HORAS_12) == "08:05 AM")
	print("[OK] formateo_12h")

	# sesión día (estático)
	_check("sesion 6 MAÑANA", RelojHud.get_sesion_dia_estatico(6) == RelojHud.SesionDia.MAÑANA)
	_check("sesion 7 MAÑANA", RelojHud.get_sesion_dia_estatico(7) == RelojHud.SesionDia.MAÑANA)
	_check("sesion 15 DIA", RelojHud.get_sesion_dia_estatico(15) == RelojHud.SesionDia.DIA)
	_check("sesion 19 DIA", RelojHud.get_sesion_dia_estatico(19) == RelojHud.SesionDia.DIA)
	_check("sesion 21 TARDE", RelojHud.get_sesion_dia_estatico(21) == RelojHud.SesionDia.TARDE)
	_check("sesion 23 TARDE", RelojHud.get_sesion_dia_estatico(23) == RelojHud.SesionDia.TARDE)
	_check("sesion 3 NOCHE", RelojHud.get_sesion_dia_estatico(3) == RelojHud.SesionDia.NOCHE)
	_check("sesion 4 NOCHE", RelojHud.get_sesion_dia_estatico(4) == RelojHud.SesionDia.NOCHE)
	print("[OK] sesion_dia")

	# colores (estático)
	_check("color primavera", RelojHud.get_color_estacion_estatico(0) == Color(0.40, 0.85, 0.40))
	_check("color invierno", RelojHud.get_color_estacion_estatico(3) == Color(0.75, 0.85, 0.95))
	print("[OK] color_estacion")

	print("---RESUMEN---")
	print("14 checks, %d fallos — RESUMEN: %s" % [_falls, "OK" if _falls == 0 else "FAIL"])
	quit(1 if _falls > 0 else 0)

func _check(nombre: String, cond: bool) -> void:
	_checks += 1
	if not cond:
		_falls += 1
		print("  [FAIL] " + nombre)
