# Modelo: glm-5.3-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-01
#
# M30: Test iter. 3 — nombres de estación localizables (M87) con fallback.
# Ejecutar: Godot --headless --path game/isla-ancestral --script res://scripts/clock/test_reloj_localizacion.gd

extends SceneTree

# --- Guardia anti-falso-verde (3 capas): _fin() por bloque + CHECKS_MINIMOS MEDIDO
#     + _summary() diferido. Instrumentacion LOTE 1 (suites SIN-DUENO), 2026-10-08,
#     DeepSeek-V4.1-Flash (msg 98). Piso = checks reales MEDIDOS (Log 1490).
#     NO cambia logica ni aserciones; solo agrega contador + control de bloques.
const CHECKS_MINIMOS := 6
const _WB_BLOQUES: Array[String] = ["run"]
var _checks: int = 0
var _wb_vistos: Dictionary = {}
var _wb_cerrado: bool = false


func _fin(nombre: String) -> void:
	_wb_vistos[nombre] = true


func _summary() -> void:
	if _wb_cerrado:
		return
	_wb_cerrado = true
	for b in _WB_BLOQUES:
		if not _wb_vistos.has(b):
			_fallos += 1
			print("[FAIL] bloque %s NO se ejecuto (posible SCRIPT ERROR)" % b)
	if _checks < CHECKS_MINIMOS:
		_fallos += 1
		print("[FAIL] solo %d checks ejecutados (minimo %d)" % [_checks, CHECKS_MINIMOS])
	print("=== Resumen M30: %d checks, %d fallos ===" % [_checks, _fallos])
	quit(1 if _fallos > 0 else 0)

var _fallos: int = 0

func _init() -> void:
	call_deferred("_run")
	call_deferred("_summary")

func _run() -> void:
	var loc := root.get_node_or_null("Localization")
	_check(loc != null, "Localization presente (M87)")
	if loc == null:
		_summary()
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
	_fin("run")
	_summary()

func _check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_fallos += 1
		print("FALLO: " + msg)
