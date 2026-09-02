# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M30: Test iter. 3 — nombres de estación localizables (M87) con fallback.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/clock/test_reloj_localizacion.gd

extends SceneTree

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var loc := root.get_node_or_null("Localization")
	_check(loc != null, "Localization presente (M87)")
	if loc == null:
		print("=== TEST M30 ITER3: 1 fallo(s) ===")
		quit(1)
		return
	# El método _estacion_nombre vive en w_reloj.gd (widget del HUD), no en el
	# autoload RelojHud. Instanciamos el widget y lo agregamos al árbol (si no,
	# get_node_or_null("/root/Localization") del widget devuelve null).
	var reloj: Node = load("res://scripts/clock/w_reloj.gd").new()
	root.add_child(reloj)
	# Español (default): nombres traducidos desde el .po
	loc.set_locale("es")
	_check(String(reloj._estacion_nombre(0)) == "Primavera", "es: estación 0 = Primavera")
	_check(String(reloj._estacion_nombre(2)) == "Otoño", "es: estación 2 = Otoño")
	# Inglés: nombres traducidos
	loc.set_locale("en")
	var e0: String = reloj._estacion_nombre(0)
	var e3: String = reloj._estacion_nombre(3)
	print("DEBUG e0=", e0, " e3=", e3)
	_check(String(e0) == "Spring", "en: estación 0 = Spring")
	_check(String(reloj._estacion_nombre(3)) == "Winter", "en: estación 3 = Winter")
	# Volver a español (estado limpio)
	loc.set_locale("es")
	_check(String(reloj._estacion_nombre(1)) == "Verano", "vuelta a es: Verano")
	reloj.free()
	print("=== TEST M30 ITER3: %d fallo(s) ===" % _fallos)
	quit(1 if _fallos > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
